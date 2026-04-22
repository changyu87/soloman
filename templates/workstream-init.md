# Template: Workstream Initialization

This template defines how a new workstream is created within an active project.

## When to Create a Workstream

A new workstream is created when:
- The Interfacer receives a new work request from the user
- The enrichment phase is complete and the request is clear enough to plan

## Steps

### 1. Increment Counter

Read `config.yaml → workstream_counter`, increment by 1, write back.
Use the new value as `{NNN}` (zero-padded to 3 digits: 001, 002, etc.).

### 2. Create Workstream Directory

```
workstreams/active/ws-{NNN}/
```

### 3. Write Brief

Write the enriched requirement to `ws-{NNN}/brief.md`:

```markdown
# Brief — ws-{NNN}
Date: {YYYY-MM-DD}
Requested by: User

## Goal
[What the user wants — clear, specific, 1-3 sentences]

## Constraints
- [Explicit constraints from user]
- [Inferred constraints from project context]

## Scope
- In scope: [what's included]
- Out of scope: [what's excluded]

## Success Criteria
- [How to know this is done]

## Context Files
- [File paths relevant to this workstream, gathered from Archivist or Interfacer knowledge]
```

### 4. Write Initial Status

Write `ws-{NNN}/status.md`:

```markdown
# Workstream Status — ws-{NNN}
Updated: {timestamp}
Phase: planning
Created: {YYYY-MM-DD}

## Progress
- [x] Brief written
- [ ] Plan created
- [ ] Plan reviewed (Auditor)
- [ ] User approved plan
- [ ] Build executed
- [ ] Build reviewed (Auditor)
- [ ] Workstream complete
```

### 5. Update Session State

Update `state/current.md` to reflect the new active workstream.
Append to `state/session-log.md`.

## Workstream Lifecycle

```
Created → Planning → Plan Review → Approved → Building → Build Review → Complete
                  ↑                          ↑
                  └── User requests changes ─┘
```

On completion: Move `ws-{NNN}/` from `active/` to `completed/`.
