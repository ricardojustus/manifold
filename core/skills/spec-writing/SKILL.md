---
name: spec-writing
description: >-
  Author any spec / implementation-contract / design-doc / LOCKED-spec amendment with a proportionality-gated discipline that prevents the wrong-target failure (a rigorous spec aimed at the wrong code path) AND encodes good-spec hygiene (regime split, bounded clarification, complexity justification, "unit tests for English", an attestable constitution-gate). INVOKE THE MOMENT you start writing spec content — before drafting. Trigger phrases: "write/author the spec", "redo the spec", "amendment spec", "design doc", "implementation contract", "spec this out". Trigger PROACTIVELY before committing spec content, ESPECIALLY when the change wires into a multi-module data flow, amends a LOCKED spec, or is hard to reverse — exactly when "am I changing the RIGHT component?" is answer-changing. Calibrated NOT to overcorrect: contained / single-module / reversible specs stay lightweight (heavy trace + owner-halt gates skipped). NOT for dispatch briefs (`brief-authoring`), design-intent plans (`plan-update`), current-state docs (`reference-doc-writing`), file placement (`doc-placement`), or the reviewer gate that runs after (`audit-cycle`).
---

# Spec-Writing

Authoring a spec is two jobs braided together: aim it at the **right target**, and make it a **good spec**. The rest of the pipeline covers neither directly — `brief-authoring` grep-verifies that references *exist*, and `audit-cycle` checks the spec is internally consistent and matches reality, but **both take the spec's scope as given.** This skill owns the part nothing else does: deciding *where* a change wires in, and *how well* the spec is written — without turning every spec into a ceremony.

## The failure this prevents

A cross-partition entity-resolution spec was authored, driven through a clean multi-round 0-findings audit to LOCK — then found to target the **wrong module**. It wired the change into a legacy path that was *being retired*, while the live forward path held the actual flaw. Every code reference was grep-verified and existed; confidence was claimed at 100%. Hundreds of thousands of tokens, wrong target. **Second occurrence of the class.**

The lesson: grep-verify proves a reference *exists*; the audit proves the artifacts *agree with each other and reality*. Neither asks **"is this the right component, given how data actually flows through the system?"** That question is this skill's Step 1–2. Scope-correctness is the gap even the mature public spec tools don't close — it's genuinely net-new.

