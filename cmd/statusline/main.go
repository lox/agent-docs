package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strings"
	"time"
)

type StatusInput struct {
	SessionID      string `json:"session_id"`
	TranscriptPath string `json:"transcript_path"`
	Model          struct {
		ID          string `json:"id"`
		DisplayName string `json:"display_name"`
	} `json:"model"`
	Workspace struct {
		CurrentDir string `json:"current_dir"`
	} `json:"workspace"`
}

type TranscriptEntry struct {
	Timestamp string `json:"timestamp"`
	Message   struct {
		Usage struct {
			InputTokens              int `json:"input_tokens"`
			CacheCreationInputTokens int `json:"cache_creation_input_tokens"`
			CacheReadInputTokens     int `json:"cache_read_input_tokens"`
			OutputTokens             int `json:"output_tokens"`
		} `json:"usage"`
	} `json:"message"`
}

const defaultContextWindow = 200000

func main() {
	sessionID := flag.String("session", "", "Debug mode: show usage for specific session ID")
	flag.Parse()

	// Session debug mode
	if *sessionID != "" {
		debugSession(*sessionID)
		return
	}

	// Normal status line mode (read from stdin)
	var input StatusInput
	if err := json.NewDecoder(os.Stdin).Decode(&input); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to parse input: %v\n", err)
		os.Exit(1)
	}

	// Get current context from last entry in transcript
	currentTokens := getCurrentContextTokens(input.TranscriptPath)
	contextWindow := getContextWindowForModel(input.Model.ID)

	// Get git branch
	gitBranch := getGitBranch(input.Workspace.CurrentDir)
	dirName := filepath.Base(input.Workspace.CurrentDir)

	// Build status line
	var parts []string
	parts = append(parts, fmt.Sprintf("🤖 %s", input.Model.DisplayName))
	parts = append(parts, fmt.Sprintf("📁 %s", dirName))

	if gitBranch != "" {
		parts = append(parts, fmt.Sprintf("🌿 %s", gitBranch))
	}

	if currentTokens > 0 {
		pct := int(float64(currentTokens) / float64(contextWindow) * 100)

		// Color code based on percentage
		tokenDisplay := formatNumber(currentTokens)
		var coloredTokens string
		if pct >= 80 {
			coloredTokens = fmt.Sprintf("\033[31m%s (%d%%)\033[0m", tokenDisplay, pct)
		} else if pct >= 60 {
			coloredTokens = fmt.Sprintf("\033[33m%s (%d%%)\033[0m", tokenDisplay, pct)
		} else {
			coloredTokens = fmt.Sprintf("%s (%d%%)", tokenDisplay, pct)
		}

		parts = append(parts, fmt.Sprintf("🧠 %s", coloredTokens))
	}

	fmt.Println(strings.Join(parts, " | "))
}

func debugSession(sessionID string) {
	// Construct transcript path
	usr, err := user.Current()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to get user home: %v\n", err)
		os.Exit(1)
	}

	// Find the project directory from transcript paths
	claudeDir := filepath.Join(usr.HomeDir, ".claude", "projects")
	entries, err := os.ReadDir(claudeDir)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to read claude projects dir: %v\n", err)
		os.Exit(1)
	}

	var transcriptPath string
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		candidate := filepath.Join(claudeDir, entry.Name(), sessionID+".jsonl")
		if _, err := os.Stat(candidate); err == nil {
			transcriptPath = candidate
			break
		}
	}

	if transcriptPath == "" {
		fmt.Fprintf(os.Stderr, "Session %s not found\n", sessionID)
		os.Exit(1)
	}

	// Read transcript and get last entry with usage
	file, err := os.Open(transcriptPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to open transcript: %v\n", err)
		os.Exit(1)
	}
	defer file.Close()

	var lastValidEntry TranscriptEntry
	var lineCount int
	scanner := bufio.NewScanner(file)

	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024)

	for scanner.Scan() {
		lineCount++
		var entry TranscriptEntry
		if err := json.Unmarshal(scanner.Bytes(), &entry); err != nil {
			continue
		}
		if entry.Message.Usage.CacheReadInputTokens > 0 || entry.Message.Usage.InputTokens > 0 {
			lastValidEntry = entry
		}
	}

	// Print debug info
	fmt.Printf("Session: %s\n", sessionID)
	fmt.Printf("Transcript: %s\n", transcriptPath)
	fmt.Printf("Total entries: %d\n\n", lineCount)

	if lastValidEntry.Timestamp == "" {
		fmt.Println("No usage data found")
		return
	}

	// Parse timestamp
	ts, _ := time.Parse(time.RFC3339, lastValidEntry.Timestamp)
	fmt.Printf("Last update: %s\n\n", ts.Format("2006-01-02 15:04:05"))

	usage := lastValidEntry.Message.Usage
	currentTokens := usage.CacheReadInputTokens + usage.InputTokens
	contextWindow := 200000 // Default, could detect from model if needed

	// Claude reserves space for system overhead + output buffer
	// System overhead: ~20K (system prompt, tools, memory files)
	// Output buffer: ~33K (safety margin for responses)
	const systemOverhead = 20000
	const outputBuffer = 33000
	const reservedSpace = systemOverhead + outputBuffer
	effectiveWindow := contextWindow - reservedSpace

	pct := int(float64(currentTokens) / float64(contextWindow) * 100)
	effectivePct := int(float64(currentTokens) / float64(effectiveWindow) * 100)

	fmt.Printf("Token Usage:\n")
	fmt.Printf("  Cache read:     %s\n", formatNumber(usage.CacheReadInputTokens))
	fmt.Printf("  Input:          %s\n", formatNumber(usage.InputTokens))
	fmt.Printf("  Cache creation: %s\n", formatNumber(usage.CacheCreationInputTokens))
	fmt.Printf("  Output:         %s\n", formatNumber(usage.OutputTokens))
	fmt.Printf("  ───────────────────────\n")
	fmt.Printf("  Current context: %s (%d%% of total, %d%% of effective)\n",
		formatNumber(currentTokens), pct, effectivePct)
	fmt.Printf("  Total window:    %s\n", formatNumber(contextWindow))
	fmt.Printf("  Reserved space:  %s (system ~%s + output ~%s)\n",
		formatNumber(reservedSpace), formatNumber(systemOverhead), formatNumber(outputBuffer))
	fmt.Printf("  Effective window: %s\n", formatNumber(effectiveWindow))
	fmt.Printf("  Remaining:       %s (%d%%)\n\n",
		formatNumber(effectiveWindow-currentTokens), 100-effectivePct)

	// Color indicator based on effective window
	var status string
	if effectivePct >= 80 {
		status = "🔴 HIGH - Consider /compact"
	} else if effectivePct >= 60 {
		status = "🟡 MEDIUM - Approaching limit"
	} else {
		status = "🟢 LOW - Plenty of space"
	}
	fmt.Printf("Status: %s\n", status)
}

