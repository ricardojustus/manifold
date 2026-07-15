#!/usr/bin/env bash
#
# selftest.sh — prove install.sh + doctor.sh behavior against a generated fixture core.
#
# Builds a throwaway mini-manifold in a mktemp scratch dir (2 dummy skills, one with an
# overlay binding; a scaffold with 2 slots; a good overlay that fills both — one with an
# empty file, which is valid — and a bad overlay that leaves one unfilled), then asserts:
#   1. clean copy install exits 0 and assembles/binds correctly
#   2. manifest hashes match the installed files
#   3. doctor is healthy on a fresh install
#   4. unfilled-slot install fails closed and writes nothing to the target
#   5. doctor detects LOCAL-CHANGE after an installed file is edited
#   6. doctor exits nonzero and reports MISSING after an installed file is deleted
#   7. doctor reports STALE (with --harness) after a core source moves on; an install-time
#      <artifact-root> binding is NOT misread as STALE
#   8. --link install works; binding-bearing skill falls back to copy; doctor is healthy
#   9. external overlay by PATH installs; artifact-root binds; manifest records the abspath
#  10. an overlay whose manifest omits artifact_root fails closed (nothing written)
#  11. source-path lint FLAGs an installed core/ path (informational); FIELD_GUIDE exempt
#  12. doctor block-scalar description-length lint fires
#  13. the real _template FAILS CLOSED on its FILL sentinels; installs with
#      --allow-placeholder-template (the installer-smoke escape hatch)
#  14. re-install PRUNES a file the harness retired (manifest-owned, unmodified)
#  15. re-install ABORTS on a locally-edited managed file; --overwrite-local proceeds
#  16. doctor survives a skill with no frontmatter name (FLAG NO-NAME, no crash)
#  17. --profile base skips module-owned skills; --profile full installs them
#
# case 1 also asserts: FIELD_GUIDE installs into the target; skill-binding scripts install to
# .claude/harness-scripts/ (README skipped); and <artifact-root> is bound from the overlay
# manifest across the constitution + a copied skill body (zero tokens left).
#
# Plain bash asserts. Prints PASS/FAIL per case; exits nonzero if any FAIL.
set -uo pipefail   # NOTE: not -e; assertion failures must be counted, not abort the run

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL="$HERE/install.sh"
DOCTOR="$HERE/doctor.sh"

PASS=0; FAIL=0
ok() { echo "PASS: $1"; PASS=$((PASS+1)); }
no() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
assert() { if eval "$1"; then ok "$2"; else no "$2  [failed cond: $1]"; fi; }

SCRATCH="$(mktemp -d "${TMPDIR:-/tmp}/manifold-selftest.XXXXXX")"
trap 'rm -rf "$SCRATCH"' EXIT

# ---------------------------------------------------------------------------
# build fixture mini-core
# ---------------------------------------------------------------------------
CORE="$SCRATCH/harness"
mkdir -p "$CORE/core/skills/alpha" "$CORE/core/skills/beta" \
         "$CORE/core/principles" "$CORE/core/case-law" "$CORE/core/rules" "$CORE/core/templates" \
         "$CORE/bootstrap" \
         "$CORE/overlays/_selftest/claude-slots" "$CORE/overlays/_selftest/skill-bindings" \
         "$CORE/overlays/_selftest/skill-bindings/scripts" \
         "$CORE/overlays/_selftest/rules" "$CORE/overlays/_selftest/hooks" \
         "$CORE/overlays/_selftest/skills/project-only" \
         "$CORE/core/agents" "$CORE/overlays/_selftest/agent-bindings" "$CORE/overlays/_selftest/agents" \
         "$CORE/overlays/_selftest_bad/claude-slots" \
         "$CORE/overlays/_selftest_noroot/claude-slots"

printf '# Changelog\n\n## v0.0.1-test\n' > "$CORE/CHANGELOG.md"
# FIELD_GUIDE carries a core/ source path on purpose — it is EXEMPT from the source-path lint
printf '# Field Guide (fixture)\nRead me once end-to-end. See core/METHODOLOGY.md.\n' > "$CORE/FIELD_GUIDE.md"

cat > "$CORE/core/CLAUDE.scaffold.md" <<'EOF'
# Constitution (fixture)
Intro line.
{{HARNESS:slot_one}}
Middle line.
{{HARNESS:slot_two}}
Artifacts under <artifact-root>/audits.
End line.
EOF

