# Vendored provenance — wayfinder

- **Upstream**: https://github.com/mattpocock/skills (`skills/engineering/wayfinder`)
- **Version**: commit `2ab958093e83e0ec752e6c1c5932da465bf23e0c` (adapted 2026-07-30)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of the upstream skill dir (SKILL.md + `agents/openai.yaml`
  interface stub; no scripts), 2026-07-30. The adopting project keeps the analysis record in its
  own evidence store.
- **Posture**: adapted, not tracked — this copy is OUR text under OUR review; upstream changes do
  not flow in automatically.

## Adaptation delta vs upstream

1. **Handoff shape replaced**: upstream ends "map clears → to-spec collapses it". Here the map
   ends in a **synthesis brief** (a coherence pass upstream doesn't have) that the project's
   adversarial design gate (council) challenges, then absorbs into the spec's intent
   front-matter — the gate geometry this harness uses.
2. **Commitment gradient added**: map-never-locks → challenged brief → LOCKED spec, plus
   sanctioned partial early handoff of a settled slice. Upstream has no lock concept.
3. **Fog test promoted to a routing section** ("When") with the three-tier table and both
   self-corrections (grill promotes to map; fogless charting aborts) — upstream carries the
   never-for-well-scoped-features warning in its router doc (`ask-matt`), not the skill.
4. **Pre-existing-card absorption step added** to charting (three buckets: re-parent /
   block-edge / close-into) — upstream assumes a clean tracker.
5. **Upstream's "never resolve more than one ticket per session" rule dropped** — it exists for
   short-context sessions; this harness's sessions are long-lived lanes. Replaced by the
   one-decision-at-a-time chat discipline plus record-at-the-event map upkeep.
6. **Decision-packet clause added**: reserved-authority/security-posture tickets produce the
   project's owed packet; the packet's ruling resolves the ticket.
7. Setup reference (`/setup-matt-pocock-skills`), tracker-config indirection, and the
   `wayfinder:<type>` label scheme dropped — the overlay binding names the tracker concretes
   directly. `agents/openai.yaml` dropped (not this harness's format).
8. Body rewritten to this harness's voice and section conventions; upstream's load-bearing
   concepts kept by name: destination, fog of war, frontier, decision tickets, HITL/AFK, the
   four ticket types, refer-by-name, plan-don't-do, zoom-as-needed, claim-before-work.
9. Upstream ships `disable-model-invocation: true` (user-invoked); this copy is MODEL-invoked —
   the description exists so operator asks and `grilling` promotions can reach it. The drop buys
   skill-reachability at the cost of a standing description in context.
