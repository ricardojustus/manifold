#!/usr/bin/env bash
#
# install.sh — install the Manifold harness into a target repo.
#
#   install.sh <target-repo> --overlay <name-or-path> [--link]
#
# Assembles <target>/CLAUDE.harness.md from core/CLAUDE.scaffold.md + the overlay's
# claude-slots, copies core skills/rules/templates/harness docs into <target>/.claude/,
# appends per-skill overlay bindings, binds the <artifact-root> token from the overlay's
# manifest, and writes <target>/.claude/manifold-manifest.yaml recording a sha256 per
# installed file (so doctor.sh can tell deliberate local edits from staleness).
#
# --overlay takes either a bare NAME (resolved under overlays/) or a PATH to an external
# overlay dir (an argument with a '/' or an existing directory).
#
# Fail-closed: everything is assembled in a scratch staging dir first; if any assembled
# file still contains a {{HARNESS:...}} placeholder OR an unbound <artifact-root> token,
# NOTHING is written to the target.
#
# macOS bash-3.2 safe: no associative arrays, no mapfile. shasum -a 256 for hashing.
set -euo pipefail

usage() { echo "usage: install.sh <target-repo> --overlay <name-or-path> [--link]" >&2; }

HARNESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TARGET=""
OVERLAY=""
MODE="copy"

while [ $# -gt 0 ]; do
  case "$1" in
    --overlay) OVERLAY="${2:-}"; shift 2 ;;
    --link)    MODE="link"; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "error: unknown option: $1" >&2; usage; exit 2 ;;
    *)         if [ -z "$TARGET" ]; then TARGET="$1"; shift
               else echo "error: unexpected argument: $1" >&2; usage; exit 2; fi ;;
  esac
done

[ -n "$TARGET" ]  || { echo "error: <target-repo> required" >&2; usage; exit 2; }
[ -n "$OVERLAY" ] || { echo "error: --overlay <name-or-path> required" >&2; usage; exit 2; }
[ -d "$TARGET" ]  || { echo "error: target is not a directory: $TARGET" >&2; exit 2; }

# Resolve the overlay. A bare NAME resolves under the harness's overlays/. An argument that
# contains a '/' OR names an existing directory is treated as a PATH to an external overlay
# dir (so a project can keep its overlay next to its own repo, not inside the harness clone).
# An external overlay must look like one: it must contain claude-slots/ or a manifest.yaml.
# OVERLAY_RECORD = what the manifest records (bare name, or absolute path for an external
# overlay); OVERLAY_SRCREF = the per-file source prefix recorded for overlay-sourced files.
case "$OVERLAY" in
  */*) OVERLAY_IS_PATH=1 ;;
  *)   if [ -d "$OVERLAY" ]; then OVERLAY_IS_PATH=1; else OVERLAY_IS_PATH=0; fi ;;
esac
if [ "$OVERLAY_IS_PATH" = 1 ]; then
  [ -d "$OVERLAY" ] || { echo "error: overlay path not found: $OVERLAY" >&2; exit 2; }
  OVERLAY_DIR="$(cd "$OVERLAY" && pwd)"
  if [ ! -d "$OVERLAY_DIR/claude-slots" ] && [ ! -f "$OVERLAY_DIR/manifest.yaml" ]; then
    echo "error: '$OVERLAY_DIR' is not an overlay (needs claude-slots/ or manifest.yaml)" >&2; exit 2
  fi
  OVERLAY_RECORD="$OVERLAY_DIR"; OVERLAY_SRCREF="$OVERLAY_DIR"
else
  OVERLAY_DIR="$HARNESS_ROOT/overlays/$OVERLAY"
  [ -d "$OVERLAY_DIR" ] || { echo "error: overlay not found: $OVERLAY_DIR" >&2; exit 2; }
  OVERLAY_RECORD="$OVERLAY"; OVERLAY_SRCREF="overlays/$OVERLAY"
fi
TARGET="$(cd "$TARGET" && pwd)"

# The overlay's REQUIRED artifact_root binds the <artifact-root> token in core prose (the
# Evidence-Store path where audit/council records live). Parsed from a top-level
# `artifact_root:` line in the overlay manifest.yaml (grep/sed — bash-3.2-safe, no yaml
# parser). Empty if absent -> the substitution below can't fill, and the fail-closed scan
# aborts the install (same contract as an unfilled slot).
ARTIFACT_ROOT=""
if [ -f "$OVERLAY_DIR/manifest.yaml" ]; then
  ARTIFACT_ROOT="$(sed -n 's/^artifact_root:[[:space:]]*//p' "$OVERLAY_DIR/manifest.yaml" | head -1)"
  ARTIFACT_ROOT="${ARTIFACT_ROOT%%#*}"                                           # strip inline comment
  ARTIFACT_ROOT="$(printf '%s' "$ARTIFACT_ROOT" | sed -e 's/[[:space:]]*$//')"   # trim trailing ws
  ARTIFACT_ROOT="${ARTIFACT_ROOT%\"}"; ARTIFACT_ROOT="${ARTIFACT_ROOT#\"}"       # strip dquotes
  ARTIFACT_ROOT="${ARTIFACT_ROOT%\'}"; ARTIFACT_ROOT="${ARTIFACT_ROOT#\'}"       # strip squotes
