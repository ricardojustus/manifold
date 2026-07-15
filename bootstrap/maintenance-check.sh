#!/usr/bin/env bash
#
# maintenance-check.sh — surface aging governance records so deferred decisions get
# re-examined instead of rotting.
#
#   maintenance-check.sh <artifact-root> [--days N]
#
# The methodology requires every waiver, backlog item, and Kill to carry a revalidation /
# revival trigger. Triggers are prose conditions — no script can evaluate "revisit when X
# changes" — so this check does the honest mechanical half: it inventories every trigger-
# bearing line in the registries, stamps each with its age (from the nearest YYYY-MM-DD on
# the line), and prints the ones older than the threshold (default 60 days) as DUE-REVIEW.
# An agent (or you) then evaluates the prose conditions of exactly that shortlist.
#
# Scanned, when present under <artifact-root>:
#   audits/audit-waivers.md        (waivers + their revalidation triggers)
#   audits/audit-backlog.md        (deferred findings + their trigger conditions)
#   audits/disputed-findings.md    (dismissed disputes — age only)
#   councils/**/  *kill*           (Kill records + their revival triggers)
#
# Informational only: exit 0 always (a maintenance check that fails builds gets disabled).
# macOS bash-3.2 safe.
set -uo pipefail

ROOT="${1:-}"
[ -n "$ROOT" ] || { echo "usage: maintenance-check.sh <artifact-root> [--days N]" >&2; exit 2; }
[ -d "$ROOT" ] || { echo "error: not a directory: $ROOT" >&2; exit 2; }
shift
DAYS=60
while [ $# -gt 0 ]; do
  case "$1" in
    --days) DAYS="${2:-60}"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

NOW_S="$(date +%s)"
TOTAL=0; DUE=0; UNDATED=0

age_days() { # <YYYY-MM-DD> -> days-ago (empty on parse failure)
  local d="$1" then_s
  then_s="$(date -j -f '%Y-%m-%d' "$d" +%s 2>/dev/null || true)"           # BSD date
  [ -n "$then_s" ] || then_s="$(date -d "$d" +%s 2>/dev/null || true)"     # GNU date
  [ -n "$then_s" ] || { echo ""; return 0; }
  echo $(( (NOW_S - then_s) / 86400 ))
}

scan_file() { # <file> <label>
  local f="$1" label="$2" line d age
  [ -f "$f" ] || return 0
  # Lines that carry a trigger vocabulary OR look like a record head. One line per finding.
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    TOTAL=$((TOTAL+1))
    d="$(printf '%s\n' "$line" | grep -oE '20[0-9]{2}-[0-9]{2}-[0-9]{2}' | head -1 || true)"
    if [ -z "$d" ]; then
      UNDATED=$((UNDATED+1))
      echo "UNDATED  [$label] ${line:0:140}"
      continue
    fi
    age="$(age_days "$d")"
    if [ -n "$age" ] && [ "$age" -ge "$DAYS" ]; then
      DUE=$((DUE+1))
      echo "DUE-REVIEW (${age}d)  [$label] ${line:0:140}"
    fi
  done < <(grep -iE 'revisit|revalidat|trigger|revive|reconsider' "$f" 2>/dev/null || true)
}

echo "maintenance-check: $ROOT (threshold ${DAYS}d)"
scan_file "$ROOT/audits/audit-waivers.md"     "waiver"
scan_file "$ROOT/audits/audit-backlog.md"     "backlog"
scan_file "$ROOT/audits/disputed-findings.md" "disputed"
if [ -d "$ROOT/councils" ]; then
  while IFS= read -r kf; do
    [ -n "$kf" ] || continue
    scan_file "$kf" "kill:$(basename "$kf" .md)"
  done < <(find "$ROOT/councils" -type f -iname '*kill*' 2>/dev/null || true)
fi

echo "---"
echo "maintenance-check: $TOTAL trigger-bearing line(s) scanned, $DUE due-review (>${DAYS}d), $UNDATED undated (add a date — an undated trigger can never age)"
exit 0
