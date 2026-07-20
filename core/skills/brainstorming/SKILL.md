---
name: brainstorming
description: >-
  Runs a Socratic generative design interview — one question at a time, goals, constraints, 2-3 genuinely different approaches, converge — producing a Vision draft with falsifiable acceptance criteria. Use BEFORE a vision exists: "help me think through X", "brainstorm", "/brainstorming". Upstream of council.
---

# Brainstorming — the generative front-end to a Vision

The expensive mistakes live in "what are we even building," and they are cheapest to catch before
a plan or spec exists. This skill is the *generative* half: a Socratic interview that helps the
operator find the right thing to build and writes it into a Vision draft.

**Where it sits (do not conflate the two directions):**
- **Brainstorming (this skill) is GENERATIVE and UPSTREAM.** It runs *before* a Vision exists and
  produces one. Its stance is collaborative discovery.
- **The Council is ADVERSARIAL and DOWNSTREAM.** It runs at Gate A / Phase 5 to *challenge* an
  existing Vision (and Plan). Its stance is "why is this wrong."

You brainstorm to create the vision the Council later tries to break.

## The one-question rule

**Ask one question at a time. Never dump a questionnaire.** A wall of ten questions gets a thin
answer to each and buries the one that mattered. A single well-aimed question gets a real answer
that *shapes the next question*. This is the single most important discipline in the skill.

After each answer: reflect it back in one line to confirm you heard it, then ask the next thing
the answer made relevant. Let the operator's answers drive the branch order.

## The sequence (a spine, not a script)

1. **Goals — what is this actually for?** Start with the problem, not the solution. What outcome
   does the operator want; who is it for; what does the world look like when it works. Resist
   jumping to "how" — a solution proposed before the goal is clear is a guess wearing confidence.
2. **Constraints — what boundaries are real?** What must be true (platform, cost, time, existing
   systems it has to fit), what's explicitly out of scope, what's fixed versus negotiable.
   Constraints are generative, not limiting: they cut the option space to what could actually ship.
3. **2-3 genuinely different approaches.** Not one plan with variations — two or three *materially
   different* ways to meet the goals (e.g. minimal-change vs clean-rebuild vs pragmatic-middle).
   For each, name what it optimizes for and what it costs. If you can only think of one, you
   haven't explored enough — push for the approach the operator hasn't considered.
4. **Challenge assumptions and probe trade-offs — gently.** Surface the load-bearing assumptions
   under the favored approach and test them: "this assumes X — is that true?" Probe the trade-offs
   between approaches honestly. Gently: stress the idea, not the person.
5. **Converge.** Once the approaches have been weighed, help the operator pick a direction and
   sharpen it into the Vision draft below.

## Interviewing discipline

- **Don't lead the witness.** Ask open questions, not ones with the answer baked in ("wouldn't it
  be better to…") — leading questions get your own idea echoed back.
- **Surface the option the operator hasn't considered.** Your value is the alternative they can't
  see from inside the problem. Offer it as a question, not a verdict.
- **Name disagreement plainly.** If the favored direction is wrong, say so with your reasoning —
  don't validate-then-undermine. (Same posture the constitution requires under pushback.)
- **Know when to stop.** The interview is done when new questions stop changing the draft — when
  you're polishing, not discovering. Convergence, not exhaustion, is the exit.

## The output — a Vision draft Phase 1 can accept

Brainstorming ends with an artifact, not just a good conversation. Write a **Vision draft** in the
shape `.claude/harness/METHODOLOGY.md` Phase 1 expects:

- **The problem** — what this is for and who it serves (from step 1).
- **The chosen approach** — the direction converged on, plus a one-line note on the alternatives
  considered and why this one (steps 3-5), so the Council sees the road not taken.
- **Constraints / scope** — what's in, what's out (step 2).
- **Acceptance criteria / definition of done** — **falsifiable** criteria a third party could judge
  the finished thing against. Non-negotiable: without concrete acceptance criteria the downstream
  audits and Council have nothing objective to check and degrade into opinion. If the brainstorm
  can't produce falsifiable criteria yet, that itself is a finding — the goal isn't clear enough
  to build.

Hand this draft to Gate A / the Council for adversarial review. It is a draft, not a lock: the
Council may send it back, and that loop is the methodology working.

## When to invoke

- The operator says "help me think through X", "brainstorm", "I have a rough idea", "let's figure
  out what to build", "/brainstorming" — anytime there is not yet a Vision.
- Proactively when someone jumps straight to a plan or spec for something whose *goal* was never
  interrogated — back up and brainstorm the vision first.

## Pairs with

- **council** — the adversarial downstream gate that challenges the Vision this produces. Run this
  first.
- **research** — when the brainstorm surfaces an unknown that needs grounding before the Vision
  can converge.
- **spec-writing** — much later. Brainstorming shapes the Vision; specs come after the Plan. Don't
  skip to spec detail during a brainstorm.
