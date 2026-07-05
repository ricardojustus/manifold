<!--
  JOURNAL.md — the "what I did" log for an unattended / autonomous work run. One of the
  three thread-local hygiene files (JOURNAL = what I did, DECISIONS = what I decided and
  why, QUESTIONS-FOR-OPERATOR = what needs the human). Keep all three in the OWNING THREAD's
  folder so parallel threads/lanes don't collide. Append as you go; present in the morning
  review. This is a narrative of actions taken, not decisions (those go in DECISIONS) and
  not open questions (those go in QUESTIONS-FOR-OPERATOR).
-->

# Journal — <thread/lane> — <run start YYYY-MM-DD>

_Append-only. What happened, in order. Commit-as-you-go: each meaningful step gets a line + a commit ref where relevant._

## <YYYY-MM-DD HH:MM> — <short title>
<!-- What you did, what you observed, what landed. Cite commits/tests/artifacts.
     Keep each entry to a few lines — this is a trail, not an essay. -->
- Did: <action>
- Result: <outcome — tests, verification, commit ref>
- Next: <the immediate next step>

<!-- Repeat one block per meaningful step. At natural pauses, scan for anything worth
     persisting to durable memory (see the memory-write-kernels principle) and write it
     silently — don't narrate the memory write here or to the operator. -->
