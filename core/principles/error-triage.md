# Error triage — the code is a symptom, never a cause

**Rule.** An error code tells you *what surfaced*, never *why*. Before you act on any error, anomaly, or failure: **enumerate the distinct causes this code can have, read the actual body and headers, then probe** — verify the cause against evidence before you diagnose. Your first reaction to an error is a hypothesis, and it will usually be wrong.

This is the quick-reference companion to the constitution's *Errors — VALIDATE Before Diagnosing* rule; that section carries the full reasoning. Use this table shape at the moment an error lands.

| Step | Do | Do NOT |
|---|---|---|
| **1. Capture** | Paste the error verbatim — the code, the body, the headers. | Paraphrase it, or pattern-match the code to one remembered cause. |
| **2. Enumerate** | List every distinct cause this code can have (a 429 = per-minute throttle *or* concurrency cap *or* periodic cap *or* tier limit *or* transient — different fixes). | Assume the first plausible cause is *the* cause. |
| **3. Read signals** | Read `retry-after`, reset headers, account/quota state, the docs for this code. | Invent a causal story ("probably my jobs saturated the quota") without tracing it. |
| **4. Probe** | Run a fresh, cheap probe that discriminates between the enumerated causes. | Restart / delete / reconfigure before the probe confirms which cause is real. |
| **5. Report** | "*X happened* (verbatim); cause not yet verified; checking `<source>`." | "*X happened because Y*, so I'll do Z." |

**Never relay a subagent's diagnostic inference as fact.** If a dispatched agent reports "saturated-window signature," the correct upstream report is "hit a 429 — cause unverified" plus a verification step. Re-stating its guess as established truth is confabulation by proxy.

## Why

Codes that pattern-match to a known failure are the highest-frequency confabulation trap: they *feel* self-explanatory, so the model skips straight to a fix aimed at the wrong cause — and a signal that looks like a known failure can have a completely different origin. A restart aimed at the wrong cause wastes the operator's time and can make things worse (restarting through a quota cap, deleting through a permission error). The discipline is cheap; the misdiagnosis is not.

*Receipt: a session hit a 429 and asserted "the periodic usage window is saturated," attaching a causal story that blamed its own background jobs — both inferred from a subagent's guess, neither checked. The window was actually at zero percent, freshly reset. The code was read as its own explanation. It never is.*

## How to apply

- Treat *every* non-zero exit, 4xx/5xx, timeout, auth failure, or unexpected count as "cause unverified until probed."
- Before any state-changing remedy (restart, delete, config edit), confirm the evidence supports *that specific* action against *that specific* cause.
- Cross-reference the smell-checklist: a hard failure narrated as "deferred" or a count that doesn't reconcile is an error in disguise — triage it the same way.
