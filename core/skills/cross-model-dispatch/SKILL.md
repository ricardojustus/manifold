---
name: cross-model-dispatch
description: >-
  Dispatches the cross-model counterparty as a BUILDER — an implementer working a brief, or a spec-drafter whose draft the main model revises. Use on "have <counterpart> build this", "send codex as implementer", "<counterpart> drafts the spec". Not the audit lens (audit-cycle) or the peer consult (cross-model-advisor).
---

# Cross-Model Dispatch — the counterparty as builder

The harness runs the cross-model counterparty in three genres: **judge** (audit-cycle), **peer**
(cross-model-advisor), and — this skill — **builder**. Two builder seats: **implementer** (code
from a brief) and **spec-drafter** (a first-draft spec the main model revises). They share
mechanics; they differ in model tier, brief genre, and which gate the output faces.

## Seat selection — where the judgment lives decides the tier

The project binding names two counterparty tiers: an **implementer tier** (fast, mechanically
faithful — but it UNDER-BUILDS when the contract doesn't carry the judgment for it) and a
**reasoning tier** (the counterparty's strongest head — the tier the audit and advisor seats use).

| Work | Seat | Why |
|---|---|---|
| Implementation from a LOCKED spec (normal stakes) | implementer tier | The spec carries the judgment; the seat needs fidelity, not invention. |
| Implementation from a LOCKED spec, complex (stakes rubric high on any dimension) | reasoning tier | Density the implementer tier under-builds on first contact. |
| Implementation WITHOUT a locked spec | **reasoning tier, ALWAYS** | No spec = the judgment must live in the builder. Operator hard rule — never the implementer tier here. |
| Spec / design-doc first draft | reasoning tier | Drafting IS judgment; the value is a different family's aggressive code-reading. |

When unsure whether an impl is "complex," run the stakes rubric (size / novelty / design-choice /
complexity / knowledge-gaps / blast-radius / security, max-of-dimension). One dimension high →
reasoning tier.

## The procedure

1. **Triage the seat** from the table above. Say which lane and why in one line.
2. **Author the brief — invoke `brief-authoring`.** All four obligations apply unchanged (GIVEN
   block with locked-spec refs, grep-verified code references, ambiguity protocol, verifiable
   success criteria). For the spec-drafter seat the "spec refs" are the design inputs: the vision,
   the plan section, the code paths to read end-to-end, and the spec-writing conventions the draft
   must land in.
3. **Dispatch per the project binding.** Write jobs run in a linked worktree; the counterparty's
   sandbox typically cannot write the worktree's git metadata, so **the controller commits on the
   counterparty's behalf** after harvest. Read-only jobs (spec drafts) need no worktree isolation.
4. **Watcher + timer, BOTH, armed in the dispatch turn** — the project's background-dispatch
   watcher discipline applies verbatim (job-loss is terminal → re-dispatch fresh; never end a
   session with a job in flight; probe from the dispatching worktree).
5. **Harvest against the contract.**
   - *Implementer seat returns*: the diff, a statement of what was built vs. the brief, surfaced
     ambiguities (the brief's protocol), and its own verification evidence. Controller re-runs the
     verification first-hand — the counterparty's green is a claim, not a result.
   - *Spec-drafter seat returns*: the draft doc + an explicit list of the code paths it actually
     read and the open questions it could not settle. A draft with no open-questions list didn't
     look hard enough — probe it.
6. **Route to the mandatory downstream gate.**
   - *Implementation* → `spec-adherence` (when a spec governs) → `audit-cycle` per the project's
     one-gate rule. **The builder's family never carries its own review**: when the counterparty
     built the artifact, the same-counterparty audit lens loses independence — the OTHER family's
     reviewer seat carries the round. Note this in the audit dispatch.
   - *Spec draft* → the main model's **revision pass, in-file** (the main model owns coherence with
     the project's architecture and prior specs; the draft is raw material) → then the normal
     `spec-writing` flow (constitution gate, lock ladder). A drafted spec LOCKS on the same
     evidence bar as any other.
7. **Refusal fallbacks are LANE-SPECIFIC** (the binding pins them): a refused *build* falls back
   in-family (the main model's own implementer tier — the build lens doesn't need to be
   cross-model); a refused *spec draft* falls back to the counterparty's alternate model first (the
   cross-family read IS the value), then in-family with the degradation recorded.

## Boundaries

- **Not `audit-cycle`** — no severity vocabulary here; a build seat never judges.
- **Not `cross-model-advisor`** — the advisor reasons and returns positions; this seat produces
  artifacts. "Think about the design with me" → advisor. "Build/draft it" → this.
- **Not the rescue lane** — rescue is diagnostic takeover when the main session is stuck; this is
  planned delegation of fresh work.
- **Never a gate substitute** — who built it changes nothing about what reviews it.

## Anti-patterns

1. **Implementer-tier un-specced work** — the table's ALWAYS row exists because the operator ruled
   it; "it's a small change" is not an exception.
2. **Brief-free dispatch** — pasting a chat paragraph instead of a `brief-authoring` brief.
3. **Trusting the builder's own green** — harvest verification is first-hand or it didn't happen.
4. **Same-family self-review** — the counterparty builds AND its own audit lens carries the round
   alone. Re-balance the seats.
5. **Spec draft shipped un-revised** — draft + revise, never draft + rubber-stamp.
