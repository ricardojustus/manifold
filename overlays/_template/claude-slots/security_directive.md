<!-- FILL security_directive: the project's security posture — exfil/infiltration priorities,
     deny-unless-allowed default, read-only-external stance, the concrete secret prefixes to
     redact + credential stores never to read in full, write-scope boundaries, any
     confidentiality framework. Back the invariant halves (no readable secrets #5; declared
     path boundaries #4) per ENFORCEMENT.md's ladder — runtime redaction, permission deny
     rules, classifier rules; never a proactive deny hook. (The scaffold provides the
     `## Security Directive` heading.) -->

<!-- Suggested starting content — the onboarding interview offers this verbatim; accept, edit,
     or drop it, then DELETE the placeholder comment above (an install with that comment still
     present fails closed). Hand-filling this template? Do the same by hand. -->

**Priority: no data leaves this system through any vector the agent configures.** Infiltration
is recoverable (revert the commit); exfiltration is not.

- **Default posture: deny unless explicitly allowed.** External access is read-only until the
  operator authorizes a write scope, per integration.
- **No secrets in any agent-readable surface** — never print, log, or paste credential values;
  never read a credential store in full; redact key-shaped strings in output.
- **Never touch**: <list the concrete paths, repos, and systems that are off-limits — production
  config, credential stores, other people's working trees>.
- **Posture changes are the operator's call — ask, never assume.** An exception to any of the
  above is a decision the operator makes with the consequences in front of them, recorded.
