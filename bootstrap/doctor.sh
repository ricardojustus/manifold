#!/usr/bin/env bash
#
# doctor.sh — verify a Manifold install and lint its structure.
#
#   doctor.sh <target-repo> [--harness <harness-repo-path>] [--overlay]
#
# Per manifest file, prints exactly one line:
#   OK <path>                  installed matches manifest (and, with --harness, the source)
#   FLAG MISSING <path>        manifest file no longer present in target        (blocking)
#   FLAG BAD-RECORD <path>     manifest record missing required fields          (blocking)
#   FLAG BROKEN-LINK <path>    mode:link but the symlink target doesn't resolve (blocking)
#   FLAG LINK-RETARGETED <path> (with --harness) link points outside the harness (warn)
#   FLAG LOCAL-CHANGE <path>   installed differs from manifest; source unchanged (info)
#   FLAG STALE <path>          (with --harness) installed==manifest but source moved on (info)
#   FLAG CONVERGED <path>      (with --harness) installed matches CURRENT source but not the
#                              manifest — a hand-synced copy; re-install to refresh the
#                              manifest (info)
#   FLAG DIVERGED <path>       (with --harness) installed matches neither manifest nor
#                              current source — local edit + upstream movement (warn)
#
# OVERLAY CHECK (needs --harness; runs at the end of the default pass, or alone with
# --overlay). Compares the install's overlay against the harness's current core:
#   OK SLOT <name>             scaffold slot with a claude-slots/<name>.md (empty = filled)
#   FLAG UNFILLED-SLOT <name>  scaffold slot the overlay has no file for      (blocking)
#   FLAG ORPHAN-SLOT <file>    overlay slot file no scaffold placeholder reads (info)
#   FLAG ORPHAN-BINDING <skill> binding for a skill no longer in core          (warn)
#   OK GENERATION overlay <o> core <c>     overlay generation equal to or ahead of core
#   FLAG GENERATION overlay <o> core <c>   overlay generation behind core/GENERATION (blocking)
#
# Then lints installed skills (frontmatter name+description, name==dirname, description
# and body length WARNs), scans for unfilled {{HARNESS:...}} slots (blocking, except the
# migration draft dir .claude/migration-draft/, which mirrors the overlay's own tokens), lints for
# core/ source-tree paths in installed .md (informational), checks that .claude/harness/
# exists (blocking), reports module/capability status (informational), and WARNs on unfinished
# onboarding and on companion tools an install expects but the machine lacks.
#
# An INFO line reports a check that could not run (e.g. the `claude` CLI erroring out on a
# companion lookup); like WARN it never fails.
#
# Exit 0 iff no blocking issue. LOCAL-CHANGE, STALE, CONVERGED, INFO, and WARN never fail.
# macOS bash-3.2 safe.
set -euo pipefail

usage() { echo "usage: doctor.sh <target-repo> [--harness <harness-repo-path>] [--overlay]" >&2; }

TARGET=""
HARNESS=""
OVERLAY_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --harness) HARNESS="${2:-}"; shift 2 ;;
    --overlay) OVERLAY_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "error: unknown option: $1" >&2; usage; exit 2 ;;
    *)         if [ -z "$TARGET" ]; then TARGET="$1"; shift
               else echo "error: unexpected argument: $1" >&2; usage; exit 2; fi ;;
  esac
done
[ -n "$TARGET" ] || { usage; exit 2; }
[ -d "$TARGET" ] || { echo "error: target is not a directory: $TARGET" >&2; exit 2; }
TARGET="$(cd "$TARGET" && pwd)"
MANIFEST="$TARGET/.claude/manifold-manifest.yaml"
[ -f "$MANIFEST" ] || { echo "error: no manifest at $MANIFEST — is the harness installed?" >&2; exit 2; }
[ -z "$HARNESS" ] || HARNESS="$(cd "$HARNESS" && pwd)"
if [ "$OVERLAY_ONLY" = 1 ] && [ -z "$HARNESS" ]; then
  echo "error: --overlay needs --harness <harness-repo-path> (the overlay is checked against that core)" >&2; usage; exit 2
fi

