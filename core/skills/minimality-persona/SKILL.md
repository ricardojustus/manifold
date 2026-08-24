---
name: minimality-persona
description: >-
  Sets the do-less/YAGNI persona (ponytail) on dispatched seats — the standing counterweight to over-building. Arc-wide: set once at the first dispatch of a build or review arc, clear at session end. Covers the flag interface and its footguns. Use on "set the minimality persona", "ponytail on for the seats", "/minimality-persona".
---

# Minimality persona (ponytail)

**WHAT**: a do-less/YAGNI persona injected into dispatched seats — the standing counterweight to
over-building. **WHEN**: arc-wide, on installs where the ponytail plugin is present and the
operator has opted in (the overlay says which) — set once at the first dispatch of a build or
review arc, clear at session end.

**INTERFACE**
- Flag: `F="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.ponytail-active"; printf full > "$F"` · clear:
  `rm -f "$F"`. Intensity `full` in seats (`ultra` is the operator's interactive tier).
- Main-loop use: invoke the `ponytail` skill (session-scoped, flag-invisible).

**FOOTGUNS**
- The flag is ACCOUNT-shared: every window on the account inherits it, and any sibling
  SessionStart resets it to the pinned default (`off`) — a vanished flag mid-arc means later
  seats run vanilla; re-set at the next dispatch.
- The `:-$HOME/.claude` fallback is LOAD-BEARING (a launch wrapper may unset
  `CLAUDE_CONFIG_DIR`).
- The session default stays pinned OFF — it never flips without the operator's word.
- The skill persona deactivates only on the operator's literal whole-message `stop ponytail` /
  `normal mode` — an agent typing the words deactivates nothing.
- A seat's "does this need to exist?" hit on something the operator RATIFIED is flagged to them,
  never silently cut.
