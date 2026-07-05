---
name: merge-and-cleanup
description: Consolidate parallel-lane workstreams after they return — walk each lane's deliverables paired with the operator, resolve the inline decision-markers, merge ratified branches via `git merge --no-ff` (preserves lane history), clean up worktrees + delete branches, update the state / kickoff / open-items files, and save memory for non-obvious decisions. Use when the operator says "consolidate", "merge the lanes", "wrap up the parallel work", "/merge-and-cleanup", or when the lanes' status reports have arrived. Sibling to `parallel-workstreams` (which dispatches the lanes; this consolidates after they return). NOT for single-branch merges (use the normal git workflow) or mid-flight lane intervention (lanes are autonomous until they return a status report).
---

# Merge-and-cleanup — consolidate parallel-lane workstreams

Sibling to `parallel-workstreams`. That skill dispatches lanes; this one consolidates them after they return status reports. They're separated because dispatch and consolidation are distinct cognitive moments with different action sets.

The principle: **lanes finish autonomously; consolidation is always paired with the operator.** No lane merges to the default branch without the operator's explicit ratification, even if its audit returned clean. **The audit clears the technical bar; the operator clears the architectural-fit bar.**

## When to invoke

**In scope**:
- The operator says "consolidate" / "merge the lanes" / "wrap up the parallel work" / "/merge-and-cleanup".
- All (or some) dispatched lanes have written their status reports + committed + exited. Partial consolidation is fine — merge what's ready, revisit the rest when they return.
- Post-compaction restart of an in-progress consolidation (read the morning-review file from Step 1 to resume).

**Out of scope**:
- Single-branch merge to the default branch → the normal git workflow.
- Mid-flight lane intervention → lanes are autonomous; to redirect one, edit its brief + restart its `/goal`, don't intervene mid-execution.
- Re-running an audit → the lanes already invoked `audit-cycle`; you're checking the verdict, not re-auditing — unless consolidation surfaces an *integration* concern the per-lane audits couldn't see, in which case dispatch a fresh `audit-cycle` on the merged state.

## Pre-flight — what to check before starting

1. **All status reports present.** A missing report means the lane is still running or died mid-flight — check its terminal window; resume the same `/goal` in the same worktree, or restart with an adjusted brief.
2. **Worktrees still present** — `git -C <repo> worktree list`. Stale entries (gone from disk but still tracked) need `git worktree prune` first.
3. **No accidental commits on the default branch** between dispatch + return — if it advanced, lane branches need `git rebase` onto it before merge.
4. **Lane status reports committed** — uncommitted changes in a worktree mean the lane was interrupted before its final commit. Read carefully + decide (commit or discard) paired with the operator.

## Step 1 — Write the morning-review file (consolidation kickoff)

Write the morning-review file using `references/morning-review-template.md` as the shape. This is the **entry point** if you come back after compaction or a fresh session — read it end-to-end, then walk through with the operator.

It lists each lane (table: lane tag / worktree / branch / brief / status-report path / one-line deliverable summary), names the **merge order** (dependency-aware — whoever produces a shared artifact ships first), gives per-lane "what to expect", includes a cross-lane integration table (if lanes touched the same contract), and an "if something went wrong" recovery branch.

Commit the morning-review file to the main repo (NOT a lane branch) — it's the controller's consolidation artifact.

## Step 2 — Walk each lane paired with the operator

Per the morning-review's merge order, for each lane in sequence:

1. **Read the status report** end-to-end. Consume its **status word first** (`DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` / `BLOCKED`) — it decides the next action before you read the body.
2. **Check the audit verdict** — lock gate met on both lenses, OR legitimate carve-outs. If it didn't clear: check artifacts; fix-pass paired with the operator, or confirm the carve-out is legitimate.
3. **Skim the deliverables** — `git -C <worktree-path> diff <default-branch>..HEAD`.
4. **Address every inline decision-marker** with the operator's call. Each is a quick paired decision; don't pre-resolve.
5. **Ratify or redirect**:
   - **Ratify** → proceed to merge (Step 3).
   - **Redirect** → a fix-pass: another `/goal` in the same worktree with an adjusted brief, OR a controller-session edit on the lane branch (paired), OR a cross-repo manual apply (hand-applied paired, NEVER auto-applied).
6. **Cross-lane integration check** (if multiple lanes touched the same contract): before merging, verify the contracts align — same field name/type/nullability, same function signature, same path/convention. If drift is found, tag it in the morning-review file and resolve paired BEFORE merging.

## Step 3 — Merge ratified branches (sequential, `--no-ff`)

For each ratified branch, in the specified order:

```bash
git -C <repo> checkout <default-branch>
git -C <repo> merge --no-ff <lane-branch>
```

**Why `--no-ff`**: it preserves the workstream as a visible feature merge in `git log`. A fast-forward merge erases the lane's identity in history; `--no-ff` produces a merge commit that names the lane explicitly.

