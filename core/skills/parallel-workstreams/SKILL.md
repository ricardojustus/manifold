---
name: parallel-workstreams
description: Dispatch multiple independent agent sessions in parallel — one per terminal window, each in its own git worktree, each kicked off with a `/goal` one-liner pointing at a brief you authored. Use when the operator says "parallelize", "spawn N sessions", "overnight pass", "split the work into worktrees", "I have N sessions open", or when the queue holds multiple independent heavy items AND specs are locked (not still in design) AND budget + operator terminal capacity allow it. Don't use for tactical bug fixes (overhead exceeds value), work needing mid-flight architectural decisions (use an in-session teammate you can message live), or single-lane work (one `/goal` in this terminal is enough). PAIRS with `merge-and-cleanup` for the consolidation phase after lanes return.
---

# Parallel workstreams — separate-terminal `/goal` dispatch

Each "lane" is a full agent session running in its own terminal window (any terminal multiplexer or app — the pattern is generic-terminal, not tied to a specific one). Each session:

- Loads the full project constitution (auto-import) + the project's memory/self-knowledge.
- Works in its own git worktree (isolation is a hard rule — see anti-patterns).
- Reads a brief `.md` you authored in the controller session.
- Runs `/goal` against verifiable acceptance criteria.
- Dispatches its OWN pre-merge audit (parallel reviewers, multi-round to the lock gate — see `audit-cycle`).
- Writes a status report as its final action, commits, exits.
- Survives independent of the controller session (you can compact / sleep / context-switch).

The controller session's job during dispatch is **brief-drafting + lane setup**, NOT execution supervision. Once the `/goal` one-liner is pasted into a lane window, that lane runs autonomously. Consolidation after lanes return is a **separate skill** — `merge-and-cleanup` — invoked when the status reports arrive.

## Pre-flight — is parallel right for this work?

Before authoring briefs, confirm:

1. **Specs are locked.** Architectural choices ratified; no pending decisions of substance. Lanes can surface ambiguity inline but they should not be *designing*.
2. **Lanes are independent.** Different files, different scopes, different worktree branches. If two lanes touch the same hot file, plan merge sequencing (one merges first, the other rebases) and call it out in both briefs.
3. **Budget allows it.** Each lane is a full agent context plus its own audit cycle — a substantial spend. Check quota; token spend explains most of the outcome variance, so size deliberately.
4. **The operator has terminal capacity.** Ask how many sessions they can run in parallel — that bounds the lane count.
5. **Briefs can carry verifiable acceptance criteria.** Checkbox shape (a `grep -c` count, tests pass, an audit verdict). If you can't write a verifiable check, `/goal` has nothing to gate on.

If any of these is *no*, redirect to an in-session teammate (one you can message live) or single-lane work.

## Step 1 — Set up worktrees

One worktree per lane, sibling to its source repo. The pattern is universal:

```bash
git -C <source-repo> worktree add -b <lane-branch> <worktree-path> <base-commit>
```

- **Lane tags** short + descriptive (e.g. `t1`/`t2`, or `path-c`/`refdocs`).
- **Base off a known-clean commit** — paste it explicitly so the lane doesn't pick up half-merged work.
- For dependency-heavy repos, symlink the installed-dependencies directory into the worktree to avoid a fresh install:
  ```bash
  ln -sfn <source-repo>/<deps-dir> <worktree-path>/<deps-dir>
  ```

## Step 2 — Draft briefs (invoke `brief-authoring`)

The brief is the contract the lane operates against. Per `brief-authoring` (mandatory invocation): every brief MUST have a GIVEN block + grep-verified concrete references + an ambiguity protocol + verifiable acceptance criteria.

**Brief location** — a stable path the lane can read *in its own worktree*:

