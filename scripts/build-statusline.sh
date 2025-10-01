#!/bin/bash
set -euo pipefail

# Build statusline
echo "Building statusline..."

mkdir -p dist

go build -o dist/statusline ./cmd/statusline

echo ""
echo "✓ Built statusline binary to dist/statusline"
ls -lh dist/statusline
