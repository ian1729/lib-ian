#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"
SCRIPTS_HOOKS="$REPO_ROOT/scripts/hooks"

for hook in "$SCRIPTS_HOOKS"/*; do
  name=$(basename "$hook")
  ln -sf "$hook" "$HOOKS_DIR/$name"
  echo "Installed $name"
done
