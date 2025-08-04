---
description: Analyze CI failures for the current PR and provide troubleshooting steps
allowed-tools:
  - Bash
  - mcp__buildkite__*
---

Investigate CI failures for the current pull request and provide detailed troubleshooting guidance.

## Steps to follow:

1. First, get the current PR status and identify failing checks:
!gh pr checks

2. Determine the CI system:
   - If checks contain "buildkite.com": Use Buildkite workflow
   - If checks are from GitHub Actions: Use GitHub workflow

### For GitHub Actions failures:

Use `gh run view` to get logs:
```
gh run view <run-id> --log-failed
```

### For Buildkite failures:

First verify Buildkite MCP tools are available. If `mcp__buildkite__*` tools are missing:
```
❌ Buildkite MCP tools not found!
Setup required: https://github.com/buildkite/buildkite-mcp-server
```

If available:
1. Extract the build number from the failing check URLs (e.g., builds/XXX)
2. Use Buildkite MCP tools to investigate:
   - Get build details with `mcp__buildkite__get_build`
   - Find failed jobs with `mcp__buildkite__get_jobs` (filter by job_state="failed")
   - Retrieve logs for each failed job with `mcp__buildkite__get_job_logs`

3. Analyze the failures and provide:
   - Root cause identification
   - Specific error messages
   - Recommended fixes
   - Commands to run locally to reproduce/fix

## Common issues to check:

- **Missing hermit packages**: Check for "not installed via Hermit" errors
- **Environment variables**: Look for missing GCP_CLOUD_AUDIENCE, HERMIT_GITHUB_TOKEN
- **Test failures**: Extract specific test names and error messages
- **Docker build errors**: Check Dockerfile syntax and base image availability
- **Linting violations**: Identify specific files and rule violations

## Output format:

Provide a clear summary like:

```
🔍 PR #XX CI Failures:

❌ [Check Name] - Failed (exit code)
   Issue: [Root cause]
   Error: [Key error message]
   Fix: [Specific command or action]

✅ Passing checks: X/Y
```

Include any additional context that would help resolve the issues quickly.
