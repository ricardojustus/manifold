# Vendored provenance — prototype

- **Upstream**: https://github.com/mattpocock/skills (`skills/engineering/prototype`)
- **Version**: commit `8b36d4fb2635b3c21998dcd8144439c9e5ba7302` (re-adapted 2026-08-05; first
  adapted 2026-07-30 at `2ab958093e83e0ec752e6c1c5932da465bf23e0c`)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of the upstream skill dir (SKILL.md + LOGIC.md + UI.md +
  `agents/openai.yaml` interface stub; no scripts), 2026-07-30; re-read of the rewritten upstream
  `SKILL.md` + `LOGIC.md` end-to-end at the new pin, 2026-08-05. The adopting project keeps the
  analysis record in its own evidence store.
- **Posture**: adapted top file; references adapted where the harness methodology demanded
  (delta 3) — OUR copy under OUR review; upstream changes do not flow in automatically.

## Adaptation delta vs upstream

1. SKILL.md rewritten to this harness's voice: "user" → "operator"; description gains the
   wayfinder-ticket and circular-design-argument triggers and the answer-is-the-deliverable
   framing; rules renumbered with two additions — rule 6 (operator-drives, upstream's "Hand it
   over" steps promoted to a rule) and the visual-delivery clause in rule 7 (deferred to the
   overlay binding).
2. Capture rule (upstream rule 6) rebound from "throwaway branch + context pointer on the
   implementation issue" to the project git contract's scrap-branch mechanics via the binding.
3. `LOGIC.md` and `UI.md` moved to `references/` (harness layout), each with the `SKILL.md` →
   `../SKILL.md` cross-link adjusted, PLUS a behavioral rewrite of upstream's
   code-into-production clauses in BOTH: LOGIC.md's lift-the-module steps and UI.md's capture step
   (6: fold-the-winner / promote-the-variant) + both files' closing anti-patterns (LOGIC's
   worth-keeping wording, UI's promotion wording). The LOGIC locators of that first pass belonged
   to the terminal-app text at pin `2ab9580`; delta 5 carries the current ones.
   Upstream folds validated prototype code into the real codebase; this harness's methodology
   forbids prototype code from shipping, so in both branches the validated DESIGN (state shape,
   transitions, interface, layout) carries forward and the implementation re-enters through the
   normal build gates — prototype code stays on the scrap branch.
4. `agents/openai.yaml` dropped (not this harness's format).
5. **HTML logic demo adopted from upstream's rewrite** at the new pin: `LOGIC.md`'s terminal-app
   scaffold is replaced by a single self-contained shareable HTML file (visible intro, pure logic
   module in one `<script>`, current-state panel, free-play buttons, tabbed guided walkthroughs,
   restrained styling), and the "pick the language" + "one command to run" steps retire with it.
   SKILL.md's logic-branch line, description, and rule 2 ("Trivial to run" — task-runner command
   for UI, double-click file for logic) follow upstream. Delta 3's design-not-code carry-forward
   is preserved through the rewrite: upstream's "lifts into the real module on its own" (step 2
   close) and its step-5 capture mapping are re-stated as the validated DESIGN carrying forward
   through the normal build gates, and the closing anti-pattern forbids shipping the module as
   well as the shell. The purity anti-pattern keeps this copy's word *portable* where upstream
   says *liftable*, for the same reason.
