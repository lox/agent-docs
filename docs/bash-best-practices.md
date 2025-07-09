# Bash Best Practices

## Style Guide

- Use 2 spaces for indentation (never tabs)
- Consistent indentation throughout

## Compatibility

Target Bash 3.2 for maximum compatibility (macOS default).

## Script Header

```bash
#!/bin/bash
set -euo pipefail
```

- `set -e` - Exit on error
- `set -u` - Exit on undefined variable
- `set -o pipefail` - Fail on pipe errors

## ShellCheck

Always validate with shellcheck (you can install with `hermit install shellcheck`):

```bash
shellcheck script.sh
```

## Variables

```bash
# Quote variables
echo "${VAR}"

# Default values
NAME="${1:-default}"

# Local variables in functions
local var="value"
```

## Conditionals

```bash
# Use [[ ]] for conditionals
if [[ -f "$file" ]]; then
    echo "File exists"
fi

# String comparison
if [[ "$var" = "value" ]]; then
    echo "Match"
fi

# Regex matching (Bash 3.2+)
if [[ "$var" =~ ^[0-9]+$ ]]; then
    echo "Number"
fi
```

## Arrays (Bash 3.2 compatible)

```bash
# Declare arrays
arr=("one" "two" "three")

# Access elements
echo "${arr[0]}"

# Array length
echo "${#arr[@]}"

# Iterate
for item in "${arr[@]}"; do
    echo "$item"
done
```

## Functions

```bash
function process_file() {
  local file="$1"
  local output="${2:-output.txt}"

  [[ -f "$file" ]] || return 1

  # Process...
}

# Call with error handling
process_file "input.txt" || echo "Failed"
```

## Error Handling

```bash
# Cleanup on exit
trap 'rm -f "$TEMP_FILE"' EXIT

# Custom error handler
error() {
  echo "Error: $1" >&2
  exit 1
}

[[ -f "$file" ]] || error "File not found"
```

## Command Substitution

```bash
# Use $() not backticks
result=$(command)

# Capture exit code
if output=$(command 2>&1); then
  echo "Success: $output"
else
  echo "Failed: $output"
fi
```

## Portability

```bash
# Avoid bash 4+ features:
# - Associative arrays
# - ${var,,} lowercase
# - mapfile/readarray

# Use portable alternatives
# Lowercase (portable)
lower=$(echo "$var" | tr '[:upper:]' '[:lower:]')

# Read lines (portable)
while IFS= read -r line; do
  echo "$line"
done < file.txt
```

## Best Practices

1. **Always quote variables**: `"$var"` not `$var`
2. **Use meaningful variable names**: `config_file` not `cf`
3. **Check command existence**: `command -v git >/dev/null`
4. **Prefer `[[ ]]` over `[ ]`** for conditionals
5. **Use `readonly` for constants**: `readonly VERSION="1.0"`
6. **Validate inputs**: Check arguments before use
7. **Use functions**: Break down complex scripts
8. **Add comments**: Explain why, not what

## Common Patterns

```bash
# Safe temporary files
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
  echo "Don't run as root"
  exit 1
fi

# Parse simple options
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done
```