func getCurrentContextTokens(transcriptPath string) int {
	if transcriptPath == "" {
		return 0
	}

	file, err := os.Open(transcriptPath)
	if err != nil {
		return 0
	}
	defer file.Close()

	var lastValidEntry TranscriptEntry
	scanner := bufio.NewScanner(file)

	// Increase buffer size to handle long lines (default is 64KB, we need more)
	buf := make([]byte, 0, 64*1024)
	scanner.Buffer(buf, 1024*1024) // Max 1MB per line

	// Read all entries to get the last one with usage data
	for scanner.Scan() {
		var entry TranscriptEntry
		if err := json.Unmarshal(scanner.Bytes(), &entry); err != nil {
			continue
		}
		// Only keep entries that have usage data
		if entry.Message.Usage.CacheReadInputTokens > 0 || entry.Message.Usage.InputTokens > 0 {
			lastValidEntry = entry
		}
	}

	// Current context = cache_read + input tokens
	return lastValidEntry.Message.Usage.CacheReadInputTokens + lastValidEntry.Message.Usage.InputTokens
}

func getContextWindowForModel(modelID string) int {
	// Check for 1M context variant
	if strings.Contains(modelID, "[1m]") {
		return 1000000
	}

	// All current Claude models support 200K by default
	switch {
	case strings.Contains(modelID, "claude-sonnet-4"):
		return 200000
	case strings.Contains(modelID, "claude-opus-4"):
		return 200000
	case strings.Contains(modelID, "claude-haiku"):
		return 200000
	case strings.Contains(modelID, "claude-3-5-sonnet"):
		return 200000
	case strings.Contains(modelID, "claude-3-opus"):
		return 200000
	case strings.Contains(modelID, "claude-3-haiku"):
		return 200000
	default:
		return defaultContextWindow
	}
}

func getGitBranch(dir string) string {
	cmd := exec.Command("git", "symbolic-ref", "--short", "HEAD")
	cmd.Dir = dir
	output, err := cmd.Output()
	if err != nil {
		// Try to get short hash if detached
		cmd = exec.Command("git", "rev-parse", "--short", "HEAD")
		cmd.Dir = dir
		output, err = cmd.Output()
		if err != nil {
			return ""
		}
	}
	return strings.TrimSpace(string(output))
}

func formatNumber(n int) string {
	if n < 1000 {
		return fmt.Sprintf("%d", n)
	}
	if n < 10000 {
		// 1.0K - 9.9K
		return fmt.Sprintf("%.1fK", float64(n)/1000.0)
	}
	if n < 1000000 {
		// 10K - 999K
		return fmt.Sprintf("%dK", n/1000)
	}
	if n < 10000000 {
		// 1.0M - 9.9M
		return fmt.Sprintf("%.1fM", float64(n)/1000000.0)
	}
	// 10M+
	return fmt.Sprintf("%dM", n/1000000)
}
