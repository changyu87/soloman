#!/usr/bin/env bash
# Install the-paradigm as a self-contained Claude Code skill bundle.
#
# Usage:
#   ./install.sh                              # install to ~/.claude/skills/the-paradigm
#   PARADIGM_INSTALL_DIR=/path ./install.sh   # install to a custom location

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${PARADIGM_INSTALL_DIR:-$HOME/.claude/skills/the-paradigm}"
VERSION="0.5.1"

# Attempt to install the writing-plans skill from its official GitHub source.
# Requires git and network. Silent failure — never errors out or changes exit code.
install_writing_plans() {
  local WP_DEST="$HOME/.claude/skills/writing-plans"
  # Skip if already installed.
  if [ -d "$WP_DEST" ] && [ -f "$WP_DEST/SKILL.md" ]; then
    return 0
  fi
  # Require git.
  if ! command -v git &>/dev/null; then
    return 0
  fi
  local TMP_DIR
  TMP_DIR="$(mktemp -d)" || return 0
  if GIT_HTTP_LOW_SPEED_LIMIT=1000 GIT_HTTP_LOW_SPEED_TIME=30 git clone --depth 1 https://github.com/obra/superpowers "$TMP_DIR/superpowers" &>/dev/null; then
    if [ -d "$TMP_DIR/superpowers/skills/writing-plans" ]; then
      mkdir -p "$WP_DEST"
      cp -R "$TMP_DIR/superpowers/skills/writing-plans/" "$WP_DEST/"
    fi
  fi
  rm -rf "$TMP_DIR"
  return 0
}

# Ensure parent dir exists.
mkdir -p "$(dirname "$DEST")"

# If DEST exists, verify it's a paradigm install before replacing.
if [ -e "$DEST" ]; then
  if [ -f "$DEST/SKILL.md" ] && grep -q "^name: the-paradigm" "$DEST/SKILL.md"; then
    rm -rf "$DEST"
  else
    echo "ERROR: $DEST exists and is not a paradigm install. Refusing to overwrite." >&2
    exit 1
  fi
fi

# Assemble the bundle.
mkdir -p "$DEST"
cp    "$SRC/skill/SKILL.md" "$DEST/SKILL.md"
cp -R "$SRC/roles"          "$DEST/roles"
cp -R "$SRC/protocols"      "$DEST/protocols"
cp -R "$SRC/templates"      "$DEST/templates"
cp -R "$SRC/knowledge"      "$DEST/knowledge"
cp -R "$SRC/scripts"        "$DEST/scripts"
chmod +x "$DEST/scripts/clear.sh"

# Write version marker (separate from runtime state).
echo "$VERSION" > "$DEST/VERSION"

# Install optional writing-plans skill (silent failure).
install_writing_plans || true

echo "Installed the-paradigm v$VERSION to $DEST"
echo "Invoke with /the-paradigm in Claude Code."
