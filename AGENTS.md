# Repository Guidelines

## Project Structure & Module Organization
- `commands/` stores Claude slash-command briefs; keep titles, usage, and guardrails accurate.
- `docs/` holds language guidance; refresh when style or workflow rules change.
- `shell/` supplies hooks installed by `install.sh`; match filenames to commands and keep functions idempotent.
- `settings/claude.json` and `AGENTS.tpl.md` are the authoritative configs; edit them together when personas or memories shift.
- `bin/` contains the Hermit bootstrapper; regenerate rather than editing binaries directly.

## Build, Test, and Development Commands
- `./install.sh` installs commands and configs to your home directory; rerun after structural updates.
- `agent-update` refreshes an installed environment from the latest repo state; use it to validate distribution steps.
- `agent-help` lists helper commands and serves as the quickest smoke test for new entries.
- `cdx update` upgrades the Codex CLI; run it when contributions depend on new CLI features.
- `hermit install shellcheck` provisions lint tooling for Bash work on macOS.

## Coding Style & Naming Conventions
- Bash scripts start with `#!/bin/bash` and `set -euo pipefail`, use two-space indentation, and quote variables.
- Markdown headings stay in Title Case with concise, action-oriented sentences and compact lists.
- YAML examples keep two-space indentation and explicit keys; align new command filenames with their slash invocation.

## Testing Guidelines
- Run `shellcheck path/to/script.sh` on every shell modification and resolve all diagnostics.
- Manually exercise updated commands via `claude`, `cdx`, or `agent-help`, and capture the steps in your PR body.
- For Go additions, activate Hermit and run `go test ./...`, using table-driven tests per `docs/go-best-practices.md`.

## Commit & Pull Request Guidelines
- Commits use conventional prefixes (`feat:`, `fix:`, `chore:`, `refactor:`) and explain the motivation in the subject or body.
- Keep change sets atomic; pair documentation and script updates only when they ship the same behavior.
- Pull requests outline user-facing impact, list validation commands, link related issues, and include before/after snippets for template updates.

## Security & Configuration Tips
- Never commit secrets or personal settings; rely on gitignored local overrides instead.
- After editing `AGENTS.tpl.md`, run `agent-update` to refresh installations and verify shell hooks remain `set -u` safe before merging.
