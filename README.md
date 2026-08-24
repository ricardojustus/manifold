# Manifold

**A portable engineering harness for [Claude Code](https://code.claude.com).** Manifold
packages the *structure* of an engineering discipline (a constitution, a methodology,
skills, templates, and the agreement an agent works under) into a project-agnostic `core/`
plus per-project `overlays/`, installable into any repo in one step.

Manifold is one engineer's personal harness: the discipline they and their AI agents built
together, over months of real agent-driven projects, to build everything else. Every rule in
it was earned the hard way and carries its *why*, because a rule without its receipt gets
deleted by the next confident junior, human or model.

## The problem it solves

AI coding agents are brilliant and forgetful. The judgment that makes one *good* — when to
research before acting, how to verify a claim instead of confabulating one, how to hand off
work across sessions — normally lives in the model's head, and evaporates every session, every
compaction, every model upgrade. Manifold moves it into **files**:

- **Procedures** become *skills*: executable one-page cards with the failure modes they guard
  against written down as receipts.
- **Non-negotiables** become *the floor*: ten hard walls in the always-loaded text, backed by
  an enforcement ladder that prefers the runtime's own permission layer over custom guards
  (and is honest about why deny hooks usually make agents worse, not safer).
- **The working agreement** becomes *the Mission Contract*: one agreement shaped with you up
  front — done, boundaries, exits, budget, receipts — that makes your absence safe.
- **Continuity** becomes *templates*: state snapshots, journals, decision logs, handoff files
  — so every session starts cold and still picks up where the last one left off.

A fresh agent (or a weaker model, or you after three weeks away) loads the harness and
inherits the discipline on day one instead of re-deriving it — or not re-deriving it.

## How it works

Two layers, one assembly step:

- **`core/`** is project-agnostic and contains **zero project references** — checked at every
  export by a fail-closed purity gate (a sensitive-term battery, generic leak patterns for home
  paths / emails / key material, a file-type allowlist). It is the part that survives being
  carried to your next project.
- **`overlays/<your-project>/`** holds everything concrete: real paths, real names, model
  pins, hooks, any project-only rules, and per-skill *bindings* that adapt each procedure to
  your project.

The installer assembles the two into a working setup inside your repo's `.claude/` directory:
skills, templates, and a `CLAUDE.harness.md` constitution built from `core/CLAUDE.scaffold.md`
with your overlay's seven slot files filled in. It is deliberately small — about 8 KB of core
text plus your overlay — and holds three of the harness's five parts: the **facts core** (who
the agent is, who you are, the map of your world), the **floor** (ten hard walls that never
bend), and the **continuity card** (how a session hands off to the next). The other two parts
are the **skills** and the **Mission Contract**. Assembly **fails closed**: any unfilled slot
aborts the install and is named to your face.

```bash
git clone https://github.com/ricardojustus/manifold ~/manifold
~/manifold/bootstrap/install.sh /path/to/your-repo --bootstrap
```

That is the whole setup. `--bootstrap` installs the harness plus an onboarding skill into a
repo that has no configuration yet; open a Claude Code session in your project and run
`/harness-onboarding`. It interviews you one question at a time, writes your overlay into
`manifold-overlay/` in your own repo (your configuration stays with your project, private with
it), finishes the real install, and walks you through the two steps that stay yours (below).
Start with [`MANUAL.md`](MANUAL.md) for the guided tour.

Already have an overlay (or prefer to fill one by hand — copy `overlays/_template/`, a fully
documented blank):

```bash
~/manifold/bootstrap/install.sh /path/to/your-repo --overlay <your-overlay>
~/manifold/bootstrap/doctor.sh  /path/to/your-repo   # verify + detect drift later
```

Install is **copy mode** by default (a reproducible snapshot, with a hash manifest so
`doctor.sh` can tell your local edits from upstream drift) or `--link` mode (symlinks that
live-track the harness repo). See [`bootstrap/INSTALL.md`](bootstrap/INSTALL.md) for the
include line, the update and rollback flows, and full mechanics.

## The first session

You answer questions; your agent does the mechanics. `/harness-onboarding` never invents facts
about you, your project, or your security posture — it asks, offers written suggestions you
accept, edit, or drop, and uses only what you confirm. It can't invent the slot truths, so have
answers ready for the seven slots:

1. **Who the agent is, and who you are** — names, roles, how it should address you, your
   formats and tone (*identity*, *user import*).
2. **What the project is** — goal, layout, where truth lives, where the state and journal
   files go (*system map*).
3. **How sessions launch** — logins, config dirs, shared quota (*accounts*; may be empty) —
   and **which models you use for what** (*model pins*).
4. **Your hard rules and your voice** — the non-negotiables you already know you want ("never
   force-push", what must never leave the machine) and any fixed vocabulary (*project hard
   rules*, *comms style*).

