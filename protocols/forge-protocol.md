# Protocol: Forge Operations

This document defines the rules and procedures for creating, editing, and deleting roles.

## Who Can Invoke the Forge

The Forge is dispatched by the Interfacer when:
1. **User requests it**: "Create a Translator role", "Edit the Builder role", "Delete the X role"
2. **Planner recommends it**: Plan includes "New Roles Needed: [role name]"
3. **Interfacer identifies a gap**: A dispatched role's task clearly requires capabilities not covered by existing roles

## Operations

### Create a New Role

1. Interfacer dispatches Forge with:
   - Role name and purpose
   - Expected responsibilities
   - Whether it's universal (`$PARADIGM_REPO/roles/`, self-mode only) or project-specific (`$STATE_ROOT/roles/`)
2. Forge reads `_template.md` and creates the new role file
3. Forge returns confirmation + reload advisory
4. Interfacer reloads from disk — the new role is immediately dispatchable

### Edit an Existing Role

1. Interfacer dispatches Forge with:
   - Which role to edit
   - What changes are needed and why
2. Forge reads the current role file, makes changes
3. Forge returns summary of changes + reload advisory
4. Interfacer reloads from disk

### Delete a Role

1. **Approval required**: The task specification MUST state that user or Planner has approved the deletion.
2. Forge verifies it is NOT being asked to delete itself (invariant: Forge cannot be deleted).
3. Forge deletes the role file.
4. Forge returns confirmation.
5. Interfacer notes the role is no longer available.

## Invariants

1. **Self-preservation**: The Forge can edit `forge.md` but CANNOT delete it. If asked to delete itself, it must refuse and report the refusal to the Interfacer.

2. **Template compliance**: Every role created or edited MUST follow the `_template.md` structure:
   - Identity (1-2 sentences)
   - Responsibilities (list)
   - Reads (file patterns)
   - Writes (file patterns)
   - Never (boundaries, must include "no user talk" and "no subagent dispatch")
   - Output Specification
   - Quality Gates
   - Resource Hint

   **Reference-document exemption**: A role file is a *reference document* if its opening block explicitly declares it (e.g., `> This is a **reference document**, NOT a subagent prompt.`). Reference documents describe a role's contract for other roles to read; they are not dispatched as subagents. For these files, `Output Specification` and `Quality Gates` are NOT required and MUST NOT be added by the Forge. All other sections (Identity, Responsibilities, Reads, Writes, Never, Resource Hint) remain required. The canonical example is `roles/interfacer.md` — the Interfacer's behavior lives in `skill/SKILL.md`, not in a dispatch prompt.

3. **Immediate usability**: The Interfacer reads role definitions from disk at dispatch time. Writing a file = creating a dispatchable role. No restart or reconfiguration needed.

4. **Reload mandate**: After ANY Forge operation, the Interfacer MUST reload the affected role definition from disk before the next dispatch of that role. The Forge's return message includes a reload advisory.

5. **Deletion requires approval**: The Forge will not delete a role unless the task specification explicitly states that user or Planner has approved. The Forge should verify this.

## Location Rules

| Scope | Directory | When to Use | Availability |
|---|---|---|---|
| Universal | `$PARADIGM_REPO/roles/` | Role is useful across all projects; writes the source repo | Self-mode only |
| Project-specific | `$STATE_ROOT/roles/` | Role is only relevant to this project | Both modes |

The installed skill bundle at `$SKILL_DIR/roles/` is read-only at runtime — universal edits happen against the source repo (`$PARADIGM_REPO`) and are picked up by other installs after they re-run `install.sh`.

In normal mode, `$PARADIGM_REPO` is unset: if asked to edit a universal role, the Forge refuses and directs the user to clone the source repo and invoke `/the-paradigm` there.

At dispatch time, when a role exists in both `$PARADIGM_REPO/roles/` (or `$SKILL_DIR/roles/` in normal mode) and `$STATE_ROOT/roles/`, the project-specific version takes precedence (override).

## Self-Improvement

The Forge can edit its own definition (`forge.md`). This enables the paradigm to improve its own meta-capabilities. However:
- Self-edits should be conservative and well-reasoned
- The Forge should explain why the self-edit improves its capabilities
- Core invariants (especially self-preservation) must be maintained in any self-edit
