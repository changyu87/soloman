# The Paradigm — Development Context

This is the source repository for The Paradigm, a self-bootstrapping universal AI work paradigm.

## Key Points

- The installed skill lives at `~/.claude/skills/the-paradigm/` and is built by `./install.sh` from this repo. The bundle is self-contained; it does not read back into the source repo at runtime.
- All universal role definitions are in `roles/`. Forge is the only role that modifies these files.
- Protocols in `protocols/` define how roles interact.
- Templates in `templates/` define scaffolding for new projects and workstreams.
- `knowledge/` at repo root ships shipped reference material (index, invariants, conventions).
- `PARADIGM.md` serves as both human docs AND the self-mode detection marker.
- Session state (when running `/the-paradigm` against this repo) goes into a gitignored `.paradigm/` at repo root. This is per-working-copy and never committed.

## When Working on This Repo

If you want to activate The Paradigm to manage its own development, type `/the-paradigm`. It detects self-mode via `PARADIGM.md` and uses `.paradigm/` for session state. In self-mode the Forge may write universal role edits back to this repo's `roles/`.

After editing `skill/SKILL.md`, a role, a protocol, or a template, re-run `./install.sh` to sync the installed bundle.

If you're just making quick edits without the full paradigm workflow, work normally.
