# Right-sized engineering — YAGNI with a floor

**Rule.** Build the smallest thing that solves the ACTUAL problem — and before building any
machinery at all (a guard, an abstraction, a config surface, a process step), run three checks:

1. **Is the need real and current** — not speculative? "We might need it" is not a need. (YAGNI:
   you aren't gonna need it.)
2. **Does something already provide it?** Check the platform's native layer first — permission
   modes and their classifiers, sandboxing, server-side branch protection, existing hooks — then
   existing code and existing rules. Rebuilding what the runtime already does is the most common
   overengineering shape, and the copy is usually worse than the native version.
3. **Was this already litigated?** Waivers, coverage notes, decision logs, and stated postures are
   *settled*. Inherit them. Re-deriving a threat model or a design tradeoff that a prior decision
   already closed burns budget and — worse — can silently reverse a deliberate call.
   **Two boundaries on this check (added 2026-07-16, after both were violated in one arc):**
   (a) **inherit exactly what was litigated, no more** — a receipt that defended one component (a
   security wall) does not settle the layers built around it; read what the prior decision
   actually closed before citing it. (b) **The OPERATOR asking "is this needed / is this
   overengineering?" REOPENS the posture** — inherit-don't-relitigate binds agents and advisors,
   never the operator. Answering their system-question by citing the settled posture back at them
   inverts the authority this check protects. *(Receipt: an advisor consult cited a prior
   sandbox-wall receipt to defend an entire cage of restrictions the receipt had never litigated,
   argued the agent off its own correct simplify instinct, and the operator's direct
   overengineering question got processed as a component-tuning decision — ~4 wasted hours.)*

**Proportionality of process.** Process weight scales with the **stakes rubric** — size, novelty,
design-choice, complexity, knowledge gaps, blast radius, security/privacy, external commitment
(max-of-dimension; METHODOLOGY.md owns the table) — not with how interesting the problem is, and
**never with reversibility** (operator ruling 2026-07-14: almost all work is reversible, so a
reversibility-keyed process goes vestigial — the big-but-reversible feature is exactly what the
full process exists for). Irreversibility keeps its bite where it lands: destructive actions halt
(`ask-vs-decide`), an irreversible chunk owes hardening (a rollback/migration proof; Critical
escalation), and one-violation-is-forever security invariants are the floor below. Multi-round
adversarial audit machinery is for spec-lane implementations and high-stakes surfaces; a
best-effort convenience gets a review and a selftest — not a hardening campaign.

**The classification check — the rubric's inputs are claims, and claims get grounded** (added
2026-07-15). A rule that keys on blast radius has no defense against a false classification. Any
invocation of "irreversible / high blast radius" **used to justify machinery** must cite the
concrete recovery story from the project's current-state docs — what actually happens when this
goes wrong, detection latency, what propagates meanwhile, recovery cost in operator labor — never
the designer's intuition. Check both directions: inflated danger inflates machinery; minimized
danger skips needed care. Evidence scales with stakes: citing where the recovery path was last
exercised usually suffices; a recovery *proof* is owed only when the claim carries heavy machinery
on its back. *(Receipt: an arc classified "AI edits the memory graph" as irreversible — the
category that justifies heavy machinery — while the architecture had made graph mistakes
recoverable months earlier (immutable evidence master, rebuildable projection, worst real
corruption hand-repaired in an afternoon). The rule was cited; it was fed a false premise; a
certification fortress followed.)*

**Pinned constants are design decisions.** Sample sizes, confidence bars, densities, thresholds,
seat counts get the same adversarial scrutiny as architecture — each pinned constant carries its
**cost implication inline** (what does this number multiply out to, per run, at recurrence?).
Constants ratified as statistics whose *price* nobody computed are how a design passes every gate
and dies on first contact with the account it runs on.

## Receipt (2026-07-04, this harness's own v1 self-audit)

