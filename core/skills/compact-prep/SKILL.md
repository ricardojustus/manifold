---
name: compact-prep
description: >-
  Checkpoint long-horizon work for a SUMMARIZED future-self before context
  compaction — the lighter mid-task counterpart to session-end. Use when the operator
  says "prep for compact" / "checkpoint before compacting" / "/compact-prep" / "I'm
  about to compact" — i.e. work is CONTINUING across a compaction, not ending. Saves
  at-risk state to files, runs the project's doc-freshness checks IF code/runtime
  changed this arc, updates the state snapshot, and writes the checkpoint resume map:
  the exact next action, the load-bearing sources to RE-READ VERBATIM (the summary
  flattens them), the locked decisions not to relitigate, and in-flight
  process/branch/test state. Pairs with compact-resume (the post-compact pickup). NOT
  session-end — you are not closing the session, so skip the full close ceremony
  (lesson writeup, full plan review, cold-stranger kickoff) unless a milestone actually
  closed.
allowed-tools: Read, Write, Edit, Bash
---

# Compact prep

Compaction is **not** session end. After compaction, the next-you retains a **lossy summary**
of this conversation:

- **Survives**: the gist, the decisions, the broad shape of what happened.
- **Lost or flattened**: verbatim spec text, exact file contents, precise line numbers, the
  nuanced reasoning behind a call, the *evidence* you verified.
- **Worse than lost**: the summary can carry a subtly-wrong framing forward as if it were fact
  — and a summary feels like memory, so you trust it.

So this checkpoint is written for a **you-who-half-remembers**, not a cold stranger (that's
session-end's job) and not full-context-you (that's gone). Its four jobs:

1. **Anchor durable state to files** — anything not in a file evaporates at compaction exactly
   as it would at session-end.
2. **Name what to RE-READ VERBATIM** — the load-bearing sources your summary will flatten.
   Acting on a summarized memory of a spec/contract/file is confabulation.
3. **Lock the decisions** — so summarized-you doesn't reopen what's settled.
4. **Pin the exact resume point** — the one next action, precise enough to act on without
   re-deriving.

This is **lighter than session-end** — a checkpoint, not a close. Don't run the full close
ceremony unless a milestone genuinely landed mid-arc.

## The sweep

### 1. Save at-risk state (compaction-proof it)
- **Commit / persist** anything in the working tree that represents completed, coherent work
  (session-end step-1 discipline: explain WHY; follow the standing branch decision). Mid-arc,
  it's fine to leave a genuinely half-finished edit uncommitted — but then it MUST be named in
  the checkpoint's resume point + re-read list.
- **Save mid-task learnings to memory** — anything the operator told you, any decision made,
  any pattern noticed this arc that isn't yet in a file. The memory-write discipline applies
  harder here: the summary won't preserve it faithfully.
- If you leave anything uncommitted on purpose, the checkpoint says so explicitly.

### 2. Doc-freshness checks — IF code/runtime changed this arc (gated)
The project's doc-freshness checks (session-end step 5) are **context-dependent in a way the
re-read list can't rescue**: knowing *which source changed → which docs drifted*, and whether
*a new primitive shipped that needs a doc-index entry*, requires THIS session's full context. A
summarized future-you doesn't know what changed at the source level, so it can't run the check
meaningfully — the undocumented primitive slips through the compaction exactly as it would
through a session boundary. So this is **not** close-out ceremony to defer; it's the same
"handle it while context is intact" rule as the re-read list.

**Gate it** (the whole point of compact-prep is to stay cheaper than session-end):
- **If this arc shipped runtime-significant code OR materially changed a documented subsystem**
  — run the project's doc-freshness checks NOW, with full context; update the changed
  subsystem's reference doc or add a same-session placeholder index entry (via
  `reference-doc-writing`); commit the doc/index changes alongside the code.
- **If this arc was design / spec / research only (no source change)** — SKIP it: the checks
  are a no-op. Don't pay session-end's cost when nothing runtime changed.

