---
name: brief-authoring
description: >-
  MANDATORY before authoring ANY brief for a dispatched agent — every subagent, teammate, parallel-lane, or ad-hoc implementer dispatch. INVOKE THE MOMENT you start writing the brief, BEFORE you paste it. Four non-negotiable obligations: (1) lead with a GIVEN block — system state, locked-spec refs by path+version, the current-state docs of any live subsystem touched, tools, explicit out-of-scope, conventions; (2) grep-verify EVERY concrete code reference against current code first — LOCK status does NOT confer code-truth, only fresh grep does; (3) state the ambiguity protocol — the receiving agent surfaces contradiction-or-silence, never silently scopes out; (4) state verifiable success criteria + the handoff/status vocabulary. Skipping it wasted whole lanes on invented infrastructure. NOT for audit-reviewer briefs (templated in `audit-cycle`) or your own research discipline (the constitution owns that); to author the spec itself use `spec-writing`; for lane dispatch mechanics use `parallel-workstreams`.
---

# Brief-Authoring Discipline — GIVEN Context Up Front

Applies to every brief authored for a teammate / subagent / implementer dispatch — including ad-hoc spawns without a LOCKED spec to point at.

## The core obligation

When authoring a brief for any dispatched agent, lead with explicit **GIVEN context** BEFORE stating the task. Don't make the receiving agent infer ambient context from a conversation it didn't have.

### Required GIVEN block

- **Current system state** — what's running, what's locked, what's pending, what was just decided.
- **Locked references (intent docs)** — paths + version tags of any LOCKED spec / contract / plan the brief depends on (the brief points; it does not re-derive).
- **Runtime reference docs (current-state docs)** — for any brief that touches a live subsystem, include ALL relevant **current-state reference docs** for that subsystem. Find them through the project's documentation-retrieval system / current-state reference corpus. **Spec/plan/research tells what the system WILL BE; the current-state docs tell what it IS RIGHT NOW.** Briefs that skip the runtime references force the lane to *discover* live-system shape via audit cycles — re-derivation cost that a maintained reference corpus exists to eliminate. *(Receipt: a 3-lane dispatch bundled the full spec corpus but omitted the one current-state doc for a still-live legacy subsystem the change would touch; one lane's audit had to discover at round 8 that its new code interacted with that live path — an interaction that would have been front-loaded into the spec had the brief carried the reference doc.)*
- **Tools available** — what tools the agent will have, what's out-of-scope by tool roster.
- **Out-of-scope explicitly** — what NOT to touch / extend / refactor.
- **Conventions** — paths to convention docs (pitfall catalogs, project conventions) the work must honor.

**When the project has steering documents, cite them — don't re-derive.** If the project maintains the three steering docs (`product.md` / `tech.md` / `structure.md`, from `.claude/harness-templates/steering/`), the GIVEN block **points at them** for the stable project context (what the project is + for whom, the stack + conventions + non-negotiables, where things live + go) rather than restating that context per dispatch. Steering docs are the persistent, once-per-project source; the GIVEN block still adds the *per-task* specifics (which spec, which files, what's out of scope for THIS task) on top. Re-deriving standing project context in every brief is exactly the waste the steering docs exist to remove — but a citation only helps if the docs are filled, so a brief that relies on them assumes a project that filled them at init.

### Required: Codebase-verified concrete claims

Every concrete code reference in the brief MUST be grep-verified against actual current code BEFORE the brief is dispatched. The Cardinal Rule (hypothesize → research → present → implement) applies to brief authoring, not only code authoring.

A **concrete claim** in a brief is any of:
- File path (`src/foo/bar.ts`, `<docs>/…/baz.md`)
- Directory existence (`src/<module>/migrations/`)
- Function / class / symbol name (`applyMigrations`, `classifyEntry`, `SomeResultType`)
- Line-number citation (`handler.ts:209`, `schema.ts:77-84`)
- Schema column / enum value (a column name, a `state='pending'` enum value)
- Pattern reference ("read the prior 5 migrations" / "follow the existing X pattern")
- Cross-reference to a sibling spec or doc (`some-sibling-spec-draft.md`)
- Line-count claim (`schema.ts (322 lines)`)
- Module-convention claim ("the telemetry module for observability")

