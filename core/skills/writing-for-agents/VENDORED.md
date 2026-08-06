# Vendored provenance — writing-for-agents

- **Upstream**: https://github.com/mattpocock/skills (`skills/productivity/writing-for-agents`)
- **Version**: commit `8b36d4fb2635b3c21998dcd8144439c9e5ba7302` (vendored 2026-08-05)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of SKILL.md + SKILL-MECHANICS.md (prose reference, no
  scripts), 2026-08-05. The adopting project keeps the analysis record in its own evidence store.
- **Posture**: vendored reference, near-verbatim — this copy is OURS; upstream changes do not flow
  in automatically. Re-vendoring requires a fresh end-to-end read.

## Adaptation delta vs upstream

1. **Supersedes this harness's `writing-great-skills` copy** (pin `2ab9580` → `8b36d4f`), which
   upstream deleted in favour of this skill. Its scope widened from skills to any agent-consumed
   document — always-loaded agent files and pointer-reached docs included.
2. Layout renamed: upstream's sibling `SKILL-MECHANICS.md` moved to `references/SKILL-MECHANICS.md`
   (harness layout); both in-body links and the file's own back-link adjusted, text verbatim.
3. Invocation unchanged from upstream (model-invoked) — the authoring-junction trigger fires
   mechanically. The delta is the description: upstream's scope statement merged with this
   harness's trigger set, the BEFORE-authoring junction, and the routing line to the installed
   skill-creator tooling.
4. Header note added: harness skill conventions win on mechanics conflicts; provenance pointer.
5. Upstream deleted its `GLOSSARY.md` (definitions absorbed into the body), so no glossary ships
   and the retired copy's glossary-pointer sentences are gone with it.
6. `agents/openai.yaml` dropped (not this harness's format).
