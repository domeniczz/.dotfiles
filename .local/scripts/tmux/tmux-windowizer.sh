#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Open a dedicated window for a specific branch or path
# and send commands to it without manually switching to the window
# Usage: ./script.sh <branch_path> [command...]
#
# Thanks @ThePrimeTimeagen
# ------------------------------------------------------------------------------

branch_name=$(basename $1)
session_name=$(tmux display-message -p "#S")
clean_name=$(echo $branch_name | tr "./" "__")
target="$session_name:$clean_name"

if ! tmux has-session -t $target 2>/dev/null; then
    tmux new-window --detached --name $clean_name
fi

shift
tmux send-keys -t $target "$*" Enter
