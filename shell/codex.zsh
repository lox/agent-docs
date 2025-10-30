# Codex CLI aliases and functions
# shellcheck shell=bash

# cdx - Run codex (all settings from config.toml)
CODEX_PREFIX="${CODEX_PREFIX:-$HOME/.codex/local}"
CODEX_PACKAGE="${CODEX_PACKAGE:-@openai/codex@latest}"

cdx() {
  if [[ "$1" == "update" ]]; then
    if command -v npm >/dev/null 2>&1; then
      npm install --global --prefix "$CODEX_PREFIX" "$CODEX_PACKAGE"
    else
      echo "npm is required to update Codex CLI" >&2
      return 1
    fi
  else
    local codex_bin
    codex_bin=$(type -p codex 2>/dev/null || true)
    if [[ -z "$codex_bin" && -x "$CODEX_PREFIX/bin/codex" ]]; then
      codex_bin="$CODEX_PREFIX/bin/codex"
    fi
    if [[ -z "$codex_bin" ]]; then
      echo "Codex CLI not found. Run install-agents.sh first." >&2
      return 1
    fi
    "$codex_bin" "$@"
  fi
}

# Development aliases (for development of codex)
alias codex-dev="/Users/lachlan/Projects/lox/codex/codex-rs/target/release/codex"
alias cdx-dev="/Users/lachlan/Projects/lox/codex/codex-rs/target/release/codex"

codex-mcp-dev-setup() {
  claude mcp add -s user codex-dev \
    /Users/lachlan/Projects/lox/codex/codex-rs/target/release/codex-mcp-server
}

codex-mcp-dev-remove() {
  claude mcp remove codex-dev
  echo "Development Codex MCP server removed."
}

alias codex-list='/Users/lachlan/Projects/agent-docs/shell/codex-list.py'
