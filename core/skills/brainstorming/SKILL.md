---
name: brainstorming
description: >-
  Run a Socratic GENERATIVE design interview to produce a Vision draft — for BEFORE
  a vision exists. This is upstream of the methodology's Phase 1; the Council is the
  adversarial DOWNSTREAM gate that challenges the vision this produces (don't
  conflate them). Procedure: one question at a time, never a questionnaire dump;
  sequence goals → constraints → 2-3 genuinely different approaches → challenge
  assumptions and probe trade-offs → converge. Output = a Vision draft in the shape
  METHODOLOGY.md Phase 1 expects, ready for Gate A / the Council. Carries the
  interviewing discipline: don't lead the witness, surface the option the operator
  hasn't considered, name disagreement plainly, stop when new questions stop
  changing the draft. Use when the operator says "help me think through X" or
  "brainstorm", before any vision exists. Neighbors: council (adversarial review of
  the output), research (for unknowns that surface), spec-writing (much later).
---

# Brainstorming — the generative front-end to a Vision

*Pattern from obra/superpowers (MIT), rewritten for this harness's methodology (it feeds Phase 1)
and its Council (which challenges what this produces).*

Most bad builds are bad Visions that were never interrogated — the expensive mistakes live in
"what are we even building," and they are cheapest to catch before a single plan or spec exists.
This skill is the *generative* half of that: a Socratic interview that helps the operator find
the right thing to build and writes it into a Vision draft. It is deliberately separated from the
Council, which is the *adversarial* half.

**Where it sits (do not conflate the two directions):**
- **Brainstorming (this skill) is GENERATIVE and UPSTREAM.** It runs *before* a Vision exists and
  produces one. Its stance is collaborative discovery.
- **The Council is ADVERSARIAL and DOWNSTREAM.** It runs at Gate A / Phase 5 to *challenge* an
  existing Vision (and Plan). Its stance is "why is this wrong."

You brainstorm to create the vision the Council later tries to break. Running the Council on a
vision that was never brainstormed means the panel does generative work it isn't shaped for; this
skill fills that gap.

## The one-question rule

**Ask one question at a time. Never dump a questionnaire.** A wall of ten questions gets a thin
answer to each and buries the one that mattered. A single, well-aimed question gets a real answer
that *shapes the next question* — the interview adapts to what you learn. This is the single most
important discipline in the skill; a questionnaire is not a brainstorm, it's a form.

After each answer: reflect it back in one line to confirm you heard it, then ask the next thing
the answer made relevant. Let the operator's answers drive the branch order — the sequence below
is a spine, not a script.

## The sequence (a spine, not a script)

1. **Goals — what is this actually for?** Start with the problem, not the solution. What outcome
   does the operator want; who is it for; what does the world look like when it works. Resist
   jumping to "how" — a solution proposed before the goal is clear is a guess wearing confidence.
2. **Constraints — what boundaries are real?** What must be true (platform, cost, time, existing
   systems it has to fit), what's explicitly out of scope, what's fixed versus negotiable.
   Constraints are generative, not limiting: they cut the option space to the ones that could
   actually ship.
3. **2-3 genuinely different approaches.** Not one plan with variations — two or three *materially
   different* ways to meet the goals (e.g. minimal-change vs clean-rebuild vs pragmatic-middle).
   For each, name what it optimizes for and what it costs. If you can only think of one, you
   haven't explored enough — push for the approach the operator hasn't considered.
4. **Challenge assumptions and probe trade-offs — gently.** Surface the load-bearing assumptions
   under the favored approach and test them: "this assumes X — is that true?" Probe the trade-offs
   between the approaches honestly. Gently: the goal is to stress the idea, not the person.
5. **Converge.** Once the approaches have been weighed, help the operator pick a direction and
   sharpen it into the Vision draft below.

## Interviewing discipline

The quality of the brainstorm is the quality of the interviewing. Hold these throughout:

- **Don't lead the witness.** Ask open questions, not ones with the answer baked in ("wouldn't it
  be better to…"). Leading questions get you your own idea echoed back, which teaches you nothing.
- **Surface the option the operator hasn't considered.** Your value is the alternative they can't
  see from inside the problem — the third approach, the constraint they forgot, the simpler thing
  that might just work. Offer it as a question, not a verdict.
- **Name disagreement plainly.** If you think the favored direction is wrong, say so with your
  reasoning — don't validate-then-undermine. Honest disagreement early is cheap; a Vision that
  ships a flaw because no one challenged it is not. (This is the same intellectual-honesty posture
  the constitution requires under pushback.)
- **Know when to stop.** The interview is done when new questions stop changing the draft —
  when you're polishing, not discovering. Stopping early leaves the Vision half-formed; grinding
  past convergence wastes the operator's time. Convergence, not exhaustion, is the exit.

## The output — a Vision draft Phase 1 can accept

Brainstorming ends with an artifact, not just a good conversation. Write a **Vision draft** in the
shape `.claude/harness/METHODOLOGY.md` Phase 1 expects, so it drops straight into the loop:

- **The problem** — what this is for and who it serves (from step 1).
- **The chosen approach** — the direction converged on, and a one-line note on the alternatives
  considered and why this one (from steps 3-5), so the Council sees the road not taken.
- **Constraints / scope** — what's in, what's out (from step 2).
- **Acceptance criteria / definition of done** — **falsifiable** criteria a third party could
  judge the finished thing against. This is the non-negotiable part: without concrete acceptance
  criteria, the downstream audits and Council have nothing objective to check and degrade into
  opinion. If the brainstorm can't produce falsifiable criteria yet, that itself is a finding —
  the goal isn't clear enough to build.

Hand this draft to Gate A / the Council for adversarial review. It is a draft, not a lock: the
Council may send it back, and that loop is the methodology working.

## When to invoke

- The operator says "help me think through X", "brainstorm", "I have a rough idea", "let's figure
  out what to build", "/brainstorming" — anytime there is not yet a Vision.
- Proactively when someone jumps straight to a plan or spec for something whose *goal* was never
  interrogated — back up and brainstorm the vision first.

## Pairs with

- **council** — the adversarial downstream gate that challenges the Vision this produces. Generative
  here, adversarial there; run this first.
- **research** — when the brainstorm surfaces an unknown that needs grounding (a claim to verify,
  a landscape to survey) before the Vision can converge.
- **spec-writing** — much later. Brainstorming shapes the Vision; specs come after the Plan, well
  downstream. Don't skip to spec detail during a brainstorm.
