#!/usr/bin/env bash
# update.sh — one-command harness update for an already-installed project.
#
# Reads the project's own .claude/manifold-manifest.yaml (overlay / mode / profile / modules,
# recorded at install), optionally fast-forwards this harness clone, and re-runs install.sh
# with the recorded settings. The careful work is install.sh's existing upgrade semantics:
# manifest reconciliation, pruning of retired files, abort on locally-edited overwrite
# (pass --overwrite-local through after syncing local edits back to the harness source).
#
# When this harness's core is a GENERATION ahead of the installed overlay, update.sh does not
# install: it prints the doctor overlay check, stages the /harness-migrate-overlay kit + a
# pending marker into the target, and exits 3 with instructions. Re-run it after the migration.
#
# usage: update.sh [<target-repo>] [--no-pull] [--overwrite-local]
#   <target-repo> defaults to the git root of the current directory (else the cwd).
#   --no-pull          skip the git fast-forward of this harness clone
#   --overwrite-local  passed through to install.sh (see its upgrade semantics)
#
# macOS bash-3.2 safe.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_ROOT="$(dirname "$HERE")"

TARGET=""; NO_PULL=0; OVERWRITE_LOCAL=0
while [ $# -gt 0 ]; do
  case "$1" in
    --no-pull) NO_PULL=1 ;;
    --overwrite-local) OVERWRITE_LOCAL=1 ;;
    -h|--help) sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "error: unknown flag '$1'" >&2; exit 2 ;;
    *) [ -z "$TARGET" ] && TARGET="$1" || { echo "error: extra argument '$1'" >&2; exit 2; } ;;
  esac
  shift
done

if [ -z "$TARGET" ]; then
  TARGET="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi
[ -d "$TARGET" ] || { echo "error: target '$TARGET' is not a directory" >&2; exit 2; }
TARGET="$(cd "$TARGET" && pwd)"

MANIFEST="$TARGET/.claude/manifold-manifest.yaml"
if [ ! -f "$MANIFEST" ]; then
  echo "error: $TARGET is not a manifold install (no .claude/manifold-manifest.yaml)." >&2
  echo "       For a first install use: install.sh <target> --overlay <name-or-path>" >&2
  exit 2
fi

mget() { sed -n "s/^$1:[[:space:]]*//p" "$MANIFEST" | head -1; }
OVERLAY="$(mget overlay)"
MODE="$(mget mode)"
PROFILE="$(mget profile)"
MODULES="$(mget modules)"
REC_HARNESS="$(mget harness_repo)"

if [ "$MODE" != "bootstrap" ]; then
  [ -n "$OVERLAY" ] || { echo "error: manifest records no overlay — cannot reconstruct the install" >&2; exit 2; }
fi
if [ -n "$REC_HARNESS" ] && [ "$REC_HARNESS" != "$HARNESS_ROOT" ]; then
  echo "warn: manifest was installed from '$REC_HARNESS'; updating from this clone ($HARNESS_ROOT)" >&2
fi
if [ "$MODE" != "bootstrap" ]; then
case "$OVERLAY" in
  */*) [ -d "$OVERLAY" ] || { echo "error: recorded external overlay '$OVERLAY' no longer exists" >&2; exit 2; } ;;
  *)   [ -d "$HARNESS_ROOT/overlays/$OVERLAY" ] || { echo "error: overlay '$OVERLAY' not found under $HARNESS_ROOT/overlays/" >&2; exit 2; } ;;
esac
fi

# fast-forward the harness clone when it has an upstream; a diverged/offline pull is a
# warning, not a failure — updating from the local state is still a valid update.
if [ "$NO_PULL" -eq 0 ] && git -C "$HARNESS_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  if git -C "$HARNESS_ROOT" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    if ! git -C "$HARNESS_ROOT" pull --ff-only >/dev/null 2>&1; then
      echo "warn: could not fast-forward $HARNESS_ROOT (offline or diverged) — updating from local state" >&2
    fi
  fi
fi

# A bootstrap install has no overlay yet — re-run bootstrap mode unchanged (the onboarding kit
# refreshes; the overlay arrives when the first session runs /harness-onboarding).
if [ "$MODE" = "bootstrap" ]; then
  set -- "$TARGET" --bootstrap
  [ -n "$PROFILE" ] && set -- "$@" --profile "$PROFILE"
  if [ -n "$MODULES" ] && [ "$MODULES" != "none" ]; then
    set -- "$@" --modules "$(printf '%s' "$MODULES" | tr ' ' ',')"
  fi
  echo "update: re-installing the onboarding kit (bootstrap, profile ${PROFILE:-base}) into $TARGET"
  exec "$HERE/install.sh" "$@"
fi

# --- core generation gate: the one-time, owner-approved overlay migration ------------------
# When this harness's core/GENERATION is ahead of the overlay's recorded core_generation, the
# overlay cannot satisfy the new scaffold and install.sh would refuse (exit 3). Rather than
# just failing, stage the migration kit into the target — the /harness-migrate-overlay skill
# plus a pending marker — and stop with instructions. The kit's files are RECORDED in the
# target's manifest so install.sh's ordinary prune removes them once the overlay is migrated
# and the update proceeds (prune reads the prior manifest's file records; a file absent from
# them is invisible to it).
case "$OVERLAY" in
  */*) OVERLAY_DIR="$OVERLAY" ;;
  *)   OVERLAY_DIR="$HARNESS_ROOT/overlays/$OVERLAY" ;;
