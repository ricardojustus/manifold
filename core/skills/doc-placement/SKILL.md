---
name: doc-placement
description: >-
  Decides WHERE a doc belongs — routes an ADR, spec, reference doc, plan, or research spike to the correct folder by a first-match-wins genre rule; owns the spec-to-reference promotion checklist and relocation link-fixes. Use on "where does this go", "/doc-placement", when a spec ships, or when relocating a misfiled doc.
---

# Doc placement

A placement taxonomy + lifecycle. Only a subset of folders is indexed into the searchable corpus; everything else is on-disk-but-unsearchable, discoverable via the forward pointers a reference doc carries. **Which index the project uses, and which folders feed it, is project-specific — the binding names them.** Place by rule, not by habit.

## The taxonomy (folder → genre → searchable?)

| Folder | Genre | Indexed? | Contents |
|---|---|---|---|
| `reference/` | current-state | ✅ | current-state subsystem docs ("how X works now") |
| `plans/` (excl. shorts, archive) | plan | ✅ | durable design intent (full) |
| `plans/*-short.md` | plan-short | ✅ | authored short versions (llms.txt shape) |
| `plans/archive/` | plan / historical | ❌ | superseded plans (banner + pointer) |
| `specs/` | — | ❌ | **active** implementation contracts |
| `specs/archive/` | — | ❌ | **spent** (implemented) specs — provenance |
| `specs/adr/` | — | ❌ | architecture decision records ("why") |
| `research/` | — | ❌ | genuine exploration / spikes only |
| `audits/` | — | ❌ | audit artifacts |

(Whether a project indexes exactly `reference/` + live `plans/`, and by what mechanism, is in the binding. The *pattern* — a small genre-pure indexed set, everything else reachable via pointers — is universal.)

## Routing decision procedure — FIRST MATCH WINS

Run top-down; stop at the first match.

1. **Records a hard-to-reverse / future-constraining decision** (the "why" behind a choice future-you would otherwise re-litigate) → `specs/adr/` (an ADR — template below). Not indexed.
2. **An implementation contract** — has acceptance criteria + names an owning-reference target it will promote into → `specs/`. Not indexed.
3. **Documents observed *current runtime* behavior** ("how subsystem X works right now") → `reference/`. Indexed. Write via `reference-doc-writing`.
4. **Durable design *intent*** independent of any one implementation session ("what we decided to build and why, at the roadmap/subsystem level") → `plans/` (with an authored short). Indexed. Maintain via `plan-update`.
5. **Exploratory / not-yet-authoritative** (a spike, a prior-art survey, an investigation) → `research/`. Not indexed.

Tie-breakers:
- **Spec vs plan**: a spec is *ephemeral* — read end-to-end at implementation, then spent. A plan is *durable* — it generates specs and outlives them. Read-once-at-build → spec; standing intent → plan.
- **Spec vs reference**: a spec is a *contract for work not yet done*; a reference doc describes *what already runs*. On implementation, the spec's durable behavior **promotes** into a reference doc (close-out below).
- **ADR vs spec**: the ADR is the distilled *decision* ("we chose X over Y because…"); the spec is the *full contract*. A significant spec produces both.
- **research vs spec**: acceptance criteria + a build target → spec; still figuring out the shape → research.

## Spec → reference promotion (close-out checklist)

When a spec finishes implementation, this is **part of definition-of-done in the SAME implementing session** — not deferred doc-debt:

- **(a) Fold** the spec's durable behavior into the **owning subsystem's reference doc** (subsystem-shaped — a small spec becomes a *section* of a bigger doc, not its own doc). If no owning subsystem doc exists, **create it** (`reference-doc-writing`). Bump its as-of + its index row. Add the **forward pointer** (the reference doc is the only searchable surface, so it's the discovery path to the un-indexed provenance).
- **(b)** If the spec embodied an **architecturally-significant decision**, write an **ADR** (`specs/adr/`).
- **(c) Move** the spec → `specs/archive/` with an IMPLEMENTED banner back-linking the reference doc (+ ADR).

**Provenance schema** (a machine-checkable backstop) — every active spec NAMES its target at authoring time, so close-out is never undefined:
- Active spec header: `owning-reference: reference/<file>.md#<anchor>`.
- Archived spec banner: `reference: reference/<file>.md#<anchor>` (required) + `adr: specs/adr/<name>.md` (if written).
- Reference doc, in the promoted section: `<!-- provenance: spec specs/archive/<name>.md; adr specs/adr/<name>.md -->`.

The `session-end` freshness sweep flags an archived spec whose `reference:` link doesn't resolve or whose target lacks the matching `provenance:` back-pointer (pointer presence only; semantic coverage stays human-reviewed). Every spec reaching `specs/archive/` via this loop carries a resolving `reference:` pointer — that's the close-out contract. If a genuine future case can't promote (a spent spec whose owning subsystem is being decommissioned with no reference doc), amend the locked placement spec with a narrow, machine-readable exemption field rather than a broad text match.

## ADR template (Nygard, short)

```md
# ADR: <title>
**Status**: Proposed | Accepted | Superseded-by <adr>
**Date**: <YYYY-MM-DD>
## Context
## Decision
## Consequences
```

Write an ADR only for an **architecturally-significant** decision: one that (a) is hard to reverse, (b) constrains future design, or (c) future-you would otherwise re-litigate. Routine specs with no novel decision get none — else busywork.

## Relocation rules (moving a misfiled doc)

- Move a misfiled **spec** in `research/` → `specs/` (active) or `specs/archive/` (already implemented); ADRs → `specs/adr/`. Genuine research stays.
- **Link-fix, not bare `mv`**: for each moved file, rewrite inbound refs in **live/active** docs (the state snapshot, the doc index, constitution imports, active cross-refs in other plans/specs/reference) → verify zero broken links → update the affected index rows — atomically per file / small batch.
- **Never rewrite immutable history** — diary entries and dated decision files are append-only provenance; a stale path inside one is acceptable historical context, not a bug to fix.
- **Defer actively-referenced specs** — don't move a spec still in flight for its phase; it relocates when its phase closes.

## When NOT to use this

- Choosing *what* to write in a reference doc (structure/tone) → `reference-doc-writing`.
- Updating a plan + its short → `plan-update`.
- Running the freshness/promotion backstop sweep → `session-end`.

## Related

- `reference-doc-writing` — writes the reference doc the promotion folds into.
- `plan-update` — maintains plan + plan-short (strict dual-update).
- `session-end` — the freshness sweep that backstops promotion + short-vs-full sync.
