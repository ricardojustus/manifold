# Statusline (optional module)

A Claude Code status bar showing, per session: tmux session name · directory · model and
reasoning effort · context tokens and a usage bar · 5-hour and weekly rate limits · the
logged-in account · a live tally of the Codex jobs this session dispatched.

Installed to `.claude/statusline/` when the `statusline` module is enabled.

## Wiring (manual, one time)

Claude Code does not pick the script up on its own — point the `statusLine` setting at it, in
either `.claude/settings.json` (this project only) or `~/.claude/settings.json` (every project).
Use the ABSOLUTE path: the directory the command runs in is not specified, so a relative path
may not resolve.

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash /path/to/repo/.claude/statusline/statusline.sh",
    "refreshInterval": 3
  }
}
```

Requires `jq`. The Codex segment additionally requires `node` and the Codex plugin; without
them the segment is simply absent — the statusline itself still renders.

## The account label

The script reads the logged-in email — from `$CLAUDE_CONFIG_DIR/.claude.json`, falling back to
`~/.claude.json`, which is where the default profile keeps it — and shows it as `Acct: <email>`.
Neither file carrying an email renders no account segment.

To show a short label instead, put a `statusline-local.sh` beside the script; it is sourced
after the email is read and may overwrite `$acct`:

```bash
case "$acct" in
  work@example.com)     acct="Work" ;;
  personal@example.com) acct="Personal" ;;
esac
```

## codex-top

`codex-top.mjs` is a full-screen live board of every Codex job across all worktrees and
accounts — Enter drills into a job's transcript, Esc returns, q quits. Read-only. Run it with
`node .claude/statusline/codex-top.mjs`, or put a launcher on your PATH:

```bash
printf '#!/usr/bin/env bash\nexec node "%s/.claude/statusline/codex-top.mjs" "$@"\n' "$PWD" \
  > ~/.local/bin/codex-top && chmod +x ~/.local/bin/codex-top
```

Track labels on the board come from the statusline: it records each session's tmux session
name under `<config-dir>/session-tracks/`. Without the statusline running, jobs still list —
unlabelled.
