#!/usr/bin/env bash
# Resolve a Python interpreter with paramiko installed, preferring conda.
# Prints the interpreter path (and, for conda, the env name) as the last
# line so the caller can capture it, e.g.:
#   PYTHON=$(bash setup_env.sh)
# All diagnostic output goes to stderr; stdout carries only the final path.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQ_FILE="$SCRIPT_DIR/requirements.txt"
ENV_NAME="skill-ssh-operation"

if command -v conda >/dev/null 2>&1; then
  echo "conda found, using/creating env '$ENV_NAME'" >&2
  if ! conda env list | awk '{print $1}' | grep -qx "$ENV_NAME"; then
    echo "creating conda env '$ENV_NAME'" >&2
    if ! conda create -y -n "$ENV_NAME" python=3.11 >&2; then
      echo "ERROR: conda env creation failed. If the error above mentions" \
           "Terms of Service, ask the user to run: sudo conda tos accept" >&2
      exit 1
    fi
  fi
  PY="$(conda run -n "$ENV_NAME" python -c 'import sys; print(sys.executable)')"
  conda run -n "$ENV_NAME" python -m pip install -q -r "$REQ_FILE" >&2
  echo "$PY"
  exit 0
fi

if command -v python3 >/dev/null 2>&1; then
  VENV_DIR="./.venv-skill-ssh-operation"
  echo "no conda; using python3 venv at $VENV_DIR" >&2
  if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR" >&2
  fi
  "$VENV_DIR/bin/python" -m pip install -q -r "$REQ_FILE" >&2
  echo "$VENV_DIR/bin/python"
  exit 0
fi

echo "ERROR: neither conda nor python3 is available on this system. Cannot run the ssh-operation skill." >&2
exit 1
