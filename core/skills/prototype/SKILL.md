---
name: prototype
description: >-
  Build a throwaway prototype to answer a design question the operator must react to rather than
  reason about. Use when the question is "does this logic / state model feel right?" (a tiny
  interactive terminal app driving the state by hand) or "what should this look like?" (several
  radically different UI variations switchable on one route), when a wayfinder prototype ticket
  fires, or when a design argument keeps going in circles on paper. The answer is the deliverable;
  the code is scaffolding — kept as a receipt on a scrap branch, never merged.
---

# Prototype

A prototype is **throwaway code that answers a question**. The question decides the shape.

## Pick a branch

Identify which question is being answered — from the operator's prompt, the surrounding code, or
by asking if they're around:

- **"Does this logic / state model feel right?"** → [references/LOGIC.md](references/LOGIC.md).
  A tiny interactive terminal app that pushes the state machine through cases that are hard to
  reason about on paper.
- **"What should this look like?"** → [references/UI.md](references/UI.md). Several radically
  different UI variations on a single route, switchable via a URL param and a floating bottom
  bar.

The two branches produce very different artifacts — getting this wrong wastes the whole
prototype. Genuinely ambiguous and the operator unreachable → default to whichever branch matches
the surrounding code (a backend module → logic; a page or component → UI) and state the
assumption at the top of the prototype.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Locate the prototype close to where it
   will be used so context is obvious, named so a casual reader sees it's a prototype, not
   production. Obey the project's existing routing/layout conventions; don't invent new top-level
   structure.
2. **One command to run**, via the project's existing task runner. The operator must be able to
   start it without thinking.
3. **No persistence by default.** State lives in memory — persistence is usually the thing being
   *checked*, not a dependency. If the question explicitly involves a database, hit a scratch
   store with a clear "PROTOTYPE — wipe me" name.
4. **Skip the polish.** No tests, no error handling beyond runnable, no abstractions. The point
   is to learn something fast.
5. **Surface the state.** After every action (logic) or on every variant switch (UI), show the
   full relevant state so the operator sees what changed.
6. **The operator drives; their reaction is the answer.** The interesting moments are "wait, that
   shouldn't be possible" and "I want the header from B with the sidebar from C" — bugs in the
   *idea*, which is the whole point. Add actions/variants on request; prototypes evolve.
7. **Capture when done.** Fold the validated decision into the real work (a wayfinder ticket
   resolution, a spec decision, the real build); park the prototype itself as the receipt on a
   **scrap branch** the project's git contract allows — out of main, never merged — with a
   pointer from the ticket or record it answered. The main branch keeps only the validated
   decision. Where the project has a visual-delivery rule (the operator must be shown verified
   renders), it applies to the prototype's handover like any other visual surface — the binding
   names the mechanics.
