# Conventions — The Paradigm

> Coding style, naming patterns, and other conventions. Updated by Archivist at milestones.

## Language
- Canonical spec: `protocols/language.md`
- Summary: user interaction mirrors user's language; all artifacts, code, and role files are English.

## Role Naming
- Names must be snap-intuitive: one glance = you know the job
- Single word preferred (Planner, Builder, Auditor, Archivist, Forge, Quartermaster)
- Avoid jargon or abstract names

## File Naming
- Role definitions: `{lowercase-name}.md` in `roles/`
- Workstreams: `ws-{NNN}/` with zero-padded 3-digit numbers
- Checkpoints: `{NNN}-{description}.md` in `state/checkpoints/`

## Role Definition Structure
- Every role follows `_template.md` structure exactly
- Identity section: 1-2 sentences max
- Never section must include: no user talk, no subagent dispatch

## Numbering and Labeling
- Sequential steps use flat integers: 1, 2, 3, 4 — no sub-numbering (2a, 2b, 2c)
- If a step needs splitting, renumber all subsequent steps

## State Files
- `current.md`: ~20 lines, snapshot format
- `session-log.md`: append-only, timestamped entries
- Knowledge files: kept under 200 lines (Archivist summarizes when growing)
