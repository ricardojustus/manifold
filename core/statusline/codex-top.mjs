#!/usr/bin/env node
// codex-top.mjs — a live board of every Codex job across all worktrees, with drill-in.
// Answers at a glance: are Codex jobs working? how many? which TRACK? what doing? done?
// Press Enter on a job to watch its FULL live transcript scroll; Esc to return.
//
// Data source (read-only): the codex plugin's own on-disk job store —
//   <config-dir>/plugins/data/codex-openai-codex/state/<worktree>/state.json  (job registry)
//   .../<worktree>/jobs/<id>.log                                              (live progress)
// Track attribution: jobs only record the dispatching Claude sessionId; the statusline writes
//   <config-dir>/session-tracks/<session_id> = <track> each render, and we join jobs to tracks on it.
// No network, no API calls, no writes.
//
// Usage:  codex-top                       live board (Enter=drill in, Esc=back, q=quit)
//         codex-top --once                render one board frame and exit (scripting/verify)
//         codex-top --once --detail KEY   render one detail frame for "<worktree>|<jobid>" (verify)
import fs from "node:fs";
import path from "node:path";
import os from "node:os";

const argv = process.argv.slice(2);
const ONCE = argv.includes("--once") || process.env.CODEX_TOP_ONCE === "1";
const DETAIL_ARG = (() => { const i = argv.indexOf("--detail"); return i >= 0 ? argv[i + 1] : null; })();
const REFRESH_MS = 1500;
const RECENT_MS = 2 * 3600 * 1000; // show finished jobs from the last 2h
const RECENT_CAP = 15;

// One config dir per login: the default ~/.claude plus any ~/.claude-* siblings a
// multi-account setup uses. Scanning all of them is what makes the board cross-account.
const CONFIG_DIRS = (() => {
  const home = os.homedir();
  const dirs = new Set([process.env.CLAUDE_CONFIG_DIR, path.join(home, ".claude")].filter(Boolean));
  try {
    for (const d of fs.readdirSync(home)) if (d.startsWith(".claude-")) dirs.add(path.join(home, d));
  } catch { /* ignore */ }
  return [...dirs];
})();

const E = "\x1b[";
const C = {
  reset: E + "0m", dim: E + "2m", bold: E + "1m", rev: E + "7m",
  green: E + "32m", yellow: E + "33m", red: E + "31m", cyan: E + "36m", gray: E + "90m", mag: E + "35m",
};

// ---- state ----
let view = "board";        // "board" | "detail"
let selectedKey = null;    // highlighted job on the board ("<worktree>|<id>")
let detailKey = null;      // job being watched in detail
let currentRows = [];      // jobs currently shown on the board (for navigation)

const jobKey = (j) => j.worktree + "|" + j.id;

// ---- data ----
function loadTrackMap() {
  const map = {};
  for (const cd of CONFIG_DIRS) {
    const dir = path.join(cd, "session-tracks");
    try {
      for (const f of fs.readdirSync(dir)) {
        try { map[f] = fs.readFileSync(path.join(dir, f), "utf8").trim(); } catch { /* ignore */ }
      }
    } catch { /* ignore */ }
  }
  return map;
}

function readAllJobs() {
  const seen = new Set();
  const jobs = [];
  for (const cd of CONFIG_DIRS) {
    const root = path.join(cd, "plugins/data/codex-openai-codex/state");
    let dirs;
    try { dirs = fs.readdirSync(root); } catch { continue; }
    for (const wt of dirs) {
      const dir = path.join(root, wt);
      let s;
      try { s = JSON.parse(fs.readFileSync(path.join(dir, "state.json"), "utf8")); } catch { continue; }
      const wtName = wt.replace(/-[0-9a-f]{16}$/, "");
      for (const j of s.jobs || []) {
        const key = wtName + "|" + j.id;
        if (seen.has(key)) continue;
        seen.add(key);
        jobs.push({ ...j, worktree: wtName, jobsDir: path.join(dir, "jobs") });
      }
    }
  }
  return jobs;
}

function readLogTail(job, maxLines) {
  try {
    const file = path.join(job.jobsDir, job.id + ".log");
    const fd = fs.openSync(file, "r");
    const size = fs.fstatSync(fd).size;
    const len = Math.min(65536, size);
    const buf = Buffer.alloc(len);
    fs.readSync(fd, buf, 0, len, size - len);
    fs.closeSync(fd);
    let lines = buf.toString("utf8").split("\n");
    if (len < size) lines = lines.slice(1); // drop partial leading line
    lines = lines.filter((l) => l.trim().length);
    return lines.slice(-Math.max(1, maxLines));
  } catch { return ["(no log output yet)"]; }
}

function lastLogAction(job) {
  const lines = readLogTail(job, 1);
  const l = lines[lines.length - 1] || "";
  return l.replace(/^\[[^\]]+\]\s*/, "").trim();
}

