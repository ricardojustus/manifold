---
name: scoped-adversarial-audit
description: >-
  Adversarial pass on one tightly-scoped security-sensitive surface — named files or a pending change. Use on "adversarial pass on X", "what am I missing", "fresh eyes", or "critique this" on a SECURITY surface; a pre-merge branch review is audit-cycle.
---

# Scoped adversarial audit

Spawn a context-less subagent pre-fed with the project's threat model, point it at an exact change, and let it critique without the author's confirmation bias. The value comes from four things done **together**: **tight scope**, a **pre-fed threat model**, the subagent **reasoning as the attacker**, and the author **reading the output critically**. Drop any one and the audit degrades into vague reassurance.

## When to invoke

**Strong signals**:
- A new integration that pulls in external / untrusted data.
- Extending the permission / trust model (a new capability tier).
- Changing how untrusted content is wrapped or how it reaches the model.
- Touching a file the project's security baseline names as load-bearing.

**Weak signals** (judgment): before a big refactor; after a session where you felt uncertain about a design choice; when the operator pushes back and you want independent verification.

**Not for**:
- A whole-subsystem inventory → `system-audit`.
- A pre-merge multi-round lock-gate cycle → `audit-cycle`.
- Generic PR review with no project-specific security context → the runtime's review tool.
- Cosmetic / style → a quality pass.

## The pattern

> Project bindings may prepend or amend steps — read the "## Project bindings" section (end of file) before the first step.

### 1. Scope tightly

Name the EXACT files + line ranges, or the EXACT diff, in scope. Vague scope produces vague audits. (Good/bad examples: `references/subagent-brief-template.md`.)

### 2. Pre-feed the threat model

Include in the subagent's brief: the project's **security baseline** (the specific sections governing this surface), the project's **current security posture** (trust tiers, structural layers, evaluation order), the relevant **absolute rules**, and the **concrete threat model** — who the adversary is, what they're trying to do, and the instruction to reason AS that adversary. The project binding names these concrete sources + the threat model; the *shape* of the pre-feed is universal.

### 3. Spawn the subagent with a pointed brief

Fill `references/subagent-brief-template.md` — it owns the brief's mandatory elements, and the brief is not optional. What you decide before opening it: the exact scope from step 1 (a vague scope voids the audit) and which adversarial questions this surface needs.

### 4. Read the output CRITICALLY

The subagent can also be wrong. Spot-check before acting:

- **High-severity claims**: does the finding actually reproduce? Try to construct the concrete path. If you can't, it may be a false positive.
- **"No issues found"**: did it actually look, or bail early? A suspiciously clean output on a complex surface usually means the brief was too narrow.
- **Disagreements with your own intuition**: that's signal — either you were wrong (update) or it was wrong (sharpen the brief). Both resolutions are useful.

Done when EVERY Critical/High finding carries a written reproduced-or-rejected verdict and every adversarial question in the brief is accounted for — answered by a finding or by the subagent's explicit "no findings on <question>" line. A question with neither is an unaudited question: go back to the brief.

### 5. Fold findings into action

- **Critical**: address before shipping the change in scope — fix, or explicitly accept the risk with a written rationale.
- **High**: fix before the next release.
- **Medium**: backlog.
- **Open disagreements**: escalate to the operator for the call.

Record the audit result in the commit message for the change, or as a dated entry in the project's reference/record store if it's substantive enough to keep.

## Related

- `system-audit` — whole-subsystem inventory; broader scope, different output.
- `audit-cycle` — the pre-merge multi-round parallel-reviewer cycle with a lock gate.
- `research` — the sibling pre-fed-subagent pattern, for knowledge-gathering rather than adversarial review.
- `brief-authoring` — the full discipline for the subagent brief you write here.
