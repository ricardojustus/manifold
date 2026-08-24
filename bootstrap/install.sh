#!/usr/bin/env bash
#
# install.sh — install the Manifold harness into a target repo.
#
#   install.sh <target-repo> --overlay <name-or-path> [--link] [--profile base|full]
#              [--modules m1,m2] [--allow-placeholder-template] [--overwrite-local]
#   install.sh <target-repo> --bootstrap [--force-bootstrap] [--profile base|full] [--modules m1,m2]
#
# Assembles <target>/CLAUDE.harness.md from core/CLAUDE.scaffold.md + the overlay's
# claude-slots, copies core skills/rules/templates/harness docs into <target>/.claude/,
# appends per-skill overlay bindings, binds the <artifact-root> token from the overlay's
# manifest, and writes <target>/.claude/manifold-manifest.yaml recording a sha256 per
# installed file plus its build recipe (source hash, binding path + hash) so doctor.sh
# can tell local edits from upstream staleness from hand-converged copies.
#
# --overlay takes either a bare NAME (resolved under overlays/) or a PATH to an external
# overlay dir (an argument with a '/' or an existing directory).
#
# PROFILES: --profile base installs the core discipline set and SKIPS the optional
# modules; --profile full installs everything. Optional modules (enable individually
# with --modules): inter-session (the peer-session messaging bus + its Python runtime),
# multi-agent (parallel-workstreams + merge-and-cleanup lane orchestration), atlas (the
# decision-record + orientation templates; owns no skills), statusline (the status-bar
# script + Codex job board; owns no skills, needs manual settings wiring). The overlay
# manifest may pin `profile:` and `modules:`; the CLI overrides. Default: full
# (back-compat for existing installs; the _template manifest pins base for new adopters).
#
# UPGRADE SEMANTICS (re-install over an existing install): files owned by the PRIOR
# manifest that vanish from the new stage are PRUNED (removed if unmodified since
# install; kept with a warning if locally edited). A locally-edited managed file that
# the new stage would overwrite ABORTS the install unless --overwrite-local is given —
# sync your local edit back to the harness source first (that is where it belongs).
#
# GENERATION GATE: core/GENERATION (absent = 1) vs the overlay manifest's core_generation
# (absent = 1). An overlay older than the core is REFUSED (exit 3, nothing written) — run
# update.sh, which stages the one-time migration kit. --bootstrap has no overlay and is exempt.
#
# Fail-closed: everything is assembled in a scratch staging dir first; if any assembled
# file still contains a {{HARNESS:...}} placeholder, an unbound <artifact-root> token,
# OR an unfilled `<!-- FILL` template sentinel (unless --allow-placeholder-template),
# NOTHING is written to the target.
#
# BOOTSTRAP MODE (--bootstrap, no --overlay): installs the onboarding kit into a repo that
# has no overlay yet — core at profile base, plus bootstrap/skills/harness-onboarding/ and a
# .claude/manifold-onboarding-pending marker naming this harness clone. No constitution is
# assembled (no overlay -> no slots), so the fail-closed rule is untouched: the constitution
# simply does not exist yet. The manifest records `mode: bootstrap`; the first session runs
# /harness-onboarding, which writes a real overlay and re-installs normally over this one.
#
# macOS bash-3.2 safe: no associative arrays, no mapfile. SHA-256 via shasum, falling back to
# sha256sum where shasum is absent (most Linux distros).
set -euo pipefail

usage() { echo "usage: install.sh <target-repo> --overlay <name-or-path> [--link] [--profile base|full] [--modules m1,m2] [--allow-placeholder-template] [--overwrite-local]
       install.sh <target-repo> --bootstrap [--force-bootstrap] [--profile base|full] [--modules m1,m2]" >&2; }

HARNESS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

TARGET=""
OVERLAY=""
MODE="copy"
PROFILE=""
MODULES_CLI=""
ALLOW_PLACEHOLDER=0
OVERWRITE_LOCAL=0
BOOTSTRAP=0
FORCE_BOOTSTRAP=0

while [ $# -gt 0 ]; do
  case "$1" in
    --overlay) OVERLAY="${2:-}"; shift 2 ;;
    --bootstrap) BOOTSTRAP=1; shift ;;
    --force-bootstrap) BOOTSTRAP=1; FORCE_BOOTSTRAP=1; shift ;;
    --link)    MODE="link"; shift ;;
    --profile) PROFILE="${2:-}"; shift 2 ;;
    --modules) MODULES_CLI="${2:-}"; shift 2 ;;
    --allow-placeholder-template) ALLOW_PLACEHOLDER=1; shift ;;
    --overwrite-local) OVERWRITE_LOCAL=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*)        echo "error: unknown option: $1" >&2; usage; exit 2 ;;
    *)         if [ -z "$TARGET" ]; then TARGET="$1"; shift
               else echo "error: unexpected argument: $1" >&2; usage; exit 2; fi ;;
  esac
