---
name: reference-doc-writing
description: >-
  Writes a current-state reference doc for a subsystem (module map, flows, invariants, log surface, debugging recipe), only once it has stabilized, and folds an implemented spec in at close-out. Use on "write the reference doc", "document this subsystem", "/reference-doc-writing". What runs NOW, not intent (plan-update).
---

# Reference doc writing

A current-state reference doc describes **what's actually running, right now**, as a stable lookup surface for future-you debugging or a future agent onboarding. Different genre from plan docs (design intent) and lesson files (hard-won lessons). The shape below is validated across subsystems — replicate it. (The project binding names the concrete example docs to read for shape, plus the doc-index/registry the project uses.)

## Diátaxis context

Diátaxis (https://diataxis.fr) splits technical docs into four genres: **Tutorial** (learn by doing / study), **How-to guide** (solve a specific problem / work), **Reference** (look up facts / work), **Explanation** (understand concepts / study).

This skill is the **reference** genre: information-oriented, precise, structured for lookup (not narrative). A step-by-step walkthrough (tutorial) or concept deep-dive (explanation) is a different genre with a different home — it doesn't go in the current-state reference corpus.

## The tier-by-stability rule

- **Working docs** — write per subsystem as it ships. Informal, may capture in-flight state, expected to evolve.
- **Reference docs** — write when a subsystem stabilizes (roughly a month-plus of no substantial rewrites). Canonical, authoritative, shouldn't need frequent updates after publication.

Don't preemptively write a reference doc for something still in flux — it goes stale faster than you can update it and misrepresents current state as stable.

Signals a subsystem is ready: shipped to production; survived at least one incident without architectural rework; a couple of weeks without substantial change; you're being asked the same debugging questions repeatedly.

## Spec → reference promotion (close-out)

A second, event-triggered reason to write/update a reference doc — independent of the tier clock: **when a spec finishes implementation, its durable behavior promotes into a reference doc as part of definition-of-done, in the SAME implementing session** (not deferred doc-debt). Procedure (full taxonomy in `doc-placement`):

- **Fold the spec's durable behavior into the OWNING SUBSYSTEM's reference doc — subsystem-shaped, not spec-shaped.** A small spec becomes a *section* of a bigger subsystem's doc; it does NOT get its own reference doc per spec.
- **If no owning subsystem doc exists yet, CREATE it** (canonical structure below). Every active spec should name its owning-reference target at authoring time, so the fold target is never undefined at close-out.
- **Add the forward pointer.** The reference doc is the only *searchable* surface, so it's the discovery path to the un-indexed provenance — add, in the promoted section: `<!-- provenance: spec <archived-spec-path>; adr <adr-path> -->` (drop the `adr` clause if none was written).
- **Bump the as-of + register the doc** (Process below), then archive the spec + write an ADR if the decision was architecturally significant — those two steps belong to `doc-placement`; this skill owns the reference-doc half.

This does NOT conflict with the tier rule: that rule bars *preemptive* docs (unshipped design that will churn). An *implemented* spec has shipped, so it IS current state — fold it in this session, scoping the section to what shipped plus an honest "not yet in scope" for the rest. If you can't write a coherent subsystem-shaped section for it, the spec isn't actually done — resolve that, don't defer the promotion.

## The canonical section structure

Every reference doc has most of these sections. Order matters — follow it.

### 1. Header

```markdown
# <Subsystem> — System Reference

**As of**: <YYYY-MM-DD> (post-<event or shipment>, commits `<hash1>` / `<hash2>`)
**Code**: `<source path>`
**Config**: `<config path>`
**State root**: `<state path>`

<One paragraph: what this is + why it exists.>
```

The **"As of"** stamp is load-bearing — reference docs go stale, and the stamp tells the reader when to trust it. Bump it when the content is reviewed-current, even if little changed.

### 2. Module map

A table of files/modules + their responsibilities. Every file in scope, one line each. Plus a sentence on dependency flow ("no circular imports; bottom-up: logging → schemas → state → delivery → runner → index").

### 3. Boot / fire / flow diagrams

ASCII flow diagrams for significant execution paths — dense, grep-friendly, and they survive markdown renderers better than prose:

```
launch → entrypoint
  ├─ init sandbox
  ├─ init integrations
  ├─ start workers
  │    ├─ load config
  │    ├─ start watcher
```

### 4. Invariants guaranteed by the system

What the platform guarantees as a contract — the "if you violate these, it's our bug" list, e.g. *Atomic state writes: rename-based — no half-written files on crash* · *No read-modify-write races: a per-path lock serializes reads+modifies+writes* · *No silent success lies: success state is set only when the underlying action succeeded.*

Debugging starts with "which invariant did we violate?" — so they must be complete + accurate.

### 5. Extension points

Split into **no code change required** vs **requires code change**. The first tells extenders what they can do; the second tells maintainers what to refactor to extend. Tables for both.

### 6. Log surface

What events fire, what error classes surface, how to grep the logs — the debugging lifeline. Table of event kinds (kind / source / when) + a list of error events.

### 7. Debugging recipe

A concrete procedure for diagnosing a failure — turns the doc from lookup reference into a runbook:

```markdown
1. Find the event: `grep '<kind>' <log> | grep <id> | tail -5`
2. Grab its correlation id from the JSON
3. Filter all related events: `grep '<correlation-id>' <log>`
4. State files: `<state-path>/<id>/latest.json`
```

Include it when the subsystem has a non-trivial failure surface.

### 8. What's NOT in this layer (deferred, non-blocking)

What the subsystem explicitly does NOT handle, so extenders + debuggers don't assume it does. List them, then a one-line "none of these block <the next thing>".

### 9. Pointers

Cross-references to other docs + canonical source files (the audit with the severity matrix, the config schema source of truth, the plan).

## Tone + voice

- **Factual, not conversational.** "Atomic state writes — rename-based, no half-written files on crash", not "you might want to note that...".
- **Imperative for procedures** ("Filter all related events: `grep ...`"); passive is fine for state descriptions.
- **No sales language.** Don't tell the reader how well-designed the system is; show it via the module map + invariants.
- **Concrete over abstract.** Real command names, file paths, event kinds, config keys.
- **Ironclad about current state.** If the doc says something's implemented, it IS. No "we'll add this later" inside a reference doc — that goes in "What's NOT in this layer" or in the plan.

## Length

No fixed limit; these land roughly 150–250 lines each. Under ~150 feels thin for a non-trivial subsystem; over ~400 suggests you're covering multiple subsystems (split) or drifting into explanation/tutorial territory (wrong genre).

## LLM-friendly authoring (for retrieval)

If the project indexes its reference corpus for retrieval, docs get chunked on headers and retrieved section-by-section. Author so a single retrieved section is useful **standalone**:

- **One subsystem per doc.** Mixing subsystems fragments retrieval + breaks a one-row-per-subsystem index mapping.
- **Each `##`/`###` section answers ONE "how does X work" question, self-contained.** Don't write "as described above" / "see the previous section" — restate the anchor or link it.
- **Stable, descriptive headings.** The heading text becomes the chunk's anchor; renaming it breaks inbound `path#anchor` citations. Prefer "Boot sequence", "Write scope" over "Details" / "Notes". Name headings to last.
- **Structured over prose.** Tables, code blocks, and explicit pattern lists retrieve + parse better than narrative paragraphs.
- **Cite source concretely.** `file:line` / exact symbol / event-kind names ground the retrieval.

## Process

1. **Confirm stability** — apply the tier rule. If not ready, write a working doc or a lesson instead.
2. **Inventory the code** — every file in scope, every event kind, every extension point. A reference doc can only describe what EXISTS; discover it systematically before writing.
3. **Draft in canonical order** — header → module map → flows → invariants → extension points → log surface → debugging → NOT in scope → pointers. Don't invent new sections until the canonical ones are filled (or you've decided one doesn't apply).
4. **Stamp with "As of"** — date + the commits that define the current state.
5. **Register the doc in the project's doc index — SAME SESSION.** If the project maintains a doc index/registry that drives a freshness sweep, add or refresh the doc's row (id, genre, path, the source paths it describes, as-of). A new/changed reference doc that isn't in the index is invisible to the freshness sweep. (Concrete index + fields: the project binding.)
6. **Commit** with a message explaining what's now documented.
7. **Let the freshness sweep handle review reminders** — once the row exists with source paths + as-of, the drift detector flags it automatically when its source changes.

## Genre purity — only current-state docs in the reference corpus

The reference corpus is the project's current-state ground truth (and, if indexed, its retrieval corpus), so it must stay genre-pure: only current-state reference docs + the index + a README. A genre violation there becomes retrieval poison. Other genres: audit reports → the audits directory; explanations / concept deep-dives → the lessons store or inline in a plan's rationale; working docs → the workspace. (See `doc-placement`.)

## Related

- `doc-placement` — the placement taxonomy + the full spec→reference promotion close-out (this skill owns the reference-doc half; doc-placement owns archive + ADR).
- `plan-update` — design-intent docs (different role, different truth).
- `system-audit` — its inventory pass often produces the first draft of a subsystem's reference doc.
- `session-end` — the freshness/promotion sweep that backstops this skill.