cat > "$CORE/core/skills/alpha/SKILL.md" <<'EOF'
---
name: alpha
description: Alpha dummy skill for selftest.
---
Alpha body references <artifact-root>/audits.
EOF
cat > "$CORE/core/skills/beta/SKILL.md" <<'EOF'
---
name: beta
description: Beta dummy skill for selftest.
---
Beta body.
EOF
# a MODULE-owned skill (the installer's module map keys on the name `inter-session`):
# installed under --profile full (the fixture default), skipped under --profile base
mkdir -p "$CORE/core/skills/inter-session"
cat > "$CORE/core/skills/inter-session/SKILL.md" <<'EOF'
---
name: inter-session
description: Module-owned dummy skill for the profile selftest.
---
Module skill body.
EOF

printf 'methodology stub\n' > "$CORE/core/METHODOLOGY.md"
printf 'enforcement stub\n'  > "$CORE/core/ENFORCEMENT.md"
printf 'calibration stub\n'  > "$CORE/core/SUCCESSOR_CALIBRATION.md"
printf 'principle one references <artifact-root>/audits.\n' > "$CORE/core/principles/p1.md"  # token: copied, no binding — isolates the artifact-root STALE fix (case 7)
printf 'case one\n'          > "$CORE/core/case-law/c1.md"
printf 'rule one\n'          > "$CORE/core/rules/r1.md"
printf 'template one\n'      > "$CORE/core/templates/t1.md"

# good overlay: fills slot_one; slot_two intentionally EMPTY (a valid fill); alpha binding
printf 'FILLED-ONE\n' > "$CORE/overlays/_selftest/claude-slots/slot_one.md"
: >                     "$CORE/overlays/_selftest/claude-slots/slot_two.md"
printf 'alpha project binding line\n' > "$CORE/overlays/_selftest/skill-bindings/alpha.md"
# skill-binding support script installs to .claude/harness-scripts/; README.md placeholder skipped
printf '#!/usr/bin/env bash\necho watch\n'  > "$CORE/overlays/_selftest/skill-bindings/scripts/watch.sh"
printf '# placeholder — not installed\n'    > "$CORE/overlays/_selftest/skill-bindings/scripts/README.md"

# overlay rules + hooks: a rule + a hook install; the rules README placeholder is SKIPPED but
# the hooks README INSTALLS (it is the operative manual-wiring instruction — dropping it
# stranded fresh installs without their setup doc)
printf 'overlay rule line\n'       > "$CORE/overlays/_selftest/rules/ovr-rule.md"
printf '# rules placeholder — not installed\n' > "$CORE/overlays/_selftest/rules/README.md"
printf '#!/usr/bin/env bash\nexit 0\n' > "$CORE/overlays/_selftest/hooks/ovr-hook.sh"
printf '# hook WIRING instructions — installed\n' > "$CORE/overlays/_selftest/hooks/README.md"

# overlay project-only skill: installs to .claude/skills/; NO binding appended; README skipped
printf -- '---\nname: project-only\ndescription: A project-only overlay skill.\n---\nProject-only skill body.\n' > "$CORE/overlays/_selftest/skills/project-only/SKILL.md"
printf '# placeholder — not installed\n' > "$CORE/overlays/_selftest/skills/README.md"

# agents: gamma has an overlay agent-binding, delta doesn't; README.md must NOT install;
# overlay-only agent ships complete from overlays/_selftest/agents/
printf -- '---\nname: gamma\ndescription: Gamma dummy agent for selftest.\n---\nGamma agent body.\n' > "$CORE/core/agents/gamma.md"
printf -- '---\nname: delta\ndescription: Delta dummy agent for selftest.\n---\nDelta agent body.\n' > "$CORE/core/agents/delta.md"
printf '# authoring doc — not installed\n' > "$CORE/core/agents/README.md"
printf 'gamma project binding line\n' > "$CORE/overlays/_selftest/agent-bindings/gamma.md"
printf -- '---\nname: ovr-agent\ndescription: Overlay-only agent for selftest.\n---\nOverlay agent body.\n' > "$CORE/overlays/_selftest/agents/ovr-agent.md"

# good overlay manifest: declares artifact_root so <artifact-root> binds on install
cat > "$CORE/overlays/_selftest/manifest.yaml" <<'EOF'
name: _selftest
runtime: claude-code
artifact_root: /fixture/artifact/root
EOF

