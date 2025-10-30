#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' RED='\033[0;31m' NC='\033[0m'

log_info() { echo -e "${GREEN}$1${NC}"; }
log_warn() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }

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

echo -e "${BLUE}Agent CLI Installer\n===================${NC}\n"

require_command npm

CLAUDE_NPM_PACKAGE="${CLAUDE_NPM_PACKAGE:-@anthropic-ai/claude-cli@latest}"
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
