# Severity case law

The rubric defines Critical / High / Medium / Low; it cannot tell you where a specific finding lands. That call is taste built from dozens of dispositions — and taste compresses into precedent. Below are worked severity calls, each anonymized to its **finding shape → severity → the one-line reasoning**. Read them to calibrate the tails the rubric leaves open. When a new finding matches a shape here, the precedent is a starting point, not a verdict — state your call and mark it CHALLENGE-able (see the principle *verify-what-changes-your-next-action* and the constitution's grounding rule).

Entries marked `[synthesized archetype]` fill a gap the real registries didn't cover; the rest are anonymized real dispositions.

## The disposition axes (what actually moves severity)

- **Reachability** — can an attacker or an ordinary input trigger it, and from where? A crash reachable *pre-auth* by anyone outranks the identical crash reachable only *post-auth*.
- **Reversibility** — does one occurrence cause damage git can't undo (exfiltration, data loss, destroyed shared history)? Irreversible pushes severity up hard.
- **Realistic failure condition** — is there a concrete, reproducible scenario where it bites, or only a theoretical one? "No realistic failure condition" is the single most common reason a finding is waived to Low.
- **Blast radius** — does it take down one request, one session, or the whole service?
- **Cost** — a correct change can still be unshippable if its recurring cost is unbounded (cost is a *decision* risk, not a defect risk, but it still gates ship).

---

## Critical

- **A drain/promotion step gated on the wrong condition (author identity, not ledger state) → Critical.** *Reasoning:* it silently lets the wrong records through the one gate meant to hold them; the failure is invisible and corrupts durable state. Caught only by the cross-model lens after every same-family lens rated it clean — the archetypal "why the second model family is load-bearing" catch.
- **A waiting/queued unit of work that isn't crash-durable → Critical (on a core substrate).** *Reasoning:* a resurrectable waiting item that survives a crash into an inconsistent state is a data-integrity break on the substrate everything else builds on. Durability of in-flight state on a core substrate is a Critical-tier property, not a nice-to-have.
- **A model-callable safety-override parameter exposed in a tool schema (`force` / `bypass` / `skip`) → Critical; fix by removing it, not guarding it.** *Reasoning:* any model-reachable override is a structural prompt-injection escalation path, and the "we'll log it" mitigation logs the bypass *after* the bypassed action. The disposition that matters: this was ratified as **surface-narrowing** (drop the parameter entirely), not incremental hardening — removing the capability is the fix, guarding it is not.

## High

- **A crash vector reachable only after authentication → Medium, not High.** *Reasoning:* an un-caught exception through an async handler that takes down the whole service is severe, but if it's reachable only by an already-authenticated caller, the reachability ceiling caps it at Medium. The identical crash reachable *pre-auth* would be High. Same crash, different severity — reachability is the axis. *(This is the load-bearing precedent: whole-service blast radius does NOT automatically mean High; reachability gates it.)*
- **A new write target not covered by the deny-list → High.** *Reasoning:* a compromised or prompt-injected agent could clobber it via a native write path that bypasses the mediated layer — the blast radius is a security boundary, and "category-symmetry blindness" (the new target didn't inherit the existing deny doctrine) is exactly what the author can't see in their own work.
- **A missing rejection belt on a fire-and-forget async call whose throw isn't caught anywhere → High.** *Reasoning:* the unhandled rejection propagates to a process-level crash; a reviewer *probe-proved* the whole-service crash through a non-fatal-boot scenario. What made it High rather than Medium: it was reachable through a normal, non-attacker path, and the blast radius was the whole service.
- **A contract asserted but never defined (a stable-anchor guarantee with no slug algorithm, dup-heading rule, or resolution precedence) → High (spec-stage).** *Reasoning:* an undefined contract that downstream code is told to rely on is a High-severity gap at spec time — it will be implemented three incompatible ways. Define the one contract before lock. `[synthesized archetype]`-adjacent: real disposition, generalized.

## Medium

- **A required test named by the spec but not landed → Medium.** *Reasoning:* the code may be correct, but the spec-mandated guard is absent, so a future regression has nothing to catch it. One lens rated these sub-threshold and recommended merge; the cross-model lens caught both — MAX-severity consolidation makes the higher call operative.
- **Client-controlled input interpolated raw into a log line (log-injection / CWE-117) → Medium.** *Reasoning:* it can forge log entries or break log parsing, but it isn't remote code execution or exfiltration — real, worth fixing, not Critical. Notably this was *introduced by a hardening fix-pass* that added a raw interpolation while closing a different finding, and caught by both lenses — a receipt for re-auditing the fix, not just the original.
- **A parameter that conflates two distinct meanings (a content-genre value doubling as a query filter) → Medium.** *Reasoning:* it's a correctness-and-clarity defect that will silently merge things that should stay distinct; contained and fixable, so Medium, but it must be split before it calcifies into the schema.
- **A required index-sync mechanism omitted (external-content FTS with no triggers) → Medium.** *Reasoning:* the keyword index silently won't populate — a real functional gap, but discoverable and fixable pre-ship with a smoke query; Medium because there's a deterministic fix and no data-integrity risk.

## Low (and what earns a waiver vs a backlog entry)

The lock gate drives C/H/M to zero; **Lows never block** — every Low is triaged into *waive* (no realistic failure condition), *backlog* (foreseeable trigger), or *promote* (actually a Medium). The disposition is the whole value:

- **A soft, report-only pointer that ratification later resolves → waive.** *Reasoning:* e.g. a stamp that points at a slightly different but still-in-threshold anchor — both are valid, the stamp is a review-queue hint, and human/automated ratification resolves identity regardless. No realistic failure condition.
- **A counter that's report-only and never gates anything → waive.** *Reasoning:* an idempotent replay that counts a no-op re-apply is spec-documented behavior; the number is informational, the health gauge reads the real table. Nothing downstream acts on it.
- **A trivial always-spread / redundant-idempotent-call on a hot path → waive, and do NOT "optimize" it.** *Reasoning:* the cost is O(field-count) or an idempotent re-resolve; removing it adds a branch and risks a future fail-open bug, and it matches a codebase-wide discipline. The reviewer explicitly flags: leave it. A "make this stricter/faster" finding here is usually the empirical-truth carve-out in disguise.
- **A contract-vs-behavior contradiction whose own writeup acknowledges zero practical impact → close by updating the stated posture to match behavior (empirical-truth carve-out); this is a legitimate Low closure, NOT a downgrade.** *Reasoning:* when the auditor's *own* text says "not a data-integrity issue" (the OS reclaims the resource on exit, the write-ahead log handles it), aligning the posture to reality closes it honestly. **Never** carve out when impact isn't acknowledged-zero, when evidence is contradicted, or for Medium-and-up — those need operator ratification.
- **A YAML/frontmatter strictness finding rated Critical by one lens but empirically loaded fine → carve to Low.** *Reasoning:* the real loader is lenient (every sibling artifact uses the same pattern and loads), and the "defensive" fix risks *breaking* the working loader — net-negative. Empirical truth beats literal-spec strictness; the carve is logged with a revalidation trigger (revisit if the loader switches to strict parsing).
- **A metric that's diluted / invisible but bounded, self-healing, and honest → backlog with a trigger.** *Reasoning:* e.g. a truncation counter dominated by hub-degree noise, or a section that can silently shrink but never renders wrong content. No wrong output today, but a foreseeable evaluation needs the signal — backlog it keyed to that evaluation ("revisit at the day-7 eval / the 3-night soak"), don't fix speculatively.
- **A latent forgery/parsing gap whose containment currently holds → backlog keyed to the expansion that would expose it.** *Reasoning:* e.g. a forged opening tag that rides verbatim while containment holds — risk rises only when more readers consume the surface, so the trigger is "when read-wiring expands," paired with a locked-spec amendment.

## Cross-cutting

- **A correct change with unbounded recurring cost → not shippable until bounded.** *Reasoning:* correctness and cost are *separate audits*. A fix judged benign for correctness once shipped with per-item model calls that, compounded with an uncapped candidate list, drove a large daily spend spike and exhausted a periodic quota. "Benign for correctness" is never "benign for cost." Bound it (cap, timebox, kill criteria) first. This is a *decision* risk, so a High-on-cost chunk owes a control artifact, not a technical one.
- **MAX-severity consolidation across lenses, with an empirical-truth carve-out.** *Reasoning:* when two lenses disagree on severity, the *higher* call is operative — never downgrade a finding because the other lens said merge. The one exception is the empirical-truth carve-out above: a higher rating that rests on a *stale or empirically-false* artifact gets re-captured or corrected, not rubber-stamped.
