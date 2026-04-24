#!/usr/bin/env bash
# Uninstall soloman skill bundle.
#
# Usage:
#   ./uninstall.sh                              # remove ~/.claude/skills/soloman
#   SOLOMAN_INSTALL_DIR=/path ./uninstall.sh   # remove from a custom location

set -euo pipefail

DEST="${SOLOMAN_INSTALL_DIR:-$HOME/.claude/skills/soloman}"

if [ ! -e "$DEST" ]; then
  echo "Nothing to uninstall: $DEST does not exist."
  exit 0
fi

# Safety: only delete if it's a soloman install.
if [ -f "$DEST/SKILL.md" ] && grep -q "^name: soloman" "$DEST/SKILL.md"; then
  rm -rf "$DEST"
  echo "Uninstalled soloman from $DEST"
else
  echo "ERROR: $DEST does not look like a soloman install (missing or mismatched SKILL.md). Refusing to delete." >&2
  exit 1
fi