# bad overlay: fills only slot_one -> slot_two stays unfilled
printf 'FILLED-ONE\n' > "$CORE/overlays/_selftest_bad/claude-slots/slot_one.md"

# noroot overlay: BOTH slots filled (passes the slot scan) but the manifest omits
# artifact_root -> the <artifact-root> substitution can't fill and the install fails closed
printf 'FILLED-ONE\n' > "$CORE/overlays/_selftest_noroot/claude-slots/slot_one.md"
: >                     "$CORE/overlays/_selftest_noroot/claude-slots/slot_two.md"
cat > "$CORE/overlays/_selftest_noroot/manifest.yaml" <<'EOF'
name: _selftest_noroot
runtime: claude-code
EOF

cp "$INSTALL" "$CORE/bootstrap/install.sh"
cp "$DOCTOR"  "$CORE/bootstrap/doctor.sh"
chmod +x "$CORE/bootstrap/install.sh" "$CORE/bootstrap/doctor.sh"
INST="$CORE/bootstrap/install.sh"
DOC="$CORE/bootstrap/doctor.sh"

# ---------------------------------------------------------------------------
# case 1: clean copy install
# ---------------------------------------------------------------------------
echo "== case 1: clean copy install =="
T1="$SCRATCH/target1"; mkdir -p "$T1"
if "$INST" "$T1" --overlay _selftest >"$SCRATCH/i1.log" 2>&1; then ok "clean install exits 0"; else no "clean install exits 0"; cat "$SCRATCH/i1.log"; fi
assert '[ -f "$T1/CLAUDE.harness.md" ]'                       "CLAUDE.harness.md assembled"
assert '[ -f "$T1/.claude/skills/alpha/SKILL.md" ]'          "alpha skill installed"
assert '[ -f "$T1/.claude/skills/beta/SKILL.md" ]'           "beta skill installed"
assert '[ -f "$T1/.claude/manifold-manifest.yaml" ]'         "manifest written"
assert '[ -f "$T1/.claude/harness/METHODOLOGY.md" ]'         "METHODOLOGY in .claude/harness/"
assert '[ -f "$T1/.claude/harness/SUCCESSOR_CALIBRATION.md" ]' "SUCCESSOR_CALIBRATION in .claude/harness/"
assert '[ -f "$T1/.claude/harness/ENFORCEMENT.md" ]'         "ENFORCEMENT in .claude/harness/"
assert '[ -f "$T1/.claude/harness/principles/p1.md" ]'       "principles copied under harness/"
assert '[ -f "$T1/.claude/harness/case-law/c1.md" ]'         "case-law copied under harness/"
assert '[ -f "$T1/.claude/rules/r1.md" ]'                    "rule installed"
assert '[ -f "$T1/.claude/harness-templates/t1.md" ]'        "template installed"
assert '! grep -q "{{HARNESS:" "$T1/CLAUDE.harness.md"'      "no unfilled placeholder in assembled constitution"
assert 'grep -q "FILLED-ONE" "$T1/CLAUDE.harness.md"'        "slot_one content substituted"
assert 'grep -q "Project bindings" "$T1/.claude/skills/alpha/SKILL.md"'          "alpha binding section appended"
assert 'grep -q "alpha project binding line" "$T1/.claude/skills/alpha/SKILL.md"' "alpha binding content present"
assert '! grep -q "Project bindings" "$T1/.claude/skills/beta/SKILL.md"'         "beta (no binding) left untouched"
assert '[ -f "$T1/.claude/rules/ovr-rule.md" ]'                                  "overlay rule installed to .claude/rules/"
assert '[ -f "$T1/.claude/harness-hooks/ovr-hook.sh" ]'                          "overlay hook installed to .claude/harness-hooks/"
assert '[ -f "$T1/.claude/harness-hooks/README.md" ]'                            "overlay hooks README.md (wiring doc) IS installed"
assert '[ ! -e "$T1/.claude/rules/README.md" ] || grep -q "core/rules" "$T1/.claude/rules/README.md"' "overlay rules README placeholder NOT installed (core rules README may link-install)"
assert 'grep -q "path: .claude/rules/ovr-rule.md" "$T1/.claude/manifold-manifest.yaml"'      "overlay rule recorded in manifest"
assert 'grep -q "path: .claude/harness-hooks/ovr-hook.sh" "$T1/.claude/manifold-manifest.yaml"' "overlay hook recorded in manifest"
# H-2: overlay project-only skills install to .claude/skills/ (README skipped; no binding appended)
assert '[ -f "$T1/.claude/skills/project-only/SKILL.md" ]'                                       "overlay project-only skill installed to .claude/skills/"
assert 'grep -q "path: .claude/skills/project-only/SKILL.md" "$T1/.claude/manifold-manifest.yaml"' "overlay project-only skill recorded in manifest"
assert '! grep -q "Project bindings" "$T1/.claude/skills/project-only/SKILL.md"'                 "overlay project-only skill gets no binding appended"
assert '[ ! -e "$T1/.claude/skills/README.md" ]'                                                 "overlay skills README.md placeholder NOT installed"
# agents tier: core agents install to .claude/agents/, bindings append, README skipped, overlay agents ship
assert '[ -f "$T1/.claude/agents/gamma.md" ]'                                    "core agent gamma installed to .claude/agents/"
assert 'grep -q "Project bindings" "$T1/.claude/agents/gamma.md"'                "gamma agent-binding section appended"
assert 'grep -q "gamma project binding line" "$T1/.claude/agents/gamma.md"'      "gamma agent-binding content present"
assert '! grep -q "Project bindings" "$T1/.claude/agents/delta.md"'              "delta (no binding) left untouched"
assert '[ ! -e "$T1/.claude/agents/README.md" ]'                                 "core agents README.md NOT installed"
assert '[ -f "$T1/.claude/agents/ovr-agent.md" ]'                                "overlay-only agent installed"
assert 'grep -q "path: .claude/agents/gamma.md" "$T1/.claude/manifold-manifest.yaml"' "agent recorded in manifest"
# F2: FIELD_GUIDE installs into the target
assert '[ -f "$T1/.claude/harness/FIELD_GUIDE.md" ]'                             "FIELD_GUIDE installed into .claude/harness/"
assert 'grep -q "path: .claude/harness/FIELD_GUIDE.md" "$T1/.claude/manifold-manifest.yaml"' "FIELD_GUIDE recorded in manifest"
# F6: skill-binding support scripts install to .claude/harness-scripts/ (README skipped)
assert '[ -f "$T1/.claude/harness-scripts/watch.sh" ]'                          "binding script installed to .claude/harness-scripts/"
assert 'grep -q "path: .claude/harness-scripts/watch.sh" "$T1/.claude/manifold-manifest.yaml"' "binding script recorded in manifest"
assert '[ ! -e "$T1/.claude/harness-scripts/README.md" ]'                       "binding scripts README.md placeholder NOT installed"
# F3: <artifact-root> is bound from the overlay manifest across all staged .md, none left
assert 'grep -q "/fixture/artifact/root/audits" "$T1/CLAUDE.harness.md"'         "artifact-root substituted in constitution"
assert '! grep -q "<artifact-root>" "$T1/CLAUDE.harness.md"'                     "no unbound <artifact-root> in constitution"
assert 'grep -q "/fixture/artifact/root/audits" "$T1/.claude/skills/alpha/SKILL.md"' "artifact-root substituted in a copied skill body"
assert '! grep -q "<artifact-root>" "$T1/.claude/skills/alpha/SKILL.md"'         "no unbound <artifact-root> in copied skill body"

