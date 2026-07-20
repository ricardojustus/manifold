# Worked decomposition — a heading-level line hides 5 clauses

Read this when calibrating clause granularity in step 1 of `spec-adherence`.

A spec paragraph:

> *"§4.2 On ingest, the writer MUST validate the payload before the transaction opens, MUST reject
> any record whose `source_id` is unknown, and MUST write exactly one ledger row per accepted
> record. On a duplicate `source_id` it returns the existing row without a new write. Every write
> path spreads a fresh record."*

decomposes to five independently-falsifiable clauses:

1. `validate(payload)` runs **before** the transaction opens — *invariant* (ordering; verify where the await/BEGIN sits).
2. unknown `source_id` → reject — *feature*.
3. exactly one ledger row per accepted record — *feature* (assert the count, not just "a row").
4. duplicate `source_id` → return existing row, **no new write** — *feature* (the no-write half is separately falsifiable).
5. every write path returns a freshly-spread record — *invariant* (enumerate ALL return paths, not one).

A single checklist line "§4.2 ingest validation" would have collapsed all five and hidden whichever
one the code missed.