done

[ -n "$TARGET" ]  || { echo "error: <target-repo> required" >&2; usage; exit 2; }
if [ "$BOOTSTRAP" = 1 ]; then
  [ -z "$OVERLAY" ] || { echo "error: --bootstrap installs the onboarding kit and takes no --overlay" >&2; usage; exit 2; }
  [ -d "$HARNESS_ROOT/bootstrap/skills/harness-onboarding" ] || { echo "error: onboarding skill not found at $HARNESS_ROOT/bootstrap/skills/harness-onboarding" >&2; exit 2; }
else
  [ -n "$OVERLAY" ] || { echo "error: --overlay <name-or-path> required (or --bootstrap for a repo with no overlay yet)" >&2; usage; exit 2; }
fi
[ -d "$TARGET" ]  || { echo "error: target is not a directory: $TARGET" >&2; exit 2; }

# Resolve the overlay. A bare NAME resolves under the harness's overlays/. An argument that
# contains a '/' OR names an existing directory is treated as a PATH to an external overlay
# dir (so a project can keep its overlay next to its own repo, not inside the harness clone).
# An external overlay must look like one: it must contain claude-slots/ or a manifest.yaml.
# OVERLAY_RECORD = what the manifest records (bare name, or absolute path for an external
# overlay); OVERLAY_SRCREF = the per-file source prefix recorded for overlay-sourced files.
# Bootstrap mode has no overlay at all: OVERLAY_DIR points at a path that does not exist, so
# every overlay-sourced copy_tree/binding lookup below is a no-op.
if [ "$BOOTSTRAP" = 1 ]; then
  OVERLAY_IS_PATH=0
  OVERLAY_DIR="$HARNESS_ROOT/overlays/__none__"
  OVERLAY_RECORD=""; OVERLAY_SRCREF=""
else
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
fi
TARGET="$(cd "$TARGET" && pwd)"

# Guard: --bootstrap over a NON-bootstrap install stages no constitution and no overlay files, so
# the prune step below removes the target's CLAUDE.harness.md and every overlay-sourced rule —
# leaving their CLAUDE.md importing a file that no longer exists. Refuse; --force-bootstrap wins.
if [ "$BOOTSTRAP" = 1 ] && [ "$FORCE_BOOTSTRAP" != 1 ] && [ -f "$TARGET/.claude/manifold-manifest.yaml" ]; then
  PRIOR_MODE="$(sed -n 's/^mode:[[:space:]]*//p' "$TARGET/.claude/manifold-manifest.yaml" | head -1)"
  PRIOR_OVERLAY="$(sed -n 's/^overlay:[[:space:]]*//p' "$TARGET/.claude/manifold-manifest.yaml" | head -1)"
  # An unreadable/absent mode is NOT 'bootstrap' — a manifest with file records but no usable
  # mode header (legacy or hand-edited) is exactly the unknown prior state a destructive guard
  # must refuse for.
  if [ "$PRIOR_MODE" != "bootstrap" ]; then
    echo "error: $TARGET already carries a full install (overlay '${PRIOR_OVERLAY:-unknown}', mode ${PRIOR_MODE:-unknown}) — --bootstrap would remove its CLAUDE.harness.md and overlay-sourced rules. Re-install with --overlay ${PRIOR_OVERLAY:-<yours>}, or pass --force-bootstrap if you really mean to strip it back to the onboarding kit." >&2
    exit 2
  fi
fi

# Read a scalar key from the overlay manifest (grep/sed — bash-3.2-safe, no yaml parser).
manifest_key() { # <key>
  [ -f "$OVERLAY_DIR/manifest.yaml" ] || { echo ""; return 0; }
  local v
  v="$(sed -n "s/^$1:[[:space:]]*//p" "$OVERLAY_DIR/manifest.yaml" | head -1)"
  v="${v%%#*}"
  v="$(printf '%s' "$v" | sed -e 's/[[:space:]]*$//')"
  v="${v%\"}"; v="${v#\"}"
  v="${v%\'}"; v="${v#\'}"
  printf '%s' "$v"
}

