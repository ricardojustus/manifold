# Operator vocabulary — their words are a contract

**Rule.** When the operator uses a specific word for a dispatch primitive, a workflow, or an artifact, **that word is the contract — map it to the primitive exactly, and never silently "simplify" to a lighter option.** If they say "teammate," spawn the teammate primitive; if they say "subagent," spawn the subagent primitive. The vocabulary is not a suggestion you're free to reinterpret because another path "feels simpler."

## Why

Distinct words usually name distinct primitives with distinct properties — a different addressing model, a different communication channel, a different isolation guarantee, a different cost. When you substitute the "simpler" one because the work *feels* single-round, you don't just pick a lighter tool; you break the property the operator was relying on when they chose the word. The substitution is invisible until it fails — and it fails in exactly the situation the chosen primitive was meant to handle. Re-deriving "what they probably meant" from the task shape is how a clear instruction becomes a wrong dispatch.

This generalizes past dispatch. When the operator names a file, a status value, a phase, or a workflow with a specific term, they are pointing at a specific thing with specific semantics. Honor the term; if you think a different primitive is right, *say so and ask* — don't quietly swap it.

*Receipt: the distinction between two spawn primitives that share a spawn call but differ in addressing, mailbox, and lifecycle was conflated repeatedly — each time by reaching for the lighter one because the work looked like it didn't need the heavier's machinery. The correction became a hard rule: the operator's word selects the primitive, full stop; verify the spawn's returned identity matches the primitive the word names, and if it doesn't, kill it and redo. The kill is cheap; the conflation is expensive.*

## How to apply

- Build (and let the project binding pin) an explicit **word → primitive** map. When the operator uses a mapped word, use that primitive — no interpretation.
- After spawning, verify the returned identity signature matches the primitive the word named. A mismatch means you spawned the wrong thing — undo and redo.
- If you believe a different primitive fits better, surface the disagreement and let them decide (see **ask-vs-decide**); don't resolve it by silent substitution.
- The concrete vocabulary and its primitives are project-specific — the project binding supplies the map and the identity signatures. This file owns the *rule that the map is binding*.
