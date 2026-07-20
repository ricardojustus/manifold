---
name: orchestrator-mode
description: >-
  Session posture where the main loop stops authoring and routes ALL spec, code, and design work to the cross-model counterparty, keeping orchestration and the gates. Activates ONLY on explicit declaration — "go into orchestrator mode", "defer everything to <counterpart>"; a single delegation is cross-model-dispatch.
---

# Orchestrator Mode — the main loop conducts, the counterparty plays

A posture, declared by the operator, for stretches where the main model should not be the author —
most commonly because the session fell back below the frontier tier and the counterparty's strong
tier out-writes the fallback main. The main loop narrows to framing work, dispatching it well,
verifying what comes back, and carrying decisions to the operator.

**The posture is spoken, never assumed — only an EXPLICIT declaration counts** (operator ruling
2026-07-15). "Go into orchestrator mode" / "defer everything to <the counterpart>" activates it;
"implement this with <the counterpart>" does NOT — that dispatches ONE task via
`cross-model-dispatch`, posture off. A posture declaration names the SESSION's way of working; a
delegation names a task. Genuinely ambiguous phrase → ask. Once on, the posture survives small
intervening chat; until ended, every qualifying junction routes out.

## The contract

**The main loop KEEPS (this is the job, not the leftovers):**

- **Briefs** — every dispatch still gets a full `brief-authoring` brief; brief quality is the
  highest-leverage orchestration act.
- **Dispatch + supervision** — seat triage per `cross-model-dispatch`, watchers + timers, job
  state, re-dispatch on loss.
- **Harvest verification** — first-hand re-verification of everything a builder claims; the
  builder's green is a claim.
- **The gates** — spec-adherence, audit-cycle, council sittings: convened and dispositioned by the
  main loop, exactly as if it had built the work itself.
- **Integration edits** — applying a revision pass to a drafted spec, wiring a harvested diff's
  loose ends, fixing a rename collision.
- **Decision packets + operator comms + memory/diary/state** — never delegated, in any mode. In
  this posture every decision a packet carries has passed the mandatory advisor consult (routing
  table, first row); the packet's "watch out" line quotes the advisor's strongest dissent as usual.

**The main loop NEVER does while the posture is active:**

- Author a spec, design doc, or plan section from scratch.
- Write implementation code beyond integration edits (the test: is this edit APPLYING a harvested
  artifact, or AUTHORING new substance? Authoring routes out).
- Produce the design at a design junction solo — reasoning junctions get the advisor lens;
  design/spec/build junctions get a dispatch.

## Junction routing

| Junction | Route |
|---|---|
| **Any decision** — architecture choice, approach selection, finding disposition, anything a decision packet will carry | `cross-model-advisor` consult, **MANDATORY while the posture is active** (operator ruling 2026-07-15) — not just load-bearing ones. The main loop still consolidates and still owns the packet — the consult is an input, never the decider. |
| Plan / design question ("how should X work?") | `cross-model-advisor` (think-with), main loop consolidates — and if the outcome needs a written design/plan artifact, its DRAFTING dispatches via `cross-model-dispatch` (reasoning tier) |
| Spec to write | `cross-model-dispatch`, spec-drafter seat → main-loop revision pass in-file → normal spec flow |
| Implementation (specced) | `cross-model-dispatch`, implementer tier (reasoning tier if complex — the seat table decides, unchanged) |
| Implementation (un-specced) | `cross-model-dispatch`, reasoning tier (the ALWAYS row — posture changes nothing) |
| Review / pre-merge | `audit-cycle`, unchanged — with the builder-independence note: the counterparty built it, so the other family's reviewer seat carries the round |
| Tiny mechanical fix (typo, path, config one-liner) | Main loop just does it — dispatching a one-line fix is orchestration theater in the other direction |

## What is deliberately NOT deferred

**The gates.** Deferring the checking would hand the builder self-review — the exact independence
the cross-model doctrine protects. In this posture the main loop is MORE of a reviewer, not less:
it authored nothing, so its read of the harvested work is the fresh-eyes read. Spec-adherence,
audit rounds, verification, severity dispositions, and every operator-facing decision stay home.

**The thinking.** Orchestrator ≠ relay. The main loop still forms its own position at every
junction (what should the brief ask for? is the harvest right? does the draft fit the
architecture?).

## Ending the posture

- The operator says so ("back to normal", "you take this one", or just directs the main loop to
  author something — an explicit authoring instruction overrides the posture for that task without
  ending it; say which reading you took if ambiguous).
- The session ends. The posture is session-scoped: note it in the session's state/journal so the
  NEXT session knows it was a posture, not a new permanent process — it does not auto-resume.

## Anti-patterns

1. **Silent posture entry** — sliding into deferring-everything because quota feels tight. The
   posture is operator-declared; propose it if you think it's warranted.
2. **Gate deferral** — letting the builder's family self-certify. Never.
3. **Relay drift** — forwarding without verifying or forming a position. A session that just
   forwards artifacts between the counterparty and the operator has failed the posture.
4. **Posture creep** — still deferring everything three sessions later because nobody said stop.
   Session-scoped, always.
5. **Theater dispatches** — routing trivial mechanical fixes out to preserve posture purity;
   judgment beats ritual.