sha256_cmd() { if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$@"; else sha256sum "$@"; fi; }
sha256_of() { sha256_cmd "$1" | awk '{print $1}'; }

# --- manifest header fields ---
hdr_key() { sed -n "s/^$1:[[:space:]]*//p" "$MANIFEST" | head -1; }
MF_MODE="$(hdr_key mode)"
MF_PROFILE="$(hdr_key profile)"
MF_MODULES="$(hdr_key modules)"
ARTIFACT_ROOT="$(hdr_key artifact_root)"

# Resolve the overlay this install was built from, the same way install.sh did: a bare name
# lives under the harness's overlays/, a path is an external overlay dir. Needs --harness for
# the bare-name form. Used by the artifact_root fallback below and by the overlay check.
OVERLAY_REF="$(hdr_key overlay)"
OVERLAY_DIR=""; OVL_MANIFEST=""
if [ -n "$OVERLAY_REF" ]; then
  case "$OVERLAY_REF" in
    */*) OVERLAY_DIR="$OVERLAY_REF" ;;                                   # external overlay path
    *)   [ -n "$HARNESS" ] && OVERLAY_DIR="$HARNESS/overlays/$OVERLAY_REF" ;;  # bare name
  esac
  [ -n "$OVERLAY_DIR" ] && OVL_MANIFEST="$OVERLAY_DIR/manifest.yaml"
fi

# Older manifests predate the artifact_root header — fall back to resolving it from the
# overlay manifest (the same file install.sh read), the pre-recipe behavior.
if [ -z "$ARTIFACT_ROOT" ] && [ -n "$HARNESS" ]; then
  if [ -n "$OVL_MANIFEST" ] && [ -f "$OVL_MANIFEST" ]; then
    ARTIFACT_ROOT="$(sed -n 's/^artifact_root:[[:space:]]*//p' "$OVL_MANIFEST" | head -1)"
    ARTIFACT_ROOT="${ARTIFACT_ROOT%%#*}"
    ARTIFACT_ROOT="$(printf '%s' "$ARTIFACT_ROOT" | sed -e 's/[[:space:]]*$//')"
    ARTIFACT_ROOT="${ARTIFACT_ROOT%\"}"; ARTIFACT_ROOT="${ARTIFACT_ROOT#\"}"
    ARTIFACT_ROOT="${ARTIFACT_ROOT%\'}"; ARTIFACT_ROOT="${ARTIFACT_ROOT#\'}"
  fi
fi

# Resolve a manifest `source:`/`binding:` ref to an absolute path: absolute refs (external
# overlays) are used as-is; relative refs resolve under --harness.
resolve_src() { # <ref> -> abs path or "" when unresolvable
  local ref="$1"
  [ -n "$ref" ] || { echo ""; return 0; }
  case "$ref" in
    /*) echo "$ref" ;;
    *)  if [ -n "$HARNESS" ]; then echo "$HARNESS/$ref"; else echo ""; fi ;;
  esac
}

# Rebuild the EXPECTED installed content of a record exactly the way install.sh stages it:
# source file, plus the appended "## Project bindings" section when a binding is recorded,
# plus the <artifact-root> substitution (which normalizes to exactly one trailing newline,
# matching install.sh's printf '%s\n' rewrite). Prints the sha256 of the expected content.
BINDING_SECTION=$'\n\n## Project bindings\n\n'
expected_hash() { # <abs-source> <abs-binding-or-empty>
  local src="$1" bind="${2:-}" tmp body
  tmp="$(mktemp "${TMPDIR:-/tmp}/manifold-doctor.XXXXXX")"
  cp "$src" "$tmp"
  if [ -n "$bind" ] && [ -f "$bind" ]; then
    printf '%s' "$BINDING_SECTION" >> "$tmp"
    cat "$bind" >> "$tmp"
  fi
  if [ -n "$ARTIFACT_ROOT" ] && grep -Iq '<artifact-root>' "$tmp" 2>/dev/null; then
    body="$(cat "$tmp")"
    printf '%s\n' "${body//"<artifact-root>"/$ARTIFACT_ROOT}" > "$tmp"
  fi
  sha256_of "$tmp"
  rm -f "$tmp"
}

FAILS=0   # MISSING + BAD-RECORD + BROKEN-LINK + unfilled-slot + missing harness dir
WARNS=0
RECORD_COUNT=0

# --- overlay check (needs --harness): the overlay's SHAPE against the harness's current core.
# This is the guard that catches an overlay left behind by a core change — a slot the scaffold
# gained and the overlay never filled, a slot file nothing reads any more, a binding for a
# skill core retired, and the generation stamp itself. Structure only; no hashes.
# Absent/empty -> generation 1 (pre-generation harnesses/overlays). A value that is PRESENT
# but not a positive integer is a corrupt record, not an absent one: fail closed (return 2).
gen_or_1() { case "${1:-}" in '') echo 1 ;; *[!0-9]*|0*) return 2 ;; *) echo "$1" ;; esac; }
overlay_check() {
  local scaffold="$HARNESS/core/CLAUDE.scaffold.md" slot sf skill core_gen ovl_gen core_gen_raw ovl_gen_raw
  echo "--- overlay ---"
  if [ -z "$OVERLAY_REF" ]; then
    echo "INFO OVERLAY-NONE — manifest records no overlay (bootstrap install); nothing to check"; return 0
  fi
  if [ ! -d "$OVERLAY_DIR" ]; then
    echo "FLAG OVERLAY-MISSING $OVERLAY_REF (recorded overlay dir not found)"; FAILS=$((FAILS+1)); return 0
  fi
  if [ ! -f "$scaffold" ]; then
    echo "INFO SCAFFOLD-MISSING core/CLAUDE.scaffold.md not found under $HARNESS; slot check not run"
  else
    # every {{HARNESS:slot}} the scaffold declares must have a claude-slots/<slot>.md
    while IFS= read -r slot; do
      [ -n "$slot" ] || continue
      if [ -f "$OVERLAY_DIR/claude-slots/$slot.md" ]; then echo "OK SLOT $slot"
      else echo "FLAG UNFILLED-SLOT $slot"; FAILS=$((FAILS+1)); fi
    done < <(grep -o '{{HARNESS:[A-Za-z0-9_]*}}' "$scaffold" 2>/dev/null | sed -e 's/^{{HARNESS://' -e 's/}}$//' | sort -u)
    # ...and every slot file must have a placeholder that reads it (info: harmless, but dead)
    if [ -d "$OVERLAY_DIR/claude-slots" ]; then
      for sf in "$OVERLAY_DIR/claude-slots"/*.md; do
        [ -f "$sf" ] || continue
        slot="$(basename "$sf" .md)"
        [ "$slot" = "README" ] && continue
        grep -q "{{HARNESS:$slot}}" "$scaffold" 2>/dev/null || echo "FLAG ORPHAN-SLOT $slot.md"
      done
    fi
  fi
  # a skill-binding whose core skill is gone appends to nothing — it is silently dead weight
  if [ -d "$OVERLAY_DIR/skill-bindings" ]; then
    for sf in "$OVERLAY_DIR/skill-bindings"/*.md; do
      [ -f "$sf" ] || continue
      skill="$(basename "$sf" .md)"
      [ "$skill" = "README" ] && continue
      if [ ! -d "$HARNESS/core/skills/$skill" ]; then
        echo "FLAG ORPHAN-BINDING $skill"; WARNS=$((WARNS+1))
      fi
    done
  fi
  core_gen_raw=""
  [ -f "$HARNESS/core/GENERATION" ] && core_gen_raw="$(head -1 "$HARNESS/core/GENERATION" | tr -d '[:space:]')"
  ovl_gen_raw=""
  [ -f "$OVL_MANIFEST" ] && ovl_gen_raw="$(sed -n 's/^core_generation:[[:space:]]*//p' "$OVL_MANIFEST" | head -1 | sed -e 's/#.*//' -e 's/[[:space:]]*$//')"
  if ! core_gen="$(gen_or_1 "$core_gen_raw")"; then
    echo "FLAG GENERATION-MALFORMED core/GENERATION '$core_gen_raw' (expected a positive integer)"; FAILS=$((FAILS+1)); return 0
  fi
  if ! ovl_gen="$(gen_or_1 "$ovl_gen_raw")"; then
    echo "FLAG GENERATION-MALFORMED $OVERLAY_REF core_generation '$ovl_gen_raw' (expected a positive integer)"; FAILS=$((FAILS+1)); return 0
  fi
  if [ "$ovl_gen" -lt "$core_gen" ]; then
    echo "FLAG GENERATION overlay $ovl_gen core $core_gen"; FAILS=$((FAILS+1))
  else
    echo "OK GENERATION overlay $ovl_gen core $core_gen"
  fi
}

# --overlay is a standalone mode: the overlay block and its verdict, nothing else.
if [ "$OVERLAY_ONLY" = 1 ]; then
  overlay_check
  echo "---"
  if [ "$FAILS" -gt 0 ]; then echo "doctor: FAIL — $FAILS blocking issue(s), $WARNS warning(s)"; exit 1; fi
  echo "doctor: PASS — 0 blocking issue(s), $WARNS warning(s)"
  exit 0
fi

# --- per-file manifest verification (state machine over the manifest) ---
P=""; S=""; SRC=""; M=""; SRCH=""; BREF=""; BH=""
check_record() {
  [ -n "$P" ] || return 0
  RECORD_COUNT=$((RECORD_COUNT+1))
  local installed="$TARGET/$P" ih eh srcabs bindabs
  if [ -z "$S" ] || [ -z "$SRC" ] || [ -z "$M" ]; then
    echo "FLAG BAD-RECORD $P (missing sha256/source/mode field)"; FAILS=$((FAILS+1)); return 0
  fi
  if [ ! -e "$installed" ] && [ ! -L "$installed" ]; then
    echo "FLAG MISSING $P"; FAILS=$((FAILS+1)); return 0
  fi
  # linked files live-track their harness source: verify the LINK itself instead of hashes —
  # a dangling link is broken (blocking); a link pointing outside the harness was retargeted.
  if [ "$M" = "link" ]; then
    if [ -L "$installed" ]; then
      if [ ! -e "$installed" ]; then
        echo "FLAG BROKEN-LINK $P"; FAILS=$((FAILS+1)); return 0
      fi
      if [ -n "$HARNESS" ]; then
        local ltarget; ltarget="$(readlink "$installed")"
        case "$ltarget" in
          "$HARNESS"/*) : ;;
          *) echo "FLAG LINK-RETARGETED $P -> $ltarget"; WARNS=$((WARNS+1)); return 0 ;;
        esac
      fi
      echo "OK $P"; return 0
    fi
    # recorded as link but a regular file sits there now — treat as a local change
    echo "FLAG LOCAL-CHANGE $P (recorded mode:link, found regular file)"; return 0
  fi
  ih="$(sha256_of "$installed")"
  # Without --harness we can only compare against the manifest.
  if [ -z "$HARNESS" ] || [ "$SRC" = "assembled" ] || [ "$SRC" = "generated" ]; then
    if [ "$ih" = "$S" ]; then echo "OK $P"; else echo "FLAG LOCAL-CHANGE $P"; fi
    return 0
  fi
  srcabs="$(resolve_src "$SRC")"
  bindabs="$(resolve_src "$BREF")"
  if [ -z "$srcabs" ] || [ ! -f "$srcabs" ]; then
    # source ref no longer resolvable — the harness retired or moved it
    if [ "$ih" = "$S" ]; then echo "FLAG STALE $P (source gone: $SRC)"; else echo "FLAG DIVERGED $P (source gone: $SRC)"; WARNS=$((WARNS+1)); fi
    return 0
  fi
  eh="$(expected_hash "$srcabs" "$bindabs")"
  if [ "$ih" = "$S" ] && [ "$eh" = "$S" ]; then echo "OK $P"; return 0; fi
  if [ "$ih" = "$S" ] && [ "$eh" != "$S" ]; then echo "FLAG STALE $P"; return 0; fi
  if [ "$ih" = "$eh" ]; then echo "FLAG CONVERGED $P (hand-synced to current source; re-install refreshes the manifest)"; return 0; fi
  if [ "$eh" = "$S" ]; then echo "FLAG LOCAL-CHANGE $P"; return 0; fi
  echo "FLAG DIVERGED $P (local edit + upstream movement)"; WARNS=$((WARNS+1))
}
while IFS= read -r line; do
  case "$line" in
    "  - path: "*)            check_record; P="${line#  - path: }"; S=""; SRC=""; M=""; SRCH=""; BREF=""; BH="" ;;
    "    sha256: "*)          S="${line#    sha256: }" ;;
    "    source: "*)          SRC="${line#    source: }" ;;
    "    mode: "*)            M="${line#    mode: }" ;;
    "    source_sha256: "*)   SRCH="${line#    source_sha256: }" ;;
    "    binding: "*)         BREF="${line#    binding: }" ;;
    "    binding_sha256: "*)  BH="${line#    binding_sha256: }" ;;
  esac
done < "$MANIFEST"
check_record

# --- manifest sanity: an empty or truncated manifest must not read as a clean pass ---
if [ "$RECORD_COUNT" -eq 0 ]; then
  echo "FLAG BAD-RECORD (manifest contains zero file records — truncated or corrupt)"; FAILS=$((FAILS+1))
fi

# --- structural lint over installed skills ---
SKILLS_DIR="$TARGET/.claude/skills"
if [ -d "$SKILLS_DIR" ]; then
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    name_dir="$(basename "$d")"
    sk="${d}SKILL.md"
    if [ ! -f "$sk" ]; then echo "FLAG MISSING .claude/skills/$name_dir/SKILL.md"; FAILS=$((FAILS+1)); continue; fi
    fm="$(awk 'NR==1 && /^---/ {f=1; next} f && /^---/ {exit} f {print}' "$sk")"
    # sed -n never exits nonzero on no-match — a missing name must produce FLAG NO-NAME,
    # not kill the script under set -e (grep in a pipeline here did exactly that).
    fname="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
    # Description may be an inline scalar OR a YAML block scalar (description: >- / | ...), whose
    # value is the indented continuation lines. Reading only the `description:` line counts a
    # block scalar as 1 word (">-"), making the length lint vacuous — so gather the block body.
    fdesc="$(printf '%s\n' "$fm" | awk '
      BEGIN { blk=0; d="" }
      blk==1 {
        if ($0 ~ /^[[:space:]]+[^[:space:]]/) { l=$0; sub(/^[[:space:]]+/,"",l); d=(d==""?l:d" "l); next }
        else { blk=2 }
      }
      blk==0 && /^description:[[:space:]]*/ {
        v=$0; sub(/^description:[[:space:]]*/,"",v)
        if (v ~ /^[>|][+-]?[0-9]*[[:space:]]*$/) { blk=1; next }   # block-scalar indicator: body follows
        else { d=v; blk=2 }                                        # inline value
      }
      END { print d }
    ')"
    if [ -z "$fname" ]; then echo "FLAG NO-NAME .claude/skills/$name_dir"; WARNS=$((WARNS+1)); fi
    if [ -z "$fdesc" ]; then echo "FLAG NO-DESCRIPTION .claude/skills/$name_dir"; WARNS=$((WARNS+1)); fi
    if [ -n "$fname" ] && [ "$fname" != "$name_dir" ]; then
      echo "FLAG NAME-DIR-MISMATCH .claude/skills/$name_dir (name: $fname)"; WARNS=$((WARNS+1))
    fi
    if [ -n "$fdesc" ]; then
      words="$(printf '%s\n' "$fdesc" | wc -w | tr -d ' ')"
      if [ "$words" -gt 150 ]; then echo "WARN DESCRIPTION-LONG .claude/skills/$name_dir ($words words)"; WARNS=$((WARNS+1)); fi
    fi
    lines="$(wc -l < "$sk" | tr -d ' ')"
    if [ "$lines" -gt 500 ]; then echo "WARN SKILL-LONG .claude/skills/$name_dir ($lines lines)"; WARNS=$((WARNS+1)); fi
  done
fi

# --- unfilled-slot scan over installed files ---
scan_hit() { # <file-or-dir>
  grep -RIl --exclude-dir=migration-draft '{{HARNESS:' "$1" 2>/dev/null || true
}
if [ -d "$TARGET/.claude" ]; then
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    echo "FLAG UNFILLED-SLOT ${hit#"$TARGET"/}"; FAILS=$((FAILS+1))
  done < <(scan_hit "$TARGET/.claude")
fi
if [ -f "$TARGET/CLAUDE.harness.md" ] && grep -Iq '{{HARNESS:' "$TARGET/CLAUDE.harness.md" 2>/dev/null; then
  echo "FLAG UNFILLED-SLOT CLAUDE.harness.md"; FAILS=$((FAILS+1))
fi

# --- installed-layout check ---
if [ ! -d "$TARGET/.claude/harness" ]; then
  echo "FLAG MISSING .claude/harness/"; FAILS=$((FAILS+1))
fi

# --- source-tree path lint (informational) ---
# An installed .md must not point a reader at a core/ source path (core/METHODOLOGY.md,
# core/principles/, core/templates/, ...) — those don't exist in a target; the installed
# locations are .claude/harness/ and .claude/harness-templates/. Non-blocking, like STALE.
# FIELD_GUIDE.md is exempt: it is the repo-orientation narrative that describes the harness
# SOURCE layout by design, not a skill pointing at its own dependency.
# The pinned leak set: reader-facing source paths whose installed home differs. NOT
# core/skills/ (the bindings' HTML provenance comments name their source skill by design).
SRC_PATH_RE='core/(METHODOLOGY\.md|ENFORCEMENT\.md|principles/|case-law/|templates/)'
lint_source_paths() { # <file>
  case "$1" in */FIELD_GUIDE.md) return 0 ;; esac
  if grep -IEq "$SRC_PATH_RE" "$1" 2>/dev/null; then
    echo "FLAG SOURCE-PATH ${1#"$TARGET"/}"
  fi
  return 0
}
if [ -d "$TARGET/.claude" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    lint_source_paths "$f"
  done < <(find "$TARGET/.claude" -type f -name '*.md' 2>/dev/null)
fi
if [ -f "$TARGET/CLAUDE.harness.md" ]; then lint_source_paths "$TARGET/CLAUDE.harness.md"; fi

# --- module / capability report (informational) ---
# Modules: which optional modules this install carries (from the manifest header).
# Capabilities: a skill that references an .claude/harness-scripts/ helper that is not
# installed is DEGRADED (its binding names a script the target lacks); audit-cycle with no
# appended Project bindings runs in its documented solo/degraded fallback.
echo "--- capabilities ---"
echo "profile: ${MF_PROFILE:-unrecorded} (modules: ${MF_MODULES:-unrecorded})"
ALL_MODULES="inter-session multi-agent"
module_skill_dirs() { case "$1" in inter-session) echo "inter-session" ;; multi-agent) echo "parallel-workstreams merge-and-cleanup" ;; esac }
for m in $ALL_MODULES; do
  present=1
  for sd in $(module_skill_dirs "$m"); do
    [ -d "$SKILLS_DIR/$sd" ] || present=0
  done
  if [ "$present" = 1 ]; then echo "module $m: READY"; else echo "module $m: UNAVAILABLE (not installed — enable via --modules $m)"; fi
