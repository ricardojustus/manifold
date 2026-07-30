# Model pins — which model tier does which job

Dated pins (public defaults, 2026-07-29). **Re-verify whenever the model lineup changes** —
a pin naming a retired model silently falls back to the session model, which is the failure
this file exists to prevent.

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
