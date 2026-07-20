---
name: test-driven-development
description: >-
  Drives new behavior test-first: RED → GREEN → REFACTOR — write the failing test first and watch it fail for the RIGHT reason, minimum code to pass, refactor green; never weaken or skip a failing test. Ships a testing-anti-patterns bank. Use for "TDD this", "write the test first", "red-green-refactor". For a live bug use debugging-discipline.
---

# Test-driven development — RED → GREEN → REFACTOR

TDD is not "write tests." It is a specific order — **the test comes before the code** — and the
order is the point: a test written *after* the code encodes what the code happens to do, including
its bugs; a test written *before* encodes what it *should* do. This skill is that loop as a
checkable procedure, plus the bank of ways tests lie (`references/testing-anti-patterns.md`).

It specializes the harness's **goal-driven-execution** principle to the construction of new
behavior. Two neighbors it is NOT:
- **debugging-discipline** DIAGNOSES a live defect — its fix phase is also test-first (the failing
  repro), but the skill is about root-causing, not building new behavior.
- **spec-adherence** verifies a *finished* implementation against a locked spec. TDD runs during
  construction; spec-adherence gates after it.

## RED — write the failing test first, and watch it fail

1. **Write the test before the implementation exists.** State, as a test, the single next
   behavior you want. If the unit under test isn't there yet, the test won't compile or will
   error — that is fine, that is RED.
2. **Run it and confirm it fails for the RIGHT reason.** Non-negotiable, and the step most often
   skipped. A test you never watched fail might be passing for a reason unrelated to your code — a
   stubbed dependency, an assertion that can't fail, a wrong import silently swallowed. If it
   fails with "undefined" when you expected "wrong value", your test is aimed wrong; fix the test
   before writing any code. **A test that has never been seen to fail is not yet a test — it is a
   hope.**
3. **One behavior at a time.** RED covers exactly one new fact about the system. Batching five
   behaviors into one test means you can't tell which one drove the code, and a later regression
   won't tell you which broke.

## GREEN — the minimum code to pass

- Write the **least** code that turns this specific test green. Not the general solution, not the
  abstraction you can already see. Over-building here is how you get untested branches: code the
  test never asked for, and so never checked.
- Run the full test suite, not just the new test. GREEN means *this* test passes AND nothing else
  broke. An old test going red is a regression — that is information, handle it now.
- Resist "while I'm here." The generalization is a later RED with its own test.

## REFACTOR — improve with the test as a net

- With the test green, improve the shape: remove duplication, rename for clarity, extract the
  abstraction that has *earned* its place (two or three real call sites, not a speculative one).
  Run the test after each refactor step.
- Refactor changes structure, never behavior. If a test goes red during refactor, you changed
  behavior — revert and try again.
- Then loop back to RED for the next behavior.

## The hard rule: a failing test is information, never an obstacle

**Never weaken, skip, comment out, or delete a failing test to get to green.** A red test is
telling you something true. The only honest responses: fix the code, or (if the test itself is
wrong) fix the test to assert the *correct* behavior and watch it fail again for the right reason.
What you must never do:

- loosen the assertion until it passes (`assertEquals(x, x)`),
- wrap it in a skip/quarantine "for now" (the "for now" that never returns),
- delete it because it's inconvenient.

Each converts a signal into a lie. A quarantined test is worse than no test: it looks like
coverage and provides none. If a test genuinely must be disabled, that is a decision with a
receipt (why, and the trigger to re-enable), not a quiet edit to reach green.

## The anti-pattern bank

Tests lie in recurring, recognizable ways — assert-nothing tests, tests that mirror the
implementation instead of the contract, weakened assertions, over-mocking until nothing real is
exercised, vacuous structural tests (asserting only a function's *arity*), snapshot-everything,
and quarantined tests that never return. Each one, with its rationale and how to recognize it, is
in `references/testing-anti-patterns.md`. Read it before writing a test suite you'll rely on; a
green suite full of these is more dangerous than no suite at all.

## When to invoke

- Building a new unit of behavior test-first: "TDD this", "write the test first",
  "red-green-refactor", "/test-driven-development".
- Proactively whenever you're about to write implementation code for a behavior that can be
  expressed as a test before it exists — which is most behavior.

## Pairs with

- **goal-driven-execution** (principle) — the parent discipline; TDD is its test-first
  specialization for new construction.
- **debugging-discipline** — the diagnosis procedure; its fix phase shares TDD's
  failing-test-first step but targets live bugs, not new behavior.
- **spec-adherence** — the post-implementation conformance gate.
- **The bugfix artifact** (methodology express-lane) — the record a test-first fix fills.