# ---------------------------------------------------------------------------
# case 2: manifest correctness (recompute hashes)
# ---------------------------------------------------------------------------
echo "== case 2: manifest hash correctness =="
verify_manifest() { # <target>  -> 0 if all listed files match their recorded hash
  local tgt="$1" p="" s="" bad=0 h
  while IFS= read -r line; do
    case "$line" in
      "  - path: "*)   p="${line#  - path: }" ;;
      "    sha256: "*) s="${line#    sha256: }"
        if [ -n "$p" ]; then
          if [ -e "$tgt/$p" ]; then
            h="$(shasum -a 256 "$tgt/$p" | awk '{print $1}')"
            [ "$h" = "$s" ] || { echo "   hash mismatch: $p" >&2; bad=1; }
          else echo "   listed-but-missing: $p" >&2; bad=1; fi
        fi ;;
    esac
  done < "$tgt/.claude/manifold-manifest.yaml"
  return $bad
}
if verify_manifest "$T1"; then ok "manifest hashes match installed files"; else no "manifest hashes match installed files"; fi

# ---------------------------------------------------------------------------
# case 3: doctor healthy on fresh install
# ---------------------------------------------------------------------------
echo "== case 3: doctor healthy on fresh install =="
if "$DOC" "$T1" >"$SCRATCH/d1.log" 2>&1; then ok "doctor exits 0 on fresh install"; else no "doctor exits 0 on fresh install"; cat "$SCRATCH/d1.log"; fi
assert 'grep -q "^OK " "$SCRATCH/d1.log"'          "doctor prints OK lines"
assert 'grep -q "doctor: PASS" "$SCRATCH/d1.log"'  "doctor prints PASS summary"
assert '! grep -q "^FLAG " "$SCRATCH/d1.log"'      "doctor raises no FLAG on clean install"

