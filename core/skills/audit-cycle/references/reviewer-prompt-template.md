# Reviewer-prompt template

Operational template the lead constructs for each reviewer in an audit-cycle round. Both the primary and the cross-model reviewer receive the same prompt; the threat model + invariant list vary per layer. The project binding supplies the concrete project-specific rubric categories + threat model.

Copy + fill in the placeholders. The single canonical output location is `AUDIT_DIR` (= `<artifact-root>/audits/<topic>/round-<N>/`) — the SAME directory the skill's pre-flight created and the diff/test artifacts live in. Do NOT introduce a second tree; a reviewer told to write elsewhere produces a mid-audit stall with no error to debug.

```
Adversarial audit of <topic> at <commit-SHA>. Your job is to break confidence in the change, not validate it.

# Subject

The implementation AS A WHOLE on `<feature-branch>` at HEAD `<sha>`.
NOT the diff. The diff at `<AUDIT_DIR>/<topic>-diff.patch` is CONTEXT ONLY.

Files in scope (read end-to-end):
- <file path 1>
- <file path 2>

# Mandatory reads — BEFORE forming opinions

- <AUDIT_DIR>/audit-state-notes.md (round-N disposition table + pre-known notes + special dimensions)
- <the spec / implementation contract>
- <related lessons / memory files>

# Threat model (from the project binding)

- Compromised-agent / adversary threat: <how it applies>
- Load-bearing invariants: <list>
- LOCKED layers untouchable: <list>

# Empirical work REQUIRED (for the primary reviewer — a cross-model reviewer does this organically)

- Grep `<source path>` for `<pattern>` and verify <claim>.
- Cross-reference the spec's `<table/code-block/schema>` against the surrounding prose. If they disagree, table/code wins for implementers — flag the mismatch.
- Verify every "resolved" item in the round-(N-1) disposition table by reading the cited file:line; mark VERIFIED-CLOSED / STILL-OPEN / FALSE-POSITIVE.

# Rubric — universal categories

1. **Contract fidelity** — does the code realize the spec verbatim?
2. **Type discipline + boundary errors** — see the conditional Type-design category for layers introducing types.
3. **Security primitives** — no secrets in tool args / logs / outputs; redaction at output boundaries; identity/authz invariants hold; no capability the layer wasn't granted.
4. **Error handling** — scrutinize every error handler:
   - **Catch specificity** — catches only expected error types? Could a broad catch silently swallow unrelated errors? List every unexpected error type the catch could hide.
   - **Fallback behavior** — explicitly requested by design? Documented? Or silently masking the problem? Fallback to a mock/stub in production code is a red flag.
   - **Error propagation** — should this error bubble up to a higher handler instead of being caught here? Does catching prevent proper cleanup?
   - **Hidden-failure anti-patterns** — empty catch (forbidden); log-and-continue without surfacing; null/undefined returns on error without logging; silent `?.` skips that drop operations; fallback chains that try multiple approaches with no explanation.
   - **Logging quality** — would this log help debug 6 months from now? Sufficient context (operation, IDs, state)? Appropriate severity?
5. **Concurrency** — parallel-collapse risk (a batch that fails all-or-nothing when it should be per-item), async/sync ordering invariants, lock/permit correctness, race windows.
6. **Test coverage non-vacuity** — does each test exercise its claim?
   - **Behavioral coverage NOT line coverage** — line coverage can be 100% with all tests still vacuous. The right question: would this test catch the specific regression it claims to cover?
   - **Tests against contracts, not implementation** — resilient to reasonable refactoring? Or coupled to internals that should be free to change?
   - **DAMP framing** — Descriptive And Meaningful Phrases. Test names should describe the regression they'd catch, not the function under test.
   - **Critical gaps to scan for** — untested error paths, missing edge cases (boundary conditions), uncovered branches, absent negative test cases, missing concurrent/async tests.
   - **Assertion specificity** — every assertion must check the SPECIFIC condition that would catch the regression, not a generic "no error thrown" or "returns truthy". A `toBeTruthy()` against a function that always returns `1` passes vacuously. Strong assertions name the value, the shape, the boundary.
   - **No shared state between tests** — each test establishes its own preconditions; cleanup must actually reset state. Tests that pass in one order and fail in another are vacuous about whatever the order-dependence hides.
7. **Edge cases** — empty / max / threshold boundaries.
8. **Cross-module imports / layering** — no forbidden cross-layer import; no circular deps; a leaf module stays importable in isolation.
9. **Observability** — telemetry shape, retry counts, failure/redaction incident surfacing; enough signal to debug in production.
10. **Prose-vs-structured-artifact consistency** — if prose says X and a table/code/schema says ¬X, the table wins for implementers. Flag every mismatch.
11. **Type design quality** (CONDITIONAL — only when the layer introduces new types):
    - **Encapsulation** (1-10) — internal implementation hidden? Can invariants be violated from outside?
    - **Invariant Expression** (1-10) — how clearly are invariants communicated through type structure? Compile-time enforcement where possible?
    - **Invariant Usefulness** (1-10) — do the invariants prevent real bugs? Neither too restrictive nor too permissive?
    - **Invariant Enforcement** (1-10) — are constraints actually enforced, or just documented?

# Rubric — project-specific categories (from the binding)

<the binding's project-specific rubric categories — data-substrate integrity, drift/determinism tests, domain-quality metrics, extra security primitives — with their concrete probes>

# Special audit dimensions for THIS layer

- <layer-specific load-bearing checks>

# Confidence scoring

Rate each finding 0-100. **Only report ≥80** (this filters noise; calibrated from cross-model-lens experience):

- **0-25**: likely false positive or pre-existing issue → don't report
- **26-50**: minor nitpick not explicitly in spec → don't report unless Critical
- **51-75**: valid but low-impact → don't report unless Critical/High and you'd stake your name on it
- **76-90**: important issue requiring attention → REPORT
- **91-100**: critical bug or explicit spec violation → REPORT

# Severity rubric

- **Critical**: would break the substrate or open a security hole
- **High**: contract violations / load-bearing invariants
- **Medium**: design choices worth pushing back on
- **Low**: cosmetic / internal-consistency

# Evidentiary discipline

When you claim "verified via grep" or "the helper at X:Y exists" — PASTE the grep output / file excerpt inline. Don't just claim it. Reviewers who claim without evidence inherit the confabulation pattern.

# Output

Write to `<AUDIT_DIR>/reviewer-<primary|cross-model>-round-<N>.md`:
- Subject + inputs
- Round-N fix-verification table (round-2+ only: VERIFIED-CLOSED / STILL-OPEN / FALSE-POSITIVE per finding)
- Summary: NC/NH/NM/NL counts + score X/Y (3 points × applicable categories — exclude the conditional Type-design category when non-applicable; the binding's project categories add to Y) + verdict (MERGE / NEEDS-FIX-PASS / NEEDS-ROUND-N+1)
- **Critical / High / Medium / Low sections** — each finding includes:
  - file:line
  - pasted-evidence (the grep output or excerpt that backs the claim)
  - inline confidence score 0-100 (e.g., `[conf 92]`) so consolidation can trace MAX-severity decisions
  - recommended fix
- **Strengths section** — explicit "what's load-bearing and correct; do NOT change in the fix-pass" callouts. Signals to the fix-pass author what NOT to touch. Especially valuable when the audit is mostly clean — prevents accidental regressions during banner amendments or test-stub updates.

DO NOT modify code. Audit only. If clean: recommend "<topic> LOCKED → MERGE".
```

## Notes on usage

- **The Type-design category** is conditional — include only when the layer introduces new types. The score base is `3 × applicable categories`; excluding a category lowers the denominator so a non-applicable category isn't scored as a miss.
- **The Error-handling category** is where the silent-failure-hunter patterns earn their keep. The expanded sub-bullets surface anti-patterns the top-level wording alone won't.
- **The Test-coverage category** sub-bullets catch the vacuous-coverage recurring failure.
- **Reviewer-prompt vs audit-state-notes**: this template is the WHAT-to-look-for; audit-state-notes is the CONTEXT (PK notes, special dimensions, disposition table). Both go in the dispatch.
