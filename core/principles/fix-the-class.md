# Fix the class — grep for the siblings before you close

**Rule.** After any confirmed bug, before you call it closed: **grep for its siblings.** A bug is rarely unique — the same mistake was usually made everywhere the same pattern appears. Fix the class, not the instance.

## Why

A one-line fix to the instance in front of you leaves every other instance latent, and latent siblings surface later as "new" bugs that cost a fresh diagnosis each. Worse, a partial fix *looks* complete — tests pass, the reported symptom is gone — so the class silently persists behind a green check. The cheapest moment to find the siblings is right now, while you understand the exact shape of the mistake and the exact grep that finds it. An hour later that context is gone and each sibling is a cold start.

The discipline generalizes past code. A drifted decision in one doc is usually drifted in three. A missing guard on one write path is usually missing on the others. A stale claim in one section of a spec usually has copies. When you fix one, search the whole surface for the distinctive phrase or pattern and fix them together.

*Receipt: a shell-string extraction routine was found to un-escape only one of the four characters that need un-escaping — every glob-pattern rule that used any of the other three had been silently broken for days. The fix that mattered wasn't "handle this one character"; it was generalizing the routine to all four at once, then grepping the codebase for every place the same extraction pattern appeared. One character fixed is one character; the class fixed is the bug gone.*

## How to apply

- The moment a bug is confirmed, name its **pattern** (not its symptom): "a write path that doesn't check the deny-list," "a count asserted without re-querying," "a shell escape that handles a subset."
- Grep the whole surface for that pattern. Paste the grep and its hits — don't claim you did it (see the smell-checklist: "fixed" without evidence).
- Fix every hit in one pass, then add the regression test keyed to the class (see `templates/bugfix.md`).
- **Prevent the class, don't only sweep it — a guard and the write it protects must share ONE predicate.** When a prevalidation guard (a `can-do-X` check) gates a write (`do-X`), do NOT re-implement the guard's condition as a separate subset of the write's preconditions — the two drift, and the guard silently becomes *narrower* than the write it is supposed to mirror. Extract one `assertX` helper: the write throws through it, the guard returns its boolean. Then the guard cannot be narrower than the write. This is the structural version of "a missing guard on one path is missing on the others" — make divergence impossible instead of grepping for it after. *(Receipt: a countersign-eligibility predicate was authored too-narrow twice — first mirroring only a subset of the write's guards, then re-narrowing on the fix — each time a release-enabling gap the tests didn't catch; the durable fix was one shared assertion, after which the two could not diverge.)*
- Tension to hold consciously: this rule pushes *wider* while **surgical-changes** pushes *narrower*. Resolve it by scope, not instinct — fix every instance of *this exact class*, and touch nothing else. Widening to "and while I'm here, improve…" is the surgical-changes violation; leaving three siblings latent is the fix-the-class violation. The receipt on each rule tells you which edge you're near.
