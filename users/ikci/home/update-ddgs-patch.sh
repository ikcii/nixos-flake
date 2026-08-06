#!/usr/bin/env bash
set -e

REPO="$HOME/software/hermes-agent"
cd "$REPO"

UPSTREAM="origin"
BRANCH=$(git symbolic-ref --short HEAD)

echo "=== Generating ddgs patch (pyproject.toml + uv.lock) ==="
echo "Branch: $BRANCH"

# Save current ddgs line if it exists
DDGS_LINE=$(grep '^ddgs = \["duckduckgo-search==' pyproject.toml || echo "")
if [ -z "$DDGS_LINE" ]; then
    DDGS_LINE='ddgs = ["duckduckgo-search==7.5.4"]'
fi

# Pull upstream clean (stash local changes)
echo "Pulling upstream..."
git stash save --include-untracked "ddgs-wip" || true
git pull "$UPSTREAM" "$BRANCH"

# Add ddgs group if missing
if ! grep -q '^ddgs = ' pyproject.toml; then
    echo "Adding ddgs group to pyproject.toml..."
    sed -i '/^exa = \["exa-py/i '"$DDGS_LINE"'' pyproject.toml
fi

# Regenerate lockfile
echo "Running uv lock..."
if command -v nix >/dev/null 2>&1; then
    nix develop --command bash -c 'VIRTUAL_ENV="" UV_PYTHON=$(which python) uv lock --upgrade-package duckduckgo-search'
else
    uv lock --upgrade-package duckduckgo-search
fi

# Generate unified patch
echo ""
echo "=== Patch output (copy everything below, including headers) ==="
echo ""
git diff HEAD -- pyproject.toml uv.lock
echo ""
echo "=== End of patch ==="
