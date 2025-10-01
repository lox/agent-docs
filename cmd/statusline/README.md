# Claude Code Status Line

A fast, lightweight status line implementation for Claude Code that shows current session context usage.

## Features

- **Current context usage**: Shows tokens in current conversation window with percentage
- **Color coding**: Orange at 60%+, red at 80%+ context usage
- **Model-aware**: Automatically detects context window size (200K or 1M)
- **Git integration**: Shows current branch when in a git repository
- **Fast**: ~18-20ms average (reads only current session transcript)

## Status Line Format

```
🤖 Sonnet 4.5 | 📁 agent-docs | 🌿 main | 🧠 172K (86%)
```

- **🤖 Model**: Current Claude model (e.g., Sonnet 4.5, Opus 4)
- **📁 Directory**: Current working directory name
- **🌿 Branch**: Git branch (if in a repo)
- **🧠 Context**: Current conversation context usage (colored by %)

## Color Coding

- **Default** (white): 0-59% context usage
- **Orange** (yellow): 60-79% context usage - approaching limit
- **Red**: 80%+ context usage - close to limit

## Context Window Detection

Automatically detects model context limits:
- **Standard models**: 200K tokens
- **`[1m]` suffix**: 1M tokens (e.g., `claude-sonnet-4-5-20250929[1m]`)

## How It Works

1. Reads JSON input from Claude Code via stdin
2. Opens current session's transcript file (JSONL)
3. Reads last entry to get current token usage
4. Calculates percentage based on model's context window
5. Formats output with colors and returns

### Token Calculation

Current context is calculated from the last transcript entry:
```
current_tokens = cache_read_input_tokens + input_tokens
```

This represents what's currently loaded in the conversation context window.

## Performance

- **Average**: ~18-20ms per call
- **Operations**: Single file open + read to end + JSON parse
- **Update frequency**: Claude Code calls at most every 300ms

Since we only read the current session (not aggregate across all sessions), performance is fast and consistent.

## Building

```bash
go build -o ../../dist/statusline .
```

Or use the build script:
```bash
./scripts/build-statusline.sh
```

## Configuration

Set in `.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "/path/to/dist/statusline"
  }
}
```

## Architecture

**Simple and focused:**
- No caching (current session only)
- No API calls (just local file reads)
- No aggregation (single conversation tracking)
- Minimal dependencies (Go stdlib only)

This keeps the implementation simple, fast, and reliable.
