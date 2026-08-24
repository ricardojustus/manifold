---
name: fresh-reviewer-dispatch
description: >-
  Dispatches the in-family review lens — a reviewer session that took no part in authoring, because freshness kills the author's blind spots. Covers what the reviewer must be given, what must never be said to it, and the completion signal. Use at floor wall #4 rungs 1 and 3: "get a fresh reviewer", "dispatch the Claude lens", "/fresh-reviewer-dispatch".
---

# Fresh-reviewer dispatch (the in-family lens)

**WHAT**: an in-family review by a session that took no part in authoring — freshness kills the
author's blind spots. **WHEN**: wall #4, rungs 1 and 3.

**INTERFACE**
- Agent tool, **`subagent_type: reviewer`** — the role file carries the adversarial charter and
  pins the reviewer model + effort in frontmatter (a typeless dispatch silently inherits the
  session model). Cold spawn, not fork — the reviewer must NOT inherit the authoring context.
- Give it: the diff, the governing contract/spec, the files' paths, and "report EVERYTHING you
  find; severity is the lead's filter, not yours". Never name which model authored the change —
  authorship framing is a measured bias vector.

**FOOTGUNS**
- Never write "only report high-severity" or "be conservative" — this model generation complies
  literally and under-reports. Ask for all; filter downstream.
- Fresh excludes the author's SESSION, never the author's FAMILY.
- A report file on disk is not completion — reviewers keep verifying and CORRECT their reports;
  the completion signal is the harness notification or the agent's final message.
- Pass every claim as challengeable; never tell a reviewer what is "already confirmed" — framing
  that narrows the search transplants your blind spot into the check.
- Reviewer prompts build from `audit-cycle/references/reviewer-prompt-template.md` (the lens
  doctrine: paste-evidence mandate, severity taxonomy, file:line bar). Rounds after the first:
  suppress new nits — Important findings only (convergence rule).
