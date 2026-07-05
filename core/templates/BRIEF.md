<!--
  BRIEF.md — the dispatch brief for any spawned agent (subagent, teammate, or lane). The
  brief IS the ambient-context contract: a dispatched agent has NO memory of prior sessions
  and no "check the project's knowledge first" reflex — the brief must carry the discipline.
  Four obligations are non-negotiable (they map to the four sections below): lead with a
  GIVEN block; grep-verify every concrete code reference before pasting it; state the
  ambiguity protocol; state verifiable success criteria. The heavy failure this prevents:
  a thin brief lets a capable implementer silently scope out real requirements, or build
  against infrastructure that doesn't exist.
-->

# Brief — <task title>

## GIVEN (context block — read before the task)
<!-- The ambient state the agent needs. EVERY concrete reference here must be grep-verified
     against the CURRENT code first — a spec being locked/ratified does NOT make its line
     numbers or symbol names true; only a fresh grep does. -->
- **System state:** <what exists and runs today that's relevant>
- **Locked references:** <spec/contract path + version>, <reference doc path> (current-state truth, not just design intent)
- **Tools available:** <the exact tool surface this agent has>
- **Out of scope (do NOT touch):** <explicit exclusions — files, systems, behaviors>
- **Conventions:** <the project conventions this agent must follow>
- **Reads (keep under budget):** <load-bearing sections only; scope the reads, don't trim the locked spec itself>

## TASK
<!-- What to do, stated concretely. If multiple interpretations exist, name them — don't
     make the agent guess. -->

## AMBIGUITY PROTOCOL
<!-- The escape hatch that prevents silent scope-out. -->
On any contradiction between this brief and the code, or any silence where you expected a
spec to answer: **do NOT silently pick an interpretation and proceed.** Send a message to
the dispatcher (or, if you have no mailbox, record it inline as a blocking question) and
name the contradiction. Conservative reading + surfaced ambiguity beats confident wrong work.

## SUCCESS CRITERIA
<!-- Verifiable, not vibes. The agent should be able to check each one itself. -->
- [ ] <criterion — e.g. "tsc clean + N tests pass">
- [ ] <criterion — e.g. "every acceptance clause in <spec> has a code cite">
- [ ] <criterion — e.g. "the return is ≤2k tokens: conclusion + load-bearing evidence">
