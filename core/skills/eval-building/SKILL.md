---
name: eval-building
description: >-
  Builds an empirical eval measuring whether a feature or agent-run actually works — pre-register the decision first, separate fixture corpus / system-under-test / grader, climb the cheapest-grader ladder (deterministic → LLM judge → human). Use for "build an eval", "bake-off", "quality regression", "A/B this", "is X better".
---

# Eval-building — measure whether it actually works

An eval is a measurement instrument: a locked set of tasks, a system under test, and a grader —
built so a number (or a pass/fail per case) answers a decision you wrote down first. Build it
without over-building it: cheapest grader that works, real failures as fixtures, and read the
transcripts before believing the score.

It is the **empirical arm of the goal-driven-execution principle**. Two neighbors it is NOT:
- **test-driven-development** — unit-level *correctness* while you build (RED→GREEN). If a
  deterministic test can express it, that's TDD's job, not an eval.
- **audit-cycle** — adversarial *review* of one artifact by inspection. An eval *measures*: it
  runs the system over a corpus and grades outputs.

The harness's **skill-eval gate** (skill-creator: 60/40 train/held-out split, each query run 3×
for a stable trigger rate) is the canonical application of everything below.

## 1. When to build an eval (and when NOT to)

Build one when the question is **"is this output good / better / reliable enough?"** across many
inputs and the answer isn't a single deterministic assertion:
- **Bake-off** — two or more systems (models, prompts, pipelines) compete on a locked corpus.
- **Quality regression** — a suite guarding against a known failure class coming back.
- **Autonomous-run goal function** — the pass/fail signal an unattended loop optimizes toward.

Do NOT build one when: a **deterministic unit test** captures it (→ `test-driven-development`);
you want **adversarial inspection** of one artifact (→ `audit-cycle`); or the decision is a
**one-off judgment call**. An eval earns its cost only when the measurement is *repeated* or
*scaled*.

## 2. Pre-register the decision FIRST

**Before a single output exists, write down "what result changes what decision"** — otherwise you
fit the criterion to the result you got (criterion-fishing). Write, before running anything:
- **The decision** the eval feeds — "ship prompt B over A", "graduate feature X", "the loop stops
  when…". No decision → no eval; you're just generating outputs.
- **The success criterion, Specific / Measurable / Achievable / Relevant.** Not "safe outputs" but
  "≤0.1% of 10,000 outputs flagged by the content filter." Bundle *metric + dataset + baseline*:
  "F1 ≥ 0.85 on a held-out set of 10,000 posts — a 5% lift over the current baseline."
- **The threshold that flips the decision** — the exact result at which you'd choose differently.

This lives at the top of `.claude/harness-templates/eval-scorecard.md`, filled *before* the run.

## 3. Name the three parts explicitly

Conflating them is the most common way an eval measures the wrong thing:
1. **Fixture corpus** — the inputs + their target/expected property. The *measuring stick*, NOT
   the system.
2. **System(s) under test** — the model / prompt / pipeline being measured (plus a **baseline**,
   §9). This is what varies between runs.
