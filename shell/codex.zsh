# Codex CLI aliases and functions

# cdx - Run codex (all settings from config.toml)
cdx() {
  if [[ "$1" == "update" ]]; then
    npm install -g @openai/codex@latest
  else
    codex "$@"
  fi
}

# Development aliases (optional - uncomment if working on codex)
# alias codex-dev="/Users/lachlan/Projects/lox/codex/codex-rs/target/release/codex-exec"
# alias cdx-dev="/Users/lachlan/Projects/lox/codex/codex-rs/target/release/codex-exec"

# MCP server setup functions (optional - uncomment if using MCP)
# codex-mcp-dev-setup() {
#   claude mcp add codex-dev \
#     /Users/lachlan/Projects/lox/codex/codex-rs/target/release/codex-mcp-server
#   echo "Development Codex MCP server configured. Restart Claude to use it."
# }
#
# codex-mcp-dev-remove() {
#   claude mcp remove codex-dev
#   echo "Development Codex MCP server removed."
# }
