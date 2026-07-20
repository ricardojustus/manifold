# council — test prompts (skill-eval fixtures)

Not needed at invocation time; used when evaluating or tuning this skill's triggering.

1. *"Convene the council on the integration — Phase 5, High stakes. Vision + Plan are in
   councils/<topic>/."* → 4 first-pass seats dispatched same turn (2 strong-reasoning subagents +
   2 cross-model backgrounded + watchers), independent first passes, 1 cross-exam round, THEN the
   Proportionality Skeptic alone on artifact + all findings (verdicts every addition),
   MAX-severity consolidation with verdicts inline → `consolidated-findings.md`, advisory.
2. *"Run Gate A on this Vision — no Plan yet, Medium stakes."* → degrades to vision-only; 3 seats
   (Premise Skeptic strong-reasoning + Feasibility Skeptic cross-model + Proportionality Skeptic
   cross-model — Systems Critic is gutted with no Plan); no plan-targeted findings; under-tagging
   check skipped; the Proportionality seat's pricing check converts to a named plan-phase
   obligation.
3. *"The council came back with a High that the Human rejects."* → logged as a waived finding; the
   Council never forces a loop-back; the Orchestrator records the disposition.
