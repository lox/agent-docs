# AmpCode Configuration
<!-- {{REPO_PATH}} will be replaced with actual path during generation -->

## Documentation

### Language Best Practices

- `@{{REPO_PATH}}/docs/bash-best-practices.md` - Bash scripting (3.2 compatible)
- `@{{REPO_PATH}}/docs/yaml-best-practices.md` - YAML formatting and structure
- `@{{REPO_PATH}}/docs/go-best-practices.md` - Go development patterns

### MCP Development

- `@{{REPO_PATH}}/docs/mcp-best-practices.md` - MCP server development

## Feedback Style

- Be direct and honest - no sugarcoating
- Point out mistakes bluntly
- Challenge incorrect assumptions
- Provide critical code reviews
- Skip the hedging and qualifiers

## Development Approach

- Build incrementally - simplest working code first
- Write a test to prove each piece works
- Execute and verify before adding complexity
- Follow language idioms for testing (pytest, go test, etc.)
- Iterate in small, verifiable steps

## Git Workflow

- Use Conventional Commits: `feat:`, `fix:`, or `chore:` only
- Never commit without explicit permission
- Never push unless specifically requested
- Stage changes and show diff before committing
- Keep commits atomic and focused

