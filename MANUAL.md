# The Manifold Manual — for the human at the wheel

*The operator's guide. Written 2026-07-05, for the human who owns a project running on this harness — what each part is, what it does, how to use it, and how to build software with it. The agent-facing counterpart is `FIELD_GUIDE.md` (written for the AI successor); this document is for you. Plain language throughout; every term of art is in the glossary at the end.*

*Freshness: inventory counts and model names in this manual are as of 2026-07-05. The repo's `CHANGELOG.md` is the running truth; if they disagree, the changelog wins.*

---

## 1. What Manifold is

Manifold is a **portable engineering discipline in a box**. It is the distilled working method of an AI agent stack that shipped months of real, audited software — every rule in it exists because something specific once went wrong, and the incident is written down next to the rule.

It is NOT an app, a framework, or a running system. It is a versioned git repo of **text**: a constitution, a methodology, procedures (skills), judgment notes (principles and case-law), templates, a handful of small guard scripts, and an installer that stamps all of it into any project so that a fresh AI agent working there behaves — from day one — like the veteran that wrote it.

Three design commitments explain almost everything about how it's built:

1. **Judgment lives in files, not in models.** Models rotate (they get upgraded, deprecated, swapped); files persist. Anything the stack learned that only lived in a model's head was going to be lost — so it was written down, with its reasoning.
2. **Universal core, project overlays.** The `core/` directory never mentions any specific project, person, or company. Everything project-specific (paths, names, concrete model choices, which directories are off-limits) arrives via a small `overlays/<project>/` package. Core + one overlay = a working installation. That's what makes it portable to your next project.
3. **Everything carries its receipt.** A rule without the story of why it exists gets deleted by the next confident reader. So every discipline names its incident — anonymized, but with the mechanism and the cost intact.

## 2. The five ideas everything hangs off

You'll recognize these in every corner of the repo:

