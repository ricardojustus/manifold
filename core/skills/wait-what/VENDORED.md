# Vendored provenance — wait-what

- **Upstream**: https://github.com/mattpocock/skills (`skills/productivity/wait-what`)
- **Version**: commit `8b36d4fb2635b3c21998dcd8144439c9e5ba7302` (vendored 2026-08-05)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of the upstream skill dir (a single-short-paragraph SKILL.md +
  `agents/openai.yaml` interface stub; no scripts), 2026-08-05. The adopting project keeps the
  analysis record in its own evidence store.
- **Posture**: near-verbatim — this copy is OURS; upstream changes do not flow in automatically.

## Adaptation delta vs upstream

1. One clause generalized: upstream names its own repo convention, "the ubiquitous language from
   `CONTEXT.md`"; here it is the project's established shared vocabulary — its glossary, where one
   exists — instead of session-coined terms. The body stays a single short paragraph.
2. Voice: upstream's first person ("I don't understand where you've got to") is the operator's
   voice; this copy addresses the agent about the operator, matching the harness's
   second-person-imperative skill voice. Upstream's description is kept as written.
3. USER-invoked kept (`disable-model-invocation: true`): zero context load — the operator types
   `/wait-what` at the moment a reply fails to land, which is the only moment it fires.
4. `agents/openai.yaml` dropped (not this harness's format).
