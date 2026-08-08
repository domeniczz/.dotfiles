---
description: Analyze the current session for workflows worth extracting into a reusable skill
---

IMPORTANT: This command has a single, focused purpose. Do not use todowrite to plan this task.

Audit this session for procedures worth promoting to a skill. This is judgment work, not a checklist to satisfy — most sessions produce zero or one good idea, and forcing more than that defeats the purpose.

## What earns a skill

A candidate must clear all of these:

1. **General** — the trigger condition and steps apply beyond this one session (a request type, not a fact about this specific bug/file/dataset).
2. **Tedious from scratch** — doing it without a skill requires multiple non-obvious steps: research/lookup, a specific tool sequence, a fiddly setup, or knowledge that isn't in the model's training (project conventions, an internal API shape, a multi-stage script).
3. **Not already covered** — list `~/.config/opencode/skills/*/SKILL.md` (and project `.opencode/skills/` if present) and check names/descriptions before proposing. If an existing skill already does this, say so instead of duplicating.

Reject anything that's a one-off (specific to this exact file/bug/dataset with no recurrence), trivial (one command, one obvious edit), or already a skill.

## Scope: project or global

For each surviving candidate, judge where it belongs:

- **Project** (`.opencode/skills/`) — tied to this repo's structure, conventions, stack, or internal tooling (e.g. anything that depends on this project's `AGENTS.md` rules, its specific services, its build commands). Wouldn't make sense or wouldn't apply in an unrelated repo.
- **Global** (`~/.config/opencode/skills/`) — useful regardless of which project the user is in (a general dev workflow, a tool-agnostic procedure, something about the user's own machine/accounts/habits).

State the scope call and a one-line reason for each idea. If genuinely unclear, say so and let the user decide.

## Process

1. Re-read the session for: multi-step procedures worked through, research that would have to be redone next time, corrections the user made that reveal a non-obvious rule, and any point where you had to figure out "how does this project/tool actually work" the hard way.
2. Check existing skills (step 3 above) before proposing anything.
3. For each real candidate, judge it against the three criteria above out loud (briefly) before including it — don't skip this filter.
4. If nothing survives the filter, say so directly: "Nothing in this session earns a skill — it was mostly one-off work." Do not manufacture a marginal idea just to have something to show.

## Output format

For each surviving idea (ordered most valuable first, capped at 3):

```
### <skill-name>
Scope: Project (.opencode/skills/) | Global (~/.config/opencode/skills/) — <one-line reason>
Trigger: <the kind of request/phrase that should invoke it>
Why: <one line — what made it tedious/non-obvious this time>
Sketch: <2-4 bullet steps it would encode>
```

This command only analyzes and reports — it does not create any files. After listing (or after saying there's nothing), ask if the user wants to build one out and at which scope. If yes, hand off to the `skill-creator` skill to draft and iterate on it at the confirmed scope — do not draft or write the SKILL.md yourself.
