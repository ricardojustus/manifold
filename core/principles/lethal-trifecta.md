# The lethal trifecta — the grant test before any tool or permission

**Rule.** Before you grant a session (or an agent, or an integration) a new tool or permission, ask whether it now holds **all three** legs at once:

1. **Access to private data** — anything sensitive the session can read (credentials, the operator's files, internal records).
2. **Exposure to untrusted content** — anything the session ingests that an attacker could have authored (web pages, emails, transcripts, tool results, another system's output).
3. **An egress channel** — any way data can leave (an outbound network call, a write to a shared or external surface, a message to a third party).

**Any two legs are survivable. All three is the exfiltration path** — untrusted content can carry an injected instruction, the session has secrets to steal, and the egress channel ships them out. When a grant would complete the trifecta, **strip a leg** (make the tool read-only, sandbox the network, quarantine the untrusted input) or **gate the action per-use** behind explicit approval.

## Why

Infiltration is recoverable — a bad write rolls back with git. Exfiltration is not — data that left cannot be un-sent, and it may be cached or indexed even if later deleted. So the one class of damage worth structural paranoia is the one where all three legs meet. The trifecta test is powerful because it's *compositional*: each tool looks individually reasonable ("just read access," "just a web fetch," "just a Slack post"), and the danger only appears when you count the legs the session holds *together*. An agent that reads secrets and fetches web pages is fine until you add the ability to post — and then a poisoned web page can read a secret and post it out.

*Receipt: the general rule behind every "why is this MCP read-only" and every "why is the sandbox network-denied" decision is this count. A session with private-data read + untrusted-content ingestion is safe precisely as long as it has no egress; the moment an outbound-write tool is added "for convenience," a prompt-injection in the untrusted content becomes an exfiltration. The default posture — read everything, send to nobody — is the trifecta broken at the egress leg by construction.*

## How to apply

- At every tool/permission/integration grant, count the three legs the session will hold *after* the grant. Three = halt and strip or gate.
- Prefer breaking the **egress** leg: read-only scopes, network-denied sandboxes, drafts-to-the-operator instead of direct sends. A session that structurally cannot send cannot exfiltrate.
- When all three are genuinely required, gate the trifecta-completing action behind explicit per-use approval — never a standing grant.
- The concrete secret paths, egress surfaces, and untrusted-input sources are project-specific; the project binding enumerates them. This file owns the *count-the-legs test*.
