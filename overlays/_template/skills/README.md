# overlays/<name>/skills/

Project-ONLY skills that don't belong in portable `core/` (each as `<skill-name>/SKILL.md`,
same shape as a core skill). Copied to `.claude/skills/` alongside core skills on install.
Most projects have none — prefer generalizing a skill into `core/` and adding a
`skill-bindings/<skill>.md` for the project concretes. This `README.md` is a placeholder the
installer skips.
