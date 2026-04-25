#!/usr/bin/env bash
# Install soloman as a self-contained skill bundle for Trae.
#
# Usage:
#   ./install.sh                              # install to ~/.trae-cn/skills/soloman
#   SOLOMAN_INSTALL_DIR=/path ./install.sh   # install to a custom location

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="0.3.0"

# Set destination
DEST="${SOLOMAN_INSTALL_DIR:-$HOME/.trae-cn/skills/soloman}"
ENVIRONMENT="Trae"

# Attempt to install the writing-plans skill from its official GitHub source.
# Requires git and network. Silent failure — never errors out or changes exit code.
install_writing_plans() {
  local WP_DEST="$HOME/.trae-cn/skills/writing-plans"
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

# If DEST exists, verify it's a soloman install before replacing.
if [ -e "$DEST" ]; then
  if [ -f "$DEST/SKILL.md" ] && grep -q "^name: soloman" "$DEST/SKILL.md"; then
    rm -rf "$DEST"
  else
    echo "ERROR: $DEST exists and is not a soloman install. Refusing to overwrite." >&2
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

echo "Installed soloman v$VERSION to $DEST"
echo "Invoke with /soloman in $ENVIRONMENT."