- **Verify, don't trust.** Claims get checked against sources *this turn*; agent reports get checked against artifacts; error causes get validated before diagnosis. The most expensive failures in agent work are confident claims nobody checked.
- **Structure beats intention.** Most rules are prose the agent chooses to follow (deliberately — prose carries reasoning and generalizes). The handful where one violation is catastrophic get the lowest mechanical backing that actually covers them (the runtime's own permission classifier, server-side controls, runtime redaction) — never a custom guard where the platform already provides the net.
- **Adversarial review is the price of confidence.** Specs get audited before code exists; code gets audited against specs; reviewers from a *different model family* double-check, because two copies of the same model share the same blind spots. Nothing ships because its author was smart.
- **Right-size everything.** Full ceremony is for work that can hurt you. Small reversible changes take an express lane. Machinery isn't built until the need is real, nothing else already provides it, and the question wasn't already settled (YAGNI — with a floor: safety invariants, tests, and receipts are never trimmed "for simplicity").
- **The context window is a workspace, not a memory.** Everything durable lives in files — state snapshots, journals, decision logs — because an agent's conversation can be compacted or lost at any moment. Files survive; recollections don't.

## 3. A tour of the repo

```
manifold/
├── MANUAL.md              ← you are here (human operator's guide)
├── FIELD_GUIDE.md         ← the agent successor's orientation (read-once narrative)
├── CHANGELOG.md           ← version + running history (installer reads the version)
├── BACKLOG.md             ← deferred work, each item with the trigger that revives it
├── core/                  ← the universal layer (zero project references)
│   ├── CLAUDE.scaffold.md      the constitution (assembled into a project's CLAUDE file)
│   ├── METHODOLOGY.md          the build loop: vision → council → plan → spec → audit → lock
│   ├── ENFORCEMENT.md          the enforcement ladder + the five invariants
│   ├── SUCCESSOR_CALIBRATION.md self-test runbook for a cold agent's judgment
│   ├── agents/            named subagent roles (reviewer, implementer) for recurring dispatches
│   ├── skills/            26 procedures (session lifecycle, build arc, dispatch, evals…)
│   ├── principles/        15 one-page judgment kernels
│   ├── case-law/          precedent for calls rubrics can't make (severity, dispatch sizing)
│   ├── rules/             always-on rules (e.g. the parallel-threads contract)
│   └── templates/         19 file skeletons + 3 steering-doc templates
├── overlays/
│   ├── <project>/         a project's bindings (paths, hooks, pins, skill add-ons)
│   └── _template/         copy this to create a new project's overlay
└── bootstrap/
    ├── install.sh         the installer (copy or link mode, hash manifest)
    ├── doctor.sh          drift detector (compares installed files against the manifest)
    ├── selftest.sh        79-case test of the installer itself
    └── INSTALL.md         install instructions
```

### The constitution (`core/CLAUDE.scaffold.md`)

The rules of being for any agent on the harness. The Cardinal Rule (hypothesize → research → present → implement — never guess-and-change), grounding and anti-confabulation discipline, error-validation-before-diagnosis, implementation discipline (think first, simplicity first, surgical changes, verifiable goals), right-sized engineering, git discipline, the security posture. It has labeled empty **slots** (project name, paths, people); the installer fills them from the overlay and writes the assembled result into the target project. When people say "the constitution," they mean this file's assembled form.

### The methodology (`core/METHODOLOGY.md`)

The full build loop, formally: score the **stakes** first (a reversible small change takes the express lane; anything that can hurt you takes the full loop) → ground in the repo → draft a **Vision** → optional early challenge (**Gate A**) → **Plan** (chunked, risk-tagged, with your thirty-second eyeball gate) → the **Round Table Council** (an adversarial panel that attacks the vision and plan before anything is built) → **Lock** → per-chunk **Specs** (each audited and locked, each carrying its implementation-dispatch triage: which model tier, what effort level, what lane shape) → **implementation** → **audit rounds** to a zero-findings gate → merge, tag, release. Locks are recorded decisions: a locked artifact is the source of truth until a logged re-open supersedes it — never silently edited.

### Enforcement (`core/ENFORCEMENT.md` + the overlay's `hooks/`)

The enforcement ladder. Rung one: prose rules (the majority — they carry reasoning, the agent applies judgment). Rung two: the runtime's own permission layer — Claude Code's classifier surfaces dangerous-shaped actions for your approval, and you can feed it project-specific rules in plain English (settings `autoMode`: `allow` / `soft_deny` — prompts you, your yes clears it / `hard_deny` — even your yes doesn't). Rung three: you, in the conversation — flows whose normal case is sanctioned (like amending a locked spec) are enforced by your approval, never by a file guard. Rung four: hooks, by shape — informational (add context, never block) and anti-escape (stop the agent bypassing a gate YOU installed, like the `--no-verify` guard) are healthy; **deny hooks on work surfaces are built only on your explicit commission**, with ownership of every hard-coded path verified with its owning workstream. The harness once shipped four deny hooks; they were retired 2026-07-05 after producing one real incident (blocking a workstream from its own surface) and zero real saves. The five invariants still stand — as prose, backed by the lowest ladder rung that actually covers each. Two durable facts: **hooks only ever tighten** (block, never grant), and **wiring is always a manual human step** — a session must never arm its own guards.

### Skills (`core/skills/` — 25 procedures)

Each skill is a markdown procedure with a strict trigger description (≤150 words, naming its neighbor skills so the agent can't grab the wrong tool). The catalog, grouped:

- **Session lifecycle:** `session-start` (orient before substantive work), `session-end` (the closing sweep — state, memory, handoffs), `compact-prep` / `compact-resume` (checkpoint before/after a context compaction).
- **The build arc:** `phase-start` (mandatory grounding before any new phase), `brainstorming` (Socratic interview that *produces* a vision — upstream), `council` (the adversarial panel that *attacks* it — downstream), `spec-writing` (author specs without aiming at the wrong component), `spec-adherence` (clause-by-clause conformance gate after implementation), `audit-cycle` (the multi-round, cross-model review to a zero-findings lock), `test-driven-development` (red→green→refactor, with a bank of the ways tests lie), `debugging-discipline` (root-cause before fixes; three failed fixes = question the architecture), `eval-building` (construct empirical evals — see §9).
- **Dispatch & parallelism:** `brief-authoring` (every dispatched agent gets a verified, self-contained brief), `parallel-workstreams` (worktree-isolated implementation lanes), `merge-and-cleanup` (consolidating lanes), `autonomous-work` (unattended runs — see §7), `hookify` (mine your corrections into draft guard rules — see §10).
- **Knowledge & docs:** `research` (source-priority protocol), `plan-update`, `reference-doc-writing`, `doc-placement`, `memory-discipline`, `system-audit`, `scoped-adversarial-audit`.

### Principles (`core/principles/` — 15 kernels) and case-law (`core/case-law/`)

One-page judgment notes — the things that used to live only in the senior model's taste. Highlights: `ask-vs-decide` (when the agent decides and parks ratification vs when it must halt and ask you), `model-economy` (which model tier and effort level per task — see §6), `right-sized-engineering` (YAGNI with a floor), `smell-checklist` (the "wait, that doesn't add up" reflexes), `grounding-and-confabulation`, `finding-freshness` (dated empirical claims carry re-verify instructions). Case-law holds worked precedent: `severity-case-law` (how bad is this finding, really) and `dispatch-sizing` (how many agents, which primitive).

### Rules (`core/rules/`)

Always-on contracts. The big one: `threads.md` — the parallel-threads convention (see §7).

### Templates (`core/templates/`)

Skeletons for every recurring artifact: state snapshots, kickoffs, journals, decision logs, questions-for-you files, dispatch briefs, specs (with the built-in dispatch-triage section), ADRs, bugfix records, eval scorecards, morning-review, and the three **steering documents** (`steering/product.md`, `tech.md`, `structure.md`) — the durable per-project context every new project fills in once (what this is and for whom; the stack and its non-negotiables; where things live).

### The overlays

An overlay is everything core is forbidden to contain: real paths, real names, concrete model pins, project-specific hooks values, and per-skill **bindings** (short project-specific addenda appended to each installed skill — e.g. an audit-cycle binding that pins exactly how a second-lens reviewer is dispatched for that project). `overlays/_template/` is the starting point — copy it, fill its manifest and slots, fill the steering docs, done.

### The successor docs

`FIELD_GUIDE.md` — the narrative orientation an incoming agent reads once, end-to-end: what the harness believes, how a build actually feels, the failure catalog, the honest "what still requires judgment" chapter. `SUCCESSOR_CALIBRATION.md` — a runbook of scenario self-tests so a cold agent can check its own judgment against known-good dispositions before touching real work.

## 4. Installing it into a project

```bash
# from the manifold repo:
bash bootstrap/install.sh <target-repo> --overlay <your-overlay-name-or-path>
```

- **Copy mode (default):** the target gets a snapshot at a pinned version — reproducible, nothing changes under you. Right for most projects.
- **Link mode (`--link`):** symlinks back to the harness — fixes flow live. Right for the "home" installation where the harness itself is developed.
- **What lands where:** skills → `.claude/skills/` (with the overlay's bindings appended), rules → `.claude/rules/`, methodology/enforcement/principles/case-law/field-guide/calibration → `.claude/harness/`, templates → `.claude/harness-templates/`, guard scripts → `.claude/harness-hooks/`, and the assembled constitution → `CLAUDE.harness.md` in the project root.
- **The manifest:** every installed file is recorded with a content hash in `.claude/manifold-manifest.yaml`. Run `bash bootstrap/doctor.sh <target>` any time: it reports `OK` (untouched), `LOCAL-CHANGE` (you deliberately edited your copy — legal and tracked), or `STALE` (upstream moved). Local divergence is sanctioned; *silent* divergence is what the doctor exists to catch.
- **The one manual step:** hooks land on disk but are **not wired** into the project's settings. You paste the wiring block (given in the hooks README) into `.claude/settings.json` yourself, once. This is a security feature, not an omission — the session must never arm its own guards. After wiring, run the hooks' selftest.

## 5. Your job vs the agent's job

The harness automates a great deal, but it deliberately keeps a short list of decisions human. Knowing which is which is most of being a good operator.

**Always yours:**
- **Stakes and posture calls** — how paranoid should a guard be, what risk is acceptable, anything that trades safety against convenience. (The force-push "seatbelt vs armor" decision was this kind; it's yours by design.)
- **Locks** — you co-sign the lock on a Vision and Plan; a lock is a recorded decision with your name on it.
- **The plan eyeball gate** — thirty seconds before the expensive Council runs: does the plan match the vision, are risks honestly tagged, is anything obviously unwanted, is the cost acceptable.
- **Council findings disposition** on the big items — re-open, waive (logged), refine, or kill.
- **Hook wiring and ratification** — guards get armed by you, and hookify's drafted rules get promoted by you.
- **Live-production actions and cutovers** — anything touching a running system users depend on happens with you present.
- **Vocabulary that binds:** some of your words are contracts. When you say an agent should be a "teammate" vs a "subagent," when you name a posture, when you pre-authorize a class of work ("audits run without my approval") — the harness treats your word as the spec. Say what you mean; it will be executed as said.

**The agent's, with your ratification parked for later:** reversible, engineering-unambiguous decisions — even amendments to locked artifacts when the change is spec-required and tests are green. The agent decides, logs it in its DECISIONS file, and you review at your leisure. This "decide-and-park" pattern exists because over-asking burns your attention; the file is the paper trail.

**The agent's entirely:** grounding, drafting, implementation, dispatching reviewers, running audits to the gate, maintaining the state files, committing as it goes.

**Your daily surfaces** (all files, all in the project or thread folder):
- `STATE.md` — where things stand right now (read this first, always).
- `QUESTIONS-FOR-OPERATOR.md` — decisions parked for you, each with the agent's recommendation.
- `DECISIONS.md` — what the agent decided autonomously, with rationale, awaiting your eventual nod.
- `JOURNAL.md` — the narrative of what happened (your morning newspaper after an overnight run).

## 6. Building software with it — the approach

This is the intended shape of a project from empty repo to shipped feature.

**Day zero — setup (once per project):**
1. Create the project's overlay (copy `overlays/_template/`, fill the slots: name, paths, never-touch directories, model pins).
2. Install (copy mode), paste the hook wiring, run the doctor and the hooks selftest.
3. Fill the three steering documents — what this project is, the stack and its rules, where things live. Half an hour that every future dispatch stops re-deriving.

**For each piece of work — size it first.** The methodology's stakes rubric decides the lane:
- **Express lane** (reversible, contained, low-novelty): grounding, one-line acceptance criteria, build, quick audit, done. A bug gets the bugfix template.
- **Full loop** (anything that can hurt you): the arc below.

**The full arc, in human terms:**
1. **Brainstorm** — the agent interviews you (one question at a time: goals, constraints, alternatives, trade-offs) and produces a Vision draft. You're the source; it's the scribe with taste.
2. **Council** — a fresh adversarial panel (including a different model family) attacks the vision. You disposition the serious findings. Cheap kills happen here, before any code.
3. **Plan** — chunked, ordered, risk-tagged. Your thirty-second eyeball. For high-stakes designs, ask for the **competing-architectures race**: two or three designers with deliberately different mandates (smallest change / cleanest structure / pragmatic), and you pick from the compared trade-offs.
4. **Lock** vision + plan (your co-sign).
5. **Spec each chunk** — grounded in how the system actually works (the harness is fanatical about not spec'ing the wrong component), audited, then locked. Each spec ends with its **dispatch triage**: which model tier implements it, at what effort level, in how many lanes — decided by the author who best understands the complexity, not by an inherited default.
6. **Implement** — dispatched to the tier/effort the spec named. Model economy in one line: frontier models for judgment, mid tier for implementing locked specs, cheap tier for mechanical sweeps — and effort is a second dial (implementers from locked specs deliberately do NOT run at maximum effort; the evidence says medium-high is both cheaper and *better* for contract fidelity).
7. **Gate** — spec-adherence (does the code match the spec, clause by clause), then audit-cycle: parallel reviewers, always including a different model family, findings consolidated at worst-case severity, fix-passes, repeat to **zero Critical/High/Medium**. The cross-model seat is non-negotiable; it has caught what the primary model literally could not see, repeatedly.
8. **Merge, tag, and close the loop** — history preserved, lessons harvested into receipts, state files updated, next session's kickoff written.

**A note on trust:** the harness's posture is that *you read outcomes, not transcripts*. The files (STATE, JOURNAL, the audit records) are written so you can audit the work without watching it happen. If a summary and a file ever disagree, the file wins.

## 7. Parallel work: threads, lanes, and overnight runs

**Threads** (`core/rules/threads.md`) — when a project has several long-lived workstreams at once, each becomes a thread with its own folder of session files (kickoff, state, journal, decisions, questions). Root session files belong to exactly ONE primary thread; nobody else touches them. Threads never write into each other's folders — **you are the bus**: cross-thread needs become parked questions, and you carry decisions between lanes. Every thread kickoff opens with a banner declaring all of this, so a fresh session can't wander out of its lane.

**Lanes** (`parallel-workstreams`) — short-lived parallel *implementation* dispatches, one git worktree per writer (two agents in one checkout is a proven disaster — there's a receipt). The orchestrator drafts briefs, dispatches, verifies the artifacts first-hand (never trusts a lane's report), and merges sequentially.

**Overnight / autonomous runs** (`autonomous-work`) — the hand-off discipline: the agent maintains the three files continuously (journal / decisions / questions), works loop-until-done through the reversible in-scope work, **halts and parks** at anything destructive, irreversible, live-production, or explicitly yours, commits as it goes, schedules its own fallback wake-ups so a stall can't kill the run, and leaves you a morning-readable summary. For bounded tasks with a mechanically checkable finish, it can be armed with the **completion-promise loop**: a hook that stops the session from declaring victory until the done-condition is literally met (with an iteration cap and a cancel switch — and never armed for interactive sessions).

## 8. The safety layer, summarized for the owner

- Five invariants, prose-first, each backed by the lowest ladder rung that covers it (see §3/Enforcement): classifier rules + server-side branch protection for history-rewrite; your in-conversation approval for LOCKED-artifact amendments; runtime redaction for secrets. No deny hooks on work surfaces (retired 2026-07-05).
- Guards, where they exist at all, are **seatbelts, not armor**: the careless mistake is caught by the native classifier and structural layers (sandboxing, your review of merges, rollback tags) — not by making text-matchers cleverer. This posture is settled and documented; re-litigating it in audits is explicitly out of bounds.
- Guards are tested on their **block path** (a guard that only ever passed its allow-path tests can fail open exactly when needed) — including in degraded environments (there's a receipt: a hook that silently allowed everything when it couldn't create a temp file in a sandbox).
- Accepted limits are **waived in writing**, with reasoning and a revalidation trigger — so a future reader sees a decision, not a hole.

## 9. Measuring instead of guessing: evals

When a decision needs evidence — two implementations to choose between, a quality bar to hold across changes, an autonomous run that needs a real finish line — the `eval-building` skill is the procedure. Its spine:

1. **Pre-register the decision**: write "what result changes what decision" *before* generating any output. No criterion-fishing after seeing scores.
2. **Lock a fixture corpus** built from real cases (real failures are the best seed; 20–50 items is a legitimate start), with a held-out slice you never tune against.
3. **Choose the cheapest grader that works**: exact/deterministic checks first, LLM-as-judge only where nuance demands it, humans only where nothing else works.
4. **If an LLM judges: respect the bias numbers.** Judges favor longer answers (>90% of the time), the first-position answer (50–70%), and their own model family (up to +25%) — so: a model never grades its own family's output, pairwise comparisons swap order and average, rubrics get a length-neutral clause, and verdicts are binary pass/fail with a written critique (never a 1–5 "vibes" scale).
5. **Read the transcripts.** No score is trusted until someone reads the failures and they "seem fair."
6. **Report honestly**: sample size, judge limitations, cost — and results go on the scorecard template with the verdict measured against the pre-registered criterion, so the eval drives the call instead of decorating it.

## 9½. Memory: what the agent remembers, and where

The harness assumes agents forget — every session starts cold — and makes continuity a *file* problem, layered from generic to project-specific:

- **Continuity files (every project, built-in):** STATE (the live snapshot), SESSION_KICKOFF, SESSION_LOG, OPEN_ITEMS, the lessons store, and the auto-loaded memory store of settled decisions and behavioral feedback. These are core; the templates ship with the harness.
- **A project memory system (when the project has one):** a project with a richer memory subsystem — say, an episodic diary that feeds a belief graph — plugs it in via the overlay. The constitution has a dedicated slot for the project's memory paths *and its usage disciplines*: typically a **write discipline** (what must be captured the moment it happens — operator corrections, decisions, facts about the operator's world — plus entry hygiene like source attribution) and a **read discipline** (recall before answering questions about the operator's world, and how to weigh the trust labels on what comes back), both @-imported by the overlay.
- **The router rule (an overlay binding, for projects with both stores):** two stores, routed by kind — *behavioral rules and settled decisions* go to the auto-loaded memory files; *episodic events and world-facts* go to the diary. When in doubt, the diary — a mis-filed note there gets re-sorted by the memory machinery; a dropped rule is gone.
- **Portability:** a new project without a memory subsystem simply fills the slot with the continuity files alone — the harness degrades gracefully to files-only memory, and the slot documents what to wire up if the project grows one.

## 10. Keeping it healthy: maintenance and evolution

- **Encode on repetition:** the ~third time you ask for the same multi-step thing, the agent should propose a skill/rule/template. You ratify what gets institutionalized.
- **Hookify** closes the correction loop: periodically (or on demand — "hookify that"), the agent mines your corrections from recent sessions, drafts the mechanically-enforceable ones as guard-rule candidates (with your words as the receipt), and parks them for your ratification. Prose-shaped corrections route to memory instead. Nothing self-activates, ever.
- **Local changes are legal:** an installed project may edit its copies — the doctor tracks them as LOCAL-CHANGE. Push a change upstream to core only when it's universal AND carries a receipt.
- **Dated findings expire:** empirical claims (model behavior, tool quirks, the model pins) carry their date and a re-verify instruction. When the model lineup changes, the overlay's pins file is the single place to update.
- **The backlog is honest debt:** every deferral in `BACKLOG.md` has a trigger that revives it. A deferral without a trigger is forgotten debt — not allowed.
- **New skills get hand-tested before shipping** (2–3 realistic prompts, including one that should NOT trigger), until the designed-but-not-yet-built skill-eval gate ships — which is now an application of §9.

## 11. When something goes wrong

- **A guard blocks legitimate work** → that's the harmful direction; don't shrug it off. Check the waiver record first (it may be a known accepted limit), then fix the guard's pattern — over-blocking teaches people to disable guards, which is worse than the risk they guard.
- **Installed files drifted** → `bash bootstrap/doctor.sh <target>` tells you what changed and whether it was sanctioned.
- **The agent seems to be violating its own discipline** → point it at the specific rule; the receipts are written so disputes resolve by reading, not arguing. If the correction recurs, hookify it.
- **A build went sideways** → the audit records and JOURNAL reconstruct what happened; the rollback tag (taken before every risky transition) restores the previous state in one command.
- **You want to undo the harness entirely** → it's all files: `git checkout` the rollback tag in the target (or remove the installed `.claude/` pieces and the assembled constitution). Nothing else in your project is touched.

## 12. Glossary

| Term | Meaning |
|---|---|
| **Binding** | A project-specific addendum appended to an installed skill (from the overlay). |
| **Bright line** | One of the five mechanically-enforced invariants (vs prose rules). |
| **Constitution** | The assembled behavioral contract (CLAUDE scaffold + overlay slot values). |
| **Council / Round Table** | The fresh adversarial panel that attacks a Vision/Plan before locking. |
| **Cutover** | Switching a live agent/project to run on the harness. |
| **Decide-and-park** | Agent makes a reversible unambiguous call, logs it, you ratify later. |
| **Express lane** | The abbreviated loop for reversible, contained, low-novelty work. |
| **Hook** | A small script the runtime consults before an action; can deny it (exit code 2 blocks; anything else must not be relied on to block). |
| **Lane** | A short-lived parallel implementation dispatch in its own git worktree. |
| **Lock** | A recorded, co-signed decision that an artifact is the source of truth until a logged re-open. |
| **Overlay** | The project-specific package (paths, names, pins, hooks, bindings) installed with core. |
| **Pins** | The overlay's dated mapping of generic model tiers to concrete current models. |
| **Receipt** | The written incident that justifies a rule — what it's FOR. |
| **Slot** | A labeled blank in core text that the overlay fills at install. |
| **Steering docs** | The three durable per-project context files (product / tech / structure). |
| **Thread** | A long-lived parallel workstream with its own folder of session files. |
| **Waiver** | A documented, reasoned acceptance of a known limit, with a revalidation trigger. |
