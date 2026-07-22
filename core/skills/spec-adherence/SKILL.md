---
name: spec-adherence
description: >-
  Light conformance tripwire before audit-cycle: ONE pass over the spec's ratified surface (acceptance criteria + Decisions), evidence per verdict, the authority fork on dead machinery, at most one fix-pass — never an agent fleet. Run as Gate 0 before audit-cycle, or on "conformance pass" / "does the impl match the spec".
---

# Spec-adherence — the conformance tripwire before the audit

`audit-cycle` hunts **defects**; it can pass clean while the code quietly **fails to implement
the contract** (a decision never wired, a branch silently dropped — divergent code reads as
internally consistent). This gate catches that class CHEAPLY, before audit rounds are spent on
it. It is a **tripwire, not a proof**: one pass, one sitting, no agent fleet. The audit's
contract-fidelity and spec-vs-reality checks stay fully live behind it.

*Settled 2026-07-22, operator-killed predecessor: the prior clause-exhaustive shape (checklist
of every MUST, multi-agent Workflow fan-out, completeness-critic agent, unbounded fix→re-verify
loop, wire-by-default adjudication) looped two builders in one day into wiring dead machinery
nobody had asked for. Do not regrow it.*

## Where it sits

```
implement → commit → [THIS GATE: one pass → adjudicate → at most ONE fix-pass → PASS @ sha]
          → audit-cycle round-1 → … → lock gate → merge
```

**A non-PASS never proceeds to the multi-model audit. The PASS is bound to a commit sha** —
any later commit invalidates it (audit-cycle asserts `HEAD` == the PASS sha; re-verify the
touched items first). Code implementations only; spec-LOCK cycles skip it (nothing to conform).

## The pass — one sitting, no fleet

**The walk list is the RATIFIED surface, not every sentence of the spec**: the acceptance
criteria, the Decisions, and — for a LOCKED-spec amendment — the delta + sibling-coordination
items. That is what the operator actually signed; prose restatements of it are not separate
obligations.

Per item: read the spec item verbatim → locate and read the implementing code path first-hand
(a grep hit is not a read) → verdict:

- **CONFORMS** — evidence required: the code `file:line` span actually read + a one-line
  why-trace. No span = UNVERIFIABLE, not CONFORMS.
- **DEVIATION** — implemented but differs (quote the item, cite the code, state the delta).
- **MISSING** — required, no implementing code found.
- **EXCESS** — one quick reverse glance at the changed surface (new exports / touched files):
  behavior with no backing requirement. The scope-creep catch; keep it to a glance.
- **UNVERIFIABLE** — resolve or surface; never silently passed.

Run the project's test suite + typecheck and capture the outputs (the audit pre-flight needs
them anyway). **Executor: the lead inline, or ONE dispatched agent** (the binding names the
model). Never a workflow fan-out, never a critic agent — the audit is the completeness net.

## Adjudication — the authority fork (the anti-ratchet rule, impl side)

- **DEVIATION / MISSING on a live, authorized requirement → fix the code.** The normal case.
- **Dead machinery** — zero-caller mechanisms, unreachable guards, alarms with no sensor,
  MISSING wiring for something nothing consumes: **run the authority test on the CLAUSE before
  touching the code.** Traces to a plan/posture clause or a concrete demonstrated need → wire
  it (a real conformance bug). No authority → **never wire it to go green**: the clause joins
  the deletion-candidate batch (owner-gated amendment — LOCKED specs change only on the
  operator's word) and the code stays unwired or leaves with the clause. Deadness alone proves
  nothing either way; authority decides.
- **EXCESS** → remove it (surgical-changes), or justify it forward to the auditors as
  "deviation accepted — CHALLENGE if you disagree".
- **Spec stale, impl right** → owner-gated amendment. Never amend just to go green.

## The cap — ONE fix-pass, no loop

Apply the fixes once; re-verify only the items the fix touched. **Still divergent after one
pass → STOP and surface to the operator** — the spec or the build has a deeper problem, and
grinding is exactly how the wire-everything loop happened. There is no second pass to get
caught in.

**PASS** = every walked item CONFORMS, is ratified-amended, or is explicitly operator-flagged
(an acceptance criterion with no test is flagged, never silently passed). Record
`spec-adherence PASSED @ <sha>` + the artifact pointer in the audit's `audit-state-notes.md`.
Hand off WITHOUT telling auditors to lower their contract guard — a conformance gap they find
is the net catching what the tripwire missed.

## Artifacts

The walk table + captured `test-output.txt` / `typecheck-output.txt` →
`<artifact-root>/audits/<topic>/spec-adherence/`. Never in the spec body.

## Anti-patterns

1. **Clause-exhaustive decomposition, agent fleets, a completeness critic, loop-until-green** —
   the operator-killed predecessor shape. The walk list is the ratified surface.
2. **Wiring a dead mechanism whose clause has no authority** — the clause is the defect;
   deletion-candidate, operator's word.
3. **A second fix-pass** — divergence after one pass surfaces to the operator.
4. **Rubber-stamp CONFORMS** — no code span actually read = UNVERIFIABLE.
5. **A stale PASS** — sha-bound; any later commit invalidates it.
6. **Running it on a spec-LOCK cycle** — no impl to conform.
7. **Telling auditors conformance is established** — the tripwire never lowers the net.

## Related skills

- `audit-cycle` — the adversarial multi-model gate behind this tripwire; owns the lock gate,
  Path A, the spec-vs-reality check, the finding-authority discipline.
- `spec-writing` — authored the spec; its self-review is the author-side analogue.
- `brief-authoring` — grep-verifies references exist; this verifies delivered behavior.
