# Protocol: Clear Operation

Destructive, three-tier operation to reset paradigm state. No backup is taken.
Gated by explicit free-text confirmation per Invariant 14.

This protocol is the destructive-ops sibling of `workflow.md` §5: both require
an explicit free-text token from the user, and both explicitly forbid
AskUserQuestion (AUQ) as the gate. AUQ is permitted only for Stage 1 tier
selection (a design choice, not approval).

## Classification

`class=meta`, `gate=direct`. Destructive peer of `distill`. Invariant
14 applies to Stage 2 (see §Invariants below).

## Tiers

| Tier | Triggers | Removes | Preserves |
|---|---|---|---|
| default | `/soloman clear`, NL phrases like "clear soloman state" / "清空状态" | `$STATE_ROOT/state/*` (current.md, session-log.md, resume.md, checkpoints/) | config.yaml, workstreams/, knowledge/, roles/ |
| --active | `/soloman clear --active`; NL triggers route through Stage 1 to choose | above + `$STATE_ROOT/workstreams/active/*` | config.yaml, workstreams/completed/, knowledge/, roles/ |
| --all | `/soloman clear --all`; NL triggers route through Stage 1 to choose | entire `$STATE_ROOT` (the `.soloman/` directory) | nothing — project will need re-initialization next session |

Note: NL triggers never carry a tier; they always route through Stage 1 tier
selection. Only slash-style invocations with explicit `--active`/`--all`
skip Stage 1.

## Trigger phrase bank (English + Chinese)

Every NL trigger MUST contain an anchor word (`paradigm`, `状态`, or
`session`). Generic phrases like `重新开始`, `从头开始`, `clean slate`, and
bare `clear the X` are explicitly excluded to avoid false positives in
ordinary conversation.

- **EN**: "clear paradigm state", "clear the paradigm state",
  "wipe paradigm state", "wipe the paradigm state", "reset paradigm state",
  "reset the paradigm", "clear session state", "wipe session state",
  "end the paradigm session", "nuke paradigm", "remove paradigm state",
  "clean up paradigm state".
- **ZH**: "清空状态", "清理状态", "重置状态", "清空 paradigm",
  "paradigm 状态全清", "彻底清空 paradigm", "清理 paradigm",
  "重置 paradigm", "清空 session 状态", "清理当前 session",
  "结束 paradigm 工作流".

Slash-style also qualifies: first message is `/soloman clear` (no args)
OR a `clear` message of ≤3 tokens optionally followed by
`--active` / `--all` / `state` / `paradigm`.

## Flow (two-stage)

### Stage 0 — Intent detection

Performed on the first user message after skill invocation, and also by the
normal `class=meta` classifier for mid-session turns. Detects only the
**intent** to clear paradigm state — NOT the tier. Slash-style invocations
may carry an explicit tier (`--active` / `--all`), which skips Stage 1.

### Stage 1 — Tier selection

Skipped if Stage 0 carried an explicit tier. Otherwise the Interfacer
presents all three tiers (default / --active / --all) via AskUserQuestion
(or a numbered list, if AUQ is unavailable), each annotated with a one-line
"will delete / will preserve" summary in the user's detected language.
The user picks. **This is a design choice, NOT destructive approval.**

### Stage 2 — Destructive confirmation

1. Interfacer runs `scripts/clear.sh <tier>` (dry-run) via the Bash tool;
   captures stdout (the manifest).
2. Interfacer presents the manifest + confirmation prompt in the detected
   language. Prose is translated (warning line, "Will be deleted" /
   "Will NOT be touched" labels, "reply with the exact phrase"
   instruction). Paths and the literal token `YES, CLEAR <tier>` are kept
   verbatim (ASCII, untranslated) so the Auditor can grep logs
   language-agnostically.
3. Interfacer awaits an explicit free-text reply matching the literal
   token `YES, CLEAR <tier>` (case-insensitive exact match on the token
   string). Silence, an AskUserQuestion answer, or any other text
   cancels the operation.
4. On match: Interfacer runs `scripts/clear.sh <tier> --confirmed` via the
   Bash tool.
5. Interfacer reports what was removed. For `default` and `--active`,
   confirm the project is still initialized. For `--all`, instruct the
   user to re-invoke `/soloman` next session for re-initialization.

## Invariants

- Confirmation token is literal ASCII: `YES, CLEAR default|active|all`.
- No backup is taken; the confirmation gate is the only safeguard.
- The same script path (`$SKILL_DIR/scripts/clear.sh`) serves slash-style
  and NL triggers.
- `STATE_ROOT` guardrail: the `--all` branch refuses to proceed if
  `$STATE_ROOT` does not end in `.paradigm`.
- AskUserQuestion MAY be used in Stage 1 for tier selection. AUQ is
  NEVER valid as Stage 2 destructive approval. See Invariant 14.

## Cross-references

- `protocols/workflow.md` §5 — approval-gate pattern mirrored here.
- `protocols/state-management.md` §Recovery — resume.md interaction.
- `knowledge/invariants.md` §14 — codifies the destructive-op gate.