**Two steps stay yours, on purpose.** The installer writes `CLAUDE.harness.md` but never
auto-includes it — you add the one-line include yourself, after reading what your agent
assembled. And hooks land on disk unwired; you paste the `settings.json` block by hand. Never
wire a hook you haven't read.

## What's inside

| | |
|---|---|
| **31 skills** | Session lifecycle (`session-start` to `session-end`, compaction prep/resume), the build pipeline (`grilling`, `council`, `audit-cycle`, `grail-loop`), dispatch (`brief-authoring`, `parallel-workstreams`, `fresh-reviewer-dispatch`, `cross-model-dispatch`, `merge-and-cleanup`), plus `research`, `eval-building`, `autonomous-work`, `inter-session`, and more. Most are one-page cards; the ones with real depth carry `references/` |
| **2 agent roles** | `reviewer` (the adversarial arm: pinned effort, no Edit tool by design) and `implementer` (dispatched builds: ambiguity protocol, verify-before-done, effort pinned at medium) |
| **The Mission Contract** | `core/templates/contract-template.md` + `agent-ready-ticket.md`: the five things every arc agrees on up front — done, granted boundaries, exits, budget, receipts — and the board-ticket form of the same agreement |
| **METHODOLOGY.md** | The heavy-build pipeline: vision, adversarial council review, plan, locked spec, implementation, multi-round audit to a 0-Critical/0-High/0-Medium gate, merge |
| **ENFORCEMENT.md** | The enforcement ladder: prose first, native permission layer next, hooks by taxonomy last (including the exit-code footgun that makes naive deny hooks fail open) |
| **Constitution scaffold** | `core/CLAUDE.scaffold.md`: the agent's standing orders — facts core, the floor's ten walls, the continuity card — with seven typed slots your overlay fills |
| **18 templates** | Continuity files, dispatch briefs, the contract, ADRs, scorecards, steering docs |
| **Successor docs** | `FIELD_GUIDE.md` (the narrative an incoming agent reads once: beliefs, the failure catalog, the honest "what still requires judgment" chapter) and `core/SUCCESSOR_CALIBRATION.md` (scenario self-tests a cold agent checks its judgment against) |
| **MANUAL.md** | The operator's guide: what each part is, how it works, how to run a project with it |

## What it believes

The short version of the philosophy (the long version is `FIELD_GUIDE.md`):

- **Receipts or it didn't happen.** Every rule states the failure that created it. Claims
  about files, systems, or prior decisions are verified against the source *this turn*.
  "I remember" is not a citation.
- **Fail closed.** Unfilled slots abort the install; a generation mismatch stops the update;
  an all-clear result gets its coverage audited before it is believed.
- **Right-sized engineering.** Process weight scales with stakes times reversibility — but
  irreversibility-class security invariants are never YAGNI'd away.
- **Structure over vibes.** Verdicts come from reading the artifact end-to-end, and the audit
  gate is a number (0/0/0), not a feeling.
- **One agreement, not a rulebook.** What the agent may do while you're away is written once,
  with you, in the contract — not inferred from a pile of standing rules.

## Platforms

Created and developed on macOS. **Linux works** — the bootstrap scripts are POSIX-ish bash with
the platform differences (SHA-256 tooling) resolved at runtime. **Windows is not systematically
tested**, but early installs have worked through Git Bash. The one known gap is the optional
inter-session module, which is Unix-only (macOS/Linux/WSL).

## Verify the tooling

```bash
bash ~/manifold/bootstrap/selftest.sh
```

Builds a throwaway fixture harness and proves install/doctor end-to-end (assembly, bindings,
fail-closed slots, hash manifest, drift detection, `--link` mode, the generation gate).

## Layout

```
core/            project-agnostic: CLAUDE.scaffold.md, GENERATION, METHODOLOGY.md,
                 ENFORCEMENT.md, SUCCESSOR_CALIBRATION.md, skills/, agents/, templates/
overlays/        per-project adaptation: _template/ (documented blank) + your overlays
bootstrap/       install.sh · update.sh · doctor.sh · selftest.sh · INSTALL.md +
                 skills/ (the first-session interview + the overlay migration helper)
MANUAL.md        the operator's guide
FIELD_GUIDE.md   the agent's orientation
```

## Upgrading from generation 1

`core/GENERATION` names the core's slot-and-roster shape; every overlay records the generation
it was written for. Generation 2 replaced ten slots with seven and trimmed the
roster, so a generation-1 overlay is never installed over silently: `update.sh` stops and
stages a one-time `/harness-migrate-overlay` helper, which drafts the new overlay from your old
one, shows you the diff, and writes only on your explicit yes. Every core replacement is tagged
beforehand too, so two lines put the previous harness back. Both flows:
[`bootstrap/INSTALL.md`](bootstrap/INSTALL.md).

## License

MIT, see [LICENSE](LICENSE).