# ---------------------------------------------------------------------------
# case 4: unfilled-slot fails closed, writes nothing
# ---------------------------------------------------------------------------
echo "== case 4: unfilled-slot fails closed =="
T2="$SCRATCH/target2"; mkdir -p "$T2"
if "$INST" "$T2" --overlay _selftest_bad >"$SCRATCH/i2.log" 2>&1; then no "unfilled-slot install fails closed"; else ok "unfilled-slot install fails closed"; fi
assert '[ ! -e "$T2/CLAUDE.harness.md" ]'  "no partial install: no CLAUDE.harness.md"
assert '[ ! -d "$T2/.claude" ]'            "no partial install: no .claude/ created"
assert 'grep -q "slot_two" "$SCRATCH/i2.log"' "failure output names the unfilled slot (slot_two)"

# ---------------------------------------------------------------------------
# case 5: doctor detects LOCAL-CHANGE
# ---------------------------------------------------------------------------
echo "== case 5: doctor detects LOCAL-CHANGE =="
printf 'a local edit\n' >> "$T1/.claude/skills/beta/SKILL.md"
"$DOC" "$T1" >"$SCRATCH/d2.log" 2>&1 || true
assert 'grep -q "FLAG LOCAL-CHANGE .claude/skills/beta/SKILL.md" "$SCRATCH/d2.log"' "doctor reports LOCAL-CHANGE on edited file"

# ---------------------------------------------------------------------------
# case 6: doctor detects MISSING and exits nonzero
# ---------------------------------------------------------------------------
echo "== case 6: doctor detects MISSING =="
rm -f "$T1/.claude/rules/r1.md"
if "$DOC" "$T1" >"$SCRATCH/d3.log" 2>&1; then no "doctor exits nonzero when a file is MISSING"; else ok "doctor exits nonzero when a file is MISSING"; fi
assert 'grep -q "FLAG MISSING .claude/rules/r1.md" "$SCRATCH/d3.log"' "doctor reports MISSING for deleted file"

# ---------------------------------------------------------------------------
# case 7: doctor detects STALE with --harness
# ---------------------------------------------------------------------------
echo "== case 7: doctor detects STALE with --harness =="
T3="$SCRATCH/target3"; mkdir -p "$T3"
"$INST" "$T3" --overlay _selftest >/dev/null 2>&1
printf 'UPSTREAM CHANGE\n' >> "$CORE/core/rules/r1.md"      # core source moves on; install unchanged
"$DOC" "$T3" --harness "$CORE" >"$SCRATCH/d4.log" 2>&1 || true
assert 'grep -q "FLAG STALE .claude/rules/r1.md" "$SCRATCH/d4.log"' "doctor reports STALE when harness source moved"
assert 'grep -q "OK .claude/harness/METHODOLOGY.md" "$SCRATCH/d4.log"' "unchanged source still reports OK under --harness"
# a copied file whose <artifact-root> was bound at install time must NOT read as STALE:
# doctor applies the same binding to the source before hashing (source has the raw token).
# p1 is copied with no binding appended, so it isolates the artifact-root substitution.
assert 'grep -q "OK .claude/harness/principles/p1.md" "$SCRATCH/d4.log"'   "artifact-root-bound copy reports OK, not STALE, under --harness"
assert '! grep -q "FLAG STALE .claude/harness/principles/p1.md" "$SCRATCH/d4.log"' "artifact-root-bound copy is not falsely STALE"
printf 'rule one\n' > "$CORE/core/rules/r1.md"             # revert for the link case

