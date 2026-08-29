#!/usr/bin/env python3
"""Run a single command on a remote host over SSH.

Auth: username/password only. Host key must already be trusted (present in
~/.ssh/known_hosts) - this script refuses unknown hosts rather than silently
trusting them, since these are typically production servers.

Usage:
    SSH_PASSWORD=secret python3 ssh_exec.py --host HOST --user USER [--port 22] -- COMMAND

Password is read from the SSH_PASSWORD env var (never argv) to keep it out of
shell history and `ps` output.

Commands that look destructive (installs, restarts, deletes, edits...) or
resource-intensive (unbounded find/du/grep, bulk archive/transfer...) are
refused unless --confirmed is passed. This is a local check against the
command text before any connection is made - the caller must get explicit
user approval first, then re-run with --confirmed.

Prints JSON: {"exit_code": int, "stdout": str, "stderr": str}
On connection/auth/host-key errors, prints JSON {"error": str} and exits 1.
On a blocked command, prints JSON {"error": str, "needs_confirmation": true,
"reason": str} and exits 3.
"""
import argparse
import json
import os
import re
import sys

import paramiko

# conservative shell-text checks, not a sandbox. Aliases, encoded
# commands, and remote scripts cannot be reliably classified without executing
# them, so opaque command interpreters are blocked instead.
DESTRUCTIVE_PATTERNS = [
    (r"\brm\b", "deletes files (rm)"),
    (r"\bmv\b", "moves/overwrites files (mv)"),
    (r"\b(dd|mkfs|shred|truncate)\b", "destructive disk operation"),
    (r"\b(apt|apt-get|yum|dnf|brew)\s+(install|remove|purge|upgrade)\b", "package management"),
    (r"\bpip3?\s+(install|uninstall)\b|\bnpm\s+(install|i|uninstall)\b", "package install/uninstall"),
    (r"\bsystemctl\s+(restart|stop|start|disable|enable|kill|reload)\b", "service control"),
    (r"\bservice\s+\S+\s+(restart|stop|start)\b", "service control"),
    (r"\b(kill|killall|pkill)\b", "kills a process"),
    (r"\b(reboot|shutdown|halt|poweroff)\b", "reboots/shuts down the host"),
    (r"\b(chmod|chown|useradd|userdel|usermod|passwd)\b", "permission/user change"),
    (r"\bsed\s+-i\b", "in-place file edit"),
    (r"\btee\b", "writes via tee"),
    (r"\bdocker\s+(rm|rmi|stop|kill|restart)\b", "docker destructive op"),
    (r"\bgit\s+push\b", "git push"),
    (r"\bcrontab\s+-[er]\b", "crontab edit/removal"),
    (r"\b(mount|umount|fdisk)\b", "filesystem mount operation"),
    (r"\b(eval|xargs)\b", "can execute another command"),
    (r"\b(bash|sh|zsh|ksh|fish)\s+-c\b", "nested shell command"),
    (r"\b(python3?|perl|ruby|node)\s+(-c|-e)\b", "embedded script execution"),
]

INTENSIVE_PATTERNS = [
    (r"\bfind\b", "filesystem-wide file scan"),
    (r"\bdu\b", "disk usage scan"),
    (r"\b(grep|egrep|fgrep|rg)\b.*(?:-[a-zA-Z]*[rR][a-zA-Z]*\b|--recursive\b)", "recursive text scan"),
    (r"\b(tar|zip|rsync)\b", "bulk archive/transfer, can be I/O heavy"),
]


def has_unquoted_redirection(command):
    """Return whether command contains an active shell redirection operator."""
    quote = None
    escaped = False
    for character in command:
        if quote == "'":
            if character == "'":
                quote = None
            continue
        if escaped:
            escaped = False
        elif character == "\\":
            escaped = True
        elif quote == '"':
            if character == '"':
                quote = None
        elif character in "'\"":
            quote = character
        elif character in "<>":
            return True
    return False


