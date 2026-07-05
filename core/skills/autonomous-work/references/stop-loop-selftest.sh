#!/usr/bin/env bash
# stop-loop-selftest.sh — pins stop-loop-hook.sh's contract. Run after any edit to the hook,
# and once after wiring it in a new project. Exit 0 iff all assertions hold.
#
# The two properties that must never regress:
#   1. FAIL SAFE — unarmed / cancelled / promise-met / max-reached / any error => NO output
#      (stop allowed). A hook that blocks on an error it can't clear is an infinite loop.
#   2. BLOCK only when armed + promise absent + under max => emits {"decision":"block",...}.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
HOOK="$HERE/stop-loop-hook.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/stoploop-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
D="$TMP/state"; mkdir -p "$D"
fails=0

run() { # <label> <want: block|allow> <payload>
  local label="$1" want="$2" payload="$3" out
  out="$(printf '%s' "$payload" | STOP_LOOP_DIR="$D" bash "$HOOK")"
  local got="allow"; printf '%s' "$out" | grep -q '"decision"[[:space:]]*:[[:space:]]*"block"' && got="block"
  if [ "$got" = "$want" ]; then echo "PASS  $label ($got)"; else echo "FAIL  $label (want $want, got $got)"; fails=$((fails+1)); fi
}

mk_transcript() { # <last assistant text> -> path
  printf '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"%s"}]}}\n' "$1" > "$TMP/tr.jsonl"
  printf '%s' "$TMP/tr.jsonl"
}

TR="$(mk_transcript "still working on it")"

# 1. unarmed (no prompt/promise) -> allow
run "unarmed is inert"            allow "{\"transcript_path\":\"$TR\"}"

printf 'do the task' > "$D/prompt.txt"; printf 'PROMISE: DONE' > "$D/promise"

# 2. armed, promise absent -> block, count increments
run "armed + no promise blocks"   block "{\"transcript_path\":\"$TR\"}"
[ "$(cat "$D/count")" = "1" ] && echo "PASS  count incremented (1)" || { echo "FAIL  count file"; fails=$((fails+1)); }

# 3. promise present -> allow
TR2="$(mk_transcript "finished. PROMISE: DONE")"
run "promise emitted allows"      allow "{\"transcript_path\":\"$TR2\"}"

# 4. max reached -> allow
printf '2' > "$D/max"; printf '2' > "$D/count"
run "max iterations allows"       allow "{\"transcript_path\":\"$TR\"}"
rm -f "$D/max"; printf '0' > "$D/count"

# 5. cancel file -> allow
touch "$D/cancel"
run "cancel file allows"          allow "{\"transcript_path\":\"$TR\"}"
rm -f "$D/cancel"

# 6. bad JSON payload -> allow (fail safe)
run "malformed payload allows"    allow 'not json at all'

# 7. unreadable transcript -> allow (fail safe)
run "missing transcript allows"   allow '{"transcript_path":"/nonexistent/tr.jsonl"}'

echo ""
if [ "$fails" = 0 ]; then echo "ALL STOP-LOOP SELFTESTS PASSED"; exit 0; fi
echo "$fails STOP-LOOP SELFTEST(S) FAILED"; exit "$fails"
