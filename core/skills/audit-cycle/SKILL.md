---
name: audit-cycle
description: >-
  Dispatch the pre-merge layer-audit cycle — a primary reviewer subagent + an independent cross-model reviewer (each with a completion-watcher), multi-round to the 0/0/0 (C/H/M) lock gate with structured Low triage, MAX-severity consolidation with an empirical-truth carve-out. **Invoke whenever a feature branch is about to merge** — pre-merge gate, per-layer audits, spec LOCK cycles. Trigger phrases: "audit X" / "round-N audit" / "dispatch audit" / "audit before merge" / "fix-pass" / "consolidate the audits" / "/audit-cycle" — and proactively whenever a branch is contract-clean and ready to merge. The audit subject is the implementation AS A WHOLE, NOT the diff (diff-scoped framing is a recurring failure mode). DIFFERENT from `scoped-adversarial-audit` (scoped adversarial single-pass on a security-sensitive surface) and `system-audit` (whole-subsystem inventory with no specific change). DO NOT use for single-PR review, a scoped-security pass (`scoped-adversarial-audit`), or subsystem inventory (`system-audit`).
---

# Audit cycle — pre-merge layer-audit dispatch

The pre-merge audit pattern. Parallel primary reviewer + independent cross-model lens; multi-round to the lock gate; round-N+1 with disposition tables; structured Low triage with per-project registries. The WHY (the convergence + cross-model-lens receipts) is embedded inline below; the full reviewer-prompt rubric is in `references/reviewer-prompt-template.md`.

## When to invoke

**In scope** (use this skill):
- Feature branch contract-clean + ready to merge, needs a final audit gate
- Per-layer / per-chunk pre-merge audit
- Spec LOCK cycles
- "audit X" / "round-1 audit" / "dispatch the audit cycle" / "audit before we merge" / "consolidate the audits"
- Backlog-clearing passes (working `audit-backlog.md` items)

**Out of scope** (different skill):
- Single-PR diff review by one reviewer → the runtime's single-PR review tool
- Scoped adversarial pass on a security-sensitive surface → `scoped-adversarial-audit`
- Whole-subsystem inventory with no specific change → `system-audit`

## The canonical audit directory (one location, everywhere)

Every artifact in a round lives under **ONE** path:

```
AUDIT_DIR = <artifact-root>/audits/<topic>/round-<N>/
```

Pre-flight captures, each reviewer's output, and the consolidated findings all write there. The three registries live one level up at `<artifact-root>/audits/` (project-wide, not per-topic). **Do not split reviewer outputs into a second tree** — a reviewer told to write somewhere other than `AUDIT_DIR` produces a mid-audit stall with no error to debug (the lead dispatches to one tree, then looks in the other). The reviewer-prompt-template writes to `AUDIT_DIR`; keep it that way.

## Gate 0 — spec-adherence runs FIRST (code implementations)

For **code implementations**, a conformance gate runs BEFORE round-1: verify the code implements its LOCKED spec AS WRITTEN — every §section / decision / acceptance-criterion / invariant / state-transition / error-path — fix the deviations, and only on a clean PASS dispatch the multi-model audit below. This is a **different axis** from the adversarial defect-hunt: conformance ("does the code obey the contract?") vs. defect-finding ("is the code correct/safe/robust?"). Skipping it lets a contract-divergent implementation reach — and often pass — the bug-focused audit, because divergent code is internally consistent and reads as correct. The fan-out conformance procedure lives in the **`spec-adherence`** skill (invoke it; don't re-derive it here). Gate 0 does NOT apply to spec-LOCK cycles (no impl to conform). It is distinct from the spec-vs-reality confab check (Cat #15, which checks the *spec's* claims about existing code); Gate 0 checks the new *code's* fidelity to the spec. It is also distinct from the reviewer rubric's **contract-fidelity** category: that is an adversarial *spot-check* inside the rubric budget, whereas Gate 0 is *exhaustive per-clause* coverage — if a round-1 fidelity finding surfaces a conformance gap, that signals Gate 0's checklist was incomplete.

**Round-1 pre-flight binds the gate to a sha**: a spec-adherence PASS is recorded as `PASS @ <sha>`; before dispatching round-1, assert `git rev-parse HEAD` equals that sha. If they differ (a piggybacked Low, a "quick" fix, a rebase landed after the gate), the PASS is **STALE** → re-run spec-adherence scoped to the new commits before round-1. The round-1 brief carries `spec-adherence PASSED @ <sha>` as a note that does NOT relax the fidelity/confab checks — reviewers still run both and flag any gap.

