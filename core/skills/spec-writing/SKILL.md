---
name: spec-writing
description: >-
  Authors specs, implementation contracts, and LOCKED-spec amendments under a proportionality-gated discipline (HEAVY/LIGHT regime, data-flow trace, owner-halt). Invoke before drafting: "write the spec", "amendment spec", "design doc", "spec this out". Not plans (plan-update) or current-state docs (reference-doc-writing).
---

# Spec-Writing

Authoring a spec is two jobs braided: aim it at the **right target**, and make it a **good spec**. Nothing else in the pipeline covers either — `brief-authoring` grep-verifies that references *exist*, `audit-cycle` checks internal consistency against reality, but **both take the spec's scope as given.**

## Step 0 — Frame-reset, THEN classify the regime

**Frame-reset first (four sentences, always).** Restate the change stripped of its solution nouns and risk labels: the plain operator outcome · the cheapest recovery if it fails (in operator labor + downtime) · the simplest direct implementation · and the operator posture-receipt that authorizes anything heavier — or `N/A — no heavier posture proposed` for a simple direct change. If a heavier frame (a migration ceremony, phase machine, soak, rollback rehearsal, an assurance program) has no posture receipt, or its recovery story contradicts the plan's risk label, it is not yet authorized — halt to the operator before drafting the body (`operator-owns-criticality-and-complexity`). Only then:

Decide how much rigor this spec earns — this is the anti-overcorrection mechanism: the heavy gates catch the wrong-target failure, but firing them on a 20-line single-module change burns your time and the owner's.

**HEAVY regime** — run every step — if EITHER is true:
- The change wires into a data flow crossing **≥2 modules / subsystems** (so "which path does this actually run through?" is a live, answer-changing question), OR
- It's a **one-way door**: hard or expensive to reverse once shipped — schema migration, data backfill, a LOCKED-spec amendment, an irreversible data transform.

**LIGHT regime** — otherwise: single-module, contained, two-way-door (cheaply reversible). Skip Steps 1–2 (the trace + the owner-halt); go straight to Steps 3–5.

Emit the verdict as the first line of the spec, e.g. `Regime: LIGHT — single-module, reversible` or `Regime: HEAVY — wires source→transform→store; amends 2 LOCKED specs`. It tells every later reader (and you) which gates were owed.

| | Step 1 trace | Step 2 owner-halt | Step 3 hygiene | Step 4 skeleton | Step 5 self-review |
|---|---|---|---|---|---|
| **LIGHT** | skip | skip | yes | yes | yes |
| **HEAVY** | yes | yes | yes | yes | yes |

## Step 1 (HEAVY) — Trace the data flow through the TARGET architecture

Name **every module a unit of data passes through, in the system as it WILL be** — not just as it is today, and not just the one subsystem you assume you're touching.

> **Surface traces are NOT grounding (HARD).** A function signature, a `grep` hit, or a doc-comment header tells you a thing *exists* — never *why it is built that way* or *how data actually flows*. **Read the actual specs to ground on the architecture's REASONING** — the LOCKED specs that govern the surface you're touching AND their **stale/archived** predecessors (a superseded spec still records *why* the design is shaped as it is). Read the project's **documentation-retrieval system** and the real code paths **end-to-end**. **Do not write the spec until the system is understood FULLY** — the bar is: you can explain the design's rationale and its rejected alternatives *from the sources*, not from inference.

- Read the **adjacent** modules' reference docs, not only the subsystem's own. Consult the project's current-state reference corpus + documentation-retrieval system. **Then read the governing specs** (the LOCKED spec store + its archive) for the surface — the reasoning lives there, not in code comments. Plan docs tell you intent; reference docs tell you what's live *right now*; specs tell you *why it's built this way*.
- Produce a **literal trace**: `Source → moduleA → moduleB → … → store`, and mark the insertion point.
- Then the one hard check: **"Is my insertion point on the live forward path, or on a path being deprecated / replaced / retired?"** If you can't answer from the docs, that's a Step-2 question for the owner.

## Step 2 (HEAVY) — Validate scope, then ask the owner the architecture questions

Run a **two-axis confidence check**:
- **Axis 1 — task understanding**: do I understand what I've been asked to spec?
- **Axis 2 — scope correctness**: have I validated that this is the *right target*, against the real end-to-end flow? **Axis 2 must cite the Step-1 trace.** 100% on Axis 1 with an unexamined Axis 2 is the trap.

