# Shared-repo commits — path-list the COMMIT, not just the stage; same-file races still need serializing

In any repo that multiple live sessions write concurrently (a shared vault, a co-edited docs repo):

1. **Never blanket-stage.** No `git add .` / `git add -A` / `git commit -a` — stage exactly the
   paths YOU edited, every commit. A blanket add sweeps a sibling session's mid-write files into
   your commit.
2. **Commit path-listed, never bare.** `git commit -m "..." -- <paths>` — a bare `git commit`
   commits the WHOLE index, so a sibling's staged-uncommitted files ride your commit invisibly;
   the path-listed form commits ONLY the named paths and leaves foreign staged entries untouched
   (native git semantics, verified empirically). An inspection (`git diff --cached`)
   before a bare commit is NOT a substitute — the index can change between the look and the
   commit.
3. **Path-scoping does NOT protect a concurrently-edited SAME file.** `git add <path>` stages
   whatever is in the working tree at that instant — a peer's edit to the same file rides your
   commit even though you scoped it. For a file N sessions edit concurrently: **serialize the
   edits** (coordinate via the operator or the project's inter-session channel), or **accept the
   misattribution explicitly** in the commit message — never claim scoping solved it.

Settled — inherit: incident receipts are diarized in the memory store.
