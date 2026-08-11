# Eval-building — pitfalls canon + framework abstractions + sources

*Patterns adapted from Anthropic docs + engineering blog, promptfoo, inspect_ai, openai/evals,
Braintrust autoevals, deepeval, Hamel Husain, and Eugene Yan (MIT / public docs). This file is
the evidence layer for `../SKILL.md` — every rule below carries the number that justifies it and
the source it came from.*

---

## The pitfalls canon (rule · evidence with numbers · source)

Each entry is a one-line rule the skill encodes, the empirical evidence behind it (with the actual
numbers, because the numbers are the WHY — a rule without its receipt gets re-litigated), and the
source URL.

1. **1–5 Likert scores are usually a bad eval → prefer binary pass/fail + a written critique.**
   Evidence: "tracking a bunch of scores on a 1–5 scale is often a sign of a bad eval" — "People
   don't know what to do with a 3 or 4." A number nobody can act on is noise; a pass/fail + reason
   is auditable.
   Source: Hamel Husain, *Using LLM-as-a-Judge* — https://hamel.dev/blog/posts/llm-judge/

2. **Fix ONE benevolent-dictator arbiter and calibrate the judge to their labels before trusting
   it (Critique Shadowing).** Evidence: find "the Principal Domain Expert," have them make
   pass/fail + critique, then align the judge — Honeycomb reached ">90% agreement… in three
   iterations." Anti-pattern: "Many developers attempt to act as the domain expert themselves…
   This is a recipe for disaster."
   Source: Hamel Husain, *Using LLM-as-a-Judge* — https://hamel.dev/blog/posts/llm-judge/

3. **Measure judge↔human alignment with precision/recall, never a single accuracy number.**
   Evidence: raw agreement lies on imbalanced sets — an always-"pass" judge scores ~90% on a
   90%-pass set while catching nothing; "report precision and recall separately."
   Source: Hamel Husain, *Your AI Product Needs Evals* — https://hamel.dev/blog/posts/evals/