# --- core generation gate ------------------------------------------------------------------
# core/GENERATION is the harness's CORE GENERATION: it bumps only when the scaffold's slot set
# or the core roster changes in a way an existing overlay cannot satisfy. An overlay records the
# generation it was written for (`core_generation:` in its manifest). Installing a gen-N overlay
# over a gen-N+1 core would assemble a constitution with unfilled slots (or silently drop content
# the new slots expect), so it is REFUSED before anything is staged. --bootstrap has no overlay
# to check.
# Absent/empty -> generation 1 (pre-generation harnesses/overlays). A value that is PRESENT
# but not a positive integer is a corrupt record, not an absent one: fail closed (return 2).
gen_or_1() { case "${1:-}" in '') echo 1 ;; *[!0-9]*|0*) return 2 ;; *) echo "$1" ;; esac; }
CORE_GEN_RAW=""
[ -f "$HARNESS_ROOT/core/GENERATION" ] && CORE_GEN_RAW="$(head -1 "$HARNESS_ROOT/core/GENERATION" | tr -d '[:space:]')"
CORE_GENERATION="$(gen_or_1 "$CORE_GEN_RAW")" || { echo "error: malformed generation value '$CORE_GEN_RAW' (expected a positive integer)" >&2; exit 2; }
if [ "$BOOTSTRAP" != 1 ]; then
  OVL_GEN_RAW="$(manifest_key core_generation)"
  OVERLAY_GENERATION="$(gen_or_1 "$OVL_GEN_RAW")" || { echo "error: malformed generation value '$OVL_GEN_RAW' (expected a positive integer)" >&2; exit 2; }
  if [ "$OVERLAY_GENERATION" -lt "$CORE_GENERATION" ]; then
    echo "INSTALL REFUSED: overlay '$OVERLAY_RECORD' is core generation $OVERLAY_GENERATION, this harness is generation $CORE_GENERATION — run update.sh to stage the migration, then /harness-migrate-overlay in a session" >&2
    exit 3
  fi
fi

# The overlay's REQUIRED artifact_root binds the <artifact-root> token in core prose (the
# Evidence-Store path where audit/council records live). Empty (or a template placeholder
# like `<fill this>`) -> the substitution below can't fill, and the fail-closed scan aborts
# the install (same contract as an unfilled slot).
# Bootstrap mode has no overlay to declare one; core prose still carries the token, so it binds
# to the target's own root provisionally. The Act-3 install (with the real overlay) rebinds it.
ARTIFACT_ROOT="$(manifest_key artifact_root)"
case "$ARTIFACT_ROOT" in '<'*'>') ARTIFACT_ROOT="" ;; esac
[ "$BOOTSTRAP" = 1 ] && ARTIFACT_ROOT="."

# --- profile + modules resolution: CLI > overlay manifest > default full ---
ALL_MODULES="inter-session multi-agent atlas statusline"
skill_module() { # <skill-name> -> module owning it, or ""
  case "$1" in
    inter-session)                        echo "inter-session" ;;
    parallel-workstreams|merge-and-cleanup) echo "multi-agent" ;;
    *)                                    echo "" ;;
  esac
}
[ -n "$PROFILE" ] || PROFILE="$(manifest_key profile)"
# Default: full for a normal install (back-compat); base for bootstrap (the onboarding
# interview turns modules on deliberately, and only after asking).
[ -n "$PROFILE" ] || { [ "$BOOTSTRAP" = 1 ] && PROFILE="base" || PROFILE="full"; }
case "$PROFILE" in base|full) ;; *) echo "error: --profile must be base or full (got: $PROFILE)" >&2; exit 2 ;; esac
ENABLED_MODULES=""
[ "$PROFILE" = "full" ] && ENABLED_MODULES="$ALL_MODULES"
MODULES_EXTRA="$(printf '%s %s' "$(manifest_key modules)" "$MODULES_CLI" | tr ',' ' ')"
for m in $MODULES_EXTRA; do
  [ -n "$m" ] || continue
  case " $ALL_MODULES " in
    *" $m "*) case " $ENABLED_MODULES " in *" $m "*) : ;; *) ENABLED_MODULES="$ENABLED_MODULES $m" ;; esac ;;
    *) echo "error: unknown module: $m (known: $ALL_MODULES)" >&2; exit 2 ;;
  esac
done
ENABLED_MODULES="$(printf '%s' "$ENABLED_MODULES" | sed -e 's/^ *//')"
module_enabled() { case " $ENABLED_MODULES " in *" $1 "*) return 0 ;; *) return 1 ;; esac }

# A staged file that will undergo <artifact-root> substitution cannot be a live symlink —
# writing the bound value would corrupt the harness source. Such files fall back to a real
# copy in --link mode, the same rule that already forces binding-bearing skills to copy.
file_has_artifact_token() { grep -Iq '<artifact-root>' "$1" 2>/dev/null; }