# ---------------------------------------------------------------------------
# case 8: --link install + symlink handling
# ---------------------------------------------------------------------------
echo "== case 8: --link install =="
T4="$SCRATCH/target4"; mkdir -p "$T4"
if "$INST" "$T4" --overlay _selftest --link >"$SCRATCH/i4.log" 2>&1; then ok "--link install exits 0"; else no "--link install exits 0"; cat "$SCRATCH/i4.log"; fi
assert '[ -L "$T4/.claude/rules/r1.md" ]'                             "plain file is a symlink in --link mode"
assert '[ -L "$T4/.claude/skills/beta/SKILL.md" ]'                    "no-binding skill is a symlink"
assert '[ -f "$T4/.claude/skills/alpha/SKILL.md" ] && [ ! -L "$T4/.claude/skills/alpha/SKILL.md" ]' "binding-bearing skill falls back to a real copy"
assert 'grep -q "alpha project binding line" "$T4/.claude/skills/alpha/SKILL.md"' "copy-fallback skill still gets its binding"
assert 'grep -q "^mode: link" "$T4/.claude/manifold-manifest.yaml"'   "manifest top-level mode: link"
assert 'grep -A3 "path: .claude/skills/alpha/SKILL.md" "$T4/.claude/manifold-manifest.yaml" | grep -q "mode: copy"' "alpha recorded per-file mode: copy under --link"
assert 'grep -A3 "path: .claude/rules/r1.md" "$T4/.claude/manifold-manifest.yaml" | grep -q "mode: link"' "linked file recorded per-file mode: link"
if "$DOC" "$T4" >"$SCRATCH/d5.log" 2>&1; then ok "doctor healthy on --link install"; else no "doctor healthy on --link install"; cat "$SCRATCH/d5.log"; fi

# ---------------------------------------------------------------------------
# case 9: external overlay by PATH (F1)
# ---------------------------------------------------------------------------
echo "== case 9: external overlay by path =="
EXT="$SCRATCH/ext-overlay"
cp -R "$CORE/overlays/_selftest" "$EXT"
EXT_REAL="$(cd "$EXT" && pwd)"
T5="$SCRATCH/target5"; mkdir -p "$T5"
if "$INST" "$T5" --overlay "$EXT" >"$SCRATCH/i5.log" 2>&1; then ok "external-overlay-by-path install exits 0"; else no "external-overlay-by-path install exits 0"; cat "$SCRATCH/i5.log"; fi
assert '[ -f "$T5/CLAUDE.harness.md" ]'                                    "external overlay: constitution assembled"
assert '[ -f "$T5/.claude/skills/alpha/SKILL.md" ]'                        "external overlay: core skills installed"
assert 'grep -q "/fixture/artifact/root/audits" "$T5/CLAUDE.harness.md"'   "external overlay: artifact-root substituted"
assert 'grep -q "^overlay: $EXT_REAL" "$T5/.claude/manifold-manifest.yaml"' "external overlay: manifest records the absolute path"
if "$DOC" "$T5" >"$SCRATCH/d6.log" 2>&1; then ok "doctor healthy on external-overlay install"; else no "doctor healthy on external-overlay install"; cat "$SCRATCH/d6.log"; fi

# ---------------------------------------------------------------------------
# case 10: missing artifact_root fails closed (F3)
# ---------------------------------------------------------------------------
echo "== case 10: missing artifact_root fails closed =="
T6="$SCRATCH/target6"; mkdir -p "$T6"
if "$INST" "$T6" --overlay _selftest_noroot >"$SCRATCH/i6.log" 2>&1; then no "missing artifact_root install fails closed"; else ok "missing artifact_root install fails closed"; fi
assert '[ ! -e "$T6/CLAUDE.harness.md" ]'                    "no partial install: no CLAUDE.harness.md"
assert '[ ! -d "$T6/.claude" ]'                              "no partial install: no .claude/ created"
assert 'grep -qE "artifact.root" "$SCRATCH/i6.log"'          "failure output names the unbound artifact-root"

# ---------------------------------------------------------------------------
# case 11: source-path lint (F7) — informational FLAG; FIELD_GUIDE exempt
# ---------------------------------------------------------------------------
echo "== case 11: source-path lint =="
T7="$SCRATCH/target7"; mkdir -p "$T7"
"$INST" "$T7" --overlay _selftest >/dev/null 2>&1
printf 'see core/principles/x.md\n' >> "$T7/.claude/skills/beta/SKILL.md"   # inject a real leak
"$DOC" "$T7" >"$SCRATCH/d7.log" 2>&1 || true
assert 'grep -q "FLAG SOURCE-PATH .claude/skills/beta/SKILL.md" "$SCRATCH/d7.log"'    "doctor FLAGs an installed core/ source path"
assert 'grep -q "doctor: PASS" "$SCRATCH/d7.log"'                                     "source-path FLAG is informational (doctor still PASSes)"
assert '! grep -q "FLAG SOURCE-PATH .claude/harness/FIELD_GUIDE.md" "$SCRATCH/d7.log"' "FIELD_GUIDE is exempt from the source-path lint"

