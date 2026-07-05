# Morning-review (consolidation kickoff) template

The controller writes this BEFORE walking through with the operator. It's the entry point if you come back after compaction or a fresh session — read it end-to-end, then walk through.

---

# <batch name> — consolidation checklist

**Date**: <DATE>
**Batch**: <batch-name>
**Origin session**: <link to the brief-authoring session or state snapshot entry>

## Context

<N> workstreams launched, each in its own lane terminal window, at <when>. Each runs as a full agent session with `/goal` applied, working in its own git worktree, and invokes its own audit-cycle before declaring the goal complete.

## Workstreams

| # | Lane tag | Worktree | Branch | Deliverables (summary) | Brief | Status report |
|---|---|---|---|---|---|---|
| <N> | <lane> | `<absolute-path>` | `<branch>` | <one-line> | `<brief-path>` | `<status-report-path>` |

All branches based on `<base-commit>`.

## Protocol (paired with the operator)

1. From the source repo: `git worktree list` — verify all <N> worktrees are still present.
2. For each lane:
   - Read the status report (consume its status word first).
   - Check the audit verdict — lock gate met, or carve-outs.
   - Open the deliverables in the worktree.
3. Walk each lane paired with the operator (suggested order: <dependency-aware order>):
   - Skim deliverables.
   - Address every inline decision-marker with the operator's call.
   - Ratify or redirect.
4. Merge ratified branches (one at a time, paired):
   - `git -C <repo> merge --no-ff <branch>` (`--no-ff` preserves the workstream as a visible feature merge).
   - After merge: `git worktree remove <worktree>` + `git branch -d <branch>`.
   - Append one line to the batch completion ledger.
5. <Cross-repo manual-apply steps if any — hand-applied paired, never auto-applied.>
6. <Convergence steps if any — e.g. "run the combined re-extraction once lanes A + B + C all merge".>
7. Update the state snapshot with the consolidation outcome.
8. Update the next-session kickoff.
9. Save memory for non-obvious decisions surfaced during consolidation.

## What to expect (per lane)

- **<Lane 1>**: <what landed; what to look for in review; specific markers to verify>
- **<Lane 2>**: <...>

## If something went wrong during the run

- **Status report missing for a lane** → the session died mid-flight. Check the lane's terminal for the last output. Resume the same `/goal` in the same worktree, or restart with an adjusted brief.
- **Worktree has uncommitted changes** → interrupted before final commit. Review via `git diff`; keep (commit) or discard.
- **Audit did not reach the lock gate** → check artifacts; fix-pass paired, or confirm the carve-out is legitimate.
- **Branch behind the default branch** → rebase the lane branch.
- **Two lanes produced conflicting outputs** → unlikely (worktree-isolated); check via `git diff` if the same file was edited.

## Hard rules during consolidation

- Do NOT merge to the default branch until the operator ratifies each lane individually.
- Apply cross-repo diff proposals only after the operator approves each diff block.
- Inline decision-markers need explicit ratification before resolving.

## Token cost retrospective

After consolidation, note approximate spend (sum across status reports) — useful for sizing future parallel passes.
