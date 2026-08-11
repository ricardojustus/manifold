---
name: plan-update
description: >-
  Updates versioned design-intent plan docs when intent shifts — new milestone, architectural decision, findings folded in — bumping the revision + audit trail and syncing any paired plan-short. Use on "update the plan", "revise the X plan", "/plan-update". Intent, not what runs (reference-doc-writing).
---

# Plan update

Plan docs are living design-intent documents: versioned, carrying audit-trail lines, reflecting architectural decisions at the phase/milestone level. This skill updates them without losing design history or creating plan-vs-runtime drift.

**Which plan doc covers which scope is project-specific** — the project binding carries the current table (which plan owns system-wide sequencing, which owns a given subsystem, which are superseded). Confirm against the live plan set before editing rather than trusting a remembered mapping; a stale "which plan" table has sent edits to the wrong doc.

## When to update a plan

- A **new milestone or sub-phase** is added.
- An **architectural decision** is made at phase scope.
- A **blocking design issue** is discovered (flag it in place with a banner callout).
- **Empirical findings** contradict the plan's assumptions (integrate the findings, revise the assumptions).
- A **research pass returns** with implementation-detail findings (library picks, threat-model corrections).
- A **plan revision** is triggered by the operator's directive.

Do NOT update a plan for:
- A runtime bug fix — that's a commit message + the state snapshot.
- An implementation detail that doesn't change design intent — that's a current-state reference doc.
- A session-specific progress note — that's the state snapshot.

## The protocol

> Project bindings may prepend or amend steps — read the "## Project bindings" section (end of file) before the first step.

### 1. Read the existing section end-to-end

Before editing, read the relevant section fully — plan docs carry prior audit notes, decision rationale, and deferred items. Don't overwrite history you don't understand.

### 2. Make the edit in place

- **Additions**: add the new section or subsection. Include a dated note if substantive: `(added <DATE> — reason)`.
- **Changes to existing content**: edit in place, but preserve prior context if it's historically useful. Don't wholesale-rewrite a section that captured valid prior reasoning; substantive content removal carries an audit-trail note explaining why.
- **Claim only what the plan contains**: a plan claiming an obligation ANSWERED must carry the substance IN the plan — "carried to a named accountable event" is the honest label for everything else.
- **Findings land IN the section they affect**, not appended at the end. Append-only "Updates" sections bloat the doc and hide conflicts between old and new intent.
- **Blocking design issues**: use a banner callout at the top of the affected section:

```markdown
> **⚠️ OPEN DESIGN ISSUE — resolve before implementation** (flagged <DATE>):
>
> <description of the issue>
>
> **Resolution options** (decide before coding):
> 1. <option 1 with tradeoff>
> 2. <option 2 with tradeoff>
>
> Section below kept as originally written for design-intent context, but <the broken premise> does NOT hold until we pick an option above.
```

Use the banner whenever a section's premise is invalidated by new findings but the fix isn't yet committed.

### 2½. Keep the top summary true (required section)

Every plan doc carries a **top summary as its first section** — plain-language, skimmable,
in the operator's terms, jargon-free and concise; **assume many operators read only this
summary**. It must be self-sufficient: every load-bearing architectural choice and decision
visible there, surfaced plainly for an explicit yes/no, any necessary term paired with a
one-line explanation; renderable diagrams (Mermaid / clean indented lists), never ASCII art.
A plan without one gets it added at this update; an
update that changes design intent re-syncs it in the same pass — a stale top summary misleads
the exact reader the section exists for.

### 3. Bump the revision

Plan docs carry a status line with a revision, a date line, and an audit trail. On a substantive edit:

- **Bump `r<N>`** if the edit changes design intent (new milestone, architectural pivot, blocking-issue flag, major integration of findings).
- **Update the date line** with the revision date.
- **Extend the audit trail** with a brief description of the revision's scope.

Minor edits (typo, formatting) don't need a bump. Substantive edits do — skipping the bump loses audit-trail fidelity.

### 4. Don't cross streams (the genre split)

Plans describe design INTENT; current-state reference docs describe what's actually running. They're **allowed to disagree** — the **plan is right for direction**, the **reference doc is right for current state**. Don't "fix" either to match the other: one loses forward-looking intent, the other misrepresents current state. If the runtime has diverged in a way that suggests the plan was *wrong*, flag it with a banner, discuss with the operator, and decide which catches up to which.

### 5. Cross-reference the ripple

If the update affects other docs, name the ripple to the operator and update only what they confirm:

- The **state snapshot** if the next-session kickoff changes.
- **Reference docs** if a plan-defined invariant shifted.
- **Memory** if the update captures a settled decision worth persisting across sessions.

## Plan ↔ short-version pairing

Some projects author a **short/overview version** of a plan (an llms.txt-shaped digest read end-to-end at session start, whose section list maps 1:1 into the full plan's headings). A short is *authored, not auto-generated* — so this skill is the only thing keeping it in sync. **Where a plan has a short, editing one without reconciling the other is a violation** — update both in the same operation, keep their stamps in step, and preserve section-list parity (same headings, same order) if you added/removed/renamed/reordered a section. The **concrete sync mechanism (which plans have shorts, which stamps to bump, how anchors are derived) is project-specific — the project binding owns it.**

**Worked example** (integrating a research pass): library picks → a new subsection where they belong; a finding that invalidates a premise → a banner callout; implementation notes → the end of the sections they touch; then bump the revision with an audit-trail note ("research pass integrated + blocking-issue callout"). Each finding lands in the section it affects, never as a trailing appendix.

## Related

- `reference-doc-writing` — the current-state docs that plans are allowed to disagree with.
- `doc-placement` — deciding whether a doc is a plan at all, versus a spec / reference / research artifact.
- `session-end` — invokes this skill at session close if design intent shifted.
- `research` — produces findings that frequently trigger a plan update.