**Third occurrence — the surface-trace variant.** A spec author presented the owner an architecture fork — *couple vs decouple* two write paths — built on reading a **comment header + function signatures** of the target module. The owner: *"I don't trust your surface traces anymore."* Reading the **actual LOCKED specs** end-to-end **reversed the recommendation**: the codebase *couples* the writes deliberately (to preserve a LOCK invariant — you cannot wrap the inner atomic transaction), so the proposed "decouple" cut against the proven, audited architecture. **A function signature, a `grep` hit, and a doc-comment header are NOT grounding** — they tell you a thing *exists*, never *why it is built that way* or *how data actually flows*. Ground in the **actual specs (the LOCKED ones AND the stale/archived ones — they carry the architecture's reasoning)**, the project's **documentation-retrieval system**, and the real code paths read **end-to-end** — and **do not write the spec until the system is understood FULLY** (to where you can explain the design's rationale + its rejected alternatives from the sources, not from inference).

## Step 0 — Classify the regime FIRST

Before anything else, decide how much rigor this spec earns. This is the whole anti-overcorrection mechanism: the heavy gates exist to catch the wrong-target failure, but firing them on a 20-line single-module change just burns your time and the owner's. Size the process to the blast radius, not to fear of repeating one bad day.

**HEAVY regime** — run every step — if EITHER is true:
- The change wires into a data flow that crosses **≥2 modules / subsystems** (so "which path does this actually run through?" is a live, answer-changing question), OR
- It's a **one-way door**: hard or expensive to reverse once shipped — schema migration, data backfill, a LOCKED-spec amendment, an irreversible data transform.

**LIGHT regime** — otherwise: single-module, contained, two-way-door (cheaply reversible). Skip Steps 1–2 (the trace + the owner-halt); go straight to Steps 3–5.

Emit the verdict as the first line of the spec, e.g. `Regime: LIGHT — single-module, reversible` or `Regime: HEAVY — wires source→transform→store; amends 2 LOCKED specs`. It tells every later reader (and you) which gates were owed.

| | Step 1 trace | Step 2 owner-halt | Step 3 hygiene | Step 4 skeleton | Step 5 self-review |
|---|---|---|---|---|---|
| **LIGHT** | skip | skip | yes | yes | yes |
| **HEAVY** | yes | yes | yes | yes | yes |

The door×span test is borrowed from the real world: the mature spec tools ship both a full phase-gated workflow *and* a lean preset; the lighter "fluid not rigid" alternatives exist specifically for the contained case. The heavy↔light split is load-bearing in the actual ecosystem, not a hedge.

## Step 1 (HEAVY) — Trace the data flow through the TARGET architecture

Before deciding where to wire the change, name **every module a unit of data passes through, in the system as it WILL be** — not just as it is today, and not just the one subsystem you assume you're touching. The wrong-target failure happened because the target was a path being retired; only an end-to-end trace surfaces that.

> **Surface traces are NOT grounding (HARD).** A function signature, a `grep` hit, or a doc-comment header tells you a thing *exists* — never *why it is built that way* or *how data actually flows*. **Read the actual specs to ground on the architecture's REASONING** — the LOCKED specs that govern the surface you're touching AND their **stale/archived** predecessors (a superseded spec still records *why* the design is shaped as it is). Read the project's **documentation-retrieval system** and the real code paths **end-to-end**. **Do not write the spec until the system is understood FULLY** — the bar is: you can explain the design's rationale and its rejected alternatives *from the sources*, not from inference.

- Read the **adjacent** modules' reference docs, not only the subsystem's own. Consult the project's current-state reference corpus + documentation-retrieval system. **Then read the governing specs** (the LOCKED spec store + its archive) for the surface — the reasoning lives there, not in the code comments. Plan docs tell you intent; reference docs tell you what's live *right now*; specs tell you *why it's built this way*.
- Produce a **literal trace**: `Source → moduleA → moduleB → … → store`, and mark the insertion point.
- Then the one hard check that would have caught last time: **"Is my insertion point on the live forward path, or on a path being deprecated / replaced / retired?"** If you can't answer from the docs, that's a Step-2 question for the owner.

## Step 2 (HEAVY) — Validate scope, then ask the owner the architecture questions

Run a **two-axis confidence check** — the failure was claiming 100% on the wrong axis:
- **Axis 1 — task understanding**: do I understand what I've been asked to spec?
- **Axis 2 — scope correctness**: have I validated that this is the *right target*, against the real end-to-end flow? **Axis 2 must cite the Step-1 trace.** 100% on Axis 1 with an unexamined Axis 2 is exactly the trap.

Pre-mortem to stress it: *"Assume this spec wired the change into the wrong module. What would have to be true for that — and have I ruled it out?"*

Then surface the **architecture-validation questions** to the owner **before drafting spec content** — the "which path does X actually flow through / is module A the live path or the retiring one?" class. Keep this bounded (the anti-overcorrection guard): ask the **≤3–5 highest (impact × uncertainty)** questions only; make informed defaults for the rest and record them in the spec's Assumptions. **HALT for the owner on these before writing the spec body** — validating scope before committing is the entire point; building first and validating later is the failure we're guarding against.

## Step 3 — Good-spec hygiene (every spec, both regimes) — attested as named gates IN the spec

Cheap, always-on quality. None of this is ceremony — each item kills a specific class of bad spec. **The r2 upgrade: these are not just done, they are *attested*.** The spec artifact carries a **gate-attestation block** (see the skeleton) where each named gate is checked off by the author, and a **Complexity-Tracking table** records any gate that could not be cleanly met. Making the checks visible in the artifact is what lets a reviewer confirm they actually ran — an unchecked gate is a finding, not a silent omission.

The named gates:

- **Constitution gate.** Validate the spec against the non-negotiables: the project constitution's HARD RULES, the state-snapshot's "do-not-regress" framings, and any LOCKED invariants the spec touches. A conflict is CRITICAL — change the *spec*, not the principle (changing a locked principle is a separate, explicit decision with the owner). Attest: `Constitution gate: PASS` (or name the conflict).
- **Clarification-cap gate.** Mark genuine unknowns inline with `[NEEDS CLARIFICATION: …]` or `DECISION-PENDING-<owner>`, but cap it: **≤3 markers**, ordered by impact (scope > security/privacy > behavior > technical detail). For everything else, make an informed default and **document it in Assumptions** — a surfaced default beats a silent one and beats a question the owner doesn't need. Attest the count.
- **Coverage gate.** Walk the completeness taxonomy in `references/coverage-and-self-review.md` and mark each area Clear / Partial / Missing. It's how you notice the dimension you forgot (failure modes, observability, security posture) before a reviewer does.
- **Complexity gate.** If the spec deviates from the simplest thing that works, add a **Complexity-Tracking row**: *what you added | why it's needed | which simpler alternative you rejected and why.* A row that can't be justified is a signal to simplify, not to waive. This is the "simplicity first" check forced into writing — and it generalizes the audit's Low-triage waiver discipline to authoring time (a deviation is waived *with a recorded reason and trigger*, not silently kept).
- **Success-criteria gate.** Every spec states how you'll know it's satisfied, in objectively checkable terms (this is what the audit gate then verifies). "Works correctly" is not a success criterion.

## Step 4 — Write the spec on the skeleton

Use the recommended section-set in `references/spec-skeleton.md`. It's a menu, not a mandate — take what the spec needs. Three pieces always earn their place:

- **Gate-attestation block + Complexity-Tracking table** (Step 3) — the named gates, checked, with a row per complexity deviation.
- **Goals / Non-Goals.** Non-Goals is where "module A is out of scope, because it's being retired" gets *forced into writing* — it doubles as a scope-correctness backstop. Cheap, high-leverage.
- **Decisions (with rationale + rejected alternatives).** Capture *why* each non-obvious choice was made so audits and future readers don't relitigate it.
- **Implementation dispatch (fill at LOCK).** The skeleton's dispatch-triage section: implementer tier + reasoning-effort + lane shape + cross-model role, with a one-line rationale. You — the author who just spent the most time inside this work's complexity — make the recommendation; the dispatcher honors it or overrides it *with a stated reason*. Locked-spec implementations default to **medium–high effort**, not the top (the model-economy principle carries the receipt, including the top-setting "no-op rationalization" failure mode); raise only for genuine coupling/novelty. This converts the effort/tier dial from an inherited default into a decision made where the knowledge is.

**Amendments to LOCKED specs** (a HEAVY case by definition) get the brownfield treatment: spec the **delta** against the locked source-of-truth (what changes / what's preserved), and add a **"Coordination with sibling specs"** section naming every other spec the change touches and how they stay consistent. Honor the HARD RULE: **no audit-trail / fix-pass log / round-N findings in the spec body** — those live in `<artifact-root>/audits/<topic>/`; a top-of-doc CHANGELOG line points at the artifact.

## Step 5 — Self-review: "unit tests for English"

Before declaring the spec ready for `audit-cycle`, run one author-side pass that tests the **requirements themselves** — not the implementation. "Is 'fast' quantified?" "Are the failure modes defined?" "Do these two requirements conflict?" This is earlier, cheaper, and author-run, where `audit-cycle` is later, adversarial, and reviewer-run. The dimensions + flags (vague adjectives, unresolved placeholders) are in `references/coverage-and-self-review.md`.

## Pre-flight checklist (before handing the spec to audit-cycle)

- Regime declared on line 1?
- (If the runtime has an advisor) one advisor consult on the finished draft — fresh eyes on
  wrong-target framing before audit rounds are paid for?
- **System understood FULLY from the actual specs (LOCKED + stale/archived) + the documentation-retrieval system + end-to-end code — not surface traces? Can you explain the design's reasoning + rejected alternatives from the sources?**
- (HEAVY) Step-1 trace done, insertion point on the **live** path confirmed?
- (HEAVY) Axis-2 scope validated with the owner before the body was written?
- Gate-attestation block filled: Constitution PASS, Clarification ≤3, Coverage walked, Complexity rows justified, Success criteria measurable?
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
- **spec-adherence** — the impl-side conformance gate that verifies the *code* obeys this spec, after it's implemented and before audit-cycle. Step-5 self-review here is the author-side analogue; spec-adherence is its impl-side complement.

## Why it's built this way (provenance)

The scope-correctness gate (Steps 1–2) is net-new — confirmed absent from the public spec tools' ambiguity-clarification and cross-artifact-consistency passes (the latter ≈ our audit-cycle). The hygiene + skeleton (Steps 3–5) are liberally plundered and adapted to an audit-then-dispatch pipeline (we do **not** generate code from specs the way the code-gen tools do): the regime split + bounded-clarification + complexity-justification + "unit tests for English" + constitution gate from the phase-gated tools; Goals/Non-Goals/Decisions + brownfield delta + sibling-coordination from the specs-as-source-of-truth tools + classic design-doc practice.
