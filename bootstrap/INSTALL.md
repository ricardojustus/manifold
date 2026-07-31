# Installing the Manifold harness

## Platforms

Created on macOS and developed there. **Linux works** — the scripts resolve the platform
differences (SHA-256 tooling) at runtime. **Windows is not yet systematically tested**, though
early installs have worked: Claude Code runs these scripts through Git Bash. The optional
inter-session module is Unix-only (macOS/Linux/WSL).

## Command

```
bootstrap/install.sh <target-repo> --overlay <name-or-path> [--link]
                     [--profile base|full] [--modules m1,m2]
                     [--allow-placeholder-template] [--overwrite-local]
bootstrap/install.sh <target-repo> --bootstrap [--profile base|full] [--modules m1,m2]
bootstrap/update.sh  [<target-repo>] [--no-pull] [--overwrite-local]
bootstrap/doctor.sh  <target-repo> [--harness <harness-repo-path>]
bootstrap/maintenance-check.sh <artifact-root> [--days N]
```

## First-time setup: `--bootstrap` + the onboarding interview

A new project has no overlay, and an overlay is what makes the harness *that project's*
harness — ten slot files, a security posture, model pins. Filling them by hand before your
first session is the wrong order. `--bootstrap` inverts it:

```
bootstrap/install.sh /path/to/your-repo --bootstrap
```

This installs the core discipline set at `--profile base`, plus the `harness-onboarding`
skill and a marker file `.claude/manifold-onboarding-pending` (which records the path of this
harness clone). It deliberately assembles **no** `CLAUDE.harness.md`: with no overlay there
are no slots, so the fail-closed rule has nothing to fail on — the constitution simply does
not exist yet, and nothing pretends it does. The manifest records `mode: bootstrap`, and
`update.sh` on such a manifest replays bootstrap mode unchanged.

Then open a Claude Code session in the project and run `/harness-onboarding`. Three acts:

1. **The interview** — one question at a time: who you are and how you like to work · what
   the project is and where its ground truth lives · what is off-limits (the security
   directive and hard rules arrive as written suggestions you accept, edit, or drop — never
   blank, never invented) · your model pins (pre-filled with dated public defaults, one
   confirm question) · your agent's name · whether several sessions will work this repo at
   once. Answers become `manifold-overlay/` at the root of your own project repo — a fixed
   convention, so your configuration lives with your project (private with it) and a resumed
   session always knows where to look. Act 3 installs from there with
   `--overlay <target>/manifold-overlay`; keeping an overlay inside this harness clone
   (`overlays/<name>/`, the right home for a meta-project) stays available via the same flag.
2. **Optional capabilities** — the two Manifold modules (`inter-session`, `multi-agent`) and
   the companion tools below, each asked before installing and verified after. The
   cross-model counterparty is *guided, never auto-installed*: it has its own account and
   billing.
3. **Assemble and verify** — the full install with your new overlay, `doctor.sh`, marker
   cleared, and a walkthrough of the two steps that stay manual on purpose (the `CLAUDE.md`
   include line and any hook wiring): the skill prints the exact text, you paste it, the
   skill verifies. A session never arms its own guards.

The skill is re-runnable at any point — it detects how far you got instead of assuming a
fresh start. `doctor.sh` warns while the marker is still there.

**Updating.** `update.sh` is the one-command update for an installed project: it reads the
project's own `.claude/manifold-manifest.yaml` (overlay, mode, profile, modules — recorded at
install), fast-forwards the harness clone when it has an upstream (`--no-pull` skips), and
re-runs `install.sh` with the recorded settings — so nobody has to remember the original
flags. Run it from the harness clone; with no argument it updates the project you're standing
in. All the re-install safety semantics below apply unchanged.

**Profiles.** `--profile base` installs the core discipline set; `--profile full` adds the
optional modules — `inter-session` (peer-session messaging bus + its Python runtime) and
`multi-agent` (parallel-workstreams + merge-and-cleanup). Enable modules individually with
`--modules`. The overlay manifest may pin `profile:`/`modules:`; the CLI overrides; the
default (nothing specified anywhere) is full, for back-compat. `doctor.sh` reports each
module READY/UNAVAILABLE and flags skills whose referenced helper scripts are missing.