- **In-worktree** (preferred): the brief lives inside the lane's own checkout (e.g. `<worktree>/<workspace-dir>/BRIEF.md`). The lane reads from its own tree — no cross-checkout dependency at execution time, and it survives compaction.
- **Shared location** (fallback): the brief lives in one canonical spot the lane reads by absolute path. Works, but creates a cross-checkout dependency.

Use `references/brief-template.md` as the starting shape. It encodes: the GIVEN block (state / locked-intent refs / **current-state docs of any live subsystem the brief touches** / tools / out-of-scope / conventions); mandatory pre-flight reads (end-to-end); a confidence gate (HALT-AND-REPORT before starting); hard constraints; numbered deliverables with target paths; discipline (the inline decision-marker rule + ambiguity protocol); an **Audit-cycle** section; a **Final status report** shape; and **Acceptance criteria** as a checkbox list.

**Include current-state docs, not just specs.** For any lane touching a live subsystem, the GIVEN block points at the current-state/reference docs — they say what the system IS RIGHT NOW versus what a spec says it WILL BE. Skipping them makes the lane re-derive live behavior. *Receipt: a lane once re-derived a subsystem's live interaction rules from specs alone because its brief pointed only at design intent, not the current-state doc.*

**Section header names are load-bearing.** The `/goal` one-liner references two headers by name — **"Audit-cycle"** and **"Acceptance criteria"**. If you rename them (to "Reviewer dispatch" / "Success criteria"), the goal prompt's gating language won't match. Keep the exact names.

**Cross-lane coordination** (when applicable): if lane A's deliverable assumes something lane C produces, bake the contract into BOTH briefs explicitly. Lanes do NOT halt-and-wait for each other — they continue with best-effort interpretation per the ambiguity protocol and tag the mismatch inline for resolution at consolidation.

## Step 3 — Hand `/goal` one-liners to the operator

Once briefs are written + committed to their lane branches, give the operator one `/goal` line per lane to paste into each lane window. Use `references/goal-oneliner-template.md` — it encodes the proven shape (entry point + worktree + branch + scope fence + the skill-suppression list + the completion gate).

