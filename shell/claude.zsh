# Claude Code CLI aliases and functions
# shellcheck shell=bash

claude() {
  local claude_bin
  for claude_bin in "$HOME/.claude/local/bin/claude" "$HOME/.claude/local/claude"; do
    if [[ -x "$claude_bin" ]]; then
      "$claude_bin" "$@"
      return
    fi
  done

  claude_bin=$(type -p claude 2>/dev/null || true)
  if [[ -n "$claude_bin" ]]; then
    "$claude_bin" "$@"
    return
  fi

  echo "Claude CLI not found. Run install-agents.sh first." >&2
  return 1
}

# cld - Run Claude with dangerous permissions skip (use with caution)
alias cld="claude --dangerously-skip-permissions"
