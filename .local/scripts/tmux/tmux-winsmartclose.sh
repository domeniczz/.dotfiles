#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Don't close tmux session when closing the last window
# -----------------------------------------------------------------------------

window_count=$(tmux list-windows | wc -l)

if ((window_count == 1)); then
  # If this is the last window, create a new one before closing
  tmux new-window
  tmux kill-window -t !
else
  # If not the last window, just close normally
  tmux kill-window
fi
