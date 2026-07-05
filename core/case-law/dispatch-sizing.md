# Dispatch sizing — how many agents, how big, which primitive

The skills give you the dispatch *menus*; this is the sizing *function* — how to decide whether a task is inline work, one subagent, a small comparison fan-out, or a true decomposition into parallel lanes. Get this wrong in the expensive direction (10 agents for a 3-call task) and you burn budget and drown in reports; wrong in the cheap direction (one agent for genuinely independent parallel writes) and you serialize work that should have run at once, or cross-pollinate lanes that should have been isolated.

## The sizing function

Four inputs decide the size:

1. **Cost of being wrong** — how expensive is a bad result? High cost pulls toward more independent verification (a second lens, a fresh-eyes pass), not toward more parallelism.
2. **Subtask independence** — can the pieces run without talking to each other? Independence is what *makes* fan-out safe; coupled subtasks that need to negotiate mid-flight want one agent (or a synchronous conversation), not N.
3. **Context budget** — is there room for N agents' worth of context, or does the work need one coherent context that N splits would fragment?
4. **Operator attention** — is the operator watching (can arbitrate mid-flight) or async (needs the work to complete without them)? Async pushes toward self-contained lanes with parked questions, not toward dispatches that stall waiting for a decision.

## The tier bands (survey numbers — dated, re-verify per finding-freshness)

| Shape | Size | Use when |
|---|---|---|
| **Inline** | 0 agents | You know the file/symbol/value; a single lookup or edit. Don't dispatch to search for one known fact. |
| **Single subagent** | 1 agent, ~3–10 tool calls | A bounded task (a search across many files, a trace, a summary) where you want the conclusion, not the file dumps. |
| **Comparison fan-out** | 2–4 agents | Genuinely comparative work — two implementations to bake off, two-to-four lenses on one artifact, a few independent research angles. |
| **True decomposition** | 10+ agents | Only when the work genuinely splits into many independent pieces. 10+ is a decomposition signal, not a thoroughness flex. |

**Two numbers to hold:** token spend explains roughly **80% of outcome variance** — how much *thinking* you buy dominates almost everything else, so spend it where the judgment is (see *model-economy*). And a subagent's return should target **1–2k tokens** — a report that comes back at 10k is doing your synthesis for you and hiding the signal; brief it to return the conclusion and the load-bearing evidence, not a transcript.

## Which primitive (the selection rule)

- **Inline subagent** (no shared mailbox, returns via tool-result) — for fire-and-return work where you need only the final answer. The cheapest coordination.
- **Named teammate** (addressable, mailbox, lifecycle) — when the work needs *mid-flight* two-way communication, or the operator's word named it a teammate. Their word is the contract (see *operator-vocabulary*).
- **Scripted workflow** (a deterministic orchestration script fanning out agents — where the runtime provides one, e.g. a Workflow tool) — when the *control flow* is known in advance and shouldn't depend on model judgment: fixed pipelines over a work-list, loop-until-dry discovery, N-lens verify stages with schema-validated returns. The script owns the loops and barriers; the agents own only their single tasks. Prefer it over hand-orchestrating the same fan-out turn-by-turn (cheaper, resumable, the control flow can't drift); prefer plain agent dispatch when the next step genuinely depends on judging the previous result. The project binding pins the concrete tool and conventions.
- **Parallel lanes** (separate sessions, each in its own git worktree) — for multiple independent *writers* on locked specs, where each lane runs its own full build+verify cycle and returns a status. The default shape is one orchestrator + N lanes: the orchestrator builds the worktrees, drafts the briefs, dispatches, watches for cross-lane drift, and sequences the merges.

**Worktree isolation is mandatory for parallel writers.** Two agents writing in subdirectories of one shared checkout cause branch-flip races and test cross-pollution — a *structural* failure, not an opinion. One worktree per writer, symlink the shared dependencies, brief each with its own worktree path everywhere. *Receipt: two implementers dispatched into subdirectories of a single shared checkout produced a branch-race and cross-contaminated test state — three restart cycles and a large token burn before "kill everything, restart on separate worktrees." Isolation is the precondition, not the polish.*

## The cost-of-being-wrong × independence matrix

|  | **Low independence** (coupled) | **High independence** (parallel-safe) |
|---|---|---|
| **Low cost-of-wrong** | Inline or one subagent — don't over-invest. | Small fan-out if it saves wall-clock; otherwise inline. |
| **High cost-of-wrong** | One agent + a second verification lens (coupled work can't be safely split; buy verification, not parallelism). | Parallel lanes in worktrees, each self-verifying, + a fresh-eyes consolidation pass on the assembled result. |

*Receipt: a dispatch mechanism was scaled to substantive parallel work before it had been validated end-to-end even once — the Cardinal Rule (research/validate before acting) applies to mechanisms, not just designs. A five-minute canary that exercised the full dispatch path would have surfaced the failures that instead cost hours. Validate the mechanism at n=1 before you fan it out.*

## How to apply

- Run the four-input function *before* choosing a size; don't reach for fan-out because the task "feels big."
- Size the return, not just the count: brief every subagent to come back at 1–2k tokens with the conclusion + load-bearing evidence.
- The concrete primitive names, spawn signatures, and worktree conventions are project-specific — the project binding supplies them; this file owns the *sizing judgment*.
- Pairs with *model-economy* (which tier per agent) and *operator-vocabulary* (their word selects the primitive).
