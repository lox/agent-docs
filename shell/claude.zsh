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

  if claude_bin=$(command -v claude 2>/dev/null); then
    if [[ "$claude_bin" == *" is "* ]]; then
      claude_bin="${claude_bin#* is }"
    fi
    if [[ "$claude_bin" == */* && -x "$claude_bin" ]]; then
      "$claude_bin" "$@"
      return
    fi
  fi

  echo "Claude CLI not found. Run install-agents.sh first." >&2
  return 1
}

# cld - Run Claude with dangerous permissions skip (use with caution)
alias cld="claude --dangerously-skip-permissions"
