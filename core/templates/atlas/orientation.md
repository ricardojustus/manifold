<!--
  orientation.md — one per repo, at `atlas/orientation.md`. It carries the four kinds of truth no
  parser can derive: how things FLOW, where the SEAMS bite, which ENTRY POINTS matter, and who
  OWNS what. Everything box-internal belongs in the code.

  LITMUS: a line with no arrow, no warning, and no pointer is regrown prose — cut it.

  CAP: 150 lines, hard. Raising it is the operator's call, never the agent's.

  OVERFLOW: the session that pushes the file over brings it back under IN THE SAME ARC —
  relocate, don't compress. Box-internal prose → the code. Mechanical listings → delete. Whys →
  `adr/`. If nothing can honestly go, the cap question goes to the operator.

  AUTHORING: written ONCE, at onboarding or when Atlas is enabled — one sitting, at most 150
  lines, and the operator skims the result. It stays current by event: the arc that moves an
  arrow updates the line, and session-end asks whether anything moved.

  HOP ZERO: wire the project's always-loaded context file (CLAUDE.md) to point here — an
  @-import where the project uses them, otherwise one pointer line. A project with NO
  always-loaded context file SKIPS this wire: there, discovery is the root-visible `atlas/`
  directory.

  EMPTY START: Enabling Atlas never creates `adr/`. Where it does not exist, it appears at the first
  real decision, and the Boundaries or Seams line that needs a "why" points at the record that
  carries it. A repo that ALREADY has an `adr/` keeps those files untouched — new records take
  the next unused 4-digit ID.
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