done
# atlas owns no skills, so it is reported separately: the loop above keys on skill dirs and
# would call it READY unconditionally. Its state is the manifest token plus the one artifact
# that actually turns the layer on — the repo's own orientation file.
case " $MF_MODULES " in
  *" atlas "*)
    if [ -f "$TARGET/atlas/orientation.md" ]; then
      echo "module atlas: READY"
    else
      echo "module atlas: PENDING-ONBOARDING (author atlas/orientation.md — template: .claude/harness-templates/atlas/orientation.md)"
    fi
    ;;
esac
# statusline owns no skills either, and its files alone are not the whole story: the script
# only renders once settings.json points at it, which no installer can do.
case " $MF_MODULES " in
  *" statusline "*)
    if [ ! -f "$TARGET/.claude/statusline/statusline.sh" ]; then
      echo "module statusline: UNAVAILABLE (recorded but not installed — re-run with --modules statusline)"
    elif grep -q '"statusLine"' "$TARGET/.claude/settings.json" 2>/dev/null ||
         grep -q '"statusLine"' "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json" 2>/dev/null; then
      echo "module statusline: READY"
    else
      echo "module statusline: PENDING-WIRING (add statusLine to settings.json — see .claude/statusline/README.md)"
    fi
    ;;
esac
# Orientation cap: detection only, never blocking — the session that pushed the file over
# brings it back under in the same arc. Keyed on the artifact alone (a repo carrying an
# orientation file has the layer on, whatever the manifest records).
if [ -f "$TARGET/atlas/orientation.md" ]; then
  olines="$(wc -l < "$TARGET/atlas/orientation.md" | tr -d ' ')"
  if [ "$olines" -gt 150 ]; then echo "WARN ORIENTATION-LONG atlas/orientation.md ($olines lines)"; WARNS=$((WARNS+1)); fi
