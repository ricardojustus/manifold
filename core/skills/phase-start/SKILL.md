---
name: phase-start
description: >-
  Run the phase-start grounding discipline before any new phase, subsystem, or
  non-trivial feature — a new worker/service, a new skill, a new integration, a new
  permission tier, a schema or routing change, an architectural decision, or anything
  that lands as a new file or substantive new doc section. It loads the design as
  already-decided BEFORE you theorize, following the shared grounding ladder, and
  makes you verify the plan's premises against the live runtime before building.
  Invoke when the operator says "start phase X" / "begin milestone Y" / "new
  subsystem/feature/integration" / "before I commit to this design" / "/phase-start",
  and proactively the moment you sense a phase boundary. NOT the fresh-session opener
  (use session-start, same ladder, different trigger) and NOT a post-compaction pickup
  (use compact-resume). Forming hypotheses before reading what was decided is the
  documented failure mode this exists to stop.
allowed-tools: Read, Grep, Glob, Bash
---

# Phase start

Phase boundaries are where the Cardinal Rule (hypothesize → research → present → implement)
is most often violated. Pattern familiarity tempts the failure mode: "I already know how this
should work, let me start coding" — the first-hypothesis trap fired before any research. This
skill is the structural defense: load the design-as-already-decided BEFORE any new theorizing.
Nothing you propose in a new phase should surprise the prior work.

## What counts as "a new phase"

Anything with design context already sitting in plans, memory, or lessons:
- a new worker / service / agent
- a new subsystem, milestone, or layer
- a new skill, integration, or external server
- a new permission tier or a security-adjacent change
- a routing / scheduling / urgency change
- a schema or data-migration change
- anything that would land as a new file or a substantive new section in an existing doc

When in doubt, treat the boundary as a new phase. Running this skill on something that wasn't
quite a phase costs a few minutes; skipping it on something that was costs hours.

## The reading order — no exceptions, no "I already know this"

Follow the **shared grounding ladder** end-to-end, in order:
[`references/grounding-ladder.md`](references/grounding-ladder.md). It is the reading spine
this skill shares with `session-start` (single-sourced so the two can't drift): plans →
current-state / reference docs → lessons grep → memory grep → state → source → **verify the
plan's premises against the runtime** → external research → only then hypothesize.

Do not shortcut a rung. The lessons grep and the reference-doc reads in particular are hard
rules — both have receipts (in the ladder) for what breaks when they're skipped.

## The §0 Verified-Inputs note (rung 7, made concrete here)

Phase-start's distinctive output: before you propose anything, **probe the runtime to confirm
the plan's premises still hold**, and open the artifact you produce with a short **§0
Verified-Inputs** note recording what you checked and what you found. A plan's premise ("the
store is empty", "X isn't built yet", "Y is still on the old path") is a claim about a moving
system — verify it with a live probe (`ls`, a count, a query, a fresh read), don't inherit it
on faith. The §0 note makes the next reader's inputs *verified*, not *assumed*. (See the
ladder's rung-7 receipt: a whole build stage was wasted on an unprobed "it doesn't exist"
premise that was false.)

## What to produce

After the ladder is complete, report back:
- **What you read** — one or two sentences per source (proves the reads happened).
- **§0 Verified-Inputs** — the premises you probed and what the runtime actually showed.
- **What surprised you** — what's NOT in the plan but should be; any plan-vs-runtime conflict.
- **Which pending decisions touch this phase.**
- **Your proposed approach**, grounded in the loaded design.
- **Open questions** before starting.

Do NOT propose new work before the reading is done. Do NOT propose work that contradicts a
plan without surfacing the contradiction explicitly.

## Failure modes this prevents

Concrete Cardinal-Rule violations at phase boundaries this skill is built to stop:
- Forming a theory about a subsystem interaction without reading its current-state doc — and
  getting a load-bearing invariant wrong, then having to redo the work.
- Proposing an implementation without reading the prior-art research — rebuilding what a
  previous investigation already settled.
- Re-deriving a lifecycle/contract without reading the reference doc that documents it —
  getting the edge semantics wrong.
- Starting downstream work without reading the upstream LOCKED invariants — introducing drift
  a later review has to catch.

## Pairs with

- `session-start` — same grounding ladder, different trigger (fresh session vs phase boundary).
- `research` — the ladder's external-research rung dispatches through it (pre-feed pattern).
- The constitution's Cardinal Rule + First-Hypothesis-Trap sections — the parent discipline;
  phase-start is its specialization at boundaries.
