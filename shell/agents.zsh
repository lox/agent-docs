#!/usr/bin/env zsh
# shellcheck disable=SC1071
# Agent CLI shell integration - Source this file in your shell config

# Get the directory of this script
AGENT_SHELL_DIR="${0:A:h}"

# Ensure agent-specific bin directories are on PATH
for agent_bin in "$HOME/.claude/local/bin" "$HOME/.codex/local/bin"; do
  if [[ -d "$agent_bin" && ":$PATH:" != *":$agent_bin:"* ]]; then
    PATH="$agent_bin:$PATH"
  fi
done
export PATH

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
