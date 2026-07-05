---
name: session-end
description: >-
  Run the end-of-session sweep so no handoff gets dropped. Eight steps: commit
  uncommitted state (clear WHY messages), update the state snapshot with its 4-way
  hygiene routing (keep in state / durable→canonical home / live item→open-items /
  stale→archive+log), save memory at triggers, update plan + architecture docs if
  intent or runtime shifted, run the project's doc-freshness checks (the binding names
  the scripts), write up any hard-won lesson, rewrite the session-kickoff for a
  cold-start next session, and log + hand off. Use when the session is wrapping —
  "wrap up", "end the session", "we're done", "good stopping point", "/session-end".
  NOT a mid-arc checkpoint across compaction (use compact-prep — you're continuing,
  not closing) and NOT the memory-save detail itself (that's memory-discipline). Don't
  just commit and exit — every step here has been forgotten before and had to be
  recovered.
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Session end

A persistent failure mode at session close: finishing the task, committing code, declaring
done — while leaving the state snapshot stale, memory-worthy decisions unsaved, plan docs out
of sync with what landed, and standing questions hanging. This skill codifies the sweep.

Not every session triggers every step — if nothing memory-worthy landed, skip memory; if plans
were untouched, skip them. But actively CHECK each one. Don't default to "probably not needed."

## The eight-step sweep

### 1. Uncommitted state — survey every repo
```bash
git status --short
```
For each repo with changes:
- **Identify logical commit boundaries** — separate code from docs from config where it makes
  sense. One commit per coherent idea beats one commit for everything.
- **Write messages that explain WHY, not just WHAT.** "Updated X" is useless in six months;
  "migrated X to skills-first format because preloaded context doesn't scale as the tool
  surface grows" is the signal.
- **Check for gitignored-but-relevant state** — if a gitignored config changed and it matters
  for the handoff, mention it in the commit body.
- Follow the project's standing branch decision; don't invent a branch for experimental work
  without checking. **Never force-push or rewrite shared history** (a bright line — see the
  enforcement doctrine).

### 2. State snapshot — update + 4-way hygiene routing
The state snapshot is the file future-you opens first — and the one that bloats fastest if
nothing prunes it (every session is tempted to stack a fresh dated block on top of the old
ones). **State holds CURRENT STATE + POINTERS ONLY.** Every session-end, route each block by
the 4-way rule first, *then* refresh what stays.

**For every block in state, ask "which bucket?":**
1. **Relevant to the active workstream** → KEEP (refresh to current truth).
2. **Durable settled knowledge** (a decision, a hard-won lesson, a design fact / invariant) →
   its canonical home, then REMOVE from state. State is NOT the permanent home for durable
   facts — if it only lives in state, it's mis-filed:
   - settled decision / behavioral rule / project fact → the memory store (+ its index line)
   - hard-won lesson → the lessons store
   - design intent or current-runtime state of a subsystem → back-propagate into the owning
     **plan** doc (via `plan-update`) or **reference** doc
3. **Live open item / pending decision / backlog** not tied to the active workstream → the
   **open-items** parking lot. Tag each with its eventual proper home.
4. **Stale** (done / superseded / no longer true) → append to the state **archive**
   (retrieval-only graveyard), then REMOVE from state. The session's own narrative → the
   **session-log** (newest-first, condensed).

**Then refresh what stays**: the active-workstream block (`Updated <date>` + what moved +
what's NEXT — *one* section, replaced in place), the current operational snapshot corrected to
truth, the canonical-references table (fix stale version/as-of markers), the
framings-do-not-regress block, and the history pointer.

Rules:
- **Never stack a new dated block on top of the old ones** — that stacking is what bloats
  state. Replace the active-workstream block; the prior narrative belongs in the session-log.
- **Nothing is deleted** — every removed block lands in open-items, the archive, the log, or a
  memory/lesson/plan. State is git-tracked; the pre-prune verbatim is always in history.
- The state snapshot is typically the one file you can edit + commit without asking each time,
  and that autonomy **includes** this hygiene routing.

### 3. Memory-save triggers — check the four types
Save at triggers (≈5 decisions accumulated, phase/topic done, compaction warning, session end),
not every turn. The four types are **user / feedback / project / reference**; the write
structure and the what-NOT-to-save rules are owned by the **`memory-discipline`** skill —
invoke it for the actual saves. Here, just run the trigger check: did this session make
decisions, receive a correction, or shift a project fact worth persisting? Skip if nothing is
high-signal — better a lean index than a bloated one.

### 4. Plan + architecture doc updates
Did this session change design intent OR current runtime state?
- **Touched a subsystem's runtime** → check whether its architecture/current-state doc needs an
  update (a subsystem shipped, a contract/invariant added or revised).
- **Added a milestone or changed status** → update the implementation plan's section + sequencing.
- **Changed an architectural decision** → update the doc + note rationale.
- **Found a blocking design issue** → flag it in-place (banner callout).
- **Made empirical findings that contradict the plan** → integrate them.

Do this through `plan-update` (it owns the genre split, revision bumps, and dual-update rules).
Architecture docs stay current with shipped reality — archive superseded bodies, don't preserve
them inline.

### 5. Doc-freshness checks — run the project's checks
If this session changed code or docs, run **the project's doc-freshness checks**. The project
binding names the concrete scripts and states what each one flags (drift of a doc behind its
source, a runtime primitive with no doc owner, plan short-vs-full sync, an implemented spec not
promoted to a reference doc). Each check emits `PASS` or `FLAG <reason>`; **resolve every FLAG
before ending the session** — a FLAG is an un-filed change, not a nuisance to silence.

**Tier rule**: write a reference doc when a subsystem *stabilizes* (roughly 1-2 months without
rewrites); a mid-flight subsystem gets a HOLD/placeholder index entry, NOT a premature
current-state doc that goes stale immediately. If a subsystem stabilized this session, consider
writing its doc (via `reference-doc-writing`) and flipping its index entry to current. Any
reference doc you wrote/changed this session must have its index entry updated the same session.

### 6. Lesson writeup — for hard-won findings only
If this session produced a non-obvious bug diagnosis + fix, a vetted decision with alternatives
considered, or a third-party claim you verified/debunked → write it to the lessons store
(Problem / Root cause / Solution / Sources / Date). One file per topic; update an existing file
rather than forking a parallel one. **Skip if no hard-won lesson landed** — the lessons store is
not a dumping ground for session notes. If it's already in state or the commit message, it
doesn't need a lesson file.

### 7. Next-session kickoff — rewrite it for a cold stranger
Edit the stable-filename **session-kickoff** file in place. It's for a fresh next-session-you
with **zero context from this session** — assume nothing carried forward beyond state + memory
+ the docs you just updated. It should state: the session's purpose (1-2 sentences); the
mandatory reading list (specific paths + sections — the phase-start discipline says read the
design before forming theories, so encode that here); the open decisions to resolve (specific:
"decide X vs Y", not "think about Z"); the stable points NOT to relitigate; the workflow +
"STOP at X" conditions; the operational state (keys live? tests passing? in-flight processes?);
and a short pacing note. Write it self-contained — don't reference "this session" or
"yesterday". **Skip the full rewrite if tomorrow is just "keep going"** — a date-stamp + minor
edit suffices; the full rewrite is for a real pivot or milestone transition.

### 8. Handoff note + log entry
Append one dense line to the project's task-audit log:
```
<ISO timestamp> — session summary. Commits: <hashes>. Open: <critical handoffs>. Next: <queued work>.
```
Then a **final message to the operator**: commits shipped (with hashes); open items that need
THEIR attention (things only they can act on — rotate a key, approve a sequencing, verify a
regression in the next run); what next-session-you will find on `session-start`; a pointer to
the rewritten kickoff. If something needed an explicit rollback and you didn't do it, SAY SO.

## When to invoke

The session is wrapping: "wrap up" / "end the session" / "call it a day" / "we're done" /
"let's commit and stop" / `/session-end`, or a clean stopping point, or context approaching
compaction *with the work actually ending* (if it's continuing, use `compact-prep`). Do NOT
invoke on mid-task pauses, after a single mid-session commit, or while the operator is still
proposing next work.

## Tone for the final message

Plain English, substantive, not formal. Lead with what landed, not what's next. The operator
reads this tired — respect that with brevity.

## Pairs with

- `session-start` — the counterpart; this skill's outputs are its inputs.
- `compact-prep` — the lighter mid-arc checkpoint when work continues across a compaction.
- `memory-discipline` — owns step 3's actual saves. `plan-update` — owns step 4. `reference-doc-writing` — owns step 5's doc authoring.
