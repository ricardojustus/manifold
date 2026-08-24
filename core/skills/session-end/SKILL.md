---
name: session-end
description: >-
  Closes a session leaving truth behind: file decisions, lessons and backlog items, update state and kickoff, true up the tracker, commit path-listed, collect or stop everything still running, and add one journal line. Use on "call it a day", "we're done", "/session-end", or before /clear.
allowed-tools: Read, Grep, Glob, Bash
---

# Session end

**WHAT**: close a session leaving truth behind — your successor and the operator read only what
you wrote. **WHEN**: any wrap-up ("call it a day", "we're done"), or before /clear.

1. Anything unfiled? Decisions and lessons → the diary intake the map names; backlog items → the
   tracker; anything the operator must read → their index, same turn — each where the map names one.
2. Update `STATE.md` (current state + pointers ONLY) and rewrite `KICKOFF.md` for the next
   session — it opens knowing only what you leave.
3. Tracker truth, where the map names one: move every item you touched to its real state.
4. Repos: commit your work path-listed; name anything left dirty and why.
5. Nothing of yours left running unaccounted: dispatched agents collected or stopped, jobs
   closed where the map names a job board (a session end kills in-flight cross-model jobs —
   collect first).
6. One JOURNAL line if the arc moved.

Depth is yours to size; the six items are not.
