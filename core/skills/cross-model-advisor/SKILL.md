---
name: cross-model-advisor
description: >-
  Consults a strong different-family model as a peer reasoning partner to pair-reason and hunt blind spots. Advisory only: positions and confidence, never severity-rated findings. Use on load-bearing decisions, roadblocks, and ALWAYS on "reason deeply" / "think deeply" / "/advisor". Not audit-cycle or council.
---

# Cross-Model Advisor — a peer, not a judge

A standing **peer reasoning partner** from a genuinely different model family (the binding names the
counterpart model + dispatch mechanics). One strong model reasoning alone converges on its own
family's blind spots. The harness already has adversarial *gates* returning severity-rated findings
(audit-cycle, council); this is the other thing — **thinking together**.

## When to invoke

- **Load-bearing decisions** — architecture choices, approach selection, anything a decision packet
  will carry to the operator.
- **New designs** — before formal machinery (a council, a spec ladder) is convened.
- **Roadblocks** — 2+ failed approaches on the same problem.
- **Deep reasoning** — first-principles arcs, challenges to settled architecture, "should this exist
  at all" questions.
- **PRESUMED-MANDATORY below the project's frontier tier** (quota exhaustion, guardrail fallback):
  skipping the consult on a load-bearing decision there requires a stated reason. A below-frontier
  main paired with a frontier cross-model peer is the cheapest quality recovery available.
- **FORCED — the operator says "reason deeply" / "think deeply"**: those words ARE the invocation,
  whatever the topic's apparent size. Never satisfy it with a longer internal think.

**Not for**: routine implementation, small fixes, mechanical questions with checkable answers,
anything inside a running audit-cycle or council sitting. Invoked often ≠ invoked always.

**Operator-question precedence**: when the question came FROM the operator as a system-question
("is this overengineering?", "do we need this?", "why does this exist?"), the plain-terms
whole-system explanation to them comes BEFORE any consult (operator-translation's audit-question
trigger) — their answer may dissolve the consult entirely.

## The three modes

**1. `think-with` (default) — blind-first, two calls on ONE continued counterpart session.**
(a) **Blind pass**: send the problem, constraints, and file pointers **WITHOUT your lean** — ask for
its independent position: how would IT approach this, what is the crux, what would it do?
(b) **Reveal pass** (same session): send your lean + reasoning; ask it to **steelman your approach
first** (critique is earned by showing it understood), then challenge it, then **reconcile** against
its own blind-pass position — where do the two reads genuinely differ, and why? Order matters:
critique-after-reveal collapses into agreement bias. (The binding names the continuation mechanism.)

**2. `dialogue` — multi-turn pair reasoning.** For roadblocks and first-principles arcs one round
can't converge. Start as `think-with`, then keep going: answer its questions, push back, refine —
**cap ~3 rounds** (unconverged at 3 needs the operator or a spike, not more tokens). Respond to ITS
points; don't re-send your position louder.

**3. `devil` — stance-assigned challenge.** Assign it explicitly: *"argue AGAINST this approach at
full strength"* / *"steelman the alternative I rejected."* Strongest real case, project-specific, no
strawmen. **The stance guardrail rides every devil prompt**: *the stance shapes HOW you present,
never WHETHER you acknowledge fundamental truths — a genuinely good idea is acknowledged regardless
of stance; a genuinely bad one is called out regardless of stance.*

## The advisor prompt — standing ingredients (compose per consult)

- **Peer framing**: "You are an equally senior engineering thought-partner reasoning WITH a peer
  agent, extending its thinking — not delivering an isolated verdict. No filler, no praise, depth
  over breadth."
- **Anti-overengineering guardrail**: "Overengineering is an anti-pattern — do not suggest solutions
  that introduce unnecessary abstraction, indirection, or configuration in anticipation of
  complexity that does not yet exist."
- **Ground, don't guess**: it has repo read access — instruct it to READ what it needs and cite
  paths; a claim about the codebase names the file it rests on. Lacking context, it asks, never
  invents.
- **Output contract (the anti-audit teeth)**: positions + reasoning + confidence in prose; questions
  back at the dispatcher; close with **"what would change my mind."** **BANNED here: severity tags
  (C/H/M/L), numbered findings lists, ship-it/rethink-it verdicts, fixed report sections.** A reply
  that comes back audit-shaped means the prompt was wrong — fix the prompt, don't relay the verdict.

## Authority + the consolidation duty

The main session keeps authority; the advisor is never prescriptive. But **listen ≠ skim**:

- **Name the advisor's structural bias on machinery questions.** An advisor asked about a guard, a
  wall, or a process step skews toward MORE of it — depth-maximizing is safe for a consultant who
  doesn't pay the cost. When its position adds machinery, weigh it explicitly against YAGNI and the
  operator's simplify instinct, and say the bias out loud when relaying ("the advisor leans
  protective here, as advisors do"). Being argued OFF a simplify instinct is a flag to re-check, not
  a reconciliation.
- **Engage every substantive point** — adopt it, or say why not. An unengaged consult is a wasted
  call and a pretend process.
- **Record the residue** where the decision lives (decision packet, design doc, journal): one line
  per significant adopted/rejected idea. When the consult materially shaped a decision the operator
  ratifies, the packet's "watch out" line quotes the advisor's strongest dissent verbatim.
- "What would change my mind" is a **closing probe for reasoning quality**, never an "are you sure?"
  retry loop (re-prompted models flip-flop; probe the reasoning, don't shake it).

## Boundaries

Not `audit-cycle` (the pre-merge gate on artifacts; severity vocabulary lives there) · not `council`
(the formal multi-seat panel at its two phase gates — a design the advisor shaped still faces the
council cold) · not the runtime's native advisor (same-family, automatic at junctions; this is
deliberately cross-family and deliberately invoked — they stack) · not an implementer (dispatched
read-only: it reasons, you act).

## Mechanics

The binding names the counterpart model pin + effort, the dispatch command, the continuation
mechanism for `dialogue` / `think-with` pass 2, the watcher discipline (watcher + fallback timer,
both, same turn — a dead watcher must never stall the consult), the refusal fallback, and the cost
note. Write the consult prompt to a file and pipe it (compose-hang resilience); persist the reply
beside the work it advised.

## Anti-patterns

1. **Audit drift** — a consult returning severity-rated findings. The prompt caused it; reshape.
2. **Anchored consult** — sending your lean in the blind pass "for context." Blind or worthless.
3. **Oracle treatment** — adopting its position wholesale without the reconcile step. The value is
   the DELTA between two strong reads, not swapping which model you obey.
4. **Consult theater** — invoking it, then neither engaging its points nor recording the residue.
5. **Gate substitution** — "the advisor liked it" is not an audit pass, a council sitting, or an
   operator GO. It changes none of the gates.
6. **Devil-mode strawman** — a stance argued weakly to be knocked down. Full strength or don't
   assign the stance.

## Test prompts

1. *"/advisor — should the scheduler own retry state, or the runner?"* → think-with: blind pass
   (problem + files, no lean) → reveal pass (steelman → challenge → reconcile) → consolidate, record
   adopted/rejected residue.
2. *"Two fixes for this race both deadlocked — pair-reason it with me."* → dialogue, ≤3 rounds.
3. *"Play devil's advocate on migrating the store to SQLite."* → devil mode with the stance
   guardrail; close with what would change its mind.
4. Main loop on the fallback tier, load-bearing design choice, about to decide solo → invoke
   unasked (presumed-mandatory), or state why not.
