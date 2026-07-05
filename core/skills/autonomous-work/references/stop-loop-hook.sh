#!/usr/bin/env bash
# stop-loop-hook.sh — OPTIONAL Stop-hook for the autonomous-work completion-promise loop.
# Pattern adapted from anthropics/claude-code plugins/ralph-wiggum (MIT), rewritten for this
# harness (never wired globally; fail-SAFE; explicit max-iterations + cancel path).
#
# WHAT IT DOES. When ARMED, it intercepts the session's attempt to end its turn (the Stop
# event) and re-injects the task prompt until the session's last message contains an exact
# completion phrase OR a max-iteration cap is hit. This is the ralph-wiggum loop mechanism as a
# dependency-free hardening of an unattended run — it complements, never replaces, the wakeup
# heartbeat + watcher discipline in autonomous-work/SKILL.md.
#
# ARMING (the hook is a NO-OP until all of this exists). It reads a state directory:
#   $STOP_LOOP_DIR  (else  $CLAUDE_PROJECT_DIR/.claude/stop-loop  else  <cwd>/.claude/stop-loop)
#     prompt.txt  (required) — the task prompt to re-inject on each loop
#     promise     (required) — the exact completion phrase; when it appears in the last
#                              assistant message, the loop ends and the stop is allowed
#     max         (optional) — integer max iterations (default 20)
#     count       (managed)  — the hook creates/increments this; delete it to reset
#     cancel      (optional) — if this file exists, the loop ends immediately (allow stop)
#   If prompt.txt or promise is missing, the hook allows the stop and does nothing. This is the
#   safety property that makes it safe to leave wired: unarmed == inert. NEVER arm it for an
#   interactive session — it would fight normal conversation.
#
# CONTRACT. A Stop hook blocks the stop (forces continuation) by emitting
# {"decision":"block","reason":...} on exit 0; emitting nothing allows the stop. This hook
# FAILS SAFE: on ANY error (bad JSON, unreadable transcript, python3 missing, un-persistable
# counter) it emits nothing and exits 0 — allowing the stop. It must NEVER block on an error,
# because a block it cannot later clear is an infinite loop. (No `set -e`: a stray nonzero must
# not change the exit path.)

PAYLOAD="$(cat)"

DECISION="$(printf '%s' "$PAYLOAD" | python3 -c '
import json,sys,os
try:
    payload=json.loads(sys.stdin.read())
except Exception:
    sys.exit(0)  # unparseable Stop payload -> fail safe, allow stop
d=os.environ.get("STOP_LOOP_DIR","")
if not d:
    base=os.environ.get("CLAUDE_PROJECT_DIR","") or (payload.get("cwd","") if isinstance(payload,dict) else "") or "."
    d=os.path.join(base,".claude","stop-loop")
try:
    with open(os.path.join(d,"prompt.txt")) as f: prompt=f.read()
    with open(os.path.join(d,"promise")) as f: promise=f.read().strip()
except Exception:
    sys.exit(0)  # not armed -> inert no-op, allow stop
if not promise or not prompt.strip():
    sys.exit(0)
if os.path.exists(os.path.join(d,"cancel")):
    sys.exit(0)  # cancelled -> allow stop
maxn=20
try:
    with open(os.path.join(d,"max")) as f: maxn=int(f.read().strip())
except Exception:
    maxn=20
last=""
try:
    with open(payload.get("transcript_path","")) as f:
        for line in f:
            line=line.strip()
            if not line: continue
            try: ev=json.loads(line)
            except Exception: continue
            if not isinstance(ev,dict): continue
            msg=ev.get("message") if isinstance(ev.get("message"),dict) else None
            role=msg.get("role","") if msg else ""
            if role!="assistant" and ev.get("type")!="assistant": continue
            content=msg.get("content") if msg else None
            if isinstance(content,str):
                if content: last=content
            elif isinstance(content,list):
                parts=[c.get("text","") for c in content if isinstance(c,dict) and c.get("type")=="text"]
                joined="".join(parts)
                if joined: last=joined
except Exception:
    sys.exit(0)  # cannot read transcript -> fail safe, allow stop
if promise in last:
    sys.exit(0)  # completion phrase emitted -> done, allow stop
cp=os.path.join(d,"count")
n=0
try:
    with open(cp) as f: n=int(f.read().strip())
except Exception:
    n=0
if n>=maxn:
    sys.stderr.write("stop-loop: max iterations ("+str(maxn)+") reached; allowing stop.\n")
    sys.exit(0)
n+=1
try:
    with open(cp,"w") as f: f.write(str(n))
except Exception:
    sys.exit(0)  # cannot persist counter -> do NOT block (would loop forever) -> fail safe
reason=prompt.rstrip()+"\n\n[stop-loop iteration "+str(n)+"/"+str(maxn)+": continue the task until you emit the exact completion phrase, then stop.]"
sys.stdout.write(json.dumps({"decision":"block","reason":reason}))
sys.exit(0)
' 2>/dev/null)"

# FAIL SAFE: empty decision (success, unarmed, cancelled, exhausted, or any error) -> allow stop.
if [ -n "$DECISION" ]; then
  printf '%s' "$DECISION"
fi
exit 0
