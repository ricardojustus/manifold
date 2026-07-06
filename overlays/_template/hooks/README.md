# overlays/<name>/hooks/

OPTIONAL enforcement bindings. Read `core/ENFORCEMENT.md`'s ladder first: most invariants
are best backed by the runtime's native layer (a plain-English classifier rule in settings
`autoMode`, permission deny rules, server-side controls) — not by a hook. Healthy hook
shapes here: informational (adds context, never blocks), anti-escape (stops the agent
bypassing an operator-installed gate), opt-in mode hooks. Deny hooks on work surfaces are
operator-commissioned only, with every hard-coded surface's ownership verified — no hook
may block a workstream from its own declared work surface. An invariant with no binding
falls back to prose-tier enforcement (still holds).

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
