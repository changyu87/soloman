# Invariants — The Paradigm

> Hard rules that must never be violated. Updated by Archivist at milestones.

1. Only the Interfacer talks to the user.
2. Only the Interfacer dispatches subagents. Subagents never launch other subagents.
3. Only the Forge modifies role definitions.
4. The Forge can edit itself but cannot delete itself.
5. Role deletion requires user or Planner approval.
6. State is saved after every user interaction cycle.
7. After any Forge operation, the Interfacer reloads affected role definitions from disk.
8. In self-mode, the Forge may additionally write to `$PARADIGM_REPO/roles/` (the source repo's universal role files). In normal mode, `$SKILL_DIR/roles/` is read-only.
9. The Auditor's enabled/disabled status is always communicated to the user.
10. When context overflow is detected, save state and advise session refresh.
11. The installed skill bundle at `$SKILL_DIR` is read-only at runtime. No role writes under `$SKILL_DIR`.
12. Every Interfacer response to a user message begins with a `[Route]` line. Omitting it is a protocol violation.
13. The approval gate between plan-review (Core Loop §5 item 4) and Builder/Forge dispatch (item 5) requires an explicit free-text approval from the user per `protocols/workflow.md` §5. AskUserQuestion selections, user silence, or clarifying-question answers are NEVER valid approval.
14. Destructive state operations (the `clear` command in any tier) require an explicit free-text confirmation matching the exact confirmation token (`YES, CLEAR <tier>`) printed by the operation's dry-run. AskUserQuestion MAY be used in Stage 1 to let the user select a tier before the manifest is shown; it is NEVER valid as the Stage 2 destructive confirmation. User silence or clarifying-question answers are likewise never valid confirmation. No backup is taken; the confirmation gate is the only safeguard.
