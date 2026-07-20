---
name: debugging-discipline
description: >-
  Hunts a live bug to its ROOT CAUSE before changing anything — trace backward from the symptom, one hypothesis at a time, fix test-first, sweep the defect class; 3 failed attempts → stop and escalate. Use for "debug X", "it's broken", "find the root cause", "/debugging-discipline". Diagnoses a live defect, unlike the pre-merge gates (audit-cycle, spec-adherence).
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# Debugging discipline

Bugs get fixed badly in one recurring way: the symptom is treated as the problem — a plausible cause
is pattern-matched, something near the symptom changes, the symptom moves, and the real defect
survives under a new patch. The discipline: **understand before you change, one variable at a time,
and know when to stop digging and escalate.**

Two neighbors this is NOT: the **pre-merge gates** (`audit-cycle`, `spec-adherence`) verify a
*finished* change against a spec — this runs earlier, on a *live* defect; and the **bugfix
artifact** (the methodology's express-lane record: symptom / root-cause / fix / unchanged-behavior
invariants / regression test) is the *contract* you produce — this is the procedure that fills it.

## Phase 1 — Root-cause investigation (NO FIXES YET)

**The hard gate of the whole skill: no fix is written until the root cause is named.** A fix applied
before the cause is understood is a guess, and a guess that moves the symptom is worse than no fix.

- **An error code / message is not a cause** — it's a symptom (the constitution's error-triage rule
  is the parent discipline). A 500, a null-deref, a timeout, a non-zero exit tells you *where it
  surfaced*, never *why*. The cause is unverified until traced to its origin with evidence in hand.
- **Trace backward from the symptom** — start where it breaks and walk *upstream* (what called this,
  with what inputs, from what state) until you reach the first place reality diverges from what
  should be true. That divergence is the root cause.
- **Instrument the boundaries** — logging / asserts / a breakpoint at module and function edges along
  the suspected path. Read the ACTUAL values crossing each boundary; don't infer them. The bug lives
  at the first boundary where the value is already wrong.
- **Reproduce it reliably first** — a bug you can't reproduce on demand can't be verified fixed. If
  intermittent, find the condition that makes it deterministic before going further.

**Output of phase 1**: a one-sentence root cause you can state and point to in the code. If you
can't, you're not done investigating — do not proceed to a fix.

## Phase 2 — Pattern analysis

Before theorizing in a vacuum, **diff against the nearest WORKING analogue** — the same call on a
different input, a parallel code path, the last release where it worked, an adjacent handler without
the defect. Compare it line by line against the broken path; the difference set is your suspect
list, grounded in a real reference rather than imagination. If nothing analogous works, widen: is
this a whole *class* of input/state that was never handled, or a regression in something that used
to work? The two have different root-cause shapes.

## Phase 3 — Hypothesis testing (one variable at a time)

- **One hypothesis, one change, one test.** State the single hypothesis ("the value is wrong because
  X"), make the single change that confirms or refutes it, run the test. Never combine two changes —
  if the symptom moves you won't know which did it, and you may have added a second bug while
  masking the first.
- **A surviving hypothesis is confirmed only when you can explain the whole chain** — root cause →
  mechanism → symptom — not "I changed it and the error went away." Symptoms go away for
  coincidental reasons; that's not a fix.
- Keep a scratch record of what you tried and what it showed — it feeds the circuit breaker and
  later the bugfix artifact.

## Phase 4 — Fix (failing test first, then the fix, then the sweep)

1. **Write the failing test first** — encode the reproduction as a test that fails NOW, for the
   root-cause reason. That turns "the symptom went away" into "the defect is provably gone" and
   guards the regression.
2. **Then make it pass** with the minimum change addressing the *root cause*, not the symptom.
   Surgical: touch only what the root cause requires.
3. **Then sweep for the same defect class elsewhere** — a root cause is rarely unique; the same
   mistake usually lives in sibling code. Grep the pattern and fix (or ticket) every instance. This
   is the **fix-the-class** principle (`.claude/harness/principles/`) — a fix leaving five siblings
   alive is a quarter of a fix.
4. **Verify unchanged behavior** — confirm the fix didn't move behavior you weren't targeting (the
   "unchanged-behavior invariants" line the bugfix artifact asks for).

## The circuit breaker — 3 strikes, then STOP

**Three failed fix attempts on the same bug → STOP. Do not make a fourth.** Three failures is not
bad luck; it signals your model of the system is wrong, and a fourth attempt from the same wrong
model produces another failure plus more layered damage. At three:

- **Stop changing code.** Question the architecture, not the line — the defect may be a design
  mismatch, not a bug in this function.
- **Consult the advisor first, if the runtime has one** (`advisorModel` set): a fresh
  full-transcript read of the failed attempts is what breaks a tunnel. Do this BEFORE escalating to
  the operator, and fold its read into your summary (concur/dissent noted).
- **Write a summary and escalate** to the operator (or a fresh reviewer): the symptom, all three
  attempts and what each showed, what you've ruled out, and what you now suspect is wrong at the
  design level.
- Same shape as the compaction / autonomous-loop thrashing guards: repeated failure on one point
  means the approach is wrong — escalate, don't grind.

## When to invoke

Chasing a live bug, a failing test, a regression, or "why is this happening": "debug X", "it's
broken", "find the root cause", "/debugging-discipline". Proactively the moment you notice you're
about to change code near a symptom without having named its cause — that's the failure this skill
exists to stop.

## Pairs with

The constitution's error-triage rule ("an error code is not a cause" — parent discipline for phase
1) · the **fix-the-class** principle (`.claude/harness/principles/`, phase 4's sweep) · the **bugfix
artifact** (the contract this fills) · `audit-cycle` / `spec-adherence` (the pre-merge gates that
verify the finished fix).
