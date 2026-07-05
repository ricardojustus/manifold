<!--
  completion-ledger.md — an append-only record of completed units of work across a multi-lane
  or multi-chunk effort. Distinct from JOURNAL (one thread's narrative) and STATUS (one lane's
  hand-back): the ledger is the CONSOLIDATED, durable "what's done and verified" across the
  whole effort, written as chunks/lanes land and merge. It's the instrument the consolidation
  phase and the operator read to know the true state of a large build. Append-only: entries
  are added as work completes and never rewritten (a reversal is a NEW entry, not an edit).
-->

# Completion ledger — <effort/phase>

_Append-only. One row per completed unit, in the order it landed + verified + merged._

| # | Unit (chunk/lane) | Landed | Verified (evidence) | Merged (ref) | Status | Notes |
|---|---|---|---|---|---|---|
| 1 | <chunk name> | <YYYY-MM-DD> | <tests/probe result> | <commit/merge ref> | DONE / DONE_WITH_CONCERNS | <parked ratifications, backlog ids> |

<!-- Status uses the handoff vocabulary (see handoff-triad.md). A DONE_WITH_CONCERNS row
     carries its concern ids so nothing flagged is lost at consolidation. A reversal or
     rework is a new appended row referencing the one it supersedes — never an in-place edit,
     so the ledger stays a true history. -->

## Open against the ledger
<!-- Units still in flight or not yet started, for at-a-glance completeness. Move them into
     the table above when they land. -->
- <unit> — <status: in-flight / not-started / blocked-on-X>
