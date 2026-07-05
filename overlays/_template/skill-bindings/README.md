# overlays/<name>/skill-bindings/

One `<core-skill-name>.md` per core skill that needs project concretes. On install its
contents are appended to that skill's `SKILL.md` under a `## Project bindings` heading — so
write each file to read as an appendix (the core body references it generically, e.g. "the
project binding names the concrete dispatch mechanics"). Put the project's vault paths,
tool/dispatch mechanics, doc-corpus refs, and any project-specific rubric here — NOT in core.

A `scripts/` subdir may hold helper scripts referenced by the bindings; the installer copies
`scripts/` into the target at `.claude/harness-scripts/` (any `README.md` skipped), so a binding
can invoke a helper from a path that exists in the installed target.
This `README.md` is a placeholder the installer skips.