4. **Start at L1 cheap assertions mined from actual failing traces; earn your way up.** Evidence:
   three-level hierarchy — L1 assertions from real failures ("Rechat has hundreds of these unit
   tests… continuously update them based on new failures"), L2 human+model eval with friction-free
   data review, L3 A/B in production.
   Source: Hamel Husain, *Your AI Product Needs Evals* — https://hamel.dev/blog/posts/evals/

5. **Position bias → for pairwise, swap A/B order and average both orderings.** Evidence: in
   pairwise judging, gpt-3.5 was "biased 50% of the time and claude-v1… 70%" by option order.
   Source: Eugene Yan, *Evaluating LLM-Evaluators* — https://eugeneyan.com/writing/llm-evaluators/

6. **Verbosity bias → put an explicit conciseness / length-neutral clause in the judge rubric.**
   Evidence: "both claude-v1 and gpt-3.5 preferred the longer response more than 90% of the time."
   Source: Eugene Yan, *Evaluating LLM-Evaluators* — https://eugeneyan.com/writing/llm-evaluators/

7. **Self-preference / self-enhancement bias → judge with a DIFFERENT model family than the one
   that generated the output.** Evidence: "Gpt-4 favored itself with a 10% higher win rate while
   claude-v1 favored itself with a 25% higher win rate." Load-bearing for this harness's
   cross-model-audit culture: a model must never grade its own bake-off entry.
   Source: Eugene Yan, *Evaluating LLM-Evaluators* — https://eugeneyan.com/writing/llm-evaluators/

8. **A judge is a lead, not a verdict → give it a reference answer where one exists, keep a human
   in the loop.** Evidence: "each model performed poorly on some datasets… not reliable enough to
   systematically replace human judgments"; "excluding the reference answer leads to the greatest
   performance degradation."
   Source: Eugene Yan, *Evaluating LLM-Evaluators* — https://eugeneyan.com/writing/llm-evaluators/

9. **Don't trust the score — read transcripts; every result is provisional until the failures
   "seem fair."** Evidence: "we do not take eval scores at face value until someone… reads some
   transcripts."
   Source: Anthropic, *Demystifying evals for AI agents* —
   https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents

10. **Pre-register the decision criterion → write "what result changes what decision" before
    generating a single output; no criterion-fishing after seeing scores.** Evidence: success
    criteria are defined BEFORE the eval runs (Specific/Measurable/Achievable/Relevant); reinforced
    by the harness's own pre-registered A/B where the criterion was fixed before the run.
    Source: Anthropic, *Define success criteria and build evaluations* —
    https://platform.claude.com/docs/en/docs/test-and-evaluate/develop-tests

11. **Contamination / overfitting → lock a held-out slice the implementation is never tuned
    against; if you edited the corpus to pass, it's no longer a test.** Evidence: Anthropic's
    held-out-test-set language + inspect_ai + the skill-creator 60% train / 40% held-out split.
    Sources: Anthropic develop-tests (above) ·
    https://github.com/anthropics/skills · https://inspect.aisi.org.uk/

12. **Saturation kills signal → when everything passes, graduate the eval to regression testing or
    make it harder.** Evidence: a saturated capability-eval should "graduate to regression testing"
    — a 100% means the instrument stopped discriminating.
    Source: Anthropic, *Demystifying evals for AI agents* (above)

### Anthropic house-method anchors (the spine several rules hang off)

- **Success criteria = Specific / Measurable / Achievable / Relevant.** Bad: "Safe outputs." Good:
  "Less than 0.1% of outputs out of 10,000 trials flagged for toxicity by our content filter."
  Bundle metric + set + baseline: "F1 ≥ 0.85… on a held-out test set of 10,000 diverse Twitter
  posts… a 5% improvement over our current baseline." (develop-tests)
- **Three grading methods, ranked:** (1) code-based — "Fastest and most reliable, extremely
  scalable, but lacks nuance"; (2) human — "Most flexible and high quality, but slow and expensive.
  Avoid if possible"; (3) LLM-based — "Fast and flexible, scalable… Test to ensure reliability
  first then scale." (develop-tests)
- **Volume over quality:** "More questions with slightly lower signal automated grading is better
  than fewer questions with high-quality human hand-graded evals." (develop-tests)
- **LLM-grading tips:** detailed rubrics; force correct/incorrect (purely qualitative evals are
  "hard to assess quickly and at scale"); "Encourage reasoning… and then discard the reasoning"
  (think in `<thinking>`, verdict in `<result>`); "best practice to use a different model to
  evaluate than the model used to generate." (develop-tests)
- **Agent-era additions:** task quality bar = "two domain experts would independently reach the
  same pass/fail verdict"; grade the outcome, not the path ("agents regularly find valid
  approaches that eval designers didn't anticipate"); isolated per-dimension LLM-as-judge with an
  "Unknown" escape hatch, "closely calibrated with human experts"; dataset = "20–50 simple tasks
  drawn from real failures"; pass@k vs pass^k by reliability need; read transcripts; watch
  saturation. (Demystifying evals)

---

## Framework abstractions — patterns to steal, tools NOT to adopt

Plunder the PATTERNS, do not install the frameworks: promptfoo's tiered assertion taxonomy (the §5
ladder), inspect_ai's dataset/solver/scorer separation (§3), openai/evals' locked versioned eval
definition (§4), Braintrust autoevals' rubric-versioning and ready-made judge rubrics (§6/§7), and
deepeval's G-Eval + RAG faithfulness metrics (assertion types, not plumbing to teach).

---

## Sources (all fetched / searched, 2026-07-04)

- Anthropic platform docs — *Define success criteria and build evaluations* —
  https://platform.claude.com/docs/en/docs/test-and-evaluate/develop-tests
- Anthropic engineering — *Demystifying evals for AI agents* —
  https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
- anthropics/claude-cookbooks (`misc/building_evals.ipynb`; `patterns/agents/` evaluator-optimizer) —
  https://github.com/anthropics/claude-cookbooks
- anthropics/skills — skill-creator eval framework (60/40 split, 3× trigger rate) —
  https://github.com/anthropics/skills
- promptfoo assertions — https://www.promptfoo.dev/docs/configuration/expected-outputs/
- UK AISI inspect_ai (dataset/solver/scorer/task) — https://inspect.aisi.org.uk/
- openai/evals (registry YAML + model-graded) — https://github.com/openai/evals
- braintrustdata/autoevals (scorers + rubric versioning) — https://github.com/braintrustdata/autoevals
- confident-ai/deepeval (G-Eval, pytest, faithfulness/hallucination) —
  https://github.com/confident-ai/deepeval
- Hamel Husain — *Using LLM-as-a-Judge* — https://hamel.dev/blog/posts/llm-judge/
- Hamel Husain — *Your AI Product Needs Evals* — https://hamel.dev/blog/posts/evals/
- Eugene Yan — *Evaluating LLM-Evaluators* — https://eugeneyan.com/writing/llm-evaluators/