esac
# Absent/empty -> generation 1 (pre-generation harnesses/overlays). A value that is PRESENT
# but not a positive integer is a corrupt record, not an absent one: fail closed (return 2).
gen_or_1() { case "${1:-}" in '') echo 1 ;; *[!0-9]*|0*) return 2 ;; *) echo "$1" ;; esac; }
CORE_GEN_RAW=""
[ -f "$HARNESS_ROOT/core/GENERATION" ] && CORE_GEN_RAW="$(head -1 "$HARNESS_ROOT/core/GENERATION" | tr -d '[:space:]')"
CORE_GEN="$(gen_or_1 "$CORE_GEN_RAW")" || { echo "error: malformed generation value '$CORE_GEN_RAW' (expected a positive integer)" >&2; exit 2; }
OVL_GEN_RAW=""
[ -f "$OVERLAY_DIR/manifest.yaml" ] && OVL_GEN_RAW="$(sed -n 's/^core_generation:[[:space:]]*//p' "$OVERLAY_DIR/manifest.yaml" | head -1 | sed -e 's/#.*//' -e 's/[[:space:]]*$//')"
OVL_GEN="$(gen_or_1 "$OVL_GEN_RAW")" || { echo "error: malformed generation value '$OVL_GEN_RAW' (expected a positive integer)" >&2; exit 2; }

MIGRATE_KIT="$HARNESS_ROOT/bootstrap/skills/harness-migrate-overlay"
PENDING="$TARGET/.claude/manifold-migration-pending"

migration_instructions() {
  echo "Migration staged."
  echo "  1) open a Claude Code session in $TARGET"
  echo "  2) run /harness-migrate-overlay and approve the diff"
  echo "  3) re-run update.sh"
}

if [ "$OVL_GEN" -lt "$CORE_GEN" ]; then
  echo "update: overlay '$OVERLAY' is core generation $OVL_GEN; this harness is generation $CORE_GEN — checking the overlay before staging the migration"
  "$HERE/doctor.sh" "$TARGET" --harness "$HARNESS_ROOT" --overlay || true

  if [ ! -f "$PENDING" ]; then
    [ -d "$MIGRATE_KIT" ] || { echo "error: migration kit not found at $MIGRATE_KIT" >&2; exit 2; }
    # Ownership recording is what makes the kit prunable later, so refuse BEFORE touching the
    # target if the manifest cannot be appended to.
    [ -w "$MANIFEST" ] || { echo "error: $MANIFEST is not writable — nothing staged" >&2; exit 2; }

    sha_of() { if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'; else sha256sum "$1" | awk '{print $1}'; fi; }
    # Kit copy + marker + manifest records are one transaction: any failure rolls all of it back.
    # Record shape is install.sh's own (record() is install-only, so this is written by hand);
    # the four fields are exactly what doctor.sh requires of a record.
    stage_migration_kit() {
      mkdir -p "$TARGET/.claude/skills/harness-migrate-overlay" &&
      cp -R "$MIGRATE_KIT/." "$TARGET/.claude/skills/harness-migrate-overlay/" &&
      {
        echo "harness_root: $HARNESS_ROOT"
        echo "overlay: $OVERLAY"
        echo "core_generation: $CORE_GEN"
      } > "$PENDING" &&
      {
        while IFS= read -r kf; do
          [ -n "$kf" ] || continue
          krel="${kf#"$MIGRATE_KIT"/}"
          echo "  - path: .claude/skills/harness-migrate-overlay/$krel"
          echo "    sha256: $(sha_of "$TARGET/.claude/skills/harness-migrate-overlay/$krel")"
          echo "    source: bootstrap/skills/harness-migrate-overlay/$krel"
          echo "    mode: copy"
        done < <(find "$MIGRATE_KIT" -type f ! -path '*/__pycache__/*' ! -name '*.pyc')
        echo "  - path: .claude/manifold-migration-pending"
        echo "    sha256: $(sha_of "$PENDING")"
        echo "    source: generated"
        echo "    mode: copy"
      } >> "$MANIFEST"
    }
    stage_migration_kit || {
      rm -rf "$TARGET/.claude/skills/harness-migrate-overlay" "$PENDING"
      echo "error: staging the migration kit failed — rolled back, nothing staged" >&2
      exit 2
    }
  else
    echo "update: a migration is already pending ($PENDING) and the overlay is still at generation $OVL_GEN"
  fi
  migration_instructions
  exit 3
fi

set -- "$TARGET" --overlay "$OVERLAY"
[ "$MODE" = "link" ] && set -- "$@" --link
[ -n "$PROFILE" ] && set -- "$@" --profile "$PROFILE"
if [ -n "$MODULES" ] && [ "$MODULES" != "none" ] && [ "$PROFILE" != "full" ]; then
  set -- "$@" --modules "$(printf '%s' "$MODULES" | tr ' ' ',')"
fi
[ "$OVERWRITE_LOCAL" -eq 1 ] && set -- "$@" --overwrite-local

echo "update: re-installing '$OVERLAY' (mode ${MODE:-copy}, profile ${PROFILE:-full}) into $TARGET"
exec "$HERE/install.sh" "$@"
