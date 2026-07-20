---
name: compact-prep
description: >-
  Writes the pre-compaction checkpoint for a summarized future-self: the exact resume point, sources to RE-READ VERBATIM, locked decisions, in-flight state. Use on "prep for compact", "I'm about to compact", "/compact-prep" — when work CONTINUES across compaction, not when it ends (session-end).
allowed-tools: Read, Write, Edit, Bash
---

# Compact prep

Compaction is **not** session end. After it the next-you retains a **lossy summary**: gist and
decisions survive; verbatim spec text, exact file contents, line numbers, nuanced reasoning, and
the evidence you verified are lost or flattened — and worse, the summary can carry a subtly-wrong
framing forward as if it were fact, because a summary feels like memory.

So the checkpoint is written for a **you-who-half-remembers** — not a cold stranger (session-end's
job), not full-context-you (gone). Four jobs: **anchor durable state to files** (anything not in a
file evaporates); **name what to RE-READ VERBATIM** (acting on a summarized memory of a
spec/contract/file is confabulation); **lock the decisions** so summarized-you doesn't reopen what's
settled; **pin the exact resume point**. Keep it lighter than session-end — no full close ceremony
unless a milestone genuinely landed mid-arc.

## The sweep

### 1. Save at-risk state (compaction-proof it)
- **Commit / persist** anything in the working tree representing completed, coherent work
  (session-end step-1 discipline: explain WHY; follow the standing branch decision). A genuinely
  half-finished edit may stay uncommitted mid-arc — but then it MUST be named in the checkpoint's
  resume point + re-read list.
- **Save mid-task learnings to memory** — anything the operator told you, any decision made, any
  pattern noticed this arc that isn't yet in a file. The summary won't preserve it faithfully.
- If you leave anything uncommitted on purpose, the checkpoint says so explicitly.

### 2. Doc-freshness — IF code/runtime changed this arc (gated)
The DOC UPDATE needs THIS session's full context: which source changed → which docs drifted, and
whether a new primitive shipped that needs an index entry. A summarized future-you can't do that
faithfully — handle it while context is intact.

- **Arc shipped runtime-significant code OR materially changed a documented subsystem** → consult
  the project's doc-freshness mechanism (the binding names it — scripts to run, or a scheduled
  job's flags file to read), then update the changed subsystem's reference doc or add a
  same-session placeholder index entry (via `reference-doc-writing`); commit the doc/index changes
  alongside the code.
- **Arc was design / spec / research only (no source change)** → SKIP; the checks are a no-op.

Still deferred even when code shipped: authoring a brand-new reference doc for a subsystem that
merely *stabilized* this arc (record a placeholder entry now; write it post-compact).

### 3. State snapshot update
Same as session-end step 2 — update the "last updated" line + a tight paragraph on what landed
this arc. The state snapshot is the durable record; it must be true even if the checkpoint and the
summary both vanished.

### 4. Write the checkpoint
Overwrite the project's **compaction-checkpoint** file (stable filename — `compact-resume` reads
exactly this; NOT the fresh-session kickoff). Structure:

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

Dense and specific. The test of a good checkpoint: post-compact-you reads it + the re-read list and
resumes WITHOUT asking the operator to re-explain anything.

### 5. Log line (optional)
If the arc hit a notable point: `<ts> — compact checkpoint. Arc: <x>. Resume: <y>.` in the
task-audit log.

## Compaction hardening
- **Older skill/rule bodies are silently dropped post-compaction** (the re-attachment budget is
  finite). `compact-resume` must **re-invoke** the skills it needs — note in the checkpoint any
  skill the resume step depends on.
- **The overlay MAY wire a `SessionStart(compact)` hook** re-injecting the checkpoint pointer on
  the post-compaction turn. If the binding provides it, the pointer arrives deterministically; if
  not, the operator triggers `compact-resume` manually. Either way the checkpoint file is the
  source of truth.

## What to SKIP (vs session-end)
Unless a milestone actually closed this arc: a *full* plan/architecture-doc review (the broad
staleness pass over docs you did NOT touch — distinct from step 2's targeted update), lesson
writeup, the cold-stranger kickoff rewrite, the full memory-type sweep. A compaction is a breath
mid-run — keep it cheap so the operator can compact often. (Step 2's doc-freshness check is NOT in
this skip-list when code shipped.)

## Final message to the operator
Short: "Checkpoint saved. After compaction, tell me to **pick up** (or `/compact-resume`) — I'll
read the checkpoint, re-read [the load-bearing sources] in full, and resume at [resume point]."
Name anything only THEY can act on.

## When to invoke
"prep for compact" / "checkpoint before I compact" / "/compact-prep", or you sense compaction is
near on a long-horizon arc and want to checkpoint proactively. Do NOT use when the work is
actually ENDING (use `session-end`) or mid-task with no compaction imminent.

## Pairs with
- `compact-resume` — reads the checkpoint; re-hydrates the verbatim-lossy sources; resumes.
- `session-end` — the heavier close (fresh session next, zero context). Use when work is DONE.
- `session-start` — fresh-session pickup; `compact-resume` is its compaction-aware sibling.
