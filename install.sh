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

# Link settings file with user confirmation
link_settings() {
  local target_file="$1"
  local repo_file="$2"
  local name="$3"

  if [ -L "$target_file" ] && [ "$(readlink "$target_file")" = "$repo_file" ]; then
    echo "$name already linked"
  elif [ -f "$repo_file" ]; then
    if [ -f "$target_file" ]; then
      echo "Existing $name found"
      read -p "Replace with symlink to repo? (y/N) " -n 1 -r
      echo
      [[ $REPLY =~ ^[Yy]$ ]] && {
        rm "$target_file"
        ln -s "$repo_file" "$target_file"
        log_success "Linked $name"
      }
    else
      read -p "Link recommended $name? (y/N) " -n 1 -r
      echo
      [[ $REPLY =~ ^[Yy]$ ]] && {
        ln -s "$repo_file" "$target_file"
        log_success "Linked $name"
      }
    fi
  fi
}

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

link_settings "$HOME/.claude/settings.json" "$SCRIPT_DIR/settings/claude/settings.json" "Claude settings"
link_settings "$HOME/.codex/config.toml" "$SCRIPT_DIR/settings/codex/config.toml" "Codex config"

mkdir -p "$HOME/.config/amp"
link_settings "$HOME/.config/amp/settings.json" "$SCRIPT_DIR/settings/amp/settings.json" "Amp settings"

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
for pattern in "/CLAUDE.md" "/AGENTS.md" "/.claude/" "/.codex/" "/.amp/"; do
  grep -q "^${pattern}$" "$GLOBAL_GITIGNORE" 2>/dev/null || echo "$pattern" >>"$GLOBAL_GITIGNORE"
done
log_success "Updated global .gitignore"

# 6. Build binaries
log_info "\nBuilding binaries..."
if command -v go >/dev/null 2>&1; then
  mkdir -p "$SCRIPT_DIR/dist"

  if [ -d "$SCRIPT_DIR/cmd/claude-statusline" ]; then
    go build -o "$SCRIPT_DIR/dist/claude-statusline" "$SCRIPT_DIR/cmd/claude-statusline" 2>/dev/null &&
      log_success "Built claude-statusline" ||
      log_warn "Failed to build claude-statusline"
  fi
else
  log_warn "Go not found - skipping binary builds"
  log_warn "Install Go via Hermit: source bin/activate-hermit && hermit install go"
fi

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
