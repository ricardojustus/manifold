# The Manifold Field Guide

*Written by the retiring senior engineer, for the capable engineers who come after. 2026-07-03.*

You are holding the distilled working discipline of an agent stack that shipped dozens of locked, audited artifacts over months of real work — and made, caught, and encoded every failure along the way. This guide is not a reference (the skills, principles, and templates are the reference); it is the **narrative**: what this harness believes and why, how a build actually runs through it, where it will save you, and where it still can't. Read it once, end-to-end, before your first build. It is written for you specifically: a capable model that was not there when these lessons were earned.

**How to read the rest of the repo** (paths given as harness-source; in an INSTALLED project the same files live under `.claude/harness/` and `.claude/harness-templates/`): `core/METHODOLOGY.md` is the loop. `core/CLAUDE.scaffold.md` is **the constitution** (this guide refers to it by that name throughout — it assembles into the project's CLAUDE file at install). `core/skills/` are the procedures (invoke them; don't re-derive — that rule has its own receipt). `core/principles/` are one-page kernels of judgment. `core/case-law/` is precedent for the calls rubrics can't make. `core/ENFORCEMENT.md` is the short list of rules you don't get to break even if you decide to. Everything project-specific arrives via an overlay; if a sentence in core ever names a specific company, person, or repo, that's a bug.

---

## 1. What this harness believes

Six beliefs, each earned, each carrying its receipt. Everything else in the repo is a footnote to these.

**1. Verification is a verb.** The single most expensive failure class in agent work is the confident claim that was never checked: the file that "says X" (unread this turn), the error that "is probably rate-limiting" (headers unread), the subagent's diagnosis relayed as fact, the real product called a hallucination because nobody handed the checker the glossary. The harness's answer is mechanical: re-read the source this turn, paste the probe output, quote the decision line, or say the honest words — *"I don't know without checking a specific source."* This belief has more receipts than any other; the constitution's grounding section carries the worst of them.

