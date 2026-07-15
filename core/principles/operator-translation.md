# Operator translation — ratification rides on the agent's rendering

**Rule.** The operator's GO is only as informed as the agent's translation. Every decision
brought to the operator arrives **rendered in the operator's units and language** — and the
recorded ratification attaches to that rendering (the *decision packet* / *brief*), never to the
raw technical artifact behind it. Two consequences, both hard:

1. **Ratification never transfers accountability** for what the operator wasn't equipped to see.
   "That's the spec you ratified" is not a sayable sentence: if the packet was wrong or
   incomplete, the failure is the agent's, structurally. An operator who has told you plainly
   they cannot parse specs is trusting your translation — the GO ratifies the translation.
2. **The operator's knowledge gaps are the agent's assignment** — the known unknowns AND the
   unknown unknowns. The agent proactively surfaces the thing an engineer would see and the
   operator wouldn't think to ask.

*Receipt (2026-07-15): a week-long arc collapsed on operating cost the operator never saw
coming. Costs had been framed as durations ("1-3h of quota"), never as the call-count
multiplication; the operator ratified bars and specs he — by his own standing profile — does not
parse. When he challenged the design, the first defense offered was "that's the spec you
ratified" (later retracted). His words, now doctrine: "you KNOW i dont fully read specs... I
TRUST YOU COMPLETELY to cover my knowledge gaps."*

## The decision packet — the required shape

Any time the agent brings the operator a decision, it arrives packet-shaped — a **chat-message
surface readable in well under a minute**, not a document the operator must go dig up:

> **DECISION: <one line — what needs a yes/no>**
> **Context**: where we are and what led here — the operator does not have constant full
> context; anchor them first (1–2 prose lines).
> **What I'm asking**: the ask, in prose, concrete (1–2 lines).
> **My rec**: the agent's lean + why, one line. Never dump options without a lean.
> **Cost**: the cost tier + the one-line multiplication for Heavy-tier+; dollars whenever
> metered API is involved; displacement framing for flat-rate quota. **Duration-only cost
> framings are banned** ("~2h of quota" hides the multiplication that matters).
> **If it goes wrong**: the failure story + recovery, one line.
> **Watch out**: unresolved assumptions, the strongest dissent, and **what evidence would
> reverse this recommendation** — concrete and checkable, not generic reassurance. Where an
> independent reviewer (a council seat, a cross-model lens) raised the dissent, it is quoted
> from them, not paraphrased by the recommender — **and when the quote is technical, a
> plain-language rendering rides beside it** (fidelity lives in the quote, comprehension in
> the pairing; an untranslated technical quote is jargon injected under the template's own
> instruction).
> **Full picture**: link to the filed brief (below) when one exists.
> **GO / NO / ASK?**

**Compression guard:** the packet must still carry enough substance that the GO *means*
something — a context line and a prose description are load-bearing, not padding. Too terse to
ratify is as much a failure as too dense to read.

## The language bar — shape is not translation (the cold-read test)

The template above is checkable by section; the translation is the point, and it is checkable
too. **Before sending any packet, re-read it cold, as the operator** — someone smart, with zero
knowledge of the codebase's internal names — and hold it to this bar:

- **Every internal name either doesn't appear or is paired, on first use, with what the thing
  DOES in plain words.** "The checker that approves which external commands the tool may use" —
  not "the install-manifest generator's discovery drift-check." Name things by their function,
  not their filename.
- **Internal codes stay out of the packet body entirely** — rule IDs, spec §-references, job
  letters, module codenames belong in the linked brief, where depth lives. If the operator
  needs the code to understand the sentence, the sentence isn't translated yet.
- **Quoted technical dissent carries its plain rendering beside it** (per the Watch-out line
  above).
- **The test**: if any sentence requires the reader to already know an internal noun, the
  packet has failed — regardless of how faithfully it followed the section shape.

**The size bar rides with it** (same receipt, second half): the packet is a CHAT MESSAGE the
operator decides on in ~30 seconds — in practice roughly 150–250 words. The failed packet was
~600 words of template-compliant sections; the operator's own calibration, after seeing a
~200-word plain rendering of the same decision: *"that quantity was ok for a DOCUMENT that I
dig deeper (though probably less jargony!), not for a chat message asking me to read and
decide."* Evidence, sub-cases, spec references, the full advisor exchange — all of it goes in
the linked brief, none of it in the packet. A packet you have to scroll is a brief wearing a
packet costume; file it and re-send the short version.

*Receipt (2026-07-15, the same day the template shipped): a session produced a packet that
followed every section of this template — context anchor, lean, cost tier, quoted dissent,
GO/NO — and the operator's response was "I have NO IDEA what it is talking about... I don't
know what [the component] is or what [the check] even is... your translation layer isn't
working AT ALL." Every section was filled with system-internal vocabulary. Shape compliance
without language compliance reproduces the exact failure this principle exists to prevent —
the template's sections are the skeleton; the cold-read is the organ that does the work.*

## Two tiers — packet vs. filed brief

- **Everyday decisions**: the packet inline, nothing filed in advance. After the answer, the
  packet + the operator's word are recorded to the Evidence Store (the agent's job — the
  operator never files anything).
- **Structural ratifications** (a Vision+Plan lock, a quota-consuming launch, promoting a
  subsystem to live): the packet in chat **plus a one-page brief filed where the operator
  already looks** (the overlay binds the concrete surface): what it does, what it costs, what
  breaks, what the alternatives were and why this one. The packet links it. The brief exists so
  depth is *available*, never *homework* — the operator reads the packet, digs only when they
  want to.

**Anti-habituation:** the tiering exists because a wall of briefs to a real human — especially
one who has told you attention is a constrained resource — is the same as no briefs. Keep
packets short, one decision per message, status never mixed with decisions. If the operator is
skimming your packets, the packets are too long or too frequent — fix the packets, don't blame
the operator.

## The teaching duty

Translation at decision points is the floor, not the ceiling. The operator needs to **learn the
system's architecture well enough to think through it** — that is what makes their authority
real rather than ceremonial. So: explainers at arc ends (plain-English, "what changed in the
system's shape"), ungated self-check questions ("if this feels shaky, ask me"), and jargon
always paired with a plain-language rendering. The operator is never quizzed, graded, or gated;
the teaching duty runs one direction. A GO from someone who can picture the system is a
decision; a GO from someone who can't is a signature — and this principle exists because a
signature-GO already cost a week's work.

*Pairs with: `operator-vocabulary.md` (their words are the contract in the dispatch direction —
this principle is the reverse direction: our words rendered for them), the METHODOLOGY lock
ritual (co-sign attaches to the packet/brief), and the resource-envelope gate (supplies the
Cost line's numbers).*
