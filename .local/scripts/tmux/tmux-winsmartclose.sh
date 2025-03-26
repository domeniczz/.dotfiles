#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Don't close tmux session when closing the last window
# ------------------------------------------------------------------------------

window_count=$(tmux list-windows | wc -l)

if (( window_count == 1 )); then
  tmux new-window
  tmux kill-window -t !
else
  tmux kill-window
fi
