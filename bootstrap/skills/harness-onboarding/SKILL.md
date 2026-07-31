---
name: harness-onboarding
description: >-
  Sets up the Manifold harness for this project by interviewing the operator: writes their overlay from the answers, offers the optional modules and companion tools, then installs, verifies, and walks the two manual steps. Use on "/harness-onboarding", "set up manifold", "finish the harness install", or when .claude/manifold-onboarding-pending exists.
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# Harness onboarding

This project has the Manifold harness half-installed: the onboarding kit is here, the overlay
that makes it *this project's* harness is not. You are going to write it — by asking the
operator, not by guessing.

## The contract (read before the first question)

- **One question at a time.** Wait for the answer. Never batch a questionnaire.
- **The operator is the source.** Never invent facts about them, their project, or their
  security posture. A suggested default is used only when they explicitly accept it.
- **Offer, don't assume.** Every suggestion below is presented as text they can accept, edit,
  or drop. "Drop" is always a legal answer; the slot can be empty.
- **You never arm anything.** The `CLAUDE.md` include line and any hook wiring stay the
  operator's to paste. You print the exact text, they paste, you verify. Act 3 says this again
  because it is the one rule that never bends.
- **Authoring writes go nowhere except this repo** — the overlay you write lives in it, at
  `manifold-overlay/`, and Act 1 appends one line to this repo's `.gitignore` so the overlay
  stays private by default.
  Act 2 has exactly three writes outside this repo, each asked before it runs: the Claude plugin
  state a `claude plugin install` updates (`~/.claude/plugins/`, plus that plugin's
  `enabledPlugins` entry in `${CLAUDE_CONFIG_DIR:-~/.claude}/settings.json`), the `inter-session` Python
  venv its own install-deps flow builds (`~/.claude/data/inter-session/`), and ponytail's
  machine-wide default pin (`~/.config/ponytail/config.json`). Nothing else, ever.

## Step 0 — locate the harness and detect where you are

```bash
cat .claude/manifold-onboarding-pending 2>/dev/null
sed -n 's/^harness_root:[[:space:]]*//p' .claude/manifold-onboarding-pending 2>/dev/null
```

`harness_root` is the Manifold clone (`<harness>` below). If the marker is missing — or its
recorded path no longer resolves (the clone was moved or renamed), treat that as missing too —
ask the operator where they cloned Manifold and confirm `<harness>/bootstrap/install.sh` exists.

**This skill is re-runnable.** Detect state from what is already on disk, don't assume a fresh
start:

| Check | Meaning | Where to resume |
|---|---|---|
| `manifold-overlay/` absent | nothing written yet | Act 1, from the top |
| overlay exists, `grep -rl FILL manifold-overlay/claude-slots/` non-empty | Groups 1–3 incomplete | Act 1, only the slots still carrying a FILL comment |
| slots all filled, marker still present | Groups 1–3 done, install not | Act 1 from Group 4 (read the traces below), then Act 2 |
| marker absent, `CLAUDE.harness.md` present, the include check below finds nothing | the Act-3 install ran, the manual steps did not — the constitution exists but nothing is in force | Act 3 step 4 |
| marker absent, `CLAUDE.harness.md` present, that same check finds the line | already onboarded | say so; offer to re-run `doctor.sh` and stop |

The include check (also Act 3 step 4):

```bash
grep -nE '^[[:space:]]*@CLAUDE\.harness\.md([[:space:]]|$)' CLAUDE.md
```

It requires the line to **be** the import, not to mention it: a commented-out or
talked-about `@CLAUDE.harness.md` (`# @CLAUDE.harness.md is disabled`) includes nothing, and a
substring search would read it as onboarded. Leading indentation and trailing whitespace are
still an active import, so the pattern accepts them.

Groups 4–6 leave weaker traces than the slot files. Read these before calling Act 1 done:

- **Group 4** — `manifold-overlay/rules/model-pins.md`. It exists from Act 1's `cp` carrying the
  pre-filled defaults, so its presence cannot tell you whether Q13 was ever asked. **On any
  resume, re-ask Q12 and Q13** (billing shape, then the one pins confirm question) — a default
  is only adopted when they accept it.
