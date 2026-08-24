---
name: session-start
description: >-
  Opens a fresh session on the truth, not on assumption: read your thread's kickoff and state, sweep your team's tracker mailbox, connect to the peer channel, check commits in every repo in play, then report before working. Use on "/session-start", "start session", "what's the state", "pick up where we left off"; not casual greetings. Not compact-resume.
allowed-tools: Read, Grep, Glob, Bash
---

# Session start

**WHAT**: open a session on the truth, not on assumption. **WHEN**: every fresh session, first
thing — before proposing any work.

1. Read your thread's `KICKOFF.md` and `STATE.md` end-to-end. They are the prior session's
   instructions to you.
2. Sweep your team's tracker mailbox, where the map names one: in progress · in review ·
   assigned-to-the-operator · triage (the map's Board row names the tool and its query traps).
3. Connect to the peer channel the map names, as your track — where it names one.
4. `git log --oneline -5` + `status --short` in each repo in play — commits are denser than
   prose state; flag anything STATE doesn't mention.
5. Report before working: where things stand · this session's directives · what's waiting on
   the operator · your proposed start. **A kickoff is a plan, never a standing GO** —
   session-scale work starts on the operator's word in THIS session.

Depth is yours to size; the five items are not.
