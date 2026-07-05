---
name: eval-building
description: >-
  Build an empirical eval to measure whether a product / feature / agent-run actually works —
  bake-offs, quality-regression suites, autonomous-run goal functions. Pre-register the decision
  FIRST ("what result changes what decision"), name the three parts (fixture corpus ≠
  system-under-test ≠ grader), then climb the assertion ladder: the cheapest grader that works —
  deterministic → model-assisted → human. Binary pass/fail + written critique over 1–5 scales;
  a judge never grades output from its own model family; read the transcripts before trusting a
  score. Use for "build an eval", "bake-off", "quality regression", "A/B this", "is X better".
  Neighbors: test-driven-development (unit-level correctness DURING construction, not measuring
  quality), audit-cycle (adversarial review of an artifact, not empirical measurement),
  goal-driven-execution principle (this is its empirical arm); its first application is the
  harness's own skill-eval gate.
---

# Eval-building — measure whether it actually works

*Patterns adapted from Anthropic's eval docs + "Demystifying evals for AI agents" engineering
blog, promptfoo, inspect_ai, Braintrust autoevals, Hamel Husain, and Eugene Yan (MIT / public
docs). Source URLs live in `references/pitfalls-and-sources.md`.*

An eval is not "run it a few times and eyeball the output." It is a measurement instrument: a
locked set of tasks, a system under test, and a grader — built so that a *number* (or a
pass/fail per case) answers a *decision* you wrote down first. This skill builds that instrument
without over-building it: cheapest grader that works, real failures as fixtures, and a hard rule
that you read the transcripts before you believe the score.

It is the **empirical arm of the goal-driven-execution principle** — that principle says turn the
task into a verifiable success criterion and loop until it passes; this skill is how you make the
criterion *measurable at scale* when the thing being measured is open-ended quality, not a unit
of code. Two neighbors it is NOT:
- **test-driven-development** checks unit-level *correctness* while you build (RED→GREEN). Evals
  measure *quality / behavior* of a finished system across many cases. If a deterministic test
  can express it, that's TDD's job, not an eval.
- **audit-cycle** is adversarial *review* of an artifact (a spec, an implementation) — a reviewer
  reads and reasons. An eval *measures*: it runs the system over a corpus and grades outputs.
  Review finds defects by inspection; an eval finds them by evidence.

The harness's own **skill-eval gate** (the skill-creator eval set: 60/40 train/held-out split,
each query run 3× for a stable trigger rate) is the first and canonical application of everything
below.

## 1. When to build an eval (and when NOT to)

Build one when the question is **"is this output good / better / reliable enough?"** across many
inputs and the answer isn't a single deterministic assertion:
- **Bake-off** — two or more systems (models, prompts, pipelines) compete on a locked corpus; you
  need to pick one.
- **Quality regression** — a suite that guards against a known failure class coming back as you
  change the system.
- **Autonomous-run goal function** — the pass/fail signal an unattended loop optimizes toward.

Do NOT build an eval when:
- A **deterministic unit test** captures it — that's `test-driven-development`. Anthropic ranks
  code-based grading first precisely because it's "fastest and most reliable"; if exact-match or
  a regex settles it, you don't need an eval harness, you need a test.
- You want **adversarial inspection** of one artifact — that's `audit-cycle` / a review, not a
  measurement.
- The decision is a **one-off judgment call** a person can just make. An eval earns its cost only
  when the measurement will be *repeated* (regression) or *scaled* (many cases, hard to eyeball).

## 2. Pre-register the decision FIRST (Step 1 in spirit)

**Before a single output exists, write down: "what result changes what decision."** This is the
step that makes an eval honest. If you generate outputs, look at scores, and *then* decide what
"good" means, you will fit the criterion to the result you got — criterion-fishing. Pre-registration
is the guard.

Write, before running anything:
- **The decision** the eval feeds — "ship prompt B over A", "graduate feature X", "the loop stops
  when…". No decision → no eval; you're just generating outputs.
