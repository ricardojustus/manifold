---
name: hookify
description: >-
  Mines operator corrections into DRAFT enforcement-rule candidates — triage by the enforcement escalation tests, then write drafts with verbatim receipts to hook-drafts and PARK ratification; NEVER wires a live hook or settings file. Use on "hookify" / "turn that correction into a rule"; judgment-shaped corrections go to memory-discipline.
---

# Hookify — corrections into draft enforcement candidates

*Adapted from anthropics/claude-code `plugins/hookify` (MIT), rewritten for this harness's
enforcement-ladder doctrine and never-self-wire posture.*

A correction evaporates at session end unless something durable catches it. ENFORCEMENT.md's ladder
orders the homes: a **prose rule** (a judgment the model reads and applies — the default), a
**native classifier rule** (a plain-English allow/soft_deny/hard_deny line the runtime's permission
classifier enforces with judgment), an **informational or anti-escape hook**, or — rarest,
operator-commissioned only — a **deny hook**. This skill triages and drafts; it installs nothing.

**The one divergence from the upstream:** upstream `hookify` activates the rule it generates. **This
harness never does** — a session authoring its own live enforcement is
`.claude/harness/ENFORCEMENT.md` invariant #3 (no mid-session config / permission
self-modification). Output is always a DRAFT parked for the operator; wiring is a separate, human,
out-of-band step. Writing into `.claude/harness-hooks/` or a `settings.json` means you have left
this skill's lane — stop.

## Step 1 — Gather the correction signals

A correction is any moment the operator redirected you: "no, do X not Y", "you keep doing Z", "I
told you already", visible frustration, a re-explanation of something you got wrong, a retracted
action. Sources: **the recent conversation** (quote the exact moment — you need it verbatim as the
receipt in Step 3) and **a correction corpus the operator points at** (a feedback file, memory dir,
or diary — prefer corrections that have fired **more than once**; a repeat is what earns mechanical
enforcement).

Collect each as: *what I did wrong · what the operator wanted instead · the verbatim quote · how
many times it has fired*. Do not editorialize; the operator's words are the ground truth.

## Step 2 — Classify each: HOOKABLE or prose-tier

Run each correction through ENFORCEMENT.md's **four escalation tests** ("Extending enforcement"),
applied as a router:

1. **Irreversibility / severity** — would one violation cause damage that cannot be cleanly undone
   (a destructive command, an exfiltration, a write outside the blast-radius fence)? A recoverable
   slip stays prose.
2. **Native-layer check** — does the permission system or classifier already cover it, or would a
   one-line classifier rule (autoMode allow/soft_deny/hard_deny in settings) cover it with judgment?
   Then draft THAT rule, not a hook — plain English enforced by a model beats a regex.
3. **Mechanical decidability** — can a hook decide "block or allow" from the tool call *alone*? A
   regex over a command string, yes; "was this the right architectural call", no.
4. **Routine-flow check** — is the "violation" actually a common, operator-sanctioned flow? Then the
   enforcement point is the operator's approval; do not mechanize it.

**CANDIDATE** = passes all four. Prefer, in order: classifier rule > informational hook (warn) >
anti-escape hook > deny hook (operator-commissioned only, with ownership verification — no hook may
block a workstream from its own declared work surface). Draft it (Step 3).

**Everything else routes to prose** = `memory-discipline`, and that is where most corrections
correctly land: a judgment rule carrying its reasoning generalizes to cases a regex never
anticipates. Hand these off as a memory-discipline entry (the correction + its why); forcing a
mechanical guard onto a judgment call recreates the brittle-checklist failure the prose tier exists
to avoid — and the over-block failure that got this harness's own deny tier retired. **When in
doubt, prose.**

## Step 3 — Draft each hookable candidate

One draft file per hookable correction, carrying exactly four things:

- **Trigger** — the pattern that fires it (a command shape, a path glob, a tool + argument match).
  Be precise: over-broad blocks legitimate work; over-narrow misses the case it was written for.
- **Action** — `warn` (surface a caution, allow the call) or `block` (deny it). Reserve `block` for
  the genuinely irreversible; `warn` is the right default when a false positive has real cost.
- **Message** — what the operator (or a future session) sees when it fires: name the rule, point at
  the why.
- **RECEIPT** — the correction moment quoted **verbatim** (from Step 1). A rule without its receipt
  is a rule waiting to be deleted; the receipt is how a future reader judges when it applies.

Match the draft to ENFORCEMENT.md's exit-code doctrine so ratification is mechanical: a `block`
candidate must be authored to **exit 2** (the only blocking code — exit 1 fails OPEN) and must ship
with **block-path** selftest fixtures (a should-BLOCK and a should-ALLOW input), because a guard
whose block path is never tested can fail open in exactly the case it exists for.

## Step 4 — Write drafts to the hook-drafts dir (NEVER live paths)

Write each draft to the project's **`hook-drafts/` directory** (the binding names the concrete
location; it may override the default) — a staging area, inert by construction. **Never** write into
`.claude/harness-hooks/` (the installed-but-unwired bindings), and **never** touch any
`settings.json` or permission file: those are the live-enforcement surfaces, and a session editing
its own enforcement is the invariant-#3 violation this skill exists to avoid. The draft dir is the
airlock; the operator moves things across it, not you.

## Step 5 — Park the ratification

Surface the drafts as parked candidates, not applied changes. For each: the correction it came from,
the trigger/action/message, and the receipt. Recommend a disposition (promote to a wired hook / keep
as prose in memory-discipline / drop) but do not act on it. **Post-ratification wiring is the
human's manual step** (per the hooks README): they move the draft into the overlay's `hooks/`, add
the block-path selftest cases, and wire it into `settings.json` out-of-band — the same
decide-and-park discipline `autonomous-work` uses for owner-gated calls.

## When to invoke

The operator says "hookify", "turn that into a rule", "capture that correction", or points you at a
correction log and asks what should become enforcement. Proactively at the end of a run that
accumulated several corrections — the consistency-audit / retro backlog item is the scheduled
version of this; until it ships, run hookify by hand.

## Pairs with

**memory-discipline** — the prose-tier destination (the majority); hookify decides HOOKABLE vs
prose, memory-discipline owns the prose home. **`.claude/harness/ENFORCEMENT.md`** — the four
escalation tests (Step 2), the hook taxonomy + exit-code footgun (Step 3), the never-self-wire
doctrine (Step 4); read it before drafting any `block` candidate. **The consistency-audit / retro
backlog item** — the periodic corrections-mining pass this stands in for.