# ---------------------------------------------------------------------------
# case 12: doctor block-scalar description-length lint (M-2)
# ---------------------------------------------------------------------------
echo "== case 12: doctor block-scalar description lint =="
T8="$SCRATCH/target8"; mkdir -p "$T8"
"$INST" "$T8" --overlay _selftest >/dev/null 2>&1
# inject a skill whose description is a `>-` block scalar of >150 words. The old lint read
# only the `description:` line, saw ">-", counted 1 word, and never fired. It must now WARN.
mkdir -p "$T8/.claude/skills/longdesc"
{
  echo '---'
  echo 'name: longdesc'
  echo 'description: >-'
  printf '  '; i=0; while [ "$i" -lt 160 ]; do printf 'word '; i=$((i+1)); done; echo
  echo '---'
  echo 'body'
} > "$T8/.claude/skills/longdesc/SKILL.md"
"$DOC" "$T8" >"$SCRATCH/d8.log" 2>&1 || true
assert 'grep -q "WARN DESCRIPTION-LONG .claude/skills/longdesc" "$SCRATCH/d8.log"' "doctor WARNs on a >150-word block-scalar description"
assert 'grep -q "doctor: PASS" "$SCRATCH/d8.log"'                                  "block-scalar length WARN is informational (doctor still PASSes)"

# ---------------------------------------------------------------------------
# case 13: the REAL _template fails closed on FILL sentinels; installs with the flag
# ---------------------------------------------------------------------------
# Uses the real install/doctor + the real overlays/_template (not the fixture core). A raw
# template's slots are `<!-- FILL ... -->` sentinels: substituting them produces a
# syntactically-valid but IDENTITY-LESS constitution — so the install must FAIL CLOSED
# unless --allow-placeholder-template (the installer-smoke escape hatch) is passed.
echo "== case 13: real _template sentinel gate =="
TPL="$SCRATCH/tpl-overlay"
cp -R "$HERE/../overlays/_template" "$TPL"
sed -i.bak 's/^name:.*/name: tpl-overlay/' "$TPL/manifest.yaml" && rm -f "$TPL/manifest.yaml.bak"
T9="$SCRATCH/target9"; mkdir -p "$T9"
if "$INSTALL" "$T9" --overlay "$TPL" >"$SCRATCH/i9a.log" 2>&1; then no "raw _template fails closed on FILL sentinels"; else ok "raw _template fails closed on FILL sentinels"; fi
assert '[ ! -e "$T9/CLAUDE.harness.md" ]'                      "sentinel gate: nothing written"
assert 'grep -q "FILL" "$SCRATCH/i9a.log"'                     "sentinel gate: failure output names the sentinel"
if "$INSTALL" "$T9" --overlay "$TPL" --allow-placeholder-template >"$SCRATCH/i9.log" 2>&1; then ok "_template installs with --allow-placeholder-template"; else no "_template installs with --allow-placeholder-template"; cat "$SCRATCH/i9.log"; fi
assert '[ -f "$T9/CLAUDE.harness.md" ]'                        "real _template: constitution assembled"
assert '! grep -q "<artifact-root>" "$T9/CLAUDE.harness.md"'   "real _template: artifact_root default bound (no unbound token)"
if "$DOCTOR" "$T9" >"$SCRATCH/d9.log" 2>&1; then ok "doctor PASSes on real _template install"; else no "doctor PASSes on real _template install"; cat "$SCRATCH/d9.log"; fi

# ---------------------------------------------------------------------------
# case 14: re-install prunes a retired file
# ---------------------------------------------------------------------------
echo "== case 14: re-install prunes a retired file =="
T10="$SCRATCH/target10"; mkdir -p "$T10"
"$INST" "$T10" --overlay _selftest >/dev/null 2>&1
assert '[ -f "$T10/.claude/skills/beta/SKILL.md" ]' "pre-prune: beta installed"
rm -rf "$CORE/core/skills/beta"                      # the harness retires beta
if "$INST" "$T10" --overlay _selftest >"$SCRATCH/i10.log" 2>&1; then ok "re-install over existing target exits 0"; else no "re-install over existing target exits 0"; cat "$SCRATCH/i10.log"; fi
assert '[ ! -e "$T10/.claude/skills/beta/SKILL.md" ]'          "retired beta pruned from target"
assert 'grep -q "pruned" "$SCRATCH/i10.log"'                   "install output reports the prune"
assert '! grep -q "path: .claude/skills/beta/SKILL.md" "$T10/.claude/manifold-manifest.yaml"' "new manifest no longer lists beta"