- **Group 5** — `manifold-overlay/manifest.yaml`: `name:` equal to `<project>` and a
  `description:` with no `<…>` placeholder left. Still bracketed ⇒ replay Group 5.
- **Group 6** — no durable trace at all; Q15's answer only ever lived in the conversation.
  **On any resume, re-ask Q15** (one question) before Act 2's module questions.

Tell the operator which of these you found before asking anything.

---

# Act 1 — the interview

**Name the overlay first.** Propose the repo's directory name (lowercase, hyphens); confirm or
take theirs. That name is `<project>` below — it names the overlay in its manifest, not its
directory.

```bash
cp -R <harness>/overlays/_template manifold-overlay
```

The overlay lives at `manifold-overlay/` in the root of THIS repo — the project being onboarded.
That is a fixed convention, not a choice: their identity, paths, and security posture stay in
their own repo, private with it, and this skill can always find it again. Keep it private by
default, right after the `cp`:

```bash
grep -qxF 'manifold-overlay/' .gitignore 2>/dev/null || printf '\nmanifold-overlay/\n' >> .gitignore
```

Then tell them what that means: the overlay holds their identity, real paths and never-touch
list, so it is gitignored by default — it will not be pushed to any remote and will not be
backed up with the repo, and if they want it versioned (a private repo, or a team that should
share the posture) they delete that one line from `.gitignore` and commit the directory.

Then work through the six question groups **in order**, one question at a time, writing each
slot file as soon as its group is answered (so an abandoned interview loses only unanswered
questions). Slot files live in `manifold-overlay/claude-slots/`.

Each template slot opens with a FILL comment stating that slot's contract — **read it before
asking that group's questions**, and **delete it when you write the real content**. Two slots
(`security_directive`, `project_hard_rules`) also carry suggested content below their FILL
comment: that is the text you offer verbatim. Those two slots carry a second wrapper comment
(`<!-- Suggested starting content … -->`) — **delete both comments** and keep only the text you
and the operator agreed on; the wrapper is authoring meta and would otherwise ship inside their
always-loaded constitution. The installer refuses to build a constitution while any FILL comment
survives, so a slot is either genuinely filled or genuinely empty:

```bash
grep -rn 'FILL' manifold-overlay/claude-slots/    # must be empty when Act 1 ends
grep -rnE '<[a-z][^>]{10,}>' manifold-overlay/claude-slots/   # also must be empty
grep -rnE '<[a-z][^>]{10,}$' manifold-overlay/claude-slots/   # ... and so must this one
```

The last two greps catch angle-bracket placeholders **inside slot content** (`<name them — e.g.
main and production>`); the second of them exists because a placeholder that wraps before its
closing `>` is invisible to a line-oriented pattern. No installer gate looks there, so a bracket
that survives ships prose that reads like a stated posture while its actual content is an
instruction to the reader. Each hit is either replaced with the operator's real answer or the
whole line is dropped — except a hit that is a real angle-bracket token in their own prose
(`<subsystem_id>` in a documented command) rather than a placeholder: leave that alone, and say
which you concluded.

### Group 1 — who you are and how you like to work → `identity`, `user_import`, `comms_style`

1. What should the agent call you, and what is your role on this project?
2. What should the agent be called, and what is it *for* here (its stance in one paragraph)?
3. Do you keep a profile file for yourself (name, working style, preferences) the agent should
   import? If not, offer to write the two or three lines you just learned directly into the
   slot instead of an `@`-import.
4. How should it talk to you? Offer the menu — they pick one, combine, or free-form:
   **deep-dive explanations** (the reasoning, not just the answer) · **quick plain-language
   summaries** (bottom line first, detail on request) · **dense technical shorthand** (they
   read code and specs; skip the translation). Then the rest: length, anything that annoys
   them (offer the harness's usual: no sycophantic openings, no formal sign-offs,
   plain-English summary at the end of anything touching code or infra), and their
   date/number/language conventions.
5. "When an engineering choice comes up mid-task, should the agent decide and note it, or
   bring you the options first?" Offer the spectrum: **decide-and-note** · **bring me the big
   ones** · **bring me everything**. Say what it changes: the harness's decision-packet
   ceremony scales with this answer — the further toward "bring me everything", the more
   junctions stop and ask. Record it in `comms_style` beside Q4's answer.

