<!-- FILL model_pins: which model tier does which job, by explicit model ID — plus any
     cross-model (second-family) lens IDs and the facts about model fallbacks this project
     must know. A pin naming a retired model silently falls back to the session model, which
     is the failure this slot exists to prevent: re-verify whenever the lineup changes.
     (The scaffold provides the heading.) -->

<!-- Suggested starting content (public defaults, dated 2026-07-29) — accept, edit, or drop it,
     then DELETE the placeholder comment above (an install with that comment still present
     fails closed). Hand-filling this template? Do the same by hand. -->

Dated pins (public defaults, 2026-07-29). **Re-verify whenever the model lineup changes.**

| Tier | Model | Used for |
|---|---|---|
| **Frontier** | `claude-opus-5` | Orchestration, design, spec authoring, severity calls, reviewer/audit seats |
| **Mid** | `claude-sonnet-5` | Implementation from an unambiguous locked spec |
| **Cheap** | `claude-haiku-4-5-20251001` | Inventories, sweeps, probes, read-and-summarize |

- **Naming a model on a dispatch is mandatory, not advisory.** A dispatch with no `model:`
  inherits the session's model — usually the most expensive one, silently.
- A spec's implementation-dispatch triage overrides these defaults for that job.
- Effort is the second dial: implementers on specced work run at **medium** effort;
  reviewer/audit seats run at the highest available.
- Cross-model reviewer seat (a second model family for audits): name the model here once you
  have one; without it, audits run the documented single-lens fallback.
