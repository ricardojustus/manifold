---
name: brief-authoring
description: >-
  Authors the brief for any dispatched agent — subagent, teammate, parallel lane, or implementer. Requires a GIVEN block, grep-verified code references, an ambiguity protocol, and verifiable success criteria. Invoke before writing it. Not the spec itself (spec-writing) or lane mechanics (parallel-workstreams).
---

# Brief-Authoring Discipline — GIVEN Context Up Front

Applies to every brief authored for a teammate / subagent / implementer dispatch — including
ad-hoc spawns without a LOCKED spec to point at. Lead with explicit **GIVEN context** BEFORE the
task: the brief is the ambient-context contract, and a thin brief makes the receiving agent fill
gaps silently.

## Required GIVEN block

- **Current system state** — what's running, what's locked, what's pending, what was just decided.
- **Locked references (intent docs)** — paths + version tags of any LOCKED spec / contract / plan
  the brief depends on (the brief points; it does not re-derive).
- **Runtime reference docs (current-state docs)** — for any brief touching a live subsystem,
  include ALL relevant **current-state reference docs** for it, found through the project's
  documentation-retrieval system. **Spec/plan/research tells what the system WILL BE; the
  current-state docs tell what it IS RIGHT NOW.** Omitting them forces the lane to *discover* live
  shape via audit cycles.
- **Tools available** — what tools the agent will have, what's out-of-scope by tool roster.
- **Out-of-scope explicitly** — what NOT to touch / extend / refactor.
- **Conventions** — paths to convention docs (pitfall catalogs, project conventions) the work must
  honor.

**When the project has steering documents, cite them — don't re-derive.** If the project maintains
`product.md` / `tech.md` / `structure.md` (from `.claude/harness-templates/steering/`), the GIVEN
block **points at them** for stable project context rather than restating it per dispatch; the
block still adds the *per-task* specifics (which spec, which files, what's out of scope for THIS
task) on top. A citation only helps if the docs are filled.

## Required: codebase-verified concrete claims

Every concrete code reference MUST be grep-verified against actual current code BEFORE dispatch.
**Spec ratification + LOCK status do NOT confer code-truth; only fresh grep does.** The Cardinal
Rule applies to brief authoring, not only code authoring.

