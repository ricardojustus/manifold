---
name: scoped-adversarial-audit
description: Spawn a context-less adversarial subagent to audit a tightly-scoped, security-sensitive surface — specific files, a pending change, or any code path where the author may have blind spots from having built it. Pre-feed the project's security threat model, point the subagent at the exact scope, and have it reason AS the attacker, then read its output critically before acting. Use when the operator says "adversarial pass on X", "fresh eyes on this", "what am I missing", "audit before we ship", "/scoped-adversarial-audit", or proactively before committing a security-sensitive change (a new external-data integration, a permission-model extension, a change to how untrusted content flows). NOT a whole-subsystem inventory (use `system-audit`); NOT a pre-merge multi-round lock-gate cycle (use `audit-cycle`). This is a focused adversarial single-pass on one scoped surface.
---

# Scoped adversarial audit

Generic PR-review and security-review tools are useful but don't know a project's *specific* security invariants — its trust model, its structural defense layers, its absolute rules. This skill is a wrapper pattern: spawn a context-less subagent pre-fed with the project's threat model, point it at an exact change, and let it critique without the author's confirmation bias.

The value comes from four things done together: **tight scope**, a **pre-fed threat model**, the subagent **reasoning as the attacker**, and the author **reading the output critically**. Drop any one and the audit degrades into vague reassurance.

## When to invoke

**Strong signals**:
- The operator says "adversarial pass", "fresh eyes", "what am I missing", "critique this", "audit before shipping".
- A new integration that pulls in external / untrusted data (its surface area is security-sensitive).
- Extending the permission / trust model (a new capability tier).
- Changing how untrusted content is wrapped or how it reaches the model.
- Touching a file the project's security baseline names as load-bearing.

**Weak signals** (judgment):
- Before a big refactor.
- After a session where you felt uncertain about a design choice.
- When the operator pushes back and you want independent verification.

**Not for**:
- A whole-subsystem inventory → `system-audit`.
- A pre-merge multi-round lock-gate cycle → `audit-cycle`.
- Generic PR review with no project-specific security context → the runtime's review tool.
- Cosmetic / style → a quality pass.

## The pattern

### 1. Scope tightly

Name the EXACT files + line ranges, or the EXACT diff, in scope. Vague scope produces vague audits.

- Bad: "Audit the new integration."
- Good: "Audit `<new-file>` (~180 lines) + the permission diff at `<file>` lines 84–102 — focus on: can a compromised low-trust actor write outside its scope through this path?"

### 2. Pre-feed the threat model

Include in the subagent's brief: the project's **security baseline** (the specific sections that govern this surface), the project's **current security posture** (its trust tiers, structural layers, evaluation order), the relevant **absolute rules**, and the **concrete threat model** — who the adversary is, what they're trying to do, and the instruction to reason AS that adversary. The project binding names these concrete sources + the threat model; the *shape* of the pre-feed is universal.

### 3. Spawn the subagent with a pointed brief

```
ADVERSARIAL audit of <exact scope>. You are a security-minded reviewer with NO attachment to how this was implemented. The author may have blind spots — find them.

## Scope
- <file path> (lines A–B)
- <file path 2> (change at line C)
(be exact)

## Pre-feed — read first
- <the project's security baseline, specific sections>
- <the project's current security-posture doc>
- <the relevant absolute-rule references>
- <the source files the scope depends on but that are NOT the change itself>

## Threat model
The adversary is <the project's concrete attacker — e.g. a prompt-injected component processing untrusted input>. Their goal: <exfiltrate a secret / write outside scope / escalate a capability / persist across sessions>. Reason as the attacker.

## Audit questions
1. <specific adversarial question about the scope>
2. <another>
3. <blast-radius question — "what's the damage if this path is compromised?">
4. "What did the author miss?" (open-ended catch)

## Output
- Each finding: severity (Critical / High / Medium) + evidence (specific file:line or a reproduction) + recommended fix.
- Explicit "no findings on <question>" when the answer is "the code is correct here" — don't imply a problem where there isn't one.
- Under 500 words. Be specific. Don't hedge. If you can't verify something, say "unable to verify X without testing" — that beats confident-but-wrong.
```

The explicit **"no findings on <question>"** honesty is load-bearing: it distinguishes "I checked and it's fine" from "I didn't look", which a silent omission conflates.

### 4. Read the output CRITICALLY

The subagent can also be wrong. Spot-check before acting:

- **High-severity claims**: does the finding actually reproduce? Try to construct the concrete path. If you can't, it may be a false positive.
- **"No issues found"**: did it actually look, or bail early? A suspiciously clean output on a complex surface usually means the brief was too narrow.
- **Disagreements with your own intuition**: where you and the subagent disagree, that's signal — either you were wrong (update) or it was wrong (sharpen the brief). Both resolutions are useful.

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
