# Coverage scan + self-review ("unit tests for English")

Two checklists the SKILL.md points at. Both test the **spec**, not the implementation. Use the coverage scan during Step 3 (am I missing a whole dimension?) and the self-review during Step 5 (are the requirements I wrote any good?).

---

## Coverage scan (Step 3)

Walk these categories and mark each **Clear / Partial / Missing** for the spec at hand. You won't need every category in every spec — but the point is to *notice* the one you'd otherwise skip (the forgotten failure mode, the unstated security posture). Don't dump the raw map into the spec; use it to find the gaps, then fill them in the right sections.

- **Functional scope & behavior** — core goals · success criteria · **explicit out-of-scope declarations** (Non-Goals) · actor/role differentiation.
- **Data model & identity** — entities/attributes/relationships · identity & uniqueness rules · lifecycle / state transitions · volume / scale assumptions.
- **Interaction & flow** — critical sequences / data paths · empty / loading / error states · user journey (behavioral surfaces).
- **Non-functional quality** — performance (latency/throughput targets) · scalability limits · reliability & recovery expectations · **observability** (logged / measured / traced) · **security & privacy** (authN/Z, data protection, threat assumptions — cross-check the project's security baseline) · compliance constraints.
- **Integration & external dependencies** — external services/APIs + their **failure modes** · import/export formats · protocol / version assumptions · which of the project's services / subsystems / daemons this touches.
- **Edge cases & failure handling** — negative scenarios · rate-limiting / throttling · conflict resolution (concurrent edits, races) · partial-failure + cleanup paths.
- **Constraints & tradeoffs** — technical constraints (language, storage, runtime) · tradeoffs taken · **rejected alternatives** (feeds Decisions).
- **Terminology & consistency** — canonical terms · no synonyms for load-bearing vocabulary the codebase already fixes · no deprecated names.
- **Completion signals** — acceptance-criteria testability · a measurable Definition-of-Done (maps to Success Criteria + the audit gate).
- **Placeholders / unresolved** — TODO / TKTK / `???` / `<placeholder>` markers · vague adjectives lacking quantification.

---

## Self-review (Step 5) — "unit tests for English"

Before the spec goes to `audit-cycle`, run one author-side pass that treats the spec like code and the review like its unit tests — testing whether the **requirements are well-written**, not whether any implementation works. The metaphor: if your spec is code written in English, this is its test suite.

What you are NOT doing here (those are audit-cycle / implementation tests):
- Not "does the function return the right value"
- Not "does the implementation match the spec"
- Not checking code at all

What you ARE checking — the requirement-quality dimensions:

- **Completeness** — every necessary requirement present ("is behavior defined for when the upstream fetch fails?").
- **Clarity** — each requirement unambiguous and specific ("is 'prominent' / 'fast' / 'large' quantified?").
- **Consistency** — requirements agree with each other, with the locked invariants, and with the constitution.
- **Measurability** — each success criterion objectively verifiable (no unfalsifiable "robust" / "clean" / "scalable").
- **Coverage** — the coverage scan's scenarios and edge cases actually addressed in the body.

### Flags to catch on this pass

- **Vague adjectives without metrics**: fast, scalable, secure, robust, intuitive, efficient, lightweight — each needs a number or a concrete criterion, or it's not testable.
- **Unresolved placeholders**: any TODO / TKTK / `???` / `[NEEDS CLARIFICATION]` still open past the cap, or `<placeholder>` text left in.
- **Verbs without objects**: "the system handles errors" — handles them *how*, resulting in *what* observable state?
- **Orphan requirements**: a requirement with no corresponding success criterion, or a success criterion no requirement produces.
- **Silent assumptions**: a default baked into the design that isn't surfaced in the Assumptions section.

A clean self-review doesn't guarantee the spec passes audit-cycle — but it catches the cheap, embarrassing classes early, where fixing them costs a sentence instead of an audit round.
