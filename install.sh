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

[ -f "$SCRIPT_DIR/AGENT.tpl.md" ] || { log_error "Error: AGENT.tpl.md not found"; exit 1; }

# Process template once, output to both files
template_content=$(sed "s|{{REPO_PATH}}|$SCRIPT_DIR|g" "$SCRIPT_DIR/AGENT.tpl.md")
echo "$template_content" > "$HOME/.claude/CLAUDE.md"
echo "$template_content" > "$HOME/.config/AGENT.md"
log_success "Created CLAUDE.md and AGENT.md"

# 3. Optional: Install settings
log_info "\nSettings configuration..."
SETTINGS_FILE="$HOME/.claude/settings.json"
REPO_SETTINGS="$SCRIPT_DIR/settings/claude.json"

if [ -L "$SETTINGS_FILE" ] && [ "$(readlink "$SETTINGS_FILE")" = "$REPO_SETTINGS" ]; then
  echo "Settings already linked"
elif [ -f "$SETTINGS_FILE" ]; then
  echo "Existing settings.json found"
  log_warn "Review $REPO_SETTINGS for recommended settings"
elif [ -f "$REPO_SETTINGS" ]; then
  read -p "Link recommended settings? (y/N) " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] && { ln -s "$REPO_SETTINGS" "$SETTINGS_FILE"; log_success "Linked settings"; }
fi

# 4. Set up global .gitignore
log_info "\nConfiguring global .gitignore..."
GLOBAL_GITIGNORE="$HOME/.gitignore"
touch "$GLOBAL_GITIGNORE"

git config --global core.excludesfile "$GLOBAL_GITIGNORE" 2>/dev/null || log_warn "Warning: Could not configure git global excludesfile"

# Add patterns if they don't exist
for pattern in "/CLAUDE.md" "/AGENT.md" "/.claude/"; do
  grep -q "^${pattern}$" "$GLOBAL_GITIGNORE" 2>/dev/null || echo "$pattern" >>"$GLOBAL_GITIGNORE"
done
log_success "Updated global .gitignore"

# Done
echo -e "\n${GREEN}✅ Installation complete!${NC}"
echo -e "\nCommands: ${BLUE}~/.claude/commands/${NC}"
echo -e "Claude: ${BLUE}~/.claude/CLAUDE.md${NC}"
echo -e "AmpCode: ${BLUE}~/.config/AGENT.md${NC}"
echo -e "\nType ${BLUE}/${NC} in Claude Code to see available commands"
