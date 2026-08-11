---
name: phase-start
description: >-
  Runs the grounding ladder before a new phase, subsystem, feature, schema/routing change, or architectural decision — loading the design as already-decided and verifying the plan's premises against the live runtime before theorizing. Use on "start phase X", "begin milestone Y", "/phase-start". Not session-start.
allowed-tools: Read, Grep, Glob, Bash
---

# Phase start

Phase boundaries are where the Cardinal Rule (hypothesize → research → present → implement) is
most often violated — familiarity fires the first-hypothesis trap before any research. Load the
design-as-already-decided BEFORE any new theorizing.

## What counts as "a new phase"

Anything with design context already sitting in plans, memory, or lessons: a new worker / service
/ agent · a new subsystem, milestone, or layer · a new skill, integration, or external server · a
new permission tier or security-adjacent change · a routing / scheduling / urgency change · a
schema or data-migration change · anything landing as a new file or a substantive new section in
an existing doc.

When in doubt, treat the boundary as a new phase (the ladder carries the cost math).

## The reading order

> Project bindings may prepend or amend steps — read the "## Project bindings" section (end of file) before the first step.

Follow the **shared grounding ladder** end-to-end, in order — every rung, including the lessons
grep and the reference-doc reads:
[`references/grounding-ladder.md`](references/grounding-ladder.md) — the reading spine shared with
`session-start` (single-sourced so the two can't drift): plans → current-state / reference docs →
lessons grep → memory grep → state → source → **verify the plan's premises against the runtime** →
external research → only then hypothesize. Each rung's rationale and receipts are in the ladder.

## What to produce

After the ladder is complete: **what you read** (a sentence or two per source — proves the reads
happened) · **§0 Verified-Inputs** (rung 7 — the premises you probed and what the runtime actually
showed) · **what surprised you** (what's NOT in the plan but should be; any plan-vs-runtime conflict) ·
**which pending decisions touch this phase** · **your proposed approach**, grounded in the loaded
design · **open questions** before starting.

Do NOT propose new work before the reading is done, and never propose work that contradicts a plan
without surfacing the contradiction explicitly.

## Failure modes this prevents

Cardinal-Rule violations at phase boundaries: theorizing about a subsystem without its
current-state doc, proposing an implementation without the prior-art research, re-deriving a
lifecycle/contract the reference doc documents, starting downstream work without the upstream
LOCKED invariants.

## Pairs with

- `session-start` — same grounding ladder, different trigger (fresh session vs phase boundary).
- `subsystem-grounding` — the deep arm when the subsystem's current-state doc is missing or stale:
  it re-derives the whole model (fan-out, status vocabulary) and CAPTURES it as the doc this
  ladder wanted to read.
- `research` — the ladder's external-research rung dispatches through it (pre-feed pattern).
- The constitution's Cardinal Rule + First-Hypothesis-Trap sections — the parent discipline;
  phase-start is its specialization at boundaries.
