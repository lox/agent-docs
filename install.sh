#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' RED='\033[0;31m' NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
log_info() { echo -e "${GREEN}$1${NC}"; }
log_warn() { echo -e "${YELLOW}$1${NC}"; }
log_error() { echo -e "${RED}$1${NC}"; }
log_success() { echo -e "${GREEN}✓ $1${NC}"; }

echo -e "${BLUE}Agent Docs Installer\n====================${NC}\n"

# 1. Install slash commands
log_info "Installing slash commands..."
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"

if [ -d "$SCRIPT_DIR/commands" ]; then
  # Remove existing commands directory if it exists
  [ -d "$CLAUDE_COMMANDS_DIR" ] && rm -rf "$CLAUDE_COMMANDS_DIR"

  # Create symlink to our commands directory
  ln -s "$SCRIPT_DIR/commands" "$CLAUDE_COMMANDS_DIR"

  count=$(find "$CLAUDE_COMMANDS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  log_success "Linked $count commands (auto-updating)"
else
  log_warn "Commands directory not found"
fi

# 2. Create configuration files from template
log_info "\nSetting up configuration files..."
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.codex"

[ -f "$SCRIPT_DIR/AGENTS.tpl.md" ] || {
  log_error "Error: AGENTS.tpl.md not found"
  exit 1
}

# Process template once, output to all files
template_content=$(sed "s|{{REPO_PATH}}|$SCRIPT_DIR|g" "$SCRIPT_DIR/AGENTS.tpl.md")
echo "$template_content" >"$HOME/.claude/CLAUDE.md"
echo "$template_content" >"$HOME/.config/AGENTS.md"
echo "$template_content" >"$HOME/.codex/AGENTS.md"
log_success "Created CLAUDE.md and AGENTS.md in multiple locations"

# 3. Optional: Install settings
log_info "\nSettings configuration..."

# Claude settings
CLAUDE_SETTINGS_FILE="$HOME/.claude/settings.json"
REPO_CLAUDE_SETTINGS="$SCRIPT_DIR/settings/claude/settings.json"

if [ -L "$CLAUDE_SETTINGS_FILE" ] && [ "$(readlink "$CLAUDE_SETTINGS_FILE")" = "$REPO_CLAUDE_SETTINGS" ]; then
  echo "Claude settings already linked"
elif [ -f "$REPO_CLAUDE_SETTINGS" ]; then
  if [ -f "$CLAUDE_SETTINGS_FILE" ]; then
    echo "Existing Claude settings.json found"
    read -p "Replace with symlink to repo settings? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && {
      rm "$CLAUDE_SETTINGS_FILE"
      ln -s "$REPO_CLAUDE_SETTINGS" "$CLAUDE_SETTINGS_FILE"
      log_success "Linked Claude settings"
    }
  else
    read -p "Link recommended Claude settings? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && {
      ln -s "$REPO_CLAUDE_SETTINGS" "$CLAUDE_SETTINGS_FILE"
      log_success "Linked Claude settings"
    }
  fi
fi

# Codex config
CODEX_CONFIG_FILE="$HOME/.codex/config.toml"
REPO_CODEX_CONFIG="$SCRIPT_DIR/settings/codex/config.toml"

if [ -L "$CODEX_CONFIG_FILE" ] && [ "$(readlink "$CODEX_CONFIG_FILE")" = "$REPO_CODEX_CONFIG" ]; then
  echo "Codex config already linked"
elif [ -f "$REPO_CODEX_CONFIG" ]; then
  if [ -f "$CODEX_CONFIG_FILE" ]; then
    echo "Existing Codex config.toml found"
    read -p "Replace with symlink to repo config? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && {
      rm "$CODEX_CONFIG_FILE"
      ln -s "$REPO_CODEX_CONFIG" "$CODEX_CONFIG_FILE"
      log_success "Linked Codex config"
    }
  else
    read -p "Link recommended Codex config? (y/N) " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] && {
      ln -s "$REPO_CODEX_CONFIG" "$CODEX_CONFIG_FILE"
      log_success "Linked Codex config"
    }
  fi
fi

# 4. Install shell hooks
log_info "\nSetting up shell hooks..."
SHELL_CONFIG="$HOME/.zshrc"
HOOKS_SOURCE="source $SCRIPT_DIR/shell/agents.zsh"

[ -f "$SHELL_CONFIG" ] || touch "$SHELL_CONFIG"

if grep -Fq "$HOOKS_SOURCE" "$SHELL_CONFIG" 2>/dev/null; then
  echo "Shell hooks already installed in $SHELL_CONFIG"
else
  {
    echo ""
    echo "# Agent CLI hooks"
    echo "$HOOKS_SOURCE"
  } >>"$SHELL_CONFIG"
  log_success "Added hooks to $SHELL_CONFIG (restart shell or run: source $SHELL_CONFIG)"
fi

# 5. Set up global .gitignore
log_info "\nConfiguring global .gitignore..."
GLOBAL_GITIGNORE="$HOME/.gitignore"
touch "$GLOBAL_GITIGNORE"

git config --global core.excludesfile "$GLOBAL_GITIGNORE" 2>/dev/null || log_warn "Warning: Could not configure git global excludesfile"

# Add patterns if they don't exist
for pattern in "/CLAUDE.md" "/AGENTS.md" "/.claude/" "/.codex/"; do
  grep -q "^${pattern}$" "$GLOBAL_GITIGNORE" 2>/dev/null || echo "$pattern" >>"$GLOBAL_GITIGNORE"
done
log_success "Updated global .gitignore"

# Done
echo -e "\n${GREEN}✅ Installation complete!${NC}"
echo -e "\nCommands: ${BLUE}~/.claude/commands/${NC}"
echo -e "Claude: ${BLUE}~/.claude/CLAUDE.md${NC}"
echo -e "AmpCode: ${BLUE}~/.config/AGENTS.md${NC}"
echo -e "Codex: ${BLUE}~/.codex/AGENTS.md${NC}"
echo -e "\nType ${BLUE}/${NC} in Claude Code to see available commands"
echo -e "\nShell commands (after restart or source):"
echo -e "  ${BLUE}claude${NC} - Run Claude Code CLI"
echo -e "  ${BLUE}cdx${NC} - Run Codex CLI"
echo -e "  ${BLUE}agent-help${NC} - Show all agent commands"
