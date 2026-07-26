<!--
  NOT FOR PROJECTS ON A TRACKER: this template is the FILE form of the open-items surface.
  Where the project binding names an issue tracker as the backlog, that tracker replaces this
  file entirely — do not create it, and do not keep a second copy of the backlog here (two
  backlogs means neither is trusted). Everything below applies only to the file form.

  OPEN_ITEMS.md — the live backlog of open threads. Distinct from STATE (current snapshot),
  SESSION_LOG (dated history), and QUESTIONS-FOR-OPERATOR (things needing a human decision).
  An open item is work that's KNOWN and PENDING but not actively in flight. This is a
  BACKLOG (pull surface): sessions GREP it at start for entries naming their lane as owner —
  they never browse it; the operator opens it on request. Every entry NAMES AN OWNER.
  Close items by REMOVING them (git history preserves the text). At ~30 entries the file is
  over cap: each owner sweeps its own entries (close / re-home / drop-as-stale).
-->

# Open items — <project>

_Live backlog. GREP by owner at session start (never browse); the operator opens it on request. Every entry carries an `<!-- owner: X -->` tag. Close = MOVE the entry to `archive/OPEN_ITEMS_ARCHIVE.md` (ALWAYS archive closed entries in the separate file — never leave them here, never rely on git history alone)._

## Open
<!-- Each item: a stable id, a one-line description, and a status/blocker if any.
     Group by area if the list is long. -->
- **OI-NNN** — <description> — **owner: <lane/person>** — <status: unblocked / blocked-on-X / waiting> — <pointer if any>

## Newly unblocked
<!-- Items whose blocker just cleared — surfaced here so the next session picks them up. -->
- **OI-NNN** — <was blocked on X; X is now done> 

## Parked / someday
<!-- Deliberately deferred, with the reason. Not dead — just not now. -->
- <item> — parked because <reason>; revisit when <trigger>
