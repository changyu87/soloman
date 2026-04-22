#!/usr/bin/env bash
# clear.sh — destructive paradigm-state clear.
# Two-phase: dry-run (prints manifest) vs --confirmed (performs deletion).
#
# Usage:
#   scripts/clear.sh <tier>                 # prints manifest, exits 0
#   scripts/clear.sh <tier> --confirmed     # performs deletion
#   tier ∈ {default, active, all}
#
# STATE_ROOT is taken from env (set by the Interfacer) or derived from cwd.

set -euo pipefail

TIER="${1:-default}"
CONFIRMED="${2:-}"

STATE_ROOT="${STATE_ROOT:-$(pwd)/.paradigm}"

case "$TIER" in
  default|active|all) ;;
  *) echo "ERROR: tier must be one of: default, active, all" >&2; exit 2 ;;
esac

print_manifest() {
  case "$TIER" in
    default)
      echo "Will be deleted:"
      echo "  $STATE_ROOT/state/current.md"
      echo "  $STATE_ROOT/state/session-log.md"
      echo "  $STATE_ROOT/state/resume.md"
      echo "  $STATE_ROOT/state/checkpoints/"
      echo ""
      echo "Will NOT be touched:"
      echo "  $STATE_ROOT/config.yaml"
      echo "  $STATE_ROOT/workstreams/"
      echo "  $STATE_ROOT/knowledge/"
      echo "  $STATE_ROOT/roles/"
      ;;
    active)
      echo "Will be deleted:"
      echo "  $STATE_ROOT/state/ (current.md, session-log.md, resume.md, checkpoints/)"
      echo "  $STATE_ROOT/workstreams/active/*"
      echo ""
      echo "Will NOT be touched:"
      echo "  $STATE_ROOT/config.yaml"
      echo "  $STATE_ROOT/workstreams/completed/"
      echo "  $STATE_ROOT/knowledge/"
      echo "  $STATE_ROOT/roles/"
      ;;
    all)
      echo "Will be deleted:"
      echo "  $STATE_ROOT  (the entire .paradigm/ directory)"
      echo ""
      echo "Will NOT be touched:"
      echo "  (nothing — the project will need re-initialization next session)"
      ;;
  esac
  echo ""
  echo "Confirmation token: YES, CLEAR ${TIER}"
}

do_clear() {
  case "$TIER" in
    default)
      rm -f  "$STATE_ROOT/state/current.md"
      rm -f  "$STATE_ROOT/state/session-log.md"
      rm -f  "$STATE_ROOT/state/resume.md"
      rm -rf "$STATE_ROOT/state/checkpoints"
      mkdir -p "$STATE_ROOT/state/checkpoints"
      ;;
    active)
      rm -f  "$STATE_ROOT/state/current.md"
      rm -f  "$STATE_ROOT/state/session-log.md"
      rm -f  "$STATE_ROOT/state/resume.md"
      rm -rf "$STATE_ROOT/state/checkpoints"
      mkdir -p "$STATE_ROOT/state/checkpoints"
      # Remove contents of active/ but keep the directory.
      if [ -d "$STATE_ROOT/workstreams/active" ]; then
        find "$STATE_ROOT/workstreams/active" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
      fi
      ;;
    all)
      # Guardrail: refuse if STATE_ROOT is not a .paradigm dir.
      case "$STATE_ROOT" in
        */.paradigm|*/.paradigm/) ;;
        *) echo "ERROR: refusing to rm -rf non-.paradigm path: $STATE_ROOT" >&2; exit 3 ;;
      esac
      rm -rf "$STATE_ROOT"
      ;;
  esac
  echo "Cleared tier=${TIER} under ${STATE_ROOT}."
}

if [ "$CONFIRMED" = "--confirmed" ]; then
  do_clear
else
  print_manifest
fi
