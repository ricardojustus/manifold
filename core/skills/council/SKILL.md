---
name: council
description: >-
  Convenes the Round Table — a fresh panel of strong-reasoning and cross-model adversarial seats that challenges a Vision, or Vision plus Plan, and returns one severity-rated findings list. Advisory only; reviews intent and design, never code (that is audit-cycle). Use on "convene the council", "round table", "run Gate A", "Phase 5 council", "/council".
---

# Council — the Round Table

Fresh adversarial scrutiny of a **Vision** (Gate A) or **Vision + Plan** (Phase 5) from genuinely
different mandates — including one seat whose only mandate is that the design isn't oversized —
then ONE consolidated findings list handed to the Orchestrator. Mirrors `audit-cycle`'s
cross-model dispatch (parallel strong-reasoning subagents + a cross-model reviewer with
completion-watchers), but the subject is **intent/design**, not code.

Authority: `.claude/harness/METHODOLOGY.md` (Roles, The Round Table, Project stakes) is the WHY;
this skill is the HOW.

## When to invoke

**In scope:**
- **Gate A** — vision-only challenge before planning effort is sunk (required at High stakes,
  optional at Medium).
- **Phase 5** — Vision + Plan adversarial review before the Lock.
- "Convene the council" / "round table" / "Gate A" / "Phase 5 council" / "/council".

**Out of scope**: per-artifact pre-merge code/spec gate → `audit-cycle` · scoped adversarial pass
on a security-sensitive surface → `scoped-adversarial-audit` · whole-subsystem inventory →
`system-audit`. The Council does NOT review a diff, an implementation, or a single spec; if
there's code to gate, it's `audit-cycle`.

## Explicit inputs (the skill does NOT infer these)

- **phase** — `gate-a` (Vision only) or `phase-5` (Vision + Plan).
- **stakes** — `low` / `medium` / `high` (scored on the methodology rubric; the Orchestrator
  passes it, the Council does not score it). Drives seat count.
- **artifacts** — `current-state note` + `Vision Doc` (always); `Plan Doc` (Phase 5 only).
- **topic** — short slug for the session record path.

