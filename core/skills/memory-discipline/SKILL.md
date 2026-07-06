---
name: memory-discipline
description: >-
  Decide what durable cross-session signal to keep and WHICH memory system it belongs
  in. Step zero is the project's memory mode: a direct-write store (Mode A — this
  skill's file mechanics: four types, save-at-triggers, Why-line structure, index
  hygiene, staleness refresh) or a routed system with its own capture door and
  promotion machinery (Mode B — the overlay binding's router REPLACES the file
  mechanics; consult it before any save). Use whenever the operator says "remember
  this" / "note for future sessions", or proactively when a decision is made, a
  correction is given, or a project fact shifts. In Mode A do NOT save every turn —
  memory is durable signal, not session notes. NOT the lessons store (hard-won
  debugging findings go there) and NOT the state snapshot (handled by session-end).
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Memory discipline

Memory is the durable cross-session signal layer — what future sessions know that cold-start
and compaction would otherwise erase. Getting what-to-keep right matters because:

- **Too little** → future-you re-derives settled decisions, re-makes fixed mistakes, re-asks
  answered questions.
- **Too much** → the index bloats, descriptions lose signal, loaded context wastes budget on
  low-value entries.

## Step zero: which memory mode does this project run?

Check the project binding FIRST — it names the mode. Getting this wrong means saving into a
store nothing reads, or bypassing the machinery that makes a save durable.

- **Mode A — direct-write store.** The project keeps a store of memory files the agent writes
  and maintains directly. The mechanics below (four types, triggers, body structure, index,
  refresh) are the discipline. **If the binding is silent, Mode A is the default.**
- **Mode B — routed system.** The project's memory pipeline has its own front door (e.g. an
  episodic capture call feeding classification / promotion machinery, with a curated
  always-loaded tier regenerated from it). **The binding MUST supply a routing rule, and that
  router REPLACES the Mode A mechanics entirely** — do not hand-write store files the pipeline
  doesn't read. The judgment sections (what counts as durable signal, what NOT to save) still
  apply; only the mechanics change.

When systems coexist (a rules store AND an episodic diary), nothing about a bare "remember
this" tells an executor where it belongs — so the binding's router decides by KIND, not by
which store is closer:

- durable **behavioral rule / settled decision / how-we-work** signal → wherever the binding
  says rules live (a direct-write store, a rules tier, or the routed door with a promotion
  path).
- **episodic** signal — what happened, what the operator said, a fact about their world/
  people/projects → the episodic system.
- **when in doubt → the episodic system**, and let the promotion machinery sort it: a
  mis-filed episodic note is recoverable; a durable rule dropped on the floor is not.
- **a rule that must fire unprompted is not merely saved — it is armed**: promoted to the
  always-loaded tier (a pin, a constitution line, a rule file) per the binding. Filing is not
  arming.
- **The hot-buffer option (recommended for Mode B).** Promotion machinery has latency; a
  correction given today should protect the very next session. A project may keep a small
  **always-loaded lessons buffer** (an @-imported file, capped ~20 entries): on any operator
  correction or self-caught mistake, append one line (`date · rule · pointer to the episodic
  entry`) BEFORE continuing — the episodic system stays the record; the buffer is the
  zero-latency echo. The cap forces graduation at session-end: each entry becomes a durable
  rule/pin/skill fix or is dropped. Uncapped, it becomes the drawer-nobody-reads failure this
  skill exists to prevent; the cap and sweep are what make it safe.

## Mode A mechanics: the direct-write store

Everything in this section assumes Mode A. In Mode B, skip to "What NOT to save".

### The four types

| Type | Purpose | Example |
|---|---|---|
| **user** | The operator's role, goals, knowledge, responsibilities | "Runs ops + strategy; deep in one stack, new to another" |
| **feedback** | Rules about how to work — corrections, validated approaches | "Don't flag cold outreach as urgent — rewrote the triage after 3 false positives" |
| **project** | Current-state facts about ongoing work | "Merge freeze starts <date> for the release cut — flag non-critical changes" |
| **reference** | Pointers to external systems + their purpose | "Pipeline bugs tracked in <tracker> project X — check there for context" |

### Save-at-triggers rule

Save **at triggers**, not every turn:
- **~5 decisions accumulated** — batch save, not one-per-turn.
- **Phase or topic done** — wrap up that scope's decisions.
- **Context approaching compaction** — proactive persist before losing nuance.
- **Session end** — the final sweep (via `session-end`).
- **Explicit operator direction** — "remember this" → save immediately.

Do NOT save: every "ok"/"great"; session-specific context (that's the state snapshot or commit
messages); routine file edits (git history is the record); information derivable from current
code (grep works, memory is expensive).

### Body structure

#### feedback + project entries (structured)
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
The **Why** line is load-bearing. Without it, future-you follows the rule blindly and fails on
the edge cases it wasn't designed for. Include the incident or reasoning that made it a rule.

#### user + reference entries
Simpler frontmatter + prose body. User entries describe the operator. Reference entries point at
external systems with their purpose.

### Index discipline

Each index entry is one line: `- [Title](file.md) — one-line hook`, under ~150 chars. Always
update the index when adding / removing / renaming a memory file. Never write memory content
directly in the index — it's an index, not a corpus. Keep it lean; order semantically by topic,
not chronologically. Know how the index reaches sessions (auto-injected vs grepped — the
binding says which) and don't assume more than it guarantees.

### When the operator says "save X"

1. **Confirm type** — feedback / project / user / reference (and, per step zero, which system).
2. **Check for an existing entry** — grep the store for the topic; update rather than duplicate.
3. **Write frontmatter + body** per the structure above.
4. **Update the index** with the one-liner hook.
5. **Report back** — file path, index updated, done.

Keep the save atomic — not "I saved a draft, refine later." Save the final version.

### Refresh + drift

Memories go stale (names change, decisions reverse, projects end). Before acting on a memory that
names a specific thing (a file, a flag, a person, a decision): verify a named file still exists,
grep for a named function/flag, check whether a referenced decision was reversed (the state
snapshot or newer commits). If a memory conflicts with current state, **trust what you observe
now** — update or remove the stale memory rather than acting on it. Memory records are frozen at
write time; for RECENT state, `git log` + the state snapshot beat memory.

## What NOT to save (every mode)

These exclusions apply even if the operator says "save this":
- **Code patterns / conventions / architecture / file paths / project structure** → derive from
  current project state.
- **Git history / recent changes / who-changed-what** → `git log` / `git blame` are authoritative.
- **Debugging solutions / fix recipes** → the fix is in the code; the commit message has context;
  a genuinely hard-won finding goes to the **lessons store**, not memory.
- **Content already in the constitution** → it's always loaded; memory is for nuance it doesn't cover.
- **Ephemeral task details / in-progress work** → the state snapshot or open-items, not memory.

If asked to save something that belongs in one of those homes, **suggest the right home first**
and explain why. The operator may still say "save to memory anyway" — then comply; but the
default is to route correctly.

## Pairs with

- `session-end` — invokes this skill at session close (its step 3).
- `session-start` — greps the memory store for relevant entries when orienting.
- The constitution's Memory-and-Continuity section — the foundational doctrine on the
  memory/lessons/state roles.
