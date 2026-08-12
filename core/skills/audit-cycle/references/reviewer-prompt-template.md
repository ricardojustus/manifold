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

*(Lead, filling this in: this list IS the evidence base as the reviewer will understand it. Where
the subject's record spans layers — a verification write-up plus the raw data it summarizes, a
decision doc plus the transcript behind it — name every layer a finding could turn on. A co-equal
source left off reads to the reviewer as non-evidence, and comes back as a confident finding
against material an un-named layer already settles. Completeness means layers, not volume —
every listed file costs reviewer tokens; list only what findings could turn on.)*

- <AUDIT_DIR>/audit-state-notes.md (round-N disposition table + pre-known notes + special dimensions)
- <the spec / implementation contract>
- <the governing PLAN — FULL read, not excerpts: its Decisions, Non-Goals, rejected alternatives, and Security Posture section are the authority your findings must cite; kill-rulings scatter across sections>
- <the governing VISION — FULL read, where one exists>
- <related lessons / memory files>
- <the deliverable's ENVIRONMENTS — build, test, release, runtime, and THE OPERATOR'S OWN
  MACHINE where the flow differs; a default path / env-var / host assumption is a concrete
  claim about a named environment (Cat #15 treatment), and a gate's acceptance includes one
  real run in each environment its flow serves>
- <where the subject is agent-consumed prose — a skill, rule, agent file, template, or any other
  document that instructs an agent: the installed `writing-for-agents` skill body
  (`.claude/skills/writing-for-agents/SKILL.md`) §Absolutes, and run its check over every
  normative clause in this review's scope — added, rewritten, or, where the subject is existing
  text rather than a change, the clauses under review. Your role carries no Skill tool, so read
  the file directly.>

# Threat model (from the project binding)

- Compromised-agent / adversary threat: <how it applies>
- Load-bearing invariants: <list>
- LOCKED layers untouchable: <list>

# Empirical work REQUIRED (for the primary reviewer — a cross-model reviewer does this organically)

- Grep `<source path>` for `<pattern>` and verify <claim>.
- Cross-reference the spec's `<table/code-block/schema>` against the surrounding prose. If they disagree, table/code wins for implementers — flag the mismatch.
- Verify every "resolved" item in the round-(N-1) disposition table by reading the cited file:line; mark VERIFIED-CLOSED / STILL-OPEN / FALSE-POSITIVE.

## Adversarial-probe classes — DECLARE OR JUSTIFY (build-phase rounds on LOCKED / high-stakes surfaces)

*Include this block only for build-phase audit rounds on a LOCKED or otherwise high-stakes surface — a best-effort convenience review does not pay this cost (right-sized engineering).*

Your report MUST carry a line per class below: either the **probe RESULT** (what you ran, what happened) or **why the class is N/A for this subject** — a specific reason, not "looks fine." This mandates the REPORT, not a fixed probe list: a bare checklist invites box-ticking and no-op rationalization; a declare-or-justify line is what changes behavior. Silence on a class is an incomplete review.

1. **Dependency-failure injection** — make the dependency FAIL, not succeed: force the query/read/write/parse to throw or return empty, and follow every `catch`/fallback path. Does a fallback silently restore a defect the spec calls load-bearing? Does the system continue in a state the spec forbids?
2. **Boundary-scale inputs** — MB-class strings, 10k-record fixtures, empty and single-element sets, max-length identifiers. Does anything blow up (RangeError/OOM/timeout) or silently truncate? Pay special attention to SHARED dependencies: a size limit in a common utility can make a legal record permanently unprocessable.
3. **Hostile-value classes** — values that are *type-valid but semantically impossible or adversarial*: impossible calendar dates, clock regressions, duplicate/reused identifiers, encoding edge cases, values that normalize into something else. Does anything impossible get accepted into a durable/immutable store?

*Receipt: across a 9-round two-model ladder, the cross-model lens was the decisive finder in 6 of 7 rounds; in one impl round the primary returned a clean MERGE while the cross-model lens found three empirically-provable Highs — an error-fallback that silently restored a spec-forbidden state, an impossible calendar date accepted into a forever-raw store, and a size-limit RangeError in a shared security dependency that made a legal record uncapturable. The primary's empirical work was solid on the probes it CHOSE; it simply never ran these classes. This narrows the primary-lens gap — it never substitutes for the cross-model lens, whose orthogonal threat model remains the strongest signal there is.*

# Repro hygiene — probes that can WRITE

This covers **any probe you run** that can write anywhere real — a live store, a shared database, a
path the running system reads — whether this brief names it or you devised it yourself. What the
probe left behind is judged by what can be UNDONE, not by who made it:

- **State the probe introduced**, except a durable write that is itself the thing under test —
  that one is the next bullet's. A planted record, a scratch row, a test file, a receipt the
  system appended because you poked it. Unwanted and the surface permits deletion: remove it before
  reporting, and say that you did. Unwanted but the surface forbids deletion (an append-only store,
  an immutable log): say in your report exactly what is now there and where. Residue outlives the
  audit that made it, and the thing it breaks next is usually unrelated to the finding it was
  proving — so it is found in your report, or it is found much later by someone debugging
  something else.
- **State you did not create, or a durable write that is itself the thing under test**: removal is
  the wrong instinct — deleting it destroys what the probe was never given. Restore what you
  changed where the data contract allows, and where it does not, name in your report exactly what
  the probe left and where, so the next reader is not discovering it.

*(Lead, filling this in: name any probe you are REQUIRING that writes to a real surface, along with
its safe cleanup or restore command, so the reviewer is not inventing one against a store you know
better than they do.)*

# Rubric — universal categories

1. **Contract fidelity** — does the code realize the spec verbatim?
2. **Type discipline + boundary errors** — see the conditional Type-design category for layers introducing types.
3. **Security primitives** — no secrets in tool args / logs / outputs; redaction at output boundaries; identity/authz invariants hold; no capability the layer wasn't granted.
4. **Error handling** — per handler: catch specificity (list every unexpected type a broad catch could hide) · fallback behavior (design-requested and documented, or silently masking? a mock/stub fallback in production code is a red flag) · propagation (should it bubble to a higher handler; does catching prevent cleanup?) · logging quality (enough context — operation, IDs, state — to debug 6 months from now; appropriate severity).
   - **Hidden-failure anti-patterns** — empty catch (forbidden); log-and-continue without surfacing; null/undefined returns on error without logging; silent `?.` skips that drop operations; fallback chains that try multiple approaches with no explanation.
5. **Concurrency** — parallel-collapse risk (a batch that fails all-or-nothing when it should be per-item), async/sync ordering invariants, lock/permit correctness, race windows.
6. **Test coverage non-vacuity** — does each test exercise its claim? Behavioral coverage NOT line coverage (100% lines can be 100% vacuous — would this test catch the specific regression it claims?) · tests against contracts, not internals that should be free to change · DAMP names describing the regression caught, not the function under test · assertion specificity (never a generic "no error thrown" / "returns truthy": a `toBeTruthy()` against a function that always returns `1` passes vacuously — name the value, the shape, the boundary) · no shared state between tests (each establishes its own preconditions; tests that pass in one order and fail in another are vacuous about whatever the order-dependence hides) · gaps to scan for: untested error paths, boundary edge cases, uncovered branches, absent negative cases, missing concurrent/async tests.
   - **Path of record** — a test asserting on a deliverable whose installed or live copy sits outside the working tree must assert against the repo-relative path under test, not the absolute path to that installed copy. An absolute live path reports on whatever is installed regardless of the branch's content, so the assertion cannot go red on a wrong branch — and a gate that cannot fail is not a gate. The exception is a test whose SUBJECT genuinely is the installed artifact (an install or promotion check); that test says so explicitly.
7. **Edge cases** — empty / max / threshold boundaries.
8. **Cross-module imports / layering** — no forbidden cross-layer import; no circular deps; a leaf module stays importable in isolation.
9. **Observability** — telemetry shape, retry counts, failure/redaction incident surfacing; enough signal to debug in production.
10. **Prose-vs-structured-artifact consistency** — if prose says X and a table/code/schema says ¬X, the table wins for implementers. Flag every mismatch.
11. **Type design quality** (CONDITIONAL — only when the layer introduces new types):
    - **Encapsulation** (1-10) — internal implementation hidden? Can invariants be violated from outside?
    - **Invariant Expression** (1-10) — how clearly are invariants communicated through type structure? Compile-time enforcement where possible?
    - **Invariant Usefulness** (1-10) — do the invariants prevent real bugs? Neither too restrictive nor too permissive?
    - **Invariant Enforcement** (1-10) — are constraints actually enforced, or just documented?
12. **Excess** — the inverse hunt, same rigor as the other categories: material the job does not
    demand — machinery no ratified clause calls for, clauses that cannot fire on this system,
    acceptance criteria satisfiable only by mocking the thing under test, defenses no in-scope
    adversary can trigger, duplicated guards. Report as findings with the same confidence bar;
    **a deletion recommendation scores exactly like a gap recommendation** — finding what
    shouldn't exist counts equally with finding what's missing. Severity: excess that widens
    attack or maintenance surface on a security-relevant path = Medium+; inert excess = Low.
    Scope guard: an excess finding against material the OPERATOR ratified routes to the
    operator (ratified machinery is theirs to keep); against ladder-born material it drives
    the mechanism-defect fork (audit-cycle's Finding authority section) normally.
13. **Code-smell baseline** (CONDITIONAL — code subjects only; the classic Refactoring smell
    set) — judgment-call heuristics matched against the code this round audits (rounds 2+: the
    fix diff), never hard violations: label each "possible <smell>" and quote the hunk. A
    documented repo/project standard OVERRIDES the baseline where they conflict, and anything
    tooling already enforces is skipped. Default severity Low; rate higher only where
    the instance compounds into a real defect, with normal authority. The set: **Mysterious Name** ·
    **Duplicated Code** · **Feature Envy** · **Data Clumps** · **Primitive Obsession** · **Repeated
    Switches** · **Shotgun Surgery** · **Divergent Change** · **Speculative Generality** (overlaps
    the Excess category — report there when it blocks) · **Message Chains** · **Middle Man** ·
    **Refused Bequest**.

# Rubric — project-specific categories (from the binding)

<the binding's project-specific rubric categories — data-substrate integrity, drift/determinism tests, domain-quality metrics, extra security primitives — with their concrete probes>

# Special audit dimensions for THIS layer

- <layer-specific load-bearing checks>

# Confidence scoring

Rate each finding 0-100. **Only report ≥80** (this filters noise):

- **0-25**: likely false positive or pre-existing issue → don't report
- **26-50**: minor nitpick not explicitly in spec → don't report unless Critical
- **51-75**: valid but low-impact → don't report unless Critical/High and you'd stake your name on it
- **76-90**: important issue requiring attention → REPORT
- **91-100**: critical bug or explicit spec violation → REPORT

# Finding authority (mandatory line per finding)

Every finding carries an `Authority:` line answering "what EXISTING requirement does this
enforce?" — a spec MUST/SHALL clause, a constitution/security-floor rule, a governing-plan
decision or Security Posture clause, or a concrete reproducible failure of intended behavior
(paste the repro). A finding whose remedy would EXPAND the contract — a new guard, gate,
freeze, denial, attestation, config knob, or process step no current clause demands — must
cite the plan/vision/posture clause that calls for it; if you cannot, report it as
`Authority: NONE — ADVISORY`. Advisory findings are real work and reach the operator, but they
do not block lock and do not drive fix-passes. "I thought of it" is not authority. A genuine
security hole the posture never anticipated: `Authority: POSTURE-GAP` + the concrete attack
path — the operator decides whether the posture grows, never you. A finding whose remedy adds
machinery also names WHICH adversary in this round's stated threat model performs the repro —
a repro needing capabilities no in-scope adversary has does not establish the problem.

# Severity rubric

- **Critical**: would break the substrate or open a security hole
- **High**: contract violations / load-bearing invariants
- **Medium**: design choices worth pushing back on — lock-blocking ONLY with an `Authority:`
  citation (see Finding authority); without one the finding is ADVISORY
- **Low**: cosmetic / internal-consistency

# Evidentiary discipline

When you claim "verified via grep" or "the helper at X:Y exists" — PASTE the grep output / file excerpt inline. Don't just claim it. Reviewers who claim without evidence inherit the confabulation pattern. Render control bytes in pasted probe evidence as escapes (`\x00`), never raw — a raw NUL byte makes your whole report file silently invisible to grep for every future verifier.

# Output

Write to `<AUDIT_DIR>/reviewer-<primary|cross-model>-round-<N>.md`:
- Subject + inputs
- Round-N fix-verification table (round-2+ only: VERIFIED-CLOSED / STILL-OPEN / FALSE-POSITIVE per finding)
- Summary: NC/NH/NM/NL counts + score X/Y (3 points × applicable categories — exclude the conditional categories (Type-design, Code-smell baseline) when non-applicable; the binding's project categories add to Y) + verdict (MERGE / NEEDS-FIX-PASS / NEEDS-ROUND-N+1)
- **Critical / High / Medium / Low sections** — each finding includes:
  - file:line
  - pasted-evidence (the grep output or excerpt that backs the claim)
  - `Authority:` line (clause citation / pasted repro / `NONE — ADVISORY` / `POSTURE-GAP`)
  - inline confidence score 0-100 (e.g., `[conf 92]`) so consolidation can trace MAX-severity decisions
  - recommended fix
- **Strengths section** — explicit "what's load-bearing and correct; do NOT change in the fix-pass" callouts. Signals to the fix-pass author what NOT to touch. Especially valuable when the audit is mostly clean — prevents accidental regressions during banner amendments or test-stub updates.

DO NOT modify code. Audit only. If clean: recommend "<topic> LOCKED → MERGE".
```

## Notes on usage

- **The Type-design and Code-smell categories** are conditional — Type-design only when the layer introduces new types, Code-smell only on code subjects. The score base is `3 × applicable categories`; excluding a category lowers the denominator so a non-applicable category isn't scored as a miss.
- **The Error-handling category** is where the silent-failure-hunter patterns earn their keep. The expanded sub-bullets surface anti-patterns the top-level wording alone won't.
- **The Test-coverage category** sub-bullets catch the vacuous-coverage recurring failure.
- **Reviewer-prompt vs audit-state-notes**: this template is the WHAT-to-look-for; audit-state-notes is the CONTEXT (PK notes, special dimensions, disposition table). Both go in the dispatch.