After each merge, verify cleanliness before the next lane: tests pass, typecheck clean, no ignored files committed, no `WIP`/`tmp`/`debug` left in messages. If post-merge checks fail — cross-lane integration issue, a lane that assumed pre-merge state, or environmental drift — investigate paired with the operator BEFORE merging the next lane. Don't ship a known-broken intermediate state.

**Rebase if needed**: if the default branch advanced since the lane branched, rebase the lane onto it before merging. If the rebase conflicts, resolve paired with the operator (conflict resolution is judgment work; don't auto-resolve).

## Step 4 — Cleanup + completion ledger

After each successful, verified-clean merge:

```bash
git -C <repo> worktree remove <worktree-path>
git -C <repo> branch -d <lane-branch>
```

**`-d` (lowercase), never `-D`.** Lowercase `-d` refuses to delete a branch that isn't merged — a safety net against killing unmerged work. If `-d` refuses, INVESTIGATE; don't escalate to `-D` (force) without a paired operator review.

**Append one line to the batch completion ledger** — an append-only record, one line per verified-clean lane merge:

```
<DATE> · <batch> · <lane-tag> · merged <merge-SHA> · audit <verdict> · clean
```

The ledger is the at-a-glance answer to "which lanes actually landed and when" across a multi-lane arc — cheaper to scan than reconstructing it from `git log`, and it survives compaction. One line, appended, never rewritten.

Leave the dispatch artifacts (goal-prompts file, the briefs committed to lane branches) in place — they're part of the historical record.

## Step 5 — Update state docs + memory

After ALL lanes for the batch have merged:

1. **State snapshot** — update with merge outcomes; move the active-workstream summary to "shipped" + reference the merge SHAs; seed the next workstream if one surfaced.
2. **Next-session kickoff** — write the next directive (stable filename; replace prior content, don't accumulate dated blocks).
3. **Open-items** — add anything that surfaced but wasn't in scope to close (deferrals, follow-ups, observed-but-not-fixed defects).
4. **Memory** — invoke `memory-discipline` for non-obvious decisions: a mid-consolidation architectural ratification, feedback affecting future dispatch, a cross-lane integration pattern that worked or didn't, a token-spend retrospective.
5. **Lessons** — if a hard-won lesson landed (failure mode caught, recovery pattern proven), write it to the lessons store (Problem / Root cause / Solution / Sources / Date).
6. **Task-audit log** — append an entry naming the batch + lanes merged + spend estimate + any flagged follow-ups.

## Common failure modes during consolidation

- **Status report missing** → lane died mid-flight. Check its terminal window; resume the same `/goal` in the same worktree, or restart with an adjusted brief.
- **Worktree has uncommitted changes** → lane interrupted before final commit. Read `git diff`; keep (commit) or discard, paired.
- **Audit didn't reach the lock gate** → check artifacts; fix-pass paired, or confirm carve-outs are legitimate.
- **Two lanes touched the same file** → unlikely with worktree isolation; resolve via sequential merge + rebase; non-trivial conflicts, paired.
- **Branch behind the default branch** → rebase before merging (Step 3).
- **Post-merge checks fail** → investigate paired BEFORE merging the next lane.
- **Cross-lane contract drift found at consolidation** (not caught earlier) → tag it in the morning-review; resolve paired; fix-pass one lane to align, or accept the drift with a documented disposition.

## Anti-patterns (don't do these)

- **Don't merge a lane the operator hasn't ratified.** Even at a clean audit, consolidation is paired — the operator calls every decision-marker before merge. The audit gate is necessary, not sufficient.
- **Don't auto-apply cross-repo diff proposals.** Hand-apply paired; cross-repo state is high-blast-radius.
- **Don't skip the morning-review file.** Coming back after compaction, it's your starting point; without it, consolidation re-derives state and wastes the operator's time.
- **Don't merge without `--no-ff`.** Fast-forward erases the lane's identity in `git log`.
- **Don't force-delete branches (`-D`) without operator review.** `-d` refuses if unmerged — that net exists for a reason.
- **Don't skip memory saves.** Mid-consolidation decisions, integration patterns, operator corrections — all durable signal.

## Templates (this skill's `references/`)

- `references/morning-review-template.md` — the consolidation-kickoff file the controller writes before walking through with the operator.

(The status-report template lives in the sibling `parallel-workstreams` skill, since lanes — not the controller — write status reports.)

## Related

- `parallel-workstreams` — sibling skill that dispatches; this one consumes its output (status reports).
- `brief-authoring` — referenced by lane briefs; consolidation verifies briefs followed it.
- `audit-cycle` — each lane invoked it; consolidation verifies the verdict; doesn't re-run unless an integration concern surfaces.
- `memory-discipline` — invoke in Step 5 if non-obvious decisions surfaced.
- `session-end` — the controller may invoke it after consolidation IF this closes the session; if the next arc starts immediately, defer it.
