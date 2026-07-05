# Finding freshness — version-pinned facts are dated observations, not timeless rules

**Rule.** An empirical finding about a specific version of a runtime, tool, model, or API is a **dated observation, not a standing rule.** Record it with its date and a **re-verify-before-relying instruction**, and treat it as provisional the moment the pinned version could have changed underneath it.

## Why

Some of the most useful things an agent learns are also the most perishable: "this CLI flag also silently does X," "this frontmatter field doesn't propagate to the subprocess," "this model tier serves best at this effort level," "this issue is still open." Every one of these is true *at a version* and can quietly become false at the next release — and a false "fact" encoded as a timeless rule is worse than no rule, because it's trusted. The distinction that keeps the corpus honest is **rule vs observation**: a rule states a durable principle (grounding before asserting; the trifecta test); an observation states what a specific version did on a specific day. Observations earn their place, but they must wear their expiry.

A companion trap: a "still open" issue or a single community comment is a *process* signal, not a *runtime* signal — a fix can ship without the ticket closing. When a version-pinned claim is load-bearing for a decision (especially one committing you to a more complex path), the smallest empirical probe beats the freshest secondhand report.

*Receipt: a cluster of runtime findings — a frontmatter field silently dropped at a subprocess boundary, a per-teammate control that only worked through one specific path, an auth gate keyed to an exact system-prompt string — were all true at the versions they were captured on. Encoded as flat rules with no date, each would eventually mislead a session running a newer version. Encoded as dated observations with a "re-verify against the current runtime before relying" note, they stay useful without becoming traps.*

## How to apply

- Any finding that names a version, a model, a CLI, or an API contract gets, inline: **the date, the pinned version, and "re-verify before relying."**
- Distinguish at write time: is this a durable *rule* or a dated *observation*? Observations go where staleness is expected (a project binding, a dated lessons entry), not into a core rule that reads as timeless.
- When a pinned finding is load-bearing for a decision, run the cheapest probe that re-confirms it against the current runtime before you build on it.
- Concrete version-pinned findings belong in the **project binding** (which pins the models/tools du jour), not in core — core carries the *convention* that they must be dated and re-verified.
