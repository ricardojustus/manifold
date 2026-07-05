<!--
  open-output-judge.md — a rubric for grading an OPEN-ENDED artifact that has no ground-truth
  clause to check against: a research brief, a synthesis, a plan, a dashboard, a written
  recommendation. Code gets clause-level conformance and tests; these don't — so grade them
  with a single, well-specified judge over scored dimensions. ONE well-specified judge beats
  a noisy ensemble: a vague rubric run five times is five vague opinions; a sharp rubric run
  once is a decidable verdict. Score each dimension 0–1 with explicit anchors, then apply the
  hard pass/fail gates (a gate failure fails the artifact regardless of the dimension scores).
-->

# Output judge — <artifact type> — <YYYY-MM-DD>

## What's being judged
<!-- The artifact + its purpose. The rubric below is calibrated to THIS purpose — restate it
     so the scores mean something. -->
- Artifact: <path> · Purpose: <what it's for / who reads it / what decision it feeds>

## Hard gates (pass/fail — a failure fails the artifact)
<!-- Non-negotiables. If any is NO, the artifact fails regardless of dimension scores. -->
- [ ] **Grounded** — every load-bearing claim traces to a source (no confabulation).
- [ ] **Covers the whole ask** — every deliverable the request named is addressed (coverage beats depth on one surface).
- [ ] **No fabricated specifics** — names/numbers/citations are real and verifiable.

## Scored dimensions (0.0–1.0, with anchors)
<!-- Score each; write the anchor you're matching so the number is defensible. Tune the
     dimension SET to the artifact — these are the common ones. -->
| Dimension | Score | Anchor (0.0 → 0.5 → 1.0) |
|---|---|---|
| **Correctness** | _ | wrong claims → mostly right, some gaps → all claims hold up |
| **Completeness** | _ | misses core points → covers most → covers all load-bearing points |
| **Reasoning** | _ | asserts conclusions → shows some work → rationale + rejected alternatives visible |
| **Clarity for its reader** | _ | jargon-bombed / unreadable cold → mostly clear → self-sufficient, plain, leads with the point |
| **Actionability** | _ | no clear next step → implied → explicit, decidable next step |

## Verdict
<!-- PASS (all gates + weighted score above threshold) / REVISE (name the specific gaps) /
     FAIL (a gate failed). Verdict is a decision, not a vibe — state the reason. -->
- **Verdict:** <PASS | REVISE | FAIL> — <one-line reason + the specific fixes if REVISE>
