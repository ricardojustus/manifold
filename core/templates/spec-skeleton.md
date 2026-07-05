<!--
  spec-skeleton.md — the canonical shape for an implementation contract / design spec.
  A spec describes the CURRENT intended design as if it were always the design — it does
  NOT accumulate audit trails, fix-pass logs, or round-N findings in the body (those live
  in the audit artifacts; a top-of-doc CHANGELOG points at them). Author it with the
  spec-writing discipline: ground in the ACTUAL specs and code end-to-end before writing,
  and gate the depth by proportionality (a contained single-module reversible spec stays
  lightweight; a cross-subsystem or hard-to-reverse one earns the full trace).

  Two sections are easy to skip and shouldn't be: §0 Verified Inputs (verify the plan's
  PREMISES against the live runtime before drafting) and the Acceptance grammar (make
  each requirement machine-checkable). Both are optional in FORM but high-value; include
  them whenever the spec wires into real data flow.
-->

# Spec — <title>

**Status:** DRAFT | LOCKED · **Version:** <n> · **As of:** <YYYY-MM-DD>

## CHANGELOG
<!-- Pointer-shaped, ONE line per cycle. Points at the audit artifact; never reproduces
     findings in the body. e.g. "v3 — folded round-2 audit → <audits/topic/round-2.md>". -->
- v<n> — <one-line> → <audit artifact path>

## Summary (read-this-first)
<!-- Plain-language, self-sufficient. State ALL core points + load-bearing architecture +
     load-bearing decisions, simply — assume this is the ONLY part a busy reviewer reads,
     and it's where they audit the SHAPE before it locks. No jargon-bombing. Surface the
     load-bearing decisions here for an explicit yes/no. -->

## §0 Verified Inputs
<!-- Verify the design's PREMISES against the CURRENT runtime before drafting. For every
     "we need X because Y doesn't exist / has gap Z", grep/ls/probe and record the ACTUAL
     state of Y here. If Y already exists in some form, the deliverable narrows. This block
     is what stops "discovery by rediscovery". -->
- **Premise:** <what the plan assumes> → **Verified:** <what the probe actually found> (<command/evidence>)

## §1 Goal & scope
<!-- What this builds, and explicitly what it does NOT (the out-of-scope fence). -->

## §2 Design
<!-- The architecture. Module ownership, data/control flow, the key decisions and — for the
     ones that matter — the rejected alternatives (why this over that). Label every code
     block [Normative] (the contract) or [Illustrative] (a sketch; not audited for compile). -->

## §3 Contract
<!-- The normative surface implementers code against: signatures, type shapes, error/retry/
     telemetry semantics, import boundaries, invariants. This is the spec, not pseudo-code. -->

## §4 Requirements & acceptance grammar (optional but high-value)
<!-- Make each requirement machine-checkable. Use EARS for the requirement statements and
     Given-When-Then for at least one acceptance scenario per requirement.

     EARS (Easy Approach to Requirements Syntax) — pick the pattern per requirement:
       • Ubiquitous:   THE SYSTEM SHALL <response>.
       • Event-driven: WHEN <trigger> THE SYSTEM SHALL <response>.        (nominal paths)
       • State-driven: WHILE <in state> THE SYSTEM SHALL <response>.
       • Optional:     WHERE <feature is present> THE SYSTEM SHALL <response>.
       • Unwanted:     IF <condition/error> THEN THE SYSTEM SHALL <response>.  (error paths)

     Every requirement needs ≥1 Given-When-Then acceptance scenario:
       GIVEN <precondition>  WHEN <action>  THEN <observable outcome>.
     Cover the nominal path with WHEN/SHALL and the error path with IF/THEN, and give each
     at least one GWT so the audit can check the code against the clause, not the prose. -->

### R-NNN — <requirement name>
- **EARS:** WHEN <trigger> THE SYSTEM SHALL <response>.  <!-- or IF/THEN for an error path -->
- **Acceptance:**
  - GIVEN <precondition> WHEN <action> THEN <observable outcome>.

## §5 Cost
<!-- The recurring runtime cost (metered spend AND flat-rate quota/throughput). Does this add
     per-item model calls? Does input scale with corpus/graph size? Can it fan out or retry-
     storm? A correct-but-unboundedly-expensive change is not shippable — bound it here. -->

## §6 Tests
<!-- What proves each requirement. Keyed to the acceptance grammar above where present. -->

## §7 Implementation dispatch (fill at LOCK)
<!-- The author just spent the most time understanding this work's complexity — spend that
     understanding on the dispatch triage instead of leaving it to an inherited default.
     Dispatcher may override any line WITH A STATED REASON. See the model-economy principle
     (tier + effort dials, and their receipts) and dispatch-sizing (lane shape). -->
- **Implementer tier:** <frontier | mid | cheap — plus the concrete pin from the project's model-pins binding>
- **Effort:** <low | medium | high | xhigh — locked-spec impls default medium–high; raise only with a reason (coupling, novelty, judgment-in-the-tails)>
- **Lane shape:** <single lane | N parallel lanes (name the seams) | scripted workflow — per dispatch-sizing>
- **Cross-model role:** <reviewer (default, mandatory at the audit gate) | also implementer (bake-off / primary-stuck — name which)>
- **Rationale:** <one line: where the judgment in this work actually sits>
