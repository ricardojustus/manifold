<!--
  orientation.md — one per repo, at `atlas/orientation.md`: how things FLOW, where the SEAMS bite,
  which ENTRY POINTS matter, who OWNS what. Box-internal detail belongs in the code.

  LITMUS: a line with no arrow, no warning, and no pointer is regrown prose — cut it.

  CAP: 150 lines, hard. Raising it is the operator's call, never the agent's.

  OVERFLOW: the session that pushes it over brings it back under IN THE SAME ARC — relocate, don't
  compress (prose → the code; listings → delete; whys → `adr/`); nothing can go → ask the operator.

  AUTHORING: written ONCE, one sitting, at onboarding or when Atlas is enabled; current by event —
  the arc that moves an arrow updates the line, session-end asks whether anything moved.

  HOP ZERO: wire the always-loaded context file (CLAUDE.md) to point here — @-import, else one
  pointer line; no such file → skip the wire, discovery is the root-visible `atlas/` directory.

  EMPTY START: enabling Atlas never creates `adr/` — it appears at the first real decision, the
  Boundaries/Seams line needing a "why" points at the record; an existing `adr/` stays untouched,
  new records take the next unused 4-digit ID.
-->

# {project} — orientation

## Flows
{Arrow-level, each arrow naming its file. `http webhook → src/api/router.ts → job queue →
src/worker/spawn.ts`. One flow per bullet; the arrows are the content.}

## Seams
{Non-obvious couplings that bite: what breaks over there when you change this here, and why the
grep does not show it.}

## Entry points
{A handful per subsystem — the file you open first, one line of role each.}

## Boundaries
{Which repo, process, or service owns what — and what is therefore NOT ours to edit.}
