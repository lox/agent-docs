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
- Settings symlink to `~/.claude/settings.json` (optional)
- Codex config symlink to `~/.codex/config.toml` (optional)
- Global gitignore for project specific files

### CLI Agents

Install the Claude and Codex CLIs with:

```bash
./install-agents.sh
```

The script uses npm under the hood and installs into `~/.claude/local` and `~/.codex/local` so no sudo is required. Override the packages or prefixes with `CLAUDE_NPM_PACKAGE`, `CODEX_NPM_PACKAGE`, `CLAUDE_PREFIX`, or `CODEX_PREFIX` if needed.

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
- `settings/claude/` - Claude Code configuration
- `settings/codex/` - Codex CLI configuration
- `AGENTS.tpl.md` - Global AI configuration template

## Inspiration

- https://www.dzombak.com/blog/2025/08/getting-good-results-from-claude-code/

## License

MIT
