# Minimality-mode tooling — explicit activation, never in a checking seat

A **minimality mode** is any installed tool that injects a do-less / YAGNI persona into sessions and
dispatched agents — typically a plugin with SessionStart + SubagentStart hooks, a set of intensity
levels, and its own over-engineering review and repo-audit skills. Where one is installed:

- **Default OFF; activation is explicit and per-arc.** Pin the tool's default to off at install —
  these ship defaulting to ON. Never assume it is off: verify by the tool's own state, not memory.
- **Never active in a checking seat.** A reviewer, an audit round, or a council seat running under an
  injected persona is a tainted lens. Assert the mode is off before dispatching any reviewer
  (`audit-cycle` pre-flight) — its subagent hook reaches dispatched agents, so a lead-only "off" is not
  off.
- **Never active in an implementer working a ratified contract.** The ladder's first rung ("does this
  need to exist?") invites second-guessing a clause the operator already ratified. Where the operator
  carves a per-arc exception, jurisdiction is NEW code only, and a rung-1 hit on a ratified clause is
  **flagged to the operator, never silently cut**.
- **The harness's YAGNI floor outranks the tool's ladder.** `right-sized-engineering`'s floor —
  irreversibility-class security invariants, the block-path test for a guard that exists, the diarized
  WHY behind a rule, small-but-real needs — is not the tool's to trim; it knows nothing of this
  project's plan, vision, or threat model. On conflict the floor wins and the candidate routes to the
  operator.
- **Its review / repo-audit skills are invoke-on-ask and mode-independent** — a deletion hunt over a
  diff or a repo is useful at any time. Its output is a list of PROPOSALS: they never bypass the owner
  gate (`operator-owns-criticality-and-complexity`) or the floor above.

Scope note: such a tool overlaps most of `right-sized-engineering` already; it earns its keep as a
second, plan-blind lens on CODE — complementary to, never a substitute for, the harness's own gates.
