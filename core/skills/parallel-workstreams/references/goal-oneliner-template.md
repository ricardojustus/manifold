# `/goal` one-liner template

Copy-paste source. One line per lane. Hand to the operator to paste into the corresponding terminal window.

The skill-suppression list is **load-bearing** — without it, lanes reflexively invoke `session-start` (clobbers the controller's context loading), `session-end` (clobbers the controller's state-file updates), and `plan-update` / `doc-placement` / `reference-doc-writing` / `memory-discipline` (the controller owns those for the multi-lane arc).

---

## Default template — spec / impl lane with audit-cycle

```
/goal Execute the brief at <ABSOLUTE-BRIEF-PATH> end-to-end. Work in <ABSOLUTE-WORKTREE-PATH> on branch <BRANCH-NAME>. Your scope is THIS LANE ONLY — do NOT invoke session-start, session-end, compact-prep, compact-resume, plan-update, doc-placement, reference-doc-writing, or memory-discipline (the controller session owns those). DO invoke audit-cycle + brief-authoring per the brief's "Audit-cycle" section. After the pre-flight reads + BEFORE drafting anything, complete the brief's "Confidence gate" (print the confidence assessment; HALT if <100% and wait for operator clarification in this terminal). Final action: full audit-cycle to the lock gate. Goal complete when all "Acceptance criteria" checkboxes in the brief pass. Surface ambiguity DURING WORK inline via the decision-marker; do not stop and wait.
```

## Variant — operator / ops lane (no audit-cycle)

For lanes whose deliverable is operator evidence, not a spec or impl (e.g. an implementation-plus-soak, a bootstrap, a migration run):

```
/goal Execute the brief at <ABSOLUTE-BRIEF-PATH> end-to-end. Work in <ABSOLUTE-WORKTREE-PATH> on branch <BRANCH-NAME>. Your scope is THIS LANE ONLY — do NOT invoke session-start, session-end, compact-prep, compact-resume, plan-update, doc-placement, reference-doc-writing, or memory-discipline (the controller session owns those). This is OPERATOR/OPS work — no spec audit-cycle. DO invoke brief-authoring if sub-dispatching. Final action: <one-sentence acceptance condition>. Goal complete when all "Acceptance criteria" checkboxes in the brief pass. Surface ambiguity inline via the decision-marker; do not stop and wait.
```

## Variant — proposal / research lane (no audit-cycle, no impl)

For lanes whose output is a research artifact or a proposal the operator reviews manually. Use sparingly — audit-cycle is the default trust gate; skip it only when the deliverable shape is "proposal for the operator to review":

```
/goal Execute the brief at <ABSOLUTE-BRIEF-PATH> end-to-end. Work in <ABSOLUTE-WORKTREE-PATH> on branch <BRANCH-NAME>. Your scope is THIS LANE ONLY — do NOT invoke session-start, session-end, compact-prep, compact-resume, plan-update, doc-placement, reference-doc-writing, or memory-discipline (the controller session owns those). Final action: write the status report per the brief's "Final status report" section. Goal complete when all "Acceptance criteria" checkboxes in the brief pass. Surface ambiguity inline via the decision-marker; do not stop and wait.
```

## Field guide

- `<ABSOLUTE-BRIEF-PATH>` — the path the lane Reads first. In-worktree convention: `<WORKTREE>/<workspace-dir>/BRIEF.md`. Shared-location convention: one canonical absolute path.
- `<ABSOLUTE-WORKTREE-PATH>` — the lane's own checkout.
- `<BRANCH-NAME>` — matches what you created with `git worktree add -b <branch>`.

## Section header names — MUST MATCH THE BRIEF

The goal prompt references two brief headers by name. The brief MUST use these exact headers or `/goal` can't find them:

- **"Audit-cycle"** — the section specifying which audits to run + dispatch discipline.
- **"Acceptance criteria"** — the `[ ]` checkbox list the goal uses to gate completion.

Don't rename them ("Reviewer dispatch" / "Success criteria") — the gating language won't match.

## Hand-off discipline

Label each line so the operator pastes the right one into the right window:

```
Window labeled "<lane-tag>" (worktree: <absolute-worktree-path>):
<goal-one-liner>
```

Publish the full set to one canonical location so it's available on the operator's other devices. Use code blocks so a triple-click selects the whole line.

## What's deliberately NOT in the goal prompt

- **"The controller has loaded context" filler.** Lanes don't care what the controller did; they need worktree + brief + goal + scope. *Receipt: first-attempt prompts once included this; flagged as irrelevant noise.*
- **"Message the controller" instructions.** Lane windows are independent sessions — no inter-process mailbox. Coordination is inline decision-markers + continue + resolve at consolidation. *Receipt: first-attempt prompts once told lanes to message the controller; lanes structurally cannot.*
- **A long contract recap.** The brief is the contract; the goal prompt is the entry point. Point at the brief; let the lane Read it.
