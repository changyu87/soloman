# Protocol: Standard Workflow

This document defines the standard workflow for processing a user request through The Paradigm.

## Flow

### 1. User Request → Interfacer Enrichment

The Interfacer receives the user's message and enriches it:
- Parses intent, identifies ambiguities
- Asks clarifying questions if needed (only the Interfacer talks to the user)
- Produces a structured brief written to `workstreams/active/ws-{NNN}/brief.md`

### 2. Context Gathering (optional) → Archivist

If the Interfacer needs file context for the Planner:
- Dispatch Archivist subagent with description of what context is needed
- Archivist returns relevant file paths and brief descriptions
- Interfacer includes these paths in the Planner prompt

### 3. Planning → Planner

Dispatch Planner subagent with:
- `brief.md` (enriched requirement)
- File paths from Archivist (if gathered)
- Relevant knowledge files (invariants, conventions)
- Current project state

Planner writes `plan.md` and returns summary.

**When Planner may be skipped:**

The Interfacer may bypass Planner dispatch when the brief fully
specifies the change — all target files named, exact before/after
text provided, and no architectural or design decisions remaining.
In this case the brief itself serves as the plan. The workstream
still runs Builder and Auditor(build). If ambiguity surfaces
mid-build, the Interfacer pauses and retroactively dispatches
Planner.

### 4. Plan Review (if Auditor enabled) → Auditor

Dispatch Auditor subagent with:
- `brief.md` (original requirement)
- `plan.md` (Planner's output)
- Relevant invariants and conventions

Auditor writes `audit-plan.md` and returns verdict.

### 5. User Approval → Interfacer

Interfacer presents the plan (and Auditor findings if applicable) to the user.

#### What "present" means

Interfacer must surface, in the same turn:
- A link or inline path to the full `plan.md` (and `audit-plan.md` if Auditor ran)
- A top-level summary covering: recommendation, scope, Builder task count, risks
- If Auditor returned APPROVE-WITH-NOTES or REJECT: every Critical finding verbatim, and counts of Important/Minor

A summary without the full plan reference is NOT a valid present. A decision-question (AskUserQuestion) about findings is NOT a valid present.

#### What "approval" means

Approval is an **explicit free-text confirmation from the user** in a subsequent turn. Accepted forms include (non-exhaustive): "approve", "approved", "yes, proceed", "go", "同意", "OK", "LGTM". The phrase must be unambiguous and refer to the most-recently-presented plan.

The following are NOT approval:
- User selecting options in an AskUserQuestion (those resolve design choices, not the gate).
- User silence.
- User answering a clarifying question.
- User saying "looks good" about a single finding without addressing the plan as a whole.

#### Handling Auditor-with-notes

When Auditor returns APPROVE-WITH-NOTES:
1. If open design decisions remain in the notes, Interfacer MAY use AskUserQuestion to resolve them. This is enrichment, not approval.
2. Interfacer applies the chosen fixes to `plan.md`.
3. Interfacer then RE-PRESENTS the revised plan per "What present means" above.
4. Interfacer awaits explicit approval per "What approval means".
5. Only then may Builder be dispatched.

#### User response branches

User may:
- **Approve** (explicit text) → proceed to Build
- **Request changes** → Interfacer enriches feedback, re-dispatches Planner (or amends brief-as-plan if Planner was skipped)
- **Reject** → Interfacer asks for new requirements or archives the workstream

#### Invariant

The Interfacer MUST NOT dispatch Builder (or any role that modifies project source files on behalf of the approved plan, including Forge operations scheduled by the plan) until explicit approval per this section has been received. Violating this is a protocol violation and must be surfaced to the user.

See also `protocols/clear.md` and Invariant 14 — destructive state operations apply the same free-text-confirmation pattern to a separate gate.

### 6. Execution → Builder

Dispatch Builder subagent with:
- `plan.md` (approved plan)
- All file paths the Builder needs to read/write
- Project conventions and invariants

Builder executes the plan, modifies project files, updates `status.md`, returns summary.

### 7. Build Review (if Auditor enabled) → Auditor

Dispatch Auditor subagent with:
- `brief.md`, `plan.md`, `status.md`
- Files modified by Builder
- Invariants and conventions

Auditor writes `audit-build.md` and returns verdict.
- **APPROVE**: Proceed to completion.
- **APPROVE-WITH-NOTES**: Present notes to user, proceed.
- **REJECT**: Present findings to user. Options: re-dispatch Builder with fixes, or re-plan.

### 8. Completion → Interfacer + Archivist

Interfacer presents results to user. If the workstream is complete:
- Move `ws-{NNN}/` from `active/` to `completed/`
- Dispatch Archivist to update knowledge base and write checkpoint

### 9. State Save → Interfacer

Update `state/current.md` and append to `state/session-log.md`.

---

## Forge Interventions

At any point, if the Planner's plan recommends a new role, or the user requests role changes:
1. Interfacer dispatches Forge with the role creation/edit/delete request
2. Forge writes the role file
3. Interfacer reloads the affected role definition from disk
4. Workflow continues with the new/modified role available

## Quartermaster Interventions

When the user reports hardware/resource changes:
1. Interfacer dispatches Quartermaster
2. Quartermaster inventories resources and updates allocation
3. If active workstreams are affected, Interfacer may re-dispatch Planner to adjust plans

## Error Handling

If a subagent returns an error or "I need more context":
1. Interfacer dispatches Archivist to gather the requested context
2. Interfacer re-dispatches the original subagent with additional context
3. If the subagent fails again, Interfacer reports to user and asks for guidance
