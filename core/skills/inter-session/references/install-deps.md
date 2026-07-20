# `/inter-session install-deps` — isolated venv

Run this only when the monitor reports `[inter-session] dependencies missing`, then reconnect.

Deps live in a dedicated venv at `~/.claude/data/inter-session/venv`; every `bin/*.py` re-execs
under it automatically once it exists.

1. Detect `uv` with `command -v uv` (faster, optional).
2. Print the exact commands, ask the user to confirm, then:
   - venv: `uv venv ~/.claude/data/inter-session/venv`
     (or `python3 -m venv ~/.claude/data/inter-session/venv`)
   - deps: `uv pip install -p ~/.claude/data/inter-session/venv -r <bin>/../requirements.txt`
     (or `~/.claude/data/inter-session/venv/bin/pip install -r <bin>/../requirements.txt`)
3. Report: installed in the isolated venv; future commands pick it up automatically.
