---
name: parallel-workstreams
description: >-
  Dispatches multiple independent agent sessions in parallel — one terminal window and git worktree each, kicked off by a `/goal` one-liner pointing at an authored brief. Use on "parallelize", "spawn N sessions", "split the work into worktrees", once specs are locked. Pairs with merge-and-cleanup for consolidation.
---

# Parallel workstreams — separate-terminal `/goal` dispatch

Each "lane" is a full agent session in its own terminal window (any multiplexer or app — the
pattern is generic-terminal). Each session: loads the project constitution + memory; works in its
own git worktree (hard rule); reads a brief `.md` you authored; runs `/goal` against verifiable
acceptance criteria; dispatches its OWN pre-merge audit (see `audit-cycle`); writes a status
report as its final action, commits, exits; and survives independent of the controller session.

The controller's job during dispatch is **brief-drafting + lane setup**, NOT execution
supervision. Once the `/goal` one-liner is pasted into a lane window, that lane runs autonomously.
Consolidation after lanes return is a **separate skill** — `merge-and-cleanup`.

## Pre-flight — is parallel right for this work?

1. **Specs are locked.** Architectural choices ratified; no pending decisions of substance. Lanes
   may surface ambiguity inline but should not be *designing*.
2. **Lanes are independent.** Different files, scopes, worktree branches. If two lanes touch the
   same hot file, plan merge sequencing (one merges first, the other rebases) and say so in BOTH
   briefs.
3. **Budget allows it.** Each lane is a full agent context plus its own audit cycle. Check quota;
   token spend explains most outcome variance, so size deliberately.
4. **The operator has terminal capacity.** Ask how many sessions they can run — that bounds the
   lane count.
5. **Briefs can carry verifiable acceptance criteria.** Checkbox shape (a `grep -c` count, tests
   pass, an audit verdict). No verifiable check → `/goal` has nothing to gate on.

If any is *no*, redirect to an in-session teammate (messageable live) or single-lane work.

## Step 1 — Set up worktrees

One worktree per lane, sibling to its source repo:

```bash
git -C <source-repo> worktree add -b <lane-branch> <worktree-path> <base-commit>
```

- **Lane tags** short + descriptive (`t1`/`t2`, or `path-c`/`refdocs`).
- **Base off a known-clean commit** — paste it explicitly so the lane doesn't pick up half-merged
  work.
- Dependency-heavy repos: symlink the installed-dependencies directory to avoid a fresh install:
  ```bash
  ln -sfn <source-repo>/<deps-dir> <worktree-path>/<deps-dir>
  ```

## Step 2 — Draft briefs (invoke `brief-authoring`)

Per `brief-authoring` (mandatory invocation): every brief MUST have a GIVEN block +
grep-verified concrete references + an ambiguity protocol + verifiable acceptance criteria.

**Brief location** — a stable path the lane can read *in its own worktree*:

- **In-worktree** (preferred): the brief lives inside the lane's own checkout (e.g.
  `<worktree>/<workspace-dir>/BRIEF.md`) — no cross-checkout dependency at execution time, and it
  survives compaction.
- **Shared location** (fallback): one canonical spot the lane reads by absolute path. Works, but
  creates a cross-checkout dependency.

Use `references/brief-template.md` as the starting shape. It encodes: the GIVEN block (state /
locked-intent refs / **current-state docs of any live subsystem the brief touches** / tools /
out-of-scope / conventions); mandatory pre-flight reads (end-to-end); a confidence gate
(HALT-AND-REPORT before starting); hard constraints; numbered deliverables with target paths;
discipline (inline decision-marker rule + ambiguity protocol); an **Audit-cycle** section; a
**Final status report** shape; and **Acceptance criteria** as a checkbox list.

**Include current-state docs, not just specs** for any lane touching a live subsystem — they say
what the system IS RIGHT NOW versus what a spec says it WILL BE.

**Section header names are load-bearing.** The `/goal` one-liner references **"Audit-cycle"** and
**"Acceptance criteria"** by name; renaming them breaks its gating language.

**Cross-lane coordination** (when applicable): if lane A's deliverable assumes something lane C
produces, bake the contract into BOTH briefs explicitly. Lanes do NOT halt-and-wait for each
other — they continue with best-effort interpretation per the ambiguity protocol and tag the
mismatch inline for resolution at consolidation.

## Step 3 — Hand `/goal` one-liners to the operator

Once briefs are written + committed to their lane branches, give the operator one `/goal` line per
lane. Use `references/goal-oneliner-template.md` — it encodes the proven shape (entry point +
worktree + branch + scope fence + the skill-suppression list + the completion gate).

