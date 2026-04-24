# Protocol: State Management

This document defines how session and project state is managed in The Paradigm.

## Two-Tier State Model

### Tier 1: Lightweight State (every user prompt)

Written directly by the Interfacer. No subagent needed.

**`state/current.md`** — snapshot of current state (~20 lines):

```markdown
# Current State
Updated: {YYYY-MM-DDTHH:MM:SS}
Session prompts: {N} | Subagent dispatches: {N}
Active workstream: ws-{NNN} | Phase: {phase}
Last action: {description}
Next: {what should happen next}
Auditor: {enabled/disabled}
Language: {detected language, e.g. "en", "zh-CN", "zh-CN primary, en mixed"}
```

**`state/session-log.md`** — append-only log of session events:

```markdown
## [{HH:MM}] {Event Type}
{Brief description — 1-3 lines}
```

Event types: `User Request`, `Enrichment Complete`, `Planner Dispatched`, `Planner Complete`, `User Approved`, `Builder Dispatched`, `Builder Complete`, `Auditor Complete`, `Workstream Complete`, `Context Warning`, `Session Handoff`.

**`state/resume.md`** — precomputed, bounded recovery summary (≤20 lines,
≤1.2KB). Always overwritten — never appended. Written by the Interfacer at
every save-state cycle, after `session-log.md` is appended, so it reflects
the just-logged turn. Read by the Interfacer at Step 4 (Session Recovery)
instead of the unbounded `session-log.md`, keeping startup token cost
bounded.

```markdown
# Session Resume
Updated: {YYYY-MM-DDTHH:MM:SS}
Language: {last-detected IETF tag, e.g. "zh-CN"}
Active workstream: ws-{NNN} | Phase: {phase | "none"}
Last action: {<=120 chars, one line}
Next: {<=120 chars, one line}
Auditor: {enabled|disabled}

## Recent turns (last 5, newest first)
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}
- [{HH:MM}] {Event Type}: {<=80 chars}

## Open gates
- {e.g. "awaiting-approval: ws-007 plan" | "none"}
```

**Update rule** (Step 6 ordering): (1) update `current.md`; (2) append to
`session-log.md`; (3) rewrite `resume.md` entirely from the freshly-updated
`current.md` + tail(`session-log.md`, 5 events) + any in-memory
pending-gate notes. Because `resume.md` is fully rewritten each turn from
a bounded schema, growth beyond the ≤20-line / ≤1.2KB budget is
structurally impossible as long as the template is honored.

**Cost**: Two small file writes per prompt (current.md rewrite + resume.md
rewrite) plus one append (session-log.md). Still negligible.

### Tier 2: Heavyweight State (milestones only)

Written by the Archivist subagent. Dispatched by the Interfacer.

**When to dispatch Archivist for state update**:
- Workstream completion
- Before context overflow handoff
- User explicit request ("archive this", "update the index")
- New workstream start (to provide file context for Planner)

**What the Archivist writes**:
- `knowledge/index.md` — updated file index for the project
- `knowledge/invariants.md` — new hard rules discovered
- `knowledge/conventions.md` — new patterns observed
- `state/checkpoints/{NNN}-{description}.md` — comprehensive snapshot

**Checkpoint format**:
```markdown
# Checkpoint: {description}
Date: {YYYY-MM-DD}
Trigger: {workstream-complete | context-overflow | user-request}

## Project State
- Active workstreams: [list]
- Completed workstreams: [list]
- Key files: [most important files and their current purpose]

## Recent Decisions
- [Decision]: [Rationale]

## Knowledge Updates
- New invariants: [list or "none"]
- New conventions: [list or "none"]
- Index changes: [summary]
```

**Cost**: ~3-5 Archivist calls per workstream.

---

## Recovery Protocol

When a new session starts and `/soloman` is invoked, read state on
the fast path (bounded token cost); defer the unbounded session-log until
the user asks for detail:

1. **Read `state/resume.md`** → Know: language, what workstream, what
   phase, last action, next step, recent events, open gates. This is the
   startup-cost-bounded entry point.
2. **On user YES to resume**, read `state/current.md` for the full
   lightweight snapshot.
3. **Only if the user asks for narrative detail** ("what happened
   earlier?", "show history"), read `state/session-log.md`.
4. **Only as needed**, read active workstream files (brief, plan, status,
   audit results).
5. **Legacy fallback**: if `state/resume.md` is missing or empty but
   `current.md` has content, read `current.md` + last 30 lines of
   `session-log.md`, construct a summary equivalent to the `resume.md`
   schema, and immediately write `resume.md` once so future sessions hit
   the fast path.
6. **Present to user**: "Previous session was at [phase]. Resume?"

### What Can Be Lost

The main session's in-memory reasoning nuance — enrichment reasoning, subtle context about why certain decisions were made that wasn't written to files.

### Mitigation

- Session-log captures key decisions and events
- Workstream files capture all formal artifacts
- Checkpoints capture comprehensive snapshots at milestones
- A new session may re-read some files, but this provides fresh perspective

### What Cannot Be Lost

- All file artifacts (briefs, plans, audits, build status)
- All knowledge base entries
- All checkpoints
- The session-log

These are all on disk and persist indefinitely.

---

## State Root

- **Both modes**: `$STATE_ROOT` = `$(pwd)/.paradigm`

The structure under `$STATE_ROOT` is identical in both modes.

**Self-mode addendum**: When running inside the paradigm's source repo (detected by `PARADIGM.md` in cwd), the Interfacer additionally binds `$PARADIGM_REPO = $(pwd)`. Only the Forge uses this — to write universal role edits back to the source repo (`$PARADIGM_REPO/roles/`). All other state (session, workstreams, checkpoints) still lives under `$STATE_ROOT` and is per-working-copy, gitignored in the source repo.
