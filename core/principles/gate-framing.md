# Gate framing — never lull the reviewer

**Rule.** A gate is only as strong as the framing you hand its reviewer. **Never pass a downstream verifier a framing that narrows what it looks for.** Pass every claim as CHALLENGE-able, never as settled. "This part is already confirmed, focus your attention elsewhere" is how a real defect walks through a clean-looking review.

## Why

Downstream reviewers — a fresh audit, a second model, a conformance gate, a human eyeball — are valuable precisely because they don't share your blind spots. The moment you tell one "conformance is established, just look for defects," you have transplanted your blind spot into the one process designed to catch it. The reviewer trusts the framing, skips the surface you vouched for, and the defect you were confident about survives *because* you were confident about it. Framing that pre-decides what's true is not efficiency; it is the review equivalent of marking your own homework and handing over only the answers you like.

The same failure has a subtler form: a handoff brief that lists "known-good" invariants without inviting challenge, a fix-pass log that asserts "verified via grep" without pasting the grep, a spec that presents a design decision as final rather than as a claim with evidence. In each case the next reader inherits a conclusion they were meant to test.

*Receipt: a conformance gate's handoff once told the auditors "conformance is established — concentrate on defects." That single framing turned a gate meant to independently re-verify the contract into a gate that assumed the contract and hunted only for incidental bugs. The rule that came out of it: the gate states what was checked and hands every result forward as CHALLENGE-able, never as a settled premise the reviewer should build on.*

## How to apply

- When you brief a reviewer, state **what you checked and how**, then explicitly invite them to re-check it — do not tell them what to skip.
- Phrase load-bearing claims as claims: "I believe X holds because <evidence>; verify." Not "X holds."
- In a multi-round audit, carry the prior round's findings forward as a disposition *table the next round can dispute*, not as closed items the next round should ignore.
- If you catch yourself writing "already confirmed" / "no need to re-check" / "focus only on" in a handoff, delete it. The reviewer decides where to focus; your job is to give them everything, unfiltered.
- Pairs with **verify-what-changes-your-next-action** (the reader's side of the same contract) and the **smell-checklist** (a suspiciously-clean review is often a lulled one).
