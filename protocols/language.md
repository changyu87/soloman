# Protocol: Language Handling

The Paradigm supports multilingual users while keeping all internal
artifacts in English. The Interfacer auto-detects the user's language
on every turn and mirrors it. Every file written by any role stays in
English so subagents receive consistent input across projects and
sessions.

## 1. Detection (per turn, automatic)

- The Interfacer detects the user's language from each incoming
  message. No opt-out, no `config.yaml` field.
- Mixed-language input: pick the dominant language; if tied, default
  to English.
- Proper nouns, code, file paths, and quoted strings are excluded
  from detection (they do not count as "language content").
- Language may change mid-session; every turn is re-detected
  independently.

## 2. Artifacts are English-only

All role-written files are English:

- `brief.md`, `plan.md`, `status.md`, `audit-*.md`
- `state/current.md`, `state/session-log.md`
- `knowledge/*.md`, `checkpoints/*.md`
- Any new role-written file is English by default.

## 3. Translation at presentation time

When the Interfacer presents an artifact (plan summary, status,
audit result, brief excerpt) to the user, it translates the English
source into the user's current language on the fly. The source file
stays English; translation is ephemeral.

## 4. Code is English-only

Source code, comments, commit messages, variable names, and
identifiers are English regardless of the user's language.

## 5. Role definitions are English-only

`$ROLES_DIR/*.md` and `$STATE_ROOT/roles/*.md` are English. No
translated overrides. Role files are a system contract, not
user-facing content.

## 6. Clarifying questions to the user

Asked in the user's current language. The resulting `brief.md` is
still written in English (the Interfacer translates the enriched
requirement during write).

## Worked Examples

- **Non-English turn**: user writes in a non-English language →
  Interfacer asks clarifying questions in that language → writes
  `brief.md` in English → presents plan summary translated to the
  user's language.
- **Mid-session switch**: user writes in one language on turn N and a
  different language on turn N+1 → turn N+1's reply is in the new
  language; all state files remain English.
- **Mixed-language turn**: user writes a non-English sentence
  containing English technical terms (e.g., identifiers, function
  names). The English tokens are treated as code, not language
  content, and are excluded from detection. The dominant carrier
  language wins; the Interfacer replies in the carrier language.
