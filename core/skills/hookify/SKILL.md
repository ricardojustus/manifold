---
name: hookify
description: >-
  Mine operator corrections into DRAFT enforcement-rule candidates — turn "you
  corrected me on X" into a proposed rule instead of a lesson that evaporates.
  Gather correction signals (recent conversation, or the corpus the operator points
  at); classify by ENFORCEMENT.md's four escalation tests (irreversible +
  mechanically-decidable + not-already-native + not-a-routine-sanctioned-flow →
  candidate; judgment-shaped → memory-discipline instead); prefer a native
  classifier rule or an informational hook over any deny-on-work-surface hook;
  draft trigger + action + message + verbatim RECEIPT; write to the hook-drafts
  dir and PARK ratification. CRITICAL: this NEVER activates a rule — never writes
  live hook or settings paths (ENFORCEMENT invariant #3). Use on "hookify" /
  "turn that correction into a rule", or after a run that accumulated corrections.
  Neighbors: memory-discipline (prose-tier judgment rules), ENFORCEMENT.md (the
  tests + wiring doctrine).
---

# Hookify — corrections into draft enforcement candidates

*Pattern adapted from anthropics/claude-code `plugins/hookify` (MIT). Rewritten for this harness's enforcement-ladder doctrine and never-self-wire posture.*

A correction the operator gives you is a signal that evaporates at session end unless something
durable catches it. Several homes exist, and ENFORCEMENT.md's ladder orders them: a **prose rule** (a judgment the
model reads and applies — the default), a **native classifier rule** (a plain-English
allow/soft_deny/hard_deny line the runtime's own permission classifier enforces with judgment),
an **informational or anti-escape hook**, or — rarest, operator-commissioned only — a
**deny hook**. This skill does the triage and drafts candidates — it does NOT install anything.

**The one divergence from the upstream it adapts, stated up front:** the upstream `hookify`
generates a rule and activates it immediately. **This harness never does.** A session authoring
its own live enforcement is exactly `.claude/harness/ENFORCEMENT.md` invariant #3 (no mid-session config /
permission self-modification). So hookify's output
is always a DRAFT parked for the operator; wiring is a separate, human, out-of-band step. If you
ever find yourself writing into `.claude/harness-hooks/` or a `settings.json`, you have left this
skill's lane — stop.

## Step 1 — Gather the correction signals

A correction is any moment the operator redirected you: "no, do X not Y", "you keep doing Z",
"I told you already", visible frustration, a re-explanation of something you got wrong, a
retracted action. Gather them from:

- **The recent conversation** — scan this session's turns for the corrections above. Quote the
  exact moment; you will need it verbatim as the receipt (Step 3).
- **A correction corpus the operator points at** — if they name a place where corrections are
  logged (a feedback file, a memory dir, a diary), read it and pull the recurring ones. Prefer
  corrections that have fired **more than once** — a repeat is what earns mechanical enforcement.

Collect each as: *what I did wrong · what the operator wanted instead · the verbatim quote · how
many times it has fired*. Do not editorialize; the operator's words are the ground truth.

## Step 2 — Classify each: HOOKABLE or prose-tier

Run each correction through `.claude/harness/ENFORCEMENT.md`'s **four escalation tests** (its
"Extending enforcement" section), applied here as a router:

1. **Irreversibility / severity** — would one violation cause damage that cannot be cleanly
   undone (a destructive command, an exfiltration, a write outside the blast-radius fence)? A
   recoverable slip stays prose.
2. **Native-layer check** — does the permission system or classifier already cover it, or would
   a one-line classifier rule (autoMode allow/soft_deny/hard_deny in settings) cover it with
   judgment? Then draft THAT rule, not a hook — plain English enforced by a model beats a regex.
3. **Mechanical decidability** — can a hook decide "block or allow" from the tool call *alone*?
   A regex over a command string — decidable. "Was this the right architectural call" — not.
