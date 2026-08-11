# Minimality-mode tooling — ON in every dispatched seat; judgment seats opt-in

A **minimality mode** is any installed tool that injects a do-less / YAGNI persona into sessions and
dispatched agents — typically a plugin with SessionStart + SubagentStart hooks, a set of intensity
levels, and its own over-engineering review and repo-audit skills. Where one is installed:

- **Every DISPATCHED seat runs the persona at standard intensity**: implementers specced and
  specless, audit-fix seats, and reviewer/audit-lens seats alike. Activation is **ARC-WIDE**: set
  the tool's flag once when a build/review arc starts, clear it at session end — no per-dispatch
  set/clear, no pre-reviewer assert. Inside implementer seats, a rung-1 "does this need to
  exist?" hit on a ratified clause is **flagged to the operator, never silently cut** —
  jurisdiction is NEW code. Standing tripwires — either fires → that seat class reverts to OFF
  and the operator is informed (instruments: downstream audit rounds + the operator's reading):
  - one persona-attributable spec-conformance failure;
  - one persona-attributable missed finding in a review round.
- **Judgment seats stay persona-free by default** — the LEAD session that authors specs,
  consolidates severities, and writes operator decision packets. No downstream gate checks these
  seats, so they run clean unless the operator explicitly opts a session in. **The session
  default stays pinned OFF at install** (these tools ship ON) precisely so a lead never starts
  ambient-persona'd; never assume the mode's state — verify by the tool's own state surface (the
  binding names it and its blast radius).
- **The sticky session-persona caveat**: the tool's session-scoped skill persona typically
  persists every response and only the OPERATOR can deactivate it (the binding carries the
  concretes). A lead that invoked it does not lead checking or judgment work — round
  consolidation, severity calls, packet-writing — until the operator deactivates it or a fresh
  session takes the seat.
- **The harness's YAGNI floor outranks the tool's ladder.** `right-sized-engineering`'s floor —
  irreversibility-class security invariants, the block-path test for a guard that exists, the diarized
  WHY behind a rule, small-but-real needs — is not the tool's to trim; it knows nothing of this
  project's plan, vision, or threat model. On conflict the floor wins and the candidate routes to the
  operator.
- **Its review / repo-audit skills are invoke-on-ask and mode-independent** — a deletion hunt over a
  diff or a repo is useful at any time. Its output is a list of PROPOSALS: they never bypass the owner
  gate (`operator-owns-criticality-and-complexity`) or the floor above.
