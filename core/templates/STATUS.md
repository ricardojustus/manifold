<!--
  STATUS.md — the status report a dispatched lane returns when it finishes (or blocks).
  The consolidation phase reads these from all lanes. It closes on ONE of the four status
  values from the handoff vocabulary (see handoff-triad.md): DONE / DONE_WITH_CONCERNS /
  NEEDS_CONTEXT / BLOCKED. Keep it tight — the point is a decidable handoff, not a transcript.
  Paths are ABSOLUTE (the reader is in a different worktree).
-->

# Status — <lane/task> — <YYYY-MM-DD>

## Status: <DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED>
<!-- DONE: complete + verified, nothing owed.
     DONE_WITH_CONCERNS: complete + verified, but I'm flagging N things the consolidator
       should weigh (each listed below).
     NEEDS_CONTEXT: I did what I could but a decision/input from the dispatcher unblocks the rest.
     BLOCKED: I could not proceed; the blocker is stated below. -->

## What landed
<!-- The deliverables, as absolute paths + commit refs. -->
- <path> — <what it is> — <commit ref>

## Verification
<!-- The evidence, not the claim. Paste the test/typecheck/probe result, don't assert it. -->
- <command run> → <result>

## Concerns / open items (if DONE_WITH_CONCERNS or NEEDS_CONTEXT)
<!-- Each: what it is, why it's not resolved, what the consolidator should decide. -->
- <concern> — <why unresolved> — <what's needed>

## Blocker (if BLOCKED)
<!-- The exact blocker + what would unblock it. -->
- <blocker> — <what unblocks it>

## Decisions parked for ratification
<!-- Cross-link to the DECISIONS log entries made this run. -->
- ↔ D-NNN — <one-line summary>
