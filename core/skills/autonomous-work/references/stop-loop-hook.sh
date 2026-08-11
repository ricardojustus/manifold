#!/usr/bin/env bash
# stop-loop-hook.sh — OPTIONAL Stop-hook for the autonomous-work completion-promise loop.
# Pattern adapted from anthropics/claude-code plugins/ralph-wiggum (MIT).
#
# Mechanism, arming contract (the $STOP_LOOP_DIR state files), guardrails, and wiring:
# autonomous-work/references/completion-promise-loop.md. Inert until armed.
# Blocks a stop only by emitting {"decision":"block","reason":...} on exit 0; FAILS SAFE — on ANY
# error it emits nothing and exits 0, allowing the stop (a block it cannot clear is an infinite
# loop). (No `set -e`: a stray nonzero must not change the exit path.)

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
