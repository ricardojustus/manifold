# The grounding ladder — the shared reading spine

Both `session-start` and `phase-start` load the design **as already decided** BEFORE any
new theorizing. This is the reading order they share. It lives in one file so it can't drift
into two half-maintained copies; each skill points here and adds its own distinct steps
around it.

**The rule the ladder enforces**: nothing you propose should surprise the prior work. Forming
a hypothesis before reading what was already decided is the single most-corrected failure
mode in this discipline — the ladder is the structural defense against it.

Read the rungs **in order**. Do **not** skip a rung because you "already know" the topic;
pattern familiarity is exactly the trap ("I already know how this works, let me start") that
fires the first-hypothesis trap before any research. When in doubt whether something is
"enough of a phase" to warrant the ladder, run it — the cost is a few minutes; the cost of
skipping it is hours spent building the wrong thing.

## The rungs

### 1. Plans — design intent, the section not the headline
The project's plan/design docs governing this area. Read the governing section **end-to-end**,
not its summary. (The project binding names the concrete plan paths.)

### 2. Current-state / reference docs — what is actually running
Consult the project's always-loaded **self-knowledge index** and read **end-to-end** every
current-state reference doc relevant to today's work. These docs exist specifically so you
don't re-derive live-system shape through an expensive review cycle — skipping them is the
failure the index was built to prevent. *Receipt: a multi-round review once had to discover,
deep into the rounds, a live daemon interaction that a current-state reference doc had
documented all along; nobody had read it at the start.* (The binding names the index and the
reference-doc location.)

**When a plan and a reference doc disagree**: the reference doc is right for *current state*;
the plan is right for *design intent*. Hold both.

### 3. Lessons — grep the topic, read every match in full
Grep the project's lessons store for the topic keywords and read **every match end-to-end**.
This is a hard rule, not a nicety — lessons capture hard-won findings that rescue you from
re-deriving a solved problem. (Binding names the lessons path.)

### 4. Memory — grep the always-loaded store, then query the recall system
Grep the project's memory store for topic-relevant entries. It is always loaded, but
topic-specific entries still warrant active consultation:
- behavioral-rule / feedback entries that apply to the work shape you're about to do
- decision entries that constrain the design space
- project-fact entries with current state

Where the project has a queryable memory system beyond the always-loaded store (a recall
tool, a belief graph — the overlay binding names it), run ONE query on the subsystem +
mechanism you're entering: **"prior operator rulings on <mechanism class>"**. Operator
rulings are often captured thread-local and never promoted — the recall system is the only
surface that sees across threads. *(Receipt: a "no wall-clock progress gates" ruling sat in
one thread's files for 6 days while another thread locked a spec violating it — the ruling
was in the graph the whole time; nothing queried it.)*

### 5. State snapshot — the sections that touch this work
Read the live state snapshot's relevant sections. Confirm the boundary isn't already resolved;
check for blocking dependencies and for framings that must not regress.

### 6. Source — what's implemented vs specced
Read the real code paths for the subsystem in scope, end-to-end where they're load-bearing.
Spec ≠ implementation: when they diverge, the implementation wins for current state, the spec
wins for design intent. (For agent-specific work, also read that agent's identity/operational
files.)

### 7. Verify the plan's PREMISES against the runtime — then record a §0 Verified-Inputs note
A plan states premises ("X doesn't exist yet", "the store is empty", "Y is still on the old
path"). **Premises rot.** Before you build on one, *probe the runtime to confirm it still
holds* — an `ls`, a count, a query, a fresh read. Record what you checked and what you found
as a short **§0 Verified-Inputs** note in the artifact you're about to produce, so the next
reader inherits verified inputs, not assumed ones. *Receipt: a build once ran its entire first
stage on the plan's premise that a needed corpus "did not exist" — hundreds of those records
had existed the whole time; one probe of the runtime would have caught it before the wasted
stage.*

### 8. ONLY THEN — external research
Vetted external sources, in the project's source-priority order (official docs of the stack →
vetted community repos → empirical testing last, and say so when you switch to empirical).
"Research to validate my theory" is the wrong framing; **"read the design so my theory is
grounded in what was decided"** is the right one.

### 9. ONLY THEN — hypothesize, plan, or propose
If you catch yourself forming a theory before finishing the rungs above, **stop and go back**.
The point of the ladder is to ground theory in what was already decided.
