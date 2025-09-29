#!/usr/bin/env zsh
# Agent CLI shell integration - Source this file in your shell config

# Get the directory of this script
AGENT_SHELL_DIR="${0:A:h}"

# Source individual agent shell scripts
[[ -f "$AGENT_SHELL_DIR/claude.zsh" ]] && source "$AGENT_SHELL_DIR/claude.zsh"
[[ -f "$AGENT_SHELL_DIR/codex.zsh" ]] && source "$AGENT_SHELL_DIR/codex.zsh"

# Additional helper functions
agent-update() {
  echo "Updating agent configurations..."
  cd "$AGENT_SHELL_DIR/.." && git pull && ./install.sh
  echo "Agent configurations updated."
}

# Show available agent commands
agent-help() {
  echo "Available agent commands:"
  echo "  claude         - Run Claude Code CLI"
  echo "  cld            - Run Claude with dangerous permissions skip"
  echo "  cdx            - Run Codex CLI"
  echo "  cdx update     - Update Codex to latest version"
  echo "  agent-update   - Update agent configurations"
  echo "  agent-help     - Show this help message"
}
