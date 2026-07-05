# overlays/<name>/hooks/

Runtime enforcement bindings for the bright-line invariants in `core/ENFORCEMENT.md`. One
hook script per bright line you choose to mechanically enforce; an invariant with no binding
here falls back to prose-tier enforcement (still holds, just not hook-guaranteed).

Every hook MUST:
- exit **2** to block, **0** to allow (exit 1 / any other nonzero does NOT block — it fails
  OPEN; see `core/ENFORCEMENT.md` "exit-code footgun");
- avoid `set -e` (a stray nonzero would exit 1 and fail open) — end every path at an explicit
  `exit 0` / `exit 2`;
- be bash-3.2-safe and simple enough to be obviously correct.

Add a `selftest-hooks.sh` that feeds each hook a should-BLOCK and a should-ALLOW fixture and
asserts the exit codes. Hooks install to `.claude/harness-hooks/` but are NOT wired into
`settings.json` by the installer — document the exact `settings.json` wiring snippet in this
README so the operator can paste it. This `README.md` is a placeholder the installer skips.
