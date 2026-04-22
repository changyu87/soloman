# Template: Project Initialization

This template defines the `.paradigm/` scaffold created when The Paradigm is initialized in a new project.

This scaffold runs in **both modes** — normal projects and self-mode (the paradigm source repo). In self-mode, the resulting `.paradigm/` is gitignored so session records stay per-working-copy.

## Directory Structure to Create

```
.paradigm/
├── config.yaml
├── state/
│   ├── current.md
│   ├── session-log.md
│   ├── resume.md
│   └── checkpoints/
├── workstreams/
│   ├── active/
│   └── completed/
├── roles/
└── knowledge/
    ├── index.md
    ├── invariants.md
    └── conventions.md
```

## Initial File Contents

### `config.yaml`

```yaml
project:
  name: "{directory name}"
  paradigm_version: "0.5.1"
  initialized: "{YYYY-MM-DD}"

settings:
  auditor: enabled
  context_warn_prompts: 15
  context_warn_agents: 10
  writing_plans_prompted: false

workstream_counter: 0
```

### `state/current.md`

```markdown
# Current State
Updated: {YYYY-MM-DDTHH:MM:SS}
Session prompts: 0 | Subagent dispatches: 0
Active workstream: none
Last action: Project initialized
Next: Awaiting user request
Auditor: enabled
Language: en
```

### `state/session-log.md`

```markdown
# Session Log

## [{time}] Project Initialized
The Paradigm initialized for this project.
```

### `state/resume.md`

```markdown
# Session Resume
Updated: {YYYY-MM-DDTHH:MM:SS}
Language: en
Active workstream: none
Last action: Project initialized
Next: Awaiting user request
Auditor: enabled

## Recent turns (last 5, newest first)
- [{time}] Project Initialized: scaffold created

## Open gates
- none
```

### `knowledge/index.md`

```markdown
# Project File Index

> Maintained by the Archivist. Last updated: {date}

## Structure
[To be populated by Archivist on first scan]
```

### `knowledge/invariants.md`

```markdown
# Project Invariants

> Hard rules that must never be violated. Updated by Archivist at milestones.

[No invariants established yet. These will be discovered during project work.]
```

### `knowledge/conventions.md`

```markdown
# Project Conventions

> Coding style, naming patterns, and other conventions. Updated by Archivist at milestones.

[No conventions established yet. These will be discovered during project work.]
```

## Post-Initialization

After creating the scaffold:
1. Optionally dispatch Archivist to scan the project and populate `knowledge/index.md`
2. Optionally dispatch Quartermaster to inventory available resources
3. Present the greeting to the user
