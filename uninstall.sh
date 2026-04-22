#!/usr/bin/env bash
# Uninstall the-paradigm skill bundle.
#
# Usage:
#   ./uninstall.sh                              # remove ~/.claude/skills/the-paradigm
#   PARADIGM_INSTALL_DIR=/path ./uninstall.sh   # remove from a custom location

set -euo pipefail

DEST="${PARADIGM_INSTALL_DIR:-$HOME/.claude/skills/the-paradigm}"

if [ ! -e "$DEST" ]; then
  echo "Nothing to uninstall: $DEST does not exist."
  exit 0
fi

# Safety: only delete if it's a paradigm install.
if [ -f "$DEST/SKILL.md" ] && grep -q "^name: the-paradigm" "$DEST/SKILL.md"; then
  rm -rf "$DEST"
  echo "Uninstalled the-paradigm from $DEST"
else
  echo "ERROR: $DEST does not look like a paradigm install (missing or mismatched SKILL.md). Refusing to delete." >&2
  exit 1
fi
