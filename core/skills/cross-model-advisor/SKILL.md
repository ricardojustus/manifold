---
name: cross-model-advisor
description: >-
  Consult a strong DIFFERENT-FAMILY model as a peer reasoning partner — bounce ideas, pair-reason,
  hunt blind spots, find new avenues, confirm-or-challenge assumptions and approaches, play devil's
  advocate. This is ADVISORY, explicitly NOT an audit: no severity tags, no findings lists, no
  verdicts — positions, reasoning, confidence, and questions back. The main session keeps authority
  but must genuinely engage every substantive point. Invoke OFTEN but not for everything: important
  or load-bearing decisions, new designs before any council, roadblocks (2+ failed approaches),
  deep first-principles reasoning, challenges to existing architecture — and PRESUMED-MANDATORY
  when the main loop runs below the project's frontier tier (quota fallback), where the cross-model
  lens matters most. FORCED trigger: the operator saying "reason deeply" or "think deeply" about
  something ALWAYS invokes this skill — that phrasing is the operator asking for the paired lens,
  not solo rumination. Other trigger phrases: "/advisor", "consult the advisor", "bounce this off
  <the counterpart>", "second opinion on this", "pair-reason this with me", "what would <the
  counterpart> say". NOT a pre-merge gate (audit-cycle), NOT the formal design panel (council), NOT the runtime's
  native same-family advisor — a second powerful lens whose ideas the main model consolidates into
  its own.
---

# Cross-Model Advisor — a peer, not a judge

One strong model reasoning alone converges on its own family's blind spots. This skill gives the
main session a standing **peer reasoning partner** from a genuinely different model family — the
project binding names the concrete counterpart model and its dispatch mechanics.

**The genre is the whole point.** The harness already has adversarial *gates* (audit-cycle,
council) that return severity-rated findings. This is the other thing: **thinking together.**
*(Receipt: the first "advisory" consult this harness ever ran came back as a C/H/M/L findings
list — the dispatcher had shaped the output contract like an audit, and the genre followed the
shape. The operator's correction created this skill.)*

## When to invoke

- **Load-bearing decisions** — architecture choices, approach selection, anything a decision
  packet will carry to the operator.
- **New designs** — before formal machinery (a council, a spec ladder) is convened; the advisor
  sharpens what the gates later judge.
- **Roadblocks** — two or more failed approaches on the same problem; you need a different head,
  not a harder push.
- **Deep reasoning** — first-principles arcs, challenges to settled architecture, "should this
  exist at all" questions.
- **PRESUMED-MANDATORY when the main loop runs below the project's frontier tier** (quota
  exhaustion, guardrail fallback): skipping the consult on a load-bearing decision there requires
  a stated reason. A below-frontier main paired with a frontier cross-model peer is the cheapest
  quality recovery available.
- **FORCED — the operator says "reason deeply" / "think deeply" about something** (operator
  directive 2026-07-15): those words ARE the invocation, whatever the topic's apparent size.
  "Deeply" means the paired cross-model lens, not solo rumination — do not satisfy it with a
  longer internal think.

**Not for**: routine implementation, small fixes, mechanical questions with checkable answers,
anything currently inside an audit-cycle or council sitting (those gates own their own lenses).
Invoked often ≠ invoked always.

## The three modes

### 1. `think-with` (default) — blind-first deep consult

The anti-anchoring protocol, two calls on one continued counterpart session:

1. **Blind pass.** Send the problem, the constraints, and pointers to the relevant files —
   **WITHOUT your current lean**. Ask for the counterpart's independent position: how would IT
   approach this, what does it see as the crux, what would it do?
2. **Reveal pass** (continue the same counterpart session). Now send your lean + reasoning. Ask it
   to: **steelman your approach first** (articulate the strongest case for it — critique is earned
   by first showing it understood), then challenge it, then **reconcile** with its own blind-pass
   position: where do the two reads genuinely differ and why?

Order matters: critique-after-reveal collapses into agreement bias; position-before-reveal is what
makes the second family a second lens. (Both passes ride ONE counterpart conversation — the
binding names the continuation mechanism.)

### 2. `dialogue` — multi-turn pair reasoning

For roadblocks and first-principles arcs where one round can't converge. Same start as
`think-with`, then keep the conversation going: answer its questions, push back, refine —
**cap ~3 rounds** (a dialogue that hasn't converged in 3 needs the operator or a spike, not more
tokens). Genuine back-and-forth: respond to ITS points, don't re-send your position louder.

### 3. `devil` — stance-assigned challenge

