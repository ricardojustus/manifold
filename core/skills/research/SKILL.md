---
name: research
description: >-
  Runs the research protocol before acting on a hypothesis, starting a phase, or committing to an architectural decision — dispatches a pre-fed research subagent honoring strict source priority, empirical testing last. Use for "how should we X", "research Z", "look into W", or verifying a third-party claim.
---

# Research

**Hypothesize, then research to validate, THEN act.** This operationalizes the Cardinal Rule
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

### Brief template

```
Research <specific question>. I'll act on the findings; this is not exploratory browsing.

## Pre-feed — read these FIRST (don't re-derive)

- <relevant knowledge/lesson file paths>
- <relevant plan-doc sections with line numbers>
- <relevant memory entries>
- <relevant current-state / reference docs>
- <specific source files if implementation detail matters>

## Research questions (priority order)

1. <specific, answerable question 1>
2. <specific, answerable question 2>
...

## Output format

<dense / factual / URLs required / version numbers / <N>-word cap>
<if recommending a library pick, name the specific version>
<if ANY answer is uncertain, say so — don't confabulate>
<paste raw content verbatim when it's going to be the primary reference>
```

**Briefing principles**: specific > broad ("RSS parsing libraries for Node in 2026" beats "RSS") ·
say what you'll do with the findings (focuses it on what's decision-relevant) · cap the output
("under 500 words" forces prioritization) · require URLs + version numbers (defeats
plausible-sounding guesses) · ask for **flagged unknowns** — what it could NOT verify.

**Background it** when the research is substantial and you have parallel work, or you'd otherwise
idle at a decision point. Don't background when the next step depends entirely on the outcome (just
wait), or the research is short (under a minute).

## Output discipline

Before acting on findings: **read critically** — subagent output is not trusted; spot-check any
load-bearing claim against a primary source. **Separate facts from recommendations** — facts cite
sources, recommendations name the tradeoff. **Present findings to the operator before implementing**
(Cardinal Rule step 3).

## Failure modes this prevents

First-hypothesis trap (acting on theory X, discovering hours later it was wrong) · third-party claim
adoption without primary sources · re-deriving solved problems (the pre-feed defeats this) · stale
information treated as current (dates matter) · empirical-first when docs exist.

## Honest about uncertainty

Conflicting sources, inconclusive data, or no authoritative answer: SAY SO. Confident prose over a
shaky foundation is worse than explicit uncertainty.

- "Research found X, Y, and Z, which disagree. I can't resolve this without an empirical test or
  your input."
- "The docs don't specify this; the most-starred community implementation does X, but I can't
  verify that's officially endorsed."
- "No primary source available — here's what I inferred from `<secondary signal>`, flagged as
  unverified."

## Related

`phase-start` (invokes this in its reading order before any new phase) · `scoped-adversarial-audit`
(the sibling pre-fed-subagent pattern, for adversarial review of a code surface) · `brief-authoring`
(the full dispatched-brief discipline — a research brief is one instance) · the constitution's
**Cardinal Rule** + **Grounding Claims in Source**.
