# Completion-promise loop (optional hardening)

*Mechanism adapted from anthropics/claude-code `plugins/ralph-wiggum` (MIT).*

For a **bounded, unattended, mechanically-checkable-done** task, the operator may arm a Stop-hook
that intercepts the session's attempt to end its turn and re-injects the task prompt until the
output contains an exact agreed **completion phrase** OR a **max-iterations** cap is hit. Where the
wakeup heartbeat saves a run that *paused*, this saves a run that would otherwise *stop early*. It
**complements, never replaces**, the heartbeat + watcher discipline; wire at most one loop
mechanism per run and keep the heartbeat regardless.

## When NOT to use it (the guardrails are the point)

- **Never wired globally**, and never for an **interactive session** or **judgment-open-ended**
  work — it would fight normal conversation, re-injecting the prompt every time you legitimately
  try to end a turn. It is only for a task whose "done" is an exact, machine-checkable phrase.
- **Only when done is mechanically decidable.** If you can't state a completion phrase that is
  true exactly when the task is finished, this mechanism does not apply — use the normal
  loop-until-done + STOP-boundary discipline instead.
- It does not relax any STOP boundary: a destructive / live-prod / owner-gated fork still halts
  and parks a QUESTION. The promise loop only stops the session from ending *before* the
  reversible in-scope work is actually done.

## The hook

Ship it from `references/stop-loop-hook.sh` (bash 3.2-safe, exit-code-footgun compliant — it
blocks a stop only by emitting `{"decision":"block","reason":…}` on exit 0, and **fails SAFE**: on
any parse error, unreadable transcript, or un-persistable counter it allows the stop rather than
looping forever). It is **inert until armed** — a wired-but-unarmed hook allows every stop, which
is what makes it safe to leave installed. To arm, populate a state dir (default
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

## Wiring

Manual, out-of-band — a session never wires its own enforcement; see `.claude/harness/ENFORCEMENT.md`
invariant #3, no mid-session config self-modification. After copying the script somewhere runnable,
add to the target repo's `.claude/settings.json`:

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
