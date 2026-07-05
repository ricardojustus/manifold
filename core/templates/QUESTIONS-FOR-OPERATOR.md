<!--
  QUESTIONS-FOR-OPERATOR.md — the "what needs the human's decision" file for an unattended
  run. The third of the three thread-local hygiene files. Two kinds of entry live here:
  (1) genuine HALTS — things you did NOT do because they cross a halt line (irreversible /
  live-production / intent-unknown / operator-reserved), stated so the operator can decide;
  (2) PARKED RATIFICATIONS — autonomous calls you DID make and want the operator to confirm
  (cross-linked from DECISIONS). Write questions the operator can actually answer: lead with
  the concrete stake in plain language, name the thing by what it does for them (not by a
  codename or an internal id), give your recommendation, and say whether it's a real
  decision or a clerical default.
-->

# Questions for the operator — <thread/lane> — <run start YYYY-MM-DD>

_Reviewed in the morning. Blocking items are halts; ratification items are already-done calls awaiting confirmation._

## Blocking — needs a decision before I can proceed
<!-- Something you stopped on because it crosses a halt line. State it so a human with zero
     loaded context can decide: the plain-language stake, the concrete scenario, your lean,
     and whether it's a real product decision or a clerical default. NO jargon/codenames. -->
### Q-NNN — <plain-language question>
- **What's at stake:** <the user-visible consequence, in plain terms>
- **Why I stopped:** <which halt line — irreversible / live-prod / intent-unknown / reserved>
- **My lean:** <recommendation + one-line why>
- **Kind:** real product decision · OR · clerical default (I'll do the lean if you don't object)

## Ratify — I already decided this (reversible, in-scope); confirm or reverse
<!-- Cross-links to DECISIONS entries. The operator's sign-off gate is satisfied here. -->
- **↔ D-NNN** — <one-line summary> — <how to reverse if they disagree>
