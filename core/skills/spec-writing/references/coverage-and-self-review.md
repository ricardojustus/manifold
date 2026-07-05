# Coverage scan + self-review ("unit tests for English")

Two checklists the SKILL.md points at. Both test the **spec**, not the implementation. Use the coverage scan during Step 3 (am I missing a whole dimension?) and the self-review during Step 5 (are the requirements I wrote any good?).

Provenance: the coverage taxonomy is the public ambiguity-and-coverage scan; the self-review is the "unit tests for English" checklist concept. Both adapted for implementation-contracts.

---

## Coverage scan (Step 3)

Walk these categories and mark each **Clear / Partial / Missing** for the spec at hand. You won't need every category in every spec — but the point is to *notice* the one you'd otherwise skip (the forgotten failure mode, the unstated security posture). Don't dump the raw map into the spec; use it to find the gaps, then fill them in the right sections.

- **Functional scope & behavior** — core goals + success criteria; **explicit out-of-scope declarations** (the Non-Goals); actor/role differentiation.
- **Data model & identity** — entities, attributes, relationships; identity & uniqueness rules; lifecycle / state transitions; volume / scale assumptions.
- **Interaction & flow** — the critical sequences / data paths; empty / loading / error states; (for behavioral surfaces) the user journey.
- **Non-functional quality** — performance (latency/throughput targets); scalability (limits); reliability & availability (recovery expectations); **observability** (what's logged / measured / traced); **security & privacy** (authN/Z, data protection, threat assumptions — cross-check the project's security baseline); compliance constraints if any.
- **Integration & external dependencies** — external services / APIs and their **failure modes**; import/export formats; protocol / version assumptions; which of the project's services / subsystems / daemons this touches.
- **Edge cases & failure handling** — negative scenarios; rate-limiting / throttling; conflict resolution (concurrent edits, races); partial-failure + cleanup paths.
- **Constraints & tradeoffs** — technical constraints (language, storage, runtime); explicit tradeoffs taken; **rejected alternatives** (feeds the Decisions section).
- **Terminology & consistency** — canonical terms; avoided synonyms / deprecated names. (A project usually has load-bearing vocabulary — distinctions where the wrong word means the wrong thing; get it right, and don't invent synonyms for a term the codebase already fixes.)
- **Completion signals** — acceptance criteria testability; a measurable Definition-of-Done. Maps to the spec's Success Criteria + the audit gate.
- **Placeholders / unresolved** — TODO / TKTK / `???` / `<placeholder>` markers; vague adjectives lacking quantification.

---

## Self-review (Step 5) — "unit tests for English"

Before the spec goes to `audit-cycle`, run one author-side pass that treats the spec like code and the review like its unit tests — testing whether the **requirements are well-written**, not whether any implementation works. The metaphor: if your spec is code written in English, this is its test suite.

What you are NOT doing here (those are audit-cycle / implementation tests):
- Not "does the function return the right value"
- Not "does the implementation match the spec"
- Not checking code at all

What you ARE checking — the requirement-quality dimensions:

- **Completeness** — are all the necessary requirements present? (e.g. "is behavior defined for when the upstream fetch fails?")
- **Clarity** — is each requirement unambiguous and specific? (e.g. "is 'prominent' / 'fast' / 'large' quantified?")
- **Consistency** — do the requirements agree with each other, and with the locked invariants? (no clause contradicts another or the constitution)
- **Measurability** — can each success criterion be objectively verified? (no unfalsifiable "robust" / "clean" / "scalable")
- **Coverage** — are all the scenarios and edge cases from the coverage scan actually addressed in the body?

### Flags to catch on this pass

- **Vague adjectives without metrics**: fast, scalable, secure, robust, intuitive, efficient, lightweight — each needs a number or a concrete criterion, or it's not testable.
- **Unresolved placeholders**: any TODO / TKTK / `???` / `[NEEDS CLARIFICATION]` still open past the cap, or `<placeholder>` text left in.
- **Verbs without objects**: "the system handles errors" — handles them *how*, resulting in *what* observable state?
- **Orphan requirements**: a requirement with no corresponding success criterion, or a success criterion no requirement produces.
- **Silent assumptions**: a default baked into the design that isn't surfaced in the Assumptions section.

A clean self-review doesn't guarantee the spec passes audit-cycle — but it catches the cheap, embarrassing classes early, where fixing them costs a sentence instead of an audit round.
