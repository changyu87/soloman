# The Paradigm — Changelog

## v0.5.1 — Token-efficiency trim (2026-04-19)

One workstream (ws-002) on `dev/v0.5.1` implementing three
recommendations from the ws-001 distill pass.

### Changed
- `skill/SKILL.md` Meta-Commands: `clear` and `distill` bullets
  collapsed to one-line pointers into `protocols/clear.md` and
  `protocols/distill.md`. Trigger-phrase bank kept (classifier
  needs it); step-by-step flows removed. Net reduction ≥40 lines
  of every-turn Interfacer prompt.
- `skill/SKILL.md` §Archivist-as-a-Service: guidance flipped from
  "pass report contents into the Planner prompt" to "pass the
  report file path plus the top 3–5 file paths to read first."
  Paths, not contents. Same rule extended to Auditor dispatches.
- `roles/planner.md`, `roles/auditor.md`: Reads sections now
  acknowledge the `archivist-report.md` path convention.
- `skill/SKILL.md` Core Loop §6 (Save State): rewritten to be
  mechanical — increment counter immediately after each Agent
  tool return, self-check against session-log before writing
  `current.md`.
- `protocols/clear.md`: new `## Classification` section
  (`class=meta`, `gate=direct`) migrated from SKILL.md.

### Fixed
- `.paradigm/state/current.md` retroactive correction: ws-001
  session was recorded as `Subagent dispatches: 4` but actually
  ran 6 dispatches (Archivist, Planner, Auditor-plan, Forge,
  Builder, Auditor-build). Counter corrected.

## v0.5.0 — Distiller & token-efficiency audits (2026-04-19)

One workstream (ws-001) on the `dev/v0.5.0` branch introducing the
**Distiller** universal role and the `distill` meta-command: a
read-only, on-demand token-efficiency audit that produces a
`findings.md` report without editing any source. In self-mode the
Distiller audits the paradigm source itself; in normal mode it audits
the third-party project. The `.paradigm/` directory is always out of
scope as an audit target, though specific state artifacts under
`state/` and `workstreams/` are read as inputs for runtime-behavioral
inference. No new runtime instrumentation is added — runtime analysis
is a one-shot read of existing state artifacts.

### Added
- `roles/distiller.md`: universal role with a strict read-only
  contract. Scope invariant encoded in the `Never` section
  (`.paradigm/` is never an audit target). Single-shot; does not
  dispatch subagents; does not produce a `plan.md`; never edits
  source, roles, protocols, or templates.
- `protocols/distill.md`: the meta-command protocol. Classification
  `class=meta`, `gate=direct`. Single-stage flow (no destructive
  confirmation, no anchor word — non-destructive op). Defines the
  trigger phrase bank, the self-edit safety rule (at most one
  Distiller dispatch per user turn), and the post-findings
  AskUserQuestion (create Planner workstream / save only / discard) —
  a design choice, NOT an Invariant 13 approval gate.
- `skill/SKILL.md` Meta-Commands: `distill` bullet registered as peer
  of `clear`. Full step-by-step flow inline (self-edit check → mkdir
  output path → dispatch Distiller → summarize → AUQ).

### Changed
- `install.sh`: `VERSION="0.5.0"`.
- `templates/project-init.md`: `paradigm_version` scaffold bumped to
  `"0.5.0"`.
- `PARADIGM.md`: version line updated to `v0.5.0 (Distiller &
  token-efficiency audits)` with a new one-paragraph status summary.

### Rationale
v0.4.2 closed the session-lifecycle gap. v0.5.0 addresses the next
self-dogfooding observation: the paradigm can now reason about its
own token cost on demand, without bolting on instrumentation. The
Distiller is intentionally output-only and boundary-strict so that
"audit" never silently becomes "edit"; any recommendation becomes
real work only via a user-approved Planner workstream that still
goes through the full §5 approval gate.

## v0.4.2 — Session lifecycle (2026-04-18)

One workstream (ws-007) on the `dev/v0.4.2` branch addressing two
thematically linked concerns: unbounded startup token cost from reading
`session-log.md` at every `/the-paradigm` invocation, and the lack of a
scripted way to end a workflow's state.

### Added
- `state/resume.md`: precomputed, bounded (≤20 lines) recovery summary
  written at every save-state cycle and read at Step 4 instead of the
  unbounded `session-log.md`. Legacy projects without `resume.md`
  auto-generate one on first post-upgrade startup.
