#!/usr/bin/env bash
#
# doctor.sh — verify a Manifold install and lint its structure.
#
#   doctor.sh <target-repo> [--harness <harness-repo-path>]
#
# Per manifest file, prints exactly one line:
#   OK <path>                 installed hash == manifest hash
#   FLAG LOCAL-CHANGE <path>  installed hash != manifest hash (sanctioned local edit — informational)
#   FLAG MISSING <path>       manifest file no longer present in target        (blocking)
#   FLAG STALE <path>         (with --harness) installed==manifest but the harness source moved on
#   FLAG SOURCE-PATH <path>   installed .md points at a core/ source-tree path (informational)
#
# Then lints installed skills (frontmatter name+description, name==dirname, description
# and body length WARNs), scans for unfilled {{HARNESS:...}} slots (blocking), lints for
# core/ source-tree paths in installed .md (informational), and checks that .claude/harness/
# exists (blocking).
#
# Exit 0 iff no MISSING and no unfilled-slot. LOCAL-CHANGE, STALE, and WARN never fail.
# macOS bash-3.2 safe.
set -euo pipefail

usage() { echo "usage: doctor.sh <target-repo> [--harness <harness-repo-path>]" >&2; }

TARGET=""
HARNESS=""
while [ $# -gt 0 ]; do
  case "$1" in
    --harness) HARNESS="${2:-}"; shift 2 ;;
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

sha256_of() { shasum -a 256 "$1" | awk '{print $1}'; }

# For the STALE comparison only: a copied core .md may have had its <artifact-root> token
# bound at install time (install.sh), so its recorded hash won't match the raw source hash.
# Resolve the overlay's artifact_root (the same manifest install.sh read) and apply the same
# substitution to the source before hashing, so an install-time binding isn't misread as
# STALE. Only relevant under --harness (the one mode STALE runs in).
ARTIFACT_ROOT=""
if [ -n "$HARNESS" ]; then
  OVERLAY_REF="$(sed -n 's/^overlay:[[:space:]]*//p' "$MANIFEST" | head -1)"
  case "$OVERLAY_REF" in
    "")  OVL_MANIFEST="" ;;
    */*) OVL_MANIFEST="$OVERLAY_REF/manifest.yaml" ;;        # external overlay path
    *)   OVL_MANIFEST="$HARNESS/overlays/$OVERLAY_REF/manifest.yaml" ;;  # bare name
  esac
  if [ -n "$OVL_MANIFEST" ] && [ -f "$OVL_MANIFEST" ]; then
    ARTIFACT_ROOT="$(sed -n 's/^artifact_root:[[:space:]]*//p' "$OVL_MANIFEST" | head -1)"
    ARTIFACT_ROOT="${ARTIFACT_ROOT%%#*}"
    ARTIFACT_ROOT="$(printf '%s' "$ARTIFACT_ROOT" | sed -e 's/[[:space:]]*$//')"
    ARTIFACT_ROOT="${ARTIFACT_ROOT%\"}"; ARTIFACT_ROOT="${ARTIFACT_ROOT#\"}"
    ARTIFACT_ROOT="${ARTIFACT_ROOT%\'}"; ARTIFACT_ROOT="${ARTIFACT_ROOT#\'}"
  fi
fi

# Hash a harness source file the way install.sh stages it: for a .md carrying <artifact-root>,
# bind it first (matching the install-time substitution + trailing-newline normalization).
source_hash() {
  local src="$1" body
  case "$src" in
    *.md)
      if [ -n "$ARTIFACT_ROOT" ] && grep -Iq '<artifact-root>' "$src" 2>/dev/null; then
        body="$(cat "$src")"
        printf '%s\n' "${body//"<artifact-root>"/$ARTIFACT_ROOT}" | shasum -a 256 | awk '{print $1}'
        return
      fi ;;
  esac
  sha256_of "$src"
}

FAILS=0   # MISSING + unfilled-slot + missing harness dir
WARNS=0

# --- per-file manifest verification (state machine over the manifest) ---
P=""; S=""; SRC=""; M=""
check_record() {
  [ -n "$P" ] || return 0
  local installed="$TARGET/$P" ih sh
  if [ ! -e "$installed" ]; then
    echo "FLAG MISSING $P"; FAILS=$((FAILS+1)); return 0
  fi
  # linked files live-track their harness source: a hash drift there is upstream
  # movement, not a local edit — hash comparison is only meaningful for copies.
  if [ "$M" = "link" ]; then
    echo "OK $P"; return 0
  fi
  ih="$(sha256_of "$installed")"
  if [ "$ih" != "$S" ]; then
    echo "FLAG LOCAL-CHANGE $P"; return 0
  fi
  if [ -n "$HARNESS" ] && [ "$SRC" != "assembled" ] && [ -f "$HARNESS/$SRC" ]; then
    sh="$(source_hash "$HARNESS/$SRC")"
    if [ "$sh" != "$S" ]; then echo "FLAG STALE $P"; return 0; fi
  fi
  echo "OK $P"
}
while IFS= read -r line; do
  case "$line" in
    "  - path: "*)   check_record; P="${line#  - path: }"; S=""; SRC=""; M="" ;;
    "    sha256: "*) S="${line#    sha256: }" ;;
    "    source: "*) SRC="${line#    source: }" ;;
    "    mode: "*)   M="${line#    mode: }" ;;
  esac
done < "$MANIFEST"
check_record

# --- structural lint over installed skills ---
SKILLS_DIR="$TARGET/.claude/skills"
if [ -d "$SKILLS_DIR" ]; then
  for d in "$SKILLS_DIR"/*/; do
    [ -d "$d" ] || continue
    name_dir="$(basename "$d")"
    sk="${d}SKILL.md"
    if [ ! -f "$sk" ]; then echo "FLAG MISSING .claude/skills/$name_dir/SKILL.md"; FAILS=$((FAILS+1)); continue; fi
    fm="$(awk 'NR==1 && /^---/ {f=1; next} f && /^---/ {exit} f {print}' "$sk")"
    fname="$(printf '%s\n' "$fm" | grep -E '^name:'        | head -1 | sed 's/^name:[[:space:]]*//')"
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
  grep -RIl '{{HARNESS:' "$1" 2>/dev/null || true
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

echo "---"
if [ "$FAILS" -gt 0 ]; then
  echo "doctor: FAIL — $FAILS blocking issue(s), $WARNS warning(s)"
  exit 1
fi
echo "doctor: PASS — 0 blocking issue(s), $WARNS warning(s)"
exit 0