function elapsed(job) {
  const start = job.startedAt ? Date.parse(job.startedAt) : (job.createdAt ? Date.parse(job.createdAt) : 0);
  if (!start) return "—";
  const live = job.status === "running" || job.status === "queued";
  const end = live ? Date.now() : (job.completedAt ? Date.parse(job.completedAt) : Date.now());
  let s = Math.max(0, Math.round((end - start) / 1000));
  if (s < 60) return s + "s";
  const m = Math.floor(s / 60); s = s % 60;
  if (m < 60) return m + "m" + (s ? s + "s" : "");
  const h = Math.floor(m / 60);
  return h + "h" + (m % 60) + "m";
}

const RANK = { running: 0, queued: 1, completed: 2, failed: 2 };
function byPriority(a, b) {
  const ra = RANK[a.status] ?? 3, rb = RANK[b.status] ?? 3;
  if (ra !== rb) return ra - rb;
  return String(b.updatedAt || "").localeCompare(String(a.updatedAt || ""));
}

function statusCell(status) {
  const map = {
    running:   [C.yellow, "● running"], queued: [C.gray, "○ queued "],
    completed: [C.green,  "✓ done   "], failed: [C.red,  "✗ failed "],
  };
  const [col, label] = map[status] || [C.reset, (status + "         ").slice(0, 9)];
  return col + label + C.reset;
}
function statusWord(status) {
  const map = { running: C.yellow + "running", queued: C.gray + "queued", completed: C.green + "done", failed: C.red + "failed" };
  return (map[status] || status) + C.reset;
}

function pad(s, n) {
  s = String(s ?? "");
  if (s.length > n) return n > 1 ? s.slice(0, n - 1) + "…" : s.slice(0, n);
  return s + " ".repeat(n - s.length);
}

// ---- board view ----
function buildBoard() {
  const tracks = loadTrackMap();
  const all = readAllJobs();
  const running = all.filter((j) => j.status === "running").sort(byPriority);
  const queued  = all.filter((j) => j.status === "queued").sort(byPriority);
  const cutoff = Date.now() - RECENT_MS;
  const finished = all
    .filter((j) => (j.status === "completed" || j.status === "failed") && Date.parse(j.updatedAt || j.completedAt || 0) >= cutoff)
    .sort(byPriority).slice(0, RECENT_CAP);
  const doneN = finished.filter((j) => j.status === "completed").length;
  const failN = finished.filter((j) => j.status === "failed").length;
  currentRows = [...running, ...queued, ...finished];
  if (!currentRows.find((j) => jobKey(j) === selectedKey)) selectedKey = currentRows.length ? jobKey(currentRows[0]) : null;

  const cols = process.stdout.columns || 130;
  const wStatus = 9, wTrack = 11, wWt = 18, wElapsed = 8;
  const wDoing = Math.max(16, cols - (2 + wStatus + 1 + wTrack + 1 + wWt + 1 + wElapsed + 1) - 1);

  const now = new Date().toLocaleTimeString();
  const out = [];
  out.push(
    `${C.bold}${C.cyan}Codex${C.reset}  ${C.yellow}${running.length} running${C.reset} · ${queued.length} queued` +
    ` · ${C.green}${doneN} done${C.reset}${failN ? ` · ${C.red}${failN} failed${C.reset}` : ""} ${C.dim}(last 2h)${C.reset}   ${C.dim}${now}${C.reset}`
  );
  out.push(
    "  " + C.dim + pad("STATUS", wStatus) + " " + pad("TRACK", wTrack) + " " + pad("WORKTREE", wWt) +
    " " + pad("DOING", wDoing) + " " + pad("ELAPSED", wElapsed) + C.reset
  );
  if (currentRows.length === 0) out.push("  " + C.dim + "no Codex jobs right now — waiting…" + C.reset);
  for (const j of currentRows) {
    const sel = jobKey(j) === selectedKey;
    const track = tracks[j.sessionId];
    const marker = sel ? C.bold + C.cyan + "› " + C.reset : "  ";
    let doing;
    if (j.status === "running") {
      doing = (j.phase ? j.phase + " · " : "") + lastLogAction(j).replace(/^(Running command:|Command completed:)\s*/, "");
    } else if (j.status === "failed") {
      doing = j.errorMessage ? "failed: " + j.errorMessage : (j.phase || "failed");
    } else { doing = j.summary || j.phase || "done"; }
    let row = statusCell(j.status) + " " +
      (track ? C.cyan : C.dim) + pad(track || "—", wTrack) + C.reset + " " +
      pad(j.worktree, wWt) + " " + C.dim + pad(doing, wDoing) + C.reset + " " + pad(elapsed(j), wElapsed);
    out.push(marker + row);
  }
  if (!ONCE) {
    out.push("");
    out.push(C.dim + "↑/↓ select · Enter watch job · q quit" + C.reset);
  }
  return out.join("\n");
}

