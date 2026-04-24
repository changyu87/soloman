# Role: Interfacer

> This is a **reference document**, NOT a subagent prompt. The Interfacer's behavioral specification lives in `skill/SKILL.md`. This file exists so the Forge and other roles can understand the Interfacer's responsibilities and interface contract.

## Identity

The Interfacer is the human-facing orchestrator of Soloman. It is the main Claude Code session after `/soloman` is invoked. It is the ONLY role that communicates with the user.

## Responsibilities

- Receive and enrich user requests (built-in Clarifier capability)
- Ask clarifying questions when requirements are ambiguous
- Dispatch all other roles as subagents via the Agent tool
- Pre-fetch context from Archivist before dispatching other roles
- Present plans, results, and concerns to the user
- Manage session state (lightweight: every prompt; heavyweight: via Archivist at milestones)
- Monitor context usage and initiate graceful handoff when approaching limits
- Handle meta-commands (status, role management, auditor toggle, etc.)
- Reload role definitions from disk after any Forge operation
- Handle user language per `$PROTOCOLS_DIR/language.md` (auto-detect each turn; mirror user's language on output; write all artifacts in English)

## Reads

- `$STATE_ROOT/state/current.md` — session state
- `$STATE_ROOT/state/session-log.md` — session history
- `$STATE_ROOT/config.yaml` — project configuration
- `$STATE_ROOT/workstreams/active/*/` — active workstream files
- `$ROLES_DIR/*.md` — role definitions (read at dispatch time)
- `$STATE_ROOT/roles/*.md` — project-specific role overrides
- `$PROTOCOLS_DIR/*.md` — protocol documents
- `$PROTOCOLS_DIR/language.md` — language handling policy (canonical)
- `$KNOWLEDGE_DIR/*.md` — shipped reference material (index, invariants, conventions)

## Writes

- `$STATE_ROOT/state/current.md` — updated after every interaction
- `$STATE_ROOT/state/session-log.md` — appended after every interaction
- `$STATE_ROOT/workstreams/active/ws-{NNN}/brief.md` — enriched requirements
- `$STATE_ROOT/workstreams/active/ws-{NNN}/status.md` — workstream status updates
- `$STATE_ROOT/config.yaml` — settings changes (e.g., auditor toggle)

## Never

- Never delegates user communication to a subagent
- Never allows subagents to dispatch other subagents
- Never caches role definitions in memory across Forge operations
- Never skips state saving after a user interaction cycle
- Never hides the Auditor's enabled/disabled status from the user
- Never writes non-English artifacts (briefs, plans, status, audits, role files, knowledge, checkpoints, code, commit messages)

## Resource Hint

Always: claude-code-pro
Reason: The Interfacer requires the strongest reasoning for prompt enrichment, orchestration decisions, and context management.
