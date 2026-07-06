# Build Methodology

> The way a project takes anything from idea to shipped artifact. It is a **loop, not a line**. Every backward edge is a deliberate, recorded re-open, never a silent edit. The Council advises; **the Human and the Orchestrator decide.**
>
> Entry is gated by the **project stakes score**, not the build-type label — Low stakes takes an **express lane**, Medium/High runs the full eight phases (see Project stakes). **Abandon** is a terminal disposition with a Kill record (see Locks and re-opens). All findings live in one **Evidence Store** with `councils/` and `audits/` as parallel sub-trees (see Records). Cross-examination **defaults to 1 round** (see The Round Table).

**Entry is by stakes, not by label.** Score the build on the project stakes rubric (below) first. A build whose **max-of-dimension stakes come out Low takes the express lane**; **Medium or High runs the full eight phases.** The gate is the stakes score, so a trivial feature can't trip the full loop (and get routed around), and a load-bearing one can't slip the gate by calling itself "just a feature." A whole subsystem (several components plus their orchestration) typically scores Medium+ and runs the full phases; a single reversible change scores Low and takes the express lane. This methodology describes **roles**, not specific agents — map your actual agents onto these roles in their own identity files. Agents read it before scoring stakes and treat its gates and authority rules as binding.

**Where things are filed.** The methodology requires an **Evidence Store** — a project root where locks, findings, and audit/council records live. This document calls that root `<artifact-root>`; the overlay binds it to a concrete path (each overlay binds it to a concrete path — a docs tree, a repo folder). Wherever you see `<artifact-root>/audits/<topic>/` or `<artifact-root>/councils/<topic>/`, read the project's configured root.

---

## 0. Core principles

1. **Loop, not line.** The forward spine is 0 to 8. The backward edges (Gate A or Council to Vision, Council to Plan, Implementation to Plan or Spec, and an architectural re-open challenging a Phase 0 repo constraint) are travelled only by deliberate, authorized, recorded re-opens.
2. **Authority is human-first.** Final authority is the **Human**. Delegated authority for routine decisions sits with the **Orchestrator / Main agent**. The **Council is advisory only**: it produces severity-rated findings and arguments, and it has zero power to change an artifact or trigger a loop-back on its own.
3. **Ground truth anchors everything.** Two anchors keep the loop honest: the **repo** (established in Phase 0) and the **acceptance criteria** (written in Phase 1). Audits and Councils check work *against these anchors*, not against taste.
4. **Right-size the rigor.** Two independent dials:
   - **Project stakes** (Low / Medium / High) drive whether Gate A runs and how large the Council is.
   - **Chunk risk** (Low / Medium / High / Critical) never decides *whether* to audit. Every artifact gets the same kinds of scrutiny: the full cross-model lens always runs. What scales by tier is the **lock-gate floor** (which severities must reach zero), the **required hardening artifact**, and the **evidence burden**. Cost scales on its own, because the audit-cycle converges: a glue chunk clears in a round or two for almost nothing, while a Critical foundation earns several rounds.
5. **Locks are decisions, re-opens are events.** Both are recorded to the decision log (Evidence Store). A locked artifact is the single source of truth until a logged re-open supersedes it.
6. **Encounter reality early.** Analysis and review reduce uncertainty only so far. A feasibility unknown is retired by a spike, not by more research or another Council. Integration risk is retired by vertical slices and a real release gate, not by validating chunks in isolation. Prefer the cheapest probe that touches reality over the most thorough argument about it.
7. **Assess operational cost before shipping — quota IS cost.** Every feature, change, or design choice must have its *recurring runtime* cost impact assessed and recorded BEFORE it ships — distinct from the stakes rubric's one-time "Build cost." Two cost surfaces, both mandatory: **metered spend** (per-token API) AND **flat-rate account quota/throughput** (a subscription's periodic cap is a finite, exhaustible resource — burning it is a real cost even when zero dollars are metered). Name the cost dimension explicitly in the spec/plan and answer: does this add model/embedding calls per item processed? Does the per-call input scale with **corpus or graph size** (the unbounded-candidate trap)? Can it **fan out** (one call per item) or **retry-storm**? A change that is correct but unboundedly expensive is **not shippable** — bound it first. "Benign for correctness" is NOT "benign for cost"; they are separate audits. *Receipt: a graph edge-inflation fix once shipped with its edge growth measured only for correctness (judged benign) while its cost dimension was never checked — it multiplied per-item model calls and, compounded with an uncapped candidate list, drove a ~$20-25/day spend spike plus weekly-quota exhaustion. Correctness-benign, cost-catastrophic.*

