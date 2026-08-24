---
name: council
description: >-
  Convenes the Round Table — five independent reviewer seats (fresh strong-reasoning + cross-model) that give ranked OPINIONS on a vision, or a vision plus plan: what each would change, what worries it, what it would keep, plus a bounded fact-check of the artifact's load-bearing claims. Cost, size and risk calls route to the operator as decisions. Advisory only; reviews intent and design, never code quality (that is audit-cycle). Use on "convene the council", "round table", "council this vision", "/council".
---

# Council — the Round Table (an opinion consult)

Five reviewers with different lenses read a **vision** (or a **vision + plan**) and each returns a
ranked opinion. In round two they read each other and revise. The orchestrator folds it into one
page for the operator. The council has zero power: it edits nothing, locks nothing, forces no
loop-back. The operator disposes.

**Why this shape.** A vision has few checkable claims, so a graded defect-hunt fills its grammar
with invented problems (receipt: `councils/reference-rethink/gate-a/dispositions.md` — 26 items,
~5 real, the operator's H-64 order followed). What that run got right was one fact-check that
refuted a false "verified" claim. So: ranked opinions, a bounded fact-check lane, all five seats,
round two kept (operator ruling 18/08; the round-two measurement is in
`audits/h64-council-revamp/round-two-evidence.md`).

## When it runs

- **On the operator's word, at any time**, for any work the operator names.
- **On the orchestrator's proposal** at the end of the shaping step (whatever the host calls it:
  SHAPE, or Phase 3→4) for big work — a multi-day autonomous run, a vision resting on world-claims
  the orchestrator cannot check, or more than one reasonable design. **The orchestrator proposes
  and stops; dispatch begins only after the operator says yes.** The orchestrator never
  self-convenes, never proposes for small work, never proposes mid-run.
- Same shape with or without a plan. With a plan, the Systems Critic also asks whether the plan
  delivers the vision.

## Explicit inputs (never inferred)

- **artifacts** — current-state note + vision doc (always); plan doc (when one exists).
- **rulings block** — the operator's settled rulings that touch this work, quoted verbatim with
  their date, from the sources the binding names (prior sittings' `dispositions.md` first — that
  is where verbatim rulings live). Every listed ruling is **fixed ground** for the seats.
- **sanctioned-challenge list** — the rulings the operator reopened for THIS sitting, from any
  operator-controlled input (this session, the ticket, the shaping record) with its receipt.
  Empty is the normal case.
- **fact list** — the orchestrator's pre-selected list of the artifact's **load-bearing factual
  premises** that should be checkable now (claims about what the system does today, what exists,
  what a number is). Bounded: at most 10. Seats check these; a seat may add ONE premise it finds
  load-bearing. Vision propositions and future-state claims are not facts and never enter this list.
- **sitting** — a short slug for the record path (`s1`, `vision-r2`); a new slug per sitting.
- **round two** — ON by default. The orchestrator may propose skipping it for a thin vision-only
  document, with the price of the round; the operator decides.

## The five seats — all sit, every sitting (operator ruling 18/08)

| Seat | Default model class | Lens (one line) |
|---|---|---|
| **The Advocate** | strong-reasoning | The end user. Does this serve them? Where does the experience break? |
| **The Premise Skeptic** | strong-reasoning | Should we build this at all? Strongest case for a different approach or nothing? |
| **The Feasibility Skeptic** | cross-model | Buildable as described with this stack? Where is the hidden complexity? |
| **The Systems Critic** | cross-model | Does it hang together? What breaks downstream? With a plan: does the plan deliver the vision? |
| **The Proportionality Skeptic** | cross-model | The smallest design that meets the vision; what could be cut; what each addition costs. |

Mandates, common framing, and the composition recipe live in `references/seat-mandates.md` — the
composer reads that file. Cross-model seats come from a genuinely different model family. A seat
that cannot sit (refusal, saturation, empty result) is replaced by **its own** fresh seat with the
same mandate — the binding's fallback ladder names the order — and the replacement is written in
`dispatch-log.md`. Five mandates always sit.

## What a seat returns (the opinion object)

```
WHAT I WOULD CHANGE — up to 3, ranked by expected effect on what gets built
  n. the change · what in the artifact prompted it · why · what it costs the vision if ignored ·
     the strongest case against making it
WHAT WORRIES ME — up to 3, ranked the same way
  n. the worry · what prompted it · what would make it real · how we would know early ·
     the strongest case that it is not real
WHAT I WOULD KEEP — up to 1
  the strongest thing here, worth preserving; "none" if nothing merits it. If the top change is
  "do not build this", name what should survive into whatever replaces it.
CHECKABLE FACTS — the briefing's fact list (+ at most one premise you add)
  claim · VERIFIED / REFUTED / COULD-NOT-CHECK · evidence (file:line, command, record).
  Code is read only to test a listed premise, never to judge implementation quality.
DECISIONS FOR THE OPERATOR — every call that turns on the operator's cost, size, risk appetite,
  or scope posture: the question · the arithmetic (calls × tokens × recurrence, or dollars for
  metered use; expected and worst case; "unknown" stated as unknown) · your lean.
  A cheaper alternative DESIGN is a change; the posture call itself is a decision.
NEW EVIDENCE AGAINST A SETTLED RULING — optional; the ruling · the evidence · what changes if
  the operator reopens it. Not an opinion item; the ruling stays fixed for this sitting.
```

