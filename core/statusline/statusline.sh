#!/usr/bin/env bash
# statusline.sh — Claude Code statusLine script
# Input: JSON payload on stdin per Claude Code statusLine spec
# Renders: [track] dir | model [effort] | tokens | context bar ‖ rate limits · account ‖ Codex jobs
#
# Wiring, helper lookup and the account label: see README.md beside this file.

input=$(cat)

# Helper scripts live beside this one; the same directory is where an optional
# statusline-local.sh (project/operator customisation) is read from.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# --- Account label: the logged-in email of the active config dir ---
# Each login has its own config dir, which records that login's email. Reading the
# email (rather than inferring from the dir name) stays truthful across a /login swap.
# The DEFAULT profile keeps its config at ~/.claude.json, not inside the config dir —
# check both, or a single-account setup shows no account at all.
# Empty = the segment is omitted. statusline-local.sh may overwrite $acct with a
# shorter label of its own.
acct=$(jq -r '.oauthAccount.emailAddress // empty' "$CONFIG_DIR/.claude.json" 2>/dev/null)
[ -n "$acct" ] || acct=$(jq -r '.oauthAccount.emailAddress // empty' "$HOME/.claude.json" 2>/dev/null)
[ -f "$HERE/statusline-local.sh" ] && . "$HERE/statusline-local.sh"

# --- Track name: the tmux session this Claude runs in ---
# Target the session id from $TMUX (the session the pane was CREATED in), not the
# bare '#S' — bare #S resolves via the attached client, so viewing through an
# umbrella session (link-window) mislabels every pane as that umbrella.
track=""
if [ -n "$TMUX" ]; then
  track=$(tmux display-message -t "\$${TMUX##*,}" -p '#S' 2>/dev/null)
fi

# --- Directory: basename of current working directory ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir=$(basename "$cwd")

# --- Model: display_name with "Claude " prefix stripped ---
display_name=$(echo "$input" | jq -r '.model.display_name // empty')
model="${display_name#Claude }"

# --- Reasoning effort: appended to model when present ---
# Field present only on models that support reasoning effort.
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
if [ -n "$effort_level" ]; then
  model="${model} [${effort_level}]"
fi

