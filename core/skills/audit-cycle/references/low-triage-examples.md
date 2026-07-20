# Low triage — worked examples (one per bucket)

The triage question, answered. Load when a Low's bucket is genuinely unclear.

- **Waive.** A Low flags that an internal helper returns `undefined` for an input the type
  system already forbids (a guard for an impossible case). Realistic-failure-condition:
  *"no caller can construct that input — the enum is closed."* → `audit-waivers.md` with that
  rationale; never actioned.
- **Backlog-with-trigger.** A Low flags a fixed-size in-memory buffer that's fine at today's
  ~200 items but silently drops entries past ~10k. Answer: *"no failure now; fails when the
  corpus crosses ~10k items."* → `audit-backlog.md`, trigger: *"revisit when item count
  approaches 10k."*
- **Promote.** A Low flags a retry loop with no backoff. Answer: *"the upstream it calls
  already rate-limits us at current volume — the failure condition exists now."* → PROMOTE to
  Medium; blocks lock like any Medium.
