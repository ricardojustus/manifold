---
name: grilling
description: >-
  Grill the operator relentlessly about a plan, decision, or idea — in frontier rounds, each round
  batching every currently-answerable question, each carrying your recommended answer — until
  shared understanding is reached. Use when the operator wants their thinking stress-tested ("grill
  me", "grill this plan", "poke holes in this"), or when another skill needs a grilling pass
  mid-flow. Sharpens an existing intent, unlike `brainstorming` (which generates one toward a
  Vision draft) and unlike `council` (which convenes a panel against an existing Vision/Plan —
  grilling is a live interview with the operator).
---

# Grilling

Interview the operator relentlessly about the plan, decision, or idea until you reach a **shared
understanding**. Map it as a **design tree**: every decision branches into the decisions that hang
off it.

## The rounds

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already
settled — the questions you can ask *now* without guessing at answers you haven't heard yet. Ask
the whole frontier in one round: number each question and give your recommended answer, then wait
for the operator's answers before the next round.

Each question is formatted like so:

```
❓ **Q1** - **<question title>**: <question body, might be multiple paragraphs, including multiple choices>

➡️ <your recommended answer>
```

- **Every question carries your recommended answer** — the operator reacts to a lean, never
  chooses blind.
- **A question that depends on another question still open this round belongs to a later round.**
- **Each answered round reshapes the tree.** Settled decisions push the frontier outward and
  unblock the questions that hung off them. Recompute the frontier and ask the next round.
- **Facts are your legwork; decisions are theirs.** Where a frontier question needs a fact from
  the environment (filesystem, tools, docs), dispatch a subagent to find it rather than asking for
  anything you could look up yourself. Don't block on it: a running exploration is an unsettled
  prerequisite, so only the questions downstream of it wait for the subagent to report — ask the
  rest of the frontier now. The decisions are the operator's: put each to them and wait.
- **Capture as you go.** A decision settled mid-grill is filed to the project's memory store at
  the moment it lands (the file-at-the-event rule) — the interview is not a substitute for the
  record.

## Completion and exit

The session is done when the frontier is empty — every branch of the design tree visited, nothing
left silently assumed — and the operator confirms shared understanding. **Do not act on the
material until they confirm.**

Grilling produces alignment, never authorization: a grill that ends in a decision to build hands
off to the project's normal gates (decision packet, spec, review ladder). A grilled answer
settles what it explicitly names; where the harness owes a decision packet — reserved-authority
and security-posture calls — the grill produces the packet, not the ruling.

One more exit: a grill whose frontier keeps growing faster than the rounds retire it — more
decisions than the sitting can hold — promotes to a `wayfinder` map mid-flight; the answers
already settled land in the map's **Decisions so far**, and the questions it couldn't settle
become its first tickets.

## Composition

The loop is unchanged when embedded in another skill's flow; the invoking skill owns what happens
with the answers.
