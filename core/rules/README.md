# core/rules/

Always-on rule files, installed to the target's `.claude/rules/` alongside the overlay's
project rules. Two tiers:

- **Always-on** — loaded into every session (the default for a file in this dir).
- **Path-scoped** — a rule with `paths:` frontmatter loads only when matching files are
  touched; use it for rules that apply to one subsystem.

Conventions for a core rule: it must be **project-agnostic** (project concretes live in the
overlay's `rules/` or in a binding), it states the rule CLEAN per `rule-writing.md` (the WHY is diarized at capture, retrieved on
challenge — not inlined), and where it needs project values it names a
**binding contract** (e.g. `threads.md` → the overlay's threads binding) rather than
hard-coding any project's paths.

**Capture format (Ric ruling 2026-07-20 — see `rule-writing.md`):** rules are always-loaded,
so every byte rides every session. State the rule, its scope, its enforcement — nothing else;
no inline receipts. The WHY is diarized at capture time and lives in the memory graph, retrieved
on challenge. Target ≤1.5 KB per rule. This README itself is never installed (`skip_readme`).
