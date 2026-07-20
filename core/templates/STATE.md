<!--
  STATE.md — the live snapshot. Read at session start, updated at session end.
  RULE: current-state + pointers ONLY. STATE is an INDEX, not the document — each line is
  either live status, a do-not-regress framing, or a POINTER; it never paraphrases a source
  inline (a paraphrase drifts from its source — the confabulation trap). Deep detail (constants,
  schemas, commit-hash lists) lives in its OWN file (spec / audit / plan) even when current —
  STATE points to it. Never stack dated "## Update 2026-xx-xx" blocks — dated narrative → SESSION_LOG;
  live backlog → OPEN_ITEMS; stale structural detail → archive/STATE_ARCHIVE. Soft smell-target
  ~50 lines (a review-trigger, NOT a truncation): over it, STATE is accreting detail or history
  that should be a pointer — the test is "is every line live-status, a framing, or a pointer?",
  not the raw count. STATE answers "where are we RIGHT NOW", not "how did we get here".
-->

# STATE — <project>

_As of: <YYYY-MM-DD>. Snapshot only; see SESSION_LOG for history, OPEN_ITEMS for backlog._

## Now
<!-- One short paragraph: what's the current focus, what phase/milestone are we in. -->

## Current state of the system
<!-- Bullet the load-bearing facts about what EXISTS and RUNS today (not what's planned).
     Each bullet is a fact + a pointer to where the detail lives. Keep it to what a
     returning session needs to orient. -->
- <subsystem>: <one-line current state> → <pointer to reference doc / spec>

## In flight
<!-- What's actively being worked, with a pointer to the branch/worktree/spec. -->
- <work item> — <branch/worktree> — <next concrete action>

## Pointers
<!-- The canonical locations a returning session needs. -->
- Plan / design intent: <path>
- Reference docs (current-state truth): <path>
- Open backlog: OPEN_ITEMS.md
- Session history: SESSION_LOG.md
- Next-session directives: SESSION_KICKOFF.md