A **concrete claim** is any of: file path · directory existence · function/class/symbol name ·
line-number citation · schema column or enum value · pattern reference ("follow the existing X
pattern") · cross-reference to a sibling spec/doc · line-count claim · module-convention claim.

Probes, before pasting:

- File path / directory → `ls <path>` or `test -f <path>`
- Function / symbol → `grep -n "function <name>\|export function <name>\|class <name>" <file>`
- Line number → `sed -n '<N>p' <file>` (or Read with offset/limit); confirm content matches
- Schema field → grep the schema source
- Pattern reference → confirm the pattern exists in code; if it doesn't, you've invented a convention
- Cross-reference → `ls <sibling-spec-path>` (specs get renamed; verify the current filename)
- Line count → `wc -l <file>`

**If you cannot verify a claim, do one of three things — never the fourth:**

1. **Don't make the claim** — describe shape generically ("append a migration following existing
   precedent — the implementer reads the migration module to confirm shape").
2. **Mark it `[unverified]`** — explicit signal that downstream consumers must verify before acting.
3. **Surface as `DECISION-PENDING-<owner>`** — the claim depends on a choice not yet made.

❌ **Never**: paste a plausible-sounding claim "as if" it were verified.

## Required TASK + protocol

- **TASK** — the specific work, with file paths where they exist.
- **Ambiguity protocol** — if anything in the brief contradicts a referenced spec, OR a spec is
  silent on something the task needs: for **in-conversation dispatches** (teammates, subagents
  within the session), message the controller IMMEDIATELY; for **lane-style dispatches** (parallel
  lanes with no inter-process mailbox), tag `DECISION-PENDING-<owner>` inline in the deliverable +
  continue. Do NOT silently scope-out or invent. The receiving agent surfaces ambiguity, it does
  not resolve it unilaterally.
- **Success criteria** — verifiable end state (tests pass / spec §N satisfied / audit gate met).

## The handoff triad + status vocabulary

A dispatch is a contract. Pass the three artifacts **as file PATHS, not pasted text**:

- **brief.md** — the GIVEN + TASK + criteria (what the controller hands down).
- **report.md** — what the agent hands back (findings, what it did, evidence).
- **diff-package** — the concrete change (patch / branch / file set), referenced by path or branch.

Canonical templates live in `.claude/harness-templates/`; point the brief at them.

The agent closes with **exactly one** status from this closed vocabulary:

| Status | Meaning | Controller response |
|---|---|---|
| **DONE** | Task complete, success criteria met, no reservations. | Verify the criteria against the report/diff, then proceed / merge. |
| **DONE_WITH_CONCERNS** | Complete, but the agent flags risks/caveats it couldn't resolve in-scope. | Read each concern; disposition it (fix now / backlog with a trigger / accept) BEFORE proceeding. Never merge past unread concerns. |
| **NEEDS_CONTEXT** | Blocked on missing information the brief should have carried. | Supply the missing context (or the source), agent resumes. A NEEDS_CONTEXT is a **brief-quality signal** — fix the brief, not just this instance. |
| **BLOCKED** | Cannot proceed — a dependency, a decision, or a broken precondition. | Resolve the blocker or re-scope. Work does not proceed until cleared; don't tell the agent to "try anyway." |

## Required: confidence gate (briefs with a substantial pre-flight read list)

For briefs where the lane reads multiple docs before starting (parallel lanes; ad-hoc dispatches
with large pre-flight read lists): include a **Confidence gate** instructing the lane to
halt-and-report AFTER pre-flight reads + BEFORE drafting anything — print
`Confidence: <0-100%>`; if <100% list clarifications needed + divergent ideas and HALT for the
owner; if 100% print "proceeding" and continue. Canonical paste text:
`references/confidence-gate.md` (also in the harness templates). Fires ONCE, before work — unlike
the `DECISION-PENDING-<owner>` inline marker, which fires during work and continues.

## Pre-flight checklist (before dispatching any teammate/subagent)

1. Does the brief have a GIVEN block at the top (state, locked refs, current-state docs, tools,
   out-of-scope, conventions)?
2. Does the brief name the locked spec by path + LOCK version?
3. Does the brief state the ambiguity protocol — "surface on contradiction or silence"?
4. Does the brief state success criteria in verifiable terms, and name the handoff triad + status
   vocabulary?
5. **Worktree isolation — not parallel-only.** If parallel implementers: did the worktree
   pre-flight run? AND if the brief's work dir is a **live-daemon / production repo** (a running
   bridge, a cron-booted checkout), does the brief mandate a **linked worktree** and **forbid
   `git switch`/`checkout` in the live path** — *regardless of lane count*? A single lane told to
   "work in `<live repo>` on branch X" will move the LIVE checkout onto an unmerged branch, and the
   daemon boots that branch at its next scheduled fire.
5½. If an Agent-tool implementation dispatch: is it using the **`implementer` role**
   (`subagent_type: "implementer"`)? The role file carries the standing conventions (ambiguity
   protocol, pwd+branch re-verify, verify-before-done, handoff shape) so the brief carries only the
   GIVEN block + contract. The triage's model goes on the call as the per-invocation `model`
   parameter.
6. **Was every concrete code reference grep-verified against actual current code?** Includes claims
   propagated from upstream specs. Verify at brief-write time, not at impl time.

If any answer is no, the brief is not ready to dispatch.

## NOT in scope

- **Audit-reviewer briefs** — templated in `audit-cycle`'s reviewer-prompt-template. This skill
  governs implementer briefs + ad-hoc dispatches without a templated locus.
- **Self-discipline** (the Cardinal Rule's "research FIRST") — the constitution owns that. This
  skill governs briefs you WRITE, not your own behavior.
