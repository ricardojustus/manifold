<!--
  eval-scorecard.md — the run artifact for one eval (a bake-off, a quality-regression run, an
  autonomous-goal-function calibration). Produced by the eval-building skill.

  THE ORDER IS LOAD-BEARING. Fill the top block (Decision & pre-registered criterion, Fixture
  corpus, System(s), Grader) BEFORE you generate a single output — that is the pre-registration
  guard against criterion-fishing. Fill Results / Transcripts / Caveats / Verdict AFTER the run.
  If the Verdict section is written and the Decision section is empty, the eval is invalid — you
  decided what "good" means after seeing the scores. One scorecard per run; a rubric or corpus
  change means a NEW scorecard (earlier scores are no longer directly comparable).
  Delete these comments as you fill each section.
-->

# Eval scorecard — <what's being evaluated> — <YYYY-MM-DD>

## Decision & pre-registered criterion  — FILL BEFORE RUNNING
<!-- The whole point of the eval. Written before any output exists. -->
- **Decision this feeds:** <e.g. ship prompt B over A / graduate feature X / loop-stop condition>
- **Success criterion (Specific/Measurable/Achievable/Relevant):** <metric + dataset + baseline,
     e.g. "pass^3 ≥ 0.90 on the held-out slice, vs 0.72 baseline">
- **Threshold that flips the decision:** <the exact result at which you'd choose differently>

## Fixture corpus  — FILL BEFORE RUNNING
<!-- The measuring stick. Real failures, not invented cases. Both should-happen and
     shouldn't-happen cases. Locked before the run. -->
- **Source:** <bug tracker / dev checks / support queue / prior failing traces — where these came from>
- **Size:** <N total> · should-fire <n> / should-NOT-fire <n> / edge cases <n>
- **Locked at:** <hash + date> — corpus frozen; not edited to pass (contamination guard)
- **Held-out slice:** <which cases / what fraction — the system is never tuned against these>

## System(s) under test + baseline  — FILL BEFORE RUNNING
<!-- What varies between runs. There is ALWAYS a baseline — a score with nothing to compare
     against is unreadable. -->
- **System(s):** <model / prompt / pipeline under test — name each variant>
- **Baseline:** <incumbent / current prod / "do nothing" — the thing the new option must beat>

## Grader  — FILL BEFORE RUNNING
<!-- The cheapest rung of the assertion ladder that captures the criterion. -->
- **Ladder level:** <deterministic | model-assisted (LLM-judge) | human>
- **If deterministic:** <the assertions — exact/contains/regex/json/latency/cost, + threshold>
- **If LLM-judge:**
  - **Judge model family:** <___> · **Generator family:** <___>
    <!-- HARD RULE: these MUST differ. A model never grades output from its own family
         (self-preference bias measured at up to +25% win rate). Pairwise → swap A/B and average. -->
  - **Rubric version:** <vN> — binary pass/fail + written critique (NOT a 1–5 scale), one
       dimension per judge call, reasoning-then-discard, "Unknown" escape hatch, reference answer
       supplied where one exists, explicit length-neutral clause
  - **Calibration status:** <arbiter = who · judge↔arbiter precision/recall = _ / _ · iterations = _>
    <!-- Uncalibrated judge = opinion generator. Report precision/recall, never a single accuracy. -->

## Results  — FILL AFTER RUNNING
<!-- Per dimension: binary verdict + the critique. Train and held-out reported separately. -->
| Dimension | System | Baseline | Verdict | pass@k / pass^k | Critique (one line) |
|---|---|---|---|---|---|
| <e.g. correctness> | _ | _ | pass/fail | _ | _ |
| <e.g. completeness> | _ | _ | pass/fail | _ | _ |
- **Train slice:** <result> · **Held-out slice:** <result>  <!-- held-out is the honest number -->
- **Repeats:** <each case run k=_ times; pass@k vs pass^k chosen because <reliability need>>

## Transcripts-read attestation  — FILL AFTER RUNNING
<!-- No score is trusted until someone reads the traces. This line is mandatory. -->
- **N transcripts read:** <___> (spot-read passes too, not only failures)
- **Failures seem fair (system genuinely wrong, not a broken grader/corpus)?** <yes / no — if no,
     fix the instrument, not the system, and re-run>

## Caveats  — FILL AFTER RUNNING
<!-- Honest reporting. Say small-N loudly; don't launder it into false precision. -->
- **Sample size:** N = <___> — <small-N caveat stated plainly>
- **Judge limits:** <known biases not fully controlled; abstention rate; calibration gap>
- **Cost:** <tokens / dollars for this run> — <re-runnable within budget? saturation risk?>
- **Saturation:** <everything passing? → graduate to regression testing or make it harder>

## Verdict  — FILL AFTER RUNNING
<!-- Against the pre-registered criterion at the top — not a fresh standard invented now. -->
- **Verdict:** <MEETS criterion / DOES NOT meet / INCONCLUSIVE (why)> — measured <result> against
     pre-registered threshold <___>. Decision: <the decision the top block named, now made>.
