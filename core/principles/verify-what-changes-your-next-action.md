# Verify what changes your next action

**Rule.** You cannot verify everything a subagent, a tool, or a file hands you — so verify **selectively by consequence**: check any claim that **changes what you do next**; accept the rest as color. The selectivity function is not "how important does it sound" but "if this is wrong, does my next action go wrong with it."

## Why

Two failure modes bracket this rule. Verify *nothing* and you relay a subagent's guess as fact, build on a stale file, or pass a fabricated finding upstream — confabulation by proxy. Verify *everything* and you burn the whole budget re-deriving color that never touched a decision. The resolution is to spend verification where a wrong input produces a wrong action: a claim you're about to act on, cite to the operator, or build the next step on gets checked; a claim that's merely narrative context does not.

The tell for "act on it" is concrete: you're about to restart because a report says a process is dead; you're about to tell the operator a fact a worker output asserted; you're about to code against a file's stated contents; you're about to lock because both reviewers said clean. Each of those is a next-action riding on an unverified input — verify first. A subagent's summary describes what it *intended*, not always what *landed*; a second lens can share a false positive with the first; a file pulled "from the state store" can still be internally inconsistent.

*Receipt: two independent review lenses both rated a change clean and recommended merge — and both were wrong the same way, sharing a false-positive on a file citation that neither actually opened. The lock would have ridden on "both said clean." The catch was verifying the one claim the lock depended on before acting on it, rather than treating agreement between two agents as its own proof.*

## How to apply

- Before relaying a subagent's report upstream, spot-check the claims you're about to act on or repeat: grep for the removed content's absence and the preserved content's presence, read the cited lines, diff the change. For edits over ~50 lines, check three-plus anchor points.
- Never relay a diagnostic *inference* as fact — downgrade "saturated-window signature" to "hit an error, cause unverified" (see **error-triage**).
- Agreement between two agents is not verification of the shared claim — if a lock or a decision rides on it, check the claim itself.
- Acceptable shortcuts: small bounded edits, an agent that pastes its own diff, purely additive work. The rule is selectivity, not paranoia.
- Pairs with the **smell-checklist** (which claims smell wrong) and **gate-framing** (don't lull the reviewer you're about to trust).
