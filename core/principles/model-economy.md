# Model economy — spend the tier the work needs, and quota IS cost

**Rule.** Match the model tier to the work, and reach for the top tier only when the tier below **demonstrably** needs more than one attempt. Frontier models earn their cost on judgment, design, and review; the mid tier implements from a locked spec; the cheap tier runs mechanical sweeps. And remember the second cost axis: **a subscription's periodic quota is a finite, exhaustible resource — burning it is a real cost even when zero dollars are metered.**

**The tier ladder:**
- **Frontier tier** — judgment-heavy work: design, architecture, adversarial review, synthesis, spec authoring, decisions with taste in the tails. Also: implementation where "feels right vs wrong" judgment happens *during* the build (UI, interaction, aesthetics).
- **Mid tier** — implementation from a locked, unambiguous spec (the judgment was spent at spec time), and sustained contract-fidelity work.
- **Cheap tier** — mechanical, high-volume, low-judgment sweeps: read-and-summarize, inventory, grep-and-trace, documentation research, probes.

**The escalation rule (steal it verbatim):** *use the top tier only when the tier below demonstrably needs multiple attempts.* Don't default to frontier "to be safe" — that silently burns the expensive resource on cheap work.

## The second dial — reasoning effort

Tier is WHICH model; **effort** (low / medium / high / xhigh-class settings, where the runtime
exposes them) is HOW HARD it thinks. They are orthogonal, and the dispatcher sets BOTH,
explicitly, at every dispatch — an inherited effort default is the same silent waste as an
inherited model default. **Triage effort by where the judgment sits, not by how important the
task feels:**

- **Implementers working from a locked, unambiguous spec: start at medium–high, not the top.**
  The judgment was spent at spec time; the implementer's job is contract fidelity. The empirical
  receipt (an external N=29 benchmark plus the source project's own A/B, ~2026-05 — dated,
  re-verify per finding-freshness): medium *beat* xhigh for locked-spec implementation on
  test-pass, review-pass, and instruction adherence at a fraction of the cost — and the top
  settings showed a specific failure mode to watch for: **no-op rationalization**, reasoning
  itself into confidently declaring "no work needed" instead of producing the change.
- **Judgment seats — design, adversarial review, synthesis, severity calls: high–xhigh.** This is
  where extra thinking buys outcome; token spend on reasoning explains most outcome variance
  (see dispatch-sizing), so spend it exactly here.
- **Mechanical sweeps — inventory, grep-and-trace, summarize: low.** More thinking does not
  improve a directory listing.
- **The main orchestrator loop** runs at the operator's chosen default (typically high or the
  xhigh-class setting on the frontier tier). A dispatched agent does NOT inherit that default —
  it gets its own triaged setting.
- **Escalate effort like you escalate tier: on evidence.** A relaxed contract, a shallow miss, a
  multi-attempt loop at the lower setting — then raise it and note why. Never on vibes.

**Specs pre-triage this** (see the methodology's spec phase): a spec at LOCK carries an
implementation-dispatch recommendation — tier + effort + lane shape — made by the author who just
spent the most time understanding the work's complexity. The dispatcher honors it or overrides it
with a stated reason; either way the setting is someone's explicit decision, never an inherited
default.

## Cross-model — counterparty always, implementer sometimes

A **different model family** as reviewer is non-negotiable at the audit gate (a second instance of
the same model shares the first's blind spots; in the source project's own harness audit the
cross-model lens caught both the only Critical and a fail-open defect the same-family reviewer
physically could not reproduce). As **implementer**, the other family earns the dispatch in
exactly two cases: (1) a **bake-off** — two independent implementations of one locked spec,
compared; (2) the primary family is **demonstrably stuck** — looping on a diagnosis or repeatedly
failing the same contract, where fresh blind spots beat more effort. Outside those, cross-model
implementation adds coordination cost without adding judgment. The project binding pins the
concrete counterparty and its dispatch mechanics.

## The advisor — a second opinion at junctions (where the runtime provides one)

Claude Code's advisor tool (set `advisorModel` in settings) attaches a fresh-context second
model that receives the FULL transcript and returns guidance; the main model decides when to
consult, steered by standing instructions — these are those instructions. **Consult at, and
only at, these junctions:**

1. **Complex decisions you're about to surface.** Consult the advisor when BOTH hold:
   - **(a) You're about to surface it** — presenting it to the operator for a decision, or
     (working alone) parking it or recording it as a formal decision; and
   - **(b) It's genuinely contested** — more than one defensible option, a real tradeoff, no
     obviously right answer.
   Consult FIRST, so what you surface already carries a second opinion: your recommendation,
   plus whether the advisor agreed (and if not, why). Obvious calls — even significant ones —
   skip the consult. A choice you wouldn't surface at all never gets one.
2. **The debugging circuit breaker** — repeated failed fixes on one bug, before escalating.
3. **Before a spec goes to its audit** — one fresh read against wrong-target framing.
4. **Autonomous-run decisions** — gray-zone STOP classification, decide-and-park
   recommendations, irreversible-ish in-scope commits, and the done-declaration (the
   autonomous-work skill owns the details).

**Never**: routine turns, routine implementation against a locked spec, audit gates (the
cross-model reviewer owns independence there) — and **never to clear a STOP boundary: advice
improves a decision within your authority; it cannot expand your authority.** Cost mechanics
make the whitelist matter: each consult ships the entire transcript uncached at the advisor
model's rates. A handful of consults in a heavy session; zero in a light one. The advisor is
same-family fresh eyes (kills anchoring, not family blind spots) — it complements the
cross-model lens, never replaces it.

## Why

Dispatching everything at the top tier feels safe and is quietly the most expensive habit an agent can have: it burns both metered spend and the flat-rate quota that gates *all* work, on tasks a cheaper tier would have done identically. The inverse — implementing a subtle contract on a cheap tier — fails differently: the cheap tier relaxes contracts it doesn't fully grasp, and you pay for the miss in audit rounds. The tier is a judgment call about where the *judgment* in the task actually lives.

Quota is the axis that's easy to forget because it doesn't show up as a dollar figure. A periodic cap is exhaustible; spending it on a mechanical sweep that a cheap tier could have run is a real cost that surfaces later as a stall. Treat throughput quota as a budget you are spending, always. (This is the runtime-cost sibling of the methodology's "quota IS cost" principle — assess *recurring* spend, both metered and flat-rate, before shipping.)

*Receipt: a batch of read-and-summarize, grep, and probe subagents were dispatched at the top tier by omission — the default inherited the expensive model when every one of them was cheap-tier work. Nothing was wrong with the output; the cost was pure waste. Naming the tier explicitly at dispatch, matched to where the judgment sits, is the whole fix.*

## How to apply

- At every dispatch, name the tier AND the effort explicitly and justify both by *where the judgment is* — never inherit either default silently. If the spec carries a dispatch triage, start from it.
- Escalate a tier (or an effort setting) only on evidence that the lower one is failing (multiple attempts, relaxed contract), not on a hunch.
- Model names and their tiers date fast — this file names tiers **generically**; the project binding pins the concrete models du jour (and carries a re-verify date per the finding-freshness convention).
- Pairs with **dispatch-sizing** (how *many* agents and how big) and **finding-freshness** (the concrete-model pins are dated observations).