The **skill-suppression list is load-bearing.** Without it, lanes reflexively invoke the session-lifecycle skills (session-start clobbers the controller's context loading; session-end clobbers the controller's state-file updates; plan-update / doc-placement / reference-doc-writing / memory-discipline are the controller's to own for the multi-lane arc). *Receipt: a first-attempt dispatch shipped goal prompts without the suppression list; lanes ran the lifecycle skills and clobbered the controller's state — caught at review.*

Label each line clearly with its lane window name (matching the worktree). Pasting the wrong line into the wrong window = wrong worktree = unmergeable state.

## Step 4 — While workstreams run

The controller session is NOT idle but also NOT supervising lanes. Use the time for architectural work the controller can do (planning, spec amendments, plan-doc updates, operator-paired ratification walks), convergence prep (if lanes merge into a combined step, pre-stage the merge order), memory saves for decisions that surface, and a cross-lane integration table (if multiple specs touch the same contract).

Don't poll status files repeatedly. Lanes surface when done. **Lane windows have no mailbox back to the controller** — each is an independent session with no inter-process channel. Cross-lane ambiguity is handled by lanes tagging the decision inline + continuing; the operator can type a directive into any lane window directly if they see a question.

## Step 5 — Consolidation

**Invoke `merge-and-cleanup`** when lanes have written their status reports. That skill owns consolidation — the operator-paired walkthrough, decision-marker resolution, `--no-ff` merges, worktree cleanup, and the state-file updates. This skill (parallel-workstreams) ends at dispatch + while-they-run.

## The dispatch handoff contract

Every lane returns through a fixed **handoff triad** — three artifacts named as **paths, never pasted inline** (paths keep the controller's context lean and the full material one hop away):

- **brief** — the contract the controller authored (Step 2).
- **report** — the lane's status writeup (`references/status-template.md`). Keep it **tight: target ~1–2k tokens.** Deliverables and audit artifacts live at their own paths; the report summarizes and points, it does not reproduce them.
- **diff-package** — the lane's committed branch (the controller reads `git diff` at consolidation), not a pasted patch.

The report opens with a **closed status word** — one of exactly four, each with a defined controller response:

| Status | Meaning | Controller response |
|---|---|---|
| `DONE` | All acceptance criteria pass; audit clean. | Verify the criteria, proceed to consolidation/merge. |
| `DONE_WITH_CONCERNS` | Criteria pass, but the lane flags a residual worry. | Read the concerns; decide whether each blocks (fix-pass) or becomes backlog. |
| `NEEDS_CONTEXT` | The lane hit an ambiguity it could not resolve from the brief. | Supply the missing context; resume the lane or re-dispatch with an augmented brief. |
| `BLOCKED` | The lane cannot proceed (missing dependency, broken precondition). | Clear the blocker, then resume or re-dispatch. |

A status word outside this set is itself a defect — the lane didn't follow the contract. The controller consumes the *word* first (it decides the next action), then the report body. The full templates for brief / report ship in `.claude/harness-templates/`; the brief-side obligations live in `brief-authoring`.

## Common failure modes during dispatch

- **Worktree-add fails** → check `git worktree list` for stale references; `git worktree prune`; verify the base commit exists.
- **Brief grep-verification finds invented code references** → a spec-confabulation. STOP; grep-verify the claims at brief-write time; correct the brief to match reality or tag the discrepancy for the operator. *Receipt: an overnight dispatch once ran three lanes against infrastructure that a spec described but the code never contained — the references were never grep-verified before the brief shipped.*
- **Cross-lane contract drift** → catch it at brief-write time by writing the cross-lane coordination table FIRST, then verifying both briefs honor it.
- **Goal prompt missing the skill-suppression list** → lanes clobber the controller's lifecycle. Always use the template.

## Anti-patterns (don't do these)

- **Don't dispatch parallel without locked specs.** Lanes designing-while-shipping produces current-state violations and confabulation.
- **Don't share a worktree across lanes.** Branch-flip races + cross-test pollution + lost commits. Hard rule. *Receipt: sharing one checkout across parallel implementers has produced a branch-flip race that silently lost a lane's commits.*
- **Don't supervise lanes from the controller session.** Once `/goal` is pasted, the lane is autonomous. Polling steals the controller's focus from the work it's supposed to do.
- **Don't tell lanes to message the controller.** Independent sessions have no inter-process mailbox; coordination is inline decision-markers + continue + resolve at consolidation. *Receipt: first-attempt briefs once instructed lanes to message the controller "immediately" on ambiguity — lanes structurally cannot.*
- **Don't put "the controller has loaded context" filler in the goal prompt.** Lanes don't care what the controller did; they need worktree + brief + goal + scope.
- **Don't omit the skill-suppression list.** (Its own receipt is above.)

## When NOT to use this skill

- **Tactical bug fix** — single-lane in-place edit; no parallel benefit.
- **Mid-flight architectural decisions** — use an in-session teammate you can message live (lane windows have no mailbox).
- **Single-deliverable work** — one `/goal` in this terminal is enough.
- **Audit on already-shipped code** — that's `audit-cycle` standalone, not a parallel dispatch.
- **Sub-30-minute work items** — brief drafting + worktree setup + consolidation overhead exceeds the value.

## Templates (this skill's `references/`)

- `references/brief-template.md` — the per-lane brief shape (the contract).
- `references/goal-oneliner-template.md` — copy-paste source for the `/goal` lines (with the skill-suppression list).
- `references/status-template.md` — the status report shape lanes write (with the closed status word).

## Related

- `brief-authoring` — MANDATORY when authoring any lane brief (GIVEN block, grep-verify, ambiguity protocol).
- `audit-cycle` — what each lane invokes for its own pre-merge lock gate.
- `merge-and-cleanup` — sibling skill; invoke for the consolidation phase after lanes return.