The **skill-suppression list is load-bearing.** Without it, lanes reflexively invoke the
session-lifecycle skills (session-start clobbers the controller's context loading; session-end
clobbers its state-file updates; plan-update / doc-placement / reference-doc-writing /
memory-discipline are the controller's to own for the multi-lane arc).

Label each line clearly with its lane window name (matching the worktree). Pasting the wrong line
into the wrong window = wrong worktree = unmergeable state.

## Step 4 — While workstreams run

The controller is NOT idle but also NOT supervising. Use the time for architectural work it can do
(planning, spec amendments, plan-doc updates, operator-paired ratification walks), convergence prep
(pre-stage the merge order), memory saves for decisions that surface, and a cross-lane integration
table (if multiple specs touch the same contract).

Don't poll status files repeatedly — lanes surface when done. **Lane windows have no mailbox back
to the controller**; cross-lane ambiguity is handled by lanes tagging the decision inline +
continuing, and the operator can type a directive into any lane window directly.

## Step 5 — Consolidation

**Invoke `merge-and-cleanup`** when lanes have written their status reports. That skill owns the
operator-paired walkthrough, decision-marker resolution, `--no-ff` merges, worktree cleanup, and
state-file updates. This skill ends at dispatch + while-they-run.

## The dispatch handoff contract

Every lane returns through a fixed **handoff triad** — three artifacts named as **paths, never
pasted inline**:

- **brief** — the contract the controller authored (Step 2).
- **report** — the lane's status writeup (`references/status-template.md`). Keep it **tight:
  target ~1–2k tokens**; it summarizes and points, it does not reproduce deliverables or audit
  artifacts.
- **diff-package** — the lane's committed branch (the controller reads `git diff` at
  consolidation), not a pasted patch.

The report opens with a **closed status word** — one of exactly four:

| Status | Meaning | Controller response |
|---|---|---|
| `DONE` | All acceptance criteria pass; audit clean. | Verify the criteria, proceed to consolidation/merge. |
| `DONE_WITH_CONCERNS` | Criteria pass, but the lane flags a residual worry. | Read the concerns; decide whether each blocks (fix-pass) or becomes backlog. |
| `NEEDS_CONTEXT` | The lane hit an ambiguity it could not resolve from the brief. | Supply the missing context; resume the lane or re-dispatch with an augmented brief. |
| `BLOCKED` | The lane cannot proceed (missing dependency, broken precondition). | Clear the blocker, then resume or re-dispatch. |

A status word outside this set is itself a defect. The controller consumes the *word* first, then
the report body. Full brief/report templates ship in `.claude/harness-templates/`; the brief-side
obligations live in `brief-authoring`.

## Common failure modes during dispatch

- **Worktree-add fails** → check `git worktree list` for stale references; `git worktree prune`;
  verify the base commit exists.
- **Brief grep-verification finds invented code references** → a spec-confabulation. STOP;
  grep-verify at brief-write time; correct the brief or tag the discrepancy for the operator.
- **Cross-lane contract drift** → catch it at brief-write time: write the cross-lane coordination
  table FIRST, then verify both briefs honor it.
- **Goal prompt missing the skill-suppression list** → lanes clobber the controller's lifecycle.

## Anti-patterns (don't do these)

- **Don't dispatch parallel without locked specs** — designing-while-shipping produces
  current-state violations and confabulation.
- **Don't share a worktree across lanes** — branch-flip races, cross-test pollution, lost commits.
  Hard rule.
- **Don't supervise lanes from the controller session** — once `/goal` is pasted the lane is
  autonomous; polling steals the controller's focus.
- **Don't tell lanes to message the controller** — independent sessions have no inter-process
  mailbox; coordination is inline decision-markers + continue + resolve at consolidation.
- **Don't put "the controller has loaded context" filler in the goal prompt** — lanes need worktree
  + brief + goal + scope.
- **Don't omit the skill-suppression list.**

## When NOT to use this skill

Tactical bug fix (single-lane in-place edit) · mid-flight architectural decisions (use an
in-session teammate you can message live) · single-deliverable work (one `/goal` here is enough) ·
audit on already-shipped code (`audit-cycle` standalone) · sub-30-minute items (setup +
consolidation overhead exceeds the value).

## Templates (`references/`) + related skills

- `references/brief-template.md` — the per-lane brief shape (the contract).
- `references/goal-oneliner-template.md` — the `/goal` lines (with the skill-suppression list).
- `references/status-template.md` — the status report shape lanes write.
- `brief-authoring` (MANDATORY for any lane brief) · `audit-cycle` (each lane's own lock gate) ·
  `merge-and-cleanup` (the consolidation phase after lanes return).
