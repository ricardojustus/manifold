# Threads — parallel long-lived workstreams on one project

**When to split.** One project, more than one concurrent long-lived workstream (a build track, a
migration, a research arc — each spanning many sessions). Below that, don't: a single stream
uses the root session files directly, and a short-lived parallel task is a dispatch
(`parallel-workstreams`), not a thread. Threads are for workstreams that each need their own
*continuity* — state, history, decisions — over days or weeks, side by side.

*Receipt: the source project ran four concurrent tracks this way (two build tracks, a memory
rebuild, this harness itself) across overlapping sessions with zero file collisions; the one
near-miss was a wrong-branch commit, caught by the re-verify-pwd-and-branch rule, not by luck.*

## The contract

1. **Each thread owns a folder** — `<threads-root>/<name>/` (the overlay binding names the
   concrete root) — holding ALL of its session-lifecycle files: `KICKOFF.md` (the mission
   brief), `STATE.md`, `JOURNAL.md`, `DECISIONS.md`, `QUESTIONS-FOR-OPERATOR.md`, and
   `COMPACT_CHECKPOINT.md` when it compacts. The templates in `harness-templates/` apply
   unchanged — they just live in the thread's folder.
2. **Root session files belong to exactly ONE primary thread** (named in the binding). Every
   other thread treats them as read-only, always. This is the single rule that makes parallel
   threads safe: two writers on one state file is how continuity dies.
3. **Never write into a sibling thread's folder.** Not updates, not helpful fixes, not
   messages. If a sibling needs to know or decide something, park it in YOUR
   `QUESTIONS-FOR-OPERATOR.md` — the operator is the bus between threads. Never assume a
   sibling saw anything you wrote.
4. **The session lifecycle binds to the owning thread.** When a session belongs to a thread,
   `session-start` reads the THREAD's KICKOFF + STATE (not the root ones), `session-end`
   updates the THREAD's STATE/JOURNAL, `compact-prep` writes the THREAD's checkpoint, and
   `autonomous-work`'s three hygiene files are the thread's own. One source of truth per
   thread, in one folder.
5. **Sessions declare their lane.** A thread session opens knowing which thread it is (the
   operator says so, or the kickoff prompt does) and stays in-lane; work that belongs to
   another thread routes through the operator, not around them.

## The banner (paste at the top of every thread KICKOFF)

> **⚡ THREAD SPLIT:** this is **<Thread Name>** — its session files live in
> `<threads-root>/<name>/` (KICKOFF + STATE.md + JOURNAL.md + DECISIONS.md +
> QUESTIONS-FOR-OPERATOR.md). **Never edit root session files** — those belong to
> <primary thread>. Cross-thread coordination = a parked question + the operator as bus.
> Sibling threads: <list>.

The banner exists because a fresh session (or a compacted one) reads the KICKOFF first — the
ownership rules must be the first thing it sees, not something it infers.
