# Deep-module vocabulary — the shared design language

One consistent language for designing or restructuring code. Use these terms exactly — not
"component", "service", "API", or "boundary" — so design conversations, briefs, and reviews mean
the same thing by the same word. The aim: **leverage** for callers, **locality** for maintainers,
**testability** for everyone.

## The terms

- **Module** — anything with an interface and an implementation. Deliberately scale-agnostic: a
  function, a class, a package, a tier-spanning slice.
- **Interface** — EVERYTHING a caller must know to use the module correctly: the type signature,
  plus invariants, ordering constraints, error modes, required configuration, performance
  characteristics. (The type-level surface alone is the narrow reading — don't use "interface" to
  mean only that.)
- **Implementation** — what's inside the module.
- **Depth** — leverage at the interface: how much behaviour a caller (or test) can exercise per
  unit of interface learned. **Deep** = a lot of behaviour behind a small interface; **shallow** =
  an interface nearly as complex as the implementation it fronts.
- **Seam** — a place where behaviour can be altered without editing in that place; the LOCATION
  where a module's interface lives. Where the seam goes is its own design decision, distinct from
  what sits behind it.
- **Adapter** — a concrete thing satisfying an interface at a seam. Describes ROLE (what slot it
  fills), not substance. A thing can be a small adapter with a large implementation (a real DB
  repo) or a large adapter with a small implementation (an in-memory fake).
- **Leverage** — what callers get from depth: one implementation pays back across N call sites
  and M tests.
- **Locality** — what maintainers get from depth: change, bugs, knowledge, and verification
  concentrate in one place. Fix once, fixed everywhere.

## The judgment calls

- **Depth is a property of the interface, not the implementation.** A deep module may be
  internally composed of small swappable parts — they just aren't part of the interface. Internal
  seams (private, used by the module's own tests) can coexist with the external seam.
- **The deletion test.** Imagine deleting the module. Complexity vanishes → it was a
  pass-through. Complexity reappears across N callers → it was earning its keep.
- **The interface is the test surface.** Callers and tests cross the SAME seam; wanting to test
  past the interface means the module is probably the wrong shape.
- **One adapter = a hypothetical seam. Two adapters = a real one.** Don't introduce a seam until
  something actually varies across it.
- **Design for testability at the interface**: accept dependencies rather than creating them
  inside; return results rather than producing side effects; keep the surface small (fewer
  methods = fewer tests; fewer params = simpler setup).

## When to reach for this

Designing or reviewing a module's interface, deciding where a seam goes, making code testable,
or any conversation that keeps saying "component"/"boundary" and meaning different things by it.

Adapted from the deep-modules school (Ousterhout's depth, Feathers' seams) via the
mattpocock/skills codebase-design distillation (MIT).
