---
name: compact-resume
description: >-
  Pick up long-horizon work AFTER a context compaction — the compaction-aware sibling
  of session-start. Use when the operator says "pick up" / "get back on track" / "we
  just compacted" / "resume" / "/compact-resume" right after a compaction (NOT a fresh
  session). Reads the checkpoint written by compact-prep, RE-READS the load-bearing
  sources it names IN FULL (your post-compact summary of them is lossy — acting on it is
  confabulation), RE-INVOKES the skills it needs (older skill bodies are silently
  dropped post-compaction), confirms the locked decisions, reconciles your summary
  against the state snapshot (file wins on any conflict), then resumes at the pinned
  point. Lighter than session-start because the gist survived — stricter on one rule:
  trust files over your own summarized memory. NOT a fresh cold start (use session-start
  — you have no summary at all there). Pairs with compact-prep.
allowed-tools: Read, Grep, Glob, Bash
---

# Compact resume

You were just compacted. You retain a **lossy summary** of the work arc — gist and decisions
mostly survived; verbatim detail, exact file state, and precise reasoning did not, and the
summary may carry a subtly-wrong framing as if it were fact. This skill re-grounds you fast,
without the full cold-start of `session-start`.

**The one rule that matters most: files beat your memory.** You were compacted; the files were
not. Where your summarized recollection and a file disagree, the file is authoritative —
re-read it, don't argue with it.

## The pickup, in order

### 1. Read the checkpoint — your resume map
Read the project's **compaction-checkpoint** file (written by `compact-prep`). End-to-end, it's
short. It tells you the arc, the resume point, what to re-read, what's locked, and in-flight
state. (If the overlay wired a `SessionStart(compact)` hook, its pointer arrives automatically;
if not, you're here because the operator triggered the pickup — either way, open the checkpoint.)

### 2. RE-READ the "re-read verbatim" list — IN FULL, before acting
This is the heart of the skill and **non-negotiable**. The checkpoint names the load-bearing
sources — locked specs (with section refs), the file(s) you were editing, contracts. **Read
them in full now.** Your summary of a spec is not the spec; building from the summary is exactly
the confabulation the re-read prevents. Chunk if large; read every chunk. Do this BEFORE forming
any plan or touching any code.

### 3. RE-INVOKE the skills the resume depends on
**Older skill/rule bodies are silently dropped post-compaction** — the re-attachment budget is
finite, and a skill you invoked before the compaction is not guaranteed to still be in context.
Do NOT act from a summarized memory of a skill's procedure. Re-invoke any skill the resume step
needs (the checkpoint should name them) so you're running the real body, not your recollection
of it. This is the same "the summary is lossy" rule applied to skills, not just documents.

### 4. Reconcile with the state snapshot — file wins
Skim the state snapshot. Confirm it matches your summarized mental model. **Where they differ,
the file is right and your memory is the compaction artifact** — update your model to the file.
If the state snapshot and the checkpoint disagree, that's a flag worth surfacing to the operator
(one of them is stale).

### 5. Confirm the locked decisions — don't relitigate
The checkpoint's LOCKED list = settled calls from the arc. Post-compact-you may feel an itch to
reopen them (the reasoning that settled them got summarized away). Don't. If you genuinely think
a locked decision is wrong, that requires NEW evidence + an explicit flag to the operator — not
a fresh-eyes re-litigation born of lost context.

### 6. Note the watch-outs + in-flight state
Internalize the WATCH-OUTS (framings that go wrong when summarized). Check IN-FLIGHT: a
background job/agent/CI to wait on or check? A branch with uncommitted work? Known test state?

### 7. Resume at the pinned point
Now act — on the precise next action the checkpoint named, grounded in the verbatim re-reads,
not the summary.

## The thrashing guard (don't loop the refill)

If you find yourself in a **repeated compact → refill → compact cycle** — the same arc being
checkpointed and resumed several times without net forward progress — **stop and escalate**,
don't keep looping. Repeated compaction on one stuck point usually means the work needs a
decomposition, a decision the operator must make, or a smaller scope — not another refill. After
roughly two or three refill cycles on the same wall, write up where you're stuck (what's done,
what's blocking, the specific decision or split needed) and surface it, rather than burning
another cycle. (Cross-ref: `autonomous-work` names the same guard for unattended loops.)

## What to produce

A short confirmation: "Picked up [arc]. Re-read [the load-bearing sources] in full, re-invoked
[skills]. Locked: [1-line]. Resuming at [resume point]." Then continue the work. Don't make the
operator re-explain — the checkpoint + re-reads are your re-grounding.

If a re-read surfaced a CONFLICT with what your summary "remembered," say so plainly — that's
signal the summary drifted, and it's exactly what this skill exists to catch.

## When to invoke
- Right after a compaction on a long-horizon arc: "pick up" / "resume" / "we compacted" /
  "/compact-resume".
- You notice your context looks summarized (a checkpoint file exists, more recent than your
  apparent context) and you're about to act — re-ground first.

Do NOT use for a true fresh session with zero context (use `session-start`). The tell: fresh
session = no conversation summary at all; compact-resume = you have a summary but lost detail.

## Why this exists
The failure mode this prevents: post-compaction, you "remember" the spec/file/decision from the
summary, skip re-reading the source, and build on a flattened or subtly-wrong recollection —
confidently. The summary is a map, not the territory; this skill sends you back to the territory
before you act.

## Pairs with
- `compact-prep` — wrote the checkpoint you read here.
- `session-start` — the fresh-session (zero-context) counterpart.
