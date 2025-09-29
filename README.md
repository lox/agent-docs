# Agent Docs

Slash commands and documentation for AI coding assistants, specifically [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) and [AmpCode](https://ampcode.com/manual).

## Installation

```bash
./install.sh
```

This installs:

- Slash commands to `~/.claude/commands/`
- Claude memory to `~/.claude/CLAUDE.md`
- AmpCode config to `~/.config/AGENTS.md`
- Codex config to `~/.codex/AGENTS.md`
- Shell hooks for CLI commands (optional)
- Settings symlink to `~/.claude/settings.json`
- Global gitignore for project specific files

## Usage

### Slash Commands
Type `/` in Claude Code to see available commands.

### Shell Commands
After installation and shell restart:

- `claude` - Run Claude Code CLI
- `cld` - Run Claude with dangerous permissions skip
- `cdx` - Run Codex CLI
- `cdx update` - Update Codex to latest version
- `agent-update` - Update agent configurations from this repo
- `agent-help` - Show all available agent commands

## Structure

- `commands/` - Slash commands for Claude Code
- `docs/` - Reference documentation and best practices
- `shell/` - Shell integration scripts
- `settings/` - Configuration files
- `AGENTS.tpl.md` - Global AI configuration template

## Inspiration

- https://www.dzombak.com/blog/2025/08/getting-good-results-from-claude-code/

## License

MIT
