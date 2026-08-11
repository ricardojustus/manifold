---
name: spec-writing
description: >-
  Authors specs, implementation contracts, and LOCKED-spec amendments under a proportionality-gated discipline (HEAVY/LIGHT regime, data-flow trace, owner-halt). Invoke before drafting: "write the spec", "amendment spec", "design doc", "spec this out". Not plans (plan-update) or current-state docs (reference-doc-writing).
---

# Spec-Writing

Authoring a spec is two jobs braided: aim it at the **right target**, and make it a **good spec**. Nothing else in the pipeline covers either.

## Step 0 — Frame-reset, THEN classify the regime

> Project bindings may prepend or amend steps — read the "## Project bindings" section (end of file) before the first step.

**Frame-reset first (four sentences, always).** Restate the change stripped of its solution nouns and risk labels: the plain operator outcome · the cheapest recovery if it fails (in operator labor + downtime) · the simplest direct implementation · and the operator posture-receipt that authorizes anything heavier — or `N/A — no heavier posture proposed` for a simple direct change. If a heavier frame (a migration ceremony, phase machine, soak, rollback rehearsal, an assurance program) has no posture receipt, or its recovery story contradicts the plan's risk label, it is not yet authorized — halt to the operator before drafting the body (`operator-owns-criticality-and-complexity`). Only then:

Decide how much rigor this spec earns — the anti-overcorrection mechanism: heavy gates fired on a 20-line single-module change burn your time and the owner's.

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
>
> **A third-party service gets a half-day REAL-CONTENT spike before any spec locks around it** —
> verdict shape + fitness/false-positive rate on real inputs, never the vendor's docs alone (a
> locked-and-built integration was torn out when first real content refuted the documented behavior).
> **A multi-surface protocol is designed by walking its lifecycle END-TO-END before writing** —
> every creation path × file→surface→act→clear→complete. Reviewers verify a design; audit rounds
> are the expensive way to finish one.

- Read the **adjacent** modules' reference docs, not only the subsystem's own. Consult the project's current-state reference corpus + documentation-retrieval system. **Then read the governing specs** (the LOCKED spec store + its archive) for the surface — the reasoning lives there, not in code comments. Plan docs tell you intent; reference docs tell you what's live *right now*; specs tell you *why it's built this way*.
- Produce a **literal trace**: `Source → moduleA → moduleB → … → store`, and mark the insertion point.
- Then the one hard check: **"Is my insertion point on the live forward path, or on a path being deprecated / replaced / retired?"** If you can't answer from the docs, that's a Step-2 question for the owner.

## Step 2 (HEAVY) — Validate scope, then ask the owner the architecture questions

Run a **two-axis confidence check**:
- **Axis 1 — task understanding**: do I understand what I've been asked to spec?
- **Axis 2 — scope correctness**: have I validated that this is the *right target*, against the real end-to-end flow? **Axis 2 must cite the Step-1 trace.** 100% on Axis 1 with an unexamined Axis 2 is the trap.

Pre-mortem to stress it: *"Assume this spec wired the change into the wrong module. What would have to be true for that — and have I ruled it out?"*

Then surface the **architecture-validation questions** to the owner **before drafting spec content** — the "which path does X actually flow through / is module A the live path or the retiring one?" class. Keep this bounded (the anti-overcorrection guard): ask the **≤3–5 highest (impact × uncertainty)** questions only; make informed defaults for the rest and record them in the spec's Assumptions. **HALT for the owner on these before writing the spec body.**

**Premises only the owner's world can confirm belong in this same question set, and they score high on impact × uncertainty by construction**: the shape of their workspace, how much of it the deliverable actually reaches, what proportion of the real population a visible sample represents, who else can see the system act. No amount of reading finds these — the fact lives with the owner and nowhere in the code, so deferring one to a later spike measures the wrong thing after the architecture is already committed, and no number of reviewers can catch it. One free question at spec start can kill an architecture on day one, which is the cheapest day to kill it. Where the deliverable makes the agent **visible to other people in the owner's world**, that is a first-line fact wherever the owner is asked to decide — the decision packet where one exists, otherwise the spec's top summary — never a spec-body detail.

**This premise class is regime-independent, so it must reach LIGHT too** (which skips this step): in LIGHT, surface such a premise as one of Step 3's clarification markers, where it outranks the others on that gate's impact ordering, rather than letting it default silently into Assumptions. A contained, cheaply-reversible change can still turn on a population ratio or put the agent in front of other people.

