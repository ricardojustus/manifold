<!--
  bugfix.md — the express-lane artifact for a bug. Bugs fall between the full multi-phase
  build loop (too heavy) and ad-hoc patching (too loose); this five-field contract is the
  right size for the common case. A bug is scored on the stakes rubric like anything else —
  most land Low and use this; a High-stakes bug (irreversible / core-substrate / security
  boundary) leaves the express lane and takes a full spec. The two fields that make this
  more than a patch note are Unchanged-behavior invariants and the Regression test keyed
  to them — that's the surgical-change contract made explicit and enforced.
-->

# Bugfix — <short title>

## Symptom
<!-- The observed failure, VERBATIM. The error text, the wrong output, the repro steps.
     NOT the guessed cause — the symptom is what you saw, not why. -->

## Root cause
<!-- Traced, not assumed. One evidence link (the line, the trace, the probe output). An
     error code is a symptom, never a cause — see the error-triage principle. If you can't
     trace it, you're not ready to fix it. -->

## Fix
<!-- The change, scoped to the root cause. Before closing: grep for the SIBLINGS of this
     bug (the fix-the-class principle) — the same mistake was probably made elsewhere. -->

## Unchanged-behavior invariants
<!-- What MUST still hold after the fix: the behaviors the surrounding code depends on that
     this change must NOT perturb. This is the surgical-change contract, written down. -->
- <invariant that must survive the fix>

## Regression test
<!-- A test keyed to the invariants above: it FAILS on the bug (proving the repro) and
     PASSES after the fix (proving the fix), and it guards the invariants against a future
     re-break. Cite the test path. -->
- <test path> — fails-before / passes-after
