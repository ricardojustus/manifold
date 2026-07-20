---
name: autonomous-work
description: >-
  Runs an unattended loop-until-done run: the three hygiene files (JOURNAL / DECISIONS / QUESTIONS), STOP boundaries parking destructive, live-prod or owner-gated actions, the fallback heartbeat, close-at-idle. Invoke the MOMENT a handoff starts — "I'm going to bed, keep going", "/loop until done", "run autonomously".
---

# Autonomous work — running unattended without dropping the thread

Invoke at the *start* of a handoff, before the first autonomous action. Two things fail silently
otherwise: **the loop stalls** (a dead dependency, a usage-limit pause, an ambiguous decision) and
**the record evaporates** — and retrofitting a journal after six hours means reconstructing from
memory, exactly the confabulation risk the record exists to kill. You stand in for the operator on
everything reversible and in-scope, and leave a clean desk for everything that's genuinely their
call. The three files ARE the clean desk.

## The three thread-local files (the non-negotiable core)

Keep three files, continuously, in the **owning thread's own folder** — never a shared/root
location, so two parallel autonomous runs never write the same file. (The project binding names
the run-local convention — a thread folder, a task workspace dir — for where these live.)

| File | Holds | Cadence |
|---|---|---|
| **JOURNAL** | What you DID — append-only narrative. Each entry: timestamp, what happened, the load-bearing outcome, commit SHAs. The compaction-survival surface: a summarized future-you rebuilds the run from here. | Append at every meaningful step + before any wakeup/idle. |
| **DECISIONS** | What you DECIDED autonomously — numbered, timestamped: the decision, the rationale, and its **reversibility** (so the operator knows the cost of overriding it). "I picked X because Y, cost to undo is Z." | One entry per autonomous call worth a sentence. Batch trivial ones. |
| **QUESTIONS** | What NEEDS THEM — parked decisions, ambiguities you refused to guess on, things owed. Each: the question in plain terms (names + context, no bare jargon — they can't answer a codename), your lean, why it's parked not decided. | The moment you hit a STOP boundary or an unanswerable fork. |

Write to these **silently and continuously** — don't narrate "I updated the journal." The test:
if the operator read only these three files cold, could they reconstruct the run, understand
every choice, and know exactly what's waiting on them? If not, they're too thin.

## Loop-until-done — and the STOP boundaries

**Proceed** on: anything that follows from the original mandate, anything version control can
roll back, anything inside the authorized scope, retrying after a transient error, gathering
missing information yourself. Don't stop to ask permission for work you were already told to do.

**HALT and park a QUESTION** — never guess — when the next action is:
- **Destructive or irreversible** — a delete/overwrite of something you didn't create, a
  history rewrite, a force-push, a data migration with no clean undo.
- **Live-production-touching** — anything that changes the running system the operator depends
  on (the live service, prod credentials, shared state other agents/people rely on). The moment
  the blast radius leaves your sandbox, stop.
- **Explicitly owner-gated** — a decision they reserved ("we do X together", "check with me
  before Y"). A reserved decision stays reserved even if the loop is ready for it.
- **A genuine scope change** — the work has drifted into something they didn't authorize, or a
  fork appears with materially different outcomes and no obvious default.

At a STOP: park the question with your lean and keep the loop moving on anything else in-scope.
When nothing reversible remains — completed or blocked — sweep and END the session (see "Close
at the idle boundary"). A halt is not a failure; the failure mode is guessing on their call to
avoid the pause. For which forks are yours to decide and which to park, see the **ask-vs-decide**
principle in `.claude/harness/principles/`.

## Advisor consults during the run (where the runtime has one)

The model-economy principle's advisor rules, applied when there's no operator to ask. With
`advisorModel` set, four run moments warrant a fresh-context second opinion — and only these;
routine loop iterations never do (each consult ships the full transcript, uncached):

1. **Gray-zone STOP classification** — before treating a borderline action as in-scope reversible.
   Misclassifying "proceed" is the expensive direction.
2. **Decide-and-park recommendations** — the parked lean is what the operator ratifies in the
   morning; consult before writing it, and record concur/dissent with the entry.
3. **Irreversible-ish in-scope commits** — a merge to a main branch, a lock record, an amendment
   executed under a pre-GO.
4. **The done-declaration** — before the morning presentation, an independent completion check
   against early-victory / no-op rationalization.

Log each consult in DECISIONS ("decided X; advisor concurred / dissented because Y") — a dissent
is exactly the signal the operator should see before ratifying. **The advisor can improve a
decision within your authority; it can NEVER expand it: a STOP boundary stays a STOP regardless
of what the advice says.**

## Surviving the night — wakeups and watchers

**Fallback heartbeat.** Whenever you end a turn with outstanding background work, schedule a
wakeup *before going idle*. Runtime-tracked subagents auto-notify, so this is a **fallback**, not
a poll — size it long (roughly 20-30 minutes) to survive a dead watcher or a resumed-after-limit
session. For an autonomous loop with no user prompt to repeat, use whatever re-entry sentinel the
runtime provides so the next wake re-enters the loop.

**Watcher discipline — two kinds of background work, opposite recovery rules:**

- **External broker jobs (a delegated external CLI, CI, remote queues)** can genuinely vanish
  without notifying. Treat **job-not-found / broker-loss as TERMINAL** — relaunch fresh, don't
  poll a dead ID to its silent timeout. Give each such wait its own scheduled fallback.
- **Runtime-tracked subagents (anything spawned via the agent-dispatch tool)** are the OPPOSITE:
  they **auto-notify on completion** and you **cannot see their liveness as a process** (the agent
  loop runs inside the runtime, not as a pollable OS process). Therefore **output-file staleness
  is NOT proof of death** — a subagent on a long build can sit silent for 30+ minutes on one slow
  step, then resume and finish. **The ONLY reliable death signal: no completion notification AND
  no advancement in the work it owns over a genuinely long window (an hour-plus) AND you have
  positively ruled out "still running."** Until then it is ALIVE.

**NEVER declare a runtime subagent dead on silence alone, and NEVER touch a workspace a
possibly-live subagent owns.** Spawning a replacement into its workspace, or committing/editing
its uncommitted work, is a **two-writer collision** — the worst self-inflicted failure in
autonomous operation. To recover a suspected-dead subagent: (1) wait out a long window for its
completion notification; (2) confirm zero head/tree advancement over that window; (3) prefer
waiting one more heartbeat over acting.

**Assemble deliverables eagerly with pending items marked** — don't hold a package hostage to the
last flaky verdict.

**Usage limits.** A rolling-window pause suspends and later resumes the session; a scheduled
wakeup + up-to-date files mean the resumed-you picks up cleanly — another reason the journal is
written continuously, since there may be no clean "end" before a pause hits.

**Compaction thrashing.** If the loop keeps hitting compaction on the same stuck point without net
progress, don't keep refilling — escalate. (`compact-resume` owns the guard.)

## Completion-promise loop (optional hardening)

For a **bounded, unattended, mechanically-checkable-done** task only, the operator may arm a
Stop-hook that re-injects the task prompt until an exact completion phrase appears or a
max-iterations cap is hit — it complements, never replaces, the heartbeat + watcher discipline,
and relaxes no STOP boundary. Never wired globally, never for interactive or judgment-open-ended
work. Mechanism, guardrails, state-dir contract, wiring, and selftest:
[`references/completion-promise-loop.md`](references/completion-promise-loop.md).

## Commit as you go

Persist work at every coherent step (respecting the run's commit scope — path-scoped adds if you
share a checkout; flag before touching repos you were told to flag). A loop that works six hours
and commits once at the end loses everything to a crash and gives the operator nothing to review
incrementally. Commit small, commit often, message clearly.

## Close at the idle boundary

An idle boundary = the run COMPLETED **or** is BLOCKED on a parked question. At either one,
unconditionally: run the **`session-end`** sweep immediately — while the prompt cache is still
warm (an idle wait outlives the cache TTL; a deferred sweep re-reads the whole context at full
uncached price) — then **END the session**. **Order: deliver the morning-presentation message (QUESTIONS first) →
sweep → end — never end before the operator has the report.** The kickoff + QUESTIONS files
carry the handoff and any parked question; the operator answers in a fresh, cheap session. The sweep persists
everything durably, so it is safe whatever the operator does next, and it relaxes no STOP
boundary: owner-gated actions stay parked in QUESTIONS.

## Morning presentation

When the operator returns (or you reach done), lead with the three files as the handoff surface:
where the loop got to, the decisions they can override (with reversibility), and the parked
questions awaiting them — in plain language. Surface the QUESTIONS first; those are what block
them. Everything else is FYI they can read at their pace.

## Relationship to other skills

This is the *harness* for unattended running; the *work* inside the loop still uses the normal
skills. It does not replace `session-end` (the full close) or `compact-prep` (the mid-run
checkpoint) — this governs the continuous discipline *between* them while the operator is away.
