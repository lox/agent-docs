# Codex CLI aliases and functions

# cdx - Run codex (all settings from config.toml)
cdx() {
  if [[ "$1" == "update" ]]; then
    npm install -g @openai/codex@latest
  else
    codex "$@"
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