Pre-mortem to stress it: *"Assume this spec wired the change into the wrong module. What would have to be true for that — and have I ruled it out?"*

Then surface the **architecture-validation questions** to the owner **before drafting spec content** — the "which path does X actually flow through / is module A the live path or the retiring one?" class. Keep this bounded (the anti-overcorrection guard): ask the **≤3–5 highest (impact × uncertainty)** questions only; make informed defaults for the rest and record them in the spec's Assumptions. **HALT for the owner on these before writing the spec body.**

## Step 3 — Good-spec hygiene (every spec, both regimes) — attested as named gates IN the spec

Each gate kills a specific class of bad spec, and each is **attested**, not merely done: the spec artifact carries a **gate-attestation block** (see the skeleton) where each named gate is checked off, plus a **Complexity-Tracking table** recording any gate not cleanly met — an unchecked gate is a finding, not a silent omission.

The named gates:

- **Constitution gate.** Validate the spec against the non-negotiables: the project constitution's HARD RULES, the state-snapshot's "do-not-regress" framings, and any LOCKED invariants the spec touches. A conflict is CRITICAL — change the *spec*, not the principle (changing a locked principle is a separate, explicit decision with the owner). Attest: `Constitution gate: PASS` (or name the conflict).
- **Clarification-cap gate.** Mark genuine unknowns inline with `[NEEDS CLARIFICATION: …]` or `DECISION-PENDING-<owner>`, capped at **≤3 markers**, ordered by impact (scope > security/privacy > behavior > technical detail). For everything else make an informed default and **document it in Assumptions** — a surfaced default beats a silent one and beats a question the owner doesn't need. Attest the count.
- **Coverage gate.** Walk the completeness taxonomy in `references/coverage-and-self-review.md` and mark each area Clear / Partial / Missing. It's how you notice the dimension you forgot (failure modes, observability, security posture) before a reviewer does.
- **Complexity gate.** If the spec deviates from the simplest thing that works, add a **Complexity-Tracking row**: *what you added | why it's needed | which simpler alternative you rejected and why.* A row that can't be justified is a signal to simplify, not to waive.
- **Success-criteria gate.** Every spec states how you'll know it's satisfied, in objectively checkable terms (this is what the audit gate then verifies). "Works correctly" is not a success criterion.
- **Visual-surface gate (only when the spec governs a UI / rendered / experiential surface — else `N/A`).** Do NOT lock a spec that pins a *visual* decision (a layout, a component split, a screen) unless the actual surface has been **seen rendered** — opened, smoke-driven, looked at. Attest: `Visual-surface gate: N/A` or `PASS — surface observed at <where>`.
- **Resource-envelope gate (when the spec's implementation or runtime consumes model calls / quota / metered spend — else `N/A` with one line of justification).** An unpriced spec **cannot lock.** Attest the envelope: **(1) the cost tier** (the overlay binds tier boundaries to observed account physics — order-of-magnitude buckets, never precision arithmetic against unpublished limits); **(2) for Heavy-tier+, the one-line multiplication** (`items × calls-per-item × token weight × recurrence`), with guessed numbers *named as guesses*; **(3) dollars, mandatorily, wherever metered API is involved** (expected + worst case); **(4) for Heavy-tier+ runs, the closed loop**: the hard call/token caps the runner enforces, the bounded canary that runs first, and the halt-and-reopen rule when observed usage exceeds the envelope — *an approved estimate is not an operational control*. A genuinely unknown capacity is recorded `UNKNOWN → capped measurement spike`, never a fabricated number. **Every pinned constant** (sample size, threshold, density, seat count) carries its cost implication inline where it is pinned. Attest: `Resource-envelope gate: N/A — <why>` or `PASS — tier <T>, table in §<n>`.

## Step 4 — Write the spec on the skeleton

Use the recommended section-set in `references/spec-skeleton.md`. It's a menu, not a mandate — take what the spec needs. Four pieces always earn their place:

- **Gate-attestation block + Complexity-Tracking table** (Step 3) — the named gates, checked, with a row per complexity deviation.
- **Goals / Non-Goals.** Non-Goals is where "module A is out of scope, because it's being retired" gets *forced into writing* — it doubles as a scope-correctness backstop.
- **Decisions (with rationale + rejected alternatives).** Capture *why* each non-obvious choice was made so audits and future readers don't relitigate it.
- **Implementation dispatch (fill at LOCK).** The skeleton's dispatch-triage section: implementer tier + reasoning-effort + lane shape + cross-model role, with a one-line rationale. You — the author who just spent the most time inside this work's complexity — make the recommendation; the dispatcher honors it or overrides it *with a stated reason*. Locked-spec implementations default to **medium–high effort**, not the top (the model-economy principle carries the receipt); raise only for genuine coupling/novelty.

**Amendments to LOCKED specs** (HEAVY by definition) get the brownfield treatment: spec the **delta** against the locked source-of-truth (what changes / what's preserved), and add a **"Coordination with sibling specs"** section naming every other spec the change touches and how they stay consistent. Honor the HARD RULE: **no audit-trail / fix-pass log / round-N findings in the spec body** — those live in `<artifact-root>/audits/<topic>/`; a top-of-doc CHANGELOG line points at the artifact.

## Step 5 — Self-review: "unit tests for English"

Before declaring the spec ready for `audit-cycle`, run one author-side pass that tests the **requirements themselves** — not the implementation. "Is 'fast' quantified?" "Are the failure modes defined?" "Do these two requirements conflict?" Earlier, cheaper, and author-run, where `audit-cycle` is later, adversarial, and reviewer-run. The dimensions + flags (vague adjectives, unresolved placeholders) are in `references/coverage-and-self-review.md`.

## Pre-flight checklist (before handing the spec to audit-cycle)

- Regime declared on line 1?
- (If the runtime has an advisor) one advisor consult on the finished draft — fresh eyes on wrong-target framing before audit rounds are paid for?
- **System understood FULLY from the actual specs (LOCKED + stale/archived) + the documentation-retrieval system + end-to-end code — not surface traces? Can you explain the design's reasoning + rejected alternatives from the sources?**
- (HEAVY) Step-1 trace done, insertion point on the **live** path confirmed?
- (HEAVY) Axis-2 scope validated with the owner before the body was written?
- Gate-attestation block filled: Constitution PASS, Clarification ≤3, Coverage walked, Complexity rows justified, Success criteria measurable, Visual-surface seen-or-N/A, **Resource envelope priced-or-N/A (unpriced = cannot lock; Heavy+ carries caps + canary + halt rule)**?
- **Prior-rulings recall gate**: for every pinned constant and every process gate (waits, windows, thresholds, retry/promotion policies), ONE query against the project's recall system (where the overlay names one) for prior operator rulings on that mechanism class — operator doctrine is often thread-local; the recall system sees across threads. A ruling found = inherit it or surface the conflict; never silently re-derive convention.
- Goals **and** Non-Goals explicit?
- (Amendment) delta-scoped + sibling-coordination section present + no audit-trail in body?
- Concrete code references grep-verified (per `brief-authoring`) — existence is necessary even though it isn't sufficient?
- Implementation-dispatch triage filled (tier + effort + lane shape + cross-model role + rationale)? (At dispatch, Agent-tool implementations use the `implementer` role with the tier passed as the per-invocation `model` param.)
- Step-5 self-review clean?

## When to invoke / when to skip

**Always invoke and classify** when authoring or redoing a spec / implementation-contract / design-doc / amendment — even a small one; classification is one line and tells you whether you owe the heavy steps. **Skip entirely** only for pure-clerical spec edits (typo, link fix, renumbering) with no scope or requirement change.

## Not this skill (siblings)

- **brief-authoring** — briefs for dispatched agents (teammates/subagents/lanes). Grep-verify lives there; this skill assumes it.
- **plan-update** — design-*intent* plan docs. A spec is a contract for a specific change; a plan is direction.
- **reference-doc-writing** — current-*state* docs. After a spec ships, its durable behavior is promoted there (close-out).
- **doc-placement** — *where* the spec file belongs in the corpus.
- **audit-cycle** — the reviewer gate that runs *after* the spec is written. This skill gets the spec to the point it's worth auditing.
- **spec-adherence** — the impl-side conformance gate that verifies the *code* obeys this spec, after implementation and before audit-cycle. Step-5 self-review here is the author-side analogue.