fi
if [ -d "$SKILLS_DIR" ]; then
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    sk="${d}SKILL.md"
    [ -f "$sk" ] || continue
    name_dir="$(basename "$d")"
    while IFS= read -r ref; do
      [ -n "$ref" ] || continue
      if [ ! -e "$TARGET/.claude/harness-scripts/$ref" ]; then
        echo "DEGRADED $name_dir: references harness-scripts/$ref which is not installed"; WARNS=$((WARNS+1))
      fi
    done < <(grep -oE 'harness-scripts/[A-Za-z0-9._-]+\.(sh|mjs|py)' "$sk" 2>/dev/null | sed 's#^harness-scripts/##' | sort -u || true)
  done
  if [ -f "$SKILLS_DIR/audit-cycle/SKILL.md" ] && ! grep -q '^## Project bindings' "$SKILLS_DIR/audit-cycle/SKILL.md" 2>/dev/null; then
    echo "INFO audit-cycle: no project binding appended — cross-model lens unbound; runs the documented solo-fallback"
  fi
fi

# --- overlay check, on every doctor run that can resolve the harness ---
if [ -n "$HARNESS" ]; then overlay_check; fi

# --- onboarding + companion warnings (never blocking) ---
# The pending marker means install.sh ran in --bootstrap mode and the interview hasn't
# finished; the companion checks cover the two setup steps humans skip (a plugin an overlay
# binding depends on, and ponytail's default mode, whose native value is `full`).
if [ -f "$TARGET/.claude/manifold-onboarding-pending" ]; then
  echo "WARN ONBOARDING-PENDING — onboarding incomplete; open a session in $TARGET and run /harness-onboarding"; WARNS=$((WARNS+1))
