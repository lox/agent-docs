#!/bin/bash
set -euo pipefail

green='\033[0;32m' yellow='\033[1;33m' blue='\033[0;34m' red='\033[0;31m' nc='\033[0m'

log_info() { echo -e "${green}$1${nc}"; }
log_warn() { echo -e "${yellow}$1${nc}"; }
log_error() { echo -e "${red}$1${nc}"; }
log_success() { echo -e "${green}✓ $1${nc}"; }

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log_error "Error: $1 is required but not installed."
    exit 1
  fi
}

install_agent() {
  local label="$1"
  local package="$2"
  local binary="$3"
  local prefix="$4"

  log_info "Installing $label..."
  mkdir -p "$prefix"

  if npm install --global --prefix "$prefix" "$package"; then
    local bin_path="$prefix/bin/$binary"
    if [ -x "$bin_path" ]; then
      ln -sf "$bin_path" "$prefix/$binary"
      log_success "$label installed to $bin_path"
    else
      log_error "Failed to locate $binary after installing $package"
      exit 1
    fi
  else
    log_error "npm failed while installing $package"
    exit 1
  fi
}

echo -e "${blue}Agent CLI Installer\n===================${nc}\n"

require_command npm

CLAUDE_NPM_PACKAGE="${CLAUDE_NPM_PACKAGE:-@anthropic-ai/claude-code@latest}"
CODEX_NPM_PACKAGE="${CODEX_NPM_PACKAGE:-@openai/codex@latest}"

CLAUDE_PREFIX="${CLAUDE_PREFIX:-$HOME/.claude/local}"
CODEX_PREFIX="${CODEX_PREFIX:-$HOME/.codex/local}"

install_agent "Claude CLI" "$CLAUDE_NPM_PACKAGE" "claude" "$CLAUDE_PREFIX"
install_agent "Codex CLI" "$CODEX_NPM_PACKAGE" "codex" "$CODEX_PREFIX"

echo
log_info "Ensuring PATH hints..."
for dir in "$CLAUDE_PREFIX/bin" "$CODEX_PREFIX/bin"; do
  if [ -d "$dir" ]; then
    log_info "Add to PATH if missing: export PATH=\"$dir:\$PATH\""
  else
    log_warn "Expected directory missing: $dir"
  fi
done

echo
log_success "Agent CLIs installed. Restart your shell or run: source ~/.zshrc"
