---
name: autonomous-work
description: >-
  Run an unattended, loop-until-done work session with the hygiene that lets the
  operator hand off and walk away. Use whenever they go async on a multi-step run —
  "I'm going to bed, keep going", "/loop until done", "run autonomously", "overnight
  pass", or any handoff where they won't watch turn-by-turn. Owns the three
  thread-local hygiene files (JOURNAL / DECISIONS / QUESTIONS), the loop-until-done +
  hard-STOP-boundary discipline (destructive / irreversible / live-prod / owner-gated
  actions halt and park; reversible in-scope work proceeds), the fallback heartbeat
  that survives a dead watcher or a usage-limit stall, background-watcher job-loss
  handling, commit-as-you-go, and the morning presentation. Invoke the MOMENT a
  handoff starts so the files exist from turn one. NOT the full session close (use
  session-end when the run wraps) and NOT a mid-run compaction checkpoint (use
  compact-prep). Works for ANY unattended context — a thread, a phase, a lane.
---

# Autonomous work — running unattended without dropping the thread

When the operator hands off and leaves, two things fail silently unless you engineer against
them: **the loop stalls** (a dead dependency, a usage-limit pause, an ambiguous decision) and
**the record evaporates** (they return unable to reconstruct what happened, what you chose, and
what still needs their call). This skill is the harness that prevents both. Invoke it at the
*start* of a handoff so the discipline is in place before the first autonomous action —
retrofitting a journal after six hours means reconstructing from memory, which is exactly the
confabulation risk the record exists to kill.

The mental model: you are standing in for the operator on everything reversible and in-scope,
and leaving them a clean desk for everything that's genuinely their call. The three files ARE
the clean desk.

## The three thread-local files (the non-negotiable core)

Keep three files, continuously, in the **owning thread's own folder** — never a shared/root
location. Parallel threads each keep their own set so two autonomous runs never write the same
file (the collision that corrupts a hand-off). The rule is *local to this run*, discoverable,
and yours alone. (The project binding names the run-local convention — a thread folder, a task
workspace dir — for where these live.)

