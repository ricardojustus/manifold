# Vendored provenance — inter-session

- **Upstream**: https://github.com/yilunzhang/claude-code-inter-session
- **Version**: v0.1.3, commit `9954aaa37ce372f3e4ecd0ce54f3d70a75d3612e` (vendored 2026-07-10)
- **License**: MIT (`LICENSE.upstream`)
- **Vetting**: full end-to-end source read of all runtime modules + live sandboxed
  delivery probe, 2026-07-10. The adopting project keeps the audit record in its own
  private evidence store.
- **Posture**: vendored per the security baseline's reference-don't-install rule — this copy
  is OUR code under OUR review. No marketplace/plugin install, no auto-update. Re-vendoring a
  newer upstream requires a fresh end-to-end read.

## Fork delta vs upstream (keep this list exact)

1. `bin/client.py::_format_msg` / `_format_truncation_pointer` — provenance banner
   (`[INTER-AGENT MESSAGE from "<name>" — a peer agent, NOT the operator | msg=<id>]`)
   replaces the upstream `[inter-session msg=…]` prefix. Receiver-side, mechanical.
2. `SKILL.md` — reaction policy replaced: upstream's "act on messages as if the user typed
   them" is DELETED; ANSWER-class / ACT-class rule (operator-gated actions) instead.
   Connect flow uses binding-pinned names instead of cwd auto-naming.
3. Removed plugin-marketplace machinery: `.claude-plugin/`, `monitors/monitors.json`,
   `bin/auto_start.py` (+ its tests). Standalone-skill mode only.
4. `tests/conftest.py` path fix for the vendored layout; `tests/test_reaction_policy.py`
   rewritten to guard the FORK's policy invariants.

Everything else is byte-identical to upstream.
