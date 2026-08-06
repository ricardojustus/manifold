<!--
  ADR.md — Architecture Decision Record. One record per settled decision, in `adr/` at the root
  of the repo the decision constrains. Filename `NNNN-slug.md`: a 4-digit zero-padded sequence
  plus a slug stating the decision (`0007-sandbox-via-seatbelt.md`). A repo that already has an
  `adr/` keeps its existing files untouched — a new record takes the next unused number.

  WHAT EARNS A RECORD: a decision that CONSTRAINS FUTURE BUILDERS — nothing else. A record states
  what was DECIDED and WHY, never what the code does now; the code answers current-behaviour
  questions, so a record that has drifted must still not read as current-code truth. The
  high-value section is REJECTED ALTERNATIVES — the one-line cause of death is what stops a
  future session re-opening a settled call.

  NOT AN ADR: implementation detail inside a live spec · operational facts · a constraint
  discovered while debugging (that goes in a CODE COMMENT, next to what it constrains) ·
  anything with no rejected alternative · facts about the operator's world (those stay in the
  memory system, which remains authoritative for them). One decision per record, a screen or
  less.

  IMMUTABLE: records are history. Superseding a decision writes a NEW record and flips the old
  one's `Decision status` to `superseded-by NNNN` — the old body stays as written, never
  rewritten. The chain of records IS the history.
-->

# {decision title — the choice itself, stated plainly}

- **Decision status:** proposed | accepted | superseded-by NNNN
- **Implementation status:** not-started | in-progress | live
- **Date:** YYYY-MM-DD

## Context and problem statement
{2–3 sentences: the forces at play, what made this a real decision.}

## Decision
{What was decided, imperative, plainly stated.}

## Consequences
* Good, because {…}
* Bad, because {…}

## Rejected alternatives
* **{alternative}** — {one-line cause of death}.