# Version: VERSION file is the single source of truth (ships in the public export, unlike
# CHANGELOG.md); the CHANGELOG grep remains as a fallback for older checkouts.
HARNESS_VERSION=""
[ -f "$HARNESS_ROOT/VERSION" ] && HARNESS_VERSION="$(head -1 "$HARNESS_ROOT/VERSION" | tr -d '[:space:]')"
[ -n "$HARNESS_VERSION" ] || HARNESS_VERSION="$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[A-Za-z0-9.-]*' "$HARNESS_ROOT/CHANGELOG.md" 2>/dev/null | head -1 || true)"
[ -n "$HARNESS_VERSION" ] || HARNESS_VERSION="unknown"

sha256_cmd() { if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$@"; else sha256sum "$@"; fi; }
sha256_of() { sha256_cmd "$1" | awk '{print $1}'; }

STAGE="$(mktemp -d "${TMPDIR:-/tmp}/manifold-install.XXXXXX")"
WORK="$(mktemp -d "${TMPDIR:-/tmp}/manifold-install-work.XXXXXX")"
cleanup() { rm -rf "$STAGE" "$WORK"; }
trap cleanup EXIT

# Records accumulate as "relpath|source|filemode|abs-source-file|binding-ref"; hashes are
# computed from the staged file after assembly (so appended bindings are hashed correctly).
# abs-source-file/binding-ref may be empty (assembled files). Bookkeeping lives in WORK,
# never in STAGE — the stage is tar'd into the target verbatim and must stay pure.
RECORDS="$WORK/records.tmp"
: > "$RECORDS"
record() { printf '%s|%s|%s|%s|%s\n' "$1" "$2" "$3" "${4:-}" "${5:-}" >> "$RECORDS"; }

stage_copy() { mkdir -p "$STAGE/$(dirname "$2")"; cp "$1" "$STAGE/$2"; }
stage_link() { mkdir -p "$STAGE/$(dirname "$2")"; ln -s "$1" "$STAGE/$2"; }

BINDING_SECTION=$'\n\n## Project bindings\n\n'

# --- skills: core/skills/* -> .claude/skills/*, append overlay skill-bindings to SKILL.md ---
# Skills owned by a module that is not enabled are skipped entirely.
if [ -d "$HARNESS_ROOT/core/skills" ]; then
  for skdir in "$HARNESS_ROOT/core/skills"/*/; do
    [ -d "$skdir" ] || continue
    sk="$(basename "$skdir")"
    skmod="$(skill_module "$sk")"
    if [ -n "$skmod" ] && ! module_enabled "$skmod"; then continue; fi
    binding="$OVERLAY_DIR/skill-bindings/$sk.md"
    while IFS= read -r f; do
      rel="${f#"$HARNESS_ROOT"/core/skills/}"      # e.g. alpha/SKILL.md
      destrel=".claude/skills/$rel"
      srcrel="core/skills/$rel"
      is_skillmd=0
      [ "$rel" = "$sk/SKILL.md" ] && is_skillmd=1
      if [ "$MODE" = link ] && ! { [ "$is_skillmd" = 1 ] && [ -f "$binding" ]; } && ! file_has_artifact_token "$f"; then
        stage_link "$f" "$destrel"; record "$destrel" "$srcrel" "link" "$f" ""
      else
        # copy path (always for copy mode; also for a linked skill that needs a binding
        # appended, since you cannot append to a symlink; also for any file carrying the
        # <artifact-root> token, which is bound in place after staging)
        stage_copy "$f" "$destrel"
        if [ "$is_skillmd" = 1 ] && [ -f "$binding" ]; then
          printf '%s' "$BINDING_SECTION" >> "$STAGE/$destrel"
          cat "$binding" >> "$STAGE/$destrel"
          record "$destrel" "$srcrel" "copy" "$f" "$OVERLAY_SRCREF/skill-bindings/$sk.md"
        else
          record "$destrel" "$srcrel" "copy" "$f" ""
        fi
      fi
    done < <(find "$skdir" -type f ! -path '*/__pycache__/*' ! -name '*.pyc')
  done
fi

# --- plain trees: copy (or link) every file under a core dir to a target prefix ---
# Optional 4th arg "skip_readme" drops any file named README.md (a directory placeholder /
# authoring doc that should not be installed into the target). Used for overlay trees.
# Python bytecode caches are excluded here and in the skills walk above: the harness ships
# runnable .py (inter-session), so running it writes __pycache__ INTO the harness clone, and
# a plain -type f walk would then install that build junk into every target.
copy_tree() { # <src-root> <dest-prefix> <source-prefix> [skip_readme]
  [ -d "$1" ] || return 0
  local f rel destrel srcrel skip="${4:-}"
  while IFS= read -r f; do
    [ "$skip" = skip_readme ] && [ "$(basename "$f")" = README.md ] && continue
    rel="${f#"$1"/}"
    destrel="$2/$rel"
    srcrel="$3/$rel"
    if [ "$MODE" = link ] && ! file_has_artifact_token "$f"; then stage_link "$f" "$destrel"; record "$destrel" "$srcrel" "link" "$f" ""
    else stage_copy "$f" "$destrel"; record "$destrel" "$srcrel" "copy" "$f" ""; fi
  done < <(find "$1" -type f ! -path '*/__pycache__/*' ! -name '*.pyc')
}
copy_tree "$HARNESS_ROOT/core/output-styles" ".claude/output-styles"  "core/output-styles"
copy_tree "$HARNESS_ROOT/core/templates"  ".claude/harness-templates" "core/templates"

# --- overlay trees: project rules + enforcement hooks ---
# Overlay rules merge into .claude/rules/ alongside core rules (README placeholders skipped);
# hooks install as DRAFT to .claude/harness-hooks/ and are NOT wired into settings.json
# (wiring is a documented manual step). The hooks README is NOT skipped: it is
# the operative wiring instruction (overlays/<name>/hooks/README.md documents the exact
# manual wiring), and dropping it stranded fresh installs without their setup doc.
copy_tree "$OVERLAY_DIR/rules"  ".claude/rules"          "$OVERLAY_SRCREF/rules"  skip_readme
copy_tree "$OVERLAY_DIR/hooks"  ".claude/harness-hooks"  "$OVERLAY_SRCREF/hooks"

# --- overlay project-only skills -> .claude/skills/ (alongside core skills). No overlay
# binding is appended: skill-bindings are for CORE skills; a project-only skill ships complete.
# README.md placeholders skipped; each file is manifest-recorded like every other copy. ---
copy_tree "$OVERLAY_DIR/skills" ".claude/skills"         "$OVERLAY_SRCREF/skills" skip_readme

# --- statusline module: the core script + helpers, plus any overlay statusline-local.sh
# beside them. The README is NOT skipped — like the hooks README it carries the manual
# wiring step (statusLine in settings.json), which no installer can perform. ---
if module_enabled statusline; then
  copy_tree "$HARNESS_ROOT/core/statusline" ".claude/statusline" "core/statusline"
  copy_tree "$OVERLAY_DIR/statusline"       ".claude/statusline" "$OVERLAY_SRCREF/statusline"
fi

# --- skill-binding support scripts -> .claude/harness-scripts/ (the installed location the
# appended bindings reference). Without this, a binding that invokes a watcher/detector script
# points at a path that doesn't exist in the target. README.md placeholders skipped. ---
copy_tree "$OVERLAY_DIR/skill-bindings/scripts" ".claude/harness-scripts" "$OVERLAY_SRCREF/skill-bindings/scripts" skip_readme

# --- agents: core/agents/*.md -> .claude/agents/, append overlay agent-bindings (same
# append mechanism as skill-bindings). README.md is an authoring doc, not installed.
# Overlay-only roles come from overlays/<name>/agents/ and ship complete (no binding). ---
if [ -d "$HARNESS_ROOT/core/agents" ]; then
  for f in "$HARNESS_ROOT/core/agents"/*.md; do
    [ -f "$f" ] || continue
    [ "$(basename "$f")" = README.md ] && continue
    ag="$(basename "$f" .md)"
    binding="$OVERLAY_DIR/agent-bindings/$ag.md"
    destrel=".claude/agents/$ag.md"
    srcrel="core/agents/$ag.md"
    if [ "$MODE" = link ] && [ ! -f "$binding" ] && ! file_has_artifact_token "$f"; then
      stage_link "$f" "$destrel"; record "$destrel" "$srcrel" "link" "$f" ""
    else
      stage_copy "$f" "$destrel"
      if [ -f "$binding" ]; then
        printf '%s' "$BINDING_SECTION" >> "$STAGE/$destrel"
        cat "$binding" >> "$STAGE/$destrel"
        record "$destrel" "$srcrel" "copy" "$f" "$OVERLAY_SRCREF/agent-bindings/$ag.md"
      else
        record "$destrel" "$srcrel" "copy" "$f" ""
      fi
    fi
  done
fi
copy_tree "$OVERLAY_DIR/agents" ".claude/agents" "$OVERLAY_SRCREF/agents" skip_readme

# --- METHODOLOGY.md + ENFORCEMENT.md + SUCCESSOR_CALIBRATION.md -> .claude/harness/
# (token-bearing ones copy, not link) ---
for base in METHODOLOGY.md ENFORCEMENT.md SUCCESSOR_CALIBRATION.md; do
  src="$HARNESS_ROOT/core/$base"
  [ -f "$src" ] || continue
  if [ "$MODE" = link ] && ! file_has_artifact_token "$src"; then stage_link "$src" ".claude/harness/$base"; record ".claude/harness/$base" "core/$base" "link" "$src" ""
  else stage_copy "$src" ".claude/harness/$base"; record ".claude/harness/$base" "core/$base" "copy" "$src" ""; fi
done

# --- FIELD_GUIDE.md (repo root) -> .claude/harness/ so it ships with an installed project ---
if [ -f "$HARNESS_ROOT/FIELD_GUIDE.md" ]; then
  if [ "$MODE" = link ] && ! file_has_artifact_token "$HARNESS_ROOT/FIELD_GUIDE.md"; then stage_link "$HARNESS_ROOT/FIELD_GUIDE.md" ".claude/harness/FIELD_GUIDE.md"; record ".claude/harness/FIELD_GUIDE.md" "FIELD_GUIDE.md" "link" "$HARNESS_ROOT/FIELD_GUIDE.md" ""
  else stage_copy "$HARNESS_ROOT/FIELD_GUIDE.md" ".claude/harness/FIELD_GUIDE.md"; record ".claude/harness/FIELD_GUIDE.md" "FIELD_GUIDE.md" "copy" "$HARNESS_ROOT/FIELD_GUIDE.md" ""; fi
fi

# --- bootstrap kit: the onboarding skill + the PENDING marker; no constitution ---
if [ "$BOOTSTRAP" = 1 ]; then
  copy_tree "$HARNESS_ROOT/bootstrap/skills/harness-onboarding" ".claude/skills/harness-onboarding" "bootstrap/skills/harness-onboarding"
  mkdir -p "$STAGE/.claude"
  {
    echo "# Manifold onboarding is not finished yet. Open a Claude Code session in this repo"
    echo "# and run /harness-onboarding. That skill writes the overlay, re-installs, and"
    echo "# removes this file. doctor.sh warns while it exists."
    echo "harness_root: $HARNESS_ROOT"
  } > "$STAGE/.claude/manifold-onboarding-pending"
  record ".claude/manifold-onboarding-pending" "generated" "copy" "" ""
fi

# --- assemble CLAUDE.harness.md (always a real file; slots substituted literally) ---
if [ "$BOOTSTRAP" = 0 ]; then
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
# Strip authoring-only scaffold comments from the ASSEMBLED file (they cost ~1.3k always-on
# tokens per session and serve only scaffold authors): the header block ("Constitution
# scaffold...") is dropped; each "<!-- SLOT name: description -->" reduces to the bare
# boundary marker "<!-- SLOT name -->" (the marker is load-bearing — it is what lets a
# maintainer back-port live edits to the right slot source). Any other comment — including
# ones inside slot CONTENT — passes through untouched. Source scaffold keeps the full text.
# The trailing awk drops the blank lines the stripped header leaves behind, so the assembled
# file opens on its first heading.
scaffold="$(printf '%s\n' "$scaffold" | awk '
  function emit(b, name) {
    b = buf; sub(/^[[:space:]]*<!--[[:space:]]*/, "", b)
    if (b ~ /^SLOT[[:space:]]/) {
      name = b; sub(/^SLOT[[:space:]]+/, "", name); sub(/[:[:space:]].*/, "", name)
      print "<!-- SLOT " name " -->"
    } else if (b ~ /^Constitution scaffold/) { }
    else print buf
  }
  {
    if (!inc) {
      if ($0 ~ /^[[:space:]]*<!--/) {
        buf = $0; inc = 1
        if ($0 ~ /-->/) { inc = 0; emit() }
        next
      }
      print; next
    }
    buf = buf "\n" $0
    if ($0 ~ /-->/) { inc = 0; emit() }
  }' | awk 'seen || NF { seen = 1; print }')"
