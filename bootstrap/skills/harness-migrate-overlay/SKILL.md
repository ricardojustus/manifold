---
name: harness-migrate-overlay
description: >-
  Re-shapes this project's Manifold overlay for a new core generation (generation 1 to 2: seven slots instead of ten, a trimmed core skill roster), drafting the new slot files, showing the owner a per-slot summary plus the full diff, and writing only on their explicit yes. Use on "/harness-migrate-overlay", "migrate my overlay", "update.sh says a migration is staged", or when .claude/manifold-migration-pending exists.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Migrate this overlay to the new core generation

The harness moved from core generation 1 to generation 2. The constitution scaffold now has
**seven** slots instead of ten, and core carries fewer skills — so this project's overlay,
written against the old shape, no longer fits it: `update.sh` refused to install and staged you
instead. Your job is a one-time re-shape of the overlay: fold the retired slots into the ones
that survive, add the two new slots, delete bindings for skills core no longer has, and stamp
the manifest. You never write into the overlay without the owner's explicit in-session yes —
this is their project's constitution, and a wrong fold is a silently wrong agent.

## Step 0 — read the ground

```bash
cat .claude/manifold-migration-pending          # harness_root, overlay, core_generation
```

Read, in this order: the marker (it names `<harness>` and the overlay), the overlay's
`manifest.yaml`, every file under the overlay's `claude-slots/`, `rules/`, `skill-bindings/`,
`agent-bindings/`, and `<harness>/core/CLAUDE.scaffold.md` (the authority on which slots now
exist — trust the scaffold's `HARNESS` slot tokens over this file's table if they ever
disagree). Each `agent-bindings/<role>.md` must name a role under `<harness>/core/agents/`; an
orphan is listed for deletion exactly like an orphan skill binding.

If the overlay directory is missing or not writable, **stop and say so** — do not create one.

## The mapping table

| Generation 1 | Generation 2 |
|---|---|
| `identity` | `identity` |
| `user_import` | `user_import` |
| `system_map` + `memory_paths` | `system_map` |
| `comms_style` | `comms_style` |
| `project_hard_rules` + `security_directive` (project-specific lines only) | `project_hard_rules` |
| `self_knowledge_corpus`, `project_knowledge_sources` | drop (or fold one-line pointers into `system_map`) |
| `compact_instructions` | drop (core carries continuity) |
| `rules/model-pins.md` (or any rule that pins model IDs) | `model_pins` (new slot) |
| any rule listing accounts / config dirs | `accounts` (new slot, may be empty) |
| other `rules/` | the slot whose section they belong to, else keep as an overlay rule, else drop |
| `skill-bindings/<skill>.md` where `<harness>/core/skills/<skill>/` no longer exists | delete |

`security_directive` is retired because the generic security floor is core text now: carry over
only the lines that are specific to THIS project (named paths, its confidentiality scheme, its
own posture rules) and drop the generic ones. "Drop" is a legal outcome for any slot; an empty
slot file is a valid fill.

## Step 1 — draft

Work in a scratch dir — never in the overlay yet. Copy the whole overlay there FIRST, so the
draft is a full mirror and the diff in step 2 is complete:

```bash
cp -R <overlay>/. <target>/.claude/migration-draft/
```

Then make every change INSIDE the draft: write `claude-slots/<slot>.md` for each of the seven
slots the scaffold declares; delete the retired slot files; delete orphan `skill-bindings/` and
`agent-bindings/` files; delete the rules you dropped; and rewrite `manifest.yaml` so
`core_generation: 2`, `claude_slots:` is the seven, `skill_bindings:` is the binding files that
remain, and `rules:` is the rule files that remain (or `[]`). Preserve the owner's own words
when folding — you are re-arranging their content, not rewriting it.

## Step 2 — show, then ask

Show the owner, in one message:

1. **A per-slot summary** — one line per slot: `kept` / `moved from <old slot>` / `dropped`,
   plus the list of `skill-bindings/` and `agent-bindings/` files to delete and any `rules/`
   file dropped.
2. **The full diff** of the draft against the current overlay
   (`diff -ru <overlay> <target>/.claude/migration-draft`) — every change, since the draft
   mirrors the whole overlay.

Then **ask for an explicit yes**. Not "shall I continue?" buried in prose — a direct question,
one message, and wait. Anything other than a clear yes is a no.

## Step 3 — on yes

1. Replace the overlay's contents with the draft — the draft IS the approved overlay:
   `rm -rf <overlay>/*` then `cp -R <target>/.claude/migration-draft/. <overlay>/` (or
   `rsync -a --delete <target>/.claude/migration-draft/ <overlay>/`). Nothing to fold by hand:
   the retired slot files, the orphan bindings, the dropped rules and the rewritten
   `manifest.yaml` are already what the owner said yes to.
2. Delete `<target>/.claude/migration-draft/`. Leave `.claude/manifold-migration-pending` in
   place — `update.sh` removes it.
3. Tell the owner to run `<harness>/bootstrap/update.sh <target>` — that is what actually
   installs the new core. Offer to run it; do not run it unasked.

## Step 3' — on no

Leave `<target>/.claude/migration-draft/` in place for hand edits, leave the pending marker
alone, say which files are where, and stop. Re-running this skill later picks up from the
existing draft.

## Rules

- **Never edit `settings.json`.** Not in the target, not in the Claude config dir. Ever.
- Never write into the overlay before the yes; the scratch dir is the whole point.
- Never invent content for a slot. If a generation-1 slot has nothing that maps, it is dropped
  and the summary says so.
- If the scaffold's slot set does not match this file's table, follow the scaffold and tell the
  owner about the mismatch.
