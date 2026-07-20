---
name: scoped-adversarial-audit
description: >-
  Spawns a context-less adversarial subagent, pre-fed the project threat model, to attack one tightly-scoped security-sensitive surface — named files or a pending change — reasoning as the attacker. Use on "adversarial pass on X", "what am I missing", or "fresh eyes" on a SECURITY surface; a pre-merge branch review is audit-cycle.
---

# Scoped adversarial audit

Spawn a context-less subagent pre-fed with the project's threat model, point it at an exact change, and let it critique without the author's confirmation bias. The value comes from four things done **together**: **tight scope**, a **pre-fed threat model**, the subagent **reasoning as the attacker**, and the author **reading the output critically**. Drop any one and the audit degrades into vague reassurance.

## When to invoke

**Strong signals**:
- The operator says "adversarial pass", "fresh eyes", "what am I missing", "critique this", "audit before shipping".
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

### 1. Scope tightly

Name the EXACT files + line ranges, or the EXACT diff, in scope. Vague scope produces vague audits. (Good/bad examples: `references/subagent-brief-template.md`.)

### 2. Pre-feed the threat model

Include in the subagent's brief: the project's **security baseline** (the specific sections governing this surface), the project's **current security posture** (trust tiers, structural layers, evaluation order), the relevant **absolute rules**, and the **concrete threat model** — who the adversary is, what they're trying to do, and the instruction to reason AS that adversary. The project binding names these concrete sources + the threat model; the *shape* of the pre-feed is universal.

### 3. Spawn the subagent with a pointed brief

Fill `references/subagent-brief-template.md`. Its mandatory elements: exact scope · the pre-feed list (baseline sections, posture doc, absolute rules, the dependency files that are NOT the change) · the threat model with "reason as the attacker" · 3+ specific adversarial questions including a blast-radius one and the open-ended "what did the author miss?" · an output contract (severity Critical/High/Medium + `file:line` evidence + recommended fix, under 500 words, no hedging, "unable to verify X without testing" when true).

The explicit **"no findings on <question>"** requirement is load-bearing: it distinguishes "I checked and it's fine" from "I didn't look", which a silent omission conflates.

### 4. Read the output CRITICALLY

The subagent can also be wrong. Spot-check before acting:

- **High-severity claims**: does the finding actually reproduce? Try to construct the concrete path. If you can't, it may be a false positive.
- **"No issues found"**: did it actually look, or bail early? A suspiciously clean output on a complex surface usually means the brief was too narrow.
- **Disagreements with your own intuition**: that's signal — either you were wrong (update) or it was wrong (sharpen the brief). Both resolutions are useful.

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
