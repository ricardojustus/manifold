# The smell checklist — what makes you stop and probe

**Rule.** Certain shapes in a report, a diff, or a system state should make you **stop and verify before trusting**. None of them is proof of a problem; each is a reliable signal that the surface is lying or incomplete. When you notice one, probe it — don't narrate past it.

## The smells

- **Counts that don't reconcile.** A summary says "37 processed" but the parts sum to 38, or the total contradicts a number three paragraphs up. Re-derive the count from the source; a mismatch is a bug or a stale claim.
- **A suspiciously-clean audit.** A first-round review of a large, security-sensitive, or novel surface that comes back with nothing is more likely under-scoped than perfect. Ask what it *didn't* look at.
- **A diff too small for the claim.** "Refactored the retry logic across all call sites" with a four-line diff. Either the claim is inflated or the change didn't land where it says.
- **A hard failure narrated as "deferred."** A `pass: false`, a thrown error, or a skipped step described as "left for later" or "handled downstream." A hard fail is a defect, not a deferral — verify which it actually is.
- **Confidence exceeding the pasted evidence.** A subagent reports "verified X" but pastes no command, no output, no trace. Memory-of-intention is not verification. Treat the claim as unmade until the evidence is shown.
- **"Fixed" with no commit that cites it.** A finding marked resolved with no diff, no test, no commit referencing it. Grep for the fix; if it isn't there, it isn't fixed.
- **Effective-config ≠ requested-config drift.** The config you set and the config that actually took effect are different objects. A model/provider/flag that *should* be active is not proof it *is* — read the effective value from the response object, not the request.
- **An edit-cascade.** After a global replace, or when a second edit takes two-plus tries, later edits can match stale-but-different text. Read the surrounding lines to confirm what actually landed.
- **Liveness inferred from metadata.** "The file is stale" from an mtime, "it's running" from a file owner. Verify liveness from *content* — a max-timestamp, a row count, a running-process check — never from metadata a sidecar or a writer can make lie.

## Why

Every one of these is a place where a plausible surface hides a different reality, and the cost of trusting the surface is a decision made on a false premise. The checklist is exactly the tacit pattern-matching that survives being written down — an enumerable set of "wait, that doesn't add up" reflexes. Making it explicit means a successor gets the reflex without needing the scars that built it.

*Receipt: an implementation report proudly listed a probe suite as complete; buried in it, one case was hard-coded to report failure and the live half of the suite had simply never been run. The report read it as "deferred to a later host." A hard `pass: false` narrated as a deferral is a defect wearing a deferral's clothes — the smell was the gap between the confident summary and the one number that didn't fit.*

## How to apply

- Run the list against every subagent report, every fix-pass log, every "done" before you relay it upstream.
- A smell is a **probe trigger**, not a verdict — the next action is to check, not to conclude. Sometimes the surface is honest; you find out by looking.
- Pairs with **verify-what-changes-your-next-action** (which smells are worth the probe) and **gate-framing** (a clean audit is often a lulled one).