- **The success criterion, Specific / Measurable / Achievable / Relevant** (Anthropic's eval
  guide). Not "safe outputs" but "≤0.1% of 10,000 outputs flagged by the content filter." Bundle
  *metric + dataset + baseline*: "F1 ≥ 0.85 on a held-out set of 10,000 posts — a 5% lift over
  the current baseline."
- **The threshold that flips the decision** — the exact result at which you'd choose differently.

This lives at the top of the scorecard (`.claude/harness-templates/eval-scorecard.md`), filled *before* the
run. The harness's own prior art is the pre-registered A/B where the decision criterion was fixed
before the run — do that every time.

## 3. Name the three parts explicitly

An eval has exactly three separable parts (inspect_ai's dataset / solver / scorer split). Name all
three out loud; conflating them is the most common way an eval measures the wrong thing:
1. **Fixture corpus** — the inputs, each with its target / expected property. This is the
   *measuring stick*, and it is NOT the system.
2. **System(s) under test** — the model / prompt / pipeline you're measuring (plus a **baseline** —
   §9). This is what varies between runs.
3. **Grader** — the thing that turns an output into a verdict (§5's ladder). It is NOT the corpus
   and NOT the system; a grader that shares code or a model family with the system under test is a
   bias, not a measurement (§7).

If you can't point at each of the three separately, you don't yet have an eval — you have a demo.

## 4. Build the fixture corpus from real failures, then LOCK it

- **Source it from real failures, not imagination.** Anthropic: "20–50 simple tasks drawn from
  real failures is a great start" — mined from "the manual checks you run during development…
  your bug tracker and support queue." Hamel's L1 is the same: cheap assertions mined from actual
  failing traces, continuously topped up from new failures. Twenty real failures beat two hundred
  invented ones.
- **Prioritize volume over per-item polish.** Anthropic: "More questions with slightly lower
  signal automated grading is better than fewer questions with high-quality human hand-graded
  evals." Breadth of the input distribution is the signal.
- **Test both sides.** Include cases where the behavior *should* fire AND where it *should not*
  ("test both the cases where a behavior should occur and where it shouldn't") — otherwise you
  optimize one-sidedly and a "always yes" system scores perfectly. Cover edge cases too:
  irrelevant / nonexistent input, over-long input, and the genuinely ambiguous cases "where even
  humans would find it hard to reach a consensus."
- **LOCK it, and hold out a slice.** Freeze the corpus (record a hash + date). Reserve a
  **held-out slice the system is never tuned against** — the skill-creator gate uses 60% train /
  40% held-out. Anthropic's contamination rule: *if you edited the corpus to make it pass, it is
  no longer a test.* The held-out slice is what keeps the number honest.

## 5. Pick the cheapest grader that works — the assertion ladder

Climb from the bottom; stop at the first rung that captures the criterion. (promptfoo's tiered
assertions + Anthropic's grading ranking.)

1. **Deterministic (free, first choice).** exact-match, contains, regex, is-json, is-refusal,
   latency, cost, levenshtein / ROUGE / BLEU. Anthropic: code-based grading is "fastest and most
   reliable, extremely scalable" — use it wherever the criterion is checkable in code. It "lacks
   nuance," so it can't grade open-ended quality — but most criteria have a deterministic core,
   and every case you settle here costs nothing.
2. **Model-assisted (LLM-as-judge — only where determinism can't reach).** llm-rubric, g-eval,
   factuality, answer-relevance, context-faithfulness. Fast and flexible and scalable, but
   biased and non-deterministic — so §6 (rubric design) and §7 (bias checklist) and §8
   (calibration) are mandatory before you trust it. "Test to ensure reliability first then scale."
3. **Human (most flexible, highest quality, slowest — avoid at scale).** Anthropic: "Avoid if
   possible." Reserve for calibrating the judge (§8) and for reading transcripts (§10), not for
   grading every case.

You can **combine** rungs: a set of weighted assertions → one pass/fail (promptfoo's assertion
sets + threshold). Prefer the lowest rung that still captures the criterion — an LLM judge for
something a regex settles is cost and noise you didn't need (§12).

## 6. Rubric design for LLM-as-judge

When you're on rung 2, the rubric is the instrument. Design it so the verdict is decidable:
- **Binary pass/fail + a written critique — NOT a 1–5 scale.** Hamel: "tracking a bunch of scores
  on a 1–5 scale is often a sign of a bad eval… People don't know what to do with a 3 or 4." Force
  correct/incorrect (or pass/fail) plus a one-line reason. A number without a critique is a vibe;
  a critique is auditable.
- **One dimension at a time, isolated.** Anthropic: "create clear, structured rubrics… and then
  grade each dimension with an isolated LLM-as-judge." Don't ask one judge call for "overall
  quality" — score correctness, then completeness, then tone, each on its own.
- **Encourage reasoning, then discard it.** Anthropic: "Ask the LLM to think first… and then
  discard the reasoning." Grader emits its reasoning in `<thinking>` tags and its verdict in
  `<result>` tags; you keep the verdict, the reasoning only improved it.
- **Give an escape hatch.** "A way out, like… return 'Unknown'." A judge forced to choose on an
  ambiguous case invents a verdict; let it abstain and route abstentions to a human.
- **Supply a reference answer where one exists.** Eugene Yan: "excluding the reference answer
  leads to the greatest performance degradation." A known-good "reference solution that passes all
  graders" (Anthropic) both defines the target and sharpens the judge.

`.claude/harness-templates/open-output-judge.md` is a ready rubric shell for the no-ground-truth case (a
research brief, a synthesis) — scored dimensions with anchors + hard pass/fail gates.

## 7. Judge-bias checklist (with the numbers) — HARD RULE for this harness

LLM judges have measured, reproducible biases. Encode each defense; the numbers are why:
- **Self-preference / self-enhancement.** Eugene Yan: "gpt-4 favored itself with a 10% higher win
  rate while claude-v1 favored itself with a 25% higher win rate." **HARD RULE for this harness:
  a model NEVER grades output generated by its own model family.** Bake-off entries get a
  *different-family* judge; a cross-family judge is the whole point of the harness's cross-model
  culture. Don't let a model grade its own bake-off entry.
- **Position bias.** In pairwise, judges were biased by option order "50% of the time" (gpt-3.5)
  to "70%" (claude-v1). **Defense: for pairwise, swap A/B order and average both orderings**
  (swap-and-average).
- **Verbosity bias.** Both claude-v1 and gpt-3.5 "preferred the longer response more than 90% of
  the time." **Defense: put an explicit length-neutral / conciseness clause in the rubric** so
  length can't buy a win.
- **Version the rubric.** autoevals: "Rubrics should be versioned alongside prompts, and when a
  rubric changes, earlier scores are no longer directly comparable." A rubric change resets
  comparability — stamp a rubric version on every run (the scorecard has a field).

## 8. Calibrate the judge before trusting it

An uncalibrated judge is an opinion generator. Calibrate before you scale (Hamel's Critique
Shadowing):
- **Fix one benevolent-dictator arbiter.** A single "Principal Domain Expert" makes the pass/fail
  calls + writes critiques on a sample. Hamel: "Many developers attempt to act as the domain
  expert themselves… This is a recipe for disaster" — pick the real arbiter.
- **Align the judge to their labels, then measure the gap with precision/recall — never a single
  accuracy number.** Hamel: "report precision and recall separately," because raw agreement lies
  on imbalanced sets (a judge that always says "pass" looks 90% accurate on a 90%-pass set while
  catching nothing). Iterate the rubric until agreement is high across a few passes (Honeycomb
  hit ">90% agreement… in three iterations").
- **A judge is a lead, not a verdict.** Eugene Yan: judges are "not reliable enough to
  systematically replace human judgments." Keep a human in the loop; the judge scales the arbiter,
  it doesn't replace them.

## 9. Run design — baseline + A/B, repeats for non-determinism

- **Always a baseline.** A score with nothing to compare against is unreadable. The baseline is
  the current system / the incumbent prompt / "do nothing" — the thing the new option must beat.
- **pass@k vs pass^k — pick by the reliability the product needs.** Anthropic: **pass@k** = "at
  least one correct solution in k attempts" (fine when a retry / a human filter catches misses);
  **pass^k** = "all k trials succeed" (the honest metric when the system must be reliable every
  time — an autonomous loop with no human gate). Non-determinism is real; a single run is a
  coin-flip, not a measurement.
- **Repeat for stable rates.** The skill-creator gate runs each query **3×** for a reliable
  trigger rate; do likewise wherever the system is stochastic.
- **Report train and held-out separately** (§4's split). A number that only looks good on the
  training slice is overfit; the held-out slice is the one that predicts real behavior.

## 10. Read the transcripts — the score is provisional

**No score is trusted until you read transcripts and the failures "seem fair."** This is the
single most load-bearing discipline in the skill. Anthropic: "we do not take eval scores at face
value until someone digs into the details of the eval and reads some transcripts." A high score
can come from a leaky grader, a contaminated corpus, or a judge rewarding verbosity — you only
see it by reading the actual traces.
- Read N transcripts per run (record N on the scorecard). Spot-read *passes* too, not only
  failures — a pass for the wrong reason is a broken grader.
- Ask of each failure: is this a *fair* miss (the system genuinely got it wrong) or an *unfair*
  one (the grader / corpus is broken)? Unfair failures mean fix the instrument, not the system.
- Attest it explicitly: "N transcripts read; failures seem fair — yes/no." An unattested score is
  provisional.

## 11. Honest reporting

- **Say small-N loudly.** A 20-case corpus is a real signal AND a small sample; report the N and
  don't launder it into a false precision. (This skill teaches "say small-N + prefer pass^k," not
  a statistics course — no power analysis, no confidence-interval math.)
- **Precision/recall over a single accuracy number** — §8's rule, in the report too.
- **State the eval's cost** — §12. A result nobody can afford to re-run isn't a regression guard.
- **Watch for saturation → graduate to regression.** Anthropic: a saturated capability-eval should
  "graduate to regression testing." When everything passes, the eval has stopped *measuring* —
  either retire it into the always-on regression suite or make it harder. A 100% is a signal the
  instrument is done discriminating, not a victory.

## 12. Cost bounds

- **Budget the run in tokens / dollars before you run it**, and put the number on the scorecard.
- **Deterministic assertions are free; the LLM judge is not** — every rung-2 case is API spend ×
  (repeats) × (swap-and-average doublings) × (dimensions). This is exactly why the assertion
  ladder (§5) climbs from the cheap rung: don't spend a judge call on what a regex settles.
- **Frugality gate:** if the eval costs more to run than the decision is worth, shrink the corpus,
  push cases down the ladder, or drop repeat count — a measurement you won't re-run isn't a
  regression guard.

## When to invoke

- Building a bake-off, a quality-regression suite, or an autonomous-run goal function: "build an
  eval", "bake-off", "quality regression", "A/B this", "is X better", "/eval-building".
- Proactively when a decision hinges on "is this output good / better / reliable enough?" across
  many cases and you're about to eyeball it instead of measuring it.

## Pairs with

- **goal-driven-execution** (principle) — the parent; this is its empirical arm for open-ended
  quality that a unit test can't express.
- **test-driven-development** — unit-level correctness during construction; if a deterministic
  test captures it, it's TDD's job, not an eval's.
- **audit-cycle** — adversarial review of an artifact by inspection; distinct from measuring a
  system over a corpus by evidence.
- **The skill-eval gate** (skill-creator: 60/40 split, 3× runs) — this skill's first and canonical
  application.
- `references/pitfalls-and-sources.md` — the full pitfalls canon (rule + numbers + source URL) and
  the framework-abstractions table. `.claude/harness-templates/eval-scorecard.md` — the run artifact.