What stays deferred even when code shipped: writing a brand-new reference doc for a subsystem
that merely *stabilized* this arc (record it as a placeholder entry now; author it post-compact).

### 3. State snapshot update
Same as session-end step 2 — update the "last updated" line + a tight paragraph on what landed
this arc. The state snapshot is the durable record; it must be true even if the checkpoint and
the summary both vanished.

### 4. Write the checkpoint
Overwrite the project's **compaction-checkpoint** file (stable filename — `compact-resume`
reads exactly this; it is NOT the fresh-session kickoff). Structure:

```markdown
# COMPACT CHECKPOINT — <date/time>

**Arc**: <one line: the long-horizon thread in flight>
**Compacted at**: <approx point — what you'd just finished / were about to do>

## RESUME POINT (do this first, after the re-reads)
<the ONE next action, precise: file:line, the command, the exact half-finished edit,
the test to run. No vagueness.>

## RE-READ VERBATIM BEFORE ACTING (your summary flattened these)
- <path + the EXACT sections> — why it's load-bearing + what the summary loses
- <the file(s) you were mid-editing> — read current state; don't trust remembered contents
- <locked spec/contract> — full section refs; acting on a summarized spec = confabulation

## LOCKED — do NOT relitigate
- <settled decision + one-line why> — summarized-you might reopen this; don't.

## WATCH-OUTS (framings that go subtly wrong when summarized)
- <known trap / a claim that's only true with a caveat the summary will drop>

## IN-FLIGHT
- Branch: <repo @ branch>, uncommitted: <what + why>
- Background: <agents/jobs/CI running; how you'll be re-notified>
- Tests: <last known state>; Runtime: <running? which commit?>
```

Keep it dense and specific. The test of a good checkpoint: post-compact-you reads it + the
re-read list and resumes WITHOUT asking the operator to re-explain anything.

### 5. Log line (optional)
If the arc hit a notable point, append one line to the task-audit log: `<ts> — compact
checkpoint. Arc: <x>. Resume: <y>.`

## Compaction hardening (know these before you rely on the checkpoint)

- **Older skill/rule bodies are silently dropped post-compaction.** The re-attachment budget is
  finite; a skill you invoked earlier this arc is NOT guaranteed to still be in context after
  the compaction. `compact-resume` must **re-invoke** the skills it needs — don't assume they
  survived. Note in the checkpoint any skill the resume step depends on.
- **The overlay MAY wire a `SessionStart(compact)` hook** that re-injects the checkpoint pointer
  automatically on the post-compaction turn, so resuming doesn't depend on the model remembering
  to. If the project binding provides it, the checkpoint pointer arrives deterministically; if
  not, the operator triggers `compact-resume` manually. Either way the checkpoint file is the
  source of truth.

## What to SKIP (vs session-end)
Unless a milestone actually closed this arc, SKIP: a *full* plan/architecture-doc review (the
broad staleness pass over docs you did NOT touch — distinct from step 2's targeted update),
lesson writeup, the cold-stranger kickoff rewrite, the full memory-type sweep. Those are
close-out ceremony. A compaction is a breath mid-run — keep it cheap so the operator can compact
often on long work. (Step 2's doc-freshness check is NOT in this skip-list when code shipped.)

## Final message to the operator
Short: "Checkpoint saved. After compaction, tell me to **pick up** (or `/compact-resume`) —
I'll read the checkpoint, re-read [the load-bearing sources] in full, and resume at [resume
point]." Name anything only THEY can act on.

## When to invoke
- The operator says "prep for compact" / "checkpoint before I compact" / "/compact-prep".
- You sense compaction is near on a long-horizon arc and want to checkpoint proactively.

Do NOT use when the work is actually ENDING (use `session-end`) or mid-task with no compaction
imminent.

## Pairs with
- `compact-resume` — reads the checkpoint; re-hydrates the verbatim-lossy sources; resumes.
- `session-end` — the heavier close (fresh-session next, zero context). Use when work is DONE.
- `session-start` — fresh-session pickup. `compact-resume` is its compaction-aware sibling.