| File | Holds | Cadence |
|---|---|---|
| **JOURNAL** | What you DID — append-only narrative. Each entry: timestamp, what happened, the load-bearing outcome, commit SHAs. The compaction-survival surface: a summarized future-you rebuilds the run from here. | Append at every meaningful step + before any wakeup/idle. |
| **DECISIONS** | What you DECIDED autonomously — numbered, timestamped: the decision, the rationale, and its **reversibility** (so the operator knows the cost of overriding it). "I picked X because Y, cost to undo is Z." | One entry per autonomous call worth a sentence. Batch trivial ones. |
| **QUESTIONS** | What NEEDS THEM — parked decisions, ambiguities you refused to guess on, things owed. Each: the question in plain terms (names + context, no bare jargon — they can't answer a codename), your lean, why it's parked not decided. | The moment you hit a STOP boundary or an unanswerable fork. |

Write to these **silently and continuously** — they're the record, not a performance. Don't
narrate "I updated the journal." The test: if the operator read only these three files cold,
could they reconstruct the run, understand every choice, and know exactly what's waiting on
them? If not, they're too thin.

## Loop-until-done — and the STOP boundaries

The value of an autonomous loop is that reversible, in-scope work doesn't wait for a human. So
**proceed** on: anything that follows from the original mandate, anything version control can
roll back, anything inside the authorized scope, retrying after a transient error, gathering
missing information yourself. Don't stop to ask permission for work you were already told to do.

**HALT and park a QUESTION** — never guess — when the next action is:
- **Destructive or irreversible** — a delete/overwrite of something you didn't create, a
  history rewrite, a force-push, a data migration with no clean undo.
- **Live-production-touching** — anything that changes the running system the operator depends
  on (the live service, prod credentials, shared state other agents/people rely on). The moment
  the blast radius leaves your sandbox, stop.
- **Explicitly owner-gated** — a decision they reserved ("we do X together", "check with me
  before Y"). Their word is the contract; a reserved decision stays reserved even if the loop is
  ready for it.
- **A genuine scope change** — the work has drifted into something they didn't authorize, or a
  fork appears with materially different outcomes and no obvious default.

At a STOP: park the question with your lean, keep the loop moving on anything else still
in-scope, and only go fully idle when nothing reversible remains. A halt is not a failure — it's
the loop working. The failure mode is guessing on their call to avoid the pause. For the
judgment of which forks are yours to decide and which to park, see the **ask-vs-decide**
principle in `.claude/harness/principles/` — it's the companion to these boundaries.

## Surviving the night — wakeups and watchers

An unattended loop dies in two ways the runtime won't save you from: a background dependency
that never notifies, and a usage-limit pause that drops you mid-run. Engineer against both.

**Fallback heartbeat.** Whenever you end a turn with outstanding background work, schedule a
wakeup *before going idle*. Runtime-tracked subagents auto-notify, so this is a **fallback**,
not a poll — size it long (roughly 20-30 minutes) to survive a dead watcher or a
resumed-after-limit session, not to check in eagerly. For an autonomous loop with no user prompt
to repeat, use whatever re-entry sentinel the runtime provides so the next wake re-enters the
loop. The heartbeat is what turns "the watcher died and I sat idle for hours" into "the watcher
died and I woke up 25 minutes later and relaunched."

**Watcher discipline — and the load-bearing distinction between two kinds of background work.**
These are NOT the same and the recovery rules are opposite:

- **External broker jobs (a delegated external CLI, CI, remote queues)** can genuinely vanish
  without notifying. Treat **job-not-found / broker-loss as TERMINAL** — relaunch fresh, don't
  poll a dead ID to its silent timeout (a documented stranding failure). Give each such wait its
  own scheduled fallback.
- **Runtime-tracked subagents (anything you spawned via the agent-dispatch tool)** are the
  OPPOSITE. They **auto-notify on completion** and you **cannot see their liveness as a process**
  — the agent loop runs inside the runtime, not as a pollable OS process. Therefore:
  **output-file staleness is NOT proof of death.** A subagent doing a long build (50+ minutes,
  hundreds of tool calls) can sit silent for 30+ minutes on a single slow step (a big test run, a
  long read, a runtime pause from a parent rate-limit) with no transcript append and no visible
  process — and then resume and finish. **The ONLY reliable death signal for a runtime subagent
  is: it never sends its completion notification AND the work it owns shows no advancement over a
  genuinely long window (an hour-plus) AND you have positively ruled out "still running."** Until
  then it is ALIVE.

**NEVER declare a runtime subagent dead on silence alone, and NEVER touch a workspace a
possibly-live subagent owns.** Spawning a replacement into the same workspace, or
committing/editing its uncommitted work, is a **two-writer collision** — the single worst
self-inflicted failure in autonomous operation. If you truly must recover a suspected-dead
subagent: (1) wait out a long window for its completion notification; (2) confirm zero
head/tree advancement over that window; (3) prefer waiting one more heartbeat over acting. A
redundant replacement that races a live sibling is far more expensive than the minutes you save.

*Receipt: a session once declared a runtime subagent dead after ~30 minutes of output silence
with no visible process, committed its uncommitted work, and spawned a continuation. It was
never dead — a ~50-minute build paused mid-slow-step; it resumed and finished clean. No damage
that time (the continuation detected the collision and stood down; history stayed linear), but
it was luck, not discipline. The broker-loss=terminal rule does NOT transfer to runtime
subagents; conflating the two caused a redundant dispatch and a risky mid-flight commit into a
live agent's workspace.*

**Assemble deliverables eagerly with pending items marked** — don't hold a whole package
hostage to the last flaky verdict.

**Usage limits.** A rolling-window pause suspends and later resumes the session; a scheduled
wakeup + up-to-date files mean the resumed-you picks up cleanly instead of losing the thread.
This is another reason the journal is written continuously, not at the end — there may be no
clean "end" before a pause hits.

**Compaction thrashing.** If the loop keeps hitting compaction on the same stuck point without
net progress, don't keep refilling — escalate. (Cross-ref: `compact-resume` owns the guard; the
same rule applies inside an unattended loop.)

## Completion-promise loop (optional hardening)

*Mechanism adapted from anthropics/claude-code `plugins/ralph-wiggum` (MIT).*

For a **bounded, unattended, mechanically-checkable-done** task, the operator may arm a Stop-hook
that intercepts the session's attempt to end its turn and re-injects the task prompt until the
output contains an exact agreed **completion phrase** OR a **max-iterations** cap is hit. This is
a concrete, dependency-free hardening of the loop: where the wakeup heartbeat saves a run that
*paused*, the completion-promise loop saves a run that would otherwise *stop early* — it keeps the
session driving until the done-condition is literally met. It **complements, never replaces**, the
heartbeat + watcher discipline above; wire at most one loop mechanism per run and keep the
heartbeat regardless.

**When NOT to use it (the guardrails are the point):**
- **Never wired globally**, and never for an **interactive session** or **judgment-open-ended**
  work — it would fight normal conversation, re-injecting the prompt every time you legitimately
  try to end a turn. It is only for a task whose "done" is an exact, machine-checkable phrase.
- **Only when done is mechanically decidable.** If you can't state a completion phrase that is
  true exactly when the task is finished, this mechanism does not apply — use the normal
  loop-until-done + STOP-boundary discipline instead.
- It does not relax any STOP boundary: a destructive / live-prod / owner-gated fork still halts
  and parks a QUESTION. The promise loop only stops the session from ending *before* the
  reversible in-scope work is actually done.

**The hook.** Ship it from `references/stop-loop-hook.sh` (bash 3.2-safe, exit-code-footgun
compliant — it blocks a stop only by emitting `{"decision":"block","reason":…}` on exit 0, and
**fails SAFE**: on any parse error, unreadable transcript, or un-persistable counter it allows the
stop rather than looping forever). It is **inert until armed** — a wired-but-unarmed hook allows
every stop, which is what makes it safe to leave installed. To arm, populate a state dir (default
`$CLAUDE_PROJECT_DIR/.claude/stop-loop`, override with `$STOP_LOOP_DIR`):

```
prompt.txt   # the task prompt re-injected each loop        (required to arm)
promise      # the exact completion phrase to watch for     (required to arm)
max          # integer max iterations (default 20)          (optional)
count        # managed by the hook; delete to reset         (state)
cancel       # touch this file to end the loop immediately  (cancel path)
```

**Cancel path:** `touch $STOP_LOOP_DIR/cancel` (or remove the wiring). The `count` file plus `max`
are the hard iteration cap; `cancel` is the soft stop.

**Wiring (manual, out-of-band — a session never wires its own enforcement; see `.claude/harness/ENFORCEMENT.md`
invariant #3, no mid-session config self-modification).** After copying the script somewhere runnable, add to the target repo's
`.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "matcher": "", "hooks": [
        { "type": "command", "command": "bash \"$CLAUDE_PROJECT_DIR/.claude/harness-scripts/stop-loop-hook.sh\"" }
      ] }
    ]
  }
}
```

Then arm it for the one bounded run, let it drive to the completion phrase or the cap, and
disarm (delete the state dir or the wiring) when done. Wiring and arming are both human steps.
After any edit to the hook — and once after wiring it in a new project — run
`references/stop-loop-selftest.sh` (8 assertions pinning the fail-safe + block contracts).

## Commit as you go

Persist work at every coherent step (respecting the run's commit scope — path-scoped adds if
you share a checkout; flag before touching repos you were told to flag). A loop that does six
hours of work and commits once at the end loses everything to a crash and gives the operator
nothing to review incrementally. Commit small, commit often, message clearly.

## Morning presentation

When the operator returns (or you reach done), lead with the three files as the handoff surface:
where the loop got to, the decisions they can override (with reversibility), and the parked
questions awaiting them — framed in plain language. Surface the QUESTIONS first; those are what
block them. Everything else is FYI they can read at their pace.

## Relationship to other skills

This is the *harness* for unattended running; the *work* inside the loop still uses the normal
skills. It does not replace `session-end` (the full close ceremony) or `compact-prep` (the
mid-run checkpoint for a summarized future-self) — reach for those at their moments; this
governs the continuous discipline *between* them while the operator is away.
