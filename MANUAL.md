# The Manifold Manual — for the human at the wheel

*The operator's guide. Written 2026-07-05, for the human who owns a project running on this harness — what each part is, what it does, and how to build software with it. The agent-facing counterpart is `FIELD_GUIDE.md`; this document is for you. Plain language throughout; every term of art is in the glossary at the end.*

*Freshness: inventory counts and model names in this manual are as of 2026-08-24. `VERSION` is the version truth (it ships in the public export; the installer reads it); the dev repo's `CHANGELOG.md` carries the running history. If this manual disagrees with either, they win.*

---

## 1. What Manifold is

Manifold is a **portable engineering discipline in a box** — the distilled working method of an AI agent stack that shipped months of real, audited software. Every rule in it exists because something specific once went wrong, and the incident is written down next to the rule.

It is NOT an app, a framework or a running system. It is a versioned git repo of **text**: a constitution, a methodology, procedures (skills), a working agreement (the Mission Contract), templates, a few small guard scripts, and an installer that stamps all of it into any project so a fresh AI agent working there behaves — from day one — like the veteran that wrote it.

Three design commitments explain almost everything about how it's built:

1. **Judgment lives in files, not in models.** Models rotate (they get upgraded, deprecated, swapped); files persist. Anything the stack learned that only lived in a model's head was going to be lost — so it was written down, with its reasoning. It is written *short*: text that doesn't change what an agent does is deleted, not trimmed.
2. **Universal core, project overlays.** `core/` never mentions any specific project, person, or company. Everything project-specific (paths, names, model choices, which directories are off-limits) arrives via a small `overlays/<project>/` package. Core + one overlay = a working installation, portable to your next project.
3. **Everything carries its receipt.** A rule without the story of why it exists gets deleted by the next confident reader. Every discipline names its incident — anonymized, mechanism and cost intact.

## 2. The five ideas everything hangs off

You'll recognize these in every corner of the repo:

- **Verify, don't trust.** Claims get checked against sources *this turn*; agent reports against artifacts; error causes validated before diagnosis. The most expensive failures in agent work are confident claims nobody checked.
- **Structure beats intention.** Most rules are prose the agent chooses to follow. The handful where one violation is catastrophic get the lowest mechanical backing that covers them — never a custom guard where the platform already provides the net.
- **Adversarial review is the price of confidence.** A reviewer from a *different model family* double-checks, because two copies of the same model share the same blind spots. Nothing ships because its author was smart.
- **Right-size everything.** Full ceremony is for work that can hurt you; small reversible changes take an express lane. YAGNI, with a floor: safety invariants, tests, and receipts are never trimmed "for simplicity".
- **The context window is a workspace, not a memory.** Everything durable lives in files, because a conversation can be compacted or lost at any moment. Files survive; recollections don't.

## 3. A tour of the repo

```
manifold/
├── MANUAL.md              ← you are here (human operator's guide)
├── FIELD_GUIDE.md         ← the agent successor's orientation (read-once narrative)
├── VERSION                ← the version (installer + public export read this)
├── CHANGELOG.md           ← running history (dev repo only; not exported)
├── BACKLOG.md             ← deferred work, each item with the trigger that revives it
├── core/                  ← the universal layer (zero project references)
│   ├── CLAUDE.scaffold.md      the constitution (assembled into a project's CLAUDE file)
│   ├── GENERATION              the core's slot-and-roster shape (currently 2)
│   ├── METHODOLOGY.md          the heavy-build loop: vision → council → plan → spec → audit → lock
│   ├── ENFORCEMENT.md          the enforcement ladder + the five invariants
│   ├── SUCCESSOR_CALIBRATION.md self-test runbook for a cold agent's judgment
│   ├── agents/            named subagent roles (reviewer, implementer) for recurring dispatches
│   ├── skills/            31 procedures (session lifecycle, build arc, dispatch, evals…)
│   └── templates/         13 file skeletons + 3 steering-doc templates + the atlas pair
├── overlays/
│   ├── <project>/         a project's bindings (paths, hooks, pins, skill add-ons)
│   └── _template/         copy this to create a new project's overlay
└── bootstrap/
    ├── install.sh         the installer (copy or link mode, hash manifest)
    ├── update.sh          re-runs a recorded install after pulling the harness
    ├── doctor.sh          drift detector (compares installed files against the manifest)
    ├── selftest.sh        the installer's own test suite
    ├── skills/            harness-onboarding (first setup) + harness-migrate-overlay
    └── INSTALL.md         install, update, generation upgrade, rollback
```

