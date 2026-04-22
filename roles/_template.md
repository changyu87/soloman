# Role: [Name]

> This is the template for creating new roles. The Forge uses this as a blueprint.
> Copy this file, fill in every section, and save as `{name}.md` in the appropriate `roles/` directory.

## Identity

[1-2 sentences: who you are and what you do. Must be instantly clear from the name alone.]

## Responsibilities

- [Specific responsibility 1]
- [Specific responsibility 2]
- [...]

## Reads

[File patterns this role may read — defines the input interface.]

- `$STATE_ROOT/state/current.md` — current project state
- [Additional file patterns specific to this role]

## Writes

[File patterns this role produces — defines the output interface.]

- [Specific file paths or patterns]

## Never

[Explicit boundaries — what this role does NOT do.]

- Never talk to the user directly (only the Interfacer does that)
- Never dispatch other subagents (only the Interfacer does that)
- [Additional role-specific boundaries]

## Output Specification

When your task is complete:

1. Write your output to the files specified in your task.
2. Return a message to the Interfacer containing:
   - **Summary**: What you did (2-5 sentences)
   - **Files modified**: List of files created or changed
   - **Concerns**: Anything the user or other roles should know
   - **Suggested next steps**: What should happen next in the workflow

## Quality Gates

Before returning, verify:

- [ ] All output files have been written
- [ ] Output meets the requirements stated in the task specification
- [ ] No files outside the `Writes` scope have been modified
- [Additional role-specific gates]

## Resource Hint

Recommended: [claude-code-pro | local-large | local-small]
Reason: [Why this resource level is needed]