fi

# A staged file that will undergo <artifact-root> substitution cannot be a live symlink —
# writing the bound value would corrupt the harness source. Such files fall back to a real
# copy in --link mode, the same rule that already forces binding-bearing skills to copy.
file_has_artifact_token() { grep -Iq '<artifact-root>' "$1" 2>/dev/null; }

HARNESS_VERSION="$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[A-Za-z0-9.-]*' "$HARNESS_ROOT/CHANGELOG.md" 2>/dev/null | head -1 || true)"
[ -n "$HARNESS_VERSION" ] || HARNESS_VERSION="unknown"

sha256_of() { shasum -a 256 "$1" | awk '{print $1}'; }

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/manifold-install.XXXXXX")"
cleanup() { rm -rf "$STAGE"; }
trap cleanup EXIT

# Records accumulate as "relpath|source|filemode"; hashes are computed from the staged
# file after assembly (so appended bindings are hashed correctly).
RECORDS="$STAGE/.records.tmp"
: > "$RECORDS"
record() { printf '%s|%s|%s\n' "$1" "$2" "$3" >> "$RECORDS"; }

stage_copy() { mkdir -p "$STAGE/$(dirname "$2")"; cp "$1" "$STAGE/$2"; }
stage_link() { mkdir -p "$STAGE/$(dirname "$2")"; ln -s "$1" "$STAGE/$2"; }

BINDING_SECTION=$'\n\n## Project bindings\n\n'

