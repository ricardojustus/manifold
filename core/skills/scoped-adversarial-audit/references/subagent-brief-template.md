# Subagent brief template — scoped adversarial audit

Copy and fill. Every placeholder is mandatory; a vague scope or a missing pre-feed produces a vague
audit.

```
ADVERSARIAL audit of <exact scope>. You are a security-minded reviewer with NO attachment to how this was implemented. The author may have blind spots — find them.

## Scope
- <file path> (lines A–B)
- <file path 2> (change at line C)
(be exact)

## Pre-feed — read first
- <the project's security baseline, specific sections>
- <the project's current security-posture doc>
- <the relevant absolute-rule references>
- <the source files the scope depends on but that are NOT the change itself>

## Threat model
The adversary is <the project's concrete attacker — e.g. a prompt-injected component processing untrusted input>. Their goal: <exfiltrate a secret / write outside scope / escalate a capability / persist across sessions>. Reason as the attacker.

## Audit questions
1. <specific adversarial question about the scope>
2. <another>
3. <blast-radius question — "what's the damage if this path is compromised?">
4. "What did the author miss?" (open-ended catch)

## Output
- Each finding: severity (Critical / High / Medium) + evidence (specific file:line or a reproduction) + recommended fix.
- Explicit "no findings on <question>" when the answer is "the code is correct here" — don't imply a problem where there isn't one.
- Under 500 words. Be specific. Don't hedge. If you can't verify something, say "unable to verify X without testing" — that beats confident-but-wrong.
```

## Scoping examples

- Bad: "Audit the new integration."
- Good: "Audit `<new-file>` (~180 lines) + the permission diff at `<file>` lines 84–102 — focus on:
  can a compromised low-trust actor write outside its scope through this path?"
