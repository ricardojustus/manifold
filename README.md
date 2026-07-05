# Manifold

**A portable engineering harness for [Claude Code](https://code.claude.com):** the
*structure* of an engineering discipline — methodology, skills, principles, rules,
templates, a constitution scaffold, and distilled judgment — split into a project-agnostic
`core/` and per-project `overlays/`, installable into any repo in one step.

Manifold started as one operator's personal harness, distilled from months of real
agent-driven builds by the agents that ran them. Everything in `core/` earned its place the
hard way: every rule carries the *why* (the receipt that produced it), every procedure is
executable by an agent that wasn't there when the lesson was learned.

## What's inside

- **25 skills** — executable procedures for the full arc: session lifecycle
  (`session-start` → `session-end`, compaction handling), the build pipeline
  (`brainstorming` → `council` → `spec-writing` → `spec-adherence` → `audit-cycle`),
  dispatch (`brief-authoring`, `parallel-workstreams`), plus debugging, TDD, eval-building,
  research, and more.
- **15 principles** — one-page judgment kernels (grounding vs. confabulation, error triage,
  right-sized engineering, model economy, ask-vs-decide…).
- **Case-law** — precedent for the calls rubrics can't make (finding severity, dispatch sizing).
- **A constitution scaffold** — `core/CLAUDE.scaffold.md` with typed slots an overlay fills;
  the installer assembles it into a working `CLAUDE.harness.md` and **fails closed** on any
  unfilled slot.
- **METHODOLOGY + ENFORCEMENT** — the vision→council→plan→spec→audit→lock pipeline, and the
  bright-line invariants with optional hook-level mechanical enforcement.
- **Templates** — 20+ file skeletons (state/journal/decisions continuity files, briefs,
  specs, ADRs, eval scorecards, steering docs).
- **Successor docs** — `FIELD_GUIDE.md` (the narrative orientation: what this harness
  believes, the failure catalog, what still requires judgment) and
  `core/SUCCESSOR_CALIBRATION.md` (scenario self-tests for a cold agent).
- **`MANUAL.md`** — the human operator's guide: what each part is, how it works, how to run
  a project with it.

## Install

```bash
git clone <this-repo> ~/manifold
~/manifold/bootstrap/install.sh /path/to/your-repo --overlay <your-overlay>
```

That copies the core skills, rules, and templates into your repo's `.claude/`, assembles a
`CLAUDE.harness.md` constitution from the scaffold + your overlay's slot fills, and writes a
hash manifest so you can later tell your own local edits from upstream drift. Add `--link`
to symlink instead of copy (live-tracks the harness repo). Then verify:

```bash
~/manifold/bootstrap/doctor.sh /path/to/your-repo
```

`CLAUDE.harness.md` is written but never auto-included — see
[`bootstrap/INSTALL.md`](bootstrap/INSTALL.md) for the one-line manual include and the full
mechanics.

**No overlay yet?** Copy `overlays/_template/` to `overlays/<your-project>/` and fill it in
— it is a fully documented blank, and the installer names anything you missed. Start with
`MANUAL.md` for the guided tour.

## Layout

```
core/            project-agnostic: CLAUDE.scaffold.md, METHODOLOGY.md, ENFORCEMENT.md,
                 SUCCESSOR_CALIBRATION.md, skills/, principles/, case-law/, rules/, templates/
overlays/        per-project adaptation: _template/ (documented blank) + your overlays
bootstrap/       install.sh · doctor.sh · selftest.sh · INSTALL.md
MANUAL.md        the human operator's guide
FIELD_GUIDE.md   the incoming agent's orientation
```

The split is load-bearing: `core/` contains zero project references (mechanically verified),
so the discipline survives being carried to your next project. Everything concrete — real
paths, real names, model pins, hooks — lives in an overlay.

## Verify the tooling

```bash
bash ~/manifold/bootstrap/selftest.sh
```

Builds a throwaway fixture harness and proves install/doctor end-to-end (assembly, bindings,
fail-closed unfilled slots, hash manifest, drift detection, `--link` mode). Exits nonzero on
any failure.

## License

MIT — see [LICENSE](LICENSE).
