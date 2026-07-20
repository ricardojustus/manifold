---
name: spec-adherence
description: >-
  Verifies exhaustively, clause by clause, that new code implements its LOCKED spec AS WRITTEN — every section, decision, acceptance criterion, invariant and error path scored CONFORMS/DEVIATION/MISSING/EXCESS. Run as Gate 0 before audit-cycle, or on "conformance pass" / "does the impl match the spec".
---

# Spec-adherence — the conformance gate before the audit

`audit-cycle` hunts **defects**; it can pass clean while the code quietly **fails to implement the contract** (a decision never wired, an invariant enforced at one site but not another, a branch silently dropped). This gate closes that axis: walk *every* requirement in the LOCKED spec and confirm the implementation does exactly that — exhaustively, not by spot-check — so the multi-model audit then operates on contract-conformant code.

Two distinctions keep it from blurring into `audit-cycle`:
- **vs the audit's spec-vs-reality check** ("does the *spec* describe reality?"): this asks "does the new *code* obey the spec?" Opposite direction.
- **vs the audit's contract-fidelity rubric item** ("does code realize spec verbatim?"): that is an *adversarial spot-check* inside a bounded category budget; this gate is *exhaustive, enumerated, per-clause coverage* that guarantees every requirement got a verdict. If the downstream audit's fidelity check finds a conformance gap, **this gate's checklist was incomplete** — a lesson, not a duplication.

## Where it sits

```
implement → commit → [SPEC-ADHERENCE GATE: decompose → fan-out verify → completeness critic → fix deviations → re-verify → PASS @ sha]
          → audit-cycle round-1 (primary + cross-model) → … → lock gate → merge
```

