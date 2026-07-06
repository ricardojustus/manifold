# core/agents/ — named subagent roles

Role definitions installed to the target's `.claude/agents/`. A role file carries **identity,
tool restrictions, and standing doctrine** for a recurring dispatched role — it is the WHO of
a dispatch. The WHAT-to-do stays in skills (procedure) and the per-dispatch brief (the
contract); an agent file that duplicates a skill's procedure will silently drift from it.
(To give a role shared procedure, point at the skill — or preload it whole via the `skills:`
frontmatter field — never paste it.)

Grounding: the 2026-07-06 research capture (official docs + Anthropic's shipped plugin agents
+ community practice) — see the overlay's research pointer. The load-bearing rules:

- **A role earns a file when**: it recurs across sessions with a stable identity and rubric,
  it is dispatched via the Agent tool (terminal-session lanes don't consume agent files), and
  its tool restrictions or standing doctrine are worth enforcing structurally. Keep the
  roster SMALL (community consensus: 4–8 max) and prune abandoned roles — every description
  costs context in every session.
- **Model/effort doctrine**: pin in frontmatter ONLY settled per-role economics (the reviewer
  pins `effort: xhigh` — a receipted, role-stable choice). Anything that varies per dispatch
  stays UNSET: the dispatcher's per-invocation `model` parameter beats frontmatter (resolution:
  env `CLAUDE_CODE_SUBAGENT_MODEL` > invocation param > frontmatter > session model), which is
  how a spec's dispatch-triage stays in charge. ⚠ Model pins have known runtime-reliability
  bugs — verify a pin on a real invocation before trusting cost assumptions.
- **Tools are least-privilege + prose**: restrict to the role's actual needs (a reviewer gets
  no Edit) AND state the constraint in the body — Anthropic's own agents do both.
- **Dispatch is explicit.** These roles are named by skills (`subagent_type: "reviewer"`), not
  left to description-matching — auto-delegation is unreliable in practice, so descriptions
  here are honest routing notes, not trigger bait.
- **Background gotcha**: a background subagent silently auto-denies permission-prompting tool
  calls. Any role that writes a report needs the return-it-inline fallback (see reviewer).
- **Returns are distillations**: artifacts to durable files, a 1–2k-token structured handoff
  back to the dispatcher.

Current roster: `reviewer` (audit-cycle's primary arm), `implementer` (dispatched build work).
**Deliberately not built** (add only when their trigger fires): a `researcher` (built-ins +
the research skill's pre-feed cover it; trigger: recurring boilerplate or a source-quality
incident in research dispatches) and council seat roles (mandates are templated in the
council skill; trigger: seat drift or much higher cadence).

Overlays may add roles (`overlays/<name>/agents/`) and append project concretes to core roles
via `overlays/<name>/agent-bindings/<role>.md` (same append mechanism as skill-bindings).
