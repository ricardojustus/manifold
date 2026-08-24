---
name: wayfinder
description: >-
  Plan a big foggy effort — more decisions than one conversation can hold, the route to the
  destination not yet visible — as a shared map on the project's issue tracker (or plain files
  where the project has none): child decision tickets with native blocking edges, resolved one
  at a time until the way is clear. Use when an
  effort fails the one-sitting test ("depends on X, which depends on Y"), when the operator asks to
  chart a map, or when a `grilling` session keeps surfacing questions it cannot settle. NOT for a
  well-scoped feature — that routes `grilling` → spec. Hands off to authoring the contract's
  definition of done (`contract-template.md`) when the fog clears; `grilling`, `research`, and
  `prototype` resolve its tickets.
---

# Wayfinder

A loose idea has arrived — too big for one session, and wrapped in fog: the way from here to the
**destination** isn't visible yet. Wayfinding charts that way as a **shared map** on the issue
tracker, then works the map's **decision tickets** — questions whose resolution is a decision, not
build work to execute — one at a time until nothing is left to decide before someone goes and
builds the thing.

**Plan, don't do.** Every ticket resolves a decision; the pull to just start building is usually
the signal the map's edge has been reached and it's time to hand off. The map produces decisions,
not deliverables.

## When (the fog test)

Route by fog, not size — can the open decisions be *phrased* now, and settled in one sitting?

