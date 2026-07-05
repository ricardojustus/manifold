---
name: session-start
description: >-
  Run the start-of-session protocol before SUBSTANTIVE work: read the session
  kickoff (today's directives), the state snapshot, glance the open-items backlog,
  check recent commits, then follow the shared grounding ladder for the topic reads,
  and report where things stand plus an explicit confidence number. Loads the design
  as already-decided so you don't propose work before reading it. Use ONLY when the
  operator orients the session for real work: "/session-start", "start session",
  "pick up where we left off", "what's the state", "continue from yesterday". Do NOT
  fire on casual openers ("hi"), quick one-off asks ("real quick", "one small thing"),
  or single-turn tactical requests — that wastes context budget. NOT a phase-boundary
  entry (use phase-start, same ladder) and NOT a post-compaction pickup (use
  compact-resume — you have a summary, not a cold start).
allowed-tools: Read, Grep, Glob, Bash
---

# Session start

A persistent failure mode: forming hypotheses and proposing action before loading the context
the prior session left. This skill codifies the checklist so it happens automatically. The
whole point is to load the design-as-already-decided into context BEFORE any new theorizing —
nothing you propose this session should surprise the prior work.

## What to do, in order

### 1. Session kickoff — end-to-end
Read the project's **session-kickoff** file in full (it's short by design). These are the
operator's directives for THIS session; any mandatory-reads list lives here — execute those
reads before proposing work.

### 2. State snapshot — read it, it's slim
Read the live **state** snapshot end-to-end: active workstream, current operational snapshot,
canonical references, and the framings that must not regress. (Pending decisions and session
narrative live in their own files — see below — so state stays current-state + pointers only.)

### 3. Open-items backlog — glance, don't dive
Scan the **open-items** category headers (session-end *writes* it; session-start *consults*
it — the read/write symmetry that keeps the backlog from rotting into a write-only graveyard).
Ask three things:
- **Does any parked item intersect today's directed work?** If so, fold it in.
- **Is anything newly unblocked** (a dependency shipped) **or newly stale** (superseded)?
- Keep general eyes on the backlog — surfacing at the right time is your job.

**Guard: the glance SURFACES, it does not REDIRECT.** Default is still to execute the kickoff
directive. Flag an intersecting / urgent / now-stale item in your summary; otherwise one line
("open-items: N, nothing intersects today") and proceed. Don't pull a backlog item into scope
just because you saw it.

### 4. Session log — only if you need recent history
Append-only session history. SKIP unless the kickoff or state references a recent entry you
need context on. Reading the whole log every session is wasteful — that's why it's separate.

### 5. Recent commits — every repo in play
```bash
git log --oneline -5
git status --short
```
Commit messages are denser than prose state; they tell you the actual shape of recent work. If
state says "migrated X" and the commit says "migrated X + shipped Y + noted regression Z", the
commit is authoritative. Uncommitted changes that state doesn't mention → flag them (left
intentionally for ongoing work, or an interrupted session?).

### 6. Topic grounding — follow the shared ladder
Run the **shared grounding ladder** for the topic reads:
[`../phase-start/references/grounding-ladder.md`](../phase-start/references/grounding-ladder.md).
It is the reading spine this skill shares with `phase-start` (single-sourced so the two can't
drift): consult the project's **always-loaded self-knowledge index** and read **end-to-end**
every current-state reference doc relevant to today's work, then the lessons grep, the memory
grep, the source, and the verify-the-premises rung. Do not reconstruct which doc covers which
subsystem from memory — consult the index; it's regenerated, your recollection is not.

## What to produce

**One message summarizing:**
- **Where we left off** (from state + commits).
- **The operator's directives for this session** (from the kickoff — numbered).
- **Any URGENT items** flagged for immediate attention.
- **Anything from the open-items glance** that intersects, is newly unblocked, or went stale
  (one line if nothing).
- **Anything inconsistent** you noticed (uncommitted state, conflicting docs, missing refs).
- **Proposed starting point** — NOT a full plan, just "I'm thinking we start with the urgent
  item unless you direct otherwise."
- **Confidence in assignment understanding (0-100%)** — an explicit number. If <100%, list the
  specific clarifications needed and any divergent ideas (be opinionated — name what YOU think
  and why it differs). **This check fires AFTER all the reads** (the reads are what build the
  understanding to be confident about — a confidence check before them is meaningless). If you
  can't articulate why you'd say <100%, you're 100%.

Keep it concise. The operator already knows most of this — your job is to confirm you loaded
it, then let them redirect.

**Do NOT**: propose new work beyond what the kickoff/state direct; form bug hypotheses before
reading the relevant reference doc; start editing in this first turn; volunteer architecture
opinions before loading the design.

## When to invoke

Fresh session oriented for substantive work: the operator says "start the session" / "where
were we" / "what's the state", or a long-idle session picks back up with new work, or you
notice you're confused about what's current (re-grounding is cheap). Do NOT fire on casual
greetings or single-turn tactical asks.

## Why this exists

The cost of reading state + commits + lessons is a few minutes; the cost of skipping it is the
operator pulling you back, re-grounding you, and losing trust that you did your homework. It
prevents: theorizing about a bug before grepping lessons for the solved case; re-proposing
work already done and documented; re-asking a standing decision; editing files before reading
the design that governs them.

## Pairs with

- `phase-start` — same grounding ladder, different trigger (phase boundary vs fresh session).
- `session-end` — the counterpart; its outputs (state, memory, plan updates) are this skill's
  inputs.
- `compact-resume` — the compaction-aware sibling (you have a lossy summary, not a cold start).
