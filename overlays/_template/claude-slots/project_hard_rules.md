<!-- FILL project_hard_rules: project-specific HARD RULES that don't generalize into core
     (agent-spawn vocabulary contracts, naming/codename mandates, routing rules, binding
     operator directives). Each states the rule clean — its receipt (who decided it, when) is
     diarized in the project's memory store, never inlined here; an anonymized worked example
     stays allowed inline.
     Point at any rule file installed via rules/. An empty fill is valid if the project has
     none yet. (The scaffold provides the `## Project Hard Rules` heading.) -->

<!-- Suggested starting content — the onboarding interview offers this verbatim; accept, edit,
     or drop it, then DELETE the placeholder comment above (an install with that comment still
     present fails closed). Hand-filling this template? Do the same by hand. -->

- **Protected branches and directories**: <name them — e.g. `main` and `production`>. Work lands
  through a branch and a review, never a direct commit.
- **Never force-push or rewrite history on a shared branch.** The damage is other people's and
  it is not recoverable from your machine.
- **Dependency updates are assessed, never routine** — read the changelog and known issues,
  present the risk, get a go-ahead, verify after.
