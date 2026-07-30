---
name: to-tickets
description: >-
  Break an approved plan, a locked spec, or a settled conversation into tracer-bullet tickets on
  the project's issue tracker — vertical slices that each cut a complete path through every layer
  and are demoable alone, with native blocking edges declaring what gates what, and a durable
  agent-brief comment on every fully-specified ticket. Use when settled work needs to become
  board items ("file this as tickets", "break the plan into issues"), or at a spec handoff into
  build. Decomposes settled intent — unlike `wayfinder` (which settles it).
---

# To Tickets

Break settled work into **tickets** — tracer-bullet vertical slices, each declaring the tickets
that **block** it — published to the issue tracker so any session can pick up the frontier.

## Process

### 1. Gather context

Work from what's already in the conversation; if the source is a referenced artifact (spec path,
issue), read its full body — and its comments/history where the tracker has them — first.

**A wayfinder map is not a source.** A map hands off through its synthesis brief and the
project's design gate into a spec — decompose the SPEC, never the brief or the map.

### 2. Explore the code (if not already grounded)

Understand the current state of the surfaces the work touches; use the project's domain
vocabulary in every title and body. Look for prefactoring opportunities — "make the change easy,
then make the easy change" — and give any prefactoring its own early ticket.

### 3. Draft vertical slices

- Each slice cuts a narrow but COMPLETE path through every layer it needs (schema, logic,
  surface, tests) — vertical, never a horizontal slice of one layer.
- A completed slice is demoable or verifiable on its own.
- Each slice fits a single fresh implementer context.

**Wide refactors are the exception.** One mechanical change whose blast radius fans across the
codebase (a rename, a retype) can't land green as one slice — sequence it **expand–contract**:
expand (add the new form beside the old), migrate in batches sized by blast radius (each batch a
ticket blocked by the expand), contract (delete the old form, blocked by every batch). When even
the batches can't stay green alone, keep the sequence but let them share an integration branch
that all block a final integrate-and-verify ticket — green is promised only there.

### 4. Quiz the operator

Present the breakdown as a numbered list — per ticket: title, blocked-by, what it delivers
end-to-end. Ask: granularity right? Edges true — does each ticket depend only on what genuinely
gates it? Merge or split anything? Iterate until approved. **Publication waits for the
operator's approval of the breakdown.**

### 5. Publish, blockers-first

One issue per ticket, in dependency order (blockers first, so edges can reference real ids),
using the tracker's **native** blocking relation. Do not close or modify any parent/source
artifact beyond linking it.

Each fully-specified ticket gets an **agent brief as its first comment** — the durable contract a
future session builds from, written per [references/AGENT-BRIEF.md](references/AGENT-BRIEF.md):
behavioral not procedural, **no file paths or line numbers** (they go stale while the ticket
waits; describe interfaces, types, and contracts instead), concrete acceptance criteria, explicit
out-of-scope. The issue body stays the operator-facing summary; the brief comment carries the
machine contract. A ticket that still needs a decision before it's buildable gets no brief — it
gets the missing decision named in its body instead.

**Context is hottest now** — at decomposition time, with the plan fresh — and coldest weeks later
when a lane picks the ticket up. The brief comment freezes it at its peak; at dispatch time the
project's dispatch-brief discipline still runs, adding fresh code references on top of the
ticket's durable contract.

Work the **frontier**: any ticket whose blockers are all done.

### Ticket body shape

```markdown
<What this delivers, end-to-end, from the operator's/user's perspective — not layer-by-layer.>

**Blocked by:** <links, or "none — can start immediately">
**Source:** <the plan / spec / ruling this decomposes — never a map or its brief>
```

Avoid code snippets in bodies. Exception: a snippet from a prototype that encodes a decision more
precisely than prose (a schema, a state machine, a type shape) — inline the decision-rich part
and note its origin.