### The constitution (`core/CLAUDE.scaffold.md`)

The rules of being for any agent on the harness, deliberately small — roughly 8 KB of core text plus your overlay's fill. It carries three of the harness's five parts:

- **The facts core** — who the agent is, the *dispositions* it works by (smallest effective solution; reversible-and-cheap gets done and reported; a question is a question, not a work order; ground before building; done means done), who you are and the two send-tests every message to you must pass, the map of your world, your accounts, model pins and voice.
- **The floor** — ten hard walls that never bend: deny-default egress · no secrets in agent-reachable surfaces · self-rule changes wait for you · independent review before significant merges · the budget envelope · no peer agent carries your authority · never confabulate on a deliverable · the grant test before wiring a tool · the contract is the permission surface · every dispatch is bounded. A wall is not advice: hitting one stops that path.
- **The continuity card** — the thread files ARE the memory; how a session opens, closes, and survives a compaction.

Seven labeled empty **slots** (identity, user import, system map, accounts, model pins, comms style, project hard rules) are filled from the overlay at install. When people say "the constitution," they mean this file's assembled form.

### The Mission Contract (`core/templates/contract-template.md`)

The fourth part, and the one that replaces a pile of standing process rules: **one agreement, shaped with you at the start of a piece of work, that makes your absence safe until delivery**. Five invariants: (1) **done**, machine-checkable wherever possible and never checked by the session that did the work; (2) **granted boundaries** — what runs without you this arc, including the review plan, written once and never re-decided mid-arc; (3) **exits** — the run ends only by a written rule (done, budget, a floor wall, or blocked on something only you hold); (4) **budget** — trivial / noticeable / heavy, plus the envelope; (5) **receipts at delivery**. Small work gets **contract-lite**: one line in chat — goal, what done means, budget word. `agent-ready-ticket.md` is the same agreement in board form: a ticket you label `agent-ready` whose body carries invariants 1-4, which an idle session picks up and finishes with you out of the loop.

### The methodology (`core/METHODOLOGY.md`)

The long-form loop for builds that can hurt you: score the **stakes** → ground → **Vision** → **Plan** → the **Round Table Council** (an adversarial panel that attacks both before anything is built) → **Lock** → per-chunk **Specs**, each audited, locked, carrying its dispatch triage → **implementation** → **audit rounds** to a zero-findings gate → merge, tag, release. §6 walks it in human terms. Locks are recorded decisions: a locked artifact is the source of truth until a logged re-open supersedes it — never silently edited.

### Enforcement (`core/ENFORCEMENT.md` + the overlay's `hooks/`)

The ladder, in four rungs. **Prose** (the majority — it carries reasoning, the agent applies judgment). **The runtime's permission layer** — the classifier surfaces dangerous-shaped actions for your approval, and takes project-specific rules in plain English. **You, in the conversation** — flows whose normal case is sanctioned (amending a locked spec) are enforced by your approval, never a file guard. **Hooks, by shape** — informational and anti-escape ones are healthy; deny hooks on work surfaces are built only on your explicit commission. Two durable facts: hooks only ever tighten (block, never grant), and wiring is always a manual human step — a session must never arm its own guards. §8 is the owner's summary.

### Skills (`core/skills/` — 31 procedures)