printf '%s\n' "$scaffold" > "$STAGE/CLAUDE.harness.md"
record "CLAUDE.harness.md" "assembled" "copy" "" ""
fi

# --- fail closed: any surviving placeholder means an unfilled slot ---
if grep -RIl '{{HARNESS:' "$STAGE" >/dev/null 2>&1; then
  echo "INSTALL FAILED: unfilled slot(s) — nothing written to $TARGET" >&2
  grep -RIn '{{HARNESS:' "$STAGE" 2>/dev/null | sed "s#$STAGE/##" >&2 || true
  exit 1
fi

# --- fail closed: unfilled template sentinels. A slot file that is still the template's
# `<!-- FILL ... -->` placeholder substitutes CLEANLY (the token is consumed), producing a
# syntactically-valid constitution with no identity, security posture, or memory paths —
# exactly the "half-configured harness" the fail-closed contract promises cannot exist.
# --allow-placeholder-template exists for installer smoke tests ONLY. ---
if [ "$ALLOW_PLACEHOLDER" != 1 ]; then
  if grep -RIl -- '<!-- FILL' "$STAGE" >/dev/null 2>&1; then
    echo "INSTALL FAILED: unfilled template sentinel(s) ('<!-- FILL') — fill the overlay's claude-slots, or pass --allow-placeholder-template for a smoke test — nothing written to $TARGET" >&2
    grep -RIn -- '<!-- FILL' "$STAGE" 2>/dev/null | sed "s#$STAGE/##" | head -20 >&2 || true
    exit 1
  fi
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

