<!--
  handoff-triad.md — the three-artifact contract for handing work between a controller and a
  dispatched agent, plus the closed status vocabulary that makes the handoff decidable. The
  triad is passed as PATHS, not pasted text (pasting a 10k-token report into a message buries
  the signal and blows the budget): a task-brief goes down, a report + a diff-package come
  back. The report closes on ONE of four status values, each with a defined controller
  response — so "done" is never ambiguous and a blocked lane never silently stalls.
-->

# Handoff triad

## The three artifacts (passed as paths)
- **Task brief** (controller → agent) — the GIVEN block + task + ambiguity protocol + success criteria. See `BRIEF.md`. Path: `<brief path>`.
- **Report** (agent → controller) — status + what landed + verification evidence + concerns. See `STATUS.md`. Path: `<status path>`.
- **Diff package** (agent → controller) — the actual change, as a branch/worktree/commit range the controller can inspect, NOT pasted into the report. Path/ref: `<branch or commit range>`.

## The closed status vocabulary
<!-- The agent's report MUST close on exactly one. Each has a DEFINED controller response —
     that pairing is what makes the handoff a contract and not a vibe. -->

| Status | Agent means | Controller response |
|---|---|---|
| **DONE** | Complete + verified; nothing owed. | Verify the load-bearing claims (verify-what-changes-your-next-action), then merge/accept. |
| **DONE_WITH_CONCERNS** | Complete + verified, but N things flagged for your judgment. | Weigh each concern; decide fix-now vs backlog; then merge or send back with a decision. |
| **NEEDS_CONTEXT** | Did what I could; a decision/input from you unblocks the rest. | Supply the decision/input; re-dispatch the remainder. Do NOT treat as failure. |
| **BLOCKED** | Could not proceed; blocker stated. | Resolve the blocker (or reroute the work); the lane did right by stopping, not guessing. |

## Rules
- The agent NEVER self-adjudicates a status it's unsure of — when between DONE and DONE_WITH_CONCERNS, pick the more cautious one and list the concern.
- The controller VERIFIES a DONE before relaying it upstream (a report describes what the agent *intended*, not always what *landed*).
- A tiny/stalled report is a re-dispatch trigger, not a verdict — an empty transcript is not "DONE".
