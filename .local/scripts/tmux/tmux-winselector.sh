#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Lists all tmux windows and switches to the selected one
# ------------------------------------------------------------------------------

if [[ -z $TMUX ]]; then
    echo "Please run the script in a tmux session"
    exit 0
fi

tmux list-windows -a -F "#{session_name}: #{window_index}:#{window_name}" | fzf --prompt="windows ❯ " --border=none | \
    {
        read -r selection || true
        if [ -n "$selection" ]; then
            session_name=$(echo "$selection" | cut -d':' -f1)
            window_index=$(echo "$selection" | cut -d':' -f2)
            tmux switch-client -t "$session_name" \; select-window -t "$window_index"
        fi
    }
