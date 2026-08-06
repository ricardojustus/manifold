# Vendored provenance — to-questionnaire

- **Upstream**: https://github.com/mattpocock/skills (`skills/productivity/to-questionnaire`)
- **Version**: commit `8b36d4fb2635b3c21998dcd8144439c9e5ba7302` (vendored 2026-08-05)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of the upstream skill dir (SKILL.md prompt text +
  `agents/openai.yaml` interface stub; no scripts), 2026-08-05. The adopting project keeps the
  analysis record in its own evidence store.
- **Posture**: near-verbatim — this copy is OURS; upstream changes do not flow in automatically.

## Adaptation delta vs upstream

1. Voice pass: "the user" → "the operator" throughout, template included.
2. Upstream ships `disable-model-invocation: true` (user-invoked); this copy is MODEL-invoked, with
   a trigger-rich description — the same reachability trade every vendored skill in this harness
   records: the agent must be able to reach it when a spec or plan premise turns out to live in a
   third party's head, at the cost of a standing description in context.
3. Output location rebound: upstream writes to "the current directory"; here the file goes where
   the invoking context says deliverables go, with the project binding naming the concrete home.
4. `agents/openai.yaml` dropped (not this harness's format).
