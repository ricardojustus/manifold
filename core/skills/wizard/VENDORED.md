# Vendored provenance — wizard

- **Upstream**: https://github.com/mattpocock/skills (`skills/engineering/wizard`)
- **Version**: commit `8b36d4fb2635b3c21998dcd8144439c9e5ba7302` (vendored 2026-08-05)
- **License**: MIT (`LICENSE.upstream`, © 2026 Matt Pocock)
- **Vetting**: full end-to-end read of the upstream skill dir (SKILL.md + `template.sh` +
  `agents/openai.yaml` interface stub), 2026-08-05. `template.sh` is the only script this batch
  vendors from the Matt Pocock upstream — read line by line: pure interactive bash (`tput`
  styling, `read` prompts, cross-platform URL open, idempotent `.env` upsert, `gh secret`/`gh
  variable` writes). No raw HTTP client and no eval of captured input; it does open authored URLs
  in the operator's browser and delegates explicit GitHub secret/variable writes to `gh`. The
  adopting project keeps the analysis record in its own evidence store.
- **Posture**: near-verbatim — this copy is OURS; upstream changes do not flow in automatically.

## Adaptation delta vs upstream

1. Voice pass only on `SKILL.md`: "the user" → "the operator" where it means this harness's
   operator (four sites). Upstream's "human" — the person driving the browser, who need not be the
   operator — is left as upstream wrote it. Description, triggers, process, and the template
   contract (never hand-edit the library above the `STAGES` marker; scope → map → author → verify
   statically) are unchanged.
2. `template.sh` is a BYTE-IDENTICAL copy of upstream's — cross-wizard consistency is the point,
   so adaptation happens in the overlay binding, never in the library.
3. `agents/openai.yaml` dropped (not this harness's format).