### Group 2 — what the project is and where things live → `system_map`, `project_knowledge_sources`, `memory_paths`, a tracker binding in `manifold-overlay/rules/`

6. What is this project, and where does its code, runtime, and docs live? Anything the agent
   must know about and *not* touch?
7. When the agent needs ground truth, what should it read, in what order? (Suggest the harness
   default order: prior lessons → the project's plans and reference docs → official docs →
   vetted sources → empirical testing last, stated explicitly as a mode switch.)
8. Where should continuity files live — state, journal, decisions, questions-for-you, lessons?
   Offer the default (`.claude/` next to the harness, or a `docs/` folder) and move on if they
   have no preference. `self_knowledge_corpus` and `compact_instructions` are legitimately
   empty on a young project — say so and leave them empty rather than inventing content.
9. Does the project use an issue tracker — and which (Linear, Jira, GitHub Issues, …) — or
   plain files? Note what it changes: `to-tickets` and `wayfinder` publish to the tracker when
   there is one and fall back to plain ticket/map files when there is not. Record the answer in
   the overlay — a one-line tracker binding in `manifold-overlay/rules/` naming the tracker (or
   stating there is none, and where ticket files live), and listed in the manifest's `rules:` to
   keep it in sync — and mention it in `system_map` so the agent knows where work items live.

### Group 3 — what is off-limits → `security_directive`, `project_hard_rules`

10. Print the template's suggested security-directive text **verbatim** and ask: accept as-is,
    edit, or drop? Then ask the one thing the suggestion cannot know: **which concrete paths,
    repos, or systems are never to be touched**, and whether external access is read-only.
11. Same for the suggested hard rules: which branches and directories are protected, and any
    project-specific non-negotiable they already know they want (a vocabulary that binds, a
    "never commit without asking", a naming mandate).

Both suggestions carry `<…>` brackets where only the operator can supply the content (the
never-touch list, the protected branches). **A bracket is never shippable**: either their answer
replaces it, or that line is dropped from the slot. "Accept as-is" is not an answer to the
bracket — ask the bracket's question before writing the file.

Never soften a posture they state, and never widen one they don't. If they are unsure, say the
strict version is the safe start and can be loosened later with a one-line edit.

### Group 4 — which models you have → `manifold-overlay/rules/model-pins.md`

12. How is their model access billed: **flat-rate subscription** or **metered API**? On
    metered, say plainly what it changes and suggest leaner pins — a cheaper tier for the
    reviewer and implementer seats — and warn that the audit ladder's multi-round fan-outs bill
    per token, several seats per round. On flat-rate, the current defaults stand and the cost
    shows up as quota displacement instead. Their answer feeds Q13.
13. Show the pre-filled pins (frontier / mid / cheap, with the date they were written) and ask
    **one** question: "these are the current public defaults — right for your account, or
    should any tier be remapped?" (If Q12 said metered, offer the leaner mapping here as the
    suggestion.) Edit the file only if they remap something. If they have a
    second model family available (a cross-model reviewer seat), record it in the file's last
    line; if not, leave the line as-is — audits fall back to single-lens, which is documented.
    **If they remap a tier**, tell them the named subagent roles (`.claude/agents/reviewer.md`,
    `implementer.md`) carry their own `model:`/`effort:` frontmatter as the per-role default —
    installer-owned files, so the change belongs in the harness copy, not a local edit; point
    them at `core/agents/README.md`, which states how to change it.

### Group 5 — the manifest → `manifold-overlay/manifest.yaml`

14. Set `name:` to `<project>`, write the one-line `description:`, and ask where audit and
    council records should live — that is `artifact_root:` (default `.`, the repo root; accept
    it unless they name a docs/evidence directory). Leave `profile:`/`modules:` for Act 2.

### Group 6 — parallel sessions → the Act 2 input

15. "Will more than one Claude Code session work this repo at the same time — different
    workstreams, or parallel implementation lanes?" This single answer drives Act 2's module
    questions. Also ask, if yes, whether one session owns the shared state files or each
    workstream keeps its own folder; record their answer in `memory_paths`.