# --- Context usage percentage ---
# Use pre-calculated field if available; otherwise compute from token counts
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# Total context tokens = new input + cache creation + cache read
# (current_usage.input_tokens alone is only the new-this-turn delta, not the full context)
input_tokens=$(echo "$input" | jq -r '
  (.context_window.current_usage.input_tokens // 0) +
  (.context_window.current_usage.cache_creation_input_tokens // 0) +
  (.context_window.current_usage.cache_read_input_tokens // 0)
')

if [ -z "$used_pct" ] || [ "$used_pct" = "null" ]; then
  if [ -n "$input_tokens" ] && [ -n "$window_size" ] && [ "$window_size" -gt 0 ] 2>/dev/null; then
    used_pct=$(echo "scale=1; $input_tokens * 100 / $window_size" | bc)
  fi
fi

# --- Token count: compact human-readable ---
if [ -n "$input_tokens" ] && [ "$input_tokens" -gt 0 ] 2>/dev/null; then
  if [ "$input_tokens" -ge 1000000 ]; then
    # Millions: e.g. 1.2M
    tok_display=$(awk "BEGIN { printf \"%.1fM\", $input_tokens / 1000000 }" | sed 's/\.0M$/M/')
  elif [ "$input_tokens" -ge 1000 ]; then
    # Thousands: e.g. 84k — one decimal only when it adds info (>= 10k shows whole number)
    tok_display=$(awk "BEGIN {
      v = $input_tokens / 1000
      if (v >= 10) printf \"%.0fk\", v
      else printf \"%.1fk\", v
    }" | sed 's/\.0k$/k/')
  else
    tok_display="${input_tokens}"
  fi
  tok_field="${tok_display} tok"
else
  tok_field="-- tok"
fi

# --- Build context bar ---
# 20-block bar, each block = 5%. Red tick marks the compaction warning threshold.
WARN_PCT=35
BAR_WIDTH=20
WARN_POS=$(( WARN_PCT * BAR_WIDTH / 100 ))  # block index just after WARN_PCT

RED=$'\033[31m'
RESET=$'\033[0m'

if [ -n "$used_pct" ]; then
  pct_int=$(printf "%.0f" "$used_pct")
  [ "$pct_int" -lt 0 ] && pct_int=0
  [ "$pct_int" -gt 100 ] && pct_int=100

  filled=$(( pct_int * BAR_WIDTH / 100 ))
  empty=$(( BAR_WIDTH - filled ))

  bar=""
  for ((i=0; i<BAR_WIDTH; i++)); do
    if [ "$i" -eq "$WARN_POS" ]; then
      bar="${bar}${RED}│${RESET}"
    fi
    if [ "$i" -lt "$filled" ]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
  done

  if [ "$pct_int" -ge "$WARN_PCT" ]; then
    pct_label="${RED}$(printf "%.0f" "$used_pct")%${RESET}"
  else
    pct_label="$(printf "%.0f" "$used_pct")%"
  fi
  ctx_display="[${bar}] ${pct_label}"
else
  empty_bar=""
  for ((i=0; i<BAR_WIDTH; i++)); do
    if [ "$i" -eq "$WARN_POS" ]; then
      empty_bar="${empty_bar}${RED}│${RESET}"
    fi
    empty_bar="${empty_bar}░"
  done
  ctx_display="[${empty_bar}] --%"
fi

# --- Rate limits: 5-hour session and 7-day weekly ---
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Any additional model-tier buckets Claude Code ever adds to rate_limits
# (beyond five_hour/seven_day) render generically as "<name> N%" — this is
# where a per-model limit would appear IF the payload carried one.
extra_limits=$(echo "$input" | jq -r '.rate_limits // {} | to_entries[] | select(.key != "five_hour" and .key != "seven_day") | select(.value.used_percentage != null) | "\(.key) \(.value.used_percentage | round)%"' 2>/dev/null | paste -sd'|' - | sed 's/|/  |  /g')

if [ -n "$five_hour_pct" ] && [ -n "$seven_day_pct" ]; then
  wk_int=$(printf "%.0f" "$seven_day_pct")
  # Weekly reset countdown from resets_at (epoch): single compact unit (Xd / Xh / Xm)
  wk_reset=""
  if [ -n "$seven_day_reset" ] && [ "$seven_day_reset" -gt 0 ] 2>/dev/null; then
    rem=$(( seven_day_reset - $(date +%s) ))
    if [ "$rem" -gt 0 ]; then
      if [ "$rem" -ge 86400 ]; then wk_reset=" ·$(( rem / 86400 ))d"
      elif [ "$rem" -ge 3600 ]; then wk_reset=" ·$(( rem / 3600 ))h"
      else wk_reset=" ·$(( rem / 60 ))m"; fi
    fi
  fi
  wk_label="Wk ${wk_int}%${wk_reset}"
  if [ "$wk_int" -ge 80 ]; then
    wk_label="${RED}${wk_label}${RESET}"
  fi
  rate_display="5h $(printf "%.0f" "$five_hour_pct")%  |  ${wk_label}"
else
  rate_display="5h --%  |  Wk --%"
fi
if [ -n "$extra_limits" ]; then
  rate_display="${rate_display}  |  ${extra_limits}"
fi
[ -n "$acct" ] && rate_display="${rate_display}  ·  Acct: ${acct}"

# --- Codex jobs for THIS session (per-session tally; empty when none) ---
# Every Codex job records the dispatching Claude session_id; the statusline receives the same
# session_id on stdin, so this shows exactly this session's Codex jobs. Fail-quiet helper.
session_id=$(echo "$input" | jq -r '.session_id // empty')
# Record this session's track so codex-top can label jobs by TRACK (jobs only carry sessionId,
# and sessions of different tracks may share one directory, so the worktree can't tell them apart).
if [ -n "$session_id" ] && [ -n "$track" ]; then
  mkdir -p "$CONFIG_DIR/session-tracks" 2>/dev/null
  printf '%s' "$track" > "$CONFIG_DIR/session-tracks/${session_id}" 2>/dev/null
fi
codex_suffix=""
if [ -n "$session_id" ] && [ -f "$HERE/codex-jobs-tally.mjs" ]; then
  codex_seg=$(node "$HERE/codex-jobs-tally.mjs" "$session_id" 2>/dev/null)
  [ -n "$codex_seg" ] && codex_suffix="  ‖  ${codex_seg}"
fi

# --- Compose status line ---
if [ -n "$track" ]; then
  printf "[%s]  %s  |  %s  |  %s  |  %s  ‖  %s%s" "$track" "$dir" "$model" "$tok_field" "$ctx_display" "$rate_display" "$codex_suffix"
else
  printf "%s  |  %s  |  %s  |  %s  ‖  %s%s" "$dir" "$model" "$tok_field" "$ctx_display" "$rate_display" "$codex_suffix"
fi
