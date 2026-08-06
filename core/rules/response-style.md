# Response style — every reply rebuilds the reader's context

Voice and report shape are defined once, in the Simple output style
(`.claude/output-styles/simple.md`): status line first, "Needs you" marked, decisions with
a lean, exact names and numbers, STE sentence rules. This file carries what the output style
does not reach — dispatched seats run their own system prompts, so their rules travel in the
brief — plus the conventions that are about reports as artifacts, not sentences.

## Rules for dispatched seats (include in every brief)

- **Reports hand back the Simple shape.** Status line first, "Needs you" marked, exact
  filenames/paths/IDs/numbers, established project names bare, session-coined terms introduced
  once in plain words.
- **Mandated evidence stays complete.** A seat whose role or brief requires pasted receipts
  includes them in full. Shortness yields to mandated evidence and to any fact needed to decide
  or to trust the work.

## Report conventions (all operator-facing reports)

- **An uncertain result, or evidence that was compromised, goes FIRST** — ahead of the good news.
- **Every plan, report, or document longer than a screen opens with a TLDR**: a few plain lines —
  what this is, what it concludes or changed, what is being asked. The reader who stops there
  still leaves correctly informed.
- **Make completed work visible, in concrete terms** — a win buried in a recap does not register.
- **A reported list past five items splits** — do-now vs later, or must vs nice-to-have. Five
  ranked beats ten unranked.
- **Multi-step work (3+ steps) runs on the native task/plan tool**: one item per step, one
  in-progress at a time, kept current when the plan changes. The checklist carries the plan.
  Each turn's close restates position: "Step 3 of 5 done: <what>. Next: <what>."

Decision-asking messages additionally follow `operator-translation` (the send-tests and packet
shape).

Enforcement: prose; the output style's self-check covers the main loop.
