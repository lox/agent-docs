# Agent Docs

Slash commands and documentation for AI coding assistants, specifically [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview) and [AmpCode](https://ampcode.com/manual).

## Installation

```bash
./install.sh
```

This installs:

- Slash commands to `~/.claude/commands/`
- Claude memory to `~/.claude/CLAUDE.md`
- AmpCode config to `~/.config/AGENT.md`
- Settings symlink to `~/.claude/settings.json`
- Global gitignore for project specific files

## Usage

Type `/` in Claude Code to see available commands.

## Structure

- `commands/` - Slash commands
- `docs/` - Reference documentation
- `settings/` - Configuration files
- `CLAUDE.tpl.md` - Claude config template
- `AGENT.tpl.md` - Global AI config template

## Inspiration

- https://www.dzombak.com/blog/2025/08/getting-good-results-from-claude-code/

## License

MIT