A best-effort force-push guard hook — whose limits were *declared at design time* ("it cannot
anticipate every exotic path… the backstop for the obvious ones, not the whole guarantee") and
whose threat model had *already been litigated* in a prior system decision (pattern-defenses guard
the careless case; the malicious case belongs to structural layers) — consumed **three expensive
audit rounds** of hardening anyway. Each pass either missed another encoding or over-blocked
innocent commands (`rm -rf pushcache/` was denied by a "safety" belt — the harmful direction,
because a guard that blocks normal work gets disabled). The operator's resolution: **radical
simplification** — 170 lines → ~60 obviously-correct lines, a written waiver for the disguise
tail, selftest-pinned. The audit rounds were the failure mode, not diligence.

## Receipt (2026-07-15, the certification fortress — the other direction)

The v1 receipt above is process pointed at too small a target; this one is machinery built too
big. A week-long arc built statistical certification gates (97% CI at n≥99/class, 100% blind
grading by a second model, 100% countersign by a third, bake-offs, held-out splits) so a nightly
janitor could apply memory-graph fixes autonomously — **enterprise ML-evaluation standards
imported into a one-user system whose mistakes had an undo story**. Every gate passed: two
unanimous councils, clean spec ladders, four dual-lens audit rounds to zero findings. The pilot
needed ~2,500 recurring model calls; the account saturated at ~150; the operator killed the arc
in an hour ("NO OVERENGINEERING IS A CORE PRINCIPLE"). Root causes now encoded as checks here and
in METHODOLOGY.md: a false irreversibility classification fed the stakes rubric (→ the
classification check), the constants' price was never computed (→ constants-carry-cost, the
resource-envelope gate), and every gate validated the design against itself, none against the
machine it ran on (→ the Proportionality Skeptic seat).

## The floor — what YAGNI must NOT trim

This principle cuts speculation. It does not cut:

- **Security invariants where one violation is irreversible** (ENFORCEMENT.md's invariants, exfiltration
  posture). Their existence is settled by the irreversibility test, not by "have we needed it yet."
- **The block-path test for any guard that exists.** A guard too trivial to test is a guard that
  fails open (see ENFORCEMENT.md's exit-code footgun).
- **Receipts and WHYs on rules.** Deleting the why is how the next confident junior deletes the
  rule.
- **Small-but-real needs.** When the need is real but modest, build the modest version — don't use
  YAGNI as a license to skip it.
- **When you can't tell speculative from real: ask or park.** Never silently drop a maybe-need;
  that's YAGNI curdling into negligence.

## Smell test (especially for less-experienced executors)

Stop and reconsider when you see yourself:

- hardening a guard against inputs no *careless* actor would ever produce;
- writing an abstraction with one caller, a config option nobody sets, error handling for
  impossible states;
- pointing heavyweight process machinery at a minor surface because the machinery exists;
- rebuilding a check the platform already performs natively;
- re-opening a question that a waiver, coverage note, or decision log already answered — if you
  think the settled answer is wrong, challenge it ONCE, explicitly, with new evidence; don't
  silently re-derive.

## How to apply

- **At design time**: declare which regime an artifact is in — *best-effort* or *guarantee*. The
  declaration is part of the spec.
- **At audit time**: auditors inherit the declared regime and its waivers as ground truth.
  Findings that amount to "the best-effort thing is not a guarantee" are posture challenges, not
  defects — raise them once to the operator, then respect the ruling.
- **At fix-pass time**: a fix that hardens beyond the declared regime is scope creep even when
  well-intentioned — the over-blocking belt in this harness's own v1 audit was exactly this.

*Pairs with: `smell-checklist.md` (probe triggers), `ask-vs-decide.md` (when to park the maybe-need),
ENFORCEMENT.md "Extending enforcement" (the four tests before any rule escalates past prose), the
Proportionality Skeptic council seat (this principle's standing adversarial owner), and the
spec-writing skill's resource-envelope gate (its lock-blocking teeth).*