## The lock gate

**A subject LOCKs / merges when BOTH hold, for BOTH reviewers:**

1. **C/H/M = 0** — zero Critical, zero High, zero Medium open findings. *(This is the default floor; the methodology's chunk-risk tier can move it — a Critical chunk drives Lows to zero too, a Low-risk chunk may triage Mediums. `.claude/harness/METHODOLOGY.md` owns the tier→floor mapping.)*
2. **The latest pass produced no new C/H/M findings** (a clean-verification pass, not just a fixed-everything pass). New Lows triaged into the registries, waived findings, and dismissed disputes do NOT count against convergence.

Lows never block lock at the default floor. Every Low gets TRIAGED (next section) — triage is mandatory, fixing is not.

**Loop cap: max 5 audit-fix cycles per subject.** Not converged after 5 → STOP and escalate to the owner with the open-findings table and your read on why it isn't converging. Convergence findings typically halve per round; a flat or rising curve is a signal the fold-ins aren't landing — surface it rather than grinding.

## Low triage (mandatory per Low)

For each Low, the lead asks: **"under what realistic conditions does this cause a failure?"**

- **No realistic condition** → add to `audit-waivers.md` with the rationale. Never actioned.
- **Foreseeable future condition** → add to `audit-backlog.md` with the TRIGGER condition ("revisit when X"). Deferred, not dropped.
- **Condition exists or is imminent** → PROMOTE to Medium; blocks lock normally.

**Worked examples** (the triage question, answered — one per bucket):
- **Waive.** A Low flags that an internal helper returns `undefined` for an input the type system already forbids (a guard for an impossible case). Realistic-failure-condition: *"no caller can construct that input — the enum is closed."* → `audit-waivers.md` with that rationale; never actioned.
- **Backlog-with-trigger.** A Low flags a fixed-size in-memory buffer that's fine at today's ~200 items but silently drops entries past ~10k. Answer: *"no failure now; fails when the corpus crosses ~10k items."* → `audit-backlog.md`, trigger: *"revisit when item count approaches 10k."*
- **Promote.** A Low flags a retry loop with no backoff. Answer: *"the upstream it calls already rate-limits us at current volume — the failure condition exists now."* → PROMOTE to Medium; blocks lock like any Medium.

Rules:
- **Trivial Lows in either bucket may be fixed via piggyback ONLY** — folded into a fix-pass that already contains C/H/M fixes. Never spin a fix-pass for Lows alone.
- **Low handling must never be the sole trigger of another audit cycle.** If the only open items are Lows, triage them and lock.

## Per-project registries (live at `<artifact-root>/audits/`)

- **`audit-waivers.md`** — waived + dismissed findings, never actioned. Entry: ID, finding summary, severity-as-reported, rationale (the "no realistic failure condition" argument), date, source cycle.
- **`audit-backlog.md`** — deferred fixes with trigger conditions. Entry: ID, finding summary, the trigger condition, date, source cycle. Backlog-clearing passes load ONLY this file as their work-list.
- **`disputed-findings.md`** — findings dismissed through adjudication (next section). Entry: ID, finding, the coder's dispute justification, the adjudicator's ruling + reasoning, date.

**Feed BOTH `audit-waivers.md` + `audit-backlog.md` to reviewers on every pass**: "Do not re-report findings listed in these files." One carve-out keeps waivers honest: a reviewer may **CHALLENGE a waiver** — not re-report it — and a valid challenge MUST cite the specific change (commit / diff / new code path) that invalidated the waiver's rationale. Re-arguing the original finding against unchanged code is NOT a valid challenge and is treated as re-reporting (a no-op). A valid challenge reopens that entry for re-triage; it is not a new finding.

## Disputed findings (cross-model adjudication)

If a finding has **no concrete, reproducible failure scenario**, the coder (the lead / fix-pass author) may dispute it with WRITTEN justification. Adjudication goes to the **OTHER reviewer** — the model that did NOT raise the finding:

- **Uphold** → fix it (at its severity).
- **Dismiss** → log in `disputed-findings.md`; does not block lock.

**The coder never self-adjudicates.** A dispute without a written justification is not a dispute. Dismissed findings join the do-not-re-report feed.

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

## Convergence expectation

Findings typically halve each round until clean. *Receipt: one spec LOCK ran 28 → 11 → 5 → 4 → 0 across 5 rounds — monotone decrease.* Budget 2-4 rounds for substantive specs/layers, NOT 1-shot. Each round catches different issue classes (structural → fix-not-applied → cross-section drift → paperwork).

**If round R+1 has MORE findings than round R**, the round-R fold-in was insufficient — that's a signal, not a setback. Audit-resolution tables are fold-in PLAN, not fold-in PROOF; proof is the NEXT round returning clean.

## Cross-model lens — why both

The cross-model lens has been load-bearing in every cycle: each lens catches a class the other misses. *Receipt: in one round the cross-model reviewer caught a Critical by tracing prompt assembly, while the primary reviewer caught a pilot-killing High by RUNNING the real code against the real seeded data — neither caught the other's headline.* *Receipt: in another, the cross-model reviewer flagged that a retry callback discarded state (defeating a token-escalation path) while the primary rated the change a clean merge.* Convergence-from-different-angles is the strongest signal there is.

**Don't dispatch a redundant 3rd primary pass** after the primary + cross-model pair has run — marginal new signal; wastes owner-attention.

**Brief the primary reviewer empirically** or it won't grep code. Include in the brief: *"Grep `<path>` for `<pattern>`. Verify the design claim that `<helper>` exists. If existing code doesn't support `<feature>` without modification, flag it."* Empirical-against-live-state probing (running real code against real data/state) is the discipline that surfaces the findings code-reading misses.

**Skill-prompt framing matters MORE than model family** — vary the prompt framing per reviewer for max angle-coverage.

## No second lens available (solo fallback)

The cross-model pair is the goal, not a precondition. If no second model family is reachable — no cross-model mechanism is configured, the fleet is offline, or you are a lone agent — **do not skip the audit**. Run it with the single lens you have, plus an explicit self-review at the subject's tier floor, and record the degradation in the audit record: verdict **DONE_WITH_CONCERNS**, with a line stating plainly that a single-lens result is *weaker evidence* — it shares the author's blind spots, which is exactly the failure the cross-model rule exists to prevent. A one-lens LOCK is provisional: flag it for re-audit if a second lens becomes reachable before the stakes justify shipping on one. The deviation is recorded, never hidden — but skipping the audit entirely because the fleet is missing is never the answer.

## Pre-flight (lead does this BEFORE dispatching reviewers)

For round-1:

1. Create `AUDIT_DIR` (= `<artifact-root>/audits/<topic>/round-1/`).
2. Capture artifacts INTO `AUDIT_DIR`:
   - `<topic>-diff.patch` — `git diff <base>..<head>`
   - `commit-list.txt` — `git log --oneline <base>..<head>`
   - `test-output.txt` — the test-suite run (with any required env vars)
   - `typecheck-output.txt` — the typecheck run (target 0 errors)
3. Write `AUDIT_DIR/audit-state-notes.md`:
   - Subject + scope (file allowlist; "implementation as a whole" framing — see anti-pattern 1)
   - Pre-known notes (PK#1, PK#2, … — items the implementer/prior-layers flagged; reviewers MUST NOT re-flag)
   - **Registry feed**: paths to `audit-waivers.md` + `audit-backlog.md` + `disputed-findings.md` with the do-not-re-report instruction (+ the change-citing waiver-challenge carve-out)
   - Special audit dimensions (layer-specific load-bearing checks)
   - **Owner-confirmed inferences** — inferences the owner has explicitly confirmed in prior sessions; reviewers MUST NOT re-flag
   - **Project-specific baseline** (when applicable — see the binding's project-specific audit dimensions)
   - Empirical state (test surface counts; typecheck lines; environment requirements)
4. Compose `AUDIT_DIR/reviewer-prompt.md` from `references/reviewer-prompt-template.md`.

For round-2+, ADD to audit-state-notes:
- Round-(N-1) disposition table: finding × MAX severity × disposition (fixed / waived / backlogged / promoted / disputed-dismissed) × fix-pass commit × what-to-verify
- Fix-pass commit map: SHA → addresses-finding
- Updated test/typecheck artifacts (re-captured POST-fix-pass — stale-artifact reuse is a recurring failure)

## Dispatch — parallel, both in same turn

Two lenses, dispatched in the SAME turn. Both get the SAME `reviewer-prompt.md` (angle-coverage comes from model diversity + per-reviewer framing variation, not different rubrics):

**Primary reviewer** — a reviewer **subagent** (NOT a teammate — per the dispatch-vocabulary contract; a subagent returns via tool-result, a teammate is heavier and unneeded here):
```
Agent({
  subagent_type: "reviewer",
  run_in_background: true,
  prompt: "Read <AUDIT_DIR>/reviewer-prompt.md and execute. Write to <AUDIT_DIR>/reviewer-<model>-round-<N>.md."
})
```
The project's reviewer role file owns the default model, effort, and standing audit doctrine, so the dispatch doesn't restate them. (A session-scoped model override from the owner goes on the `Agent` call.)

**Independent cross-model reviewer** — a reviewer from a genuinely different model family, dispatched through the project's cross-model mechanism, **paired with a completion-watcher**. A cross-model reviewer typically doesn't auto-notify like a subagent does — without the watcher the lead misses completion (a recurring failure mode). The concrete dispatch command, the completion-watcher, and the result-extraction are project-specific — **the binding names them and ships the `scripts/`**. Have it write (or have the lead persist its returned result) to `<AUDIT_DIR>/reviewer-<model>-round-<N>.md` — the same `AUDIT_DIR`, never a second tree.

## Consolidation (after BOTH reviewers return)

Wait for both before drafting any fix code. Single-pass synthesis on combined findings preserves discipline.

**MAX-severity rule**: when reviewers disagree on severity for the same finding, the higher rating wins — UNLESS underlying evidence is provably wrong (stale artifact, mis-read source).

**Dedup algorithm** — match findings across reviewers by `(file:line, issue-class)` key:
- Same `file:line` + same issue → MERGE into one finding (keep the more detailed description; take MAX severity; max confidence). **Tag `[multi-lens confirmed]`** — strong convergence signal.
- Same `file:line` + different issues → keep BOTH, tag `[co-located]`.
- Same issue + different `file:line` → keep separate, cross-reference.
- Conflicting fix recommendations on a merged finding → INCLUDE BOTH with reviewer attribution; the lead chooses during the fix-pass.

**Empirical-truth carve-out** — when a higher-rated finding rests on bad evidence:
1. Document the disposition in the round-N+1 audit-state-notes.
2. **Re-capture the stale artifact and PASTE it inline in the disposition entry.** The carve-out is **INVALID unless the re-captured artifact is pasted** — evidence-or-it-didn't-happen, exactly the evidentiary bar the skill holds reviewers to. A downgrade note that merely asserts "the artifact was stale" without the fresh capture inline is not a carve-out; it's an ungrounded severity dodge, and MAX-severity stands until the evidence is shown.
3. Then decide pragmatically: (a) accept-as-resolved with the pasted disposition note, (b) apply the recommended fix anyway if small (the owner's preferred path — concrete code-change closure), or (c) dispatch a focused round-N+1 with fresh artifacts (for architectural divergence).

**Disposition paths** (every finding gets exactly one):
- **Direct fix-pass** — code change, commit on feature branch (C/H/M; trivial Lows piggyback)
- **Path A — spec amendment** — the implementer's choice was deliberate-and-correct but the spec wording diverged; amend the spec (clerical ratification, not relitigation)
- **Path C — bounded code change** — a small additive change closes the finding + a related concern
- **Waive** — Low with no realistic failure condition → `audit-waivers.md`
- **Backlog** — Low with a foreseeable trigger → `audit-backlog.md`
- **Promote** — Low whose failure condition exists/is imminent → Medium, blocks lock
- **Dispute** — no concrete reproducible failure scenario → written justification → other-reviewer adjudication → fix or `disputed-findings.md`

## Consolidated findings output shape

Write to `<AUDIT_DIR>/round-<N>-consolidated-findings.md`:

- **Per-lens summary table** — primary row, cross-model row, merged row × C/H/M/L counts. Calibration signal at a glance.
- **Verdict** — LOCK / NEEDS-FIX-PASS / NEEDS-ROUND-N+1 / ESCALATE (cycle-5 cap)
- **Disposition table** — every finding × reviewer source × MAX severity × disposition × commit-SHA-once-applied (or registry entry ID)
- **Low-triage table** — each Low × the realistic-failure-condition answer × bucket (waive / backlog / promote / piggyback-fixed)
- **Recommended action sequence** — explicit fix order for the C/H/M set
- **Strengths preserved** — what NOT to touch in the fix-pass (prevents accidental regressions)
- **Empirical-truth carve-out notes** — any finding downgraded vs MAX-severity, **with the re-captured artifact pasted inline**

## Round-N+1 prompt scaffolding

Round-2 prompts need MORE than round-1 copy-pasted. Add to the reviewer-prompt:

1. Round-(N-1) disposition table (each finding's outcome, including triaged Lows)
2. Fix-pass commit map (SHA → which finding it addresses)
3. R2-A/B/C dimensions:
   - **R2-A**: round-(N-1) C/H/M closure verification (VERIFIED-CLOSED / STILL-OPEN / FALSE-POSITIVE per finding) + piggybacked-Low spot-check
   - **R2-B**: no new fix-pass issues (review the fix-pass diff explicitly — pitfalls: wrong error-class assertions, comment cruft, mis-mocked seams, scope creep)
   - **R2-C**: registry integrity — waived/backlogged items correctly recorded; a waiver may be challenged ONLY by citing the specific fix-pass change that invalidated its rationale
4. Re-audit scope is TIGHT to the fix diff — don't re-walk wide-surface edges already covered

## Re-audit C/H findings = same-session priority

When a re-audit returns Critical/High findings, fix in the SAME session as atomic commits. Don't queue for "future hardening" — re-audits exist because the implementation team had blind spots; queuing defers the audit's value. Mediums: same-session default; bar for deferring = "structurally requires multi-day work" (then it goes to `audit-backlog.md` with its trigger, explicitly owner-flagged since a Medium-deferral bends the gate). Lows: triage.

## Evidentiary discipline — verify at edit time

Before writing any load-bearing claim in audit consolidation / fix-pass commit msg / spec amendment:
- File content claim → Read fresh; paste relevant lines
- System behavior claim → run the probe; paste output inline
- Prior decision claim → grep the memory/lessons store; quote the line
- Empirical result claim → check the tool output; don't paraphrase from working memory

If you can't verify, mark `[unverified]` and ask. *Receipt: a batch of evidentiary errors in a single spec-revision session all got caught by the audit cycle — they should have been caught at edit time.*

## Audit-trail location — per the specs-describe-current-state HARD RULE

Audit artifacts live under `<artifact-root>/audits/<topic>/` — never in the spec body:

- Round-N reviewer docs → `AUDIT_DIR`
- Consolidated findings + disposition tables → `AUDIT_DIR`
- The three registries → `<artifact-root>/audits/` root (project-wide)
- Spec doc: gets EDITED to reflect corrected state; a one-line CHANGELOG entry at top points at the audit artifact

*Receipt: folding audit-resolution logs into spec `§X.5` sections once produced a 13-round patch-spec hell — the audit cycles started finding discrepancies in the audit trail itself.* If you find yourself adding an audit log to a spec body: stop, move it to `audits/`, edit the spec body to the corrected shape.

## Anti-patterns (don't regress)

1. **Diff-scoped audit framing** at the pre-merge gate — wrong; the subject is the full implementation, the diff is context only. (Rounds 2+ ARE diff-scoped — that's the re-audit rule, not this anti-pattern.)
2. **Consolidating after only one reviewer** — wait for BOTH.
3. **Skipping the cross-model completion-watcher** — recurring failure mode.
4. **Re-flagging pre-known notes, waived, backlogged, or dispute-dismissed findings** — they're listed explicitly; re-flags are no-op findings. A waiver challenge is legitimate ONLY when it cites the specific change that invalidated the waiver's rationale.
5. **Claimed-verification without evidence** — paste grep output / file excerpts inline.
6. **Stale artifact reuse** in round-2 — re-capture test-output + typecheck-output POST-fix-pass.
7. **Audit log inline in the spec** — artifacts go to `audits/`.
8. **Wide-surface re-audit** when the fix diff is narrow — wastes tokens on edges already covered.
9. **Queuing re-audit C/H findings for "future hardening"** — they are same-session priority.
10. **A redundant 3rd primary pass after the primary + cross-model pair already ran** — marginal new signal.
11. **Vacuous-coverage tests** — claims N×M assertions but only seeds N+M fixtures. Defend with positive controls + explicit nested loops (the test-coverage rubric category handles this).
12. **Conflating literal-source-grounding with truth-grounding** — a "hallucination" finding MUST distinguish (a) source-ungrounded AND truth-ungrounded, (b) false-against-reality, (c) source-weak but truth-strong (NOT a prompt-tightening candidate). Re-flagging (c) as (a) is a process failure.
13. **Enshrining audit framing against an explicit owner correction** — when the owner says an audit finding is wrong, the AUDIT is wrong. Don't "fix" the implementation against a factual correction. Save the correction to memory; add it to the PK list (or `audit-waivers.md`) for subsequent rounds.
14. **Propagating upstream spec claims into briefs/impl without re-verifying against current code** (the confab class — Cat #15) — ratification + LOCK confer design-intent agreement, NOT code-truth; re-grep at brief-write time.
15. **Fix-passes or audit cycles triggered by Lows alone** — Lows are triaged, piggybacked, or promoted; they never drive a cycle by themselves.
16. **Dispatching this multi-model audit on freshly-implemented code before spec-adherence Gate 0 PASSES** (code impls) — conformance is a separate axis; a contract-divergent impl reads as correct and slips the bug-hunt. Run `spec-adherence` first (see Gate 0).

## Cat #15 — Spec-vs-Reality Confab Check

**When applicable**: every audit. The default. Spec drafts, spec LOCK cycles, and impl audits where the spec is the reference — each has the same failure mode: the spec author makes concrete claims about code/files/patterns that don't match reality, and downstream consumers propagate them without grepping.

A **confabulation** is: the spec claims X (file path / function name / line number / schema column / pattern reference / cross-ref to a sibling artifact) but X doesn't exist as described in the current codebase.

**Reviewer verification methods** — for EVERY concrete claim, run the probe:
- File-path claim → `ls <path>`
- Function / symbol claim → `grep -n "function <name>\|export function <name>\|class <name>" <file>`
- Line-number claim → Read with offset/limit, OR `sed -n '<N>p' <file>`
- Schema column / DDL claim → grep the schema source; confirm constraints + nullability
- Pattern claim ("follow the existing X pattern") → confirm the pattern exists; if not, the spec invented a convention
- Cross-reference claim → `ls <sibling-spec-path>`; verify §N exists at the claimed anchor
- Line-count claim → `wc -l <file>`

**Reporting shape** (in consolidated findings):
```
## Cat #15 — Spec-vs-Reality Confab Check
- Verified claims: N
- Confabulated claims: M (each: §N.M : <claim> — CONFAB: <reality at file:line>)
- Ambiguous claims: K (listed; reasons)
- Confidence in spec: HIGH / MEDIUM / LOW
```

**Severity thresholds** (applied BEFORE judgment):
- **Critical floor** — any spec claim about existing-code-shape that doesn't match. A spec with even ONE Critical confab cannot LOCK.
- **High** — a pattern reference confabulated; the impl mid-flight will hit it.
- **Medium** — a cross-reference to a non-existent sibling spec OR a named module that's elsewhere.
- **Low** — minor numerical drift (line count off by 1-5), trivial citation precision. Triage like any Low.

*Receipt: an overnight spec batch carried 20 confabs across 4 specs (invented directories, modules, enums, cross-refs); the clean spec was the one whose author did real end-to-end reads.* Cat #15 is the FIRST audit dimension, not the last — confabs in the spec invalidate every downstream layer of audit.

## Project-specific audit dimensions

Some audit dimensions are project-specific — a data-substrate integrity measure, a domain-quality metric, extra security primitives. Those live in the **binding** (`## Project bindings`, appended on install), which supplies the concrete thresholds + when they apply. When the audit subject is unrelated, they don't apply.

## Related skills

- `scoped-adversarial-audit` — scoped adversarial single-pass on a security-sensitive surface
- `system-audit` — whole-subsystem inventory
- `spec-adherence` — Gate 0 for code impls (runs before round-1)
- `research` — the pre-feed dispatch shape this cycle reuses

## Test prompts

1. *"I'm ready to merge `feature/<x>` to main. Dispatch the round-1 audit."* → skill fires; lead spawns the parallel primary reviewer subagent + the cross-model reviewer + its completion-watcher; feeds the registries; consolidates MAX-severity.
2. *"Round-1 came back NEEDS-FIX-PASS with 2 Mediums the primary lens missed. Help me consolidate."* → MAX-severity applies; decide direct fix-pass / Path A / Path C.
3. *"Round-2 cleared C/H/M from both lenses but left 3 Lows. Does this lock?"* → triage each Low (waive / backlog / promote); if none promote and no new C/H/M appeared, the gate is met → LOCK. No round-3 for the Lows.
4. *"A reviewer flagged a Medium I think has no reproducible failure scenario."* → written dispute → the other reviewer adjudicates → uphold (fix) or dismiss (`disputed-findings.md`, doesn't block).
