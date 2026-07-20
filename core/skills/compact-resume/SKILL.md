---
name: compact-resume
description: >-
  Picks work up AFTER a compaction: reads the compact-prep checkpoint, re-reads its load-bearing sources IN FULL (the summary is lossy), re-invokes dropped skill bodies, resumes at the pinned point — files beat memory. Use on "pick up", "resume", "we just compacted", "/compact-resume". Not a cold start (session-start).
allowed-tools: Read, Grep, Glob, Bash
---

# Compact resume

You were just compacted. You retain a **lossy summary**: gist and decisions mostly survived;
verbatim detail, exact file state, and precise reasoning did not — and the summary may carry a
subtly-wrong framing as if it were fact.

**The one rule that matters most: files beat your memory.** You were compacted; the files were
not. Where your recollection and a file disagree, the file is authoritative — re-read it, don't
argue with it.

## The pickup, in order

**1. Read the checkpoint — your resume map.** The project's **compaction-checkpoint** file
(written by `compact-prep`), end-to-end; it's short. It gives the arc, the resume point, what to
re-read, what's locked, and in-flight state. (A wired `SessionStart(compact)` hook delivers the
pointer automatically; either way, open the checkpoint.)

**2. RE-READ the "re-read verbatim" list — IN FULL, before acting.** The heart of the skill and
**non-negotiable**. The checkpoint names the load-bearing sources — locked specs (with section
refs), the file(s) you were editing, contracts. **Read them in full now.** Your summary of a spec
is not the spec; building from the summary is exactly the confabulation the re-read prevents.
Chunk if large; read every chunk. Do this BEFORE forming any plan or touching any code.

**3. RE-INVOKE the skills the resume depends on.** Older skill/rule bodies are silently dropped
post-compaction — a skill you invoked before the compaction is not guaranteed to still be in
context. Do NOT act from a summarized memory of a skill's procedure; re-invoke any skill the
resume step needs (the checkpoint should name them) so you're running the real body.

**4. Reconcile with the state snapshot — file wins.** Skim it; confirm it matches your summarized
mental model. **Where they differ, the file is right and your memory is the compaction artifact.**
If the state snapshot and the checkpoint disagree, surface that to the operator (one is stale).

**5. Confirm the locked decisions — don't relitigate.** The checkpoint's LOCKED list = settled
calls from the arc. Post-compact-you may itch to reopen them (the reasoning that settled them got
summarized away). Reopening one requires NEW evidence + an explicit flag to the operator — not
fresh-eyes re-litigation born of lost context.

**6. Note the watch-outs + in-flight state.** Internalize the WATCH-OUTS (framings that go wrong
when summarized). Check IN-FLIGHT: a background job/agent/CI to wait on or check? A branch with
uncommitted work? Known test state?

**7. Resume at the pinned point** — the precise next action the checkpoint named, grounded in the
verbatim re-reads, not the summary.

## The thrashing guard (don't loop the refill)

A **repeated compact → refill → compact cycle** on the same arc without net forward progress means
**stop and escalate**. Repeated compaction on one stuck point usually means the work needs a
decomposition, a decision the operator must make, or a smaller scope. After roughly two or three
refill cycles on the same wall, write up where you're stuck (what's done, what's blocking, the
specific decision or split needed) and surface it. (`autonomous-work` names the same guard for
unattended loops.)

## What to produce

A short confirmation: "Picked up [arc]. Re-read [the load-bearing sources] in full, re-invoked
[skills]. Locked: [1-line]. Resuming at [resume point]." Then continue the work — don't make the
operator re-explain. If a re-read surfaced a CONFLICT with what your summary "remembered", say so
plainly; that's signal the summary drifted, and exactly what this skill exists to catch.

## When to invoke

Right after a compaction on a long-horizon arc: "pick up" / "resume" / "we compacted" /
"/compact-resume" — or you notice your context looks summarized (a checkpoint file exists, more
recent than your apparent context) and you're about to act. Do NOT use for a true fresh session
with zero context (use `session-start`); the tell: fresh session = no conversation summary at all;
compact-resume = you have a summary but lost detail.

## Pairs with
- `compact-prep` — wrote the checkpoint you read here.
- `session-start` — the fresh-session (zero-context) counterpart.