- `scripts/clear.sh` + `protocols/clear.md`: three-tier destructive
  state-clearing operation (default / --active / --all), gated by an
  explicit free-text confirmation in the user's detected language.
  Slash-style and NL triggers route through the same script. NL phrase
  bank requires an anchor word (`paradigm` / `状态` / `session`) to
  avoid false positives on generic "start fresh" / "clear the logs".
- Invariant 14 (destructive-op confirmation gate): the `YES, CLEAR
  <tier>` token must be typed as free text; AskUserQuestion is permitted
  only for Stage 1 tier selection, never as destructive approval.

### Changed
- `skill/SKILL.md` Step 4 (Session Recovery): reads `resume.md` on the
  fast path; falls back to `current.md` + tail(`session-log.md`, 30) only
  for legacy projects and auto-generates `resume.md` in that case.
- `skill/SKILL.md` Step 6 (Save State): now a three-step ordered list —
  update `current.md`, append to `session-log.md`, then rewrite
  `resume.md` so it reflects the just-logged turn.
- `skill/SKILL.md` Meta-Commands: added the `clear` bullet with the
  two-stage flow + Bash-capture contract.
- `protocols/state-management.md`: documents the `resume.md` schema and
  lifecycle under Tier 1; Recovery Protocol updated to read `resume.md`
  first and defer `session-log.md` until the user asks for narrative
  detail.
- `protocols/workflow.md` §5: one-line cross-reference to `clear.md` and
  Invariant 14.
- `templates/project-init.md`: scaffold includes `state/resume.md` with
  an initial stub so fresh projects hit the fast path from turn one.
  `paradigm_version` bumped to `0.4.2`.
- `install.sh`: `VERSION="0.4.2"`; bundle now ships `scripts/` and marks
  `scripts/clear.sh` executable.

### Rationale
v0.4.1 hardened the plan-to-Build approval gate. v0.4.2 closes the two
remaining session-lifecycle gaps surfaced in the same self-dogfooding
pass: startup cost that grew unbounded with session-log size, and the
missing scripted way to end a workflow's state. `resume.md` is the
bounded replacement for the startup read. `scripts/clear.sh` is the
scripted end-of-lifecycle, reusing the §5 free-text-confirmation pattern
but with a stronger invariant (Invariant 14): AskUserQuestion MAY be
used only for Stage 1 tier selection — never as destructive approval.

## v0.4.1 — Approval-Gate Hardening (2026-04-18)

One workstream on the `dev/v0.4.1` branch fixing a protocol violation observed while running the paradigm on itself: the Interfacer silently treated post-audit AskUserQuestion selections as implicit plan approval and dispatched Forge before explicit user approval of the revised plan.

### Added
- **Approval-gate semantics (ws-006)** — `protocols/workflow.md` §5 now spells out "What `present` means" (full `plan.md` path + top-level summary + every Critical audit finding verbatim), "What `approval` means" (explicit free-text confirmation referring to the most-recently-presented plan), "Handling Auditor-with-notes" (AskUserQuestion may resolve design choices during enrichment; it is never approval), and a no-dispatch invariant.
- **Invariant 13** (SKILL.md + `knowledge/invariants.md`): "The approval gate between plan-review and Builder/Forge dispatch requires an explicit free-text approval. AskUserQuestion selections, user silence, or clarifying-question answers are NEVER valid approval."
- **Invariant 12 back-fill** — `knowledge/invariants.md` gained the missing `[Route]`-preamble invariant from v0.4.0, closing the drift between SKILL.md and the shipped reference.

### Changed
- `skill/SKILL.md` Core Loop §5 item 4: rewritten from "Present plan to user for approval" to an expanded spec that references `workflow.md` §5 and explicitly forbids treating AskUserQuestion selections as approval.
- `knowledge/index.md`: added cross-references for the approval-gate triad and a note on the installed-bundle layout (`$SKILL_DIR/SKILL.md`, not `$SKILL_DIR/skill/SKILL.md`).

### Rationale
v0.4.0 added `[Route]` preambles to force the Interfacer through the Core Loop. v0.4.1 closes the next layer: the approval gate itself. Under-specified prose in the old §5 ("Present plan to user for approval") let the Interfacer conflate enrichment questions with the approval signal. The new spec is negatively stated ("NEVER valid approval"), which is harder to rationalize around.

