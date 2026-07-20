---
name: memory-discipline
description: >-
  Decides what durable cross-session signal to keep and WHICH memory system it belongs in — check the project binding's memory mode first (direct-write store vs routed capture door). Use on "remember this" / "note for future sessions", or when a decision, correction, or project fact lands. NOT the lessons store.
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Memory discipline

Memory is the durable cross-session signal layer — what future sessions know that cold-start and
compaction would otherwise erase. Too little → future-you re-derives settled decisions and re-asks
answered questions; too much → the index bloats and loaded context wastes budget.

## Step zero: which memory mode does this project run?

Check the project binding FIRST — it names the mode. Getting this wrong means saving into a store
nothing reads, or bypassing the machinery that makes a save durable.

- **Mode A — direct-write store.** The agent writes and maintains memory files directly; the
  mechanics below are the discipline. **Binding silent → Mode A is the default.**
- **Mode B — routed system.** The pipeline has its own front door (an episodic capture call feeding
  classification / promotion machinery, with a curated always-loaded tier regenerated from it).
  **The binding MUST supply a routing rule, and that router REPLACES the Mode A mechanics
  entirely** — never hand-write store files the pipeline doesn't read. The judgment sections (what
  counts as durable signal, what NOT to save) still apply; only the mechanics change.

When systems coexist (a rules store AND an episodic diary), the binding's router decides by KIND,
not by which store is closer: durable **behavioral rule / settled decision / how-we-work** signal →
wherever the binding says rules live; **episodic** signal (what happened, what the operator said, a
fact about their world / people / projects) → the episodic system; **when in doubt → the episodic
system** and let the promotion machinery sort it (a mis-filed episodic note is recoverable; a
durable rule dropped on the floor is not). **A rule that must fire unprompted is not merely saved —
it is armed**: promoted to the always-loaded tier (a pin, a constitution line, a rule file) per the
binding. Filing is not arming.

**The hot-buffer option (recommended for Mode B).** Promotion machinery has latency, but a
correction given today should protect the very next session. A project may keep a small
**always-loaded lessons buffer** (an @-imported file, capped ~20 entries): on any operator
correction or self-caught mistake, append one line (`date · rule · pointer to the episodic entry`)
BEFORE continuing — the episodic system stays the record, the buffer is the zero-latency echo. The
cap forces graduation at session-end (each entry becomes a durable rule/pin/skill fix, or is
dropped); uncapped it becomes a drawer nobody reads.

## Mode A mechanics: the direct-write store

Mode B sessions skip to "What NOT to save".

### The four types

| Type | Purpose | Example |
|---|---|---|
| **user** | The operator's role, goals, knowledge, responsibilities | "Runs ops + strategy; deep in one stack, new to another" |
| **feedback** | Rules about how to work — corrections, validated approaches | "Don't flag cold outreach as urgent — rewrote the triage after 3 false positives" |
| **project** | Current-state facts about ongoing work | "Merge freeze starts <date> for the release cut — flag non-critical changes" |
| **reference** | Pointers to external systems + their purpose | "Pipeline bugs tracked in <tracker> project X — check there for context" |

### Save-at-triggers rule

Save **at triggers**, not every turn: **~5 decisions accumulated** (batch, not one-per-turn) ·
**phase or topic done** · **context approaching compaction** (persist before losing nuance) ·
**session end** (the final sweep, via `session-end`) · **explicit operator direction** ("remember
this" → save immediately).

Do NOT save: every "ok"/"great"; session-specific context (that's the state snapshot or commit
messages); routine file edits (git history is the record); anything derivable from current code
(grep works, memory is expensive).

### Body structure

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

### Index discipline

Each index entry is one line — `- [Title](file.md) — one-line hook`, under ~150 chars. Always update
the index when adding / removing / renaming a memory file. Never write memory content in the index
(it's an index, not a corpus). Order semantically by topic, not chronologically. Know how the index
reaches sessions (auto-injected vs grepped — the binding says which) and don't assume more than it
guarantees.

### When the operator says "save X"

1. **Confirm type** — feedback / project / user / reference (and, per step zero, which system).
2. **Check for an existing entry** — grep the store for the topic; update rather than duplicate.
3. **Write frontmatter + body** per the structure above.
4. **Update the index** with the one-liner hook.
5. **Report back** — file path, index updated, done.

Keep the save atomic — not "I saved a draft, refine later." Save the final version.

### Refresh + drift

Memories go stale (names change, decisions reverse, projects end). Before acting on a memory naming
a specific thing (a file, flag, person, decision): verify the named file still exists, grep the
named function/flag, check whether the referenced decision was reversed (the state snapshot or newer
commits). If a memory conflicts with current state, **trust what you observe now** — update or
remove the stale memory rather than acting on it. For RECENT state, `git log` + the state snapshot
beat memory.

## What NOT to save (every mode)

These exclusions apply even if the operator says "save this":

- **Code patterns / conventions / architecture / file paths / project structure** → derive from
  current project state.
- **Git history / recent changes / who-changed-what** → `git log` / `git blame` are authoritative.
- **Debugging solutions / fix recipes** → the fix is in the code, the commit message has context; a
  genuinely hard-won finding goes to the **lessons store**, not memory.
- **Content already in the constitution** → always loaded; memory is for nuance it doesn't cover.
- **Ephemeral task details / in-progress work** → the state snapshot or open-items.

Asked to save something belonging in one of those homes: **suggest the right home first** and
explain why. The operator may still say "save to memory anyway" — then comply; the default is to
route correctly.

## Pairs with

`session-end` (invokes this at session close — its step 3) · `session-start` (greps the store when
orienting) · the constitution's Memory-and-Continuity section (the memory/lessons/state roles).