# --- write the manifest (hashes computed from staged files; recipe fields for doctor) ---
mkdir -p "$STAGE/.claude"
MANIFEST="$STAGE/.claude/manifold-manifest.yaml"
{
  echo "# Manifold install manifest. To update this install: run bootstrap/update.sh from the"
  echo "# harness clone (harness_repo below) — it re-reads this file and reconstructs the install."
  echo "harness_version: $HARNESS_VERSION"
  echo "core_generation: $CORE_GENERATION"
  echo "harness_repo: $HARNESS_ROOT"
  if [ "$BOOTSTRAP" = 1 ]; then echo "mode: bootstrap"; else echo "mode: $MODE"; fi
  echo "overlay: $OVERLAY_RECORD"
  echo "profile: $PROFILE"
  echo "modules: ${ENABLED_MODULES:-none}"
  echo "artifact_root: $ARTIFACT_ROOT"
  echo "generated_at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "files:"
  while IFS='|' read -r rel src fmode srcfile bindingref; do
    [ -n "$rel" ] || continue
    echo "  - path: $rel"
    echo "    sha256: $(sha256_of "$STAGE/$rel")"
    echo "    source: $src"
    echo "    mode: $fmode"
    if [ -n "$srcfile" ] && [ -f "$srcfile" ]; then
      echo "    source_sha256: $(sha256_of "$srcfile")"
    fi
    if [ -n "$bindingref" ]; then
      bindingabs="$bindingref"
      case "$bindingabs" in /*) : ;; *) bindingabs="$HARNESS_ROOT/$bindingabs" ;; esac
      echo "    binding: $bindingref"
      [ -f "$bindingabs" ] && echo "    binding_sha256: $(sha256_of "$bindingabs")"
    fi
  done < "$RECORDS"
} > "$MANIFEST"

# --- upgrade reconciliation vs the PRIOR manifest (if any) -----------------------------------
# 1. CONFLICT CHECK (before anything is written): a managed file that was locally edited
#    since the prior install, which this install would overwrite with different content,
#    aborts unless --overwrite-local. Local edits belong in the harness source — sync them
#    back first (that is exactly how a live fix gets preserved instead of clobbered).
# 2. PRUNE LIST: files owned by the prior manifest that are absent from the new stage are
#    deleted after extraction (only if unmodified since install — a locally-edited orphan
#    is kept with a warning). Without this, retired skills/rules stay active forever.
OLD_MANIFEST="$TARGET/.claude/manifold-manifest.yaml"
OLDLIST="$WORK/oldlist.tmp"
NEWPATHS="$WORK/newpaths.tmp"
: > "$OLDLIST"; : > "$NEWPATHS"
cut -d'|' -f1 "$RECORDS" > "$NEWPATHS"
if [ -f "$OLD_MANIFEST" ]; then
  P=""; S=""; M=""
  flush_old() { [ -n "$P" ] || return 0; printf '%s|%s|%s\n' "$P" "$S" "$M" >> "$OLDLIST"; }
  while IFS= read -r line; do
    case "$line" in
      "  - path: "*)   flush_old; P="${line#  - path: }"; S=""; M="" ;;
      "    sha256: "*) S="${line#    sha256: }" ;;
      "    mode: "*)   M="${line#    mode: }" ;;
    esac
  done < "$OLD_MANIFEST"
  flush_old

  CONFLICTS=""
  while IFS='|' read -r opath osha omode; do
    [ -n "$opath" ] || continue
    grep -qxF "$opath" "$NEWPATHS" || continue          # only files the new stage will overwrite
    tfile="$TARGET/$opath"
    [ -f "$tfile" ] || continue
    [ -L "$tfile" ] && continue                          # links live-track; nothing to clobber
    [ "$omode" = "copy" ] || continue
    [ -n "$osha" ] || continue
    thash="$(sha256_of "$tfile")"
    [ "$thash" = "$osha" ] && continue                   # unmodified since install — safe
    nhash="$(sha256_of "$STAGE/$opath" 2>/dev/null || true)"
    [ "$thash" = "$nhash" ] && continue                  # already hand-converged to the new content
    CONFLICTS="$CONFLICTS$opath"$'\n'
  done < "$OLDLIST"
  if [ -n "$CONFLICTS" ] && [ "$OVERWRITE_LOCAL" != 1 ]; then
    echo "INSTALL ABORTED: locally-edited managed file(s) would be overwritten — sync the edits back to the harness source (or pass --overwrite-local to discard them). Nothing written." >&2
    printf '%s' "$CONFLICTS" | sed 's/^/  LOCAL EDIT: /' >&2
    exit 1
  fi
  [ -n "$CONFLICTS" ] && printf '%s' "$CONFLICTS" | sed 's/^/  overwriting local edit (--overwrite-local): /' >&2
fi

# --- commit staging into the target (tar preserves symlinks and merges into .claude) ---
# NB: extraction failure must abort loudly (set -e + pipefail) — never print INSTALL OK
# after a failed write. Count is computed separately so it can't mask a tar failure.
tar -C "$STAGE" -cf - . | tar -C "$TARGET" -xf -

# --- prune: prior-manifest files absent from the new stage ---
PRUNED=0
if [ -s "$OLDLIST" ]; then
  while IFS='|' read -r opath osha omode; do
    [ -n "$opath" ] || continue
    grep -qxF "$opath" "$NEWPATHS" && continue           # still managed
    tfile="$TARGET/$opath"
    [ -e "$tfile" ] || [ -L "$tfile" ] || continue
    if [ -L "$tfile" ]; then
      rm -f "$tfile"; echo "  pruned (retired link): $opath"; PRUNED=$((PRUNED+1))
    elif [ -n "$osha" ] && [ "$(sha256_of "$tfile")" = "$osha" ]; then
      rm -f "$tfile"; echo "  pruned (retired, unmodified): $opath"; PRUNED=$((PRUNED+1))
    else
      echo "  WARN kept (retired from harness but locally edited): $opath" >&2
    fi
  done < "$OLDLIST"
  # sweep now-empty managed dirs, best-effort. A dir whose only survivor is a stray .DS_Store
  # is empty in substance: drop the stray so the chain collapses with it, or a retired skill
  # dir lingers as a husk and doctor then reports its SKILL.md MISSING.
  sweeps=0
  while [ "$sweeps" -lt 8 ]; do
    sweeps=$((sweeps+1)); dropped=0
    find "$TARGET/.claude" -type d -empty -delete 2>/dev/null || true
    while IFS= read -r d; do
      [ -n "$d" ] || continue
      if [ "$(ls -A "$d" 2>/dev/null)" = ".DS_Store" ]; then
        rm -f "$d/.DS_Store"; dropped=1
      fi
    done < <(find "$TARGET/.claude" -type d 2>/dev/null)
    [ "$dropped" = 1 ] || break
  done
fi

n_files="$(grep -c '  - path: ' "$MANIFEST" 2>/dev/null || true)"
if [ "$BOOTSTRAP" = 1 ]; then
  echo "INSTALL OK (bootstrap): harness $HARNESS_VERSION, no overlay yet, profile $PROFILE (modules: ${ENABLED_MODULES:-none})"
else
  echo "INSTALL OK: harness $HARNESS_VERSION, overlay '$OVERLAY_RECORD', mode $MODE, profile $PROFILE (modules: ${ENABLED_MODULES:-none})"
fi
echo "  target:   $TARGET"
echo "  manifest: $TARGET/.claude/manifold-manifest.yaml ($n_files files)"
[ "$PRUNED" -gt 0 ] && echo "  pruned:   $PRUNED retired file(s)"
if [ "$BOOTSTRAP" = 1 ]; then
  echo "  NEXT:     open a Claude Code session in $TARGET and run /harness-onboarding"
  echo "            (it interviews you, writes your overlay, and finishes the install)"
else
  echo "  note:     $TARGET/CLAUDE.harness.md is NOT auto-included — see bootstrap/INSTALL.md"
fi