---

## Roles

| Role | Responsibility |
|---|---|
| **Human** | Ultimate authority. Co-signs Locks. Final say on every re-open. |
| **Orchestrator / Main agent** | Runs the process end to end. Holds delegated authority. Drafts the Vision Doc in Phases 1 and 3 on the Human's direction. Convenes the Council, synthesizes its findings, dispositions them, owns Locks and re-opens on the Human's behalf, and escalates anything above its delegation. |
| **Builder** | Phase 0 grounding, Phase 2 research, Phase 6 specs, Phase 7 implementation. |
| **Auditor** | Runs the `audit-cycle` on every spec and every implementation: the same cross-model lens every time. The chunk's risk tier sets the lock-gate floor and the evidence burden, not whether the audit happens. |
| **Round Table** | Ephemeral panel spawned only for the Council (Phase 5 and Gate A). At full strength, 2 strong-reasoning + 2 cross-model seats, four adversarial roles. Advisory only. Disbanded after each sitting so nothing it argues contaminates later phases. |
| **Untrusted-content handler** | Fetches and quarantines untrusted external content when research reaches the open web. |

The Council is deliberately **not** the agents who built the thing. Freshness is the point: a builder defending its own plan is not an adversary.

---

## Project stakes rubric

Score the build on each dimension. **Project stakes = the highest tier reached on any single dimension.** One High dimension makes the whole project High. This is conservative on purpose: it is cheaper to over-review a build that turned out simple than to under-review one that turned out load-bearing.

**Stakes can be downgraded, but only with evidence.** Because the max-of-dimension rule is conservative, it is one-directional by default. A dimension can be lowered, and the project re-scored down, when something concrete retires the risk that raised it — most often a spike that resolves a novelty unknown. The downgrade is logged with the evidence that justified it (the spike result, the retired unknown). There is no silent de-escalation.

