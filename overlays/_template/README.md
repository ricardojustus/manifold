# overlays/_template — documented blank overlay

Copy this directory to `overlays/<your-project>/` and fill it in. An overlay adapts the
project-agnostic `core/` to one project. Every directory below is optional except
`claude-slots/` (the scaffold fails closed on any unfilled slot); an absent directory simply
contributes nothing.

```
overlays/<name>/
├── manifest.yaml        # overlay metadata (name, runtime, what it binds); its comments state the contract.
├── claude-slots/        # one <slot_name>.md per {{HARNESS:slot_name}} placeholder in core/CLAUDE.scaffold.md.
│                        #   - filename (minus .md) MUST equal the slot name.
│                        #   - an empty file is a valid fill (placeholder removed).
│                        #   - EVERY placeholder in the scaffold needs a file here, or install fails closed.
├── rules/               # project rule files (.md), installed to .claude/rules/ (README.md skipped).
├── skills/              # project-only skills (each <name>/SKILL.md), copied alongside core skills.
├── skill-bindings/      # <core-skill-name>.md, appended to that core skill's SKILL.md as a
│                        #   "## Project bindings" section on install.
└── hooks/               # OPTIONAL enforcement bindings per core/ENFORCEMENT.md's ladder + taxonomy
                         #   (installed to .claude/harness-hooks/, DRAFT — wiring is manual; README.md skipped).
```

This `_template/` ships a **fillable skeleton**: every one of the 10 slots is present as a
commented `<!-- FILL … -->` file and `manifest.yaml` sets `artifact_root: .`, so a raw copy
**installs out of the box** — but with placeholder content, so replace the FILL comments with
real content before you rely on it. Each subdirectory carries a one-line README explaining what
goes in it. Delete the placeholder READMEs (or leave them — the installer skips any `README.md`).

## Fill order (recommended)

1. **`manifest.yaml`** — set `name` (must equal the directory name), `runtime`, `description`,
   and set `artifact_root` (defaults to `.`, the target repo root — point it at your project's
   audit/evidence dir; removing the key entirely makes the install fail closed).
2. **`claude-slots/`** — fill each slot from your project's constitution / operator profile.
   The comment in each file says what it needs. `identity`, `user_import`, `system_map`,
   `security_directive`, `memory_paths`, `comms_style` are almost always worth writing;
   `self_knowledge_corpus`, `project_hard_rules`, `compact_instructions` may be empty early.
3. **`rules/`** — drop in any binding project directive that doesn't generalize into core.
4. **`skill-bindings/`** — for each core skill that needs project concretes (paths, dispatch
   mechanics, doc-corpus refs), add `<skill>.md`; it appends as a `## Project bindings` section.
5. **`hooks/`** — optional. Read `core/ENFORCEMENT.md`'s enforcement ladder FIRST: prefer a
   native classifier rule (settings `autoMode` allow/soft_deny) or an informational /
   anti-escape hook; deny hooks on work surfaces are operator-commissioned only, with
   ownership of every hard-coded path verified. Any hook that denies ships with a
   `selftest-hooks.sh` asserting its block path (exit 2 — see the exit-code footgun).
6. Keep `manifest.yaml` in sync with what you actually added.

## Steering documents (fill at init)

A new project SHOULD, at init, copy the three **steering documents** from
`core/templates/steering/` (`product.md`, `tech.md`, `structure.md`) into its own docs tree
and fill them — the durable per-project context (what the project is + for whom, the stack +
conventions + non-negotiables, and where things live + go). These are loaded once per project,
not per dispatch: once they exist, a brief's GIVEN block **cites** them for the stable project
context instead of re-deriving it every time (see `core/skills/brief-authoring`). Filling them
at init is the cheapest point; a project without them makes every dispatch re-discover the same
standing facts.

## Install + verify

```
bootstrap/install.sh <target-repo> --overlay <name> [--link]
bootstrap/doctor.sh  <target-repo>
```

Assembly is exact: the installer replaces each `{{HARNESS:slot_name}}` in
`core/CLAUDE.scaffold.md` with `claude-slots/slot_name.md`. If any placeholder has no
matching slot file, the install writes nothing to the target and exits nonzero, naming each
unfilled slot. `doctor.sh` then verifies the installed tree against the manifest.

## Future tooling

An interactive `harness-init` interview (planned) will walk a new project through these
steps — asking for the operator profile, the system map, the security posture, etc., and
writing the slot files for you. Until it lands, fill the skeleton by hand — each slot file's
FILL comment states its contract, and `install.sh` fails closed naming anything you missed.
