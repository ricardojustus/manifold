# Research sufficiency — when you've read enough

**Rule.** Grounding is done when **new sources stop changing what you'd do next.** Not when you're tired, not when the token budget is tight, not when you've read the file the task named — when the marginal read stops moving the plan. And the bar for a design or a spec is specific: *you can explain the design's rationale AND its rejected alternatives from the sources*, not from inference.

## The stop rule

- **Keep reading while the plan keeps moving.** If each source changes what you'd build, you are not done — you are mid-discovery.
- **Stop when the plan stabilizes.** When two or three more sources add detail but don't change the shape of what you'd do, you have read enough.
- **The escalation:** if two more reads keep *reversing* your plan, the system is not understood — go **wider, not deeper.** Reversal-on-every-read means you're missing a load-bearing source, not that you need more depth on the ones you have.

## Verify the premises, not just the design

Reading the design tells you what was *decided*; it does not tell you whether the design's *premises still hold*. When a plan says "we must build X because Y doesn't exist / has gap Z," **verify Y against the current runtime before drafting** — grep, list, probe. If Y already exists in some form, the whole X-deliverable narrows or changes. Record the actual state of each premise in a "Verified Inputs" block at the top of the spec (see `templates/spec-skeleton.md`).

## Why

The failure this prevents is "discovery by rediscovery" — a design built on unread sources, where each audit round surfaces a primitive that invalidates the prior design, and you pay for the missing reads one expensive round at a time. Surface traces are the specific trap: a function signature or a grep hit proves a thing *exists*, never *why it's built that way* or *how data flows through it*. The rationale-and-rejected-alternatives bar forces you past the surface — you cannot explain why a design beat its alternatives from a signature alone; you have to have read the reasoning.

*Receipt: a spec was drafted on the premise that a certain runtime artifact "doesn't exist today," so a whole subsystem was scoped to create it. The artifact already existed — the runtime had been writing it all along. One `ls` before drafting would have narrowed the deliverable to a fraction. The plan read the design as-decided and never verified the design's claim of absence against what was actually running.*

## How to apply

- Enumerate the load-bearing sources *before* reading, then read them end-to-end — not the summary, the source. Grounding a spec means reading the actual (and superseded) specs, not their headers.
- For every "X doesn't exist" the plan asserts, probe the runtime and record the result in the Verified-Inputs block.
- Apply the sufficiency test consciously: after each source, ask "did that change what I'd do next?" When the answer is no twice running, stop.
- Enumerate the *whole* ask — coverage of every named deliverable beats depth on the one interesting surface.
