# The Paradigm

A self-bootstrapping universal AI work paradigm.

## What Is This?

The Paradigm decomposes complex AI-assisted work into specialized **roles** — an **Interfacer** (the main session, human-facing) orchestrating **subagents** (Planner, Builder, Auditor, etc.) that each get their own isolated context window. All communication happens through the file system.

The paradigm can manage any project — including producing and improving itself.

## Why?

Single-session AI work collapses when mid-project requirement changes cause context window overload. Quality degrades because one session tries to hold everything: requirements, architecture, implementation details, review feedback, and project history.

The Paradigm solves this by ensuring no single session needs the full picture. Each role reads only what it needs, does its job, writes its output, and returns.

## Quick Start

### Install

```bash
# From the paradigm source repo:
./install.sh
```

This assembles a self-contained skill bundle at `~/.claude/skills/the-paradigm/` (SKILL.md + `roles/` + `protocols/` + `templates/` + `knowledge/` + a `VERSION` marker). The bundle is independent of the source repo — it works on any machine and does not reach back to the repo at runtime.

Override the install location with `PARADIGM_INSTALL_DIR=/path ./install.sh` (useful for shared team installs or isolated test installs). Re-run `./install.sh` any time you change `skill/SKILL.md`, a role, a protocol, a template, or the shipped `knowledge/` — it idempotently replaces the prior install.

> **Note**: `install.sh` uses `cp` rather than `ln -s` because Claude Code filters out skills whose symlink resolves into the active workspace.

### Use in Any Project

```bash
cd ~/work/my-project
claude
# In the Claude session:
# /the-paradigm
```

The session transforms into the Interfacer. It will:
1. Offer to scaffold `.paradigm/` if the project hasn't been initialized
2. Present current state and ask what you'd like to work on

### Use for Self-Evolution

```bash
cd ~/work/the-paradigm
claude
# /the-paradigm
```

The session detects `PARADIGM.md` in cwd and enters **self-mode**. Behavior is identical to a normal project except: the Forge is allowed to write universal role edits back to the source repo (`$PARADIGM_REPO/roles/`). Session state still lives in a gitignored `.paradigm/` under the repo, so commits stay clean.

After universal role edits land in the repo, re-run `./install.sh` so other installs pick them up.

## Built-in Roles

| Role | Type | Job |
|---|---|---|
| **Interfacer** | Main session | Human interface, prompt enrichment, orchestration, state management |
| **Planner** | Subagent | Produces thorough execution plans |
| **Builder** | Subagent | Executes plans — writes code, creates content |
| **Auditor** | Subagent | Independent review (optional, enabled by default) |
| **Archivist** | Subagent | Project knowledge curator — knows where every file is |
| **Forge** | Subagent | Creates/edits/deletes roles — the self-bootstrapping engine |
| **Quartermaster** | Subagent | AI/hardware resource management |

## Standard Flow

1. User gives a request (can be messy)
2. **Interfacer** enriches the prompt, asks clarifying questions if needed
3. **Archivist** (if needed) provides relevant file paths
4. **Planner** produces an execution plan
5. **Auditor** (if enabled) reviews the plan
6. User approves the plan
7. **Builder** executes the plan
8. **Auditor** (if enabled) reviews deliverables
9. **Interfacer** presents results, saves state

## Key Design Principles

- **Only the Interfacer talks to the user.** All other roles are subagents.
- **Only the Interfacer dispatches subagents.** No nested subagent calls.
- **Archivist-as-a-service.** Interfacer pre-fetches context from Archivist before dispatching other roles.
- **State saved every prompt.** Lightweight state by Interfacer; heavyweight state by Archivist at milestones.
- **Forge is CORE.** Can create/edit/delete roles. Can edit itself, cannot delete itself.
- **Auditor is optional.** Enabled by default, user can disable to save tokens.

## File Structure

```
the-paradigm/               # Paradigm source repo
├── PARADIGM.md              # This file (also self-mode marker)
├── skill/SKILL.md           # Claude Code skill definition
├── roles/                   # Universal role definitions
├── protocols/               # Interaction protocols
├── templates/               # Project scaffolding
├── knowledge/               # Shipped reference (index, invariants, conventions)
├── install.sh / uninstall.sh
└── changelog.md             # Evolution log

~/.claude/skills/the-paradigm/   # Installed skill bundle (read-only at runtime)
├── SKILL.md
├── roles/ protocols/ templates/ knowledge/
└── VERSION

any-project/.paradigm/       # Per-project control plane (gitignored in the source repo)
├── config.yaml              # Project settings
├── state/                   # Session state (current.md, session-log.md, checkpoints/)
├── workstreams/             # Active and completed workstreams
├── roles/                   # Project-specific custom roles
└── knowledge/               # Runtime project knowledge
```

## Version

- **Current**: v0.5.1 (Token-efficiency trim — pointer-based subagent hand-off)
- **Status**: Trims the every-turn Interfacer prompt by collapsing the `clear` and `distill` meta-command flows into one-line pointers to `protocols/*.md`, flips the Archivist-as-a-Service convention from "pass report contents" to "pass report path" (propagated to `roles/planner.md` and `roles/auditor.md`), and mechanises the Core-Loop §6 dispatch-counter update (plus one retroactive `current.md` fix). Net `skill/SKILL.md` reduction −14 lines (R1 saves ~39; R2/R3 add substantive prose). See `changelog.md` for details.
