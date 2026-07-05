# Workstream status report template

The lane writes this as its final action before `/goal` completes. The controller reads it during consolidation.

**Keep it tight — target ~1–2k tokens.** The report *summarizes and points*; deliverables and audit artifacts live at their own paths, not pasted in.

---

# Workstream status — <lane tag>

**Status**: `DONE` | `DONE_WITH_CONCERNS` | `NEEDS_CONTEXT` | `BLOCKED`
**Date**: <DATE>
**Lane**: <lane-tag>
**Branch**: `<branch-name>`
**Worktree**: `<absolute-worktree-path>`
**Brief**: `<absolute-brief-path>`

> The status word is the first thing the controller consumes — it decides the next action:
> `DONE` → verify criteria, merge · `DONE_WITH_CONCERNS` → triage the concerns below ·
> `NEEDS_CONTEXT` → supply the missing context, resume/re-dispatch · `BLOCKED` → clear the blocker, resume/re-dispatch.

## Summary

<One paragraph. What landed. Headline outcomes. Any unexpected discovery during the lane's work.>

## Deliverables

| # | Path | Lines / Tests | Notes |
|---|------|---------------|-------|
| 1 | `<relative-path>` | <count> | <one-line note> |
| 2 | `<relative-path>` | <count> | <one-line note> |

## Concerns / blockers (if status is not plain `DONE`)

<For DONE_WITH_CONCERNS: each residual worry + why it doesn't block. For NEEDS_CONTEXT: the exact ambiguity + what you assumed to keep moving. For BLOCKED: the missing dependency / broken precondition + what would unblock it.>

## Decision-markers raised (if any)

| Deliverable | Where | Decision | Tentative pick |
|---|---|---|---|
| <file> | §<n> | <one-line> | <option> |

**Total**: <N> markers across <M> deliverables.

## Audit-cycle outcome

- **Rounds**: R1 (<verdict>) → R2 (<verdict>) → ... → final R<N> (<lock-gate met | carve-outs>)
- **Artifacts**: `<audit-artifact-path>` per round.
- **Carve-outs (if any)**: <residual findings + why each is a legitimate operator-decision>.

## Acceptance criteria (mirror of brief — paste with [x])

- [x] <criterion from brief>
- [x] <criterion>
- [ ] <criterion — uncheck if NOT met + explain in Concerns above>

## What the controller needs to know

<Anything specific for consolidation — e.g. "cross-refs another lane; merge that one first" or "found a defect at `<file>:line` out of scope; should be filed" or "architectural concern for a future phase".>

## Commit hashes

- `<hash>` — <subject>
- `<hash>` — <subject>
