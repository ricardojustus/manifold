# Enforcement doctrine

Most of this harness is **prose the model must choose to obey**. That is deliberate: a rule that carries its reasoning ("here is *why* we validate errors before diagnosing, here is the incident that taught us") produces better judgment than a rule reduced to a mechanical check, because the model can apply the *why* to cases the check never anticipated. Prose generalizes; a checklist does not.

Prose has one failure mode a check does not: a careless, confused, or compromised session can simply not obey it. The original version of this doctrine answered that with a tier of deny-hooks. **That answer was revised on 2026-07-05, from production experience:** within one day of being wired, the deny tier produced one real incident (a boundary hook blocked a workstream from its own primary surface, and the self-modification guard then blocked the operator-authorized fix — a deadlock only the operator could break) and zero real saves. The revised doctrine below reflects what actually held the line all along: the prose, the operator in the loop, and the runtime's own permission layer.

## The enforcement ladder (in order of preference)

### 1. Prose — the default, the majority

Judgment rules that carry the WHY. The model reads them, understands the reasoning, and applies it — including to novel situations the rule's author never anticipated. Enforcement is the model's trained disposition plus the review loop. Every rule that isn't explicitly escalated below lives here. **When in doubt, prose.**

### 2. The runtime's native permission layer

Claude Code's permission system — modes, allow/deny/ask rules, and (in auto mode) a **model-based classifier** that surfaces dangerous-shaped actions for operator approval. This is the first *mechanical* layer, and it is almost always the right one, for two reasons:

- **It has judgment.** The classifier reads intent, not string patterns — so it avoids the twin pathology of hand-written guards (under-blocking encodings it didn't anticipate while over-blocking innocent near-matches). A guard built from `grep` inherits both failure modes forever; the classifier inherits neither.
- **It is customizable in plain English.** `settings.json → autoMode` accepts project-specific rules: `allow` (auto-approve), `soft_deny` (prompt — destructive-shaped actions the operator's explicit approval clears), and `hard_deny` (security boundaries that operator intent does *not* clear). A one-line English rule enforced with judgment beats a hundred-line bash hook enforced with string-matching. Include the literal `"$defaults"` entry to inherit the built-in rules.

Where an invariant has a server-side form, prefer it over anything local: hosted-remote **branch protection** cannot be fooled by any command shape, because it enforces at the only place the damage could land.

### 3. The operator in the loop

For gated flows whose *normal case is sanctioned* — amending a locked artifact, a spec correction found mid-implementation, a scope change — conversational approval IS the enforcement point. **Do not mechanize a flow whose common case is "ask and receive yes": the mechanism blocks the flow, not the failure.** Receipt: a locked-artifact write-deny hook was retired 2026-07-05 because amendment is a routine, operator-approved, near-daily operation; in production the hook could only ever stand between the artifact's owner and their own sanctioned work.

### 4. Hooks — by shape, and the shapes are not equal

Claude Code hooks run user-configured commands at tool-call lifecycle points. Their healthy uses, in descending order:

- **Informational hooks (always healthy).** They add context, never deny: a SessionStart hook that re-injects a checkpoint pointer, notify-on-completion, format-after-edit. Worst case is noise.
- **Anti-escape hooks (healthy in small numbers).** They block the *agent* from bypassing a gate the *operator* installed — e.g. denying `git --no-verify` / `--no-gpg-sign` so a session cannot skip the operator's pre-commit checks when they fail inconveniently. These cannot block legitimate work, because the legitimate path is the gate itself.
- **Opt-in mode hooks (healthy because the operator arms them).** Active only in a mode the operator explicitly started — e.g. a Stop-hook keeping an unattended run going until its declared completion. Worst case is extra work, not blocked work.
- **Deny hooks on work surfaces (the dangerous class — operator-commissioned only).** A PreToolUse deny on files, paths, or commands the project actually works with. Never build one proactively. If the operator commissions one, three requirements are non-negotiable:
  1. **Ownership verification.** Verify every hard-coded surface with that surface's actual owner, not from memory or a scope note. A constraint scoped to ONE workstream ("this track must not touch X") must never be encoded installation-wide — the hook runs for every session, including X's owner. **Standing rule: no hook ships that can block a workstream from its own declared work surface.**
  2. **The block-path test.** Assert the deny actually fires (exit code 2, action denied) AND that the known-innocent neighbors pass. An untested guard is worse than none — it manufactures false confidence.
  3. **The deadlock check.** Any guard that protects the guards (self-modification denies) turns every OTHER misconfigured deny into an operator-only outage. Account for the combination before wiring, not after.

### The exit-code footgun (read this before writing any hook that denies)

A PreToolUse hook signals its decision through its **exit code**, and the semantics have a trap:

- **Exit code 2 → BLOCKS** the tool call. This is the *only* blocking exit code.
- **Exit code 0 → allows** (the normal pass).
- **Exit code 1 (or any nonzero that isn't 2) → does NOT block.** It is treated as a non-fatal hook error: the failure is surfaced but the tool call **proceeds**. A hook that means to block but exits 1 — a script error, command not found, a pipe failure, `set -e` tripping — **silently fails open**, in exactly the situation it exists for.

So: every deny hook MUST exit 2 to block, MUST avoid `set -e`, MUST end every path at an explicit `exit 0` / `exit 2`, and MUST be tested on the block path, not just the allow path. Prefer hooks simple enough to be obviously correct. **Hooks only ever tighten** — a hook can deny what permissions would allow, never grant what they forbid.

## The invariants (what core declares)

These remain the harness's non-negotiables — as prose, each backed by the *lowest* rung of the ladder that actually covers it. Overlays bind the concrete values.

1. **No force-push / history rewrite on shared protected branches.** Irreversible for everyone who has pulled. Backing: a classifier `soft_deny` rule (overlay documents the snippet) + server-side branch protection wherever a shared remote exists. *(Previously a deny hook; retired — the classifier covers the shape with judgment.)*
2. **No writes to LOCKED artifacts outside the amendment process.** The Lock makes "authoritative as written" true. Backing: **the operator-gated amendment flow itself** — amendments are routine and sanctioned in conversation; no mechanical gate. *(Previously a deny hook; retired — it mechanized a daily approved flow.)*
3. **No mid-session config / permission self-modification.** A session must not rewrite its own leash. Backing: the runtime's own settings schema validation + the classifier's treatment of settings edits + prose. A dedicated guard is deny-class: operator-commissioned only, with the deadlock check above. *(Previously a deny hook; retired — it was the deadlock multiplier.)*
4. **Declared path boundaries.** Surfaces owned by NO workstream that this installation must never touch. Backing: prose + the classifier's out-of-workspace-write prompts; permission `deny` rules for anything stronger. Ownership verified with the owner before any surface is declared. *(Previously a deny hook; retired after the ownership defect above.)*
5. **No secrets readable in agent surfaces.** Exfiltration is the one damage git cannot roll back. Backing: the serving runtime's redaction/exfil-guard and credential `denyRead` — enforced where output leaves the system, not in session hooks. Posture prose (deny-unless-allowed, read-only external access) is the real guarantee.

## Extending enforcement

Before escalating any rule past prose, four tests — failing any one keeps it prose:

1. **Irreversibility / severity** — would one violation cause damage that cannot be cleanly undone? Recoverable → prose.
2. **Native-layer check** — does the permission system, the classifier (possibly with a one-line custom rule), or a server-side control already cover it? Then it's covered; duplicating it in a hook adds failure modes, not safety.
3. **Mechanical decidability** — can "block vs allow" be decided from the tool call alone, without judgment? If it needs interpretation, a mechanical guard will under-block real cases AND over-block innocent ones. The force-push guard proved this both directions before it was retired.
4. **Routine-flow check** — is the "violation" actually the common, sanctioned case (an approved amendment, an owner working its own surface)? Then the enforcement point is the operator's approval, and a mechanical gate only obstructs it.

Growing mechanical enforcement without this discipline recreates the brittle-checklist failure the prose tier exists to avoid — guards that block real work and still miss the judgment cases. When in doubt, prose.