## Step 3 — Good-spec hygiene (every spec, both regimes) — attested as named gates IN the spec

Each gate kills a specific class of bad spec, and each is **attested**, not merely done: the spec artifact carries a **gate-attestation block** (see the skeleton) where each named gate is checked off, plus a **Complexity-Tracking table** recording any gate not cleanly met — an unchecked gate is a finding, not a silent omission.

The named gates:

- **Constitution gate.** Validate the spec against the non-negotiables: the project constitution's HARD RULES, the state-snapshot's "do-not-regress" framings, any LOCKED invariants the spec touches, AND the governing plan/vision's Decisions, Non-Goals, and Security Posture section — a spec clause contradicting its governing plan is CRITICAL (the plan outranks the spec; the audit gate re-checks this at LOCK via the spec-vs-plan gate). A conflict is CRITICAL — change the *spec*, not the principle (changing a locked principle is a separate, explicit decision with the owner). Attest: `Constitution gate: PASS` (or name the conflict).
- **Clarification-cap gate.** Mark genuine unknowns inline with `[NEEDS CLARIFICATION: …]` or `DECISION-PENDING-<owner>`, capped at **≤3 markers**, ordered by impact (scope > security/privacy > behavior > technical detail). For everything else make an informed default and **document it in Assumptions**. Attest the count.
- **Coverage gate.** Walk the completeness taxonomy in `references/coverage-and-self-review.md` and mark each area Clear / Partial / Missing — the dimension you forgot (failure modes, observability, security posture) surfaces here rather than in review.
- **Complexity gate.** If the spec deviates from the simplest thing that works, add a **Complexity-Tracking row**: *what you added | why it's needed | which simpler alternative you rejected and why.* A row that can't be justified is a signal to simplify, not to waive.
- **Success-criteria gate.** Every spec states how you'll know it's satisfied, in objectively checkable terms (this is what the audit gate then verifies). "Works correctly" is not a success criterion.
- **Prior-rulings recall gate.** For every pinned constant and every process gate (waits, windows, thresholds, retry/promotion policies), ONE query against the project's recall system (where the overlay names one) for prior operator rulings on that mechanism class. A ruling found = inherit it or surface the conflict; never silently re-derive convention. Attest: `Prior-rulings recall gate: PASS — <n> queries` (or `N/A — no pinned constants or process gates`).
- **Environments gate.** Enumerate the environments the deliverable's flow serves — build, test, release, runtime, and THE OWNER'S OWN MACHINE where the flow differs. Every default path / env-var / host assumption is a concrete claim about a named environment (verify-or-mark-unverified), and the acceptance criteria include one real run in each. Attest the list.
- **Advisor gate (where the runtime has an advisor — else `N/A`).** One advisor consult on the finished draft, before audit rounds are paid for. Attest: `PASS — consult recorded` or `N/A`.
- **Visual-surface gate (only when the spec governs a UI / rendered / experiential surface — else `N/A`).** Do NOT lock a spec that pins a *visual* decision (a layout, a component split, a screen) unless the actual surface has been **seen rendered** — opened, smoke-driven, looked at. Attest: `Visual-surface gate: N/A` or `PASS — surface observed at <where>`.
- **Resource-envelope gate (when the spec's implementation or runtime consumes model calls / quota / metered spend — else `N/A` with one line of justification).** An unpriced spec **cannot lock.** The project's cost-tier binding owns the procedure (tier boundaries, the Heavy-tier+ multiplication, dollar math wherever metered API is involved, and the closed loop of runner-enforced caps + bounded canary + halt-and-reopen). **Every pinned constant** (sample size, threshold, density, seat count) carries its cost implication inline where it is pinned. Attest: `Resource-envelope gate: N/A — <why>` or `PASS — tier <T>, table in §<n>`.

## Step 4 — Write the spec on the skeleton

Use the recommended section-set in `references/spec-skeleton.md`. It's a menu, not a mandate — take what the spec needs. Five pieces always earn their place:

- **Top summary (REQUIRED, the FIRST section of the doc).** A plain-language, skimmable summary at the top of the same doc, in the operator's terms. **Assume many operators read only this summary** — it must be self-sufficient: every load-bearing architectural choice and decision visible there, surfaced plainly for explicit yes/no, any necessary term paired with a one-line explanation. Renderable diagrams (Mermaid / clean indented lists), never ASCII art. Where the operator audits the SHAPE before it locks (receipt: a 5,300-word vision doc whose inverted architecture shipped because it was too long to audit).
- **Gate-attestation block + Complexity-Tracking table** (Step 3) — the named gates, checked, with a row per complexity deviation.
- **Goals / Non-Goals.** The scope-correctness backstop; the skeleton carries why Non-Goals earns its place.
- **Decisions (with rationale + rejected alternatives).** Capture *why* each non-obvious choice was made so audits and future readers don't relitigate it.
- **Implementation dispatch (fill at LOCK).** The skeleton's dispatch-triage section: implementer tier + reasoning-effort + lane shape + cross-model role, with a one-line rationale. The author makes the recommendation; the dispatcher honors it or overrides it *with a stated reason*. Locked-spec implementations default to **medium–high effort**, not the top (the model-economy principle carries the receipt); raise only for genuine coupling/novelty.

**Amendments to LOCKED specs** (HEAVY by definition) get the brownfield treatment: spec the **delta** against the locked source-of-truth (what changes / what's preserved), and add a **"Coordination with sibling specs"** section naming every other spec the change touches and how they stay consistent. Honor the HARD RULE: **no audit-trail / fix-pass log / round-N findings in the spec body** — those live in `<artifact-root>/audits/<topic>/`; a top-of-doc CHANGELOG line points at the artifact. Note the reverse direction too: when a CHILD spec's audit cycle surfaces a defect in this spec as the PARENT contract, the fold-in happens before that cycle closes (`audit-cycle` close-out duty) — a parent is never left stale beside a corrected child.

## Step 5 — Self-review: "unit tests for English"

Before declaring the spec ready for `audit-cycle`, run one author-side pass that tests the **requirements themselves** — not the implementation. "Is 'fast' quantified?" "Are the failure modes defined?" "Do these two requirements conflict?" The dimensions + flags (vague adjectives, unresolved placeholders) are in `references/coverage-and-self-review.md`.

## Pre-flight checklist (before handing the spec to audit-cycle)

A roll-call, not a re-description — each line names something already done above:

- Regime declared on line 1 (Step 0).
- System grounded from the actual sources, not surface traces (Step 1's hard rule — owed by every spec, both regimes).
- Step 4's five always-earn pieces present: top summary FIRST, gate-attestation block + Complexity-Tracking table, Goals **and** Non-Goals, Decisions with rejected alternatives, implementation-dispatch triage. (At dispatch, Agent-tool implementations use the `implementer` role with the tier passed as the per-invocation `model` param.)
- Every Step-3 gate attested or explicitly `N/A`: Constitution · Clarification-cap · Coverage · Complexity · Success-criteria · Prior-rulings recall · Environments · Advisor · Visual-surface · Resource-envelope (**unpriced = cannot lock**).
- (HEAVY) Step-1 trace done with the insertion point on the **live** path, and Step-2 Axis-2 scope validated with the owner before the body was written.
- (Amendment) delta-scoped + sibling-coordination section present + no audit-trail in body.
- Concrete code references grep-verified (per `brief-authoring`).
- Step-5 self-review clean.

## When to invoke / when to skip

**Always invoke and classify** when authoring or redoing a spec / implementation-contract / design-doc / amendment — even a small one; classification is one line and tells you whether you owe the heavy steps. **Skip entirely** only for pure-clerical spec edits (typo, link fix, renumbering) with no scope or requirement change.

## Not this skill (siblings)

- **brief-authoring** — briefs for dispatched agents (teammates/subagents/lanes). Grep-verify lives there; this skill assumes it.
- **plan-update** — design-*intent* plan docs. A spec is a contract for a specific change; a plan is direction.
- **reference-doc-writing** — current-*state* docs. After a spec ships, its durable behavior is promoted there (close-out).
- **doc-placement** — *where* the spec file belongs in the corpus.
- **audit-cycle** — the reviewer gate that runs *after* the spec is written. This skill gets the spec to the point it's worth auditing.
- **spec-adherence** — the impl-side conformance gate that verifies the *code* obeys this spec, after implementation and before audit-cycle. Step-5 self-review here is the author-side analogue.
