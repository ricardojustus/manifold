<!-- FILL security_directive: the project's security posture — exfil/infiltration priorities,
     deny-unless-allowed default, read-only-external stance, the concrete secret prefixes to
     redact + credential stores never to read in full, write-scope boundaries, any
     confidentiality framework. Back the invariant halves (no readable secrets #5; declared
     path boundaries #4) per ENFORCEMENT.md's ladder — runtime redaction, permission deny
     rules, classifier rules; never a proactive deny hook. (The scaffold provides the
     `## Security Directive` heading.) -->
