---
name: ssh-operation
description: Connect to a remote server over SSH to run commands (username/password auth), typically for checking logs, service status, disk/memory usage, config files, or diagnosing an issue on a box the user gives credentials for. Use this whenever the user gives an SSH connection string (e.g. "ssh alice@10.0.0.5") plus a password and asks you to look at, check, inspect, or debug something on that server. Defaults to read-only, safe, non-destructive commands since these are usually production machines - any command that could change state (installs, restarts, file writes/deletes, config edits, kills) requires explicit user confirmation first, spelled out plainly before running it.
---

# SSH Operation

Run commands on a remote server the user gives you access to. The core risk here isn't the SSH mechanics, it's that these boxes are usually production - a wrong command can take down something real. Treat every session as read-only by default, and treat "can you also fix/restart/install X" as a separate decision point requiring the user's explicit go-ahead, not something to bundle into the same turn as the diagnosis.

## Setup (once per session)

Resolve a Python interpreter with `paramiko` installed by running:

```bash
bash scripts/setup_env.sh
```

This prefers conda (creates/reuses a `skill-ssh-operation` env), falls back to a local `.venv-skill-ssh-operation` venv if only `python3` is available, and exits with an error if neither exists. Capture its stdout - that's the interpreter path to use for every `ssh_exec.py` call below. Only run this once per session; reuse the path for subsequent commands.

## Connecting and running commands

Each call to `scripts/ssh_exec.py` is a single stateless SSH connection that runs one command and exits. There's no persistent session to manage - chain multiple commands with `&&` inside the one `command` argument if a task needs a sequence (e.g. `cd /var/log && ls -la`).

```bash
SSH_PASSWORD='<password>' <python> scripts/ssh_exec.py --host <host> --user <user> -- <command>
```

- Password goes through the `SSH_PASSWORD` env var, never as a CLI argument - keeps it out of shell history and process listings.
- The script only trusts hosts already in `~/.ssh/known_hosts`. If the user hasn't connected to this host before, it'll fail with a message telling them to run `ssh user@host` once by hand to accept the host key. Don't work around this by adding host-key auto-accept logic - that's the one guardrail standing between this skill and a silent man-in-the-middle on an unfamiliar network.
- Output is JSON on stdout: `{"exit_code": ..., "stdout": ..., "stderr": ...}` on success, or `{"error": ...}` if the connection/auth itself failed. Parse it rather than treating raw output as the command's stdout.

## The read-only default

Reach for diagnostic, listing, and viewing commands first: `ls`, `cat`, `less`/`head`/`tail`, `ps`, `top -bn1`, `df`, `free`, `systemctl status`, `journalctl`, `netstat`/`ss`, `grep` over logs, `docker ps`/`docker logs`, etc. These cover the large majority of "what's going on with this server" requests without any risk.

Before running *any* command, judge it yourself first: would this change state on the server (install, restart, delete, edit, kill, permission/user change...) or put real load on it (unscoped scans, bulk archiving/transfer, anything that walks the whole filesystem or a big log)? You understand intent and context far better than a pattern list ever could - an oddly-phrased or aliased command that's clearly a restart-in-disguise should get the same pause as `systemctl restart` spelled out plainly. Don't wait to be blocked before thinking about this.

As a backstop, `ssh_exec.py` also checks every command against a list of destructive and resource-intensive patterns (installs, restarts, deletes, edits, kills, reboots, unscoped `find`/`du`/`grep` over `/`, `tar`/`zip`/`rsync`...) and refuses to run a match, exiting with code 3 and `needs_confirmation: true`. This exists so the guardrail holds even if a step gets skipped - but it's a regex heuristic, not a shell parser, so it will miss obfuscated or unusual phrasings. Treat it as a safety net under your own judgment, not a substitute for it: if the script lets something through that you already flagged as risky, still ask.

Either way - whether you caught it yourself or the script blocked it - handle it the same way:
1. Tell the user plainly what command you want to run and why, and its concrete effect (e.g. "this restarts nginx, which drops active connections for a few seconds" or "this greps the entire filesystem, which can spike CPU on a live server"). Make this a standalone ask, not folded into a longer explanation.
2. Only after they say yes, run it with `--confirmed` added (needed to get past the script's own check regardless of whether it would have blocked you).

This isn't about being unable to make changes - it's that on a production box, the cost of an unreviewed mistake or an unexpected load spike is much higher than the cost of one extra confirmation round-trip.