# --- skills: core/skills/* -> .claude/skills/*, append overlay skill-bindings to SKILL.md ---
if [ -d "$HARNESS_ROOT/core/skills" ]; then
  for skdir in "$HARNESS_ROOT/core/skills"/*/; do
    [ -d "$skdir" ] || continue
    sk="$(basename "$skdir")"
    binding="$OVERLAY_DIR/skill-bindings/$sk.md"
    while IFS= read -r f; do
      rel="${f#"$HARNESS_ROOT"/core/skills/}"      # e.g. alpha/SKILL.md
      destrel=".claude/skills/$rel"
      srcrel="core/skills/$rel"
      is_skillmd=0
      [ "$rel" = "$sk/SKILL.md" ] && is_skillmd=1
      if [ "$MODE" = link ] && ! { [ "$is_skillmd" = 1 ] && [ -f "$binding" ]; } && ! file_has_artifact_token "$f"; then
        stage_link "$f" "$destrel"; record "$destrel" "$srcrel" "link"
      else
        # copy path (always for copy mode; also for a linked skill that needs a binding
        # appended, since you cannot append to a symlink; also for any file carrying the
        # <artifact-root> token, which is bound in place after staging)
        stage_copy "$f" "$destrel"
        if [ "$is_skillmd" = 1 ] && [ -f "$binding" ]; then
          printf '%s' "$BINDING_SECTION" >> "$STAGE/$destrel"
          cat "$binding" >> "$STAGE/$destrel"
        fi
        record "$destrel" "$srcrel" "copy"
      fi
    done < <(find "$skdir" -type f)
  done
fi

# --- plain trees: copy (or link) every file under a core dir to a target prefix ---
# Optional 4th arg "skip_readme" drops any file named README.md (a directory placeholder /
# authoring doc that should not be installed into the target). Used for overlay trees.
copy_tree() { # <src-root> <dest-prefix> <source-prefix> [skip_readme]
  [ -d "$1" ] || return 0
  local f rel destrel srcrel skip="${4:-}"
  while IFS= read -r f; do
    [ "$skip" = skip_readme ] && [ "$(basename "$f")" = README.md ] && continue
    rel="${f#"$1"/}"
    destrel="$2/$rel"
    srcrel="$3/$rel"
    if [ "$MODE" = link ] && ! file_has_artifact_token "$f"; then stage_link "$f" "$destrel"; record "$destrel" "$srcrel" "link"
    else stage_copy "$f" "$destrel"; record "$destrel" "$srcrel" "copy"; fi
  done < <(find "$1" -type f)
}
copy_tree "$HARNESS_ROOT/core/rules"      ".claude/rules"             "core/rules"
copy_tree "$HARNESS_ROOT/core/templates"  ".claude/harness-templates" "core/templates"
copy_tree "$HARNESS_ROOT/core/principles" ".claude/harness/principles" "core/principles"
copy_tree "$HARNESS_ROOT/core/case-law"   ".claude/harness/case-law"   "core/case-law"

# --- overlay trees: project rules + enforcement hooks (README.md placeholders skipped) ---
# Overlay rules merge into .claude/rules/ alongside core rules; hooks install as DRAFT to
# .claude/harness-hooks/ and are NOT wired into settings.json (ruling D3 — wiring is a
# documented manual step; see overlays/<name>/hooks/README.md).
copy_tree "$OVERLAY_DIR/rules"  ".claude/rules"          "$OVERLAY_SRCREF/rules"  skip_readme
copy_tree "$OVERLAY_DIR/hooks"  ".claude/harness-hooks"  "$OVERLAY_SRCREF/hooks"  skip_readme

# --- overlay project-only skills -> .claude/skills/ (alongside core skills). No overlay
# binding is appended: skill-bindings are for CORE skills; a project-only skill ships complete.
# README.md placeholders skipped; each file is manifest-recorded like every other copy. ---
copy_tree "$OVERLAY_DIR/skills" ".claude/skills"         "$OVERLAY_SRCREF/skills" skip_readme

# --- skill-binding support scripts -> .claude/harness-scripts/ (the installed location the
# appended bindings reference). Without this, a binding that invokes a watcher/detector script
# points at a path that doesn't exist in the target. README.md placeholders skipped. ---
copy_tree "$OVERLAY_DIR/skill-bindings/scripts" ".claude/harness-scripts" "$OVERLAY_SRCREF/skill-bindings/scripts" skip_readme

# --- METHODOLOGY.md + ENFORCEMENT.md + SUCCESSOR_CALIBRATION.md -> .claude/harness/
# (token-bearing ones copy, not link) ---
for base in METHODOLOGY.md ENFORCEMENT.md SUCCESSOR_CALIBRATION.md; do
  src="$HARNESS_ROOT/core/$base"
  [ -f "$src" ] || continue
  if [ "$MODE" = link ] && ! file_has_artifact_token "$src"; then stage_link "$src" ".claude/harness/$base"; record ".claude/harness/$base" "core/$base" "link"
  else stage_copy "$src" ".claude/harness/$base"; record ".claude/harness/$base" "core/$base" "copy"; fi
done

# --- FIELD_GUIDE.md (repo root) -> .claude/harness/ so it ships with an installed project ---
if [ -f "$HARNESS_ROOT/FIELD_GUIDE.md" ]; then
  if [ "$MODE" = link ] && ! file_has_artifact_token "$HARNESS_ROOT/FIELD_GUIDE.md"; then stage_link "$HARNESS_ROOT/FIELD_GUIDE.md" ".claude/harness/FIELD_GUIDE.md"; record ".claude/harness/FIELD_GUIDE.md" "FIELD_GUIDE.md" "link"
  else stage_copy "$HARNESS_ROOT/FIELD_GUIDE.md" ".claude/harness/FIELD_GUIDE.md"; record ".claude/harness/FIELD_GUIDE.md" "FIELD_GUIDE.md" "copy"; fi
fi

# --- assemble CLAUDE.harness.md (always a real file; slots substituted literally) ---
scaffold="$(cat "$HARNESS_ROOT/core/CLAUDE.scaffold.md")"
if [ -d "$OVERLAY_DIR/claude-slots" ]; then
  for sf in "$OVERLAY_DIR/claude-slots"/*.md; do
    [ -e "$sf" ] || continue
    [ "$(basename "$sf")" = "README.md" ] && continue   # dir placeholder, not a slot
    slot="$(basename "$sf" .md)"
    content="$(cat "$sf")"
    token="{{HARNESS:${slot}}}"
    case "$scaffold" in
      *"$token"*) : ;;
      *) echo "warn: overlay slot file '$slot.md' matches no {{HARNESS:$slot}} placeholder in the scaffold (unused)" >&2 ;;
    esac
    scaffold="${scaffold//"$token"/$content}"   # quoted search = literal; replacement not re-interpreted
  done
fi
printf '%s\n' "$scaffold" > "$STAGE/CLAUDE.harness.md"
record "CLAUDE.harness.md" "assembled" "copy"

# --- fail closed: any surviving placeholder means an unfilled slot ---
if grep -RIl '{{HARNESS:' "$STAGE" >/dev/null 2>&1; then
  echo "INSTALL FAILED: unfilled slot(s) — nothing written to $TARGET" >&2
  grep -RIn '{{HARNESS:' "$STAGE" 2>/dev/null | sed "s#$STAGE/##" >&2 || true
  exit 1
fi

# --- bind <artifact-root>: literal substitution across all staged .md files ---
# Only real files (-type f) are rewritten; token-bearing files were forced to copy above, so
# no symlink is ever written through. Same literal-substitution discipline as the slots.
if [ -n "$ARTIFACT_ROOT" ]; then
  while IFS= read -r mf; do
    [ -n "$mf" ] || continue
    body="$(cat "$mf")"
    case "$body" in
      *"<artifact-root>"*) printf '%s\n' "${body//"<artifact-root>"/$ARTIFACT_ROOT}" > "$mf" ;;
    esac
  done < <(find "$STAGE" -type f -name '*.md' 2>/dev/null)
fi

# --- fail closed: any surviving <artifact-root> means the overlay lacked artifact_root ---
if grep -RIl '<artifact-root>' "$STAGE" >/dev/null 2>&1; then
  echo "INSTALL FAILED: unbound <artifact-root> — overlay manifest.yaml is missing a top-level 'artifact_root:' key — nothing written to $TARGET" >&2
  grep -RIn '<artifact-root>' "$STAGE" 2>/dev/null | sed "s#$STAGE/##" >&2 || true
  exit 1
fi

# --- write the manifest (hashes computed from staged files) ---
mkdir -p "$STAGE/.claude"
MANIFEST="$STAGE/.claude/manifold-manifest.yaml"
{
  echo "harness_version: $HARNESS_VERSION"
  echo "mode: $MODE"
  echo "overlay: $OVERLAY_RECORD"
  echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "files:"
  while IFS='|' read -r rel src fmode; do
    [ -n "$rel" ] || continue
    echo "  - path: $rel"
    echo "    sha256: $(sha256_of "$STAGE/$rel")"
    echo "    source: $src"
    echo "    mode: $fmode"
  done < "$RECORDS"
} > "$MANIFEST"
rm -f "$RECORDS"

# --- commit staging into the target (tar preserves symlinks and merges into .claude) ---
# NB: extraction failure must abort loudly (set -e + pipefail) — never print INSTALL OK
# after a failed write. Count is computed separately so it can't mask a tar failure.
tar -C "$STAGE" -cf - . | tar -C "$TARGET" -xf -
n_files="$(grep -c '  - path: ' "$MANIFEST" 2>/dev/null || true)"
echo "INSTALL OK: harness $HARNESS_VERSION, overlay '$OVERLAY_RECORD', mode $MODE"
echo "  target:   $TARGET"
echo "  manifest: $TARGET/.claude/manifold-manifest.yaml ($n_files files)"
echo "  note:     $TARGET/CLAUDE.harness.md is NOT auto-included — see bootstrap/INSTALL.md"