For EACH such claim, before pasting into the brief, run the probe:

- File path / directory → `ls <path>` or `test -f <path>`
- Function / symbol → `grep -n "function <name>\|export function <name>\|class <name>" <file>`
- Line number → `sed -n '<N>p' <file>` (or Read with offset/limit); confirm content matches
- Schema field → grep the schema source
- Pattern reference → confirm the pattern actually exists in code; if it doesn't, you've invented a convention
- Cross-reference → `ls <sibling-spec-path>` (specs get renamed; verify the current filename)
- Line count → `wc -l <file>`

**If you cannot verify a claim, do one of three things — never the fourth:**

1. **Don't make the claim** — describe shape generically ("append a migration following existing precedent — the implementer reads the migration module to confirm shape") without inventing specifics.
2. **Mark it `[unverified]`** — explicit signal that downstream consumers must verify before acting.
3. **Surface as `DECISION-PENDING-<owner>`** — the claim depends on a choice not yet made; flag for the owner.

❌ **Never**: paste a plausible-sounding claim "as if" it were verified. The implementer will hit it on first `ls` and waste the lane.

### Required TASK + protocol

- **TASK** — the specific work, with file paths where they exist.
- **Ambiguity protocol** — if anything in the brief contradicts a referenced spec, OR if a spec is silent on something the task needs: for **in-conversation dispatches** (teammates, subagents within the session), send a message to the controller IMMEDIATELY; for **lane-style dispatches** (parallel lanes with no inter-process mailbox), tag `DECISION-PENDING-<owner>` inline in the deliverable + continue. Do NOT silently scope-out or invent. The receiving agent's job is to surface ambiguity, not resolve it unilaterally.
- **Success criteria** — verifiable end state (tests pass / spec §N satisfied / audit gate met).

### The handoff triad + status vocabulary (dispatch as a contract, not a conversation)

A dispatch is a contract between a controller and an agent. Pass the three artifacts **as file PATHS, not pasted text** — paths are re-readable, versionable, and don't bloat the dispatch turn:

- **brief.md** — the GIVEN + TASK + criteria above (what the controller hands down).
- **report.md** — what the agent hands back on completion (findings, what it did, evidence).
- **diff-package** — the concrete change the agent produced (a patch, a branch, a set of files), referenced by path/branch, never pasted inline.

The canonical templates for these live in `.claude/harness-templates/`; point the brief at them rather than restating their shape.

The agent closes with **exactly one** of a **closed status vocabulary**, and each has a defined controller response — so completion is unambiguous and the controller always knows its next move:

| Status | Meaning | Controller response |
|---|---|---|
| **DONE** | Task complete, success criteria met, no reservations. | Verify the criteria against the report/diff, then proceed / merge. |
| **DONE_WITH_CONCERNS** | Complete, but the agent flags risks/caveats it couldn't resolve in-scope. | Read each concern; disposition it (fix now / backlog with a trigger / accept) BEFORE proceeding. Never merge past unread concerns. |
| **NEEDS_CONTEXT** | Blocked on missing information the brief should have carried. | Supply the missing context (or the source), agent resumes. A NEEDS_CONTEXT is a **brief-quality signal** — the GIVEN block was incomplete; fix the brief, not just this instance. |
| **BLOCKED** | Cannot proceed — a dependency, a decision, or a broken precondition stands in the way. | Resolve the blocker (dependency, decision, precondition) or re-scope. Work does not proceed until cleared; don't tell the agent to "try anyway." |

An open-ended "how did it go?" invites a narrative the controller has to interpret; a closed status + a defined response makes the handoff mechanical.

### Required: Confidence gate (lane briefs that read a substantial corpus before starting)

For briefs where the lane reads multiple docs before starting work (parallel lanes; ad-hoc dispatches with large pre-flight read lists): include a **Confidence gate** section that instructs the lane to halt-and-report AFTER pre-flight reads + BEFORE drafting anything:

> **Confidence gate (HALT-AND-REPORT before starting work)**
>
> After completing pre-flight reads + BEFORE drafting anything: print to terminal:
>
> `Confidence: <0-100%> in assignment understanding.`
>
> If <100%, list:
> - **Clarifications needed** (if any) — specific questions the owner should answer before you start
> - **Divergent ideas** (if any) — be opinionated; name what YOU think + why it differs from the brief
>
> If 100%, print "Confidence: 100% — proceeding" and continue.
>
> If <100%, HALT + wait for the owner to type clarification in this terminal window. Do NOT proceed with assumptions — cost of waiting for clarification < cost of building the wrong thing.