**A non-PASS never proceeds to the multi-model audit. The PASS is bound to a commit sha — any new commit invalidates it** (audit-cycle's Gate 0 re-checks `HEAD` == the PASS sha). Applies to **code implementations only** — spec-LOCK cycles skip it (nothing to conform).

## The procedure

### 1 — Decompose the spec into a CLAUSE-level requirement checklist
Read the LOCKED spec **end-to-end** (no surface traces — the full spec, plus the sibling specs it amends). Extract every **independently-falsifiable clause** into a numbered checklist. **Clause granularity, not heading granularity: a checklist line that summarizes a multi-clause section is a coverage defect** — each MUST / MUST NOT / NEVER / ALWAYS, each "every/all" quantifier, each state-transition arrow, each error/crash-recovery branch, each named helper/schema element is its OWN line. (Calibration example: `references/worked-decomposition.md` — one heading-level line hiding five clauses.) Tag each item by type, because the type changes how it's verified:
- **feature** — a single behavior implemented in one place.
- **invariant** — a property that must hold at MANY sites ("before first await", "outside the atomic transaction", "every return path spreads", "fail-closed at every call site"). One item, verified across all sites (step 2).
- **test-obligation** — an acceptance criterion that says "test X" / is itself an acceptance test.
- **preserved-invariant** — for a LOCKED-spec amendment: each sibling-spec contract the amendment claims to keep intact. Derive these from the spec's "Coordination with sibling specs" / delta section; the dangerous hole in an amendment is a sibling invariant it silently broke, not the new clause.

Write the checklist down — it is the gate artifact and the coverage contract. A clause that was never enumerated is a clause that was never checked.

### 2 — Fan out the conformance verification (dynamic Workflow)
Partition the checklist across N verifier agents (see `## Dispatch`). Each agent, per clause: read the spec clause **verbatim** → locate the implementing code first-hand (grep + read the path **end-to-end**, not a signature glance) → render a verdict via structured output:
- **CONFORMS** — implemented exactly as specified. Evidence REQUIRED: the verbatim spec clause, the code `file:line` span *actually read*, a one-line why-trace, and **the line that would have to change to break it** (this forces reading the path, defeating rubber-stamps). A CONFORMS missing the code-span or why-trace is auto-downgraded to UNVERIFIABLE.
- **DEVIATION** — implemented but differs (the delta; spec quote + code cite; how far off).
- **MISSING** — the spec requires it; no implementing code found.
- **EXCESS** — the code does something the spec did NOT ask for (an extra branch, side effect, unrequested feature, behavior contradicting a Non-Goal). Caught by a reverse-pass: walk the *changed surface* (new exports / touched files) and flag any behavior with no backing requirement. (Surgical-Changes axis — the gate is otherwise blind to scope creep.)
- **UNVERIFIABLE** — couldn't determine from the code; must be resolved, never passed.

Per-type verification rules:
- **Invariants** (tagged in step 1): enumerate ALL governed call sites (grep the operation class, not one instance) and render the verdict over the FULL set — CONFORMS only if every site holds; a single-site citation is insufficient.
- **Ordering/atomicity invariants** (before-await, outside the atomic transaction, single-writer): trace the actual control/transaction ordering as evidence — reading a function top-to-bottom is not verifying an ordering property.
- **Test-obligations**: CONFORMS requires the test exists, exercises the specified scenario (cite the assertion lines), AND is **non-vacuous** — would FAIL if the behavior regressed (the audit-cycle vacuous-coverage bar applies here too).
- **Error-handlers / catch-blocks / branches**: verify the handler is not **BROADER** than the clause authorizes — enumerate what it ALSO catches beyond the named case. A clause "X → fallback" implemented as a catch-all that ALSO swallows an unauthorized failure (especially an error a fail-loud contract requires to propagate) is a **DEVIATION**: the code does MORE than the spec ordered. Checking only the authorized case is insufficient.

A single-model fan-out is fine: conformance is **mapping**, not the adversarial defect-hunt where cross-model diversity earns its keep — the evidence requirement above substitutes for an adversarial counter-party.

### 3 — Completeness critic (mandatory, context-less agent)
A **dedicated, context-less agent** (not the lead — the lead authored the checklist and is worst-positioned to catch its own omissions) confirms full coverage. Two axes, because requirements hide in two places:
- **Structural**: every §heading, decision, and acceptance criterion maps to a checklist item with a verdict.
- **Normative (catches cross-cutting requirements)**: grep the spec **body** for the imperative/prohibition vocabulary — MUST / MUST NOT / NEVER / ALWAYS / every / all / before / outside / invariant / atomic — and confirm EACH hit maps to a checklist clause with a verdict. Cross-cutting NEVER/invariant requirements live in prose, not headings, so a heading-only check is blind to exactly them.

Any uncovered clause → back to step 1–2 for that slice.

### 4 — Adjudicate deviations
Per DEVIATION / MISSING / EXCESS / UNVERIFIABLE:
- **Code is wrong → FIX the code.** The default for DEVIATION/MISSING. For EXCESS: remove it (Surgical-Changes) or justify-and-document.
- **Spec is stale, impl is right → amendment** (the clerical-ratification posture `audit-cycle`'s Path A defines, but recorded in the **gate artifact**, not an audit disposition table — no round has run yet). For a LOCKED spec the amendment needs the **owner's sign-off**. Do NOT amend just to go green — that hides a real deviation.
- **Genuinely-intentional deviation from a NON-locked design note → document it** in the gate artifact, AND surface it forward to the auditors as "deviation accepted — CHALLENGE if you disagree" (never "do not re-flag"). A deviation from a **LOCKED** spec is NEVER merely documented — it is fixed or owner-gated-amended, full stop.

UNVERIFIABLE must be resolved (re-read or a re-dispatched probe), never passed.

### 5 — Fix + re-verify (blast-radius scoped) until PASS
Apply fixes; re-run the fan-out on the **blast radius**, not just the failed items: any clause whose implementing code (its recorded `file:line` cites) intersects the fix diff is re-verified — a fix that satisfies clause R can break an already-CONFORMS clause R' in another slice. Then the completeness critic re-confirms FULL coverage on the post-fix sha (every clause still has a current verdict against the latest code). **PASS = full clause coverage AND zero open DEVIATION / MISSING / EXCESS / UNVERIFIABLE** — every clause CONFORMS or has a ratified amendment / a CHALLENGE-able documented-deviation.

### 6 — Gate → hand off to audit-cycle
ONLY on PASS: record in the audit's `audit-state-notes.md`: **"spec-adherence PASSED @ `<sha>`"** + a pointer to the gate artifact. Frame the handoff as **"conformance coverage verified at clause granularity per the attached checklist — auditors still run the contract-fidelity + spec-vs-reality checks and spot-check; a conformance gap you find is evidence the checklist was incomplete."** Do NOT tell auditors "conformance is established, focus only on defects" — that lulls the audit into lowering its own contract guard on the strength of a single-model attestation.

## Dispatch
The fan-out is a **dynamic Workflow** (the `Workflow` tool — `agent(prompt, {schema})` returns a validated verdict object). Partition by **code-module / data-flow cluster** (not by spec section number), budget **~15–25 clauses or one cohesive module per agent** (capped so the agent can read its code paths end-to-end in-context), and **double-cover the seams**: any clause that spans two slices (a cross-section invariant, a transition whose error-path lives in another module) is assigned to BOTH agents or to a dedicated cross-cutting-invariants slice — never dropped between partitions. Each `agent()` call uses the `references/verifier-prompt-template.md` brief + the per-clause verdict schema **and pins `opts.model` to the dispatch model the project binding names — never omitted** (an omitted pin silently inherits the main-loop model); the completeness critic (step 3) is a final stage in the same Workflow, same pin. A failed/empty slice is re-dispatched — never accepted as "all conform". *(Fallback if not using the Workflow tool: N parallel `Agent({subagent_type:'general-purpose', run_in_background:true})`, each writing `<artifact-root>/audits/<topic>/spec-adherence/slice-<k>.md` against the template.)*

## PASS criteria + artifacts
PASS is anchored to reproducible artifacts, not lead attestation alone: the checklist with every clause CONFORMS-or-resolved, the **acceptance criteria mapped 1:1 to a passing test** (or an explicit "no test for criterion N" admission, which blocks PASS or is owner-flagged), and the captured `test-output.txt` + `typecheck-output.txt` (the same the audit-cycle pre-flight needs). Per the specs-describe-current-state HARD RULE these live in `<artifact-root>/audits/<topic>/spec-adherence/` — **never in the spec body**. If an amendment lands, the spec is EDITED and a CHANGELOG line points at the artifact.

## Anti-patterns
1. **Dispatching the multi-model audit before this gate PASSES** — the audit burns rounds on conformance gaps it's the wrong tool to find.
2. **A heading-level checklist** — a multi-clause section collapsed to one line. Clause granularity; the normative sweep is the backstop.
3. **A single-site verdict for an invariant** while another site violates. Verify across ALL governed sites.
4. **Passing with open UNVERIFIABLE** — don't launder uncertainty into a PASS.
5. **Rubber-stamp CONFORMS** — no code-span actually-read + why-trace + would-break line. Auto-downgrade to UNVERIFIABLE.
6. **Surface-trace verification** — a grep hit proves a symbol exists, never that the path matches. Read end-to-end.
7. **Amending OR "documenting" a real deviation to go green** — amendment is for genuinely-stale wording (owner-gated on LOCKED); "documented deviation" is non-locked-only and CHALLENGE-able forward, never suppressed.
8. **Scope-creep blindness** — forgetting the EXCESS reverse-pass.
9. **The completeness critic run by the lead** — self-review can't catch the checklist's own omissions.
10. **A stale PASS** — bound to its sha; any commit after it (a piggybacked Low, a "quick" fix, a rebase) invalidates it. Re-verify the blast radius before the audit.
11. **Running it on a spec-LOCK cycle** — no impl to conform; that's `audit-cycle` + the spec-vs-reality check.

## When to invoke / skip
**Invoke** the moment a code implementation against a spec/contract is complete + committed and is heading for audit — it is GATE-0 of every impl audit. **Skip** for spec-LOCK cycles (no impl), pure-clerical edits, and non-spec'd throwaway code.

## Related skills
- `audit-cycle` — the adversarial multi-model gate this feeds into; owns Path A, the spec-vs-reality check, the reviewer contract-fidelity rubric, the lock gate, the registries. This skill is its GATE-0 for code impls.
- `spec-writing` — authored the spec you're conforming to (its self-review step is the author-side analogue; this is the impl-side check).
- `brief-authoring` — grep-verifies references exist; this verifies the code matches the contract.