1. **Route already visible** → just do it (spec + review ladder where the project's gates require).
2. **Decisions exist but fit one sitting** → `grilling` → spec. Most features. No map.
3. **Multi-session, decisions blocking decisions, route invisible** → a map.

The boundary self-corrects both ways: a grill that keeps hitting "depends on X, which depends on
Y" promotes to a map mid-flight; a charting session that surfaces no fog aborts to a plain spec —
if the whole journey fits one session, you don't need a map. Stop and say so.

## The map

One issue on the tracker — the canonical artifact. Tickets are its child issues. Body, five
sections:

```markdown
## Destination
<what reaching the end looks like — the spec, decision, or change this effort walks toward.
One or two lines; every session orients to it before choosing a ticket.>

## Notes
<domain; skills every session should consult; standing operator preferences for this effort>

## Decisions so far
<!-- the index — one line per closed ticket: title-as-link + one-line gist of the answer.
The detail lives in the ticket; the map never restates it. -->

## Not yet specified
<!-- the fog of war: in-scope questions not yet phrasable sharply. Graduates to tickets as
the frontier advances. -->

## Out of scope
<!-- work consciously ruled beyond the destination; closed, never graduates -->
```

**Refer by name.** In everything the operator reads — narration, the index — a ticket is its
title (wrapping its link), never a bare id. A wall of `#42, #43` is illegible.

## Tickets

Each ticket is a child issue; its body is the **question** it resolves. Blocking uses the
tracker's **native** dependency relationship, so the tracker itself can answer for the
**frontier** — the open, unblocked, unclaimed tickets: what is answerable *right now*. A session
claims a ticket (assigns itself) before working it, so concurrent sessions skip it.

**No tracker?** A project without an issue tracker still gets a map, as plain files: a folder
(`maps/<effort-slug>/` under the project's docs root, unless the binding names another home)
holding `map.md` (the same map body) plus one file per ticket — `NN-<slug>.md` carrying
the question, a `Type:` line, a `Blocked by:` line naming the gating ticket files, and a
`Status: open | claimed | closed` line, with the resolution appended on close. Blocking is body
text, the frontier is found by reading, claiming is the `Status:` edit — strictly weaker than a
real tracker (no native blocking view; nothing the operator sees without opening files), so say
so at charting, and when the project earns a real tracker, migrate the OPEN tickets and keep the
folder as the archive.

Every ticket carries a type — **HITL** (worked live with the operator, who speaks for themselves;
an agent never answers the operator's side) or **AFK** (agent-driven alone):

- **Grilling** (HITL, the default) — resolved by a `grilling` pass: one frontier round per
  message, the operator rules.
- **Research** (AFK) — a fact outside the working tree that a decision waits on; resolved by a
  `research` dispatch, findings linked from the ticket.
- **Prototype** (HITL) — "how should it look / feel / behave" questions that die in prose;
  resolved via the `prototype` skill: a cheap throwaway artifact the operator reacts to. The
  reaction is the decision; the artifact is linked, never merged.
- **Task** (HITL or AFK) — grunt work that must happen before a decision is even possible
  (provision access, move data so its shape can be seen). The one type that *does* rather than
  decides — it earns its place by unblocking a decision.

## Charting (one session, once)

1. **Name the destination** — a `grilling` pass pins what this map walks toward. The destination
   fixes the scope; it's settled first.
2. **Map the frontier** — grill again, **breadth-first**: fan across the whole space surfacing
   open decisions, rather than deep on one thread. No fog surfaced → abort per the fog test.
3. **Absorb pre-existing tracker items** covering this territory — three buckets, dispositioned
   visibly, never silently: decision-shaped → re-parent as a child ticket (history kept);
   build-shaped → stays a work item, gains a blocked-by edge from the decisions that gate it;
   superseded → closes into the map with a pointer.
4. **Create the map, then the tickets you can phrase now**; wire blocking edges in a second pass
   (issues need ids before they can reference each other). Everything not yet phrasable stays in
   **Not yet specified**.
5. **Fire the research tickets** as dispatches in parallel — they need no operator time.
6. Stop. Charting hand-resolves nothing.

## Working the map

1. Load the **map body only** — destination + index, not every ticket.
2. Pick the ticket: the operator's named one, else the first frontier ticket. **Claim it.**
3. Resolve by type. Zoom on demand — fetch any closed ticket's detail when the current question
   leans on it.
4. Record at the event: the answer as a **resolution comment** on the ticket · close it · append
   the one-line gist to **Decisions so far** · file the decision to the project's memory store.
5. Ripple: graduate any fog the answer sharpened into new tickets (create, then wire edges);
   update or close tickets the answer invalidated; a ticket revealed to sit past the destination
   closes into **Out of scope** — a scope boundary, not a step on the route.

A resolved decision stays reversible while the map lives **and it has not yet been absorbed into
a locked artifact**: reopening is a new operator ruling, a new resolution, an updated index
line — no amendment ceremony. Once a slice has locked (partial handoff below), reopening any
decision inside it runs the project's amendment process — the map cannot reach into a locked
spec. **Where the project owes a decision packet — reserved-authority and security-posture
calls — the ticket produces the packet; the packet's ruling resolves the ticket.**

## Completion and handoff

The map is done when no open tickets remain and **Not yet specified** is empty — the way is
clear. Then:

1. **Draft the synthesis brief** — one to two pages weaving every load-bearing decision into one
   coherent narrative (destination, the shape that emerged, the index linked as receipts).
   Drafting it is itself the coherence check: decisions made one at a time can be locally right
   and globally contradictory, and the contradiction surfaces in the writing.
2. **The adversarial design gate challenges the brief with the map behind it** (where the
   project's methodology convenes a council/design review, this is its slot for map-fed efforts).
3. The surviving brief becomes the **spec's intent front-matter** — authoring against the
   contract's definition of done (`contract-template.md`) proceeds from it into the project's
   normal lock cycle. The brief is not a standing artifact of its own.

**The commitment gradient**: fluid ledger (the map — never locks, closes as the archive of how
we got there) → challenged narrative (the brief) → LOCKED contract (the spec, exactly as the
project's enforcement already defines). **Partial handoff is sanctioned**: a slice settled early
can carve out to its own spec and lock while the map keeps working the rest.

After the build, durable architecture lands in the project's reference docs as usual — the map's
closed archive and the memory store hold the why-chain.
