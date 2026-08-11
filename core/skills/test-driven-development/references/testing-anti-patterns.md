# Testing anti-patterns bank

*Pattern from obra/superpowers (MIT), rewritten. The receipts are anonymized to the source
project's own audit history.*

The recurring ways a green suite lies, each with how to recognize it. When a test "passes," ask
which of these it might be before you believe it.

---

## 1. The test that asserts nothing

**Shape.** A test that runs the code but has no assertion, or an assertion that cannot fail
(`assert True`, `expect(x).toBeDefined()` on something that is always defined, a `try/catch` that
swallows the failure and passes anyway).

**Recognize it.** Delete the implementation's body and the test still passes. If breaking the code
doesn't break the test, the test checks nothing.

---

## 2. The test written after the code that mirrors its implementation

**Shape.** A test authored *after* the implementation that re-encodes the code's own steps —
asserting on internal calls, private intermediate values, or the exact branch structure — instead
of the observable contract.

**Recognize it.** It breaks on every refactor even when behavior is unchanged (coupled to *how*,
not *what*), and it agrees with whatever mistakes the code already has.

---

## 3. The weakened assertion

**Shape.** An assertion loosened until a failing test passes — `assertEquals(expected, actual)`
softened to `assertNotNull(actual)`, a specific value relaxed to `any`, a tightened range widened
to swallow the wrong result.

**Recognize it.** Does the assertion pin the expected value, or merely that *something* came back?
"Not null" where the contract specifies a value is a weakened assertion.

---

## 4. Over-mocking until nothing real is exercised

**Shape.** So many collaborators are mocked that the test drives only mocks — every dependency is
a stub returning canned values, and the real integration between units is never run.

**Recognize it.** Count what's real versus mocked in the test. If the only real object is the
mock framework, the test proves the mocks were configured, not that the system works. Mocks are
for isolating a genuinely external or slow boundary (network, clock, filesystem), not for
replacing the logic under test.

---

## 5. Testing the mock

**Shape.** The assertion checks the mock's own configured behavior — `mock.returns(5); assert
result == 5` — so the test verifies the test's own setup, not the code.

**Recognize it.** Trace the asserted value back: does it come from the code's logic, or from a
`.returns()` you wrote three lines up? If the answer is set by the mock, you're testing the mock.

---

## 6. The vacuous structural test (arity-only)

**Shape.** A test that asserts only a function's *shape* — that it exists, or that it takes N
arguments (`assert fn.length === 2`) — without ever calling it and checking what it does.

**Recognize it.** The test never invokes the function with real inputs and never checks an output.
It would pass for an empty function body of the right signature.

**Receipt.** The source project's audits caught a test asserting only a function's arity, passing
against an implementation that did the wrong thing entirely.

---

## 7. Snapshot-everything

**Shape.** A giant snapshot/golden-file assertion over a whole output blob, auto-updated whenever
it fails.

**Recognize it.** When the snapshot breaks, is the reflex to *understand* the diff or to press
"update"? A snapshot that is regenerated on every failure asserts nothing — it always matches
itself. Snapshots are acceptable for a small, stable, human-reviewed output; over a large or
churny blob they are a rubber stamp.

---

## 8. The skipped / quarantined test that never returns

**Shape.** A test marked skip / ignore / `xit` / `@Disabled` "temporarily" — and left there.

**Recognize it.** Grep for skip markers and check their age — a skip with no re-enable trigger and
no dated receipt is permanent by default. Disabling a test is a decision that needs a receipt
(why, and the exact trigger to turn it back on), never a quiet edit to make the suite green.

---

## The through-line

Every anti-pattern here is one move: **converting a signal into a comforting lie.** A test exists
to fail when the code is wrong. Anything that makes a test pass while the code is wrong — no
assertion, a weakened one, an all-mock harness, a snapshot rubber-stamp, a skip — defeats the
entire reason the test is there. When you catch yourself making a red test green by changing the
*test*, stop: you are almost certainly writing one of these.
