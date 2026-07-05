# Workstream brief template

Replace `<...>` placeholders. Drop sections that don't apply (e.g. omit "Test surface" for doc-drafting lanes).

---

# Workstream brief — <lane tag>: <one-line mission>

**Created**: <DATE>
**Branch**: `<lane-branch-name>`
**Worktree**: `<absolute-worktree-path>`
**Source repo**: `<repo>`
**Base commit**: `<commit-hash>` (paste explicitly so the lane doesn't drift)
**Identity**: workstream lane. Full project context auto-loaded via the constitution.

## Mission

<One paragraph. What the lane is shipping + why it matters + which queued item it closes.>

## GIVEN (per brief-authoring)

- **Current system state**: <what's running, what's locked, what's pending — be specific>.
- **Locked references** (the brief points; the lane does NOT re-derive):
  - `<spec-path>` LOCK <version-tag> — <one-line summary of what it governs>
  - `<plan-doc-path>` — <relevant sections>
- **Current-state docs** (for any live subsystem this lane touches): `<reference/current-state doc paths>` — what the system IS RIGHT NOW.
- **Tools available**: <file paths / commands / tools the lane can use>.
- **Out of scope explicitly** (❌ list): <what NOT to touch / extend / refactor>.
- **Conventions**: <paths to convention docs to honor>.

## Pre-flight reads (mandatory, end-to-end)

1. `<file-path>` — <one-line why-this-matters>
2. `<file-path>` — <one-line why-this-matters>
3. ...

Read SECTIONS end-to-end — don't reconstruct from grep fragments.

## Confidence gate (HALT-AND-REPORT before starting work)

After the pre-flight reads + BEFORE drafting anything, print to the terminal:

**Confidence: <0–100%> in assignment understanding.**

If <100%, list:
- **Clarifications needed** — specific questions the operator should answer before you start.
- **Divergent ideas** — be opinionated; name what YOU think + why it differs from the brief.

If 100%, print "Confidence: 100% — proceeding" and continue.

If <100%, **HALT** and wait for the operator to type clarification in this terminal window. Do NOT proceed on assumptions. Cost of waiting < cost of building the wrong thing. (This fires ONCE, after reads, before any work — distinct from the inline decision-marker pattern, which fires DURING work and continues.)

## Hard constraints

- ❌ Do NOT modify files outside `<absolute-worktree-path>`.
- ❌ Do NOT call the project's memory-write tool. (The controller captures memory.)
- ❌ Do NOT modify state files or plan docs unless explicitly in the deliverables.
- ❌ Do NOT commit to the default branch.
- ❌ Do NOT LOCK specs. Specs in this lane are DRAFTS unless the brief says otherwise.
- ❌ <other lane-specific hard constraints>

## Deliverables

Sequential. One at a time. Each numbered, each with a target output path + structure.

### Deliverable 1: <name>

Output: `<target-relative-path>`

<Section structure / content shape / test surface if impl.>

### Deliverable 2: <name>

Output: `<target-relative-path>`

<...>

## Discipline

- Every architectural choice needing operator judgment → tag it inline with the project's decision-marker (options + tentative pick + one-line rationale). Do NOT force-resolve.
- Surface ambiguity inline — never silently scope out.
- Use the project's conventions (section structure, naming, tone).
- Cross-reference between deliverables where one depends on another.
- Goal: "the operator can read the deliverables and ratify or redirect each decision."

## Audit-cycle (full — parallel reviewers, multi-round to the lock gate)

After all deliverables are committed, invoke `audit-cycle`. Target: <all deliverables together | per-deliverable>.

Dimensions to enforce explicitly:
- <dimension 1 — e.g. "all deliverable files exist at canonical paths">
- <dimension 2>
- <dimension 3>

Iterate round 1 → fix-pass → round 2 until the lock gate is met OR all residual findings are tagged as decisions for the operator.

Audit artifacts at `<audits-dir>/<batch>-<lane>-round-<N>.md` per round.

## Final status report

Write to `<status-report-path>`. Use `references/status-template.md` as the shape. Open with the closed status word (`DONE` / `DONE_WITH_CONCERNS` / `NEEDS_CONTEXT` / `BLOCKED`). Keep the report tight (~1–2k tokens) — deliverables + audit artifacts live at their paths, not pasted in.

Commit. Goal complete.

## Acceptance criteria

Goal met when (run from `<absolute-worktree-path>`):

- [ ] <verifiable check — e.g. "all deliverable files exist at specified paths, committed">
- [ ] <verifiable check — e.g. "grep -c '<marker>' <file> >= N">
- [ ] <verifiable check — e.g. "tests pass; typecheck clean">
- [ ] <verifiable check — e.g. "status report exists at path, committed">
- [ ] <verifiable check — e.g. "audit verdict meets the lock gate OR residuals tagged for the operator">
- [ ] <verifiable check — e.g. "diff against the default branch touches no out-of-scope files">

Every criterion must be checkable without judgment. `/goal` uses this list to gate completion.