**Re-installing (upgrade).** A re-install reconciles against the prior manifest: files the
harness retired are **pruned** (removed if unmodified since install; kept with a warning if
locally edited), and a locally-edited managed file the new install would overwrite **aborts
the install** unless `--overwrite-local` — sync local edits back to the harness source first;
that is where they belong.

**Placeholder sentinels.** An overlay slot still containing the template's `<!-- FILL ... -->`
comment fails the install closed (it would assemble a valid-looking constitution with no real
identity). `--allow-placeholder-template` exists for installer smoke tests only.

`--overlay` takes either a bare **name** (resolved under this repo's `overlays/`) or a **path**
to an external overlay directory (any argument containing a `/`, or an existing directory).
The path form is what the onboarding interview uses (`<target>/manifold-overlay`) and what any
project keeping its overlay outside the harness clone uses; the external dir must contain `claude-slots/` or a `manifest.yaml`. The manifest
records which was used (`overlay: <name-or-abspath>`).

## What install.sh writes into `<target-repo>`

| Source (in this repo)            | Destination (in target)              | Notes |
|----------------------------------|--------------------------------------|-------|
| `core/skills/*`                  | `.claude/skills/*`                   | overlay `skill-bindings/<skill>.md` appended to that skill's `SKILL.md` |
| `core/rules/*`                   | `.claude/rules/*`                    | |
| `core/templates/*`               | `.claude/harness-templates/*`        | |
| `core/METHODOLOGY.md`, `core/ENFORCEMENT.md`, `core/principles/`, `core/case-law/` | `.claude/harness/` | |
| `FIELD_GUIDE.md` (repo root)     | `.claude/harness/FIELD_GUIDE.md`     | the onboarding narrative — ships with the installed project |
| `core/CLAUDE.scaffold.md` + overlay `claude-slots/` | `CLAUDE.harness.md` (target root) | assembled; **never** overwrites an existing `CLAUDE.md` |
| —                                | `.claude/manifold-manifest.yaml`     | records a sha256 per installed file |

### Binding `<artifact-root>` (the Evidence Store path)

Core prose (the constitution, several skills) references the project's Evidence Store as the
token `<artifact-root>` — the root where `audits/` and `councils/` records live. The overlay's
`manifest.yaml` MUST declare a top-level `artifact_root:` key; the installer substitutes it
into every staged `.md`. Like an unfilled slot, a **missing** `artifact_root` fails the install
closed (nothing written), naming each file that still carries the unbound token.

### Including the constitution

`install.sh` writes `CLAUDE.harness.md` and deliberately does **not** touch your existing
`CLAUDE.md`. Include it yourself, once, with an import line in your `CLAUDE.md`:

```
@CLAUDE.harness.md
```

## Slot assembly (the constitution)

The scaffold `core/CLAUDE.scaffold.md` contains named placeholders in the form
`{{HARNESS:slot_name}}` (lowercase snake_case). Assembly replaces each placeholder with
the contents of `overlays/<name>/claude-slots/slot_name.md`:

- An **empty** slot file is a valid fill — the placeholder is removed.
- A placeholder with **no** matching slot file is an unfilled slot. The install writes
  nothing to the target, prints each offending placeholder with its line, and exits
  nonzero (**fail-closed**). Fix by adding the missing slot file to the overlay.

Assembly happens in a scratch staging directory; the target is touched only after the
whole install passes the unfilled-slot scan, so a failed install never leaves a partial
tree behind.

## Copy vs `--link`

- Default (**copy**): files are copied at their current version. Your later edits are
  yours; `doctor.sh` reports them as `LOCAL-CHANGE` (informational, sanctioned).
- `--link`: files are symlinked to this repo, so they live-track it. A skill that has an
  overlay binding cannot be a symlink (you cannot append to a link), so that skill's
  `SKILL.md` falls back to a real copy — recorded per-file as `mode: copy` in the
  manifest. Linked files always match their source, so they never show as `STALE`.

## doctor.sh

Reads the manifest and prints one line per file:

- `OK <path>` — installed file matches the manifest hash.
- `FLAG LOCAL-CHANGE <path>` — installed file differs from the manifest (a sanctioned
  local edit; informational, does not fail).
- `FLAG MISSING <path>` — a manifest file is gone (**fails** the run).
- `FLAG STALE <path>` — with `--harness <path>`: the install still matches the manifest,
  but the harness source has since changed (an upgrade is available; does not fail).

Plus a structural lint over installed skills (frontmatter `name`+`description`,
`name` == directory, WARN on descriptions >150 words or bodies >500 lines), an
unfilled-slot scan, and a check that `.claude/harness/` exists. Exit is nonzero iff there
is a `MISSING` file or an unfilled slot.

## Vendored (upstream) skills

These skills are **vendored from upstream**, not authored here. They are never forked into
`core/` — install each from its upstream source so it tracks upstream updates. The first four
are published in Anthropic's skills repo; `karpathy-guidelines` is a Claude Code plugin.
**The onboarding interview offers the last two** (`karpathy-guidelines`, `ponytail`) — asking
first, installing from upstream, and verifying afterwards; everything here applies whether the
skill installs them or you do:

| Skill | Purpose | Provenance |
|---|---|---|
| `claude-api` | Build/debug/optimize Claude API + Anthropic SDK apps; model migrations | Anthropic (`anthropics/skills`) |
| `mcp-builder` | Author MCP servers | Anthropic (`anthropics/skills`) |
| `skill-creator` | Create / edit / eval skills | Anthropic (`anthropics/skills`) |
| `doc-coauthoring` | Co-author docs | Anthropic (`anthropics/skills`) |
| `karpathy-guidelines` | Coding-guidelines depth for the constitution's Implementation Discipline section | `karpathy-skills` Claude Code plugin marketplace (`~/.claude/plugins/marketplaces/karpathy-skills/`) |
| `ponytail` | Minimality mode: a plan-blind YAGNI lens over CODE — session persona plus `ponytail-review` (diff) and `ponytail-audit` (whole repo) | `ponytail` Claude Code plugin marketplace (`dietrichgebert/ponytail`) |

`karpathy-guidelines` is **optional**: the constitution's Implementation Discipline section
states its four principles inline and refers to "the project's coding-guidelines skill, if one
is installed" generically (core names no specific repo — a purity requirement). Install this
plugin to get the fuller worked-examples depth; skip it and the four principles still apply.
**Exception: an overlay that wires this plugin into its authoring junctions (via its skill
bindings) makes it REQUIRED for that overlay's installs** — such an install without the plugin
leaves junctions ordering a nonexistent skill.

`ponytail` is **optional** and, if installed, is governed by `core/rules/minimality-mode.md`
(written generically, per the same purity requirement). Two install-time steps, both needed:
pin the default mode off — `~/.config/ponytail/config.json` = `{"defaultMode":"off"}`, or
`PONYTAIL_DEFAULT_MODE=off` (**its native default is `full`**, i.e. persona injection in every
session AND every dispatched subagent). The pin exists to keep the minimality persona out of
**lead and judgment seats**, where do-less is the wrong instinct: the rule turns it ON per
seat, deliberately — dispatched implementation and audit-fix seats, and reviewer seats, which
are sanctioned. Also leave it off the cross-model counterparty CLI, which occupies implementer
and reviewer seats only. `doctor.sh` warns if ponytail is installed with the pin unset.

Provenance: the Anthropic-published skills ecosystem (`anthropics/skills` + the Anthropic
plugin marketplace). **Install from upstream, never fork** — a fork drifts from Anthropic's
updates and re-introduces the maintenance burden the vendoring avoids. They are not shipped
in this repo's `core/` or `overlays/`; the overlay only *depends on* them. (The manifold
installer does not fetch them — add them to a target the same way the live checkout has
them: from their upstream source.)

## ⚠️ Re-install / upgrade caution (v0.1 — R-2)
Re-running `install.sh` onto an already-installed target OVERWRITES installed files —
including any deliberate local modifications (which the manifest + `doctor.sh` track as
sanctioned `LOCAL-CHANGE`). Until the guarded `--upgrade` mode ships (H5/H7): run
`doctor.sh` first, and hand-preserve any `LOCAL-CHANGE` files before re-installing.
