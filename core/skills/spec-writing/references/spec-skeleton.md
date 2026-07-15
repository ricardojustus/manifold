# Spec skeleton — recommended section-set

A menu, not a mandate. Take the sections the spec actually needs; a contained LIGHT spec might use five of these, a HEAVY cross-subsystem amendment most of them. In an implementation-contract project, specs deliberately blend *what/why* with *how* — file paths, signatures, invariants — unlike the hard split some tools draw between a tech-free spec and a plan. State which genre you're writing and let that set the depth.

Provenance: plundered from the public spec/plan templates, the specs-as-source-of-truth `design.md` shape (Context / Goals / Non-Goals / Decisions), and classic design-doc practice (Non-Goals, Alternatives Considered).

## Top matter

- **`Regime:` line** (first line) — `LIGHT — …` or `HEAVY — …` with the one-clause reason. From Step 0.
- **Genre** — one of: `behavior-spec` (what the system does, light on how) · `implementation-contract` (the common case — paths, signatures, invariants) · `amendment` (a delta to a LOCKED spec).
- **Status / CHANGELOG** — `Draft` / `LOCKED <date> R<n>`. If amended post-LOCK, a one-line CHANGELOG entry pointing at the audit artifact in `<artifact-root>/audits/<topic>/` — **never** an inline audit trail (HARD RULE).

## Gate-attestation block (Step 3 — every spec)

Right under the top matter, an attestation the author fills and a reviewer can confirm ran:

```
## Gates
- Constitution gate: PASS  (or: CONFLICT — <which HARD RULE / framing / LOCKED invariant> → resolved by <change>)
- Clarification-cap gate: <N> markers (≤3), ordered scope > security > behavior > detail
- Coverage gate: walked (taxonomy in coverage-and-self-review.md); gaps filled in <sections>
- Complexity gate: <no deviations> | see Complexity-Tracking table
- Success-criteria gate: PASS (criteria objectively checkable)
- Visual-surface gate: N/A | PASS — surface observed at <where>
- Resource-envelope gate: N/A — <why> | PASS — tier <T>, multiplication + caps/canary in §<n>, $ math if metered API

### Complexity-Tracking   (one row per deviation from the simplest thing that works; empty is good)
| What was added | Why it's needed | Simpler alternative rejected — and why |
|---|---|---|
```

An unchecked gate or an unjustifiable Complexity row is a finding, not a silent omission — this block is what generalizes the audit's Low-triage waiver discipline to authoring time.

## Core sections

### Context / Summary
The primary requirement in one or two sentences, plus the technical approach in one line. Enough that a reader knows what this is and why, before the detail.

### Goals / Non-Goals
- **Goals** — what this change must achieve, as a short list.
- **Non-Goals** — what is explicitly *out of scope*, and why. This is the highest-leverage cheap section: it's where "module A is not touched because it's being retired" gets *written down*, which is exactly the scope-correctness backstop the wrong-target failure lacked. A Non-Goal with a reason is worth three paragraphs of prose.

### Scenarios (for behavior-specs / behavioral surfaces)
Concrete acceptance scenarios in **Given / When / Then** form. Prioritize them (P1/P2/P3) and make each **independently verifiable** — a slice you could implement and audit on its own. This maps directly onto a per-layer audit cadence and parallel-lane decomposition (below).

### Requirements / Technical Context
- **Behavior-spec**: numbered functional requirements (`FR-001 …`), each testable.
- **Implementation-contract** (the common case): the concrete surface — file paths, function/type signatures, schema columns, invariants, the exact insertion point from the Step-1 trace. Be specific; this is the contract the implementer and the auditor both hold you to.

### Key Entities / Data Model
Entities, attributes, identity/uniqueness rules, lifecycle/state transitions, schema fields. Include when the change touches data shape.

### Decisions (with rationale + rejected alternatives)
Enumerate each non-obvious choice: **what was decided · why · which simpler/alternative approach was rejected and why.** This is the `design.md` "Decisions" pattern. It's what stops a future reader (or a round-3 auditor) re-opening a settled question — and it's where the "justify complexity" hygiene item from Step 3 lands.

### Success Criteria
How you'll know the spec is satisfied, in **measurable / objectively checkable** terms (`SC-001 …`). This is what the `audit-cycle` gate then verifies against. Avoid unfalsifiable criteria ("robust", "clean").

### Assumptions
The informed defaults you chose where the input was silent (Step 3 clarification-cap overflow lands here). Surfacing "I assumed X" is anti-confabulation: it lets the owner or a reviewer catch a wrong default instead of it hiding inside the design.

### Edge Cases & Failure Handling
Negative paths, boundary conditions, concurrency/race behavior, partial-failure and recovery. The coverage scan (`coverage-and-self-review.md`) will prompt the ones you'd otherwise miss.

### Slice / layer decomposition
For anything non-trivial, decompose into a **foundational/blocking layer** (must land before any slice) followed by **independently-auditable slices**, marking those that can run in parallel `[P]` (different files, no inter-dependency). This is the tasks-by-user-story + `[P]` pattern, and it's already how the pipeline dispatches (per-layer locks, parallel lanes). Writing the decomposition into the spec makes the dispatch plan fall out for free.

## Amendment variant (delta to a LOCKED spec)

A LOCKED-spec amendment is HEAVY by definition. Don't restate the whole spec — spec the **delta**, brownfield-style (specs-as-source-of-truth vs changes-as-deltas):

- **What changes** — the specific sections/clauses being amended, quoted by `§` reference, with old → new.
- **What's preserved** — the locked invariants the amendment explicitly does *not* touch (reassures the auditor and prevents accidental scope creep).
- **Coordination with sibling specs** — every *other* spec this change touches, named, with how they stay mutually consistent. (Worked example: a cross-partition redo amends two sibling specs at named sections — those are its siblings, and this section is where their joint consistency is argued.)
- **CHANGELOG line** at top pointing to the audit artifact — never an inline audit log.

## Minimal LIGHT template

For a contained, single-module, reversible spec, this is often enough:

```
Regime: LIGHT — single-module, reversible
Genre: implementation-contract

## Gates
- Constitution: PASS · Clarification: 0 · Coverage: walked · Complexity: none · Success: PASS

## Context
<what + why, 1–2 sentences>

## Goals / Non-Goals
- Goal: …
- Non-Goal: … (because …)

## Technical Context
<paths, signatures, invariants, insertion point>

## Decisions
- <choice> — because <reason>; rejected <alternative> because <reason>

## Success Criteria
- SC-001: <objectively checkable>

## Assumptions
- <informed default chosen where input was silent>

## Edge Cases
- <boundary / failure path>
```