| Dimension | Low | Medium | High |
|---|---|---|---|
| **Reversibility** | Undo in under a day | Days to redo | Architectural, hard or impossible to cleanly reverse |
| **Blast radius** | Self-contained, no dependents | One shared component or a few dependents | Core shared substrate (the project's central data store or engine) or many dependents |
| **Novelty** | Done before, standard pattern | Adjacent to something known | First-principles, unprecedented |
| **External commitment** | None | Internal stakeholders only | A contract, a partner, a public launch, or money is on the line |
| **Security / privacy** | No sensitive data, no new attack surface | Internal-only sensitive data, limited surface | Confidential IP, user data, credentials, or a new external attack surface (partner NDAs, restricted material) |
| **Build cost** | Hours to one day | Days to ~two weeks | Weeks or more, or expensive to get wrong |

**What stakes control:**

| Project stakes | Gate A (early vision challenge) | Phase 5 Council |
|---|---|---|
| **Low** | Skip | **Dropped** — Low takes the express lane (below), so the Phase 5 Council is skipped; human review suffices. An out-of-method advisory pass only on explicit request. |
| **Medium** | Optional (Orchestrator's call) | 2 seats: 1 strong-reasoning + 1 cross-model. Full Round Table at the Orchestrator's discretion. |
| **High** | **Required** | **Full 4-seat Round Table: 2 strong-reasoning + 2 cross-model.** |

**The express lane (Low stakes).** A build that scores Low on every dimension does **not** run the full eight phases. It runs: **Phase 0** grounding + **acceptance criteria** (one line each is fine) → **build** → **`audit-cycle`** on the implementation (at the chunk's risk-tier floor) → a **lightweight release verify** (does it meet the one-line acceptance criteria). It **drops** Phase 2 deep research, Gate A, the Phase 5 Council, and per-chunk spec ceremony. This is not a lesser process; it is the right-sized one for reversible, self-contained, low-novelty work, and it keeps the full loop credible by not charging ceremony where none is owed. **A bug fix is the archetypal express-lane build** — it uses the Bugfix artifact below in place of a full spec. The instant any dimension would score Medium+, the build leaves the express lane and runs the full phases.

**The Bugfix artifact (the express lane's default spec).** Bugs fall between the full 8-phase loop (too heavy) and ad-hoc patching (too loose). A bug is scored on the stakes rubric like anything else — most land Low and take the express lane — and its lightweight contract is a **Bugfix artifact** with five fields:

- **Symptom** — the observed failure, verbatim (the error, the wrong output, the repro steps). Not the guessed cause.
- **Root cause** — traced, not assumed. One evidence link. (See the constitution's error-triage discipline: an error code is a symptom, never a cause.)
- **Fix** — the change, scoped to the root cause.
- **Unchanged-behavior invariants** — what MUST still hold after the fix: the behaviors the surrounding code depends on that this change must not perturb. This is the surgical-change contract made explicit.
- **Regression test** — a test keyed to those invariants: it fails on the bug (proving the repro) and passes after the fix (proving the fix), and it guards the invariants against a future re-break.

A High-stakes bug (irreversible, core-substrate, security boundary) leaves the express lane and takes a full spec like any other High chunk — the Bugfix artifact is the Low-stakes default, not a ceiling.

---

## Chunk risk tiers

Set during Phase 4 planning. Every chunk in the plan carries a tag. **The tag never decides whether to audit.** Every spec (Phase 6) and every implementation (Phase 7) gets the same kinds of scrutiny from the `audit-cycle` skill: the full cross-model lens, MAX-severity consolidation, multi-round to convergence, the 5-cycle cap, dispute adjudication by the other model, and the waiver / backlog / disputed registries.

What scales by tier is the **lock-gate floor** (which severities must be driven to zero before the artifact locks, versus which get triaged), the **required hardening artifact**, and the **evidence burden**. Cost scales on its own through convergence.

| Chunk risk | Lock gate (must reach 0) | Below the floor |
|---|---|---|
| **Low** | C, H | M and L triaged with the same waive / backlog / promote discipline the skill applies to Lows |
| **Medium** | C, H, M | L triaged |
| **High** | C, H, M | L triaged |
| **Critical** | C, H, M, L = 0/0/0/0 | nothing deferred; Lows are fixed, not merely triaged |

The audit mechanics are owned by the `audit-cycle` skill and are identical at every tier. The chunk tag only moves the floor.

- **Medium shares the audit skill's default floor** (C/H/M = 0).
- **High shares that floor but owes a hardening artifact.** Beyond C/H/M = 0, a High chunk must also produce one extra deliverable, determined by the dimension that pushed the chunk to High (chunks are scored on the same dimensions as project stakes, at chunk scope): high reversibility owes a rollback or migration proof; high blast radius owes an integration or regression proof; high novelty owes a spike or benchmark proof; high external commitment owes a release, comms, and support checklist; high security/privacy owes a threat model. Build cost is the exception only in kind: a chunk that is High on cost alone owes no *technical* hardening artifact, since cost is not a defect risk, but it does owe a **control artifact** (kill criteria, a timebox, milestone cuts, or a fallback scope), because cost is a decision risk and a high-cost chunk with no kill criteria is how a build runs away. This deterministic mapping is what keeps the High label from decaying into theater.
- **Low relaxes it**: Mediums on a Low-risk chunk may be triaged rather than mandatorily fixed.
- **Critical is an explicit escalation, not a dimension score.** A chunk is tagged Critical when it carries one of: an irreversible migration, a security or trust boundary, a core-substrate change, data-loss risk, or a record of repeated audit failure (a chunk that will not converge inside the 5-cycle cap escalates here). Critical does two things beyond High: it tightens the lock gate so Lows are driven to zero too (overriding the skill's "Lows never block lock" rule), and it inherits the applicable High hardening artifact(s), on top of which the Auditor may require one additional reproducible proof.
- **The tags themselves are a review target.** Because a lower tier earns an easier floor, there is an incentive to mislabel a chunk as lower-risk than it is. The human eyeball gate (Phase 4) and the Council's Plan review (Phase 5) both check that chunks are honestly tagged. A tag that gets reviewed is harder to quietly game.

**Evidence burden by tier** (what proof the audit must show, not whether the lens runs): Low clears on automated evidence where available (tests, lint, typecheck) or equivalent mechanical verification for non-code artifacts; Medium adds targeted verification of the changed behavior; High requires a mapped proof tying each acceptance-relevant claim to concrete evidence; Critical requires reproducible proof (another agent can re-run it) plus a retained audit trail. This is the "paste the grep, do not claim it" rule, tiered.

Note this is a different mechanism from the Round Table Council (Phase 5 / Gate A). The Council is a qualitative, advisory panel reviewing the Vision and Plan. The `audit-cycle` is a per-artifact pre-merge gate using a Claude-reviewer-plus-cross-model pair. Do not conflate the two.

---

## The phases in detail

### Phase 0 — Ground in the repo
- **Purpose.** Orient in what already exists before imagining anything, so the Vision is built with the grain of the codebase rather than against it.
- **Owner.** Builder.
- **Activities.** Read the relevant repo: current architecture, conventions, naming, what is already solved, which constraints are load-bearing. Strictly local and narrow. This is *not* the deep research of Phase 2.
- **Output.** A short **current-state note**: what exists, what is reusable, what is off-limits, and the open questions the build will need to answer.
- **Exit criteria.** The current-state note exists and names the constraints the Vision must respect.
- **Phase 0 facts are immutable; the architecture they describe is not.** The current-state note records what the repo *is*, and that observation is never silently rewritten to suit the plan. But the repo is ground truth descriptively, not normatively: sometimes the correct finding is that the current architecture is itself the problem. A repo constraint can be challenged through a recorded **architectural re-open** (see Backward propagation), never through a quiet edit to the note.
- **Verify the premises, don't inherit them.** A plan or a prior doc can assert facts about the runtime that are no longer true. Before building on any such premise, verify it against the *current* system, and record what you verified. (Receipt: a build once proceeded on a plan that said the input transcripts didn't exist; hundreds of them did. The premise was never checked. A §0 "Verified Inputs" note is cheap insurance against building on a stale assumption.)

### Phase 1 — Vision
- **Purpose.** Decide what we are building and why, and what "done" looks like.
- **Owner.** Human owns the decisions; the Orchestrator does the writing.
- **Activities.** Discuss the vision with the Human, who sets direction and content. The Orchestrator writes it into the **Vision Doc**, grounded by the Phase 0 note.
- **Output.** Vision Doc. **Must include acceptance criteria / a definition of done.** Without falsifiable acceptance criteria, later audits have nothing objective to check against and degrade into opinion.
- **Exit criteria.** Vision Doc written and acceptance criteria are concrete enough that a third party could judge whether the finished thing meets them.

### Phase 2 — Deep research (bounded)
- **Purpose.** Learn what the wider world already knows so the Vision is informed, not naive.
- **Owner.** Builder; the untrusted-content handler for any untrusted external fetches.
- **Activities.** First derive a **bounded list of research questions** from the Vision. Then research deeply across local files and online references, fanning out with dynamic workflows. **The research budget is the question list.** Stop when the questions are answered, not when curiosity is exhausted.
- **Output.** A research findings note, organized by the questions it answers.
- **Exit criteria.** Every research question is either answered or explicitly marked unanswerable with a reason.

### Phase 3 — Refine vision
- **Purpose.** Fold findings back into the Vision before any planning effort is sunk.
- **Owner.** Human owns the decisions; the Orchestrator does the writing.
- **Activities.** On the Human's direction, the Orchestrator updates the Vision Doc and acceptance criteria in light of Phase 2, resolving the contradictions the research surfaced.
- **Output.** Updated Vision Doc.
- **Exit criteria.** The Vision is consistent with what research revealed, and acceptance criteria still hold.

### Spike path — empirical probes (as needed)
- **When.** Any time from Phase 2 onward, whenever a feasibility unknown is identified that reading and arguing cannot settle: a tool or model choice, a throughput target, an integration that might not hold, a performance ceiling.
- **Purpose.** Retire a specific unknown with the cheapest experiment that touches reality. Research tells you what others claim; a spike tells you what is true in your environment.
- **Owner.** Builder.
- **Rules.** A spike is time-boxed and scoped to one named question. Its only output is a **learning**, recorded as a finding that feeds the Vision (Phase 3) or the Plan (Phase 4). A spike never ships: throwaway by default, so it is never quietly promoted into the build. If its result deserves to live on, it re-enters as a normal chunk with its own spec and audit.
- **Exit criteria.** The named unknown is resolved to a recorded learning, or explicitly marked still-open with the residual risk flagged for the Council.

### Gate A — Optional vision-only challenge
- **When.** **Required** if project stakes are High. Optional at Medium (the Orchestrator decides). Skipped at Low.
- **Purpose.** Catch "should we even build this" *before* planning effort is sunk. The most expensive mistakes live in the Vision, and they are cheapest to kill here.
- **Owner.** The Orchestrator convenes a lightweight Round Table sitting against the **Vision only** (no plan exists yet).
- **Outcome.** Findings go to the Orchestrator and the Human. They may loop back to Phase 1 or 3, **abandon the build outright** (a logged Kill), or proceed. The Council does not decide; it informs.

### Phase 4 — Plan
- **Purpose.** Turn the locked-in-spirit Vision into a buildable plan.
- **Owner.** Builder drafts; the Orchestrator reviews; the Human eyeballs.
- **Activities.** Break the work into chunks. **Prefer vertical slices** (thin end-to-end pieces that each exercise the whole stack) over horizontal layers wherever dependencies allow, so integration reality and learning arrive at slice one instead of at the end. Set order, priority, dependencies, and architecture. **Tag every chunk with a risk tier** (Low / Medium / High / Critical), and for any High chunk name its required hardening artifact. Record the Plan.
- **Human eyeball gate.** Before convening the expensive Phase 5 Council, the Human does a quick sanity pass on the Plan: (1) does the Plan match the Vision, (2) are the risks honestly tagged, (3) are chunks ordered so learning comes early, (4) is anything obviously unwanted, (5) is the cost acceptable. This is a thirty-second gate, not a ritual: it exists to catch the thing the Human would kill on sight before Council cycles are spent on it. An under-tagged chunk (check 2) is the cheapest place to catch gaming.
- **Competing-architectures option (High/Critical designs).** When the plan's central design choice is high-stakes, don't settle for the first architecture: race two or three designer agents in parallel, each given a deliberately DIFFERENT mandate — smallest-possible-change, cleanest-long-term-structure, pragmatic-balance — then lay the proposals side by side (what each costs, what each buys, where each breaks) and let the Human pick or direct a merge. A few agent-minutes at plan time buys visibility into the trade-off space instead of trust in a single designer's instincts. Skip it for Low/Medium designs — one good architecture and the eyeball gate is enough. *(Pattern from Anthropic's first-party feature-dev plugin, MIT.)*
- **Output.** Plan Doc with chunked, ordered, risk-tagged work and a dependency map.
- **Exit criteria.** Plan recorded, every chunk risk-tagged, Human has done the eyeball pass.

### Phase 5 — Round Table Council, then Lock
- **Purpose.** Subject the Vision *and* the Plan to fresh adversarial scrutiny from first principles, then lock both.
- **Owner.** The Orchestrator convenes and synthesizes. The Round Table argues. The Human co-signs the Lock.
- **Activities.** See **The Round Table** section below for seats, roles, and run format.
- **Disposition.** The Orchestrator collects the Council's severity-rated findings into one list. For each finding, the Human or the Orchestrator chooses one of: **re-open** (loop back, see governance), **waiver** (accept the risk, logged), **refine in place**, or — when a finding kills the build itself — **abandon** (terminal; recorded as a Kill, see governance).
- **Lock.** Once dispositioned, the Human co-signs a **Lock** on the Vision and the Plan. A Lock is a recorded decision, not a mood. Locked artifacts are the source of truth until a logged re-open supersedes them.
- **Exit criteria.** All findings recorded. High and Critical dispositioned before lock; Medium and Low waived, backlogged, or refined per policy. Vision and Plan Locked.

### Phase 6 — Specs
- **Purpose.** Produce a detailed, authoritative spec for each chunk.
- **Owner.** Builder writes; Auditor audits.
- **Ground FULLY before writing — no surface traces.** Before authoring a chunk's spec, understand the system it touches *fully* from the **actual specs** (the LOCKED ones AND their stale/archived predecessors — a superseded spec still records *why* the architecture is shaped as it is), the project's **documentation-retrieval system** (its indexed doc corpus, if it has one), and the real code paths read **end-to-end**. A function signature, a `grep` hit, or a doc-comment header proves a thing *exists* — it is **not** grounding, and it does not tell you *why* the design is built that way or *how data actually flows*. The bar: you can explain the design's rationale and its rejected alternatives *from the sources*, not from inference. **Do not write the spec until that bar is met.** (Receipt: a chunk author once proposed "decouple X from Y" off a comment header; reading the LOCKED spec showed the codebase couples them deliberately, and reversed the call. The `spec-writing` skill owns the full procedure.)
- **Activities.** Work chunk by chunk in Plan order. For each chunk, write the spec, then run the `audit-cycle` (the same cross-model lens every time). The chunk's risk tier sets the lock-gate floor and evidence burden (see Chunk risk tiers).
- **Output.** One Locked spec per chunk.
- **Exit criteria.** Spec passes its tier's audit gate; the spec carries its **implementation-dispatch triage** (implementer tier + reasoning-effort + lane shape + cross-model role — the author who best understands the chunk's complexity recommends; the dispatcher overrides only with a stated reason; see the model-economy principle). Lock the spec. At dispatch time, Agent-tool implementations use the **`implementer` role** (`core/agents/implementer.md` — the standing conventions live there; the brief carries the GIVEN block + spec) with the triage's model passed as the per-invocation `model` parameter; the role file deliberately pins neither model nor effort, so the triage stays in charge.

### Analyze gate — Pre-implementation consistency (agent-run)
- **When.** After the chunk specs exist and before implementation begins — the seam between Phase 6 and Phase 7. Advisory, like the Human eyeball gate, but agent-run and cross-artifact.
- **Purpose.** Catch the contradictions *between* artifacts that a single-artifact audit can't see: a spec that assumes an interface a sibling spec doesn't provide, an acceptance criterion no chunk covers, a plan dependency the specs invert. These are cheapest to catch before code is written against them.
- **Owner.** An agent (not the spec's author) runs a consistency pass over the locked artifact set.
- **Activities.** One pass, one section, producing a short findings note: (1) **coverage** — every Phase 1 acceptance criterion maps to at least one chunk/spec; every locked spec traces back to a plan chunk; (2) **contradiction scan** — cross-spec interface and assumption conflicts; (3) **premise check** — the specs' stated runtime premises still hold against the current system (see Phase 0's verify-the-premises rule). Advisory: findings route to the Orchestrator, who dispositions them (amend a spec, re-open, or waive with rationale) before implementation.
- **Exit criteria.** Every acceptance criterion is covered or its gap is dispositioned; no un-dispositioned cross-spec contradiction remains; premises confirmed. This gate never *blocks* on its own authority — it informs the Orchestrator, exactly like the eyeball gate.

### Phase 7 — Implementation
- **Purpose.** Build each chunk to its spec.
- **Owner.** Builder builds; Auditor audits.
- **Activities.** Implement in Plan order. Run the `audit-cycle` on each implementation (the same cross-model lens every time); the chunk's risk tier sets the lock-gate floor and evidence burden, same as Phase 6.
- **Output.** Working, audited implementation per chunk, with the audit result pinned to an exact code state (commit hash, diff hash, or release-candidate ID). The merge commit, or an equivalent versioned artifact hash for non-git deliverables, is the implementation's lock.
- **Exit criteria.** Implementation passes its tier's audit gate, satisfies the chunk's slice of the Vision's acceptance criteria, and the audit record names the hash it covered, so "passed audit" cannot later drift from the code.

### Phase 8 — Integrate and release
- **Purpose.** A green chunk is not a shipped product. This phase validates the assembled whole, which is where the Phase 1 acceptance criteria finally pay off: they were written so something downstream could verify against them, and this is that something.
- **Owner.** Builder integrates; Auditor runs the final gate; the Human signs off.
- **Activities.** Assemble the chunks. Verify the system end to end against the **Vision's acceptance criteria** (the whole, not the per-chunk slices). Confirm the release essentials are in place: deployment path, a rollback or recovery path appropriate to the artifact, docs, and post-release observability or verification appropriate to the artifact. A server gets rollback and monitoring; a doc or local tool gets version restore and a verification step instead.
- **Output.** A release candidate that satisfies the acceptance criteria, with the appropriate rollback-or-recovery path and post-release verification wired.
- **Exit criteria.** Every Phase 1 acceptance criterion is demonstrably met end to end, the rollback or recovery path is tested, the appropriate post-release observability or verification is in place, and the Human has signed off. Only then does the build ship.

---

## The Round Table

The Council is a fresh, ephemeral panel spawned for Gate A and Phase 5. At full strength (High stakes) it is **four seats: 2 strong-reasoning + 2 cross-model**, each given a distinct adversarial role. Diversity of role beats raw model count: telling two strong models to "argue" yields shared blind spots, while assigning genuinely different mandates forces genuinely different attacks. (The overlay pins which concrete models fill the strong-reasoning and cross-model seats.)

| Seat | Default model class | Mandate |
|---|---|---|
| **The Advocate** | strong-reasoning | Argues from the end user or player. Does this actually serve and delight them? Where does the experience break down? |
| **The Premise Skeptic** | strong-reasoning | Attacks the core premise from first principles. Should we build this at all? What is the strongest case for a completely different approach, or for doing nothing? |
| **The Feasibility Skeptic** | cross-model | Technical and resource realism. Can this be built with the stack, the constraints, the timeline? Where is the hidden complexity? |
| **The Systems Critic** | cross-model | Coherence and second-order effects. Does the Plan actually deliver the Vision? Are the dependencies, ordering, and architecture sound? What breaks at scale or under load? |

Model-to-seat mapping is a sensible default (the strongest qualitative reasoner on the conceptual seats, a genuinely different model on the technical and architectural seats), not a law. The Orchestrator may remap if a particular build calls for it. **Cross-model is the point** — two seats from a model family genuinely different from the primary reasoner, because a second instance of the same model shares the first's blind spots.

**Run format.**
1. The Orchestrator briefs each seat through that seat's mandate rather than handing all four an identical prompt. Shared framing is how four models arrive at one shared blind spot.
2. Each seat produces a **fully independent first pass** before seeing any other seat's. Each finding states its assumptions, a confidence level, and the strongest counterargument the seat can muster against its own finding.
3. Only then do the seats cross-examine each other — **one round by default; zero for cheap sittings** (the Orchestrator may set 0 at Low/Medium to favor speed and maximal independence).
4. Each finding is recorded as: `{ severity: Low | Medium | High | Critical, target: vision | plan, claim, assumptions, confidence, steelman, suggested disposition }`.
5. The Orchestrator synthesizes all findings into one dispositioned list, writes the session record under `<artifact-root>/councils/<topic>/<phase>/`, and brings it to the Human.

**Authority.** The Round Table is advisory. It can poke severe holes; it cannot patch them, change an artifact, or force a loop-back. When it raises High or Critical findings, those escalate to the Orchestrator and the Human, who decide the disposition. A brilliant Council argument that the Human rejects is simply a logged, waived finding.

---

## Locks and re-opens (governance)

**A Lock** is a recorded decision that an artifact (Vision, Plan, or an individual spec) is authoritative as written. Locks are created at Phase 5 (Vision + Plan, Human co-signed) and Phase 6 (per spec). A locked artifact is followed as truth until superseded.

**Changing a locked artifact comes in three weights.** Not every correction deserves the full ritual; if it did, people would route around it with silent edits, which is the exact failure the Lock exists to prevent. Match the ceremony to the change:

- **Clarification** — wording, a typo, a sharper phrasing of an existing acceptance criterion, anything that does not change meaning. Logged as a one-line changelog entry on the artifact. No authorization needed.
- **Amendment** — a bounded change that does not invalidate the artifact's core (a spec detail corrected, a chunk's scope trimmed). Mirrors the `audit-cycle` Path A spec amendment. Authorized by the Orchestrator; recorded.
- **Re-open** — a change that invalidates a Lock: the Vision is wrong, the Plan's shape is wrong, a spec's premise no longer holds. The full ritual below. Never a silent edit.

**Who may authorize a re-open:** the Human always; the Orchestrator within its delegation. The Council never. (Clarifications and amendments follow the lighter rules above.) **Abandon** — ending a build, or killing a chunk, outright — follows the same authority rule as re-open (Human always; Orchestrator within delegation; Council never) and is recorded as a **Kill** (see record types below). Abandon is terminal: where a re-open sends an artifact back to be fixed, an abandon ends it.

**Re-open record** (appended to the decision log / Evidence Store):

```
RE-OPEN  [date]
Trigger:       <finding id, or implementation discovery>
Invalidates:   <artifact + section>
Authorized by: <Human | Orchestrator>
Disposition:   <re-vision | re-plan | re-spec | refine-in-place | waiver>
Re-lock:       <new lock id / date>
```

**Records the methodology depends on.** All findings — from the per-artifact `audit-cycle` and from the Round Table Council alike — live in **one Evidence Store**, under **one set of record types** and **one severity/disposition vocabulary**. They differ only in where their session records file: code-audit artifacts under `<artifact-root>/audits/<topic>/`, intent-review (Council) artifacts under `<artifact-root>/councils/<topic>/` (per-sitting records nest one level deeper at `councils/<topic>/<phase>/` — Gate A vs Phase 5) — different objects, the same schema. The methodology does not define the Evidence Store schema (that belongs to the Evidence Store subsystem); it only requires that these record types exist there, each with a stable ID and at least these fields:

- **Lock** — lock ID, artifact path, version, content hash, who co-signed, date, and a **supersedes** field pointing at the lock it replaces. The hash pins "authoritative as written" to an exact artifact state.
- **Clarification** — clarification ID, artifact, the one-line changelog entry, date. No authorization field, since none is required.
- **Amendment** — amendment ID, artifact, what changed and why, the authorizing Orchestrator, date.
- **Finding** — finding ID, severity, source (which Council seat or audit lens), target artifact, disposition.
- **Re-open** — as in the record above.
- **Kill** — kill ID, what was killed (the whole build, or a single artifact/chunk), the finding ID or evidence that killed it, who decided (Human | Orchestrator), date, and a **revival trigger** ("reconsider if X changes"). The terminal sibling of re-open: a re-open sends an artifact back to be fixed; a Kill ends it. A killed idea returns only through its trigger — the same discipline waivers use, applied to a whole build.
- **Waiver** — waiver ID, the finding it waives, the rationale, and a **revalidation trigger**: the condition under which the waiver must be re-examined ("revisit when X"). A waiver with no trigger rots into permanent forgotten debt, so every waiver carries one, exactly as the `audit-backlog` attaches trigger conditions to deferred items.
- **Audit result** — audit ID, the artifact audited pinned by hash (a spec's content hash, or an implementation's commit / diff / artifact hash or release-candidate ID), tier, the lock-gate floor and evidence burden it cleared, round count, and the triaged residue (waived or backlogged Lows). This is what keeps "passed audit" attached to an exact artifact state.
- **Release** — release ID, the release-candidate hash or version that shipped, the acceptance evidence (which Phase 1 criteria were met and how), the rollback or recovery proof, the Human's signoff, and the shipped date. Phase 8's counterpart to the Lock: it pins what actually went out the door.

---

## Backward propagation (the loop edges)

Four legitimate loop-backs. Each is travelled only via an authorized, recorded re-open.

1. **Gate A or Council to Vision.** When adversarial review finds the Vision itself is wrong, the Human or the Orchestrator may re-open Phase 1 or 3. The Council surfaces the hole; the decision to loop back rests with the Human or the Orchestrator.
2. **Council to Plan.** When review finds the Plan does not deliver the Vision or the chunking is wrong, re-open Phase 4.
3. **Implementation to Plan or Spec.** Reality discovered during Phase 7 (a spec is wrong, a dependency order was backwards, a Vision assumption no longer holds) triggers a re-open of the affected artifact. Never follow a spec known to be wrong, and never silently deviate from one. Surface it, disposition it, re-lock.
4. **Architectural re-open to Phase 0.** When a finding is that a load-bearing repo constraint is itself the problem, the Human or the Orchestrator may re-open it. The Phase 0 facts are not rewritten; the architectural decision they record is challenged, fixed, and re-locked. This is the one edge that touches Phase 0, and it is deliberately the heaviest, since it moves ground truth.

---

## Quick reference checklist

```
[ ] Stakes 1st Score the build. Low → EXPRESS LANE (Phase 0 + 1-line acceptance → build → audit-cycle → release verify; skip research / Gate A / Council / per-chunk specs; a bug uses the Bugfix artifact). Medium or High → the full checklist below.
[ ] Phase 0  Current-state note written; constraints named; runtime premises verified
[ ] Phase 1  Vision Doc + acceptance criteria written
[ ] Phase 2  Research questions derived; all answered or marked unanswerable
[ ] Spike    Any feasibility unknown retired by a time-boxed probe; learning recorded
[ ] Phase 3  Vision refined against findings and spikes
[ ] Stakes   Project scored Low / Medium / High; any downgrade logged with evidence
[ ] Gate A   Run if High (required) or Medium (optional); skip if Low
[ ] Phase 4  Plan chunked (prefer vertical slices), risk-tagged, High/Critical chunks name a hardening artifact
[ ] Gate     Human eyeball pass: matches vision, honest tags, ordered for learning, nothing unwanted, cost ok
[ ] Phase 5  Council sat at stakes-appropriate size; independent first passes; findings dispositioned
[ ] Lock     Vision + Plan Locked, Human co-signed
[ ] Phase 6  Each spec audited (audit-cycle) and locked at its risk-tier floor
[ ] Analyze  Pre-implementation cross-artifact pass: acceptance coverage, contradiction scan, premise check; findings dispositioned
[ ] Phase 7  Each impl audited (audit-cycle) at its risk-tier floor; chunk acceptance met
[ ] Phase 8  Whole verified end-to-end vs acceptance criteria; rollback + post-release verification + signoff
[ ] Loop     Any change classed (clarification / amendment / re-open) and recorded
```
