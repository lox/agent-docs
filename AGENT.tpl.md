# Development Guidelines

## Philosophy

### Core Beliefs

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

### Simplicity Means

- Single responsibility per function/class
- Avoid premature abstractions
- No clever tricks - choose the boring solution

## Process

### 1. Planning & Staging

Break complex work into 3-5 stages. Document in `PLAN.md`:

```markdown
## Stage N: [Name]
**Goal**: [Specific deliverable]
**Success Criteria**: [Testable outcomes]
**Tests**: [Specific test cases]
**Status**: [Not Started|In Progress|Complete]
```

- Update status as you progress
- Remove file when all stages are done

### 2. Implementation Flow

1. **Understand** - Study existing patterns in codebase
2. **Test** - Write test first (red)
3. **Implement** - Minimal code to pass (green)
4. **Refactor** - Clean up with tests passing
5. **Commit** - With clear message linking to plan

### 3. When Stuck (After 3 Attempts)

**CRITICAL**: Maximum 3 attempts per issue, then STOP and ask for assistance.

1. **Document what failed**:
   - What you tried
   - Specific error messages
   - Why you think it failed

2. **Research alternatives**:
   - Find 2-3 similar implementations
   - Note different approaches used

3. **Question fundamentals**:
   - Is this the right abstraction level?
   - Can this be split into smaller problems?
   - Is there a simpler approach entirely?

4. **Try different angle**:
   - Different library/framework feature?
   - Different architectural pattern?
   - Remove abstraction instead of adding?

## Technical Standards

### Architecture Principles

- **Composition over inheritance** - Use dependency injection
- **Interfaces over singletons** - Enable testing and flexibility
- **Explicit over implicit** - Clear data flow and dependencies
- **Test-driven when possible** - Never disable tests, fix them

### Code Quality

- **Every commit must**:
  - Compile successfully
  - Pass all existing tests
  - Include tests for new functionality
  - Follow project formatting/linting

- **Before committing**:
  - Run formatters/linters
  - Self-review changes
  - Ensure commit message explains "why"

### Error Handling

- Fail fast with descriptive messages
- Include context for debugging
- Handle errors at appropriate level
- Never silently swallow exceptions

## Decision Framework

When multiple valid approaches exist, choose based on:

1. **Testability** - Can I easily test this?
2. **Readability** - Will someone understand this in 6 months?
3. **Consistency** - Does this match project patterns?
4. **Simplicity** - Is this the simplest solution that works?
5. **Reversibility** - How hard to change later?

## Project Integration

### Learning the Codebase

- Find 3 similar features/components
- Identify common patterns and conventions
- Use same libraries/utilities when possible
- Follow existing test patterns

### Tooling

- Use project's existing build system
- Use project's test framework
- Use project's formatter/linter settings
- Don't introduce new tools without strong justification

## Quality Gates

### Definition of Done

- [ ] Tests written and passing
- [ ] Code follows project conventions
- [ ] No linter/formatter warnings
- [ ] Commit messages are clear
- [ ] Implementation matches plan
- [ ] No TODOs that we haven't covered in the future plan

### Test Guidelines

- Test behavior, not implementation
- One assertion per test when possible
- Clear test names describing scenario
- Use existing test utilities/helpers/frameworks
- Tests should be deterministic and FAST

## Key Tools to Use

You have access to Zen tools to supplement your existing capabilities, use them!

- Need deeper thinking? → `thinkdeep` (extends analysis, finds edge cases, use o3-pro for heavy lifting)
- If you are about to reply "You're absolutely right!", use `challenge` (challenges assumptions, encourages thoughtful re-evaluation)
- Need to break down complex projects? → `planner` (step-by-step planning, project structure, breaking down complex ideas)
- Pre-commit validation? → `precommit` (validate git changes before committing)
- Something's broken? → `debug` (systematic investigation, step-by-step root cause analysis)
- Want to understand complex code? → `analyze` (architecture, patterns, dependencies)
- Code needs refactoring? → `refactor` (intelligent refactoring with decomposition focus)

Beyond that you have access to a web browser via playwright.

### Language Best Practices

These are guides you should use to understand best practices for the various languages we work in.

- `@{{REPO_PATH}}/docs/bash-best-practices.md` - Bash scripting (3.2 compatible)
- `@{{REPO_PATH}}/docs/yaml-best-practices.md` - YAML formatting and structure
- `@{{REPO_PATH}}/docs/go-best-practices.md` - Go development patterns

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

## Important Reminders

- NEVER use `--no-verify` to bypass commit hooks
- NEVER use `--no-gpg-sign` to bypass commit signing
- NEVER disable tests instead of fixing them
- NEVER Commit code that doesn't compile
- NEVER Make assumptions - verify with existing code

- ALWAYS Commit working code incrementally, matching the commit conventions for the repo
- ALWAYS Update plan documentation as you go
- ALWAYS Learn from existing implementations
- ALWAYS Stop after 3 failed attempts and reassess
