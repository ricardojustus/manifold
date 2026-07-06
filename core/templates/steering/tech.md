<!--
  tech.md — steering document (2 of 3: product / tech / structure).
  Pattern adapted from Pimzino/claude-code-spec-workflow (MIT).

  WHAT THIS IS. A durable, per-project statement of HOW this project is built — the stack, the
  practices, the conventions, and the non-negotiables. Loaded once per project; a brief's GIVEN
  block CITES this for the stable technical context instead of re-deriving "what stack / what
  conventions" per dispatch. Keep it to the durable facts a newcomer needs before touching code;
  transient version pins that churn belong in the project's dependency manifests, not here.
  Delete these comments as you fill each section.
-->

# Tech — <project name>

## Stack
<!-- Languages, runtimes, frameworks, key libraries, datastores, external services. The load-
     bearing ones a newcomer must know exist — not an exhaustive dependency dump. -->

## Practices
<!-- How work is done here: test strategy (e.g. test-first? see test-driven-development),
     review/audit gates, branch and commit discipline, how changes ship. Point at the harness
     skills that own each practice rather than restating them. -->

## Conventions
<!-- The house style a change must match to look native: error-handling posture, logging,
     naming, formatting/lint rules, API/interface shape. "Match the surrounding code" is the
     default; name the conventions where the surrounding code is not obvious. -->

## Non-negotiables
<!-- The hard technical constraints — the things a change must never violate (a security
     posture, a compatibility contract, a performance floor, a locked interface). These are the
     project-level cousins of .claude/harness/ENFORCEMENT.md's invariants; each should carry its WHY. -->
