package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
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
	// Read JSON input from stdin
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

func getCurrentContextTokens(transcriptPath string) int {
	if transcriptPath == "" {
		return 0
	}

	file, err := os.Open(transcriptPath)
	if err != nil {
		return 0
	}
	defer file.Close()

	var lastEntry TranscriptEntry
	scanner := bufio.NewScanner(file)

	// Read all entries to get the last one
	for scanner.Scan() {
		if err := json.Unmarshal(scanner.Bytes(), &lastEntry); err != nil {
			continue
		}
	}

	// Current context = cache_read + input tokens
	return lastEntry.Message.Usage.CacheReadInputTokens + lastEntry.Message.Usage.InputTokens
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
