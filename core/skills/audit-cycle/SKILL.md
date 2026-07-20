---
name: audit-cycle
description: >-
  Runs the pre-merge audit ladder — a fresh reviewer subagent plus an independent cross-model reviewer, multi-round to a 0 Critical/High/Medium lock gate. Required for any branch implementing a LOCKED spec, and for spec-LOCK cycles. Triggers "audit before merge", "round-N audit", "fix-pass", "/audit-cycle". Not a whole-subsystem pass (system-audit).
---

# Audit cycle — pre-merge layer-audit dispatch

Parallel primary reviewer + independent cross-model lens; multi-round to the lock gate;
round-N+1 with disposition tables; structured Low triage with per-project registries. Full
reviewer-prompt rubric: `references/reviewer-prompt-template.md`.

## When to invoke

**In scope**: a spec-lane branch (implements a LOCKED spec/contract) contract-clean + ready to
merge · a per-layer / per-chunk pre-merge audit in that lane · spec LOCK cycles · backlog-clearing
passes (working `audit-backlog.md` items) · "audit X" / "round-1 audit" / "dispatch the audit
cycle" / "audit before we merge" / "consolidate the audits".

**Out of scope**:
- Non-spec work (quick fixes, ops, tooling) — the methodology's **light review** by default
  (self-review + exercise-the-change + regression test where it's a bugfix + a single fresh-eyes
  reviewer at the builder's judgment). It enters this ladder at the **builder's judgment**, is
  never auto-excluded, and during autonomous work the builder records the call in the run journal.
- Single-PR diff review by one reviewer → the runtime's single-PR review tool
- Scoped adversarial pass on a security-sensitive surface → `scoped-adversarial-audit`
- Whole-subsystem inventory with no specific change → `system-audit`

**When rounds END**: on operator word or orchestrator judgment, once the finding tail goes cosmetic
or waived — the gate is 0C/0H/0M on REAL findings, not infinite rounds. Inherit declared postures
and waivers from earlier rounds and from design time: a settled threat-model or design posture is
challenged once with NEW evidence or respected, never re-litigated by default.

## The canonical audit directory (one location, everywhere)

```
AUDIT_DIR = <artifact-root>/audits/<topic>/round-<N>/
```

Pre-flight captures, each reviewer's output, and the consolidated findings all write there. The
three registries live one level up at `<artifact-root>/audits/` (project-wide, not per-topic).
**Never split reviewer outputs into a second tree** — a reviewer writing elsewhere produces a
mid-audit stall with no error to debug. The reviewer-prompt-template writes to `AUDIT_DIR`; keep
it that way.

## Gate 0 — spec-adherence runs FIRST (code implementations)

For **code implementations**, a conformance gate runs BEFORE round-1: verify the code implements
its LOCKED spec AS WRITTEN — every §section / decision / acceptance-criterion / invariant /
state-transition / error-path — fix the deviations, and dispatch the multi-model audit only on a
clean PASS. Conformance ("does the code obey the contract?") is a different axis from
defect-finding ("is the code correct/safe/robust?"): divergent code is internally consistent and
reads as correct, so it slips a bug-focused audit. Procedure lives in **`spec-adherence`** —
invoke it, don't re-derive it.

- Does NOT apply to spec-LOCK cycles (no impl to conform).
- Distinct from Cat #15 (which checks the *spec's* claims about existing code) and from the
  reviewer rubric's **contract-fidelity** category (an adversarial spot-check inside the rubric
  budget, whereas Gate 0 is exhaustive per-clause coverage — a round-1 fidelity finding surfacing
  a conformance gap means Gate 0's checklist was incomplete).
- **Round-1 pre-flight binds the gate to a sha**: record the PASS as `PASS @ <sha>`; before
  dispatching round-1, assert `git rev-parse HEAD` equals it. Differ (a piggybacked Low, a "quick"
  fix, a rebase after the gate) → the PASS is **STALE**; re-run spec-adherence scoped to the new
  commits first. The round-1 brief carries `spec-adherence PASSED @ <sha>` as a note that does NOT
  relax the fidelity/confab checks — reviewers still run both and flag any gap.

## The lock gate

**A subject LOCKs / merges when BOTH hold, for BOTH reviewers:**

1. **C/H/M = 0** — zero Critical, zero High, zero Medium open findings. *(Default floor; the
   methodology's chunk-risk tier can move it — a Critical chunk drives Lows to zero too, a
   Low-risk chunk may triage Mediums. `.claude/harness/METHODOLOGY.md` owns the tier→floor
   mapping.)*
2. **The latest pass produced no new C/H/M findings** — a clean-verification pass, not just a
   fixed-everything pass. New Lows triaged into the registries, waived findings, and dismissed
   disputes do NOT count against convergence.

Lows never block lock at the default floor. Every Low gets TRIAGED — triage is mandatory, fixing
is not.

**Loop cap: max 5 audit-fix cycles per subject.** Not converged after 5 → STOP, escalate to the
owner with the open-findings table and your read on why. Findings typically halve per round; a
flat or rising curve means the fold-ins aren't landing — surface it rather than grinding.

## Low triage (mandatory per Low)

Per Low the lead asks: **"under what realistic conditions does this cause a failure?"**

- **No realistic condition** → `audit-waivers.md` with the rationale. Never actioned.
- **Foreseeable future condition** → `audit-backlog.md` with the TRIGGER ("revisit when X").
  Deferred, not dropped.
- **Condition exists or is imminent** → PROMOTE to Medium; blocks lock normally.

Worked example per bucket: `references/low-triage-examples.md`.

- **Trivial Lows in either bucket may be fixed via piggyback ONLY** — folded into a fix-pass that
  already contains C/H/M fixes. Never spin a fix-pass for Lows alone.
- **Low handling is never the sole trigger of another audit cycle.** Only Lows open → triage, lock.

## Per-project registries (live at `<artifact-root>/audits/`)

- **`audit-waivers.md`** — waived + dismissed findings, never actioned. Entry: ID, summary,
  severity-as-reported, rationale (the "no realistic failure condition" argument), date, source
  cycle.
- **`audit-backlog.md`** — deferred fixes. Entry: ID, summary, trigger condition, date, source
  cycle. Backlog-clearing passes load ONLY this file as their work-list.
- **`disputed-findings.md`** — findings dismissed through adjudication. Entry: ID, finding, the
  coder's dispute justification, the adjudicator's ruling + reasoning, date.

**Feed BOTH `audit-waivers.md` + `audit-backlog.md` to reviewers on every pass**: "Do not
re-report findings listed in these files." One carve-out keeps waivers honest: a reviewer may
**CHALLENGE a waiver** — not re-report it — and a valid challenge MUST cite the specific change
(commit / diff / new code path) that invalidated its rationale. Re-arguing the original finding
against unchanged code is re-reporting (a no-op). A valid challenge reopens that entry for
re-triage; it is not a new finding.

## Disputed findings (cross-model adjudication)

A finding with **no concrete, reproducible failure scenario** may be disputed by the coder (lead /
fix-pass author) with WRITTEN justification. Adjudication goes to the **OTHER reviewer** — the
model that did NOT raise it. **Uphold** → fix at its severity. **Dismiss** → log in
`disputed-findings.md`; does not block lock. **The coder never self-adjudicates.** A dispute
without written justification is not a dispute. Dismissed findings join the do-not-re-report feed.

## The pattern

```
implement → commit → [code impls: spec-adherence Gate 0 → PASS @ sha (see `spec-adherence`)] → dispatch round-1 (parallel primary + cross-model)
  → wait for BOTH (consolidating after one reviewer is a recurring waste)
  → consolidate findings MAX-severity with empirical-truth carve-out
  → triage Lows (waive / backlog / promote) · adjudicate disputes
  → fix-pass commit (C/H/M + piggybacked trivial Lows) OR Path A spec amendment OR Path C bounded change
  → dispatch round-2 with disposition table + R2-A/B/C dimensions
  → lock gate met (C/H/M = 0 + no new C/H/M) → MERGE → push → cleanup
  → otherwise: round-3+ (cap 5; scope should decrease per round)
```

**Convergence expectation**: findings typically halve each round until clean. Budget 2-4 rounds for
substantive specs/layers, NOT 1-shot; each round catches different classes (structural →
fix-not-applied → cross-section drift → paperwork). **Round R+1 with MORE findings than round R**
means the round-R fold-in was insufficient — a signal, not a setback. Audit-resolution tables are
fold-in PLAN, not fold-in PROOF; proof is the NEXT round returning clean.

## Cross-model lens — why both

Each lens catches a class the other misses; convergence from different angles is the strongest
signal there is.

- **No redundant 3rd primary pass** after the primary + cross-model pair has run — marginal signal,
  wasted owner-attention.
- **Brief the primary reviewer empirically** or it won't grep code. Include: *"Grep `<path>` for
  `<pattern>`. Verify the design claim that `<helper>` exists. If existing code doesn't support
  `<feature>` without modification, flag it."* Running real code against real data/state surfaces
  what code-reading misses.
- **Prompt framing matters MORE than model family** — vary framing per reviewer for max
  angle-coverage.
- **Independence = fresh eyes + both families, NOT "exclude the author's family."** Two seats from
  two families, each seeing the work fresh — satisfied whether the author was a Claude or a Codex.
  A fresh same-family-as-author reviewer plus a cross-family reviewer IS the cross-model pair; a
  fresh seat carries none of the authoring session's blind spots. Exclude the author's *session*,
  never the author's *family*.

**No second lens available (solo fallback)**: the pair is the goal, not a precondition. No second
family reachable — none configured, fleet offline, or you are a lone agent — **do not skip the
audit**. Run the single lens you have plus an explicit self-review at the subject's tier floor,
and record the degradation: verdict **DONE_WITH_CONCERNS** with a line stating plainly that a
single-lens result is *weaker evidence* — it shares the author's blind spots, exactly the failure
the cross-model rule prevents. A one-lens LOCK is provisional: flag it for re-audit if a second
lens becomes reachable before the stakes justify shipping on one. Recorded, never hidden.

## Pre-flight (lead does this BEFORE dispatching reviewers)

Round-1:

1. Create `AUDIT_DIR` (= `<artifact-root>/audits/<topic>/round-1/`).
2. Capture INTO `AUDIT_DIR`: `<topic>-diff.patch` (`git diff <base>..<head>`) · `commit-list.txt`
   (`git log --oneline <base>..<head>`) · `test-output.txt` (the test-suite run, with any required
   env vars) · `typecheck-output.txt` (the typecheck run, target 0 errors).
3. Write `AUDIT_DIR/audit-state-notes.md`:
   - Subject + scope (file allowlist; "implementation as a whole" framing — anti-pattern 1)
   - Pre-known notes (PK#1, PK#2, … — flagged by the implementer/prior layers; reviewers MUST NOT
     re-flag)
   - **Registry feed**: paths to `audit-waivers.md` + `audit-backlog.md` + `disputed-findings.md`
     with the do-not-re-report instruction (+ the change-citing waiver-challenge carve-out)
   - Special audit dimensions (layer-specific load-bearing checks)
   - **Owner-confirmed inferences** — confirmed by the owner in prior sessions; MUST NOT re-flag
   - **Project-specific baseline** (when applicable — see the binding's dimensions)
   - Empirical state (test surface counts; typecheck lines; environment requirements)
4. Compose `AUDIT_DIR/reviewer-prompt.md` from `references/reviewer-prompt-template.md`.

Round-2+, ADD to audit-state-notes: the round-(N-1) disposition table (finding × MAX severity ×
disposition [fixed / waived / backlogged / promoted / disputed-dismissed] × fix-pass commit ×
what-to-verify) · the fix-pass commit map (SHA → addresses-finding) · test/typecheck artifacts
re-captured POST-fix-pass (stale-artifact reuse is a recurring failure).

## Dispatch — parallel, both in same turn

Both lenses in the SAME turn, both given the SAME `reviewer-prompt.md` (angle-coverage comes from
model diversity + per-reviewer framing variation, not different rubrics).

**Primary reviewer** — a reviewer **subagent** (NOT a teammate, per the dispatch-vocabulary
contract: a subagent returns via tool-result; a teammate is heavier and unneeded):
```
Agent({
  subagent_type: "reviewer",
  run_in_background: true,
  prompt: "Read <AUDIT_DIR>/reviewer-prompt.md and execute. Write to <AUDIT_DIR>/reviewer-<model>-round-<N>.md."
})
```
The `reviewer` role file (ships in `core/agents/`, installed to `.claude/agents/reviewer.md` with
the overlay's project floors appended) owns the effort pin and standing audit doctrine, so the
dispatch doesn't restate them. **The MODEL travels on the `Agent` call** (`model: "<tier>"` —
per-invocation beats frontmatter); the project's model pins name the reviewer tier.

**Independent cross-model reviewer** — a genuinely different model family, dispatched through the
project's cross-model mechanism, **paired with a completion-watcher** (cross-model reviewers
typically don't auto-notify like a subagent does; without the watcher the lead misses completion —
a recurring failure mode). The concrete dispatch command, completion-watcher, and
result-extraction are project-specific — **the binding names them and ships the `scripts/`**. Have
it write (or persist its returned result) to `<AUDIT_DIR>/reviewer-<model>-round-<N>.md` — same
`AUDIT_DIR`, never a second tree.

**Content-policy refusal = terminal for that attempt; the remedy is a MODEL SWAP, not a retry.** An
adversarial, security-framed review can trip the provider's content filter: the analysis runs,
then the provider REFUSES to emit the report (a cyber-risk / dual-use filter reading "attack this
code" as security work). A same-model retry re-trips the same filter. Remedy: re-dispatch the SAME
prompt once on the binding's named **filter-free fallback model** (the binding pins the exact
string + the refusal signatures); the swap counts against the dispatch attempt cap. Fallback also
refused, or none configured → the single-lens degradation path above, recorded honestly. Never
soften a refusal into "the reviewer found nothing" — a refused review is a MISSING lens, not a
clean one.

## Consolidation (after BOTH reviewers return)

Wait for both before drafting any fix code; single-pass synthesis on combined findings preserves
discipline.

**MAX-severity rule**: reviewers disagreeing on severity for the same finding → the higher rating
wins, UNLESS the underlying evidence is provably wrong (stale artifact, mis-read source).

**Dedup** — match findings across reviewers by `(file:line, issue-class)`:
- Same `file:line` + same issue → MERGE (keep the more detailed description; MAX severity; max
  confidence). **Tag `[multi-lens confirmed]`** — strong convergence signal.
- Same `file:line` + different issues → keep BOTH, tag `[co-located]`.
- Same issue + different `file:line` → keep separate, cross-reference.
- Conflicting fix recommendations on a merged finding → INCLUDE BOTH with reviewer attribution;
  the lead chooses during the fix-pass.

**Empirical-truth carve-out** — a higher-rated finding resting on bad evidence:
1. Document the disposition in the round-N+1 audit-state-notes.
2. **Re-capture the stale artifact and PASTE it inline in the disposition entry.** The carve-out is
   **INVALID unless the re-captured artifact is pasted** — evidence-or-it-didn't-happen, the same
   bar the skill holds reviewers to. A note merely asserting "the artifact was stale" is not a
   carve-out but an ungrounded severity dodge; MAX-severity stands until the evidence is shown.
3. Then decide pragmatically: (a) accept-as-resolved with the pasted disposition note, (b) apply
   the recommended fix anyway if small (the owner's preferred path — concrete code-change
   closure), or (c) dispatch a focused round-N+1 with fresh artifacts (architectural divergence).

**Disposition paths** (every finding gets exactly one):
- **Direct fix-pass** — code change, commit on feature branch (C/H/M; trivial Lows piggyback)
- **Path A — spec amendment** — the implementer's choice was deliberate-and-correct but the spec
  wording diverged; amend the spec (clerical ratification, not relitigation)
- **Path C — bounded code change** — a small additive change closes the finding + a related concern
- **Waive** — Low with no realistic failure condition → `audit-waivers.md`
- **Backlog** — Low with a foreseeable trigger → `audit-backlog.md`
- **Promote** — Low whose failure condition exists/is imminent → Medium, blocks lock
- **Dispute** — no concrete reproducible failure scenario → written justification →
  other-reviewer adjudication → fix or `disputed-findings.md`

**Consolidated findings output shape** — write to
`<AUDIT_DIR>/round-<N>-consolidated-findings.md`:
- **Per-lens summary table** — primary row, cross-model row, merged row × C/H/M/L counts
- **Verdict** — LOCK / NEEDS-FIX-PASS / NEEDS-ROUND-N+1 / ESCALATE (cycle-5 cap)
- **Disposition table** — every finding × reviewer source × MAX severity × disposition ×
  commit-SHA-once-applied (or registry entry ID)
- **Low-triage table** — each Low × its realistic-failure-condition answer × bucket (waive /
  backlog / promote / piggyback-fixed)
- **Recommended action sequence** — explicit fix order for the C/H/M set
- **Strengths preserved** — what NOT to touch in the fix-pass (prevents accidental regressions)
- **Empirical-truth carve-out notes** — any finding downgraded vs MAX-severity, **with the
  re-captured artifact pasted inline**

## Round-N+1 prompt scaffolding

Round-2 prompts need MORE than round-1 copy-pasted. Add to the reviewer-prompt:

1. Round-(N-1) disposition table (each finding's outcome, including triaged Lows)
2. Fix-pass commit map (SHA → which finding it addresses)
3. R2-A/B/C dimensions:
   - **R2-A**: round-(N-1) C/H/M closure verification (VERIFIED-CLOSED / STILL-OPEN /
     FALSE-POSITIVE per finding) + piggybacked-Low spot-check
   - **R2-B**: no new fix-pass issues (review the fix-pass diff explicitly — pitfalls: wrong
     error-class assertions, comment cruft, mis-mocked seams, scope creep)
   - **R2-C**: registry integrity — waived/backlogged items correctly recorded; a waiver may be
     challenged ONLY by citing the specific fix-pass change that invalidated its rationale
4. Re-audit scope is TIGHT to the fix diff — don't re-walk wide-surface edges already covered

**Re-audit C/H findings = same-session priority.** Fix them in the SAME session as atomic commits;
don't queue for "future hardening" — re-audits exist because the implementation team had blind
spots, and queuing defers the audit's value. Mediums: same-session default; the bar for deferring
is "structurally requires multi-day work" (then `audit-backlog.md` with its trigger, explicitly
owner-flagged, since a Medium-deferral bends the gate). Lows: triage.

## Evidentiary discipline — verify at edit time

Before any load-bearing claim in audit consolidation / fix-pass commit msg / spec amendment: file
content claim → Read fresh, paste relevant lines · system behavior claim → run the probe, paste
output inline · prior decision claim → grep the memory/lessons store, quote the line · empirical
result claim → check the tool output, don't paraphrase from working memory. Can't verify → mark
`[unverified]` and ask.

**Audit-trail location** — per the specs-describe-current-state HARD RULE, artifacts live under
`<artifact-root>/audits/<topic>/`, never in the spec body: round-N reviewer docs → `AUDIT_DIR` ·
consolidated findings + disposition tables → `AUDIT_DIR` · the three registries →
`<artifact-root>/audits/` root (project-wide) · the spec doc gets EDITED to reflect corrected
state, with a one-line CHANGELOG entry at top pointing at the audit artifact. Catching yourself
adding an audit log to a spec body: stop, move it to `audits/`, edit the spec body to the
corrected shape.

## Anti-patterns (don't regress)

1. **Diff-scoped audit framing** at the pre-merge gate — the subject is the full implementation,
   the diff is context only. (Rounds 2+ ARE diff-scoped — the re-audit rule, not this.)
2. **Consolidating after only one reviewer** — wait for BOTH.
3. **Skipping the cross-model completion-watcher** — recurring failure mode.
4. **Re-flagging pre-known notes, waived, backlogged, or dispute-dismissed findings** — they're
   listed explicitly; re-flags are no-op findings. A waiver challenge is legitimate ONLY when it
   cites the specific change that invalidated its rationale.
5. **Claimed-verification without evidence** — paste grep output / file excerpts inline.
6. **Stale artifact reuse** in round-2 — re-capture test-output + typecheck-output POST-fix-pass.
7. **Audit log inline in the spec** — artifacts go to `audits/`.
8. **Wide-surface re-audit** when the fix diff is narrow — wastes tokens on covered edges.
9. **Queuing re-audit C/H findings for "future hardening"** — same-session priority.
10. **A redundant 3rd primary pass after the primary + cross-model pair already ran.**
11. **Vacuous-coverage tests** — claims N×M assertions but only seeds N+M fixtures. Defend with
    positive controls + explicit nested loops (the test-coverage rubric category handles this).
12. **Conflating literal-source-grounding with truth-grounding** — a "hallucination" finding MUST
    distinguish (a) source-ungrounded AND truth-ungrounded, (b) false-against-reality, (c)
    source-weak but truth-strong (NOT a prompt-tightening candidate). Re-flagging (c) as (a) is a
    process failure.
13. **Enshrining audit framing against an explicit owner correction** — when the owner says a
    finding is wrong, the AUDIT is wrong. Don't "fix" the implementation against a factual
    correction. Save the correction to memory; add it to the PK list (or `audit-waivers.md`) for
    subsequent rounds.
14. **Propagating upstream spec claims into briefs/impl without re-verifying against current code**
    (the confab class — Cat #15) — ratification + LOCK confer design-intent agreement, NOT
    code-truth; re-grep at brief-write time.
15. **Fix-passes or audit cycles triggered by Lows alone** — Lows are triaged, piggybacked, or
    promoted; they never drive a cycle by themselves.
16. **Dispatching this multi-model audit on freshly-implemented code before spec-adherence Gate 0
    PASSES** (code impls) — conformance is a separate axis; a contract-divergent impl reads as
    correct and slips the bug-hunt. Run `spec-adherence` first (see Gate 0).

## Cat #15 — Spec-vs-Reality Confab Check

**When applicable**: every audit — the default. Spec drafts, spec LOCK cycles, and impl audits
where the spec is the reference share one failure mode: the spec author makes concrete claims
about code/files/patterns that don't match reality, and downstream consumers propagate them
without grepping. A **confabulation**: the spec claims X (file path / function name / line number
/ schema column / pattern reference / cross-ref to a sibling artifact) but X doesn't exist as
described in the current codebase.

**Reviewer verification methods** — for EVERY concrete claim, run the probe:
- File path → `ls <path>`
- Function / symbol → `grep -n "function <name>\|export function <name>\|class <name>" <file>`
- Line number → Read with offset/limit, OR `sed -n '<N>p' <file>`
- Schema column / DDL → grep the schema source; confirm constraints + nullability
- Pattern ("follow the existing X pattern") → confirm the pattern exists; if not, the spec
  invented a convention
- Cross-reference → `ls <sibling-spec-path>`; verify §N exists at the claimed anchor
- Line count → `wc -l <file>`
- **Normative-oracle claim** (a spec cell that *drives* impl + golden tests — an exact field list,
  a bound, a decoding/encoding behavior) → the symbol resolving is NOT enough. Read the cited
  handler **body end-to-end** and verify every claimed field / bound / behavior against it; a
  name-level "anchor exists" check gives false confidence on an oracle table.

**Reporting shape** (in consolidated findings):
```
## Cat #15 — Spec-vs-Reality Confab Check
- Verified claims: N
- Confabulated claims: M (each: §N.M : <claim> — CONFAB: <reality at file:line>)
- Ambiguous claims: K (listed; reasons)
- Confidence in spec: HIGH / MEDIUM / LOW
```

**Severity thresholds** (applied BEFORE judgment): **Critical floor** — any spec claim about
existing-code-shape that doesn't match; a spec with even ONE Critical confab cannot LOCK.
**High** — a pattern reference confabulated; the impl mid-flight will hit it. **Medium** — a
cross-reference to a non-existent sibling spec OR a named module that's elsewhere. **Low** — minor
numerical drift (line count off by 1-5), trivial citation precision; triage like any Low.

Cat #15 is the FIRST audit dimension, not the last — confabs in the spec invalidate every
downstream layer of audit.

## Project-specific audit dimensions

Some dimensions are project-specific — a data-substrate integrity measure, a domain-quality
metric, extra security primitives. They live in the **binding** (`## Project bindings`, appended
on install), which supplies the concrete thresholds + when they apply. When the audit subject is
unrelated, they don't apply.

## Related skills

- `scoped-adversarial-audit` — scoped adversarial single-pass on a security-sensitive surface
- `system-audit` — whole-subsystem inventory
- `spec-adherence` — Gate 0 for code impls (runs before round-1)
- `research` — the pre-feed dispatch shape this cycle reuses

Skill-eval test prompts: `references/test-prompts.md`.
