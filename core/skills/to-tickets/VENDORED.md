# Vendored provenance — to-tickets

- **Upstream**: https://github.com/mattpocock/skills (`skills/engineering/to-tickets` +
  `skills/engineering/triage/AGENT-BRIEF.md`)
- **Version**: commit `2ab958093e83e0ec752e6c1c5932da465bf23e0c` (adapted 2026-07-30)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of both upstream sources (prose + templates, no scripts),
  2026-07-30. The adopting project keeps the analysis record in its own evidence store.
- **Posture**: adapted top file + near-verbatim brief reference — OUR copy under OUR review;
  upstream changes do not flow in automatically.

## Adaptation delta vs upstream

1. **The agent-brief comment is imported from a different upstream skill**: upstream `triage`
   posts durable agent briefs on ready-for-agent issues; upstream `to-tickets` does not. This
   adaptation grafts the brief-comment onto ticket publication — every fully-specified ticket is
   born with its contract; `references/AGENT-BRIEF.md` is
   triage's brief doc near-verbatim below an ADDED harness preamble blockquote (posted at
   publication; a durable build contract, never a substitute for a locked spec — the upstream
   `ready-for-agent`/GitHub framing is marked as upstream's). GitHub/PR examples retained as
   examples; the local-markdown tracker material was not carried.
2. Upstream's `.scratch/` layout, per-ticket file template, `ready-for-agent` label application,
   and `/setup-matt-pocock-skills` indirection dropped — the overlay binding names the tracker
   concretes. Upstream's local-files tracker branch is carried in generalized form: a no-tracker
   project publishes `NN-<slug>.md` ticket files with `Blocked by:` / `Status:` body lines,
   mirroring the sibling `wayfinder` fallback rather than upstream's layout.
3. Body-vs-comment split added (operator-facing body, machine brief in the first comment) — the
   project's board rules own the body register; upstream has no such split.
4. Step 4's quiz kept; publication explicitly gated on the operator's approval (upstream
   implies, this states). The "context is hottest now" rationale and the
   ticket-brief-vs-dispatch-brief distinction are additions.
5. Vertical-slice rules, tracer-bullet framing, expand–contract sequencing (integration-branch
   fallback included), blockers-first publication, read-body-and-comments, frontier concept,
   prototype-snippet exception: upstream substance, lightly reworded. Upstream's
   "respect ADRs in the area" line dropped — this harness's grounding ladder (governing specs +
   reference docs read before decomposition) owns that duty.
6. `agents/openai.yaml` dropped (not this harness's format).
7. Upstream ships `disable-model-invocation: true` (user-invoked); this copy is MODEL-invoked —
   reachable at spec handoffs and on the operator's file-as-tickets ask. Same
   reachability-for-context-load trade as the sibling skills, recorded here per house form.