**Close Act 1** by running the FILL grep above and showing the operator the list of files you
wrote. Offer to show any of them in full.

---

# Act 2 — optional capabilities

Every install below is **asked before it runs and verified after it runs**. Nothing here is
installed silently, and a "no" is final — the operator can enable it later with one command.

### The two Manifold modules

| Module | What it gives them | Ask when |
|---|---|---|
| `inter-session` | A localhost messaging bus between parallel sessions on this machine (questions, FYIs, co-sign opinions — never remote) | they answered yes to Q15 |
| `multi-agent` | `parallel-workstreams` + `merge-and-cleanup`: dispatching several implementation lanes in separate git worktrees, then merging them | they answered yes to Q15, or they expect long multi-lane builds |

A "no" to both is the right default for a solo project — say so; they are re-enabled any time
by re-running the installer with `--modules`.

For each module they want, enable it now against the bootstrap install so the rest of Act 2 can
verify it:

```bash
<harness>/bootstrap/install.sh . --bootstrap --modules <comma-separated-modules>
```

Record the same list in the overlay manifest's `modules:` line so future updates keep them.

**`inter-session` yes-path also needs its Python runtime.** Run its own install-deps procedure
(`.claude/skills/inter-session/references/install-deps.md` — it asks for confirmation and
builds an isolated venv), then verify:

```bash
python3 .claude/skills/inter-session/bin/list.py --self
```

Any error here (a missing-dependency line, an import traceback) means install-deps did not
complete — say so plainly rather than leaving a module that looks enabled and isn't.

### The companion tools

These are third-party Claude Code plugins, installed from upstream — never vendored into this
repo, so they track their own updates. Marketplace first, then the plugin:

```bash
claude plugin marketplace add <source>
claude plugin install <plugin>@<marketplace>
claude plugin list                      # verification, every time
```