## v0.4.0 — Forced Routing + Language Persistence + Soft Dependencies (2026-04-18)

Three workstreams on the `dev/v0.4.0` branch fixing defects observed while running the paradigm on itself: the Interfacer silently bypassing the Core Loop, losing the user's language on session recovery, and hard-depending on an externally-installed `writing-plans` skill.

### Added
- **Routing Preamble (ws-003)** — `skill/SKILL.md` now mandates a structural `[Route] lang=<IETF-tag> | class=<category> | gate=<decision>` line at the start of every Interfacer response to a user message. Forces execution of steps 0 → 1 → 3 before any response content. Class values: `new-work`, `feedback`, `meta`, `clarification`. Gate values: `planner`, `direct`, `enriching`. Exempt: startup greeting and session-recovery prompt.
- **Invariant 12**: "Every Interfacer response to a user message begins with a `[Route]` line. Omitting it is a protocol violation."
- **Language persistence (ws-001)** — Session state now stores the detected IETF language tag in `current.md`. On recovery, the Interfacer greets in the previously-detected language instead of re-detecting from scratch. `protocols/state-management.md`, `skill/SKILL.md` Step 6 (Save State), and `templates/project-init.md` updated accordingly.
- **Writing-Plans soft dependency (ws-002)** — `install.sh` now silently installs `writing-plans` from `github.com/obra/superpowers` (the official upstream) when available; never errors out. New Startup Step 3 in `skill/SKILL.md` detects availability on first run and asks the user once whether to retry installation. `roles/planner.md` gained an availability check with a fallback to built-in planning when the skill is not installed. `templates/project-init.md` tracks `writing_plans_prompted` to make the prompt one-time.

### Changed
- `skill/SKILL.md` Step 1 (Classify): bullet labels are now backtick-formatted `class` values.
- `skill/SKILL.md` Step 3 (Planner Gate): bullet labels are backtick-formatted `gate` values; `enriching` added for the clarifying-question branch.
- `templates/project-init.md`: unified timestamp placeholder to `{YYYY-MM-DDTHH:MM:SS}`; added `Auditor: enabled` and `Language: en` defaults.

### Removed
- Old "Transparency rule" paragraph in Step 3 (Planner Gate) — replaced by the structural `[Route]` preamble.

### Rationale
The earlier spec said "Every user message follows this protocol" but produced no mandatory visible output, letting the Interfacer degrade into a conversational assistant under load. The `[Route]` line is the structural enforcement: the model cannot write a response without first having classified and gated it, and the user can see (and correct) the routing decision. Language persistence and soft-dep handling are smaller quality-of-life fixes surfaced during the same self-dogfooding pass.

## v0.3.0 — Distributable Skill + Unified State Model (2026-04-15)

The paradigm becomes installable by third parties and collapses its dual state concept (`.self/` vs `.paradigm/`) into a single unified model.

### Added
- `install.sh` — assembles a self-contained skill bundle at `~/.claude/skills/the-paradigm/` (`SKILL.md` + `roles/` + `protocols/` + `templates/` + `knowledge/` + `VERSION`). Idempotent, honors `PARADIGM_INSTALL_DIR` for custom install targets, refuses to overwrite non-paradigm directories.
- `uninstall.sh` — symmetric; verifies target is a paradigm install before removing it.
- `knowledge/` at repo root — shipped reference material (`index.md`, `invariants.md`, `conventions.md`), promoted from the old `.self/knowledge/`.
- SKILL.md invariant #11: the installed bundle at `$SKILL_DIR` is read-only at runtime.
- SKILL.md invariant #8 (rewritten): in self-mode the Forge may additionally write to `$PARADIGM_REPO/roles/`; in normal mode `$SKILL_DIR/roles/` is read-only.