This is distinct from the `DECISION-PENDING-<owner>` inline pattern (which fires *during* work + continues). The confidence gate fires ONCE, AFTER reads, BEFORE work. Its canonical text lives in the dispatch brief template in `.claude/harness-templates/` — point the brief at the template if you're not customizing.

## Why this is a hard rule

An A/B test made the shape concrete: given the same thin brief, one implementer silently scoped out spec requirements (a broad `catch { return [] }`, a missing structural element, a wrong result shape) while the other hit the same gaps but surfaced them as questions instead of guessing. **The brief is the ambient-context contract.** Thin brief → implementer fills gaps silently. The GIVEN block converts inferred context into referable context; the ambiguity protocol converts silent scope-out into a surfaced question.

## Pre-flight checklist (before dispatching any teammate/subagent)

1. Does the brief have a GIVEN block at the top (state, locked refs, current-state docs, tools, out-of-scope, conventions)?
2. Does the brief name the locked spec by path + LOCK version?
3. Does the brief state the ambiguity protocol — "surface on contradiction or silence"?
4. Does the brief state success criteria in verifiable terms, and name the handoff triad + status vocabulary?
5. **Worktree isolation — not parallel-only.** If parallel implementers: did the worktree pre-flight run? AND if the brief's work dir is a **live-daemon / production repo** (a running bridge, a cron-booted checkout), does the brief mandate a **linked worktree** and **forbid `git switch`/`checkout` in the live path** — *regardless of lane count*? A single lane told to "work in `<live repo>` on branch X" will move the LIVE checkout onto an unmerged branch, and the daemon boots that branch at its next scheduled fire.
5½. If an Agent-tool implementation dispatch: is it using the **`implementer` role**
   (`subagent_type: "implementer"`)? The role file carries the standing conventions
   (ambiguity protocol, pwd+branch re-verify, verify-before-done, handoff shape) so the
   brief carries only the GIVEN block + contract — do not re-paste conventions the role
   already enforces. The triage's model goes on the call as the per-invocation `model`
   parameter.
6. **Was every concrete code reference in the brief grep-verified against actual current code?** Includes claims propagated from upstream specs — spec ratification does NOT confer code-truth. Verify at brief-write time, not at impl time.

If any answer is no, the brief is not ready to dispatch.

## NOT in scope

- **Audit-reviewer briefs** — templated in `audit-cycle`'s reviewer-prompt-template. This skill governs implementer briefs + ad-hoc dispatches without a templated locus.
- **Self-discipline** (the Cardinal Rule's "research FIRST") — the constitution owns that. This skill governs briefs you WRITE, not your own behavior.

## Receipts

- **The A/B silent-scope-out** (above): on the same thin brief, one arm scoped out silently, the other surfaced the ambiguity. The brief is the ambient-context contract.
- **The spec-confab incident**: an overnight worker authored spec drafts with confabulated code references (a `migrations/` directory that didn't exist; a wrongly-named module; an event enum value that was different in the actual code; cross-refs to a spec that had since been renamed). Those confabs were then propagated into impl-lane briefs WITHOUT re-grepping. The impl lane caught the first confab on `ls migrations/`. Cumulative cost: 3 impl lanes stopped + spec-audit and spec-fix dispatches to clean up. Lesson: **spec ratification + LOCK status do NOT confer code-truth; only fresh grep does**. Brief authors who skip the grep are the LAST safety gate before impl wastes tokens on invented infrastructure.
- **The runtime-reference-docs gap** (above, GIVEN block): a lane discovered a live-subsystem interaction at round 8 that a current-state reference doc in the GIVEN block would have front-loaded.
- **The live-checkout move**: a brief said "work in `<live-daemon repo>` on branch X"; the lane read it literally and switched the running daemon's checkout onto an unmerged branch — the next scheduled cron fire would have booted it. Worktree isolation is a **single-lane** requirement for live-daemon repos too, not just a parallel-writer race guard.
