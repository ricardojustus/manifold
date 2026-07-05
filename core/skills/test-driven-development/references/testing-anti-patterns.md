# Testing anti-patterns bank

*Pattern from obra/superpowers (MIT), rewritten. The receipts are anonymized to the source
project's own audit history.*

Tests are supposed to be the thing you trust when everything else is uncertain. That trust is
only earned if the tests actually exercise the behavior they claim to. These are the recurring
ways a green suite lies — each with how to recognize it and the one-line rationale (a receipt)
for why it's banned. When a test "passes," ask which of these it might be before you believe it.

---

## 1. The test that asserts nothing

**Shape.** A test that runs the code but has no assertion, or an assertion that cannot fail
(`assert True`, `expect(x).toBeDefined()` on something that is always defined, a `try/catch` that
swallows the failure and passes anyway).

**Recognize it.** Delete the implementation's body and the test still passes. If breaking the code
doesn't break the test, the test checks nothing.

**Receipt / why banned.** A no-assertion test is coverage theater: it lights up the coverage
report and verifies nothing. It is worse than no test, because it tells you an untested path is
tested.

---

## 2. The test written after the code that mirrors its implementation

**Shape.** A test authored *after* the implementation that re-encodes the code's own steps —
asserting on internal calls, private intermediate values, or the exact branch structure — instead
of the observable contract.

**Recognize it.** The test breaks on every refactor even when behavior is unchanged, because it
is coupled to *how*, not *what*. It also can't catch the bug the code already has: it was written
to match the code, so it agrees with the code's mistakes.

**Receipt / why banned.** A test that mirrors the implementation validates that the code does what
it does — a tautology. This is the core reason for test-FIRST: a test written before the code
encodes the intended contract, not the accidental implementation.

---

## 3. The weakened assertion

**Shape.** An assertion loosened until a failing test passes — `assertEquals(expected, actual)`
softened to `assertNotNull(actual)`, a specific value relaxed to `any`, a tightened range widened
to swallow the wrong result.

**Recognize it.** Check the assertion's history / strength: does it pin the actual expected value,
or merely that *something* came back? "Not null" where the contract specifies a value is a
weakened assertion.

**Receipt / why banned.** Weakening an assertion to reach green converts a real signal ("the
output is wrong") into a lie ("the output exists"). This is the failing-test-is-information rule
violated in slow motion — the test still runs, so it looks honest, but it no longer checks the
thing that failed.

---

## 4. Over-mocking until nothing real is exercised

**Shape.** So many collaborators are mocked that the test drives only mocks — every dependency is
a stub returning canned values, and the real integration between units is never run.

**Recognize it.** Count what's real versus mocked in the test. If the only real object is the
mock framework, the test proves the mocks were configured, not that the system works.

**Receipt / why banned.** Mocks are for isolating a genuinely external or slow boundary (network,
clock, filesystem), not for replacing the logic under test. Over-mocking gives a fast green suite
that stays green while the real integration is broken — the worst false sense of safety.

---

## 5. Testing the mock

**Shape.** The assertion checks the mock's own configured behavior — `mock.returns(5); assert
result == 5` — so the test verifies the test's own setup, not the code.

**Recognize it.** Trace the asserted value back: does it come from the code's logic, or from a
`.returns()` you wrote three lines up? If the answer is set by the mock, you're testing the mock.

**Receipt / why banned.** A test that asserts its own stub's return value is a closed loop that
can never fail for a real reason. It is the over-mock failure taken to its endpoint.

---

## 6. The vacuous structural test (arity-only)

**Shape.** A test that asserts only a function's *shape* — that it exists, or that it takes N
arguments (`assert fn.length === 2`) — without ever calling it and checking what it does.

**Recognize it.** The test never invokes the function with real inputs and never checks an output.
It would pass for an empty function body of the right signature.

**Receipt / why banned.** The source project's own audits caught exactly this — a test asserting a
function's arity and nothing else, which passed against an implementation that did the wrong thing
entirely. Structure is not behavior; a signature check is not a test.

---

## 7. Snapshot-everything

**Shape.** A giant snapshot/golden-file assertion over a whole output blob, auto-updated whenever
it fails.

**Recognize it.** When the snapshot breaks, is the reflex to *understand* the diff or to press
"update"? A snapshot that is regenerated on every failure asserts nothing — it always matches
itself.

**Receipt / why banned.** Snapshots are acceptable for a small, stable, human-reviewed output.
Over a large or churny blob they become a rubber stamp: no one reads the diff, the update key
launders regressions into the golden file, and the test's job (catch unintended change) inverts
into "record whatever happened."

---

## 8. The skipped / quarantined test that never returns

**Shape.** A test marked skip / ignore / `xit` / `@Disabled` "temporarily" — and left there.

**Recognize it.** Grep for skip markers; check how old they are. A skip with no re-enable trigger
and no dated receipt is permanent by default.

**Receipt / why banned.** A quarantined test looks like coverage and provides none — the most
dangerous state, because the suite reports a behavior as tested while the guard is off. Disabling
a test is a decision that needs a receipt (why, and the exact trigger to turn it back on), never a
quiet edit to make the suite green.

---

## The through-line

Every anti-pattern here is one move: **converting a signal into a comforting lie.** A test exists
to fail when the code is wrong. Anything that makes a test pass while the code is wrong — no
assertion, a weakened one, an all-mock harness, a snapshot rubber-stamp, a skip — defeats the
entire reason the test is there. When you catch yourself making a red test green by changing the
*test*, stop: you are almost certainly writing one of these.
