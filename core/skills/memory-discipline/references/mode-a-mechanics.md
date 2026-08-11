# Mode A mechanics: the direct-write store

Mode B sessions skip to `memory-discipline`'s "What NOT to save".

## The four types

| Type | Purpose | Example |
|---|---|---|
| **user** | The operator's role, goals, knowledge, responsibilities | "Runs ops + strategy; deep in one stack, new to another" |
| **feedback** | Rules about how to work — corrections, validated approaches | "Don't flag cold outreach as urgent — rewrote the triage after 3 false positives" |
| **project** | Current-state facts about ongoing work | "Merge freeze starts <date> for the release cut — flag non-critical changes" |
| **reference** | Pointers to external systems + their purpose | "Pipeline bugs tracked in <tracker> project X — check there for context" |

## Save-at-triggers rule

Save **at triggers**, not every turn: **~5 decisions accumulated** (batch, not one-per-turn) ·
**phase or topic done** · **context approaching compaction** (persist before losing nuance) ·
**session end** (the final sweep, via `session-end`) · **explicit operator direction** ("remember
this" → save immediately).

Do NOT save: every "ok"/"great"; session-specific context (that's the state snapshot or commit
messages); routine file edits (git history is the record); anything derivable from current code
(grep works, memory is expensive).

## Body structure

feedback + project entries are structured:

```markdown
---
name: {{short title that reads in the index}}
description: {{one-line — used for relevance matching in future sessions; be specific}}
type: {{feedback|project}}
---

{{The rule or fact, stated clearly.}}

**Why:** {{The reason or incident. What happened that made it a rule? Future-you judges edge cases from the why.}}

**How to apply:** {{When/where does this kick in? What pattern triggers it?}}
```

The **Why** line is load-bearing — without it, future-you follows the rule blindly and fails on the
edge cases it wasn't designed for. **user + reference** entries take simpler frontmatter + prose:
user entries describe the operator, reference entries point at external systems with their purpose.

## Index discipline

Each index entry is one line — `- [Title](file.md) — one-line hook`, under ~150 chars. Always update
the index when adding / removing / renaming a memory file. Never write memory content in the index
(it's an index, not a corpus). Order semantically by topic, not chronologically. Know how the index
reaches sessions (auto-injected vs grepped — the binding says which) and don't assume more than it
guarantees.

## When the operator says "save X"

1. **Confirm type** — feedback / project / user / reference (and, per step zero, which system).
2. **Check for an existing entry** — grep the store for the topic; update rather than duplicate.
3. **Write frontmatter + body** per the structure above.
4. **Update the index** with the one-liner hook.
5. **Report back** — file path, index updated, done.

Keep the save atomic — not "I saved a draft, refine later." Save the final version.

## Refresh + drift

Memories go stale (names change, decisions reverse, projects end). Verify a memory's named things
before acting on it (constitution §Grounding Claims in Source). If a memory conflicts with current
state, **trust what you observe now** — update or remove the stale memory rather than acting on it.
For RECENT state, `git log` + the state snapshot beat memory.
