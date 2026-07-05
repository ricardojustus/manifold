# Manifold

**A portable engineering harness for [Claude Code](https://code.claude.com).** Manifold
packages the *structure* of an engineering discipline (methodology, skills, principles,
rules, templates, a constitution scaffold, and distilled judgment) into a project-agnostic
`core/` plus per-project `overlays/`, installable into any repo in one step.

Manifold is Ric's personal harness: the discipline he and his AI agents built together,
over months of real agent-driven projects, to build everything else. It was distilled into
this portable form by the agents that ran it. Every rule in it was earned the hard way, and
every rule carries its *why*, because a rule without its receipt gets deleted by the next
confident junior, human or model.

## The problem it solves

AI coding agents are brilliant and forgetful. The judgment that makes one *good* (when to
research before acting, how to verify a claim instead of confabulating one, when a finding
is Critical vs. cosmetic, how to hand off work across sessions) normally lives in the
model's head, and it evaporates every session, every compaction, every model upgrade.

Manifold moves that judgment into **files**:

- **Procedures** become *skills*: executable, step-by-step, with the failure modes they
  guard against written down as receipts.
- **Judgment** becomes *principles* and *case-law*: one-page kernels plus real precedent
  for the calls no rubric can make.
- **Non-negotiables** become *enforcement*: bright-line invariants, optionally backed by
  hooks that block the action mechanically (prose asks; exit code 2 refuses).
- **Continuity** becomes *templates*: state snapshots, journals, decision logs, and handoff
  files, so every session starts cold and still picks up exactly where the last one left
  off.

A fresh agent (or a weaker model, or you after three weeks away) loads the harness and
inherits the discipline on day one instead of re-deriving it, or not re-deriving it.

## How it works

Two layers, one assembly step:

- **`core/`** is project-agnostic and contains **zero project references** (mechanically
  verified). It is the part that survives being carried to your next project.
- **`overlays/<your-project>/`** holds everything concrete: real paths, real names, model
  pins, hooks, and per-skill *bindings* that adapt each generic procedure to your project.

The installer assembles the two into a working setup inside your repo's `.claude/`
directory: skills, rules, templates, and a `CLAUDE.harness.md` constitution built from
`core/CLAUDE.scaffold.md` with your overlay's slot files filled in. Assembly **fails
closed**: any unfilled slot aborts the install and is named to your face. No
half-configured harness can exist.

```bash
git clone https://github.com/ricardojustus/manifold ~/manifold
~/manifold/bootstrap/install.sh /path/to/your-repo --overlay <your-overlay>
~/manifold/bootstrap/doctor.sh  /path/to/your-repo   # verify + detect drift later
```

**No overlay yet?** Copy `overlays/_template/` to `overlays/<your-project>/` and fill it
in. It is a fully documented blank: every slot file states its contract, and the installer
lists anything you missed. Start with [`MANUAL.md`](MANUAL.md) for the guided tour.

Install is **copy mode** by default (a reproducible snapshot, with a hash manifest so
`doctor.sh` can tell your local edits from upstream drift) or `--link` mode (symlinks that
live-track the harness repo). `CLAUDE.harness.md` is written but never auto-included; see
[`bootstrap/INSTALL.md`](bootstrap/INSTALL.md) for the one-line include and full mechanics.

## Give this to your agent

The setup is agent-friendly by design: you answer questions, your agent does the mechanics.
Clone the repo, open a Claude Code session **in your project**, and paste:

> Read `~/manifold/MANUAL.md` end-to-end. Then set up Manifold for this project: copy
> `~/manifold/overlays/_template/` to `~/manifold/overlays/<name-my-project>/` and fill it
> in. For every slot file, **interview me, one question at a time, and use my answers**;
> never invent facts about me, my project, or my security posture. Where the template's
> FILL comment offers a sensible default and I have no preference, say so and use it. Then
> run `~/manifold/bootstrap/install.sh <this repo> --overlay <the overlay path>`, fix
> anything it names, run `doctor.sh`, and show me the assembled `CLAUDE.harness.md` for
> review before adding the include line.

**Your side of the interview.** The agent can't invent the slot truths. Have answers ready
for roughly these five things:

1. **Who you are and how you like to work**: name, role, how the agent should address you,
   tone and format preferences (the *identity* and *comms style* slots).
2. **What the project is**: its goal, rough layout, where its docs and plans live, what
   "ground truth" the agent should consult before asserting things (the *system map* and
   *knowledge sources* slots).
3. **Your security posture**: what the agent must never read, never touch, never send
   anywhere; whether external access is read-only (the *security directive* slot). If in
   doubt, start strict: deny unless explicitly allowed.
4. **Your hard rules**: the non-negotiables you already know you want ("never force-push",
   "never commit without asking", vocabulary that has a fixed meaning) (the *project hard
   rules* slot).
5. **Memory and continuity paths**: where state/journal/decision files should live. The
   defaults are fine for most projects; say "defaults" and move on.

**Two steps stay yours, on purpose.** (1) The installer writes `CLAUDE.harness.md` but
never auto-includes it; you add the one-line include to your `CLAUDE.md` yourself after
reviewing what your agent assembled. (2) If you opt into enforcement hooks, you paste their
`settings.json` wiring by hand. Never wire a hook you haven't read.

## What's inside

| | |
|---|---|
| **25 skills** | The full arc: session lifecycle (`session-start` to `session-end`, compaction prep/resume), the build pipeline (`brainstorming`, `council`, `spec-writing`, `spec-adherence`, `audit-cycle`), dispatch (`brief-authoring`, `parallel-workstreams`, `merge-and-cleanup`), plus `debugging-discipline`, `test-driven-development`, `eval-building`, `research`, `autonomous-work`, and more |
| **15 principles** | One-page judgment kernels: grounding vs. confabulation, error triage, right-sized engineering (YAGNI with a floor), model economy, ask-vs-decide, fix-the-class, and others |
| **Case-law** | Precedent for calls rubrics can't make: finding severity, dispatch sizing |
| **METHODOLOGY.md** | The build pipeline end-to-end: vision, adversarial council review, plan, locked spec, implementation, multi-round audit to a 0-Critical/0-High/0-Medium gate, merge |
| **ENFORCEMENT.md** | The bright-line invariants and how to back them with hooks (including the exit-code footgun that makes naive hooks fail open) |
| **Constitution scaffold** | `core/CLAUDE.scaffold.md`: the agent's standing orders, with typed slots your overlay fills |
| **20+ templates** | State/journal/decision continuity files, dispatch briefs, spec skeletons, ADRs, eval scorecards, steering docs |
| **Successor docs** | `FIELD_GUIDE.md` (the narrative orientation an incoming agent reads once: what this harness believes, the failure catalog, the honest "what still requires judgment" chapter) and `core/SUCCESSOR_CALIBRATION.md` (scenario self-tests so a cold agent can check its judgment against known-good dispositions) |
| **MANUAL.md** | The human operator's guide: what each part is, how it works, how to run a project with it |

## What it believes

The short version of the philosophy (the long version is `FIELD_GUIDE.md`):

- **Receipts or it didn't happen.** Every rule states the failure that created it. Claims
  about files, systems, or prior decisions are verified against the source *this turn*.
  "I remember" is not a citation.
- **Fail closed.** Unfilled slots abort the install; enforcement hooks that error must
  block, not shrug; an all-clear result gets its coverage audited before it is believed.
- **Right-sized engineering.** Process weight scales with stakes times reversibility. A
  best-effort convenience gets a review and a selftest, not a hardening campaign. But
  bright-line security invariants are never YAGNI'd away.
- **Structure over vibes.** Verdicts come from reading the artifact end-to-end, findings
  carry severity and evidence, and the audit gate is a number (0/0/0), not a feeling.

## Verify the tooling

```bash
bash ~/manifold/bootstrap/selftest.sh
```

Builds a throwaway fixture harness and proves install/doctor end-to-end (assembly, bindings,
fail-closed unfilled slots, hash manifest, drift detection, `--link` mode). Exits nonzero on
any failure.

## Layout

```
core/            project-agnostic: CLAUDE.scaffold.md, METHODOLOGY.md, ENFORCEMENT.md,
                 SUCCESSOR_CALIBRATION.md, skills/, principles/, case-law/, rules/, templates/
overlays/        per-project adaptation: _template/ (documented blank) + your overlays
bootstrap/       install.sh · doctor.sh · selftest.sh · INSTALL.md
MANUAL.md        the human operator's guide
FIELD_GUIDE.md   the incoming agent's orientation
```

## License

MIT, see [LICENSE](LICENSE).