# ---------------------------------------------------------------------------
# case 15: re-install aborts on a locally-edited managed file; --overwrite-local proceeds
# ---------------------------------------------------------------------------
echo "== case 15: local-edit conflict abort =="
T11="$SCRATCH/target11"; mkdir -p "$T11"
"$INST" "$T11" --overlay _selftest >/dev/null 2>&1
printf 'LOCAL EDIT LINE\n' >> "$T11/.claude/rules/r1.md"       # local edit in the target
printf 'UPSTREAM V2\n'     >> "$CORE/core/rules/r1.md"         # source moves too
if "$INST" "$T11" --overlay _selftest >"$SCRATCH/i11.log" 2>&1; then no "conflicting re-install aborts"; else ok "conflicting re-install aborts"; fi
assert 'grep -q "LOCAL EDIT: .claude/rules/r1.md" "$SCRATCH/i11.log"' "abort names the conflicted file"
assert 'grep -q "LOCAL EDIT LINE" "$T11/.claude/rules/r1.md"'         "abort left the local edit in place"
if "$INST" "$T11" --overlay _selftest --overwrite-local >"$SCRATCH/i11b.log" 2>&1; then ok "--overwrite-local proceeds"; else no "--overwrite-local proceeds"; cat "$SCRATCH/i11b.log"; fi
assert 'grep -q "UPSTREAM V2" "$T11/.claude/rules/r1.md"'             "--overwrite-local installed the new content"
assert '! grep -q "LOCAL EDIT LINE" "$T11/.claude/rules/r1.md"'       "--overwrite-local discarded the local edit"

# ---------------------------------------------------------------------------
# case 16: doctor survives a skill with no frontmatter name
# ---------------------------------------------------------------------------
echo "== case 16: doctor survives missing frontmatter name =="
T12="$SCRATCH/target12"; mkdir -p "$T12"
"$INST" "$T12" --overlay _selftest >/dev/null 2>&1
mkdir -p "$T12/.claude/skills/noname"
printf -- '---\ndescription: A skill with no name.\n---\nbody\n' > "$T12/.claude/skills/noname/SKILL.md"
"$DOC" "$T12" >"$SCRATCH/d10.log" 2>&1 || true
assert 'grep -q "FLAG NO-NAME .claude/skills/noname" "$SCRATCH/d10.log"' "doctor FLAGs the missing name"
assert 'grep -q "doctor: " "$SCRATCH/d10.log"'                           "doctor reaches its summary line (no mid-script death)"

# ---------------------------------------------------------------------------
# case 17: profiles — base skips module skills, full installs them
# ---------------------------------------------------------------------------
echo "== case 17: profile base vs full =="
T13="$SCRATCH/target13"; mkdir -p "$T13"
"$INST" "$T13" --overlay _selftest --profile base >"$SCRATCH/i13.log" 2>&1 || cat "$SCRATCH/i13.log"
assert '[ -f "$T13/.claude/skills/alpha/SKILL.md" ]'          "base: core skill installed"
assert '[ ! -e "$T13/.claude/skills/inter-session/SKILL.md" ]' "base: module skill skipped"
assert 'grep -q "^profile: base" "$T13/.claude/manifold-manifest.yaml"' "base: manifest records the profile"
T14="$SCRATCH/target14"; mkdir -p "$T14"
"$INST" "$T14" --overlay _selftest --profile full >"$SCRATCH/i14.log" 2>&1 || cat "$SCRATCH/i14.log"
assert '[ -f "$T14/.claude/skills/inter-session/SKILL.md" ]'  "full: module skill installed"
assert 'grep -q "^modules: .*inter-session" "$T14/.claude/manifold-manifest.yaml"' "full: manifest records the modules"

# ---------------------------------------------------------------------------
echo "======================================================"
echo "selftest: $PASS passed, $FAIL failed"
if [ "$FAIL" -ne 0 ]; then echo "SELFTEST FAILED"; exit 1; fi
echo "SELFTEST PASSED"
exit 0
