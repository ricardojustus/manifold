---
name: system-audit
description: Run a structured audit of a whole subsystem — inventory the surface area, identify findings by severity (Critical / High / Medium / Low / Defer), propose a fix for each, and sequence the fixes for implementation. Produces a canonical audit artifact under the audits directory. Use when the operator says "audit X", "do a systemic pass on Y", "find the bugs in Z", "hardening pass", "/system-audit", or proactively when a subsystem has accumulated 3+ incidents of the same class, the operator has corrected the same class of issue twice, or a subsystem is about to absorb new load. NOT for a single change / PR (use the runtime's PR-review tool), NOT a scoped adversarial pass on a security-sensitive surface (use `scoped-adversarial-audit`), NOT a pre-merge multi-round lock-gate cycle (use `audit-cycle`). This is a systemic thinking pass on one whole subsystem with no specific pending change.
---

# System audit

A generic PR-review tool handles single-change reviews. This skill covers the different pattern: a STRUCTURED audit of a *whole subsystem*, producing a severity-sorted finding list + proposed fixes + implementation sequence. The output shape (severity matrix + detailed findings + execution sequence) is what makes an audit ACTIONABLE instead of aspirational — without the structure, audits produce vague concerns that never convert to commits.

## When to invoke

**Strong signals**:
- The operator explicitly asks for an audit of a specific subsystem.
- A subsystem has accumulated multiple incidents (3+ production or near-production issues of the same class).
- Before a subsystem absorbs new load (a new consumer, a cut-over, a major dependency bump touching it).
- The operator has corrected the same class of issue across sessions — a systemic root cause is likely.

**Weak signals** (use judgment):
- "This feels fragile" — maybe, maybe not worth a full audit.
- After a successful run — usually NOT audit-time; audits are triggered by friction, not success.

**Don't use for**:
- A single change / PR → the runtime's PR-review tool.
- A scoped adversarial pass on a security-sensitive surface → `scoped-adversarial-audit`.
- A pre-merge multi-round lock-gate cycle → `audit-cycle`.
- Code-style cleanup → a quality/simplify pass.
- Drive-by "while I'm here let me find things" — audits have cost; trigger them intentionally.

## Procedure

### 1. Scope the audit clearly

Before writing any findings, nail down:

- **Subsystem boundary**: exactly what files / modules / behaviors are in scope. Narrow is better — name the concrete modules, not "everything that touches this".
- **Time horizon**: e.g. "post-launch hardening" or "pre-cut-over readiness". This frames which findings matter against THIS horizon, not everything ever.
- **Explicit out-of-scope**: write it down. Prevents scope creep during the audit itself.

### 2. Inventory the surface area

Read every file in scope — not skim, read. Build a map:

- What are the modules and their responsibilities?
- What invariants does the system claim to guarantee?
- What are the extension points (no-code-change vs requires-code-change)?
- What's the log surface — what events fire, what error classes?
- What's NOT in the system — deferred items, known-not-yet-implemented design intent?

**This inventory often IS the reference-doc writeup for the subsystem.** If no current-state reference doc exists, the audit is a good moment to produce one — two outputs from one read pass (see `reference-doc-writing`).

### 3. Identify findings

For each potential finding, capture: **What** (one sentence), **Where** (file + line range, or a concept — not all findings are file-scoped), **Severity** (rubric below), **Impact** (the concrete failure mode if unaddressed), **Detection** (how you found it, how someone else would verify it).

### Severity rubric

| Severity | Meaning |
|---|---|
| **Critical / P0** | Production outage, data loss, security breach. Fix before merging. |
| **High / P1** | Reliability regression, silent data corruption, isolation breach. Fix in the same hardening pass. |
| **Medium / P2** | Observability gap, brittle error handling, broken recovery path, minor resource leak. Batch into the next hardening cycle. |
| **Low / P3** | Ergonomics, config redundancy, small dead code, cosmetic inconsistency. Fix when next touching the file. |
| **Defer** | Design intent that's known-not-yet-implemented. Document the gap; don't flag it as a bug. |

Don't inflate severity — a pile of P2s labelled "high" dilutes the signal that the actually-critical things need.

### 4. Propose fixes

For each finding (not just P0/P1 — all of them): **What to change** (file + approximate diff shape), **Why this fix vs alternatives** (if non-obvious), **Dependencies** (does it need another fix to land first?), **Risk** (does it change invariants? could it regress elsewhere?), **Verification** (how we'll know it worked — test, empirical observation, schema check).

### 5. Sequence the fixes

Build an execution order. Group fixes that touch the same file + similar scope into one block. Call out: **P0/P1 first** (these define "hardening complete"), **P2 stretch** (fit in if cycles allow), **P3 backlog** (queued for next touch). Dependencies matter — if fix B needs fix A, A blocks B; note it.

### 6. Produce the audit artifact

Write to `<audits-dir>/<subsystem>-audit-<YYYY-MM-DD>.md`. Structure:

```markdown
# <Subsystem> audit — <YYYY-MM-DD>

**Scope**: <what's in>
**Out of scope**: <what's out>
**Horizon**: <pre-X / post-Y>

## Severity matrix

| # | Finding | Severity | Where |
|---|---------|----------|-------|
| 1 | <short> | P0 | <file/module> |
| 2 | ... | P1 | ... |

## Findings (detailed)

### 1. <Finding title> [P0]

**Impact**: <concrete failure mode>
**Where**: <file:line or concept>
**Detection**: <how found>
**Fix**: <what to change>
**Risk**: <regression surface>
**Verification**: <how we'll know>

## Execution sequence

Block 1 (P0): Fix #1 + Fix #3 (same file, ship together); Fix #7 (independent)
Block 2 (P1): Fix #2 (depends on #1)
Deferred (P2/P3): Fix #4, #5, #6, #8 — backlog
```

## Optional: adversarial subagent pass

For subsystems where audit rigor matters (security-sensitive, architectural, pre-production): after your draft, dispatch a context-less adversarial subagent, pre-fed with the same sources you read, to critique the audit *itself*.

```
Review this draft audit of <subsystem>. Your job is to find what the audit MISSED.

Audit draft: <path or inline>
Pre-feed (what the author read): <reference/current-state docs>, <plan docs>, <source files in scope>

Look for:
- Findings the author downplayed or classified too low
- Failure modes that would happen under <specific adversarial scenario>
- Inconsistencies between what the audit claims and what the code actually does
- Fixes that wouldn't actually address the underlying issue

Output: each gap with a severity + evidence. Under 400 words.
```

Fold the subagent's findings back into the artifact; flag where its severity differs from your initial read. (The tightly-scoped, security-focused version of this pattern is its own skill — `scoped-adversarial-audit`.)

## After the audit

The audit artifact is the INPUT to hardening work, not the work itself. Ship the fixes in a follow-up pass (or the same session if scope is small); reference the audit in commit messages ("Block 1 of <subsystem>-audit-<date>: fixes #1+#3+#7").

**Leave the audit doc in the audits directory** — it's the historical record of what was found, what shipped, and what deferred. Future audits cross-reference it *there*. Do NOT move it into the current-state reference corpus: an audit report is a different genre (severity matrix + findings, not "how the subsystem works now"), and a current-state doc corpus that's also a search index treats a stray audit report as retrieval poison (see `doc-placement` and `reference-doc-writing` on genre purity).

## Related

- `scoped-adversarial-audit` — the tightly-scoped, security-focused adversarial single-pass (the subagent-critique pattern in isolated form).
- `audit-cycle` — the pre-merge multi-round parallel-reviewer cycle with a lock gate; different trigger, different output.
- `reference-doc-writing` — the inventory in step 2 often doubles as the subsystem's current-state doc.
- `doc-placement` — why the audit artifact stays in the audits directory, not the reference corpus.
