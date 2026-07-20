# audit-cycle — test prompts (skill-eval fixtures)

Not needed at invocation time; used when evaluating or tuning this skill's triggering.

1. *"I'm ready to merge `feature/<x>` to main. Dispatch the round-1 audit."* → skill fires;
   lead spawns the parallel primary reviewer subagent + the cross-model reviewer + its
   completion-watcher; feeds the registries; consolidates MAX-severity.
2. *"Round-1 came back NEEDS-FIX-PASS with 2 Mediums the primary lens missed. Help me
   consolidate."* → MAX-severity applies; decide direct fix-pass / Path A / Path C.
3. *"Round-2 cleared C/H/M from both lenses but left 3 Lows. Does this lock?"* → triage each
   Low (waive / backlog / promote); if none promote and no new C/H/M appeared, the gate is met
   → LOCK. No round-3 for the Lows.
4. *"A reviewer flagged a Medium I think has no reproducible failure scenario."* → written
   dispute → the other reviewer adjudicates → uphold (fix) or dismiss (`disputed-findings.md`,
   doesn't block).
