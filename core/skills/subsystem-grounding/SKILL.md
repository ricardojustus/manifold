---
name: subsystem-grounding
description: >-
  Re-derive your model of a WHOLE subsystem from its sources before working on or
  advising about it, and CAPTURE the result as a durable dated grounding doc so the
  next session reads instead of re-derives (each pass shrinks the doc-corpus debt).
  Fires when: (1) starting work on a subsystem that lacks a fresh current-state doc
  and wasn't read this session — phase-start's deep-grounding arm; (2) CIRCUIT
  BREAKER: corrected twice on the same subsystem in a session — stop advising,
  declare the stale model, re-ground (a correction about system behavior is never
  just a fact-patch); (3) the operator says "ground yourself on X". Depth is
  proportional: single-lane read for a narrow touch; parallel fan-out (cheap readers,
  cross-check agent, forced status vocabulary RUNNING/GATED/RETIRED/SPEC-ONLY,
  citation per claim) for whole-subsystem grounding. NOT a single-assertion doc
  lookup, NOT compact-resume (checkpoint working set), NOT research (open questions).
allowed-tools: Read, Grep, Glob, Bash, Write, Agent, Workflow
---

# Subsystem grounding — re-derive the model, capture the doc

## Why this exists (the receipt)

2026-07-06: after a context compaction, a session carried a lossy paraphrase of a memory
subsystem's architecture **with full confidence** — a summary feels like memory. Over one
evening it advised at architecture level while factually wrong about which fixes were built
vs parked, which pipelines were live vs retired vs gated, what a running daemon actually did,
and whether a nightly worker existed. The killer wasn't any single wrong fact — it was the
**correction-patch-continue loop**: each operator correction got patched as one local fact
and the advising continued, never generalizing to "my entire model of this subsystem is
stale." It took an explicit operator order ("FULLY ground yourself — no more surface greps")
to break the loop. The single-assertion lookup rules never fired, because no single assertion
was the problem — the *model* was.

## The standing rule

**An operator correction about system behavior is never just a fact-patch — it is evidence
that the model behind your advice is stale.** One correction: fix the fact AND ask what else
that model got wrong. Two corrections on the same subsystem in one session: the model is
globally stale. **Stop advising. Say so plainly** ("I've been corrected twice on X; my model
of it is stale — I need to re-ground before saying more"), then re-ground at the proportional
depth. Patching the second correction and continuing is the failure mode, not a recovery.

## Triggers

1. **Starting work on a subsystem** that has no fresh current-state doc AND whose sources you
   have not read this session. This is `phase-start`'s deep-grounding arm: the phase-start
   ladder tells you *what to read*; when the current-state doc is missing or stale, THIS
   skill's fan-out derives it — and captures it, so the gap closes for good.
2. **The circuit breaker** — two corrections, same subsystem, one session (see the standing
   rule). Depth choice: ask the operator when present; during autonomous work decide by
   severity and record the call.
3. **The operator says "ground yourself on X"** — run the full procedure.

**The floor, always:** architecture-level advice (recommending changes, designs, priorities —
as opposed to answering a lookup) about a subsystem you haven't read this session gets, at
minimum, the single-lane read first. A summary carried across a compaction does not count as
having read anything.

## Depth triage (proportionality guard)

- **Single-lane read** — a narrow question, one component, or a fresh capture already exists:
  read the current-state doc / latest grounding capture end-to-end, freshness-check it
  (below), spot-verify the claims your work touches. Minutes.
- **Full fan-out** — whole-subsystem grounding: no current doc, a stale model (circuit
  breaker), or operator-ordered. Expensive by design; it fires on the triggers, not
  routinely — and it pays for itself by producing the capture.

## The fan-out procedure

1. **Slice the subsystem into lanes** (ingest path, storage layer, read path, daemons/jobs,
   config/gates — whatever the subsystem's real seams are). One reader agent per lane,
   **cheap/mid-tier models** (this is disciplined reading, not judgment).
2. **Each lane reads END-TO-END, in the mandatory order** of the shared grounding ladder
   (`../phase-start/references/grounding-ladder.md`): current-state reference docs → the
   governing LOCKED specs **including archived/superseded predecessors** (a dead spec still
   records the architecture's reasoning) → the real code paths, entry to exit. **Live-system
   probes are encouraged and read-only**: process lists, log tails, read-only DB queries.
   No surface greps — a function signature proves existence, never behavior.
3. **Citation per claim** — every claim carries `file:line` or `doc#section` (or the probe
   command + output). Anything not proven carries an explicit `UNVERIFIED:` marker.
4. **Forced status vocabulary** — every component gets exactly one label:
   - **RUNNING** — process/log/probe evidence cited;
   - **GATED** — built but behind a gate; the exact gate named (flag, wiring, env);
   - **RETIRED** — no longer in the path; when and why;
   - **SPEC-ONLY** — designed, not built.
   The words "live", "exists", "we built" are **banned** — they are where the failure hides.
5. **Cross-check agent** over all lane outputs: contradictions between lanes, status-label
   audit (evidence actually cited?), coverage gaps against the subsystem index, and direct
   cited answers to the specific questions the operator disputed (if the circuit breaker
   fired, those questions ARE the acceptance test).
6. **The orchestrator reads every output file itself.** Delegating the reading defeats the
   purpose — the point is YOUR model, rebuilt from evidence. Then write the capture.

## The capture (the step that compounds)

The output is not a transcript — it is a **durable, dated grounding document**:

- component inventory with the status vocabulary + evidence citations;
- the data flows (what actually feeds what, entry to exit);
- direct answers to the disputed/driving questions, cited;
- an honest gaps section (`UNVERIFIED:` items, lanes not covered);
- an **as-of date** on top (finding-freshness: this is an observation, not a law).

File it per `doc-placement`: a **stable** subsystem's capture folds into (or becomes) the
proper current-state reference doc (`reference-doc-writing`); a **mid-churn** subsystem gets
a dated grounding capture in the project's workspace, **pointed at from the subsystem index's
gap entry** so the next session finds it instead of re-deriving. Either way the doc-corpus
debt shrinks — if the corpus were complete and fresh, this skill would rarely fire.

**Freshness protocol for an existing capture:** read it end-to-end, check the as-of date
against the subsystem's recent commits, spot-verify the RUNNING claims your work depends on.
Fresh-enough → proceed (single-lane). Stale → re-ground the lanes that moved, update the
capture's date and changed rows.

## What this is NOT

- **Not the single-assertion lookup** (the project's doc-retrieval discipline covers "check
  the doc before asserting one fact") — this rebuilds the whole model.
- **Not `compact-resume`** — that re-reads the checkpoint's named working set; this covers
  subsystems OUTSIDE the checkpoint that you're about to advise on anyway.
- **Not `research`** — that answers open questions from external + project sources; this
  re-derives internal ground truth from the system itself.
- **Not `system-audit`** — that hunts defects in a subsystem; this establishes what the
  subsystem IS. (An audit often wants this first.)

## Pairs with

- `phase-start` — the trigger-1 host: its grounding ladder names the reading order; this
  skill is the deep arm + capture when the doc is missing.
- `reference-doc-writing` + `doc-placement` — the capture's graduation path and filing rules.
- `grounding-and-confabulation` (principle) — the epistemics this skill mechanizes.
- `model-economy` (principle) — cheap readers, frontier judgment.
- The overlay binding names the doc corpus, the capture directory, index-registration
  mechanics, and a worked fan-out example.