The fifth part. Each skill is a markdown procedure with a strict trigger description (≤150 words, naming its neighbours so the agent can't grab the wrong tool). Most are **one-page cards** — the interface and the footguns, nothing a competent model already knows; the few with real depth keep it in `references/`, opened only when needed. The catalog:

- **Session lifecycle:** `session-start` (orient before working), `session-end` (the closing sweep — state, memory, handoffs), `compact-prep` / `compact-resume`, `inter-session` (the peer-session bus), `memory-discipline`.
- **The build arc:** `grilling` (turns a fuzzy ask into a design), `council` (the adversarial panel that attacks a vision or plan), `audit-cycle` (multi-round cross-model review to a zero-findings lock), `fresh-reviewer-dispatch` (the in-family lens), `cross-model-advisor` / `cross-model-dispatch`, `prototype`, `eval-building` (see §9), `grail-loop` (long autonomous quality runs).
- **Dispatch & parallelism:** `brief-authoring` (every dispatched agent gets a verified, self-contained brief), `parallel-workstreams` (worktree-isolated lanes), `orchestrator-mode`, `merge-and-cleanup`, `autonomous-work` (§7), `minimality-persona` (the do-less counterweight on dispatched seats), `hookify` (§10).
- **Knowledge, docs & routing:** `research`, `doc-placement`, `writing-for-agents`, `wayfinder` (work too foggy to spec), `to-tickets` / `to-questionnaire`, `wait-what`, `brain-mode`, `wizard`.

Judgment that used to live in a separate principles library — when to ask you versus decide and park, how bad a finding really is, how many agents a job needs — is now a disposition in the constitution, a step inside the card that needs it, or a `FIELD_GUIDE.md` judgment chapter.

### Rules (overlay only)

Core ships **no** always-on rules: what used to be eight of them is now the constitution's dispositions, the floor's ten walls, and the contract. A project may still add its own — `overlays/<project>/rules/` installs to `.claude/rules/` — but the harness's own overlay ships zero, on purpose. Before writing one, ask whether it belongs in a slot, a card, or the contract.

### Templates (`core/templates/`)

Skeletons for every recurring artifact: the **Mission Contract** and the **agent-ready ticket**, state snapshots, journals, decision logs, questions-for-you files, the handoff triad, dispatch briefs, ADRs, bugfix records, eval scorecards, morning-review, and the three **steering documents** (`steering/product.md`, `tech.md`, `structure.md`) — the durable per-project context filled in once: what this is and for whom, the stack and its non-negotiables, where things live.

### The overlays

An overlay is everything core is forbidden to contain: real paths, real names, model pins, hook values, any project-only rules, and per-skill **bindings** (short addenda appended to each installed skill — e.g. an audit-cycle binding pinning exactly how the second-lens reviewer is dispatched here). `overlays/_template/` is the starting point: copy it, fill its manifest and its seven slots, fill the steering docs, done. The onboarding interview copies it to `manifold-overlay/` inside the project being onboarded (configuration lives with the project); an overlay kept in this clone as `overlays/<project>/` works identically — `--overlay` takes either.

### The successor docs

`FIELD_GUIDE.md` — the narrative an incoming agent reads once: what the harness believes, how a build feels, the failure catalog, the honest "what still requires judgment" chapter. `SUCCESSOR_CALIBRATION.md` — scenario self-tests so a cold agent can check its judgment against known-good dispositions before touching real work.

## 4. Installing it into a project

```bash
# from the manifold repo — a project with no overlay yet (the usual first time):
bash bootstrap/install.sh <target-repo> --bootstrap     # then run /harness-onboarding in the project

# a project whose overlay already exists:
bash bootstrap/install.sh <target-repo> --overlay <your-overlay-name-or-path>
```

- **Copy mode (default):** a snapshot at a pinned version — reproducible, nothing changes under you. Right for most projects. **Link mode (`--link`):** symlinks back to the harness, so fixes flow live. Right for the "home" installation where the harness itself is developed.
- **What lands where:** skills → `.claude/skills/` (with the overlay's bindings appended), any overlay rules → `.claude/rules/`, methodology/enforcement/field-guide/calibration → `.claude/harness/`, templates → `.claude/harness-templates/`, guard scripts → `.claude/harness-hooks/`, and the assembled constitution → `CLAUDE.harness.md` in the project root.
- **The manifest:** every installed file is recorded with a content hash in `.claude/manifold-manifest.yaml`. Run `bash bootstrap/doctor.sh <target>` any time: `OK` (untouched), `LOCAL-CHANGE` (you deliberately edited your copy — legal and tracked), or `STALE` (upstream moved). It also checks your overlay: unfilled slots, orphaned slot files, bindings naming skills core no longer has, and the generation. Local divergence is sanctioned; *silent* divergence is what the doctor exists to catch.
- **Updating:** `bash bootstrap/update.sh <target>` pulls the harness and re-runs the recorded install. It checks your overlay first and refuses to install over a mismatch, so a broken install never happens silently.
- **Crossing a core generation:** `core/GENERATION` names the core's slot-and-roster shape; your overlay records the one it was written for. When core moves ahead (generation 2 replaced ten slots with seven and trimmed the roster), the update **stops** and stages a one-time `/harness-migrate-overlay` helper into your project. Run it in a session: it drafts the new overlay from your old one, shows you a per-slot summary and the full diff, and writes **only on your explicit yes**. Then re-run the update.
- **Rolling back:** every core replacement is tagged before it lands, and two lines put the old harness back (check the clone out at the tag, re-run `update.sh --no-pull --overwrite-local`); your repo's own install commit is a second path (`git revert`). All three flows in full: `bootstrap/INSTALL.md`.
- **The two manual steps:** (1) the constitution is **not auto-included** — add `@CLAUDE.harness.md` at the end of the project's own `CLAUDE.md`, or it sits on disk governing nothing. (2) Overlay hooks land on disk **unwired**: you paste the wiring block (in the hooks README) into `.claude/settings.json` yourself, once, and run the hooks' selftest after. Both are security features, not omissions — a session must never edit the file that governs it or arm its own guards.

## 5. Your job vs the agent's job

The harness automates a great deal but deliberately keeps a short list of decisions human. Knowing which is which is most of being a good operator.

**Always yours:**
- **The contract** — what the agent may do without you this arc is your call, made once, up front.
- **Stakes and posture calls** — how paranoid a guard should be, what risk is acceptable, anything trading safety for convenience.
- **Locks** — you co-sign the lock on a Vision and Plan; a lock is a recorded decision with your name on it.
- **The plan eyeball gate** — thirty seconds before the expensive Council runs: does the plan match the vision, are risks honestly tagged, is the cost acceptable.
- **Council findings disposition** on the big items — re-open, waive (logged), refine, or kill.
- **Hook wiring and ratification** — guards get armed by you, and hookify's drafted rules get promoted by you.
- **Live-production actions and cutovers** — anything touching a running system users depend on happens with you present.
- **Vocabulary that binds:** some of your words are contracts. When you name a posture, or pre-authorize a class of work ("audits run without my approval"), the harness treats your word as the spec. Say what you mean; it will be executed as said.

**The agent's, with your ratification parked for later:** reversible, engineering-unambiguous decisions — even amendments to locked artifacts when the change is spec-required and tests are green. The agent decides, logs it in DECISIONS, and you review at your leisure. Decide-and-park exists because over-asking burns your attention; the file is the paper trail. One exception is absolute: a change to the agent's *own* rules, floor, or contract machinery is never machine-approved (floor wall #3).

**The agent's entirely:** grounding, drafting, implementation, dispatching reviewers, running audits to the gate, maintaining state files, committing as it goes.

**Your daily surfaces** (all files, in the project or thread folder): `STATE.md` — where things stand right now, read it first, always · `QUESTIONS-FOR-OPERATOR.md` — decisions parked for you, each with the agent's recommendation · `DECISIONS.md` — what it decided autonomously, with rationale · `JOURNAL.md` — the narrative (your morning newspaper after an overnight run).

## 6. Building software with it — the approach

This is the intended shape of a project from empty repo to shipped feature.

**Day zero — setup (once per project):** install and run `/harness-onboarding` (§4), then fill the three steering documents — what this project is, the stack and its rules, where things live. Half an hour that every future dispatch stops re-deriving.

**Start with the contract.** Before work starts, you and the agent agree — out loud, in one exchange — on what done means, what it may do without you, what ends the run, what it may spend. Small work: one line in chat. Anything bigger: the Mission Contract (§3), written down, and the *only* permission surface — anything irreversible or externally visible it didn't grant does not happen. The arc then runs **SHAPE → RUN → DELIVER**: shape the agreement with you, run inside it (a digest per sitting, a live status file, nothing else reaching you unless you look in), deliver receipts against every line of done, checked by something other than the session that did the work.

**Then size the work.** The methodology's stakes rubric decides the lane:
- **Express lane** (reversible, contained, low-novelty): grounding, one-line acceptance criteria, build, quick audit, done. A bug takes the bugfix template.
- **Full loop** (anything that can hurt you): the arc below.

**The full arc, in human terms:**
1. **Interview** — the agent questions you (goals, constraints, alternatives, trade-offs; one thing at a time) and produces a Vision draft. You're the source; it's the scribe with taste. A vision guessed in one shot costs dozens of corrective revisions — that's why the contract says shape by interview, never by guess.
2. **Council** — a fresh adversarial panel (including a different model family) attacks the vision. You disposition the serious findings. Cheap kills happen here, before any code.
3. **Plan** — chunked, ordered, risk-tagged. Your thirty-second eyeball. For high-stakes designs, ask for the **competing-architectures race**: two or three designers with different mandates (smallest change / cleanest structure / pragmatic), and you pick from the trade-offs.
4. **Lock** vision + plan (your co-sign).
5. **Spec each chunk** — grounded in how the system actually works (the harness is fanatical about not spec'ing the wrong component), audited, then locked. Each spec ends with its **dispatch triage**: which model tier implements it, at what effort level, in how many lanes — decided by the author who best understands the complexity, not by an inherited default. Every dispatched agent gets a brief, and every brief is bounded: a timeout and an abort path (floor wall #10).
6. **Implement** — dispatched to the tier/effort the spec named. Model economy in one line: frontier models for judgment, mid tier for implementing locked specs, cheap tier for mechanical sweeps — and effort is a second dial (implementers working from a locked spec deliberately do NOT run at maximum effort; the evidence says medium is both cheaper and *better* for contract fidelity).
7. **Gate** — conformance first (does the code match the spec, clause by clause), then audit-cycle: parallel reviewers, always including a different model family, findings consolidated at worst-case severity, fix-passes, repeat to **zero Critical/High/Medium**. Floor wall #4 sets the ladder, and who wrote the code changes nothing — a significant merge gets a fresh in-family lens *and* a cross-model one. Where no second family exists, `audit-cycle`'s single-lens fallback runs (one lens + explicit self-review, verdict `DONE_WITH_CONCERNS`), never a skipped audit.
8. **Merge, tag, close the loop** — history preserved, lessons harvested into receipts, state files updated, next session's kickoff written.

**A note on trust:** *you read outcomes, not transcripts*. The files (STATE, JOURNAL, the audit records) are written so you can audit the work without watching it happen. If a summary and a file ever disagree, the file wins.

## 7. Parallel work: threads, lanes, and overnight runs

**Threads** (the constitution's continuity card, plus your overlay) — when a project has several long-lived workstreams at once, each becomes a thread with its own folder of session files (kickoff, state, journal, questions, compaction checkpoint). Root session files have exactly ONE owner; the overlay names the model. One writing seat per file, everyone else reads. Threads never write into each other's folders — **you are the bus**: cross-thread needs become parked questions, and you carry decisions between lanes. Every thread kickoff opens with a banner declaring this, so a fresh session can't wander out of its lane.

**Lanes** (`parallel-workstreams`) — short-lived parallel *implementation* dispatches, one git worktree per writer (two agents in one checkout is a proven disaster). The orchestrator drafts briefs, dispatches each with a timeout and an abort path, verifies artifacts first-hand (never a lane's report), and merges sequentially.

**Overnight / autonomous runs** (`autonomous-work`) — the hand-off discipline: the agent maintains the three files continuously (journal / decisions / questions), works loop-until-done through the reversible in-scope work the contract granted, **halts and parks** at anything destructive, irreversible, live-production, or explicitly yours, commits as it goes, schedules its own fallback wake-ups so a stall can't kill the run, and leaves you a morning-readable summary. For bounded tasks with a mechanically checkable finish, it can be armed with the **completion-promise loop**: a hook that stops the session declaring victory until the done-condition is literally met (iteration cap, cancel switch, never armed for interactive sessions).

## 8. The safety layer, summarized for the owner

- The floor's ten walls are always loaded and never negotiated. Beneath them, five invariants, prose-first, each backed by the lowest ladder rung that covers it (§3/Enforcement): classifier rules + server-side branch protection for history-rewrite; your approval for LOCKED-artifact amendments; runtime redaction for secrets. No deny hooks on work surfaces (retired 2026-07-05).
- Guards, where they exist at all, are **seatbelts, not armor**: the careless mistake is caught by the native classifier and structural layers (sandboxing, your review of merges, rollback tags) — not by making text-matchers cleverer. This posture is settled and documented; re-litigating it in audits is explicitly out of bounds.
- Guards are tested on their **block path** — a guard that only ever passed its allow-path tests can fail open exactly when needed — including in degraded environments (receipt: a hook that silently allowed everything when it couldn't create a temp file in a sandbox).
- Accepted limits are **waived in writing**, with reasoning and a revalidation trigger — so a future reader sees a decision, not a hole.

## 9. Measuring instead of guessing: evals

When a decision needs evidence — two implementations to choose between, a quality bar to hold, an autonomous run that needs a real finish line — `eval-building` is the procedure. Its spine:

1. **Pre-register the decision**: write "what result changes what decision" *before* generating output. No criterion-fishing after seeing scores.
2. **Lock a fixture corpus** from real cases (real failures are the best seed; 20–50 items is a legitimate start), with a held-out slice you never tune against.
3. **Choose the cheapest grader that works**: deterministic checks first, LLM-as-judge where nuance demands it, humans only where nothing else works.
4. **If an LLM judges: respect the bias numbers.** Judges favor longer answers (>90%), the first-position answer (50–70%), and their own model family (up to +25%) — so a model never grades its own family's output, pairwise comparisons swap order and average, rubrics get a length-neutral clause, and verdicts are binary pass/fail with a written critique (never a 1–5 "vibes" scale).
5. **Read the transcripts.** No score is trusted until someone reads the failures and they "seem fair".
6. **Report honestly**: sample size, judge limitations, cost — results go on the scorecard template, measured against the pre-registered criterion, so the eval drives the call instead of decorating it.

## 9½. Memory: what the agent remembers, and where

The harness assumes agents forget — every session starts cold — and makes continuity a *file* problem:

- **Continuity files (every project, built-in):** STATE (the live snapshot), the kickoff, journal, decisions log, questions file, compaction checkpoint. The constitution's continuity card names them; the templates ship with the harness.
- **A project memory system (when there is one):** a richer subsystem — say, an episodic diary feeding a belief graph — plugs in through the *system map* slot, which names the store **and** how to use it: recall before answering anything about your world, write the diary silently at natural pauses, treat what comes back as a pointer to re-read, not a fact.
- **Routing, with two stores:** *behavioral rules and settled decisions* go to the auto-loaded memory files; *episodic events and world-facts* go to the diary. When in doubt, the diary — a mis-filed note there gets re-sorted; a dropped rule is gone.
- **Portability:** a project without a memory subsystem simply leaves that out of the map — the harness degrades gracefully to files-only memory.

## 10. Keeping it healthy: maintenance and evolution

- **Encode on repetition:** the ~third time you ask for the same multi-step thing, the agent should propose a card or template. You ratify what gets institutionalized — and a card that doesn't change what the agent would have done anyway gets deleted, not shipped.
- **Hookify** closes the correction loop: on demand ("hookify that"), the agent mines your recent corrections, drafts the mechanically-enforceable ones as guard-rule candidates (your words as the receipt), and parks them for ratification. Prose-shaped corrections route to memory instead. Nothing self-activates, ever.
- **Local changes are legal:** an installed project may edit its copies — the doctor tracks them as LOCAL-CHANGE. Push upstream to core only when the change is universal AND carries a receipt.
- **Dated findings expire:** empirical claims (model behavior, tool quirks, the pins) carry their date and a re-verify instruction. When the model lineup changes, the overlay's *model pins* slot is the single place to update.
- **The backlog is honest debt:** every deferral in `BACKLOG.md` carries a trigger that revives it. A deferral without one is forgotten debt — not allowed.
- **New cards get hand-tested before shipping** (2–3 realistic prompts, including one that should NOT trigger), until the designed-but-not-yet-built skill-eval gate ships — an application of §9.

## 11. When something goes wrong

- **A guard blocks legitimate work** → that's the harmful direction; don't shrug it off. Check the waiver record first (it may be a known accepted limit), then fix the guard's pattern — over-blocking teaches people to disable guards, which is worse than the risk.
- **Installed files drifted** → `bash bootstrap/doctor.sh <target>` says what changed and whether it was sanctioned.
- **The agent seems to be violating its own discipline** → point it at the specific wall, disposition or card; the receipts are written so disputes resolve by reading, not arguing. If the correction recurs, hookify it.
- **A build went sideways** → the audit records and JOURNAL reconstruct what happened; git history restores the previous state (the release gate requires a tested rollback path for anything that ships — use it).
- **You want to undo the harness entirely** → it's all files and it's all in git: revert the install commit, or roll back to the previous core (§4). Nothing else in your project is touched.

## 12. Glossary

| Term | Meaning |
|---|---|
| **Binding** | A project-specific addendum appended to an installed skill, from the overlay. |
| **Contract** | The Mission Contract: the agreement (done / boundaries / exits / budget / receipts) governing an arc; the only permission surface. |
| **Constitution** | The assembled standing orders (scaffold + overlay slot values): facts core, floor, continuity card. |
| **Council / Round Table** | The fresh adversarial panel that attacks a Vision/Plan before locking. |
| **Cutover** | Switching a live agent/project to run on the harness. |
| **Generation** | The core's slot-and-roster shape (`core/GENERATION`); a mismatch stops the update. |
| **Decide-and-park** | Agent makes a reversible unambiguous call, logs it, you ratify later. |
| **Express lane** | The abbreviated loop for reversible, contained, low-novelty work. |
| **Hook** | A small script the runtime consults before an action; can deny it (exit code 2 blocks; anything else must not be relied on to). |
| **Lane** | A short-lived parallel implementation dispatch in its own git worktree. |
| **Lock** | A recorded, co-signed decision that an artifact is the truth until a logged re-open. |
| **Overlay** | The project-specific package (paths, names, pins, hooks, bindings) installed alongside core. |
| **Pins** | The overlay's dated mapping of generic model tiers to concrete current models. |
| **Receipt** | The written incident that justifies a rule — what it's FOR. Also the evidence delivered at an arc's end. |
| **Slot** | A labeled blank in core text that the overlay fills at install. |
| **Steering docs** | The three durable per-project context files (product / tech / structure). |
| **Wall** | One of the floor's ten hard invariants. Hitting one stops that path. |
| **Thread** | A long-lived parallel workstream with its own folder of session files. |
| **Waiver** | A documented, reasoned acceptance of a known limit, with a revalidation trigger. |
