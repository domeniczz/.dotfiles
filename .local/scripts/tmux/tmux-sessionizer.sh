#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Select a directory and create a tmux session for that directory
#
# Thanks @ThePrimeTimeagen
# ------------------------------------------------------------------------------

places="$HOME/Work $HOME/Personal $HOME/Personal/repository $HOME/Clones"

if command -v fd >/dev/null 2>&1; then
  selected=$(fd . $places --min-depth 1 --max-depth 1 --type d | sort --reverse | fzf --prompt="sessionizer > " --border=none)
else
  selected=$(find $places -mindepth 1 -maxdepth 1 -type d | sort --reverse | fzf --prompt="sessionizer > " --border=none)
fi

[[ -z $selected ]] && exit 0

selected_name=$(basename "$selected" | tr '.' '_' | cut -c1-20)
is_tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $is_tmux_running ]]; then
  tmux new-session -s $selected_name -c $selected -n "nvim" "nvim ."
  tmux new-window -t $selected_name:2 -c $selected
  tmux select-window -t $selected_name:1
  exit 0
fi

if ! tmux has-session -t=$selected_name 2>/dev/null; then
  tmux new-session -ds $selected_name -c $selected -n "nvim" "nvim ."
  tmux new-window -t $selected_name:2 -c $selected
  tmux select-window -t $selected_name:1
fi

tmux switch-client -t $selected_name
