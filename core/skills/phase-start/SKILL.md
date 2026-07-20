---
name: phase-start
description: >-
  Runs the grounding ladder before a new phase, subsystem, feature, schema/routing change, or architectural decision — loading the design as already-decided and verifying the plan's premises against the live runtime before theorizing. Use on "start phase X", "begin milestone Y", "/phase-start". Not session-start.
allowed-tools: Read, Grep, Glob, Bash
---

# Phase start

Phase boundaries are where the Cardinal Rule (hypothesize → research → present → implement) is
most often violated: familiarity tempts "I already know how this should work, let me start
coding" — the first-hypothesis trap, fired before any research. Load the design-as-already-decided
BEFORE any new theorizing; nothing you propose in a new phase should surprise the prior work.

## What counts as "a new phase"

Anything with design context already sitting in plans, memory, or lessons: a new worker / service
/ agent · a new subsystem, milestone, or layer · a new skill, integration, or external server · a
new permission tier or security-adjacent change · a routing / scheduling / urgency change · a
schema or data-migration change · anything landing as a new file or a substantive new section in
an existing doc.

When in doubt, treat the boundary as a new phase: running this on something that wasn't quite a
phase costs a few minutes; skipping it on something that was costs hours.

## The reading order — no exceptions, no "I already know this"

Follow the **shared grounding ladder** end-to-end, in order:
[`references/grounding-ladder.md`](references/grounding-ladder.md) — the reading spine shared with
`session-start` (single-sourced so the two can't drift): plans → current-state / reference docs →
lessons grep → memory grep → state → source → **verify the plan's premises against the runtime** →
external research → only then hypothesize.

Do not shortcut a rung. The lessons grep and the reference-doc reads in particular are hard rules
— both have receipts in the ladder for what breaks when they're skipped.

## The §0 Verified-Inputs note (rung 7, made concrete here)

Before you propose anything, **probe the runtime to confirm the plan's premises still hold**, and
open the artifact you produce with a short **§0 Verified-Inputs** note recording what you checked
and what you found. A plan's premise ("the store is empty", "X isn't built yet", "Y is still on
the old path") is a claim about a moving system — verify it with a live probe (`ls`, a count, a
query, a fresh read), don't inherit it on faith. The §0 note makes the next reader's inputs
*verified*, not *assumed*.

## What to produce

After the ladder is complete: **what you read** (a sentence or two per source — proves the reads
happened) · **§0 Verified-Inputs** (the premises you probed and what the runtime actually showed)
· **what surprised you** (what's NOT in the plan but should be; any plan-vs-runtime conflict) ·
**which pending decisions touch this phase** · **your proposed approach**, grounded in the loaded
design · **open questions** before starting.

Do NOT propose new work before the reading is done, and never propose work that contradicts a plan
without surfacing the contradiction explicitly.

## Failure modes this prevents

Cardinal-Rule violations at phase boundaries: theorizing about a subsystem interaction without
reading its current-state doc (load-bearing invariant wrong, work redone); proposing an
implementation without reading the prior-art research (rebuilding what a previous investigation
settled); re-deriving a lifecycle/contract instead of reading the reference doc that documents it
(wrong edge semantics); starting downstream work without the upstream LOCKED invariants (drift a
later review has to catch).

## Pairs with

- `session-start` — same grounding ladder, different trigger (fresh session vs phase boundary).
- `subsystem-grounding` — the deep arm when the subsystem's current-state doc is missing or stale:
  it re-derives the whole model (fan-out, status vocabulary) and CAPTURES it as the doc this
  ladder wanted to read.
- `research` — the ladder's external-research rung dispatches through it (pre-feed pattern).
- The constitution's Cardinal Rule + First-Hypothesis-Trap sections — the parent discipline;
  phase-start is its specialization at boundaries.
