# Confidence gate — canonical paste text

For lane briefs and any dispatch with a substantial pre-flight read list. Fires ONCE, AFTER the
pre-flight reads, BEFORE any drafting. (Distinct from the `DECISION-PENDING-<owner>` inline
marker, which fires *during* work and continues.)

The canonical text also ships in the dispatch brief template in `.claude/harness-templates/` and
in `parallel-workstreams/references/brief-template.md` — point the brief at a template rather than
re-pasting when you aren't customizing.

> **Confidence gate (HALT-AND-REPORT before starting work)**
>
> After completing pre-flight reads + BEFORE drafting anything: print to terminal:
>
> `Confidence: <0-100%> in assignment understanding.`
>
> If <100%, list:
> - **Clarifications needed** (if any) — specific questions the owner should answer before you start
> - **Divergent ideas** (if any) — be opinionated; name what YOU think + why it differs from the brief
>
> If 100%, print "Confidence: 100% — proceeding" and continue.
>
> If <100%, HALT + wait for the owner to type clarification in this terminal window. Do NOT proceed
> with assumptions — cost of waiting for clarification < cost of building the wrong thing.