def without_quoted_text(command):
    """Replace quoted argument contents so data is not mistaken for commands."""
    output = []
    quote = None
    escaped = False
    for character in command:
        if quote == "'":
            if character == "'":
                quote = None
            output.append(" ")
        elif escaped:
            escaped = False
            output.append(" ")
        elif character == "\\":
            escaped = True
            output.append(" ")
        elif quote == '"':
            if character == '"':
                quote = None
            output.append(" ")
        elif character in "'\"":
            quote = character
            output.append(" ")
        else:
            output.append(character)
    return "".join(output)


def has_unbounded_log_read(command):
    """Return the reason for an unbounded log read, if any."""
    if re.search(r"\bjournalctl\b", command) and not re.search(
        r"(?:^|\s)-n\s*\d+\b|(?:^|\s)--lines(?:=|\s+)\S+", command
    ):
        return "unbounded journal read"
    if re.search(r"\bdocker\s+logs\b", command) and not re.search(
        r"(?:^|\s)--tail(?:=|\s+)\S+", command
    ):
        return "unbounded container log read"
    return None


def check_risk(command):
    """Return (reason, category) if command matches a risky pattern, else None."""
    if has_unquoted_redirection(command):
        return "redirects output to a file (write)", "destructive"
    command_without_quoted_text = without_quoted_text(command)
    log_reason = has_unbounded_log_read(command_without_quoted_text)
    if log_reason:
        return log_reason, "resource-intensive"
    for pattern, reason in DESTRUCTIVE_PATTERNS:
        if re.search(pattern, command_without_quoted_text):
            return reason, "destructive"
    for pattern, reason in INTENSIVE_PATTERNS:
        if re.search(pattern, command_without_quoted_text):
            return reason, "resource-intensive"
    return None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", required=True)
    parser.add_argument("--user", required=True)
    parser.add_argument("--port", type=int, default=22)
    parser.add_argument("--timeout", type=float, default=15.0)
    parser.add_argument("--confirmed", action="store_true",
                         help="User has explicitly approved a risky command")
    parser.add_argument("command", nargs=argparse.REMAINDER,
                         help="Command to run, after --")
    args = parser.parse_args()

    command = " ".join(args.command).lstrip("- ").strip()
    if not command:
        parser.error("no command given (use: -- your command here)")

    risk = check_risk(command)
    if risk and not args.confirmed:
        reason, category = risk
        print(json.dumps({
            "error": "Command blocked: looks {} ({}). Ask the user for explicit "
                      "approval, then re-run with --confirmed.".format(category, reason),
            "needs_confirmation": True,
            "reason": reason,
        }))
        sys.exit(3)

    password = os.environ.get("SSH_PASSWORD")
    if not password:
        print(json.dumps({"error": "SSH_PASSWORD env var not set"}))
        sys.exit(1)

    client = paramiko.SSHClient()
    client.load_system_host_keys()  # ~/.ssh/known_hosts
    # default RejectPolicy is what we want - unknown hosts must be
    # accepted by the user via a normal `ssh` connection first. No AutoAddPolicy.

    try:
        client.connect(
            hostname=args.host,
            port=args.port,
            username=args.user,
            password=password,
            timeout=args.timeout,
            allow_agent=False,
            look_for_keys=False,
        )
        _, stdout, stderr = client.exec_command(command, timeout=args.timeout)
        exit_code = stdout.channel.recv_exit_status()
        result = {
            "exit_code": exit_code,
            "stdout": stdout.read().decode(errors="replace"),
            "stderr": stderr.read().decode(errors="replace"),
        }
        print(json.dumps(result))
        sys.exit(0 if exit_code == 0 else 2)
    except paramiko.ssh_exception.SSHException as e:
        hint = ""
        if "not found in known_hosts" in str(e):
            hint = (" Run `ssh {}@{}` manually once to accept the host key, "
                     "then retry.").format(args.user, args.host)
        print(json.dumps({"error": str(e) + hint}))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({"error": "{}: {}".format(type(e).__name__, e)}))
        sys.exit(1)
    finally:
        client.close()


if __name__ == "__main__":
    main()
