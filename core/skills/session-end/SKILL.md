---
name: session-end
description: >-
  Runs the end-of-session sweep: commits, state-snapshot update with 4-way hygiene routing, memory saves, plan/doc updates, doc-freshness flags, lesson writeup, cold-start kickoff rewrite. Use on "wrap up", "end the session", "we're done", "/session-end". Not the mid-arc compaction checkpoint (compact-prep).
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Session end

The failure mode: finishing the task, committing code, declaring done — while the state snapshot
is stale, memory-worthy decisions unsaved, plan docs out of sync, and standing questions hanging.

With `file-at-the-event` in force, steps 2–6 are VERIFICATION checks ("anything unfiled?") —
finding production work there is exception repair for a mid-session miss, not the normal
workload. Check each step in one sentence; never default to "probably not needed."

## Sweep economy — the cost is turns, not bytes

A sweep's context growth is dominated by the session's own per-turn reasoning, not file I/O
(measured: ~2/3 of one sweep's growth was thinking/output). The sweep is MECHANICAL — write what
the session already knows, don't re-deliberate it: **no re-reads** of files you wrote or read in
this same sweep (a claim about any file NOT touched this sweep still gets the Grounding-Claims
fresh read) · **one consolidated write per file** (STATE
in a single rewrite; the corrections buffer in a single batched edit — never sequential edit
rounds) · **one commit round per repo** · skip-checks for the conditional steps are one sentence,
not investigations. A typical sweep fits in ~6 tool-turns.

## The eight-step sweep

### 1. Uncommitted state — survey every repo (`git status --short`)
Per repo with changes: **logical commit boundaries** (one commit per coherent idea — code, docs,
config separated); **messages that explain WHY, not just WHAT** ("Updated X" is useless in six
months; "migrated X to skills-first format because preloaded context doesn't scale as the tool
surface grows" is the signal); **gitignored-but-relevant state** → name it in the commit body.
Follow the project's standing branch decision (don't invent a branch for experimental work without
checking). **Never force-push or rewrite shared history** (ENFORCEMENT.md invariant #1).

### 2. State snapshot — update + 4-way hygiene routing
**State holds CURRENT STATE + POINTERS ONLY.** Route every block by the 4-way rule first, *then*
refresh what stays.

1. **Active-workstream-relevant** → KEEP (refresh to current truth).
2. **Durable settled knowledge** (decision, hard-won lesson, design fact / invariant) → its
   canonical home, then REMOVE from state — if it only lives in state, it's mis-filed. Settled
   decision / behavioral rule / project fact → the memory store (+ its index line); hard-won
   lesson → the lessons store; design intent or current-runtime state of a subsystem →
   back-propagate into the owning **plan** doc (via `plan-update`) or **reference** doc.
3. **Live open item / pending decision / backlog** not tied to the active workstream → the
   **open-items** parking lot, each tagged with its eventual proper home.
4. **Stale** (done / superseded / no longer true) → the state **archive** (retrieval-only
   graveyard), then REMOVE. The session's own narrative → the **session-log** (newest-first,
   condensed).

**Then refresh what stays**: the active-workstream block (`Updated <date>` + what moved + what's
NEXT — *one* section, replaced in place), the operational snapshot corrected to truth, the
canonical-references table (fix stale version/as-of markers), the framings-do-not-regress block,
the history pointer.

Rules: **never stack a new dated block on the old ones** — replace the active-workstream block;
prior narrative goes to the session-log. **Nothing is deleted** — every removed block lands in
open-items, the archive, the log, or a memory/lesson/plan (state is git-tracked; the pre-prune
verbatim is in history). State is typically the one file you edit + commit without asking, and
that autonomy **includes** this routing.

**STATE is an index, not the document.** A kept line is live status, a do-not-regress framing, or
a pointer — it never paraphrases its source inline (a paraphrase drifts from the source; a pointer
can't — the confabulation trap). Deep detail (constants, schemas, hash lists) lives in its own file
even when current — STATE points to it. Soft smell-target **~50 lines** (a review-trigger, not a
truncation): over it, find what's accreting — paraphrased detail, a dated block, a hash list — and
route it out. The test is "every line is live-status / framing / pointer", not the raw count.

### 3. Memory-save triggers — check the four types
Save at triggers (≈5 decisions accumulated, phase/topic done, compaction warning, session end),
not every turn. The four types are **user / feedback / project / reference**; write structure and
what-NOT-to-save belong to **`memory-discipline`** — invoke it for the saves. Here just run the
trigger check: did this session make decisions, receive a correction, or shift a project fact
worth persisting? Skip if nothing is high-signal — better a lean index than a bloated one.

### 4. Plan + architecture doc updates
Did this session change design intent OR current runtime state? **Touched a subsystem's runtime**
→ does its architecture/current-state doc need updating (subsystem shipped, contract/invariant
added or revised)? **Added a milestone or changed status** → update the implementation plan's
section + sequencing. **Changed an architectural decision** → update the doc + note rationale.
**Found a blocking design issue** → flag it in-place (banner callout). **Empirical findings
contradicting the plan** → integrate them. Do it through `plan-update` (owns the genre split,
revision bumps, dual-update rules). Architecture docs stay current with shipped reality — archive
superseded bodies, don't preserve them inline.

### 5. Doc-freshness checks — consult the project's freshness surface
If code or docs changed, consult **the project's doc-freshness mechanism** — the binding names it
(scripts to run, or a scheduled job's flags file to read) and what each check flags (a doc drifted behind its source, a runtime primitive with no doc owner, plan
short-vs-full sync, an implemented spec not promoted to a reference doc). Each emits `PASS` or
`FLAG <reason>`; **resolve every FLAG before ending** — a FLAG is an un-filed change, not a
nuisance to silence.

**Tier rule**: write a reference doc when a subsystem *stabilizes* (roughly 1-2 months without
rewrites); a mid-flight subsystem gets a HOLD/placeholder index entry, NOT a premature
current-state doc. If a subsystem stabilized this session, consider writing its doc (via
`reference-doc-writing`) and flipping its index entry to current. Any reference doc you
wrote/changed gets its index entry updated the same session.

### 6. Lesson writeup — hard-won findings only
A non-obvious bug diagnosis + fix, a vetted decision with alternatives considered, or a
third-party claim you verified/debunked → the lessons store (Problem / Root cause / Solution /
Sources / Date). One file per topic; update an existing file rather than forking a parallel one.
**Skip if no hard-won lesson landed** — if it's already in state or the commit message, it doesn't
need a lesson file.

### 7. Next-session kickoff — rewrite it for a cold stranger
Edit the stable-filename **session-kickoff** in place, for a fresh next-session-you with **zero
context from this session**: the session's purpose (1-2 sentences); the mandatory reading list
(specific paths + sections — encode the phase-start discipline of reading the design before
forming theories); the open decisions to resolve (specific: "decide X vs Y", not "think about Z");
the stable points NOT to relitigate; the workflow + "STOP at X" conditions; the operational state
(keys live? tests passing? in-flight processes?); a short pacing note. Self-contained — never
"this session" or "yesterday". **Skip the full rewrite if tomorrow is just "keep going"** — a
date-stamp + minor edit suffices; the full rewrite is for a real pivot or milestone transition.

### 8. Handoff note + log entry
One dense line to the project's task-audit log:
```
<ISO timestamp> — session summary. Commits: <hashes>. Open: <critical handoffs>. Next: <queued work>.
```
Then a **final message to the operator**: commits shipped (with hashes); open items needing THEIR
action (rotate a key, approve a sequencing, verify a regression next run); what next-session-you
will find on `session-start`; a pointer to the rewritten kickoff. If something needed an explicit
rollback and you didn't do it, SAY SO. Tone: plain English, substantive, not formal; lead with
what landed, not what's next; they read this tired — respect that with brevity.

## When to invoke

The session is wrapping: "wrap up" / "end the session" / "call it a day" / "we're done" / "let's
commit and stop" / `/session-end`, a clean stopping point, or context approaching compaction *with
the work actually ending* (if it's continuing, use `compact-prep`). Do NOT invoke on mid-task
pauses, after a single mid-session commit, or while the operator is still proposing next work.

## Pairs with

- `session-start` — the counterpart; this skill's outputs are its inputs.
- `compact-prep` — the lighter mid-arc checkpoint when work continues across a compaction.
- `memory-discipline` owns step 3's saves · `plan-update` owns step 4 · `reference-doc-writing`
  owns step 5's doc authoring.