Every heading is present; an empty section says `None`. Ranking is by expected effect on whether
and what gets built. The object is written in plain language for the operator; a seat may mark one
cross-lens dependency when it is needed to explain its own item. Grades, scores, severity words,
and "finding" vocabulary do not appear — an object that carries them is a format violation (see
Run format, step 3a).

## Run format

> Project bindings may prepend or amend steps — read "## Project bindings" (end of file) first.

1. **Pre-flight.** `COUNCIL_DIR` = absolute `<artifact-root>/councils/<topic>/<sitting>` (the
   binding gives the root; a bare relative path resolves wrongly). `mkdir -p`. Write
   `briefing.md`: artifacts (absolute paths), rulings block, sanctioned-challenge list, fact list,
   whether a plan exists, round-two setting, and — when the plan carries a security-posture
   section — name it as a target (seats give an opinion in both directions: protection not
   earning its cost, a gap the posture does not cover; appetite calls still go to DECISIONS). If an
   artifact names its author, the briefing says to ignore that line. Compose
   `seat-<name>-round1-prompt.md` per seat per `references/seat-mandates.md`.
2. **Round one — all five seats, same turn, independent.** Each seat is dispatched with its
   composed prompt file **verbatim** (never a summary). Persist `seat-<name>-round1.md`.
3. **Round two — default ON.** Compose `seat-<name>-round2-prompt.md` = the seat's mandate + the
   round-two framing + the paths of **all five** round-one files (its own included). Every seat is
   re-dispatched **fresh** (a read-only seat's round-one job is terminal; a cold Claude seat has no
   memory) with its own watcher and timer. Each returns a **complete revised opinion object** in
   the same shape plus a short `RESPONSES TO OTHER SEATS` section (opinion + evidence, no labels).
   Persist `seat-<name>-round2.md`. The fold reads round-two objects (round-one when round two was
   skipped).
   - **3a. Shape gate, both rounds.** Before folding, assert five present, non-empty, well-formed
     objects. A missing, truncated, or graded/defect-shaped output is re-prompted once with the
     framing, then replaced by a fresh seat; it is never folded after stripping labels. Record in
     `dispatch-log.md`.
4. **Fold — the orchestrator writes `for-operator.md`** (the binding pins the concrete filename),
   in plain language for the operator, **at most ~60 lines** on the main page:
   - **Each seat's #1 change and #1 worry** — always, so a unique observation from a deliberately
     different seat is never lost.
   - **Where the seats converge** — items several seats named, each with its own evidence line;
     agreement is descriptive metadata and never strengthens an item. Ordered by expected effect on
     what gets built.
   - **Where they disagree** — both sides, one line each; never resolved by the orchestrator.
   - **Fact-check results** — every REFUTED premise first with evidence; then COULD-NOT-CHECK for
     listed premises only; conflicting verdicts on one premise are shown side by side.
   - **What should survive** — the keeps.
   - **Decisions for the operator** — each with arithmetic and the seats' leans.
   - **New evidence against a settled ruling** — the ruling · the evidence · which seat (empty is
     normal). **Set aside as relitigation** — one line naming items that reopened a listed ruling
     without new evidence (visible, never silently cut). The orchestrator judges "new evidence" and
     says so.
   - Pointer to the seat files as evidence on demand.
   The orchestrator's own lean appears only if the operator asks.
5. **Hand over.** The operator reads the page and disposes; the orchestrator records dispositions
   in `dispositions.md` and applies only what the operator ruled.

## Dispatch — parallel, same turn, every seat bounded

**Strong-reasoning seats**: cold-spawned subagents (not forks — no authoring context) with a
Write tool: `Agent({ subagent_type: "general-purpose", model: <binding pin>, run_in_background:
true, prompt: <the full text of seat-<name>-round1-prompt.md> })`; the prompt names the file the
seat writes. **Cross-model seats**: the project's read-only cross-model mechanism (the binding
names the command, watcher, extraction, and fallback ladder); a read-only seat returns the object
as its final answer and the orchestrator persists it. **Every background seat, both classes,
gets a watcher and a fallback timer armed in the dispatch turn** (named background spawns can die
silently). Completion = terminal status AND a non-empty, well-formed object; anything else →
step 3a. Job metadata is never persisted as an opinion.

## Output + authority

`COUNCIL_DIR` holds `briefing.md`, `seat-<name>-round1-prompt.md`, `seat-<name>-round1.md`,
`seat-<name>-round2-prompt.md` + `seat-<name>-round2.md` (when round two ran), `dispatch-log.md`,
`for-operator.md` (binding-named), `dispositions.md`. Advisory only: an opinion the operator does
not adopt is recorded as not adopted.

## Related

- `audit-cycle` — code against a locked spec; graded review lives there, including a
  security-sensitive surface or a whole-subsystem pass scoped to the round.
- `cross-model-advisor` — one peer consult, not a panel.
- `grilling` — a live interview with the operator; the council is a panel against a written artifact.

Fixtures: `references/test-prompts.md`.