At `gate-a` with no Plan the skill **degrades cleanly**: no plan-targeted findings, and the
under-tagging check is skipped (there's no plan to tag).

## Council size by stakes

| stakes | seats |
|---|---|
| **low** | **Skip** — Low builds take the express lane, which drops the Council (human review suffices). Convene only if the operator *explicitly* asks for an out-of-method advisory pass. |
| **medium** | 3 seats — default **Premise Skeptic (strong-reasoning) + Systems Critic (cross-model) + Proportionality Skeptic (cross-model)** (premise + coherence are highest-leverage; proportionality always sits). Full panel at Orchestrator discretion. |
| **high** | Full 5-seat Round Table: 2 strong-reasoning + 3 cross-model (the Proportionality Skeptic standing). |

**The Proportionality Skeptic sits at EVERY sitting, both phases, all stakes where a council
convenes** — a standing seat, never stakes-scaled and never folded into another seat (a
proportionality mandate embedded in a broader charter silently drops). At Gate A its pricing check
degrades gracefully: with no plan constants yet, "price it" becomes a named plan-phase obligation;
the classification challenge and simplest-design/measured-size questions run in full.

**And it runs LAST — a second stage, after every other seat has finished.** The other seats' bias
is structurally ADDITIVE (skeptics find missing safeguards, critics find missing coverage), so a
parallel proportionality seat reviews only the original artifact while the others pile on
unpriced additions. It therefore receives the artifact **plus every other seat's findings**, with
a dual target: (a) the design itself, unchanged; (b) **every additive finding from the other seats
gets its own verdict — `endorse` / `demote` / `price` — with plain-language reasoning**. Accepted
trade: the other seats cannot cross-examine its verdicts; both sides of any disagreement reach the
Human in the consolidated list, and the Human is the disposition anyway.

**At Gate A (vision-only), the cross-model default alongside it is the Feasibility Skeptic, not the
Systems Critic** — the Systems Critic's mandate (plan delivery + risk-tag honesty) is gutted with
no Plan to critique.

## The five seats

Diversity of *mandate* beats raw model count — identical prompts yield one shared blind spot, so
each seat is briefed through its own mandate (full text in `references/seat-mandates.md`).

| Seat | Default model class | Mandate (one line) |
|---|---|---|
| **The Advocate** | strong-reasoning | The end user / player. Does this serve and delight them? Where does the experience break? |
| **The Premise Skeptic** | strong-reasoning | First-principles attack on the core premise. Should we build this at all? Strongest case for a different approach or doing nothing? |
| **The Feasibility Skeptic** | cross-model | Technical + resource realism. Buildable with the stack/constraints/timeline? Where's the hidden complexity? |
| **The Systems Critic** | cross-model | Coherence + second-order effects. Does the Plan deliver the Vision (acceptance criteria AND vision-mandated deliverables)? Dependencies/ordering/architecture sound? What breaks at scale? **Are chunks honestly risk-tagged, or under-tagged to earn an easier audit floor?** |
| **The Proportionality Skeptic** | cross-model (standing, every sitting) | Overengineering + YAGNI + cost. Price the design (tiers; "cannot price" blocks at Phase 5); challenge the blast-radius classification against the written recovery story; the six standing questions; findings name concrete deletions. |

Model-to-seat mapping is the default, not a law — the Orchestrator may remap (e.g. a saturated
cross-model provider → a third strong-reasoning seat). **Cross-model is the point**: the two
cross-model seats come from a genuinely different family than the primary reasoner, because a
second instance of the same model shares the first's blind spots.

## Run format

1. **Pre-flight.** Set `COUNCIL_DIR` to the ONE session dir every step uses — an **absolute** path
   under the artifact root, `<artifact-root>/councils/<topic>/<phase>` (a bare relative
   `councils/…` would wrongly resolve under the orchestrator's cwd; the binding gives the concrete
   root). `mkdir -p "$COUNCIL_DIR"`. Write `$COUNCIL_DIR/briefing.md` (artifacts + phase + stakes +
   topic). Compose each seat's prompt from `references/seat-mandates.md` + the briefing into
   `$COUNCIL_DIR/seat-<name>-prompt.md` — **one tailored prompt per seat, never a shared prompt**.
2. **Independent first pass — dispatch all seats EXCEPT the Proportionality Skeptic in the SAME
   turn** (see Dispatch). Each seat produces findings WITHOUT seeing any other seat's. Every
   finding carries `assumptions`, `confidence`, and a `steelman` (the strongest counter the seat
   can make to its own finding).
3. **Cross-examine — default 1 round, 0 for cheap sittings.** Give each first-pass seat the other
   seats' pass-1 findings; each may challenge, concede, or sharpen. Write `seat-<name>-pass2.md`.
   The Orchestrator may set 0 rounds at Low/Medium to favor speed + maximal independence.
4. **Proportionality stage — the standing seat runs now, alone.** Compose its prompt from its
   mandate + the briefing + **all other seats' final findings** (pass-2 where cross-exam ran, else
   pass-1). It reviews the design AND verdicts every additive finding
   (`endorse`/`demote`/`price` + plain-language reasoning) per its mandate. Write
   `seat-proportionality-pass1.md`. Same dispatch mechanics + completion guard as any cross-model
   seat.