Explicitly assign the stance: *"argue AGAINST this approach at full strength"* or *"steelman the
alternative I rejected."* Not theater — the strongest real case, project-specific, no strawmen.
**The stance guardrail rides every devil prompt**: *the stance shapes HOW you present, never
WHETHER you acknowledge fundamental truths — a genuinely good idea is acknowledged regardless of
stance; a genuinely bad one is called out regardless of stance.* (A devil that manufactures a fake
case for a bad idea is worse than no devil.)

## The advisor prompt — standing ingredients (compose per consult)

Every consult prompt carries these, adapted:

- **Peer framing**: "You are an equally senior engineering thought-partner reasoning WITH a peer
  agent, extending its thinking — not delivering an isolated verdict. No filler, no praise,
  depth over breadth."
- **The anti-overengineering guardrail** (near-verbatim from the ecosystem, kept because it's
  cheap and high-leverage): "Overengineering is an anti-pattern — do not suggest solutions that
  introduce unnecessary abstraction, indirection, or configuration in anticipation of complexity
  that does not yet exist."
- **Ground, don't guess**: it has repo read access — instruct it to READ the files it needs and
  cite paths; a claim about the codebase names the file it rests on. If it lacks context, it asks
  — never invents.
- **Output contract (the anti-audit teeth)**: positions + reasoning + confidence in prose;
  questions back at the dispatcher; close with **"what would change my mind."**
  **BANNED in this skill: severity tags (C/H/M/L), numbered findings lists, ship-it/rethink-it
  verdicts, fixed report sections.** If the reply comes back audit-shaped anyway, the dispatch
  prompt was wrong — fix the prompt, don't relay the verdict.

## Authority + the consolidation duty

The main session keeps authority — the advisor is never prescriptive. But **listen ≠ skim**:

- **Engage every substantive point** — adopt it, or say why not. A consult you don't engage with
  was a wasted call and a pretend process.
- **Record the residue** where the decision lives (the decision packet, the design doc, the
  journal): one line per significant adopted/rejected idea. When the consult materially shaped a
  decision the operator ratifies, the decision packet's "watch out" line quotes the advisor's
  strongest dissent — from it, not paraphrased into mush.
- "What would change my mind" is a **closing probe for reasoning quality** — never an
  "are you sure?" retry loop (re-prompted models flip-flop; probe the reasoning, don't shake it).

## Boundaries (what this is NOT)

- **Not `audit-cycle`** — the pre-merge gate on artifacts; severity vocabulary lives there.
- **Not `council`** — the formal multi-seat panel at its two phase gates. The advisor is upstream
  and informal; a design the advisor helped shape still faces the full council cold.
- **Not the runtime's native advisor** (where one exists) — that's same-family and automatic at
  junctions; this is deliberately cross-family and deliberately invoked. They stack.
- **Not an implementer** — the counterpart is dispatched read-only; it reasons, you act.

## Mechanics

The project binding names: the counterpart model pin + effort, the dispatch command, the
continuation mechanism for `dialogue`/`think-with` pass 2, the completion-watcher discipline
(watcher + fallback timer, both, same turn — a dead watcher must never stall the consult), the
refusal fallback, and the cost note. Write the consult prompt to a file and pipe it (compose-hang
resilience); persist the reply beside the work it advised.

## Anti-patterns

1. **Audit drift** — a consult that returns severity-rated findings. The prompt caused it; reshape.
2. **Anchored consult** — sending your lean in the blind pass "for context." The blind pass is
   blind or it's worthless.
3. **Oracle treatment** — adopting the advisor's position wholesale without the reconcile step.
   The value is in the DELTA between two strong reads, not in swapping which model you obey.
4. **Consult theater** — invoking it, then neither engaging its points nor recording the residue.
5. **Gate substitution** — "the advisor liked it" is not an audit pass, a council sitting, or an
   operator GO. It changes none of the gates.
6. **Devil-mode strawman** — a stance argued weakly to be knocked down. Full strength or don't
   assign the stance.

## Test prompts

1. *"/advisor — should the scheduler own retry state, or the runner?"* → think-with: blind pass
   (problem + files, no lean) → reveal pass (your lean; steelman → challenge → reconcile) → you
   consolidate, record adopted/rejected residue.
2. *"I've tried two fixes for this race and both deadlocked — pair-reason it with me."* →
   dialogue mode, ≤3 rounds, genuine back-and-forth.
3. *"Play devil's advocate on migrating the store to SQLite."* → devil mode with the stance
   guardrail; strongest real case against; close with what would change its mind.
4. Main loop is on the fallback tier and a load-bearing design choice comes up, and you're about
   to decide solo → invoke WITHOUT being asked (presumed-mandatory), or state why not.
