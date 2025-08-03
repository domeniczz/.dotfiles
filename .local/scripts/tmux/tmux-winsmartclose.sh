#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Don't close tmux session when closing the last window
# ------------------------------------------------------------------------------

current_win_pane_count=$(tmux display-message -p '#{window_panes}')
if tmux list-panes -F '#{pane_current_command}' | grep -Eq "^vim|nvim|nano$"; then
    editor_running=true
else
    editor_running=false
fi

if (( current_win_pane_count > 1 )) || $editor_running; then
    if (( current_win_pane_count > 1 )); then
        if $editor_running; then
            prompt="Close window with $current_win_pane_count panes and vim/nvim running? (y/n)"
        else
            prompt="Close window with $current_win_pane_count panes? (y/n)"
        fi
    else
        prompt="Close window with vim/nvim running? (y/n)"
    fi
    tmux confirm-before -p "$prompt" \
        "if-shell 'test \$(tmux display-message -p \"#{session_windows}\") -eq 1' \
            'new-window ; kill-window -t !' \
            'kill-window'" || true
else
    current_session_win_count=$(tmux display-message -p '#{session_windows}')
    if (( current_session_win_count == 1 )); then
        tmux new-window
        tmux kill-window -t !
    else
        tmux kill-window
    fi
fi
