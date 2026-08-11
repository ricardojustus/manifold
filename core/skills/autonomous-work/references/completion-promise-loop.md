# Completion-promise loop (optional hardening)

*Mechanism adapted from anthropics/claude-code `plugins/ralph-wiggum` (MIT).*

For a **bounded, unattended, termination-mechanically-checkable** task, the operator may arm a
Stop-hook that intercepts the session's attempt to end its turn and re-injects a continuation
payload until the last assistant message contains an exact agreed **completion phrase** OR a cap
is hit — the heartbeat saves a run that *paused*, this saves one that would *stop early*. It
**complements, never replaces**, the heartbeat + watcher discipline; wire at most one loop
mechanism per run and keep the heartbeat regardless.

**Eligibility — termination, not the work, must be mechanical.** The done condition must be
computable from recorded evidence. Work INSIDE the loop may be judgment-based (a quality-pursuit
run whose critics exercise judgment every cycle) so long as the run's stop rules evaluate from
recorded numbers — a ledger the run appends as it goes. The exclusion's real target is the run
where "done" ITSELF is a judgment call: if no recorded evidence can decide termination, this
mechanism does not apply — use the normal loop-until-done + STOP-boundary discipline instead.

## When NOT to use it (the guardrails are the point)

- **Never wired globally**, and never for an **interactive session** — it would fight normal
  conversation, re-injecting the prompt every time you legitimately try to end a turn.
- **Never where "done" itself is a judgment call** (the eligibility rule above).
- It does not relax any STOP boundary: a destructive / live-prod / owner-gated fork still halts
  and parks a QUESTION. The promise loop only stops the session from ending *before* the
  reversible in-scope work is actually done.

## Two shapes

**Classic — mechanical work, mechanical done** (scripts, migrations, ports): `prompt.txt` = the
task prompt, re-injected whole; `promise` = the completion phrase; `max` = a generous iteration
ceiling. Restating the full task each iteration is fine when every iteration starts from a
checkable state.

**Stall-recovery — judgment-based work, mechanical termination** (an asymptotic quality-pursuit
run): the hook is a STALL-RECOVERY device, not a completion device — the run's stop rules own
termination. Two differences:

1. **Payload = a continuation sentinel, never the original task prompt.** `prompt.txt` carries:
   *"Resume the run from the ledger and the compaction checkpoint; evaluate the stop rules;
   continue."* Re-injecting the original prompt mid-run induces restart-from-zero reasoning —
   the amnesia the checkpoint exists to prevent. The sentinel should add the fast path: *"If
   the loop counter is climbing with no new ledger entry, the machinery is stalled — park a
   QUESTION with the evidence and notify, instead of continuing."* (The hook prints the
   iteration counter with every re-injection, so the session can see it.)
2. **Cap = progress-keyed, not run-keyed.** `max` = N consecutive re-injections without a new
   ledger entry (default 5), armed by convention: the run **deletes `count` every time it
   appends a ledger entry** (sanctioned — the counter is documented delete-to-reset). The cap
   then bounds stall-thrash, never run length, and fires precisely on the broken-machinery
   signature: re-injection with no ledger advancement. On cap the hook allows the stop; the
   still-armed heartbeat wakeup finds `count` at `max` in the state dir, parks the stall
   QUESTION, and notifies — one more reason the heartbeat stays mandatory even with the hard
   loop armed.

**Early-victory guardrails — mandatory on any judgment-inside run:**

1. The completion phrase may be emitted only AFTER the stop-rule evaluation is written to the
   run's ledger with its evidence, and the message emitting the phrase cites that ledger entry.
   A phrase without the entry is a violation, not a completion.
2. The advisor done-declaration consult (run moment #4 in SKILL.md) is MANDATORY before
   emitting the phrase — concur or dissent logged in DECISIONS.

## The hook

Ship it from `references/stop-loop-hook.sh` (bash 3.2-safe, exit-code-footgun compliant — it
blocks a stop only by emitting `{"decision":"block","reason":…}` on exit 0, and **fails SAFE**: on
any parse error, unreadable transcript, or un-persistable counter it allows the stop rather than
looping forever). It is **inert until armed** — a wired-but-unarmed hook allows every stop, which
is what makes it safe to leave installed. To arm, populate a state dir (default
`$CLAUDE_PROJECT_DIR/.claude/stop-loop`, override with `$STOP_LOOP_DIR`):

```
prompt.txt   # the re-injected payload: task prompt (classic)
             #   or continuation sentinel (stall-recovery)   (required to arm)
promise      # the exact completion phrase to watch for      (required to arm)
max          # the cap (default 20): iterations (classic);
             #   consecutive no-progress re-injections
             #   (stall-recovery — run deletes count on
             #   each ledger append)                         (optional)
count        # managed by the hook; delete to reset          (state)
cancel       # touch this file to end the loop immediately   (cancel path)
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
