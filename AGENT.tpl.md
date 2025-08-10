# Core Development Guidelines

## Critical Safety Rules (ALWAYS APPLY)

- **NEVER commit without explicit permission**
- **NEVER use git --no-verify or --no-gpg-sign flags**
- **NEVER disable tests instead of fixing them, even if failures seem unrelated**
- **Maximum 3 attempts per issue, then STOP and ask for help**
- **ALWAYS verify with existing code before making assumptions**

## Core Philosophy

- **Incremental progress** - Small changes that compile and pass tests
- **Simplicity first** - Choose boring, obvious solutions
- **Test-driven** - Write tests first when possible
- **Learn from code** - Study existing patterns before implementing

## Specialist Delegation

When encountering specialized tasks, delegate to appropriate sub-agents:

### Available Specialists

- **planning-specialist**: Strategic planning and long-term context management
  - Use PROACTIVELY for multi-stage projects and complex breakdowns
  
- **git-specialist**: Git operations (commits, merges, rebases, PRs)
  - Use PROACTIVELY for any git workflow tasks

- **debug-specialist**: Systematic debugging and root cause analysis
  - Use PROACTIVELY when errors occur or debugging is needed

- **test-specialist**: Test generation and testing strategies
  - Use PROACTIVELY for writing or fixing tests

- **implementation-specialist**: Feature implementation and refactoring
  - Use PROACTIVELY for new features or code improvements

## Quick Decision Framework

When making choices:
1. **Testability** - Can I easily test this?
2. **Readability** - Will someone understand in 6 months?
3. **Consistency** - Does this match project patterns?
4. **Simplicity** - Is this the simplest working solution?

## Language Best Practices

Refer to guides for language-specific patterns:
- `@{{REPO_PATH}}/docs/bash-best-practices.md` - Bash scripting
- `@{{REPO_PATH}}/docs/yaml-best-practices.md` - YAML formatting
- `@{{REPO_PATH}}/docs/go-best-practices.md` - Go development

## Remember

- Build incrementally with working commits
- Stop after 3 failed attempts and reassess
- Follow project conventions over personal preferences
- When stuck, document what failed and try a different approach
