#!/usr/bin/env bash

if (($# > 1)); then
  selected=$1
else
  places="$HOME/Work $HOME/Personal $HOME/Personal/repository $HOME/Clones"
  if command -v fd >/dev/null 2>&1; then
    selected=$(fd . $places --min-depth 1 --max-depth 1 --type d | fzf --prompt="sessionizer: ")
  else
    selected=$(find $places -mindepth 1 -maxdepth 1 -type d | fzf --prompt="sessionizer: ")
  fi
fi

if [[ -z $selected ]]; then
  exit 0
fi

selected_name=$(basename "$selected" | tr . _ | cut -c1-20)
is_tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $is_tmux_running ]]; then
  tmux new-session -s $selected_name -c $selected
  exit 0
fi

if ! tmux has-session -t=$selected_name 2>/dev/null; then
  tmux new-session -ds $selected_name -c $selected
fi

tmux switch-client -t $selected_name
