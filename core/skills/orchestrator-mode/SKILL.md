---
name: orchestrator-mode
description: >-
  A SESSION POSTURE the operator declares, not a per-task procedure: the main loop stops
  authoring and routes ALL substantive building — spec writing, implementation, planning/design
  drafting — to the cross-model counterparty, keeping only orchestration (briefs, dispatch,
  watchers, harvest verification, gates, decision packets, operator comms, memory). Activates
  ONLY on an EXPLICIT posture declaration from the operator: "go into orchestrator mode", "act
  solely as orchestrator", "defer EVERYTHING to <the counterpart>", "defer all specs/impl/design
  to <the counterpart>". A single-task delegation — "implement this with <the counterpart>",
  "have it draft the spec" — is NOT activation: that is one cross-model-dispatch call, posture
  unchanged. Most commonly declared when the main loop has fallen below the project's frontier
  tier (quota fallback) and the counterparty's strong tier is the better author. Stays active
  until the operator ends it or the session ends —
  it never persists across sessions on its own. Owns the KEEP/NEVER contract, the junction
  routing table, and the rule that quality gates are NEVER deferred to the builder. Composes
  cross-model-dispatch (each build/spec junction), cross-model-advisor (reasoning junctions), and
  the unchanged audit gates.
---

# Orchestrator Mode — the main loop conducts, the counterparty plays

A posture, declared by the operator, for stretches where the main model should not be the
author — most commonly because the session fell back below the frontier tier and the
cross-model counterparty's strong tier out-writes the fallback main. The main loop's job
narrows to what orchestration actually is: framing work, dispatching it well, verifying what
comes back, and carrying decisions to the operator.

**The posture is spoken, never assumed — and only an EXPLICIT declaration counts** (operator
ruling 2026-07-15). "Go into orchestrator mode" / "defer everything to <the counterpart>"
activates it. "Implement this with <the counterpart>" does NOT — that sentence dispatches ONE
task via `cross-model-dispatch` and the posture stays off. The distinction is scope: a posture
declaration names the SESSION's way of working; a delegation names a task. When a phrase is
genuinely ambiguous, ask — entering a session-wide posture on an inferred signal is the
skill's first anti-pattern. Once on, the posture survives small intervening chat; until ended,
every qualifying junction routes out.

## The contract

**The main loop KEEPS (this is the job, not the leftovers):**

- **Briefs** — every dispatch still gets a full `brief-authoring` brief; brief quality is the
  single highest-leverage orchestration act.
- **Dispatch + supervision** — seat triage per `cross-model-dispatch`, watchers + timers, job
  state, re-dispatch on loss.
- **Harvest verification** — first-hand re-verification of everything a builder claims. The
  builder's green is a claim.
- **The gates** — spec-adherence, audit-cycle, council sittings: convened and dispositioned by
  the main loop, exactly as if it had built the work itself.
- **Integration edits** — applying a revision pass to a drafted spec, wiring a harvested diff's
  loose ends, fixing a rename collision. Light, judgment-applying, main-loop work.
- **Decision packets + operator comms + memory/diary/state** — never delegated, in any mode.
  In this posture every decision a packet carries has passed the mandatory advisor consult
  (routing table, first row); the packet's "watch out" line quotes the advisor's strongest
  dissent as usual.

**The main loop NEVER does while the posture is active:**

- Author a spec, design doc, or plan section from scratch.
- Write implementation code beyond integration edits (the test: is this edit APPLYING a
  harvested artifact, or AUTHORING new substance? Authoring routes out).
- Produce the design at a design junction solo — reasoning junctions get the advisor lens,
  design/spec/build junctions get a dispatch.

## Junction routing

| Junction | Route |
|---|---|
| **Any decision** — architecture choice, approach selection, finding disposition, anything a decision packet will carry | `cross-model-advisor` consult, **MANDATORY while the posture is active** (operator ruling 2026-07-15) — not just load-bearing ones. The posture exists because the main loop is below its best tier; an unconsulted decision there is the exact quality hole being plugged. The main loop still consolidates and still owns the packet — the consult is an input, never the decider. |
| Plan / design question ("how should X work?") | `cross-model-advisor` (think-with), main loop consolidates — and if the outcome needs a written design/plan artifact, its DRAFTING dispatches via `cross-model-dispatch` (reasoning tier) |
| Spec to write | `cross-model-dispatch`, spec-drafter seat → main-loop revision pass in-file → normal spec flow |
| Implementation (specced) | `cross-model-dispatch`, implementer tier (reasoning tier if complex — the seat table decides, unchanged) |
| Implementation (un-specced) | `cross-model-dispatch`, reasoning tier (the ALWAYS row — posture changes nothing) |
| Review / pre-merge | `audit-cycle`, unchanged — with the builder-independence note: the counterparty built it, so the other family's reviewer seat carries the round |
| Tiny mechanical fix (typo, path, config one-liner) | Main loop just does it — dispatching a one-line fix is orchestration theater in the other direction |

## What is deliberately NOT deferred

**The gates.** Deferring the building is the point; deferring the checking would hand the
builder self-review — the exact independence the cross-model doctrine exists to protect. In this
posture the main loop is MORE of a reviewer, not less of one: it authored nothing, so its read
of the harvested work is the fresh-eyes read. Spec-adherence, audit rounds, verification,
severity dispositions, and every operator-facing decision stay home.

**The thinking.** Orchestrator ≠ relay. The main loop still forms its own position at every
junction (what should the brief ask for? is the harvest right? does the draft fit the
architecture?). A session that stops thinking and just forwards artifacts between the
counterparty and the operator has failed the posture — the operator could have dispatched the
counterparty directly and saved a hop.

## Ending the posture

- The operator says so ("back to normal", "you take this one", or just directs the main loop to
  author something — an explicit authoring instruction overrides the posture for that task
  without ending it; say which reading you took if ambiguous).
- The session ends. The posture is session-scoped: note it in the session's state/journal so the
  NEXT session knows it was a posture, not a new permanent process — it does not auto-resume.

## Anti-patterns

1. **Silent posture entry** — sliding into deferring-everything because quota feels tight. The
   posture is operator-declared; propose it if you think it's warranted.
2. **Gate deferral** — letting the builder's family self-certify. Never.
3. **Relay drift** — forwarding without verifying or forming a position. Orchestration is a
   thinking job.
4. **Posture creep** — still deferring everything three sessions later because nobody said stop.
   Session-scoped, always.
5. **Theater dispatches** — routing trivial mechanical fixes out to preserve posture purity. The
   routing table's last row exists because judgment beats ritual.

## Test prompts

1. *"Quota's out, you're on the fallback tier — defer all spec writing and impl to the
   counterparty, you orchestrate."* → posture ON: junctions route per the table, gates stay
   home, noted in session state.
2. Mid-posture: *"actually you write this small helper yourself"* → explicit authoring
   instruction: do it in-loop, posture stays on for everything else.
3. Mid-posture, a design question comes up → advisor consult + consolidation; the resulting
   plan-section DRAFT dispatches out; the decision packet is authored home.
4. Next session opens after a posture session → posture is OFF; the state note explains
   yesterday's routing, nothing auto-resumes.
