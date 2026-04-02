#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Don't close tmux session when closing the last window
# ------------------------------------------------------------------------------

editors='^(vi|vim|nvim|emacs|nano|micro|helix|kakoune)$'

win_panes=$(tmux display-message -p '#{window_panes}')
cur_cmd=$(tmux display-message -p '#{pane_current_command}')
cur_pid=$(tmux display-message -p '#{pane_pid}')

editor_running=false
if tmux list-panes -F '#{pane_current_command}' | grep -Eq "$editors"; then
	editor_running=true
fi

bg_process_running=false
for pane_pid in $(tmux list-panes -F '#{pane_pid}'); do
	if ps -o pid= --ppid "$pane_pid" | grep -q .; then
		bg_process_running=true
		break
	fi
done

only_editor_running=false
if (( win_panes == 1 )) && [[ $cur_cmd =~ $editors ]]; then
	if (( $(ps -o pid= --ppid "$cur_pid" | wc -l) == 1 )); then
		only_editor_running=true
	fi
fi

if (( win_panes > 1 )) || $editor_running || $bg_process_running; then
    reasons=()
    (( win_panes > 1 )) && reasons+=("$win_panes panes")
    $editor_running && reasons+=("editor running")
    $bg_process_running && ! $only_editor_running && reasons+=("background process(es)")
    prompt="Close window"
    if ((${#reasons[@]})); then
        separator=" with "
        for r in "${reasons[@]}"; do
            prompt+="$separator$r"
            separator=" and "
        done
    fi
    prompt+="? (y/n)"
    tmux confirm-before -p "$prompt" "if -F '#{==:#{session_windows},1}' 'new-window; kill-window -t !' 'kill-window'" || true
else
    tmux if -F '#{==:#{session_windows},1}' 'new-window; kill-window -t !' 'kill-window'
fi
