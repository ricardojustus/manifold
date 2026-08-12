#!/usr/bin/env node
// codex-jobs-tally.mjs — compact per-SESSION Codex-job summary for the Claude Code statusline.
// Usage: node codex-jobs-tally.mjs <claude_session_id>
// Prints a compact segment (e.g. "Cdx 2>run editing,verifying · 3 done · 1 fail") for the Codex
// jobs THIS Claude session dispatched, or NOTHING when the session has no Codex jobs. Fail-quiet:
// any error prints nothing and exits 0, so it can never break the host statusline.
//
// Scoping: every Codex job records `sessionId` == the dispatching Claude session id (the plugin's
// SessionStart hook stamps input.session_id). The statusline receives that same session_id on
// stdin, so matching job.sessionId === session_id shows exactly this track/session's jobs.
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const ESC = String.fromCharCode(27);
const RED = `${ESC}[31m`;
const GREEN = `${ESC}[32m`;
const YELLOW = `${ESC}[33m`;
const DIM = `${ESC}[2m`;
const RESET = `${ESC}[0m`;

try {
  const sid = process.argv[2];
  if (!sid) process.exit(0);

  // The codex plugin's on-disk job store lives under the active config dir's plugin data.
  const base = process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), ".claude");
  const root = path.join(base, "plugins", "data", "codex-openai-codex", "state");
  if (!fs.existsSync(root)) process.exit(0);

  const t = { running: 0, queued: 0, completed: 0, failed: 0 };
  const phases = [];
  for (const wt of fs.readdirSync(root)) {
    const f = path.join(root, wt, "state.json");
    let s;
    try { s = JSON.parse(fs.readFileSync(f, "utf8")); } catch { continue; }
    for (const j of s.jobs || []) {
      if (j.sessionId !== sid) continue;
      if (t[j.status] !== undefined) t[j.status] += 1;
      if (j.status === "running" && j.phase) phases.push(j.phase);
    }
  }

  const total = t.running + t.queued + t.completed + t.failed;
  if (total === 0) process.exit(0);

  const parts = [];
  if (t.running) {
    let seg = `${YELLOW}${t.running}▶${RESET}`; // ▶ busy
    const uniq = [...new Set(phases)].filter(Boolean).slice(0, 3);
    if (uniq.length) seg += ` ${DIM}${uniq.join(",")}${RESET}`;
    parts.push(seg);
  }
  if (t.queued) parts.push(`${t.queued}⏳`); // ⏳ queued
  if (t.completed) parts.push(`${GREEN}${t.completed}✓${RESET}`); // ✓ done
  if (t.failed) parts.push(`${RED}${t.failed}✗${RESET}`); // ✗ failed

  process.stdout.write(`${DIM}Cdx${RESET} ${parts.join(` ${DIM}·${RESET} `)}`);
} catch {
  process.exit(0);
}