3. **Grader** — turns an output into a verdict (§5's ladder). NOT the corpus, NOT the system; a
   grader sharing code or a model family with the system under test is a bias (§7).

If you can't point at each separately, you have a demo, not an eval.

## 4. Build the fixture corpus from real failures, then LOCK it

- **Source it from real failures, not imagination** — mined from manual checks during
  development, the bug tracker, the support queue, actual failing traces, and topped up
  continuously from new failures. Twenty real failures beat two hundred invented ones.
- **Prioritize volume over per-item polish.** More questions with slightly lower-signal automated
  grading beats fewer high-quality hand-graded ones; breadth of the input distribution is signal.
- **Test both sides.** Include cases where the behavior *should* fire AND where it *should not* —
  else an "always yes" system scores perfectly. Cover edge cases: irrelevant / nonexistent input,
  over-long input, and genuinely ambiguous cases where even humans wouldn't reach consensus.
- **LOCK it, and hold out a slice.** Freeze the corpus (record a hash + date). Reserve a
  **held-out slice the system is never tuned against** — the skill-creator gate uses 60% train /
  40% held-out. Contamination rule: *if you edited the corpus to make it pass, it is no longer a
  test.*

## 5. Pick the cheapest grader that works — the assertion ladder

Climb from the bottom; stop at the first rung that captures the criterion.

1. **Deterministic (free, first choice).** exact-match, contains, regex, is-json, is-refusal,
   latency, cost, levenshtein / ROUGE / BLEU. Fastest and most reliable; it lacks nuance so it
   can't grade open-ended quality — but most criteria have a deterministic core, and every case
   settled here costs nothing.
2. **Model-assisted (LLM-as-judge — only where determinism can't reach).** llm-rubric, g-eval,
   factuality, answer-relevance, context-faithfulness. Flexible and scalable, but biased and
   non-deterministic — §6 (rubric design), §7 (bias checklist) and §8 (calibration) are mandatory
   before you trust it. Test reliability first, then scale.
3. **Human (most flexible, highest quality, slowest — avoid at scale).** Reserve for calibrating
   the judge (§8) and reading transcripts (§10), not for grading every case.

You can **combine** rungs: weighted assertions → one pass/fail (assertion sets + threshold).
Prefer the lowest rung that still captures the criterion (§12).

## 6. Rubric design for LLM-as-judge

- **Binary pass/fail + a written critique — NOT a 1–5 scale.** People don't know what to do with a
  3 or 4. Force correct/incorrect plus a one-line reason: a number without a critique is a vibe.
- **One dimension at a time, isolated.** Don't ask one judge call for "overall quality" — score
  correctness, then completeness, then tone, each on its own.
- **Encourage reasoning, then discard it.** Grader emits reasoning in `<thinking>` tags and its
  verdict in `<result>` tags; you keep the verdict, the reasoning only improved it.
- **Give an escape hatch** — a way out, like returning "Unknown". A judge forced to choose on an
  ambiguous case invents a verdict; route abstentions to a human.
- **Supply a reference answer where one exists.** Excluding it causes the greatest performance
  degradation; a known-good reference both defines the target and sharpens the judge.

`.claude/harness-templates/open-output-judge.md` is a ready rubric shell for the no-ground-truth
case (a research brief, a synthesis) — scored dimensions with anchors + hard pass/fail gates.

## 7. Judge-bias checklist — HARD RULE for this harness

LLM judges have measured, reproducible biases. Encode each defense (the measured numbers behind
each are in `references/pitfalls-and-sources.md`):
- **Self-preference / self-enhancement → HARD RULE: a model NEVER grades output generated by its
  own model family.** Bake-off entries get a *different-family* judge.
- **Position bias → for pairwise, swap A/B order and average both orderings** (swap-and-average).
- **Verbosity bias → put an explicit length-neutral / conciseness clause in the rubric** so length
  can't buy a win.
- **Version the rubric.** A rubric change resets comparability — earlier scores are no longer
  directly comparable. Stamp a rubric version on every run (the scorecard has a field).

## 8. Calibrate the judge before trusting it

An uncalibrated judge is an opinion generator. Calibrate before you scale (Critique Shadowing):
- **Fix one benevolent-dictator arbiter** — a single Principal Domain Expert makes the pass/fail
  calls + writes critiques on a sample. Don't act as the domain expert yourself; pick the real one.
- **Align the judge to their labels, then measure the gap with precision/recall — never a single
  accuracy number.** Raw agreement lies on imbalanced sets (an always-"pass" judge looks 90%
  accurate on a 90%-pass set while catching nothing). Iterate the rubric until agreement is high
  across a few passes.
- **A judge is a lead, not a verdict.** Keep a human in the loop; the judge scales the arbiter, it
  doesn't replace them.

## 9. Run design — baseline + A/B, repeats for non-determinism

- **Always a baseline.** A score with nothing to compare against is unreadable: the current system
  / incumbent prompt / "do nothing" is what the new option must beat.
- **pass@k vs pass^k — pick by the reliability the product needs.** **pass@k** = at least one
  correct solution in k attempts (fine when a retry or human filter catches misses); **pass^k** =
  all k trials succeed (the honest metric when the system must be reliable every time — an
  autonomous loop with no human gate). A single run is a coin-flip, not a measurement.
- **Repeat for stable rates.** The skill-creator gate runs each query **3×**; do likewise wherever
  the system is stochastic.
- **Report train and held-out separately** (§4's split). The held-out slice predicts real behavior.

## 10. Read the transcripts — the score is provisional

**No score is trusted until you read transcripts and the failures "seem fair."** The single most
load-bearing discipline here: a high score can come from a leaky grader, a contaminated corpus, or
a judge rewarding verbosity — you only see it in the traces.
- Read N transcripts per run (record N on the scorecard). Spot-read *passes* too — a pass for the
  wrong reason is a broken grader.
- Ask of each failure: a *fair* miss (the system got it wrong) or an *unfair* one (the grader /
  corpus is broken)? Unfair failures mean fix the instrument, not the system.
- Attest explicitly: "N transcripts read; failures seem fair — yes/no." An unattested score is
  provisional.

## 11. Honest reporting

- **Say small-N loudly.** A 20-case corpus is a real signal AND a small sample; report the N, don't
  launder it into false precision. (Say small-N + prefer pass^k — this is not a statistics course:
  no power analysis, no confidence intervals.)
- **Precision/recall over a single accuracy number** — §8's rule, in the report too.
- **State the eval's cost** — §12. A result nobody can afford to re-run isn't a regression guard.
- **Watch for saturation → graduate to regression.** When everything passes, the eval has stopped
  *measuring* — retire it into the always-on regression suite or make it harder. 100% means the
  instrument is done discriminating, not victory.

## 12. Cost bounds

- **Budget the run in tokens / dollars before you run it**, and put the number on the scorecard.
- **Deterministic assertions are free; the LLM judge is not** — every rung-2 case is API spend ×
  repeats × swap-and-average doublings × dimensions.
- **Frugality gate:** if the eval costs more to run than the decision is worth, shrink the corpus,
  push cases down the ladder, or drop repeat count.

## When to invoke

- Building a bake-off, a quality-regression suite, or an autonomous-run goal function: "build an
  eval", "bake-off", "quality regression", "A/B this", "is X better", "/eval-building".
- Proactively when a decision hinges on "is this output good / better / reliable enough?" across
  many cases and you're about to eyeball it instead of measuring it.

## Pairs with

- **goal-driven-execution** (principle) — the parent; this is its empirical arm.
- **test-driven-development** — unit-level correctness during construction.
- **audit-cycle** — adversarial review by inspection, not measurement over a corpus.
- **The skill-eval gate** (skill-creator: 60/40 split, 3× runs) — canonical application.
- `references/pitfalls-and-sources.md` — the full pitfalls canon (rule + numbers + source URL),
  the framework-abstractions table, and all source URLs.
  `.claude/harness-templates/eval-scorecard.md` — the run artifact.