| Companion | Source / plugin id | Ask |
|---|---|---|
| ponytail (minimality mode: a plan-blind YAGNI lens over code) | `dietrichgebert/ponytail` → `ponytail@ponytail` | optional; recommend it if they build a lot of glue code |
| karpathy-guidelines (coding-guidelines depth for the constitution's Implementation Discipline section) | `forrestchang/andrej-karpathy-skills` → `andrej-karpathy-skills@karpathy-skills` | **required** if any of their overlay's skill bindings point at it; optional otherwise — the constitution states the four principles inline either way |

**ponytail has a second step humans skip: pin its default off.** Its native default is `full`,
which injects the persona into every session including lead and judgment seats; the harness
wants it opt-in per seat. After installing:

```bash
cat ~/.config/ponytail/config.json 2>/dev/null
```

- File absent → create it with `{"defaultMode":"off"}` (`mkdir -p ~/.config/ponytail` first).
- File exists and already pins `off` → nothing to do, say so.
- File exists with different content → **show it to the operator and ask before editing.** It is
  their machine-wide config, not this project's.

Verify by reading the file back and telling them what it now says.

### The cross-model counterparty — guided, never installed

If they want a second model family for reviewer seats (the audit discipline's cross-model
lens), **do not install it**: it has its own account, its own billing, and its own login. Tell
them what it is, what it costs them (a separate subscription and a `login` step), and how to
add it when they want it — the Codex plugin, `openai/codex-plugin-cc` → `codex@openai-codex`,
followed by that CLI's own authentication. Then ask whether to note it as pending in their
model-pins file. Audits without it run the documented single-lens fallback; that is a real
option, not a failure.

---

# Act 3 — assemble and verify

**1. Install for real.** Run the full install with the overlay Act 1 wrote:

```bash
<harness>/bootstrap/install.sh . --overlay ./manifold-overlay \
    --profile <base|full> [--modules <the Act 2 list>]
```

If it exits nonzero it names exactly what is wrong — an unfilled slot, a surviving FILL
comment, a missing `artifact_root`. Fix the named file and re-run; **never** pass
`--allow-placeholder-template` to get past it. Nothing is written to the repo until it passes,
so a failed install leaves nothing half-done.

This install also **removes both bootstrap-kit files** — the pending marker and this skill's own
copy in the target — because they are absent from the new install's file set. That is expected
(the kit's job is done), and it means **steps 2–5 must be finished in this session**: after step
1 there is no `/harness-onboarding` in the target left to re-invoke. If the session ends before
step 4, the constitution sits on disk with nothing including it, and the whole recovery is
pasting one line — `@CLAUDE.harness.md` into their own `CLAUDE.md` (`MANUAL.md` step 1).

**2. Run the doctor.**

```bash
<harness>/bootstrap/doctor.sh . --harness <harness>
```

Read its output to the operator in plain terms: blocking issues (it exits nonzero), warnings
(it does not). The onboarding-pending warning is already gone — step 1 removed the marker.

**3. Verify the marker is gone.**

```bash
ls .claude/manifold-onboarding-pending      # expected: No such file or directory
```

Step 1 removed it. If it is somehow still there, delete it now
(`rm -f .claude/manifold-onboarding-pending`) and say so.

**4. Walk the two manual steps.** These are manual on purpose: a session must never arm its own
guards or edit the file that governs it. You print, they paste, you verify.

*The include line.* Show them the exact line and where it goes — their own `CLAUDE.md`, at the
end (if they have no `CLAUDE.md`, ask them to create one — you never write this file):

```
@CLAUDE.harness.md
```

Offer to show them the assembled `CLAUDE.harness.md` first — it is their agent's standing
orders and they should see it before adopting it. When they say they have pasted it, verify:

```bash
grep -nE '^[[:space:]]*@CLAUDE\.harness\.md([[:space:]]|$)' CLAUDE.md
```

The line must **be** the import, not a substring of prose about it: a commented-out mention
includes nothing.
Report what you found. If it is not there, say so and offer the line again — do not write it
yourself, and do not treat their "done" as proof.

*The hook wiring.* Only if their overlay ships actual hook FILES. The installer also copies the
overlay's `hooks/README.md` (the wiring doc), so the directory is never empty — count what is
there excluding that README:

```bash
ls .claude/harness-hooks/ 2>/dev/null | grep -v '^README.md$'
```

No output — the template case, and every overlay that ships no hooks — say "no hooks to wire",
skip this step, and verify nothing in `settings.json`. Otherwise:
print the wiring snippet from the overlay's `hooks/README.md` verbatim, tell them it goes in
`.claude/settings.json`, and remind them not to wire a hook they have not read. After they
confirm, verify the wiring is present and run the hooks selftest if the overlay ships one:

```bash
grep -n 'harness-hooks' .claude/settings.json
bash .claude/harness-hooks/selftest-hooks.sh    # if present
```

**5. Close.** Tell them in plain English: what their agent now knows (identity, project map,
security posture, hard rules, model pins), which modules and companions are live, what the
doctor said, and that the include line makes it take effect in the **next** session, not this
one. Point them at `MANUAL.md` in the harness clone for the operator's guide and at
`.claude/harness/FIELD_GUIDE.md` for what the harness believes.

## When it goes wrong

- **Install fails on a slot you thought you filled** — the FILL comment is still in the file.
  Grep for it, delete that comment, re-run. Never bypass the check.
- **Operator quits mid-interview** — everything already written stays; re-running this skill
  resumes at the first unfilled slot (Step 0's table), re-asking Q12/Q13 (the pins file cannot
  prove it was confirmed) and Q15 (its answer was never written anywhere).
- **They want to redo part of this after the install finished** — re-run the full install with
  their overlay: `<harness>/bootstrap/install.sh . --overlay ./manifold-overlay` after
  editing the overlay files directly. Do **not** reach for `install.sh . --bootstrap`: over a
  finished install it removes the assembled `CLAUDE.harness.md` and every overlay-sourced rule,
  leaving their `CLAUDE.md` importing a file that no longer exists. The installer now refuses
  that command for exactly this reason.
- **A plugin install fails** — report the actual error, do not retry blindly, and continue with
  the rest of onboarding. Companions are optional by construction.
- **The operator disagrees with a suggestion** — theirs wins, always, including "leave it
  empty". Record what they chose, not what you would have chosen.
