#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Select a directory and create a tmux session for that directory
#
# Thanks @ThePrimeTimeagen
# ------------------------------------------------------------------------------

places="$HOME/Personal $HOME/Work $HOME/Public $HOME/Personal/repository $HOME/Clones"

if command -v fd >/dev/null 2>&1; then
    selected=$(fd . $places --min-depth 1 --max-depth 1 --type d 2>/dev/null | sort --reverse | fzf --prompt="sessionizer ❯ " --border=none)
else
    selected=$(find $places -mindepth 1 -maxdepth 1 -type d -O2 2>/dev/null | sort --reverse | fzf --prompt="sessionizer ❯ " --border=none)
fi

[[ -z $selected ]] && exit 0

selected_name=$(basename "$selected" | tr '.' '_' | cut -c1-20)

function create_session() {
    if ! tmux has-session -t="$selected_name" 2>/dev/null; then
        tmux new-session -ds "$selected_name" -c "$selected" "env INCOGNITO=1 $SHELL"
        tmux new-window -t "$selected_name:2" -c "$selected" "env INCOGNITO=1 $SHELL"
        tmux send-keys -t "$selected_name:1" "nvim +\"lua vim.g.quit_on_empty = false\" ." C-m
        tmux select-window -t "$selected_name:1"
    fi
}

if [[ -n "${TMUX:-}" ]]; then
    create_session
    tmux switch-client -t "$selected_name"
else
    create_session
    tmux attach-session -t "$selected_name"
fi
