# System-audit artifact template + adversarial-critique brief

## The audit artifact

Write to `<audits-dir>/<subsystem>-audit-<YYYY-MM-DD>.md`.

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

## Optional adversarial-subagent critique brief

For subsystems where audit rigor matters (security-sensitive, architectural, pre-production):
after your draft, dispatch a context-less adversarial subagent, pre-fed with the same sources you
read, to critique the audit *itself*.

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

Fold the subagent's findings back into the artifact; flag where its severity differs from your
initial read. (The tightly-scoped, security-focused version of this pattern is its own skill —
`scoped-adversarial-audit`.)