### Changed
- `skill/SKILL.md` constants block: `PARADIGM_HOME` removed. Introduced `SKILL_DIR` (harness-provided base directory), `ROLES_DIR`, `PROTOCOLS_DIR`, `TEMPLATES_DIR`, `KNOWLEDGE_DIR` — all rooted under `$SKILL_DIR`.
- `skill/SKILL.md` Step 1 (mode detection): both modes now set `STATE_ROOT = $(pwd)/.paradigm`. Self-mode additionally binds `PARADIGM_REPO = $(pwd)` for Forge writes. Step 2 (initialization) now runs in both modes.
- `roles/forge.md`, `protocols/forge-protocol.md`: universal role writes target `$PARADIGM_REPO/roles/` (self-mode only). In normal mode, universal role edits are refused with guidance to clone the source repo.
- `roles/quartermaster.md`, `roles/interfacer.md`: `$PARADIGM_HOME` references replaced with `$SKILL_DIR`-rooted constants; Interfacer's Reads list now includes `$KNOWLEDGE_DIR`.
- `protocols/state-management.md` State Root section: unified model, with self-mode addendum for `$PARADIGM_REPO`.
- `templates/project-init.md`: `paradigm_version` bumped to `0.3.0`; scaffold now documented as running in both modes.
- `PARADIGM.md`, `CLAUDE.md`: install instructions use `./install.sh`; file-structure and self-mode sections rewritten.
- `.gitignore`: replaced `.self/state/` and `.self/workstreams/` with a single `.paradigm/` line.

### Removed
- `.self/` tree — state is now unified on `.paradigm/`. Git history preserves the old content.
- `PARADIGM_HOME` as a concept — the installed bundle is self-locating via the Claude Code harness's base-directory preamble.

### Rationale
Before v0.3.0, `skill/SKILL.md` hardcoded `PARADIGM_HOME: ~/work/the-paradigm`, which meant the installed skill reached back into the developer's source tree for roles, protocols, and templates. That made third-party installs impossible. The dual `.self/` vs `.paradigm/` concept was the same thing under two names, multiplied doc surface, and complicated the distribution story (what ships? what stays?). v0.3.0 resolves both: the bundle is self-contained and read-only; session state always goes to `.paradigm/` under the current project. Self-mode survives as a *behavioral* distinction — only in self-mode may the Forge write universal role edits back to the source repo.

## v0.2.0 — Protocol Refinements (2026-04-14)

Three workstreams in self-mode, validating the paradigm on itself.

### Added
- `protocols/language.md` — canonical multilingual-interaction / English-artifact policy (ws-001)
- Planner-skip rule in `protocols/workflow.md` §3: Interfacer may bypass Planner when the brief fully specifies the change (ws-002)
- Reference-document exemption in `protocols/forge-protocol.md` Invariant #2: role files marked as reference documents are exempt from `Output Specification` and `Quality Gates` (ws-003)
- `.gitignore` — excludes `.self/state/` and `.self/workstreams/` as runtime session records

### Changed
- `skill/SKILL.md` — added language-detection step at the start of the Core Loop
- `roles/interfacer.md` — responsibilities, reads, and never clauses updated for language policy
- `.self/knowledge/conventions.md` — Language section points at the canonical spec

### Infrastructure
- Established artifact-vs-record boundary for self-mode. `.self/config.yaml` and `.self/knowledge/` ship with the paradigm (settings + hand-distilled knowledge). `.self/state/` and `.self/workstreams/` are local runtime state and are git-ignored. Rationale: session snapshots, logs, checkpoints, and workstream briefs/audits are per-working-copy records; tracking them would churn every commit with unrelated content and conflict across parallel sessions.

### Self-Mode Validation
Paradigm ran three workstreams on its own codebase using only its own roles and protocols. Dispatch counts: ws-001 = 6, ws-002 = 3, ws-003 = 3 (Planner skipped on ws-002 and ws-003 via the new skip rule). Zero Critical/Important audit findings on ws-002 and ws-003.

## v0.1.0 — V0 Bootstrap (2026-04-13)

Initial creation of The Paradigm.

### Added
- 7 built-in role definitions: Interfacer, Planner, Builder, Auditor, Archivist, Forge, Quartermaster
- Role template (`_template.md`) for Forge to create new roles
- Claude Code skill (`/the-paradigm`) with full Interfacer behavioral specification
- 4 protocol documents: workflow, state-management, context-overflow, forge-protocol
- 2 project templates: project-init, workstream-init
- Self-mode support (`.self/` directory, detected via `PARADIGM.md` presence)
- Session state management: lightweight (every prompt) + heavyweight (milestones)
- Context overflow detection and graceful handoff protocol

### Design Decisions
- Interfacer absorbs Clarifier (only main session can talk to user)
- All other roles are subagents via Agent tool (isolated context windows)
- No weight classes — paradigm always runs full protocol
- Forge is CORE and cannot be deleted
- Auditor is optional (enabled by default, user can disable)
- File system is the sole communication interface between roles
