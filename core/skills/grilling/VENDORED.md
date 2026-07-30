# Vendored provenance — grilling

- **Upstream**: https://github.com/mattpocock/skills (`skills/productivity/grilling` +
  `skills/productivity/grill-me`)
- **Version**: commit `2ab958093e83e0ec752e6c1c5932da465bf23e0c` (adapted 2026-07-30)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of both upstream skill dirs (two SKILL.md prompt texts + two
  `agents/openai.yaml` interface stubs; no scripts), 2026-07-30. The adopting project keeps the
  analysis record in its own evidence store.
- **Posture**: adapted, not tracked — this copy is OUR text under OUR review; upstream changes do
  not flow in automatically.

## Adaptation delta vs upstream

1. Merged `grill-me` (a user-invoked 3-line wrapper) into the one `grilling` skill — upstream's
   split adds no capability in this harness (a described skill is both operator- and
   skill-reachable). The merge DROPS upstream `grill-me`'s `disable-model-invocation: true`
   restriction: there is no non-auto-invocable alias here.
2. Dropped both upstream `agents/openai.yaml` files (OpenAI-agent interface stubs; not part of
   this harness's skill format).
3. Rewrote the whole text from the operator's first person ("Interview me… the decisions are
   mine") to this harness's second-person imperative with headed sections — the largest textual
   delta; the five behavioral invariants survive verbatim in substance.
4. Added the capture rule (settled decisions filed at the event — this harness's equivalent of
   upstream `grill-with-docs`, whose doc-capture rides the always-on memory discipline instead of
   CONTEXT.md/ADR files), the exit rule (alignment, never authorization — hands off to the
   project's gates; reserved calls still owe their decision packet), and the dependency-sequencing
   instruction (upstream implies it via "resolving dependencies").
5. Routing lines to `brainstorming` and `council` in the description (harness neighbors).

Everything else preserves upstream's behavioral core: one question at a time · recommended answer
per question · facts looked up, not asked · decisions are the operator's · no action until
confirmed shared understanding.
