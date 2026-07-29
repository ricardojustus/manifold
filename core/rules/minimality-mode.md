# Minimality-mode tooling — seat-scoped activation, never in a checking seat

A **minimality mode** is any installed tool that injects a do-less / YAGNI persona into sessions and
dispatched agents — typically a plugin with SessionStart + SubagentStart hooks, a set of intensity
levels, and its own over-engineering review and repo-audit skills. Where one is installed:

- **Session default OFF; pin at install** — these ship defaulting to ON. Activation is per-SEAT
  (below), not ambient. Never assume the mode's state: verify by the tool's own state surface, not
  memory — and that state may be shared beyond your session (the binding names the blast radius).
- **Specless implementation seats: MANDATORY ON** (operator ruling 2026-07-26) — implementation
  with no ratified spec/contract behind it (quick fixes, glue, unspecced building) runs under the
  persona at standard intensity. This is the seat the tool exists for.
- **Audit-fix seats: ON at standard intensity** — the persona text obeys explicit remedies
  ("explicitly requested → build it, no re-arguing"), and the next audit round re-checks every
  fix, so a too-lazy fix is caught structurally. Standard intensity, never the extreme tier.
- **Spec-driven implementer seats: ON at standard intensity as an evidence-gated TRIAL** (operator
  ruling 2026-07-26; kill condition verbatim: "if it messes up a spec impl, we stop"). This amends
  the prior never-in-a-ratified-contract-implementer posture. Kill condition: one spec-impl
  conformance failure attributable to the persona (audit rounds are the instrument) → the trial
  ends, revert to never-on. Unchanged inside the seat: a rung-1 "does this need to exist?" hit on
  a ratified clause is **flagged to the operator, never silently cut** — jurisdiction is NEW code.
- **Never in a checking seat.** A reviewer, an audit round, or a council seat running under an
  injected persona is a tainted lens. Subagent-scoping filters (matchers) **fail OPEN** — never
  rely on one to protect a reviewer. Assert the mode is off **by the tool's own state, immediately
  before every reviewer/checking dispatch** (`audit-cycle` pre-flight) — a lead-only "off", or a
  memory of having turned it off, is not off.
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
