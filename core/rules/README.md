# core/rules/

Always-on rule files, installed to the target's `.claude/rules/` alongside the overlay's
project rules. Two tiers:

- **Always-on** — loaded into every session (the default for a file in this dir).
- **Path-scoped** — a rule with `paths:` frontmatter loads only when matching files are
  touched; use it for rules that apply to one subsystem.

Conventions for a core rule: it must be **project-agnostic** (project concretes live in the
overlay's `rules/` or in a binding), it carries its **WHY and a receipt** (a rule without its
why gets deleted by the next confident reader), and where it needs project values it names a
**binding contract** (e.g. `threads.md` → the overlay's threads binding) rather than
hard-coding any project's paths.
