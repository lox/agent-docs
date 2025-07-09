#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Agent Docs Installer${NC}"
echo -e "${BLUE}====================${NC}"
echo

# 1. Install slash commands
echo -e "${GREEN}Installing slash commands...${NC}"
CLAUDE_COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$CLAUDE_COMMANDS_DIR"

if [ -d "$SCRIPT_DIR/commands" ]; then
  cp "$SCRIPT_DIR/commands"/*.md "$CLAUDE_COMMANDS_DIR/" 2>/dev/null || {
    echo -e "${YELLOW}No command files found${NC}"
  }
  count=$(find "$CLAUDE_COMMANDS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${GREEN}✓ Installed $count commands${NC}"
fi

# 2. Create CLAUDE.md from template
echo -e "\n${GREEN}Setting up CLAUDE.md...${NC}"
CLAUDE_MD="$HOME/.claude/CLAUDE.md"

if [ -f "$SCRIPT_DIR/CLAUDE.tpl.md" ]; then
  # Process template - replace {{REPO_PATH}} with actual path
  sed "s|{{REPO_PATH}}|$SCRIPT_DIR|g" "$SCRIPT_DIR/CLAUDE.tpl.md" >"$CLAUDE_MD"
  echo -e "${GREEN}✓ Created CLAUDE.md${NC}"
else
  echo -e "${RED}Error: CLAUDE.tpl.md not found${NC}"
  exit 1
fi

# 3. Create AGENT.md from template
echo -e "\n${GREEN}Setting up AGENT.md...${NC}"
AGENT_MD="$HOME/.config/AGENT.md"
mkdir -p "$HOME/.config"

if [ -f "$SCRIPT_DIR/AGENT.tpl.md" ]; then
  # Process template - replace {{REPO_PATH}} with actual path
  sed "s|{{REPO_PATH}}|$SCRIPT_DIR|g" "$SCRIPT_DIR/AGENT.tpl.md" >"$AGENT_MD"
  echo -e "${GREEN}✓ Created AGENT.md${NC}"
else
  echo -e "${RED}Error: AGENT.tpl.md not found${NC}"
  exit 1
fi

# 4. Optional: Install settings
echo -e "\n${GREEN}Settings configuration...${NC}"
SETTINGS_FILE="$HOME/.claude/settings.json"
REPO_SETTINGS="$SCRIPT_DIR/settings/claude.json"

if [ -L "$SETTINGS_FILE" ] && [ "$(readlink "$SETTINGS_FILE")" = "$REPO_SETTINGS" ]; then
  echo "Settings already linked"
elif [ -f "$SETTINGS_FILE" ]; then
  echo "Existing settings.json found"
  echo -e "${YELLOW}Review $REPO_SETTINGS for recommended settings${NC}"
else
  if [ -f "$REPO_SETTINGS" ]; then
    read -p "Link recommended settings? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      ln -s "$REPO_SETTINGS" "$SETTINGS_FILE"
      echo -e "${GREEN}✓ Linked settings${NC}"
    fi
  fi
fi

# 5. Set up global .gitignore
echo -e "\n${GREEN}Configuring global .gitignore...${NC}"
GLOBAL_GITIGNORE="$HOME/.gitignore"
touch "$GLOBAL_GITIGNORE"

git config --global core.excludesfile "$GLOBAL_GITIGNORE" 2>/dev/null || {
  echo -e "${YELLOW}Warning: Could not configure git global excludesfile${NC}"
}

# Add patterns if they don't exist
for pattern in "/CLAUDE.md" "/AGENT.md" "/.claude/"; do
  grep -q "^${pattern}$" "$GLOBAL_GITIGNORE" 2>/dev/null || echo "$pattern" >>"$GLOBAL_GITIGNORE"
done
echo -e "${GREEN}✓ Updated global .gitignore${NC}"

# Done
echo -e "\n${GREEN}✅ Installation complete!${NC}"
echo
echo -e "Commands installed to: ${BLUE}~/.claude/commands/${NC}"
echo -e "Claude memory: ${BLUE}~/.claude/CLAUDE.md${NC}"
echo -e "AmpCode memory: ${BLUE}~/.config/AGENT.md${NC}"
echo -e "\nType ${BLUE}/${NC} in Claude Code to see available commands"
