---
name: brain-mode
description: >-
  Session posture where a scarce frontier main model keeps ALL the thinking and delegates ALL
  implementation to an abundant strong implementer tier. Activates ONLY on explicit operator
  declaration — "brain mode", "go into brain mode", "Fable Brain Mode", "Fable Mode"; a single
  delegation is an ordinary dispatch, not this posture. Distinct from orchestrator-mode, which
  routes even spec/design DRAFTING out to the cross-model counterparty.
---

# Brain Mode — the main model thinks, hired hands type

A posture, declared by the operator, for stretches where the frontier main model's own capacity is
the scarce resource and its comparative edge is reasoning, not typing. The main loop keeps every
thinking artifact and delegates every implementation artifact to the implementer tier the overlay
pins — which sits at parity for code work, so the delegation costs quality nothing while the
scarce window pays only for judgment.

> Project bindings may amend this contract — read the "## Project bindings" section (end of file) first.

**The posture is spoken, never assumed — only an EXPLICIT declaration counts.** The activation
phrases are the ones in this skill's description. "Implement this with a subagent" is NOT the
posture — that is one ordinary dispatch. Genuinely ambiguous phrase → ask. Once on, the posture survives small
intervening chat; until ended, every qualifying junction routes per the table.

## The sibling contrast (know which posture you are in)

**brain-mode**: the main model IS the frontier tier — thinking stays HOME, only implementation
routes DOWN, and cross-model consults stay optional and junction-triggered, exactly as outside the
posture. **orchestrator-mode**: the main model sits BELOW the frontier tier (typically after a
quota fallback) and the cross-model counterparty out-writes it — authoring routes OUT, spec and
design drafting included, with a mandatory advisor consult at every decision. If the main model
falls below the frontier tier mid-session, brain-mode's premise is gone: say so, and put the
posture question back to the operator (orchestrator-mode is usually the fitting successor).

## The contract

**The main loop KEEPS:**

- **Thinking and discussion** — design reasoning, option analysis, decisions with the operator.
- **Vision docs, plans, briefs** — every dispatch still gets a full `brief-authoring` brief;
  brief quality is the highest-leverage act in this posture. The brief IS the thinking: a thin one
  delegates judgment rather than typing (**brief-thinning**).
- **Specs** — spec authoring stays home: the spec is where the thinking lives and is the quality
  lever for everything downstream. The main model authors EVERY spec class by default; a
  cross-model spec DRAFT runs only on the operator's explicit per-spec word — never
  agent-selected, and a standing conservation directive from outside the posture does not carry
  in. (With the posture OFF, the overlay's cross-model draft/revise pattern is unaffected.)
- **Research consolidation** — research subagents fan out as usual; the synthesis is thinking.
- **The gates** — the contract's definition of done, audit-cycle convening, severity dispositions, harvest
  verification: a builder's green is a claim until the main loop re-verifies it.
- **Decision packets + operator comms + memory/diary/state** — never delegated, in any mode.
- **Mechanical APPLICATION, never authoring** — applying a harvested diff or artifact, a one-line
  config/path/continuity edit: stays home. AUTHORING any code stays out — a tiny code fix, a glue
  edit, or an implementation-bearing integration edit still dispatches. (Dispatching a one-line
  CONFIG edit is still orchestration theater — do that one yourself.) One exception,
  operator-gated: the trivial-edit row in **Junction routing** below.

**The main loop NEVER does while the posture is active:**

- Write implementation code — features, fixes, glue, scripts, and **audit fix-passes**: the main
  loop authors the fix BRIEF; an implementer seat applies it.
- Execute bulk mechanical non-code work (mass renames, batch rewrites from a settled design,
  sweep edits) — that dispatches to the cheap tier per the overlay's dispatch triage.

**The boundary test, when a file edit is on your fingertips**: is this edit AUTHORING
implementation substance? → dispatch it — unless the trivial-edit row in **Junction routing**
applies. Is it a thinking artifact (spec/plan/brief/packet), a continuity surface
(state/diary/memory), or the trivial mechanical application of something already decided? → it
stays home.

## Junction routing

| Junction | Route |
|---|---|
| Implementation, specced | Implementer seat per the overlay's model pins — a full brief, the spec, verifiable success criteria |
| Implementation, un-specced (quick fixes, glue — above the trivial-edit threshold below) | Implementer seat, with the `minimality-persona` card's seat rules the overlay wires for specless work |
| Audit fix-pass | Main loop writes the fix brief from the findings; implementer seat applies; the next round re-checks |
| Bulk mechanical non-code work | Cheap-tier dispatch per the overlay's triage |
| Spec to write | Main loop authors — always, unless the operator explicitly routes THIS spec to a cross-model draft (their per-spec word; never agent-selected) |
| Cross-model consult | OPTIONAL, junction-triggered, unchanged by the posture |
| Review / pre-merge | The project's audit gates, unchanged |
| Trivial stand-alone code edit (one line or less, no design judgment) | ASK the operator: dispatch or inline? Their answer governs; autonomous → always dispatch |
| Tiny non-code mechanical edit (config/path/continuity) | Main loop just does it |

## Enforcement

Prose posture, v1 — no blocking hook. **Standing revisit trigger: the first observed instance of the
main loop writing substantive implementation code with the posture on → escalate to a hook**, via
the project's enforcement pipeline.

## Ending the posture

- The operator says so ("back to normal", "drop brain mode"). An explicit instruction to author
  one specific thing does NOT end the posture — it is the operator's answer pre-given (the
  trivial-edit question, or a per-task override for bigger work): do that task at their word, keep
  the posture on (say which reading you took if ambiguous).
- The session ends. Session-scoped, never auto-resumes: note posture ON/OFF in the session
  journal, and a line in thread state if the session ends while ON.
- **Posture creep** — the posture covers a stretch, not a standing default: when sessions keep
  running on it because nobody said stop, put ending it back to the operator.