// ---- detail view ----
function colorLogLine(line, cols) {
  const m = line.match(/^\[([^\]]+)\]\s*(.*)$/);
  let time = "", msg = line;
  if (m) { time = (m[1].length >= 19 ? m[1].slice(11, 19) : m[1]); msg = m[2]; }
  let col = C.reset;
  if (/^Running command:/.test(msg)) col = C.cyan;
  else if (/^Command completed:/.test(msg)) col = /\(exit 0\)/.test(msg) ? C.green : C.red;
  else if (/^Applying/.test(msg)) col = C.yellow;
  else if (/^Searching:/.test(msg)) col = C.mag;
  else if (/^(Reviewer|Calling)/.test(msg)) col = C.cyan;
  else if (/^Assistant message captured:/.test(msg)) col = C.gray;
  else if (/^(Thread|Turn|Starting|Queued|Resuming|Final output)/.test(msg)) col = C.gray;
  const timeStr = time ? C.dim + time + " " + C.reset : "";
  const avail = Math.max(8, cols - (time ? 9 : 0));
  if (msg.length > avail) msg = msg.slice(0, avail - 1) + "…";
  return timeStr + col + msg + C.reset;
}

function buildDetail() {
  const all = readAllJobs();
  const job = all.find((j) => jobKey(j) === detailKey);
  const cols = process.stdout.columns || 130;
  const rows = process.stdout.rows || 40;
  if (!job) {
    return `${C.dim}◀ Esc back${C.reset}\n\n  ${C.red}job no longer in the store (pruned or session ended)${C.reset}`;
  }
  const track = loadTrackMap()[job.sessionId] || "—";
  const out = [];
  out.push(
    `${C.dim}◀ Esc${C.reset}  ${C.bold}${C.cyan}${track}${C.reset} ${C.dim}·${C.reset} ${job.worktree} ${C.dim}·${C.reset} ` +
    `${statusWord(job.status)}${job.phase ? C.dim + " (" + job.phase + ")" + C.reset : ""} ${C.dim}·${C.reset} ${elapsed(job)}   ${C.dim}${job.id}${C.reset}`
  );
  out.push(C.dim + "─".repeat(Math.min(cols, 140)) + C.reset);
  const bodyLines = Math.max(4, rows - 5);
  for (const l of readLogTail(job, bodyLines)) out.push(colorLogLine(l, cols));
  out.push("");
  out.push(C.dim + `Esc back · q quit · live tail (${REFRESH_MS / 1000}s)` + C.reset);
  return out.join("\n");
}

// ---- paint / loop ----
function frame() { return view === "detail" ? buildDetail() : buildBoard(); }
function paint() {
  try { process.stdout.write(E + "H" + E + "J" + frame() + "\n"); }
  catch (e) { process.stdout.write("codex-top error: " + e.message + "\n"); }
}

function moveSel(d) {
  if (!currentRows.length) return;
  let i = currentRows.findIndex((j) => jobKey(j) === selectedKey);
  if (i < 0) i = 0;
  i = Math.max(0, Math.min(currentRows.length - 1, i + d));
  selectedKey = jobKey(currentRows[i]);
}
function enterDetail() {
  if (selectedKey && currentRows.find((j) => jobKey(j) === selectedKey)) { detailKey = selectedKey; view = "detail"; }
}

const restore = () => { try { process.stdout.write(E + "?25h"); } catch {} };
function quit() {
  restore();
  if (process.stdin.isTTY) { try { process.stdin.setRawMode(false); } catch {} }
  process.stdout.write("\n");
  process.exit(0);
}
function onKey(s) {
  if (s === "\x03" || s === "q") return quit();
  if (view === "board") {
    if (s === "\x1b[A" || s === "k") moveSel(-1);
    else if (s === "\x1b[B" || s === "j") moveSel(1);
    else if (s === "\r" || s === "\n" || s === "\x1b[C" || s === "l") enterDetail();
    else return;
  } else {
    if (s === "\x1b" || s === "\x1b[D" || s === "h") view = "board";
    else return;
  }
  paint();
}

// ---- entry ----
if (ONCE) {
  if (DETAIL_ARG) { detailKey = DETAIL_ARG; view = "detail"; process.stdout.write(buildDetail() + "\n"); }
  else process.stdout.write(buildBoard() + "\n");
  process.exit(0);
}

process.stdout.write(E + "?25l"); // hide cursor
process.on("exit", restore);
process.on("SIGINT", quit);
if (process.stdin.isTTY) {
  process.stdin.setRawMode(true);
  process.stdin.resume();
  process.stdin.setEncoding("utf8");
  process.stdin.on("data", onKey);
}
paint();
setInterval(paint, REFRESH_MS);