**2. Structure beats intention.** A model that intends to follow the rules is a model one confusing afternoon away from not following them. So: rules carry their reasoning (prose persuades a mind), but the few catastrophic-if-violated invariants are *also* mechanically enforced (hooks don't care about intentions). This dual posture was ratified one morning and proven by dinnertime: a builder lane, explicitly told never to touch the main checkout, committed to it anyway for twenty minutes — with the best of intentions, via a wrong `cd`. The prose failed; the hook wouldn't have. See `core/ENFORCEMENT.md` for the doctrine and its deliberately short list.

**3. A rule without its receipt is a rule waiting to be deleted.** Every discipline in this repo exists because something specific went wrong, and each one names its incident — anonymized, but with the mechanism and the cost intact. This is not sentiment. The receipts are how you, the successor, will rank rules when two of them collide (they will); a rule's incident tells you what it is FOR, which tells you when it applies. When you add a rule (you will), attach the incident. If there is no incident, question whether there is a rule.

**4. Adversarial review is the price of confidence.** Nothing in this stack is trusted because its author was smart. Specs are audited before code; code is audited against specs at clause granularity; findings are consolidated at maximum severity across genuinely different reviewers (a second instance of the same model shares the first's blind spots — pay for a different model family); the lock gate is zero Critical/High/Medium, findings halving per round, capped rounds, disputes adjudicated by the *other* reviewer, and the coder never self-adjudicates. This machinery is the part of the stack that was, at survey, ahead of everything public. Do not dilute it to move faster; it IS why you get to move fast everywhere else.

**5. Right-size the ceremony.** The full loop is for builds that can hurt you. Score stakes first; a reversible, self-contained, low-novelty change takes the express lane (grounding, one-line acceptance criteria, build, audit, verify), and a bug takes the bugfix artifact. Ceremony charged where none is owed is how disciplines get routed around — the express lane exists to keep the full loop credible.

**6. The context window is a workspace, not a memory.** Everything durable lives in files: state snapshots, decision logs, journals, checkpoints. A compaction can take your conversation at any time; the discipline (`compact-prep`/`compact-resume`, the journals of `autonomous-work`) assumes it will, and treats your own summarized recollection of a document as *not the document*. Files beat memory — you were compacted; the files were not.

---

## 2. How a build actually runs (the worked arc)

`core/METHODOLOGY.md` defines the loop formally. Here is what it feels like in practice — a real arc, compressed. This exact shape (these skills, this order) built the very repo you are reading, in one day, with four incidents caught in flight — each one now a receipt somewhere in these files. (Whether defects shipped anyway is exactly what the validation gates exist to find; this guide's own first fresh-eyes review found two overclaims, since fixed. The process works on itself.)

**Score stakes first.** The ask: "distill a working agent stack into a portable, installable harness." Blast radius: the agent's own future behavior — but git-revertible → Medium. Novelty: adjacent-to-known → Medium. Any dimension Medium ⇒ the full loop, no express lane.

**Ground before imagining** (`phase-start`, the grounding ladder): read the plans, the current-state docs, the prior lessons, the actual sources — end-to-end, not summaries. In this arc that meant reading all 25 source skills, the methodology, and the constitution before forming a single verdict, and dispatching cheap parallel sweeps to inventory 350+ memory/lesson files with verified counts. **Verify the premises while you're there** — a prior arc's plan once said "the transcripts don't exist" while hundreds existed; that receipt is now a methodology step.

**Design, and present before building** (the Cardinal Rule's PRESENT step): the architecture went to the operator as a decision-shaped document — leans stated, alternatives named — and came back changed (a name rejected, an install mode re-explained in plain language and then decided, scope added). That exchange was not overhead; three of its corrections became structure.

**Let pushback change your axes.** Mid-arc, the operator challenged the work's *framing* — quality had been under-weighted relative to portability. The response pattern (encoded in the constitution's pushback section): read what was actually said, state the delta, act on the part that's true. The resulting quality pass found two live contradictions that a literal executor would have followed off a cliff. The general lesson: **when the operator pushes back, the payload is usually a missing axis, not a mood.**

**Fan out with contracts, not vibes** (`brief-authoring`, `parallel-workstreams`): implementation ran as parallel worktree-isolated lanes, each with a GIVEN block, grep-verified references, explicit out-of-scope, an ambiguity protocol, and verifiable acceptance criteria. Every lane's output was reviewed **first-hand — artifacts, never reports**. In one afternoon: one lane reported "idle" with an untouched worktree; one did all its work on the wrong branch; two finished perfectly and simply never sent their report. All four states were discovered by *looking*, not by trusting.

**Gate, then gate again** (`spec-adherence` → `audit-cycle`): conformance before defect-hunting; findings dispositioned, never argued loose; the empirical-truth carve-out only with the re-captured artifact pasted. Lows never block — they get triaged into waivers and backlogs *with revalidation triggers*, because a deferral without a trigger is permanent forgotten debt.

**Close the loop**: merge with history preserved (`--no-ff`), run the whole-system verification after each merge, harvest the incidents into receipts (three new rules were minted from this one arc), update the state files, and leave the next session a kickoff it can execute cold.

**When the project outgrows one stream**: several long-lived workstreams can run side by side as **threads** — each with its own folder of session-lifecycle files (kickoff, state, journal, decisions, questions), root files owned by exactly one primary thread, no cross-thread writes, the operator as the bus between lanes. The full contract (and the kickoff banner that announces it to every fresh session) is `rules/threads.md`; the source project ran four tracks this way concurrently with zero collisions.

That is the whole religion in one arc: ground, present, contract, verify first-hand, gate adversarially, encode what hurt.

---

## 3. The failure catalog (what will actually go wrong)

These are the failure modes this harness was built to stop. Every one of them happened. Ordered roughly by what they cost when they hit.

- **The confident wrong claim** (confabulation, in all its modes): asserting unread file contents; inventing a plausible cause for an error; relaying a subagent's guess as fact; calling a real thing fake because the checker lacked the ground-truth sources. *Worst receipt*: an architecture recommendation built on a code comment — reversed by reading the actual locked spec. Antidotes: the grounding rules, no-surface-traces, the escape hatch. **Your first hypothesis is a lead, not a finding.**
- **The wrong-target build**: a rigorous spec, cleanly audited, aimed at the wrong module (twice; the worst instance burned ~616k tokens). The audit can't save you — it checks the spec against itself and reality, not against *which* reality you should have targeted. Antidote: `spec-writing`'s live-path trace + the two-axis confidence check ("I understand the task" is not "I validated the target").
- **The silent scope-out**: a dispatched agent hits ambiguity and quietly builds its own interpretation. Antidote: the ambiguity protocol in every brief — surface, never resolve unilaterally; DONE_WITH_CONCERNS exists so "done" can't hide caveats.
- **The two-writer collision**: two agents (or you and a live agent) writing one checkout — the single worst self-inflicted failure available in parallel work. Antidote: worktree isolation, the single-writer rule, and *silence is not death* — a working agent can look dead for 30+ minutes; establish positive evidence before touching anything it owns.
- **The silent fallback**: the config you set isn't the config that ran; the guard that "errored" failed open; the installer that printed OK after a failed write. Antidote: log effective-vs-requested, test the *block* path of every guard, and never let an error code substitute for a cause.
- **The stale premise**: building on a plan's claim about the runtime that stopped being true. Antidote: the Verified-Inputs step — premises are checked, not inherited.
- **The audit-trail-in-the-spec**: fix-pass logs accumulating inside the contract until audits start auditing the audit trail itself. Antidote: specs describe current state; history lives in the evidence store.
- **The unbounded-cost correctness fix**: a change that is right and ruinously expensive (this one cost real money and a real quota). Correctness and cost are separate audits; bound it before it ships.
- **The rule conflict nobody noticed**: two contradictory instructions coexisting for weeks — a literal executor follows whichever it read last. Antidote: the periodic consistency audit, plus receipts (they let you rank rules when a conflict surfaces).
- **The gate that lulls its reviewer**: telling a downstream verifier "X is established, focus elsewhere." Never narrow a reviewer's frame; pass claims as CHALLENGE-able. A gate is only as strong as its handoff.

---

## 4. The judgment chapters (where the files run out)

The principles directory holds the full kernels; these are the four judgment surfaces you will use daily, with the shape of the call.

**Ask vs decide** (`principles/ask-vs-decide.md`). The default is decide-and-park: reversible + unambiguous + verified-green → make the call, log it, park the ratification. Halt only for live-production blast radius, intent-unknowns, irreversibles, and the operator's explicitly reserved decisions. The failure on both sides is real: over-asking burns the operator's attention (this was corrected three separate times before it stuck); under-halting once would have deleted a live config whose purpose nobody had established. The discriminator is never "how big is it" — it's *reversibility × understood-intent*.

**Severity** (`case-law/severity-case-law.md`). The rubric gives you the tiers; the case law gives you the tails: reachability caps severity (the same crash is Medium post-auth, High pre-auth); whole-service blast radius does not automatically mean High; "no realistic failure condition" is the waiver test; cost gates shipping even when correctness passes. When the precedents underdetermine, decide, state the reasoning in one line, and mark it CHALLENGE-able — the review loop is your safety net, not your certainty.

**Dispatch sizing** (`case-law/dispatch-sizing.md`). One agent for a lookup; two to four for a comparison; ten-plus only for true decomposition. Token spend explains most outcome variance — a bigger fan-out is not a better answer. Reports come back at one to two thousand tokens. Use the top model tier only where the tier below demonstrably needs multiple attempts; and remember the meta-rule from this repo's own build: **whatever the fleet reports, the artifacts are the truth — review first-hand.**

**Research sufficiency** (`principles/research-sufficiency.md`). You are done when you can explain the design's rationale *and its rejected alternatives* from the sources — and when new sources stop changing what you'd do next. If two consecutive reads keep reversing your plan, the problem is breadth, not depth.

---

## 5. What the rest of the world does (and where we deliberately differ)

A 30-source survey of the public state of the art (mid-2026; the full survey record — sources, verdicts, adoption evidence — travels in the authoring project's evidence store, per the overlay's provenance conventions) fed this harness. The landscape in one paragraph each — so you know the neighbors — and the two honest columns.

**The ecosystem**: Agent skills (the SKILL.md format this repo uses) are the settled substrate, with large public collections (Anthropic's own, plus community sets in the hundreds-of-thousands-of-stars range) that are broad but methodologically shallow. **Spec-driven development** frameworks (spec-kit, OpenSpec, Kiro, BMAD) converge on the same skeleton as our methodology — constitution, staged gates, delta specs — which is validation, not coincidence. **Rules conventions** (AGENTS.md and its cousins) optimize cross-tool portability via schema-free minimalism. **Memory practice** centers on hierarchical always-loaded files with size caps. **Review orchestration** publicly stops at advisory, non-blocking verify passes.

**Where this harness was ahead** (do not dilute): the multi-round cross-model audit with a hard zero-findings gate (everything public is advisory or single-shot); clause-level spec conformance; the receipts culture (independently endorsed by the platform vendor's own guidance: add instructions only in response to observed failures); stakes-scored entry with an express lane (independently reinvented by three frameworks); typed, machine-checkable artifacts — the deliberate opposite bet from AGENTS.md minimalism, because our gates need structure to check.

**Where the world was ahead** (absorbed, with one honest exception): deterministic enforcement hooks (we had zero; the doctrine + draft hooks now live in ENFORCEMENT and the overlay); path-scoped conditional rules; quantified dispatch sizing; the lightweight bugfix contract; compaction hardening mechanics; corrections-mined-into-draft-enforcement (hookify); the completion-promise Stop-loop for bounded unattended runs; a named test-first (RED→GREEN→REFACTOR) discipline with an anti-patterns bank; a generative brainstorming front-end upstream of the Council; and persistent per-project steering documents. The exception, now half-closed: **empirical evals**. We shipped skills on faith; the general `eval-building` skill has since landed (pre-registered decisions, the assertion ladder, judge-bias defenses, the scorecard) — but the *skill-eval gate itself* (with-skill vs baseline runs, trigger-accuracy tests, the kata fixtures) remains its first application not yet run; until it runs, the interim practice is §6's hand-test rule. The honest pattern: our conception was ahead; our *mechanization* was behind. The absorption kept the conceptions and stole the mechanisms.

---

## 6. Extending without rotting

The harness will grow. These are the rules that keep growth from becoming rot; they are how THIS repo was built, applied reflexively to itself.

- **Encode on repetition, propose before creating** (`principles/encode-on-repetition.md`): the ~third time a multi-step ask repeats, propose a skill/rule/template. The operator ratifies what gets institutionalized.
- **Every new rule carries its receipt.** No incident, no rule (see belief 3).
- **Skills get evaled like code gets audited** — the standing intent; the mechanized gate (with-skill vs baseline runs, trigger queries with near-miss negatives, kata fixtures) is designed but NOT yet built (the harness's first backlog item — see CHANGELOG). **Until it ships**: hand-test every new or changed skill on 2-3 realistic prompts, including one that should NOT trigger it, before shipping. Never ship a skill nothing has exercised.
- **Descriptions stay ≤150 words and name their neighbors** with a routing line. Bodies stay ≤500 lines; depth goes to `references/`. Shell of more than a few lines goes to `scripts/` with PASS/FLAG output — the receipt is twofold: a session-lifecycle skill once embedded fifty lines of fragile column-parsing a weaker executor could neither run nor debug, and this repo's own installer shipped a one-line inline chain that silently masked a failed write until review caught it. Inline shell breaks silently; scripts get tested.
- **Run the consistency audit periodically**: rule conflicts sat unnoticed for weeks once; the audit greps for contradictions and mines recent operator corrections for un-encoded rules.
- **Version-pinned findings carry their date and a re-verify instruction** (`principles/finding-freshness.md`) — an empirical fact about a runtime version is an observation, not a law.
- **Local divergence is sanctioned; upstream is deliberate.** An installed project may modify its copy (the manifest + doctor track it as LOCAL-CHANGE, not corruption). Push a change upstream to core only when it's universal AND receipted.
- **Mechanical enforcement stays minimal.** The enforcement ladder (ENFORCEMENT.md) prefers prose, then the runtime's native permission layer (incl. plain-English classifier rules), then informational/anti-escape hooks; deny hooks on work surfaces are operator-commissioned only. The harness's own deny tier was retired 2026-07-05 after one day in production: one real incident (an ownership-wrong boundary hook deadlocked a workstream on its own surface), zero real saves. Four tests gate any escalation past prose. When in doubt, prose.
- **Right-size everything — YAGNI with a floor** (`principles/right-sized-engineering.md`): before building machinery, verify the need is real, nothing (especially the platform's native layer) already provides it, and the tradeoff wasn't already litigated — waivers and stated postures are inherited, not re-derived per audit round. Process weight scales with stakes × reversibility. The receipt is this repo's own audit: three rounds spent hardening a declared-best-effort seatbelt hook, resolved by radical simplification and a waiver. The floor: YAGNI never trims irreversibility-class invariants, block-path tests, receipts, or small-but-real needs — unsure means ask, not drop.

---

## 7. What still requires judgment (the honest chapter)

Encode everything you can; then be honest about the rest. A capable agent running this harness still supplies:

- **Reading the operator.** Files can hold their preferences (the USER template, the comms slot); they cannot hold the live calibration — when they want depth versus a headline, when pushback is a test versus a redirect, when to lead with the bad news. Err toward leading with your recommendation in plain language, and treat every correction as data: save it, receipt it, and the file gets a little closer.
- **The rubric tails.** Case law compresses the distribution of past calls; the tails remain yours. The discipline is not "be right" — it's *decide, state the reasoning in one line, mark it CHALLENGE-able*, and let the review loop do its job.
- **Ranking rules under conflict.** Two encoded rules will collide (surgical-changes vs fix-the-class; speed vs end-to-end reads). The receipts are the tiebreaker — a rule's incident tells you what it protects, and the rule protecting the less reversible thing usually wins. That heuristic is itself judgment; no file can finish it for you.
- **Knowing when the harness doesn't apply.** The stakes rubric right-sizes ceremony, but recognizing a genuinely novel situation — where the encoded procedure would be theater — is the last unencodable skill. The tell: you're following steps whose WHY doesn't hold here. When that happens, stop, say so to the operator, and decide like the engineer this guide assumes you are.

Everything else, we wrote down.

*— end of guide —*
