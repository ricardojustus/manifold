---
name: grilling
description: >-
  Grill the operator relentlessly about a plan, decision, or idea — one question at a time, each
  carrying your recommended answer — until shared understanding is reached. Use when the operator
  wants their thinking stress-tested ("grill me", "grill this plan", "poke holes in this"), or when
  another skill needs a grilling pass mid-flow. Sharpens an existing intent, unlike `brainstorming`
  (which generates one toward a Vision draft) and unlike `council` (which convenes a panel against
  an existing Vision/Plan — grilling is a live interview with the operator).
---

# Grilling

Interview the operator relentlessly about every aspect of the plan, decision, or idea until you
reach a **shared understanding**. Walk down each branch of the decision tree, resolving
dependencies between decisions one by one.

## The loop

- **One question at a time.** Ask, then wait for the answer before continuing. Asking multiple
  questions at once is bewildering.
- **Every question carries your recommended answer** — the operator reacts to a lean, never
  chooses blind.
- **Facts are your legwork; decisions are theirs.** If a fact can be found by exploring the
  environment (filesystem, tools, docs), look it up rather than asking. The decisions, though,
  belong to the operator — put each one to them and wait.
- **Sequence by dependency.** Ask the questions whose answers unlock other questions first.
- **Capture as you go.** A decision settled mid-grill is filed to the project's memory store at
  the moment it lands (the file-at-the-event rule) — the interview is not a substitute for the
  record.

## Completion and exit

The session is done when every branch of the decision tree has been visited and the operator
confirms shared understanding — nothing left silently assumed. **Do not act on the material until
they confirm.**

Grilling produces alignment, never authorization: a grill that ends in a decision to build hands
off to the project's normal gates (decision packet, spec, review ladder). A grilled answer
settles what it explicitly names; where the harness owes a decision packet — reserved-authority
and security-posture calls — the grill produces the packet, not the ruling.

One more exit: a grill that keeps hitting "depends on X, which depends on Y" — more decisions
than the sitting can hold — promotes to a `wayfinder` map mid-flight; the answers already
settled land in the map's **Decisions so far**, and the questions it couldn't settle become
its first tickets.

## Composition

The loop is unchanged when embedded in another skill's flow; the invoking skill owns what happens
with the answers.
