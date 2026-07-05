---
name: research
description: Run the research protocol before acting on any hypothesis, building a non-trivial feature, starting a new phase, or committing to an architectural decision — dispatch a research subagent pre-fed with the project's own knowledge so it doesn't re-derive settled facts. Honors a strict source-priority order: the project's knowledge base and plans first, official docs of the stack next, vetted community sources after, empirical testing last (say so when you switch to it). Use when the operator asks "how should we X" / "is it worth Y" / "research Z" / "look into W", at any phase-start, before proposing a design change, or when a third-party claim (a video, a blog, another model's advice) needs primary-source verification — third-party claims are hypotheses to verify, not conclusions to adopt. NOT adversarial code review (use scoped-adversarial-audit); NOT whole-subsystem inventory (use system-audit).
---

# Research

The core discipline: **hypothesize, then research to validate, THEN act.** This skill operationalizes the Cardinal Rule (the constitution's `HYPOTHESIZE → RESEARCH → PRESENT → IMPLEMENT`) plus the pre-feed rule for dispatched agents.

Most of the worst failures come from skipping research: forming a theory, treating it as fact, acting on it, then wasting hours fixing the wrong thing. The Cardinal Rule is a structural fix for that, not a vibe.

## When to invoke

### Always — before any of these

- **Phase start**: new milestone, new subsystem, new component, new skill file. Before forming any hypothesis about design.
- **Architectural decisions**: library picks, integration patterns, security-posture changes, permission-model changes.
- **Third-party claims**: video demos, blog posts, another model's recommendation, "someone said" — all hypotheses until primary-sourced.
- **Updates**: the runtime/CLI, SDKs, language deps, any tool (the *never-update-without-assessment* rule).
- **Debugging something unfamiliar**: when you don't immediately know the cause, research before theorizing.

### Useful — before many of these

- Proposing a significant refactor
- Recommending an approach the operator hasn't explicitly directed
- Any "I think this is probably X" moment — catch yourself, stop, research

### Skip when

- The operator has explicitly directed the action ("just do X") — respect the direction; don't research to second-guess.
- The answer is definitely in existing project code / docs you can read directly in under two minutes.
- The question is about the project's *own* current state — run `git log`, read the state snapshot, grep the lessons store. That's not research, that's reading.

## Source priority (strict order)

Research happens top-down. Don't skip to web sources until the project-internal layers are exhausted. The **project binding names the concrete sources at each rung** (which lesson store, which plan docs, which official-doc URLs); the order itself is universal:

1. **Project knowledge base** — prior lessons, distilled solutions, the security baseline. Grep for the topic FIRST; a solved problem shouldn't be re-solved.
2. **Project plans + current-state docs** — architecture decisions, phase intent (plans), and what's *actually running* now (reference/current-state docs). When these disagree, current-state wins for "what is", plan wins for "where we're headed".
3. **Official docs of the project's stack** — the runtime, the SDK, the API, the language/framework the project is built on. Primary source beats memory.
4. **Vetted community sources** — repos with meaningful stars/activity, authoritative technical writeups, upstream issue trackers. Weight by provenance + date.
5. **Empirical testing** — ONLY after exhausting docs and finding no authoritative answer. **State explicitly when you shift into this mode** ("docs don't cover this; switching to an empirical probe").

**When docs contradict observed behavior**: trust what the system actually does. Flag the discrepancy; verify with the operator before acting on either.

## How to dispatch a research subagent

Research is almost always a subagent task — it protects the main context from being flooded with raw source material and lets you do other work in parallel.

### The pre-feed rule (non-negotiable)

ALWAYS include the relevant rank-1 project sources (lesson paths, plan-doc sections with line numbers, memory entries, current-state docs) in the subagent's brief as the sources to read FIRST. Otherwise the subagent re-derives settled knowledge — wastes time and often misses project-specific nuance the internal sources already captured.

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

### Briefing principles

- **Specific > broad.** "RSS parsing libraries for Node in 2026" beats "RSS". The more specific, the higher the signal.
- **Say what you'll do with the findings.** "I'm building X, weighing Y vs Z, need the tradeoff." Lets the subagent focus on what's decision-relevant.
- **Cap the output.** "Under 500 words" forces prioritization. Unbounded outputs are harder to read and often lower quality.
- **Require URLs + version numbers.** Defeats plausible-sounding guesses.
- **Ask for "flagged unknowns"** — what the subagent could NOT verify. Better to know the gaps than read confident prose over a shaky foundation.

### When to run in background

Background the research when it's substantial and you have other work to do in parallel, or you're at a decision point where you'd otherwise idle. Don't background when the next step depends entirely on the outcome (just wait), or the research is short (under a minute).

## Output discipline

When findings come back, before acting:

- **Read critically.** Don't treat subagent output as trusted. Spot-check any claim that feels load-bearing — reproduce it against a primary source.
- **Separate facts from recommendations.** Facts cite sources. Recommendations should name the tradeoff.
- **Present findings to the operator before implementing** (Cardinal Rule step 3). Let them redirect if their priors differ.

## Common failure modes this prevents

- **First-hypothesis trap**: forming theory X, acting on it, discovering hours later it was wrong. The research step catches this before the investment. *Receipt: sessions have burned hours fixing the wrong thing because the first plausible cause was treated as the answer instead of the start of the search.*
- **Third-party claim adoption**: believing a video / another model / "someone said" without checking primary sources. Verify BEFORE acting.
- **Re-deriving solved problems**: building something the knowledge base already has a solution for. The pre-feed step defeats this.
- **Stale information**: acting on years-old advice as if current. Source priority puts docs over blog posts; dates matter.
- **Empirical-first when docs exist**: running experiments to discover what the docs already say — slower and less reliable than reading them.

## Honest about uncertainty

If research returns conflicting sources, inconclusive data, or simply no authoritative answer: SAY SO. Confident prose over a shaky foundation is worse than explicit uncertainty.

- "Research found X, Y, and Z, which disagree. I can't resolve this without an empirical test or your input."
- "The docs don't specify this; the most-starred community implementation does X, but I can't verify that's officially endorsed."
- "No primary source available — here's what I inferred from `<secondary signal>`, flagged as unverified."

## Related

- **`phase-start`** — invokes this skill as part of its reading order before any new phase.
- **`scoped-adversarial-audit`** — the sibling pre-fed-subagent pattern, but for *adversarial review* of a code surface, not knowledge-gathering.
- **`brief-authoring`** — the full discipline for any dispatched-agent brief (GIVEN block, grep-verified references, ambiguity protocol); a research brief is one instance of it.
- The constitution's **Cardinal Rule** + **Grounding Claims in Source** — the doctrine this skill enforces.