4. **Routine-flow check** — is the "violation" actually a common, operator-sanctioned flow? Then
   the enforcement point is the operator's approval; do not mechanize it.

**CANDIDATE** = passes all four. Prefer, in order: classifier rule > informational hook (warn) >
anti-escape hook > deny hook (operator-commissioned only, with ownership verification — no hook
may block a workstream from its own declared work surface). Draft it (Step 3).

**Everything else routes to prose** = `memory-discipline`. Most corrections land here, and that
is correct — a judgment rule that carries its reasoning generalizes to cases a regex never
anticipates. Hand these off as a memory-discipline entry (the correction + its why); do not force
a mechanical guard onto a judgment call, or you recreate the brittle-checklist failure the prose
tier exists to avoid — and the over-block failure that got this harness's own deny tier retired.
When in doubt, prose.

## Step 3 — Draft each hookable candidate

One draft file per hookable correction. Each carries exactly four things:

- **Trigger** — the pattern that fires it (a command shape, a path glob, a tool + argument
  match). Be precise: an over-broad trigger blocks legitimate work (the harmful false-positive
  direction), an over-narrow one misses the case it was written for.
- **Action** — `warn` (surface a caution, allow the call) or `block` (deny it). Reserve `block`
  for the genuinely irreversible; a warn is the right default when the cost of a false positive
  is real.
- **Message** — what the operator (or a future session) sees when it fires: name the rule and
  point at the why.
- **RECEIPT** — the correction moment quoted **verbatim** (from Step 1). A rule without its
  receipt is a rule waiting to be deleted; the receipt is what a future reader uses to judge when
  the rule applies and when it does not.

Match the draft's shape to `.claude/harness/ENFORCEMENT.md`'s exit-code doctrine so ratification is mechanical: a
`block` candidate must be authored to **exit 2** (the only blocking code — exit 1 fails OPEN),
and it must ship with **block-path** selftest fixtures (a should-BLOCK and a should-ALLOW input),
because a guard whose block path is never tested can fail open in exactly the case it exists for.

## Step 4 — Write drafts to the hook-drafts dir (NEVER live paths)

Write each draft to the project's **`hook-drafts/` directory** (the project binding names the
concrete location; it may override the default). This is a staging area — inert by construction.

**Never** write into `.claude/harness-hooks/` (the installed-but-unwired bindings), and **never**
touch any `settings.json` or permission file. Those are the live-enforcement surfaces, and a
session editing its own enforcement is the invariant-#3 violation this whole skill is built to
avoid. The draft dir is the airlock; the operator moves things across it, not you.

## Step 5 — Park the ratification

Surface the drafts to the operator as parked candidates — not applied changes. For each: the
correction it came from, the trigger/action/message, and the receipt. Recommend a disposition
(promote to a wired hook / keep as prose in memory-discipline / drop) but do not act on it.

**Post-ratification wiring is the human's manual step**, exactly as the hooks README describes:
they move the draft into the overlay's `hooks/`, add the block-path selftest cases, and wire it
into `settings.json` out-of-band. Your job ended at the parked draft. This is the same
decide-and-park discipline autonomous-work uses for owner-gated calls: you prepared the decision;
the human makes it.

## When to invoke

- The operator says "hookify", "turn that into a rule", "capture that correction", or points you
  at a correction log and asks what should become enforcement.
- Proactively at the end of a run that accumulated several corrections — the consistency-audit /
  retro backlog item is the scheduled version of this; until it ships, run hookify by hand.

## Pairs with

- **memory-discipline** — the destination for every correction that classifies as prose-tier
  (the majority). Hookify decides HOOKABLE vs prose; memory-discipline owns the prose home.
- **`.claude/harness/ENFORCEMENT.md`** — supplies the four escalation tests (Step 2), the hook
  taxonomy + exit-code footgun (Step 3), and the never-self-wire doctrine (Step 4). Read it
  before drafting any `block` candidate.
- **The consistency-audit / retro backlog item** — the periodic corrections-mining pass this
  skill is the manual stand-in for.
