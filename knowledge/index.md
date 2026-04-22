# Project File Index — The Paradigm

> Maintained by the Archivist. Last updated: 2026-04-18

## Core
- `PARADIGM.md` — Human docs, quick start guide, self-mode marker
- `CLAUDE.md` — Auto-loaded dev context for Claude Code sessions
- `changelog.md` — Version history and evolution log
- `install.sh` / `uninstall.sh` — Build and remove the installed skill bundle

## Skill
- `skill/SKILL.md` — Claude Code skill definition + Interfacer behavioral spec

## Roles (7 built-in + template)
- `roles/_template.md` — Blueprint for creating new roles (used by Forge)
- `roles/interfacer.md` — Reference doc for Interfacer (NOT a subagent prompt)
- `roles/planner.md` — Subagent: produces execution plans
- `roles/builder.md` — Subagent: executes plans, writes code/content
- `roles/auditor.md` — Subagent: independent review (optional)
- `roles/archivist.md` — Subagent: project knowledge curator
- `roles/forge.md` — Subagent: creates/edits/deletes roles (CORE, cannot be deleted)
- `roles/quartermaster.md` — Subagent: AI/hardware resource management

## Protocols
- `protocols/workflow.md` — Standard flow: enrichment → plan → audit → build → audit → complete. §5 is the canonical spec for the plan-approval gate (what "present" and "approval" mean; AskUserQuestion selections are NEVER approval).
- `protocols/state-management.md` — Lightweight (every prompt) + heavyweight (milestones) state
- `protocols/context-overflow.md` — Detection heuristics and graceful handoff protocol
- `protocols/forge-protocol.md` — Rules for role creation, editing, deletion
- `protocols/language.md` — Multilingual-interaction / English-artifact policy

## Templates
- `templates/project-init.md` — `.paradigm/` scaffold for new projects
- `templates/workstream-init.md` — Workstream creation procedure

## Knowledge (shipped reference material)
- `knowledge/index.md` — This file
- `knowledge/invariants.md` — Hard rules (items 1–13; item 12 = Route preamble, item 13 = explicit-approval gate)
- `knowledge/conventions.md` — Style and naming conventions

## Key Cross-References
- Plan-approval gate: `protocols/workflow.md` §5 (spec) ↔ `skill/SKILL.md` Core Loop §5 item 4 + Invariant 13 ↔ `knowledge/invariants.md` item 13
- Route preamble: `skill/SKILL.md` Invariant 12 ↔ `knowledge/invariants.md` item 12
- Installed bundle layout: `install.sh` copies `skill/SKILL.md` → `$SKILL_DIR/SKILL.md` (bundle root, NOT under `skill/`)
