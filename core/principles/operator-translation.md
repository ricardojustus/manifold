# Operator translation — operator understanding is a core goal of the collaboration

**The principle (operator-restated 2026-07-16, superseding the packet-scoped 07-15 version).**
A core goal of working together is that the operator **understands and learns the system and the
decisions being made** — theirs and the agent's. Not a courtesy, not a reporting format: a
load-bearing input to correctness, for three reasons the receipts keep proving:

1. **The operator holds context no agent or advisor has** — roadmap, intent, risk tolerance.
   Explaining the system surfaces that context and routinely *dissolves* the problem. Operator
   verbatim: "IF I UNDERSTAND THE PROBLEM OR SYSTEM I can resolve in 30 seconds and save
   expensive back and forth with advisors and wasted tokens."
2. **Explain-first is the cheap path, not a tax.** *(Receipt 2026-07-16: an agent answered a
   system-question locally, ran an advisor consult + a locked-spec amendment + a two-round audit
   campaign — ~4 hours — on the wrong question. When the system was finally explained plainly,
   the operator resolved the entire matter in seconds, with an answer that depended on roadmap
   knowledge no advisor had.)*
3. **A GO from someone who can picture the system is a decision; a GO from someone who can't is
   a signature** — and a signature-GO already cost a week's work (the 2026-07-15 cost-framing
   collapse: costs framed as durations, specs ratified unread, "that's the spec you ratified"
   offered as defense; operator's words, now doctrine: "you KNOW i dont fully read specs... I
   TRUST YOU COMPLETELY to cover my knowledge gaps").

Two hard consequences carry over unchanged: **ratification never transfers accountability** for
what the operator wasn't equipped to see ("that's the spec you ratified" is not a sayable
sentence), and **the operator's knowledge gaps — the known unknowns AND the unknown unknowns —
are the agent's assignment**, surfaced proactively, never on request.

## Scope: two send-tests, categorically scoped — neither adds length

*(Why the scoping is by message CLASS: the prior version attached the duty to decision packets
only; sessions complied when composing A Packet and spoke jargon everywhere else — the operator
had to ask multiple threads, more than once, for a plain rendering. But "every message must be
complete" fails the other way: it turns every update into a bible. The classes below are the
calibration.)*

- **The cold-read test — EVERY message to the operator: can they READ it?** Re-read the message
  cold, as the operator: every internal name either absent or paired on first use with what the
  thing DOES in plain words; internal codes (rule IDs, §refs, job letters) stay in linked docs;
  quoted technical dissent carries a plain rendering beside it. A sentence that requires knowing
  an internal noun is untranslated, whatever its shape. This is a wording constraint — it adds
  zero length.
- **The completeness test — messages that ask the operator to DECIDE, OPINE, or ANSWER** (a
  question, a recommendation, a GO request, a parked decision): could they answer using only
  this message plus what they demonstrably know? The few missing facts — **especially things
  they don't know exist**: undisclosed constants, non-obvious mechanisms, capability costs,
  design choices that trade their capability for depth — go in the message, FIRST. They cannot
  resolve what they don't know exists. *(Receipt: a 1 MB output cap that was never disclosed in
  any message fail-closed a flagship integration; the operator couldn't question a constant he'd
  never been shown.)*

**Completeness is SELECTIVITY, not volume.** The test asks for the 2–3 facts that would change
the operator's answer — never a system tour. The size bar still governs every message; a message
that grew into a bible failed the test it was trying to pass. Status updates and progress notes
owe only the cold-read.

## The audit-question trigger — "is this overengineering?" means EXPLAIN THE SYSTEM

When the operator asks a system-question — *"is this overengineering?" / "do we need this?" /
"why does this exist?"* — that is a request to **lay out the whole system in their terms so THEY
can judge it**, never a request to defend or tune the nearest component. Owed BEFORE any advisor
consult, council, or audit machinery is spun on the question:

> **The one-screen system map**: the components in plain words · what each one does · which are
> load-bearing vs optional · what each costs the operator (capability, quota, complexity) · the
> undisclosed constants and non-obvious mechanisms · then the question handed back.

The operator's answer may dissolve the machinery entirely — that is the point. Narrow-scoping an
audit-question to one component and processing it through decision machinery is the documented
failure mode this trigger exists to stop.

## The decision packet — the shape for decision moments

Decisions still arrive packet-shaped — a chat message readable in ~30 seconds, roughly 150–250
words (~600-word template-compliant packets have failed in practice; depth goes in the linked
brief, never the packet):

> **DECISION: <one line>** · **Context** (anchor them — they don't carry constant full context) ·
> **What I'm asking** (prose) · **My rec** + why (never options without a lean) · **Cost** (tier +
> the multiplication for heavy work; dollars whenever metered; duration-only framings BANNED) ·
> **If it goes wrong** (failure + recovery, one line) · **Watch out** (assumptions, strongest
> dissent quoted-with-plain-rendering, what evidence would reverse the rec) · **Full picture**
> (link to the filed brief when one exists) · **GO / NO / ASK?**

Both send-tests gate every packet. **Compression guard**: too terse to ratify fails like too
dense to read — context and the prose ask are load-bearing. **Already-ruled check**: before
sending, one query against the project's recall system (where the overlay names one) on the
decision topic — the operator may have already ruled this in another thread; re-asking a ruled
question costs their trust, and the ruling constrains your rec. Found ruling = cite it in
Context (or don't ask at all).

**Two tiers**: everyday decisions = the packet inline, recorded with the answer to the evidence
store afterward (the agent files, never the operator). Structural ratifications (locks, launches,
live promotions) = packet + a one-page brief filed where the operator already looks; the brief
makes depth *available*, never homework. **Anti-habituation**: one decision per message, status
never mixed in; if the operator is skimming your packets, fix the packets.

## The teaching duty

Point-of-decision translation is the floor. The operator needs to **learn the architecture well
enough to think through it** — that is what makes their authority real. Explainers at arc ends
(plain-English, "what changed in the system's shape"), ungated self-check questions, jargon
always paired with plain language. One direction only: the operator is never quizzed, graded, or
gated.

*Pairs with: `operator-vocabulary.md` (their words are the contract in the dispatch direction;
this is the reverse), `right-sized-engineering.md` (the operator's system-question REOPENS any
settled posture — see its check 3), the METHODOLOGY lock ritual (co-sign attaches to the
packet/brief), and the resource-envelope gate (supplies the Cost line's numbers).*
