# Protocol: Context Overflow

This document defines how the Interfacer detects and handles approaching context window limits.

## The Problem

The Interfacer (main session) accumulates context with every:
- User message
- Subagent dispatch + return message
- File read
- Internal reasoning

Eventually the context window fills up and quality degrades. The paradigm must handle this gracefully.

## Detection

The Interfacer tracks two metrics in `state/current.md`:

| Metric | Default Threshold | Configurable In |
|---|---|---|
| Session prompt count | 15 | `config.yaml → settings.context_warn_prompts` |
| Subagent dispatch count | 10 | `config.yaml → settings.context_warn_agents` |

When EITHER threshold is exceeded, enter the Graceful Handoff protocol.

### Heuristic Rationale

- Each user prompt adds ~500-2000 tokens (user message + Interfacer response)
- Each subagent dispatch adds ~500-1500 tokens (dispatch + return message)
- At 15 prompts + 10 dispatches, roughly 20-40K tokens consumed
- Claude Code sessions typically support 100-200K context, but quality degrades well before the hard limit
- Conservative thresholds ensure handoff before quality loss

## Graceful Handoff Protocol

When a threshold is exceeded:

### Step 1: Warn the User

```
Context is approaching capacity after {N} prompts and {M} subagent dispatches.
I'll prepare for a session handoff now.
```

### Step 2: Dispatch Archivist (if not recently run)

Dispatch Archivist to:
- Update `knowledge/index.md`
- Write a checkpoint to `state/checkpoints/`
- Capture any new invariants or conventions

Skip if Archivist ran within the last 3 interactions.

### Step 3: Write Comprehensive State

Update `state/current.md` with full detail:
- Current workstream and exact phase
- What was just completed
- What should happen next
- Any pending decisions or open questions

Ensure `state/session-log.md` is up to date.

### Step 4: Advise the User

```
State saved. Here's where we are:

- Workstream: ws-{NNN} — {description}
- Phase: {phase}
- Completed: {what's done}
- Next step: {what should happen when you resume}

To continue: start a new Claude Code session and type /the-paradigm
The new session will automatically detect the saved state and offer to resume.
```

### Step 5: Stop Initiating New Work

After the handoff advisory, the Interfacer should:
- Still respond to user questions about current state
- NOT dispatch new subagents
- NOT start new workstreams
- Encourage the user to start a fresh session

## Early Warning

At 80% of threshold (e.g., 12 prompts when threshold is 15):

```
Note: We're at {N}/{threshold} prompts. Consider wrapping up the current task
before starting something new, or we'll need a session refresh soon.
```

This gives the user a chance to finish the current workstream cleanly.

## Tuning Thresholds

Users can adjust thresholds in `config.yaml`:

```yaml
settings:
  context_warn_prompts: 15  # Increase for simpler conversations
  context_warn_agents: 10   # Increase if subagent returns are small
```

Lower thresholds = more frequent handoffs but consistently high quality.
Higher thresholds = fewer handoffs but risk of quality degradation.
