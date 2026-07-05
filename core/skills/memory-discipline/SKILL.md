---
name: memory-discipline
description: >-
  Decide what and when to save into the project's always-loaded memory store, and —
  when the project has more than one memory system — which system a given "remember
  this" belongs in. Covers the four types (user / feedback / project / reference), the
  save-at-triggers rule (~5 decisions, phase done, compaction warning, session end),
  the Why-line body structure, index hygiene, staleness refresh, and what NOT to save
  (things belonging in the lessons store, plan docs, the state snapshot, or commit
  messages). Use whenever the operator says "remember this" / "note for future
  sessions", or proactively when a decision is made, a correction is given, or a
  project fact shifts. Do NOT save every turn — memory is durable cross-session signal,
  not session notes. NOT the lessons store (hard-won debugging findings go there) and
  NOT the state snapshot (current-state + pointers, handled by session-end).
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Memory discipline

The project's memory store is always loaded into future sessions — the persistence layer that
survives cold-start and compaction. Getting what-to-save right matters because:

- **Too little** → future-you re-derives settled decisions, re-makes fixed mistakes, re-asks
  answered questions.
- **Too much** → the index bloats, descriptions lose signal, auto-load context wastes budget on
  low-value entries.

## The four types

| Type | Purpose | Example |
|---|---|---|
| **user** | The operator's role, goals, knowledge, responsibilities | "Runs ops + strategy; deep in one stack, new to another" |
| **feedback** | Rules about how to work — corrections, validated approaches | "Don't flag cold outreach as urgent — rewrote the triage after 3 false positives" |
| **project** | Current-state facts about ongoing work | "Merge freeze starts <date> for the release cut — flag non-critical changes" |
| **reference** | Pointers to external systems + their purpose | "Pipeline bugs tracked in <tracker> project X — check there for context" |

## Save-at-triggers rule

Save **at triggers**, not every turn:
- **~5 decisions accumulated** — batch save, not one-per-turn.
- **Phase or topic done** — wrap up that scope's decisions.
- **Context approaching compaction** — proactive persist before losing nuance.
- **Session end** — the final sweep (via `session-end`).
- **Explicit operator direction** — "remember this" → save immediately.

Do NOT save: every "ok"/"great"; session-specific context (that's the state snapshot or commit
messages); routine file edits (git history is the record); information derivable from current
code (grep works, memory is expensive).

## Body structure

### feedback + project entries (structured)
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

### user + reference entries
Simpler frontmatter + prose body. User entries describe the operator. Reference entries point at
external systems with their purpose.

## Index discipline

The memory index is always loaded. Each entry is one line: `- [Title](file.md) — one-line hook`,
under ~150 chars. Always update it when adding / removing / renaming a memory file. Never write
memory content directly in the index — it's an index, not a corpus. Keep it lean; order
semantically by topic, not chronologically.

## Layered memory routing (when the project has more than one memory system)

Some projects run **more than one memory system** — e.g. an always-loaded rules/decisions store
(this skill's subject) AND an episodic diary / recall system that captures what happened and what
the operator's world contains. When two systems coexist, **nothing about a bare "remember this"
tells an executor which one it belongs in** — and picking arbitrarily scatters signal across
stores where nobody finds it again.

So: **if the project has layered memory, its binding MUST supply a routing rule** naming which
system a given save goes to. Consult that rule before saving. The routing question is "what KIND
of signal is this?", not "which store is closer":
- durable **behavioral rule / settled decision / how-we-work** signal → the always-loaded memory
  store (this skill).
- **episodic** signal — what happened, what the operator said, a fact about their world/people/
  projects → the diary/recall system.
- **when in doubt → the episodic system**, and let the promotion machinery sort it: a
  mis-filed episodic note is recoverable; a durable rule dropped on the floor is not.

If the project has only one memory system, this section is a no-op — the binding says so.

## What NOT to save

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

## When the operator says "save X"

1. **Confirm type** — feedback / project / user / reference (and, if layered, which system).
2. **Check for an existing entry** — grep the store for the topic; update rather than duplicate.
3. **Write frontmatter + body** per the structure above.
4. **Update the index** with the one-liner hook.
5. **Report back** — file path, index updated, done.

Keep the save atomic — not "I saved a draft, refine later." Save the final version.

## Refresh + drift

Memories go stale (names change, decisions reverse, projects end). Before acting on a memory that
names a specific thing (a file, a flag, a person, a decision): verify a named file still exists,
grep for a named function/flag, check whether a referenced decision was reversed (the state
snapshot or newer commits). If a memory conflicts with current state, **trust what you observe
now** — update or remove the stale memory rather than acting on it. Memory records are frozen at
write time; for RECENT state, `git log` + the state snapshot beat memory.

## Pairs with

- `session-end` — invokes this skill at session close (its step 3).
- `session-start` — greps the memory store for relevant entries when orienting.
- The constitution's Memory-and-Continuity section — the foundational doctrine on the
  memory/lessons/state roles.
