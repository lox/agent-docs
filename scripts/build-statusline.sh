#!/bin/bash
set -euo pipefail

# Build claude-statusline
echo "Building claude-statusline..."

mkdir -p dist

go build -o dist/claude-statusline ./cmd/claude-statusline

echo ""
echo "✓ Built claude-statusline binary to dist/claude-statusline"
ls -lh dist/claude-statusline
