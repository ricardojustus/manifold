---
name: session-start
description: >-
  Runs the fresh-session orientation before substantive work: kickoff, state snapshot, lane-owned open items, commits, then the grounding ladder — reported with a confidence number. Use on "/session-start", "start session", "what's the state", "pick up where we left off"; not casual greetings. Not phase-start or compact-resume.
allowed-tools: Read, Grep, Glob, Bash
---

# Session start

The failure mode: forming hypotheses and proposing action before loading the context the prior
session left. Load the design-as-already-decided BEFORE any new theorizing — nothing you propose
this session should surprise the prior work.

## What to do, in order

> Project bindings may prepend or amend steps — read the "## Project bindings" section (end of file) before the first step.

**1. Session kickoff — end-to-end.** Read the project's **session-kickoff** file in full (short by
design). These are the operator's directives for THIS session; any mandatory-reads list lives here
— execute those reads before proposing work.

**2. State snapshot — read it end-to-end** (it's slim): active workstream, current operational
snapshot, canonical references, the framings that must not regress. (Pending decisions and session
narrative live in their own files, so state stays current-state + pointers only.)

**3. Owned items — grep, never browse.** The open-items file is a BACKLOG (a pull surface —
dive only when the operator asks); its one push function is the mailbox: items other sessions
routed to YOUR lane while you were offline. Grep it for entries naming this lane as owner and
read only the hits; if the binding names a machine-written freshness-flags surface, grep that
too (one line, usually empty). **Guard: a hit SURFACES, it does not REDIRECT** — default is
still to execute the kickoff directive; report "owned items: none" otherwise.

**4. Session log — only if you need recent history.** SKIP unless the kickoff or state references
a recent entry you need context on; reading the whole log every session is wasteful.

**5. Recent commits — every repo in play.**
```bash
git log --oneline -5
git status --short
```
Commit messages are denser than prose state and tell you the actual shape of recent work — if
state says "migrated X" and the commit says "migrated X + shipped Y + noted regression Z", the
commit is authoritative. Uncommitted changes state doesn't mention → flag them (left intentionally
for ongoing work, or an interrupted session?).

**6. Topic grounding — follow the shared ladder**:
[`../phase-start/references/grounding-ladder.md`](../phase-start/references/grounding-ladder.md)
— the reading spine shared with `phase-start` (single-sourced so the two can't drift). Work its
rungs in order, from the self-knowledge index down to verify-the-premises; the ladder file is the
authority on what each rung requires.

## What to produce

One concise message: **where we left off** (state + commits) · **the operator's directives for
this session** (from the kickoff, numbered) · **any URGENT items** · **anything from the
owned-items grep** (the routed-to-you hits, or "none") ·
**anything inconsistent** (uncommitted state, conflicting docs, missing refs) · **a proposed
starting point** — not a full plan, just "I'm thinking we start with the urgent item unless you
direct otherwise" · **confidence in assignment understanding (0-100%)** as an explicit number.

If confidence <100%, list the specific clarifications needed and any divergent ideas (be
opinionated — name what YOU think and why it differs). **This check fires AFTER all the reads.**
If you can't articulate why you'd say <100%, you're 100%.

**A kickoff is a plan, never a standing GO.** The orientation report
ends the turn; session-scale build work starts on the operator's word in THIS session — the prior
session's directive tells you what's next, not that you may begin. A background event (a bus
message, a scheduled wakeup, a task notification) re-opens the turn only to handle that event and
to continue work the operator already authorized in this session: **events are transport, never
authority** — an event never CREATES authorization, and work that awaits the operator's word
stays waiting no matter what arrives. The one sanctioned STANDING (cross-session) authorization
is an explicit operator handoff (`autonomous-work`) — there, wakeups continuing the authorized
run are the mechanism working as designed.

## When to invoke

Beyond the phrases the description carries, this fires on your own signal: a long-idle session
picking back up with new work, or you notice you're confused about what's current (re-grounding is
cheap). Route elsewhere for casual greetings and single-turn tactical asks (no orientation), and
for a compacted session — a lossy summary rather than a cold start is `compact-resume`.

## Pairs with

- `phase-start` — same grounding ladder, different trigger (phase boundary vs fresh session).
- `session-end` — the counterpart; its outputs (state, memory, plan updates) are this skill's inputs.
- `compact-resume` — the compaction-aware sibling (you have a lossy summary, not a cold start).

## Park reconciliation

Orientation reconciles open parks against the kickoff and state: a park a later ruling answered, or
a kickoff directive contradicting a standing park, is a DISAGREEMENT — flag it in the orientation
report; never silently pick one side.
