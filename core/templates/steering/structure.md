<!--
  structure.md — steering document (3 of 3: product / tech / structure).
  Pattern adapted from Pimzino/claude-code-spec-workflow (MIT).

  WHAT THIS IS. A durable, per-project map of WHERE things live and WHERE new things go — the
  file organization, naming patterns, and placement rules a change must follow to land in the
  right place. Loaded once per project; a brief's GIVEN block CITES this so a dispatched agent
  does not have to discover the layout by grep. Keep it a map, not a mirror: name the load-
  bearing directories and the rules, not every file. Delete these comments as you fill each section.
-->

# Structure — <project name>

## Where things live
<!-- The top-level layout: the directories that matter and what each holds. A newcomer should
     be able to find the right area for a change from this alone. Not a full tree — the load-
     bearing folders and their purpose. -->

## Naming patterns
<!-- The conventions for names: files, modules, tests, symbols. Case style (kebab / snake /
     camel), suffixes, test-file placement and naming. What a new file must be called to match. -->

## Where new code goes
<!-- The placement rules: given a new feature / module / test / doc, where does it belong and
     why. The decision a contributor makes most often — encode it so it is not re-argued per
     change. Point at any doc-placement / routing skill the project uses for the finer calls. -->

## Boundaries
<!-- The structural fences: directories or systems that are off-limits or owned elsewhere, and
     where the blast radius of a change is meant to stop. The project-level view of the
     never-touch paths ENFORCEMENT.md invariant #4 declares (prose + permission rules; ownership verified with the surface's owner). -->
