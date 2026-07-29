# Shared-repo commits — path-scope the stage; scoping does not solve same-file races

In any repo that multiple live sessions write concurrently (a shared vault, a co-edited docs repo):

1. **Never blanket-stage.** No `git add .` / `git add -A` / `git commit -a` — stage exactly the
   paths YOU edited, every commit. A blanket add sweeps a sibling session's mid-write files into
   your commit.
2. **Path-scoping does NOT protect a concurrently-edited SAME file.** `git add <path>` stages
   whatever is in the working tree at that instant — a peer's edit to the same file rides your
   commit even though you scoped it. For a file N sessions edit concurrently: **serialize the
   edits** (coordinate via the operator or the project's inter-session channel), or **accept the
   misattribution explicitly** in the commit message — never claim scoping solved it.

Litigated 2026-07-26 — inherit; the incident receipt is diarized in the memory store.
