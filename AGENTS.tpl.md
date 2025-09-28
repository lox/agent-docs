# Agent Configuration

## ALWAYS (Every Task)
- Study existing code first
- Follow project conventions
- Test before implementing
- Maximum 3 attempts, then ask

## NEVER (Safety Rules)
- Commit without permission
- Push without explicit request
- Use --no-verify or --no-gpg-sign
- Disable failing tests
- Make assumptions without verification

## Implementation Cycle
1. Red: Write failing test
2. Green: Minimal code to pass
3. Refactor: Clean with tests passing
4. Verify: Run build, tests, linter

## Choose Solutions By
1. Can I test it easily?
2. Will others understand it?
3. Does it match the project?
4. Is it the simplest approach?

## Git Commits
- Format: `feat:`, `fix:`, or `chore:`
- One logical change per commit
- Explain "why" not "what"
- Show diff before committing

## Error Handling
- Fail fast with clear messages
- Include debugging context
- Never swallow exceptions

## Language References
- @{{REPO_PATH}}/docs/bash-best-practices.md
- @{{REPO_PATH}}/docs/yaml-best-practices.md
- @{{REPO_PATH}}/docs/go-best-practices.md

## Communication
Direct feedback only. Skip pleasantries.
