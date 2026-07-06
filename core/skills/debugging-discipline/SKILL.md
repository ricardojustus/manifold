---
name: debugging-discipline
description: >-
  Run a disciplined live bug-hunt: find the ROOT CAUSE before changing anything, then
  fix it once. Four phases — (1) root-cause investigation (trace backward from the
  symptom, instrument boundaries; NO FIXES WITHOUT A ROOT CAUSE), (2) pattern analysis
  (diff against the nearest working analogue), (3) hypothesis testing (one hypothesis,
  one change, never combine variables), (4) fix (failing test first, then the fix, then
  sweep for the same defect class). Hard circuit breaker: 3 failed fix attempts → STOP,
  question the architecture, escalate with a written summary — not a 4th attempt. Use
  when chasing a live bug, a failing test, or a regression — "debug X", "it's broken",
  "find the root cause", "/debugging-discipline". NOT the pre-merge gates (audit-cycle /
  spec-adherence verify a finished change; this DIAGNOSES a live one) and NOT the bugfix
  artifact (that's the contract you fill; this is the procedure that fills it).
allowed-tools: Read, Edit, Bash, Grep, Glob
---

# Debugging discipline

Bugs get fixed badly in one recurring way: the symptom is treated as the problem. Someone sees
an error, pattern-matches it to a plausible cause, changes something near the symptom, the
symptom moves — and the real defect is still there, now with a second patch layered on top. This
skill is the discipline that stops that: **understand before you change, one variable at a time,
and know when to stop digging and escalate.**

It is the *diagnosis* procedure. Two neighbors it is NOT:
- The **pre-merge gates** (`audit-cycle`, `spec-adherence`) verify a *finished* change against a
  spec. This runs earlier — on a *live* defect, before there's a change to gate.
- The **bugfix artifact** (the methodology's express-lane record: symptom / root-cause / fix /
  unchanged-behavior invariants / regression test) is the *contract* you produce. This skill is the procedure that
  *fills* it — the artifact is the output, this is the method.

## Phase 1 — Root-cause investigation (NO FIXES YET)

**The hard gate of the whole skill: no fix is written until the root cause is named.** A fix
applied before the cause is understood is a guess, and a guess that moves the symptom is worse
than no fix — it hides the defect and adds a patch to maintain.

- **An error code / message is not a cause.** It's a symptom. The constitution's error-triage
  rule is the parent discipline here: a 500, a null-deref, a timeout, a non-zero exit tells you
  *where it surfaced*, never *why*. The cause is unverified until you've traced it to the actual
  origin with evidence in hand.
- **Trace backward from the symptom.** Start where it breaks and walk *upstream* — what called
  this, with what inputs, from what state — until you reach the first place where reality
  diverges from what should be true. That divergence point is the root cause; the symptom is just
  where it finally became visible.
- **Instrument the boundaries.** Add logging / asserts / a debugger breakpoint at the module and
  function edges along the suspected path. Read the ACTUAL values crossing each boundary; don't
  infer them. The bug lives at the first boundary where the value is already wrong.
- **Reproduce it reliably first.** A bug you can't reproduce on demand can't be verified fixed.
  If it's intermittent, find the condition that makes it deterministic before going further.

Output of phase 1: a one-sentence root cause you can state and point to in the code. If you can't,
you're not done investigating — do not proceed to a fix.

## Phase 2 — Pattern analysis

Before theorizing in a vacuum, **diff against the nearest WORKING analogue.** Almost every bug has
a sibling that works: the same call on a different input, a parallel code path, the last release
where it worked, an adjacent handler that doesn't have the defect.
- Find the closest thing that works and compare it, line by line, against the broken path.
- The difference set is your suspect list — and it's grounded in a real working reference, not in
  imagination.
- If nothing analogous works, widen: is this a whole *class* of input/state that was never
  handled, versus a regression in something that used to work? The two have different root-cause
  shapes.

## Phase 3 — Hypothesis testing (one variable at a time)

- **One hypothesis, one change, one test.** State the single hypothesis ("the value is wrong
  because X"), make the single change that would confirm or refute it, run the test. Never combine
  two changes — if the symptom moves, you won't know which one did it, and you may have introduced
  a second bug while masking the first.
- **A hypothesis that survives is confirmed only when you can explain the whole chain** — root
  cause → mechanism → symptom — not just "I changed it and the error went away." Symptoms go away
  for coincidental reasons; that's not a fix.
- Keep a scratch record of what you tried and what it showed. This is what feeds the circuit
  breaker below, and later the bugfix artifact.

## Phase 4 — Fix (failing test first, then the fix, then the sweep)

1. **Write the failing test first.** Encode the reproduction as a test that fails NOW, for the
   root-cause reason. This is what turns "the symptom went away" into "the defect is provably
   gone" — and it guards against the regression returning.
2. **Then make it pass** with the minimum change that addresses the *root cause* (not the symptom).
   Surgical: touch only what the root cause requires.
3. **Then sweep for the same defect class elsewhere.** A root cause is rarely unique — the same
   mistake usually lives in sibling code. Grep for the pattern and fix (or ticket) every instance,
   so the class dies, not just this one case. This is the **fix-the-class** principle (in
   `.claude/harness/principles/`) — apply it every time; a fix that leaves five siblings alive is a quarter
   of a fix.
4. **Verify unchanged behavior.** Confirm the fix didn't move behavior you weren't targeting —
   this is exactly the "unchanged-behavior invariants" line the bugfix artifact asks for.

## The circuit breaker — 3 strikes, then STOP

**Three failed fix attempts on the same bug → STOP. Do not make a fourth.**

Three failures is not bad luck — it's a signal that your model of the system is wrong. A fourth
attempt from the same wrong model produces another failure plus more layered damage. When you hit
three:
- **Stop changing code.** Question the architecture, not the line — the defect may be a design
  mismatch, not a bug in this function.
- **Consult the advisor first, if the runtime has one** (`advisorModel` set): a fresh
  full-transcript read of the failed attempts is exactly what breaks a tunnel — do this BEFORE
  escalating to the operator; fold its read into your summary (concur/dissent noted).
- **Write a summary and escalate.** What the symptom is, what you've tried (all three, with what
  each showed), what you've ruled out, and what you now suspect is wrong at the design level.
  Escalate to the operator (or a fresh reviewer) with that summary.
- This is the same shape as the compaction / autonomous-loop thrashing guards: **repeated failure
  on one point means the approach is wrong; escalate, don't grind.**

The circuit breaker is a discipline, not a defeat. Catching a wrong mental model at strike three
and escalating is far cheaper than the tenth patch on a design that can't hold the fix.

## When to invoke
- Chasing a live bug, a failing test, a regression, or "why is this happening": "debug X", "it's
  broken", "find the root cause", "/debugging-discipline".
- Proactively the moment you notice you're about to change code near a symptom without having
  named its cause — that's the failure this skill exists to stop.

## Pairs with
- The constitution's error-triage rule ("an error code is not a cause") — the parent discipline
  for phase 1.
- The **fix-the-class** principle (`.claude/harness/principles/`) — phase 4's sibling-sweep.
- The **bugfix artifact** (the methodology express-lane) — the contract this procedure fills.
- `audit-cycle` / `spec-adherence` — the pre-merge gates that verify the finished fix; distinct
  from this diagnosis pass.
