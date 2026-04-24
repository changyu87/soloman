# Protocol: Distill Operation

Read-only, single-stage meta-command that audits token efficiency of the
current project (normal mode) or the paradigm source repo (self-mode).
Output is a single `findings.md`. No source files are modified. No
destructive operation is performed. No approval gate (Invariant 13)
applies to the Distiller dispatch itself; the gate DOES apply to any
follow-up Planner → Builder/Forge workstream the user asks for.

## Classification

`class=meta`, `gate=direct`. Peer of `clear`. Unlike `clear`, this
operation is non-destructive, so Invariant 14 does not apply and no
anchor word is required.

## Trigger phrase bank

- **Slash**: `/soloman distill`
- **EN**: "distill", "run distill", "run a distill pass",
  "audit token efficiency", "token-efficiency audit",
  "run a token audit"
- **ZH**: "跑一次 distill", "审计 token 效率", "做一次 token 效率审计",
  "运行 distill"

The meta-classifier matches on the literal token `distill` or the
paraphrase set above. Because `distill` is not a common English verb in
this project's conversational context, no anchor word is required.

## Scope invariant

The Distiller **always ignores** the `.paradigm/` directory as an audit
target. Self-mode audits `$PARADIGM_REPO` (roles/, protocols/, skill/,
templates/, knowledge/, scripts/). Normal mode audits the project source
tree. In both modes, `.paradigm/` is out of scope as an audit target,
even though specific state artifacts under `$STATE_ROOT/state/` and
`$STATE_ROOT/workstreams/` ARE read as inputs for runtime-behavioral
inference. This carve-out is encoded verbatim in the Distiller's
`Never` section.

## Flow (single-stage)

1. **Intent detection**: normal `class=meta` classifier catches the
   trigger.
2. **Self-edit safety check**: if a Distiller dispatch has already
   occurred in the current user turn, the Interfacer refuses the second
   dispatch with a one-liner ("A distill pass already ran this turn —
   review its findings before running another.") and returns to normal
   meta-dispatch. No subagent is launched.
3. **Prepare output path**: Interfacer computes
   `$STATE_ROOT/distill/$(date -u +%Y-%m-%d-%H%M)/findings.md` and
   creates the parent directory via Bash (`mkdir -p`).
4. **Dispatch Distiller**: one subagent invocation. Task spec includes
   the audit target (self-mode vs. normal-mode, derived from mode
   detection at session start) and the exact output path.
5. **Present findings**: Interfacer reads `findings.md`, summarizes the
   top 2-3 recommendations in the user's detected language, and
   displays the absolute path.
6. **Ask next step (design-choice AUQ, NOT approval gate)**:
   AskUserQuestion with three options —
   - "Create a Planner workstream from these findings"
   - "Save findings only — decide later"
   - "Discard findings (delete the directory)"
   On option 1: route into the standard new-workstream flow with
   `findings.md` as the enriched requirement. On option 2: no-op.
   On option 3: `rm -rf` the timestamped directory (non-destructive
   of paradigm state; Invariant 14 does not apply because no paradigm
   state is touched).

## Invariants

- Distiller is read-only; it never edits source, roles, protocols, or
  templates. Enforced by `roles/distiller.md` Never section.
- Distiller never dispatches other subagents (Invariant 2).
- Self-edit safety: at most one Distiller dispatch per user turn.
- AskUserQuestion at step 6 is a design choice, NOT the Invariant 13
  approval gate; if the user picks option 1, the resulting Planner
  workstream still goes through the full §5 flow including free-text
  approval before any Builder/Forge dispatch.

## Cross-references

- `roles/distiller.md` — the role prompt.
- `skill/SKILL.md` Meta-Commands — the `distill` registration entry.
- `protocols/workflow.md` §5 — approval gate applies to any follow-up
  workstream, not to the Distiller dispatch itself.
