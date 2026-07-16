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

**Receipt WEIGHT (operator ruling 2026-07-16 — the always-on diet):** rules are always-loaded,
so every byte rides every session. The WHY stays inline as ONE line; the full receipt body —
the dated war story, verbatim quotes, incident trail — lives in the project's **receipts
store** (the overlay names its location; it is NOT installed into the loaded rules dir), with
the rule carrying a pointer. A multi-paragraph receipt inline in a rule file is a defect, not
diligence. This README itself is never installed (`skip_readme`).
