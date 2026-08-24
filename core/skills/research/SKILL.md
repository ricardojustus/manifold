---
name: research
description: >-
  Runs the research protocol before acting on a hypothesis, starting a phase, committing to an architectural decision, updating a runtime/CLI/SDK/language dep or any tool, or debugging something unfamiliar. Use for "how should we X", "research Z", "look into W", or verifying a third-party claim.
---

# Research

**Hypothesize, then research to validate, THEN act.** This operationalizes the research protocol
(`HYPOTHESIZE → RESEARCH → PRESENT → IMPLEMENT`) plus the pre-feed rule for dispatched agents.
Skipping it is how sessions spend hours fixing the wrong thing.

## When to invoke

**Always, before**: a **phase start** (new milestone, subsystem, component, skill file — before
forming any design hypothesis) · **architectural decisions** (library picks, integration patterns,
security-posture or permission-model changes) · **third-party claims** (video demos, blog posts,
another model's recommendation, "someone said" — all hypotheses until primary-sourced) ·
**updates** to the runtime/CLI, SDKs, language deps, any tool (the
*never-update-without-assessment* rule) · **debugging something unfamiliar** (research before
theorizing).

**Useful, before**: proposing a significant refactor · recommending an approach the operator hasn't
directed · any "I think this is probably X" moment — catch yourself, stop, research.

**Skip when**: the operator explicitly directed the action ("just do X") — respect it · the answer
is definitely in project code/docs readable in under two minutes · the question is about the
project's *own* current state (`git log`, the state snapshot, the lessons store — that's reading,
not research).

## Source priority (strict order)

> Project bindings may prepend or amend steps — read the "## Project bindings" section (end of file) before the first step.

Top-down; don't skip to web sources until the project-internal layers are exhausted. The **binding
names the concrete sources at each rung**; the order is universal.

1. **Project knowledge base** — prior lessons, distilled solutions, the security baseline. Grep the
   topic FIRST; a solved problem shouldn't be re-solved.
2. **Project plans + current-state docs** — architecture decisions and phase intent (plans), and
   what's actually running now (reference docs). When these disagree, current-state wins for "what
   is", plan wins for "where we're headed".
3. **Official docs of the project's stack** — runtime, SDK, API, language/framework. Primary source
   beats memory.
4. **Vetted community sources** — repos with meaningful stars/activity, authoritative writeups,
   upstream issue trackers. Weight by provenance + date.
5. **Empirical testing** — ONLY after exhausting docs with no authoritative answer. **State
   explicitly when you shift into this mode** ("docs don't cover this; switching to an empirical
   probe").

**When docs contradict observed behavior**: trust what the system actually does. Flag the
discrepancy; verify with the operator before acting on either.

## Dispatching a research subagent

Research is almost always a subagent task — it protects the main context from raw source material
and lets you work in parallel.

**The pre-feed rule (non-negotiable)**: ALWAYS include the relevant rank-1 project sources (lesson
paths, plan-doc sections with line numbers, memory entries, current-state docs) in the brief as the
sources to read FIRST. Otherwise the subagent re-derives settled knowledge and misses
project-specific nuance the internal sources already captured.

### The brief

Author it with `brief-authoring`. Four things a research brief adds:

- **Pre-feed, read FIRST** — the rank-1 project sources (lesson paths, plan-doc sections with line
  numbers, memory entries, current-state / reference docs, specific source files where
  implementation detail matters), marked "don't re-derive".
- **Research questions in priority order** — specific and answerable ("RSS parsing libraries for
  Node in 2026" beats "RSS"), plus what you'll do with the findings (focuses it on what's
  decision-relevant).
- **Output format** — dense / factual · URLs + version numbers required (defeats
  plausible-sounding guesses; name the specific version for a library pick) · an `<N>`-word cap
  ("under 500 words" forces prioritization) · raw content pasted verbatim where it will be the
  primary reference.
- **Flagged unknowns** — what it could NOT verify; if any answer is uncertain, say so, don't
  confabulate.

**Background it** when the research is substantial and you have parallel work, or you'd otherwise
idle at a decision point. Don't background when the next step depends entirely on the outcome (just
wait), or the research is short (under a minute).

## Output discipline

Before acting on findings: **subagent output is not trusted** — floor wall 7 (never confabulate on
deliverable surfaces) applies to every load-bearing claim it returns. **Separate facts from
recommendations** — facts cite sources, recommendations name the tradeoff. **Present findings to
the operator before implementing** (the research protocol's PRESENT step).

**Name the shape of the uncertainty, not just its presence** — conflicting sources, an unendorsed
community answer, and an inference from a secondary signal are three different results, and the
operator acts differently on each: "X, Y and Z disagree; unresolvable without an empirical test or
your input" · "the docs don't specify it; the most-starred implementation does X, officially
endorsed unverified" · "no primary source — inferred from `<secondary signal>`, flagged unverified".

## Related

the judgment for when research is enough to act on · the GROUND-FIRST disposition (facts core —
invokes this in its reading order before any new phase) · an `audit-cycle` round scoped to the
surface (the sibling pre-fed-subagent pattern, for adversarial review of a code surface) ·
`brief-authoring` (the full dispatched-brief discipline — a research brief is one instance) · the
research protocol above + floor wall 7 (never confabulate on deliverable surfaces).
