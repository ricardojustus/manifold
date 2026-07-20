<!--
  SESSION_KICKOFF.md — next-session-ONLY directives. A stable filename, rewritten at the
  end of each session for the start of the next one. NOT append-only (that's SESSION_LOG),
  NOT a backlog (that's OPEN_ITEMS). It holds only "when you next sit down, do THIS first".
  The session-start routine reads this before anything else. Clear/replace it each time.

  QUALITY BAR: every slot below is MANDATORY (an empty slot is a broken handoff, not a lean
  one). LEAN BAR: ~2 KB budget — pointers and deltas only, never content that lives in STATE
  or a plan. Self-check before writing: could a stranger with zero session context start
  correctly from this file alone?
-->

# Session kickoff — for the next session

_Written: <YYYY-MM-DD> · for the session that picks up next._

## Start here
<!-- The single most important thing to do first next session. One line. -->

## Context you need loaded
<!-- The load-bearing files to RE-READ (not just recall) before starting — name them by
     path, and say WHY each is load-bearing so a stranger-future-self reads the right ones.
     A summary flattens these; the point is to read the source. -->
- <path> — <why it's load-bearing>

## Directives
<!-- Specific instructions for next session: decisions already made not to relitigate,
     the sequence to follow, anything the operator said to do next. -->
- <directive>

## Do NOT
<!-- Guardrails: things a fresh session might wrongly do — a relitigation, a wrong target,
     a premature action. -->
- <guardrail>

## Operational state
<!-- In-flight facts a stranger can't infer: background jobs out, branches mid-merge,
     credentials/keys state, anything armed (timers, watchers, pending GOs). "None" is valid. -->
- <fact or "None">