5. **Consolidate** all findings into one list, **MAX-severity** when two seats raise the same issue
   (mirror `audit-cycle`). Dedup by `(target, claim-class)`. **Each additive finding carries its
   proportionality verdict inline** ("Systems Critic proposes X — Proportionality: demote, because
   Y"); a disagreement between a seat and the Proportionality verdict is surfaced as-is, both
   sides, never resolved by the Orchestrator.
6. **Hand to the Orchestrator.** Write the session record (below). The Orchestrator + Human
   disposition; the Council does not.

## Dispatch — parallel, all first-pass seats same turn

(Mirrors `audit-cycle`; the Proportionality Skeptic dispatches later, in its own stage.)

**Strong-reasoning seats** (subagents with a Write tool):
```
Agent({
  subagent_type: "general-purpose",
  run_in_background: true,
  prompt: "You are <SEAT>. Read $COUNCIL_DIR/briefing.md + the named artifacts (absolute paths). Execute your mandate from <the seat-mandate text>. Write findings (schema below) to $COUNCIL_DIR/seat-<name>-pass1.md."
})
```
(The project binding pins the concrete model for these seats.)

**Cross-model seats** — dispatched through the project's **independent cross-model reviewer**
mechanism, **READ-ONLY**. A read-only seat CANNOT write files, so its mandate is to **return
findings as its final answer**; the Orchestrator persists them after the completion guard. The
concrete dispatch command, completion-watcher, and result-extraction are project-specific — **the
binding names them and ships the `scripts/`**. Two invariants the core enforces regardless of
mechanism:

- **Pair EACH cross-model seat with its own completion-watcher.** These seats typically don't
  auto-notify like a subagent does; skipping the watcher means consolidating on a half-finished
  panel. Two cross-model seats = two independent watchers, each tracking its own job.
- **Completion guard before accepting a seat**: require a terminal *completed* status AND a
  non-empty result. Failed/empty → **never write failed-job metadata as findings**: re-launch the
  seat, or remap it (cross-model seat → a third strong-reasoning seat) and note the remap in the
  session record.

## Findings schema

Every finding (mirror `audit-cycle` severity vocabulary — C / H / M / L):
```
{ severity: C|H|M|L, target: vision|plan, claim, assumptions, confidence, steelman, suggested_disposition }
```
`suggested_disposition` ∈ { re-open, waiver, refine-in-place, **abandon** } — a *suggestion only*.
The real disposition is the Orchestrator + Human's call, never the Council's.

## Output + authority

Write to `$COUNCIL_DIR` (= `<artifact-root>/councils/<topic>/<phase>/`):
- `briefing.md`, `seat-<name>-pass1.md` (×seats), `seat-<name>-pass2.md` (if cross-exam ran)
- **`consolidated-findings.md`** — per-seat summary table (seat × C/H/M/L), the MAX-severity
  merged list, and for each finding its `assumptions / confidence / steelman /
  suggested_disposition`.

This is one Evidence Store with `audit-cycle`'s — same schema/severity/disposition vocabulary,
parallel sub-tree (`councils/` vs `audits/`). **The Council is advisory: zero power to edit an
artifact, lock, or loop back.** A brilliant Council argument the Human rejects is simply a logged,
waived finding.

## Anti-patterns (don't regress)

1. **Shared prompt across seats** — defeats the whole design; brief each seat through its own
   mandate.
2. **First-pass seats seeing each other before the first pass** — independence is the point;
   cross-exam is a *separate, later* round. (The Proportionality Skeptic is the deliberate
   exception: it runs LAST and sees everything — that's its job, not a leak.)
3. **Skipping a cross-model seat's completion-watcher** — it doesn't auto-notify; you'll
   consolidate on a half-finished panel.
4. **The Council deciding** — it advises. Re-open / waiver / refine / abandon are Orchestrator +
   Human calls.
5. **Using it as a code audit** — no diffs, no impl, no single spec. That's `audit-cycle`.
6. **Convening it on the Council itself or on a lone Low-stakes item** — below the methodology
   threshold (express lane); don't council the council.
7. **Inventing findings without grounding** — a feasibility/coherence claim cites the artifact line
   or the repo reality it rests on (seats can read the current-state note + repo).

## Related skills

- `audit-cycle` — per-artifact pre-merge code/spec gate (the dispatch shape this skill mirrors).
- `scoped-adversarial-audit` — scoped adversarial single-pass on security-sensitive surface.
- `phase-start` / `.claude/harness/METHODOLOGY.md` — where the Council sits in the loop.

Skill-eval test prompts: `references/test-prompts.md`.