fi
if command -v claude >/dev/null 2>&1; then
  # A failing CLI is not an empty plugin set: without this guard an errored `plugin list` reads as
  # "nothing installed" — a spurious karpathy warning plus a silently skipped ponytail check.
  if ! PLUGINS="$(claude plugin list 2>/dev/null)"; then
    echo "INFO COMPANION-CHECK-SKIPPED — 'claude plugin list' exited nonzero; companion checks not run"
  else
    if grep -RIlq 'karpathy-guidelines' "$TARGET/.claude" 2>/dev/null; then
      case "$PLUGINS" in
        *karpathy*) : ;;
        *) echo "WARN COMPANION-MISSING karpathy-guidelines — an installed skill binding references it; install it (see bootstrap/INSTALL.md)"; WARNS=$((WARNS+1)) ;;
      esac
    fi
    case "$PLUGINS" in
      *ponytail*)
        PT_CFG="$HOME/.config/ponytail/config.json"
        PT_MODE=""
        [ -f "$PT_CFG" ] && PT_MODE="$(sed -n 's/.*"defaultMode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$PT_CFG" | head -1)"
        [ -n "${PONYTAIL_DEFAULT_MODE:-}" ] && PT_MODE="$PONYTAIL_DEFAULT_MODE"
        if [ "$PT_MODE" != "off" ]; then
          echo "WARN PONYTAIL-DEFAULT-ON — ponytail is installed but its default mode is '${PT_MODE:-unset (native default: full)}'; pin it off in $PT_CFG"; WARNS=$((WARNS+1))
        fi
        ;;
    esac
  fi
fi

echo "---"
if [ "$FAILS" -gt 0 ]; then
  echo "doctor: FAIL — $FAILS blocking issue(s), $WARNS warning(s)"
  exit 1
fi
echo "doctor: PASS — 0 blocking issue(s), $WARNS warning(s)"
exit 0
