# The operator owns criticality, security-machinery depth, and operating posture — ask, don't assume

**Rule.** Some decisions are the operator's to make, not the agent's — and the agent may not quietly
make them by building as if they were already settled. This is an AUTHORITY boundary that sits
BESIDE the YAGNI machinery (`right-sized-engineering`, the Proportionality Skeptic seat), not on top
of it: those ask *"is this proportionate?"*; this asks *"whose call is it?"* The failure they miss is
an agent OWNING a premise the operator has reserved.

## What is reserved to the operator

- whether a component is **mission-critical**, how much **downtime / disruption** it tolerates,
  whether it can be **turned off**;
- **how much security or assurance machinery** to build, and **what residual risk to accept**;
- the **operating posture** generally — any choice that materially **changes the solution class,
  delays a capability, adds recurring cost/quota, or stands up a new guard / recovery / migration /
  process / security subsystem.**

Routine implementation complexity **inside** an already-chosen posture stays the agent's (retry
counts, cache TTLs, timeouts, validation, permission checks, availability design). The reserved
thing is the **posture**, not every line of code.

**The agent may NOT infer a reserved call from a risk label ("Critical", "irreversible"),
architecture, industry practice, reviewer/council consensus, or prior artifact approval.** None of
those is evidence or consent — a label is not information.

## Security invariants — binding by default, lowered only by an informed exception

A security invariant whose one violation is irreversible (a no-exfiltration/no-leak posture; the
enforcement invariants) **remains binding absent an explicit, informed operator exception.** The
agent never silently weakens it; while a decision is pending it neither opens a new exposure nor
lowers an existing control; and the **standard control is built by default** — a pending posture
decision is never an excuse to defer protection; only gold-plating *beyond* the default routes to
the operator. **"Settled" means the invariant cannot be silently WEAKENED — NOT that its enforcement
DEPTH is the agent's to select.**

The operator may knowingly accept a posture **below** such an invariant — but ONLY through a
**finite, totally-informed exception** (no proof of the operator's mental state is required or
possible — that framing would itself invite an endless assurance campaign). Operationally: a bounded
disclosure the operator explicitly accepts, naming **what could leak/fail · by what path · to which
destination or recipient class · why it is unrecoverable · the simplest invariant-preserving option
and its real cost · mitigations and remaining risk · every material KNOWN warning · what remains
materially unknown.** An exception to an irreversibility-class invariant is a
**structural-ratification-tier** decision (a recorded packet + brief, never an inline "fine"), and
it cannot erase an obligation outside the operator's authority (a third-party or contractual
constraint is disclosed, not overridden).

## Present, don't assume — in the operator's terms

Surface the reserved call with its consequence legible (`operator-translation`): the **specific
issue and consequence stated concretely** — what breaks, to what, how badly, how recoverable in the
operator's labor and downtime, and what the machinery actually buys — never a bare label the operator
cannot unpack. **Always find and present the simplest way** to solve the actual problem; any heavier
option arrives with the simplest alternative beside it. The cheap author-time technique is the
**frame-reset** (`spec-writing` Step 0): restate the change stripped of its solution nouns and risk
labels, and the machinery must justify itself from scratch. A fresh independent lens is valuable
**where one already runs** (the Proportionality seat challenges the machinery premise) — but do not
stand up a new review invocation on every non-trivial decision: the operator, not another model,
holds the missing risk tolerance.

## Where the teeth are — the plan-lock gate

Route the reserved call at **plan-lock** — the earliest point machinery appears as intent, and the
point the operator reliably co-signs (autonomous spec-drafting can't be relied on for a human
decision; and by spec-lock the tokens to author the machinery are already spent).

- **A plan cannot lock while operator-visible machinery justified by a criticality / recovery /
  security-depth posture lacks a cited operator POSTURE RECEIPT** covering that trade. A receipt is a
  **stable pointer to the complete decision packet AND the operator's explicit response**, recording
  the chosen posture and its exact scope; its failure/recovery story is **grounded in current-state
  docs** (per `right-sized-engineering`'s classification check), and it names **the simplest
  alternative the posture was chosen against**. **What does NOT count:** a risk tag, a generic GO,
  industry practice, council/reviewer consensus, or approval of unrelated rulings. A missing receipt
  yields **"operator posture unresolved"** — never a conservative default that builds the safest
  imaginable machinery unasked.
- **The classification stays factually visible; only its MACHINERY CONSEQUENCES wait.** Any mapping
  from a criticality/irreversibility/security classification to operator-visible hardening, delay,
  recurring cost, or reduced capability is a **recommendation until a cited posture receipt activates
  it** — routing the DECISION to the operator (whose answer, for a genuinely warranted case, is
  normally "build it"), never a license for the agent to silently SKIP an owed hardening. The gate
  fires on the machinery **consequence**, so machinery introduced under a neutral name ("robustness",
  "correctness") is caught the same way.
- **Backstop**: the `spec-writing` before-drafting frame-reset (Step 0) carries the same check for
  machinery that appears in a spec with no plan behind it.

## Bounding — so this doesn't over-fire, rubber-stamp, or flood

- **Trigger on operator-visible consequence, not keywords** (the reserved list above). Routine
  engineering inside a chosen posture stays delegated.
- **Exact-scope and class-wide inheritance prevent flooding.** A recorded operator ruling counts as
  "asked" for the exact scope it decided; a **class-wide** ruling is a standing receipt for its whole
  class; downstream artifacts CITE it. Re-ask only when the recovery story changes or a materially
  different protection class is added.
- **Grounding + the named-alternative requirement prevent the rubber-stamp**: a receipt whose story
  is ungrounded, or whose cheap alternative was never named, does not count — even with a GO.

## Pairs with

- `right-sized-engineering` — its operator-authority complement: the simplicity kernel and the
  classification check live there; *whose call the machinery depth is* lives here.
- `operator-translation` — the teaching duty + packet completeness; criticality and
  security-machinery depth are the completeness facts most often withheld.
- `ask-vs-decide` — reserved-authority calls are a halt trigger, never decide-and-park.
