#!/usr/bin/env bash
# update.sh — one-command harness update for an already-installed project.
#
# Reads the project's own .claude/manifold-manifest.yaml (overlay / mode / profile / modules,
# recorded at install), optionally fast-forwards this harness clone, and re-runs install.sh
# with the recorded settings. The careful work is install.sh's existing upgrade semantics:
# manifest reconciliation, pruning of retired files, abort on locally-edited overwrite
# (pass --overwrite-local through after syncing local edits back to the harness source).
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
    -h|--help) sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
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

[ -n "$OVERLAY" ] || { echo "error: manifest records no overlay — cannot reconstruct the install" >&2; exit 2; }
if [ -n "$REC_HARNESS" ] && [ "$REC_HARNESS" != "$HARNESS_ROOT" ]; then
  echo "warn: manifest was installed from '$REC_HARNESS'; updating from this clone ($HARNESS_ROOT)" >&2
fi
case "$OVERLAY" in
  */*) [ -d "$OVERLAY" ] || { echo "error: recorded external overlay '$OVERLAY' no longer exists" >&2; exit 2; } ;;
  *)   [ -d "$HARNESS_ROOT/overlays/$OVERLAY" ] || { echo "error: overlay '$OVERLAY' not found under $HARNESS_ROOT/overlays/" >&2; exit 2; } ;;
esac

# fast-forward the harness clone when it has an upstream; a diverged/offline pull is a
# warning, not a failure — updating from the local state is still a valid update.
if [ "$NO_PULL" -eq 0 ] && git -C "$HARNESS_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  if git -C "$HARNESS_ROOT" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    if ! git -C "$HARNESS_ROOT" pull --ff-only >/dev/null 2>&1; then
      echo "warn: could not fast-forward $HARNESS_ROOT (offline or diverged) — updating from local state" >&2
    fi
  fi
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
