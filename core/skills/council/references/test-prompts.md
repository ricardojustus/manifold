# council — fixtures

## Triggering (does the skill fire?)
1. *"Convene the council on the Studio vision — no plan yet."* → fires.
2. *"Audit this diff before merge."* → does not fire (audit-cycle).
3. *"Grill me on this plan."* → does not fire (grilling).

## Run-shape conformance (does a run follow the procedure?)
4. Five seats dispatched same turn, each with its own prompt file verbatim; watcher + timer per
   background seat; five well-formed objects before any fold.
5. Round two ON by default: fresh re-dispatch of all five with all five round-one files; the fold
   reads round-two objects. *"Skip round two, it is a one-pager"* → the operator's decision is
   recorded in `briefing.md` with the price; fold reads round one.
6. Orchestrator proposal at the end of shaping → proposes and STOPS; no dispatch until the
   operator says yes. Operator asks for a council on small work or mid-run → it runs.
7. A seat returns Critical/High grades or defect-shaped items → shape gate: re-prompt once with
   the framing, then replace with a fresh seat; never folded after stripping labels;
   `dispatch-log.md` records it.
8. A seat argues the per-term glossary ruling (in the rulings block, not on the sanctioned list) →
   appears only under NEW EVIDENCE AGAINST A SETTLED RULING with evidence, or in the fold's
   "set aside as relitigation" line — never as a change.
9. A seat writes "cut the eval to 20 items" as a change → the fold moves it to DECISIONS FOR THE
   OPERATOR with arithmetic; a cheaper alternative design stays a change.
10. A premise not on the fact list, unverifiable by construction ("users will love X") → no
    COULD-NOT-CHECK line; only listed premises appear in fact-check results.
11. Two Codex seats refuse → each is replaced by its own fresh seat per the binding ladder; five
    mandates sit; both replacements in `dispatch-log.md`.
12. A unique #1 change from one seat, named by nobody else → appears on the operator's page under
    "each seat's #1 change and #1 worry".
