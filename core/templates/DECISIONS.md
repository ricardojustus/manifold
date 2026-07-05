<!--
  DECISIONS.md — the "what I decided autonomously, and why" log for an unattended run.
  The audit trail for the ask-vs-decide boundary: every call you made WITHOUT stopping to
  ask, with its rationale, so the operator can review (and ratify or reverse) asynchronously.
  This is what makes "decide and park the ratification" safe — the operator's oversight is
  preserved, just async. One of the three thread-local hygiene files; keep it in the owning
  thread's folder. A decision that touches a HALT line (irreversible / live-prod / intent-
  unknown / operator-reserved) does NOT go here — it goes in QUESTIONS-FOR-OPERATOR unmade.
-->

# Decisions — <thread/lane> — <run start YYYY-MM-DD>

_Autonomous calls made this run, for async ratification. Each is reversible + in-scope (per ask-vs-decide); genuine halts live in QUESTIONS-FOR-OPERATOR._

## D-NNN — <the decision, one line>
- **What I decided:** <the call>
- **Why:** <rationale — spec-required / clearly right / the tradeoff>
- **Reversibility:** <how to undo it — commit ref, config revert>
- **Ratification:** PARKED — <what the operator should check to confirm/reverse>

<!-- Even a locked-artifact amendment goes here when the answer was engineering-unambiguous
     (additive, tests-green): decide, re-lock, PARK the ratification. Record the re-lock ref. -->
