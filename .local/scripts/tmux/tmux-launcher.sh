#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Launch programs within tmux
#
# Usage:
#   <script-name> [--program PROGRAM] [--mode MODE] ...
#
# Options:
#   --program PROGRAM  Program to launch, USER_INPUT, FZF_SEARCH (default: $SHELL)
#   --mode MODE        Launch mode: split, or newwin (default: newwin)
#   --sudo             Run program with sudo privileges
#   --path PATH        Path to start program in
#   --winname          Newly created tmux window name (default: <program-name>)
#   --splitpct         Percentage space to taken for the new window
#
# Examples:
#   ./<script-name> --mode split
#   ./<script-name> --mode newwin --sudo
#   ./<script-name> --program htop --sudo
# ------------------------------------------------------------------------------

LAUNCH_MODE="newwin"
PROGRAM="${SHELL:-$(command -v bash)}"
USE_SUDO=0
WIN_NAME=""
START_PATH=$(tmux display-message -p "#{pane_current_path}")
SPLIT_PCT=0
FZF_SEARCH=0

# ------------------------------------------------------------------------------
# Parse arguments
# ------------------------------------------------------------------------------

while (( $# > 0 )); do
    case $1 in
        --)
            shift
            break
            ;;
        --mode|-m)
            if [[ $2 =~ ^(split|newwin)$ ]]; then
                LAUNCH_MODE="$2"
            else
                echo "Invalid mode. Available: normal, split, or newwin"
                exit 1
            fi
            shift 2
            ;;
        --program|-p)
            if [[ "$2" == "USER_INPUT" ]]; then
                PROGRAM=$(tmux command-prompt -p "Program to run:" "display-message -p '%%'")
            elif [[ "$2" == "FZF_SEARCH" ]]; then
                FZF_SEARCH=1
            else
                PROGRAM="$2"
            fi
            shift 2
            ;;
        --sudo|-s)
            USE_SUDO=1
            shift 1
            ;;
        --path|-d)
            START_PATH="$2"
            shift 2
            ;;
        --winname|-n)
            WIN_NAME="$2"
            shift 2
            ;;
        --splitpct|-b)
            SPLIT_PCT="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# -------------------------------------------------------------------------------
# Launch logic
# -------------------------------------------------------------------------------

if (( FZF_SEARCH == 1 )); then
    FZF_PROMPT="launch ❯ "
    if (( USE_SUDO == 1 )); then
        FZF_PROMPT="sudo launch ❯ "
    fi
    PROGRAM=$(
        {
            if command -v fd >/dev/null 2>&1; then
                fd . /usr/bin --type x --follow --color=never --format="{/}" 2>/dev/null || true;
                fd . ~/.local/bin ~/.bin --type x --follow --color=never --format="{/}" 2>/dev/null | sed 's/^/\x1b[33m/; s/$/\x1b[0m/' || true;
            else
                find /usr/bin -type f -follow -perm /111 -printf '%f\n' 2>/dev/null || true;
                find ~/.local/bin ~/.bin -type f -follow -perm /111 -printf '%f\n' 2>/dev/null | sed 's/^/\x1b[33m/; s/$/\x1b[0m/' || true;
            fi
        } | fzf --ansi --prompt="$FZF_PROMPT" --border=none | sed 's/\x1b\[[0-9;]*m//g'
    ) || exit 0
fi

WIN_NAME=$(basename "${WIN_NAME:-$PROGRAM}" | tr '.' '_' | cut -c1-20)

if (( USE_SUDO == 1 )); then
    CMD="sudo --preserve-env $PROGRAM"
else
    CMD="$PROGRAM"
fi

if [[ "$LAUNCH_MODE" = "newwin" && -n "$START_PATH" ]]; then
    tmux new-window -c "$START_PATH" -n "$WIN_NAME" "$CMD"
    exit
fi

if [[ "$LAUNCH_MODE" = "split" && -n "$START_PATH" ]]; then
    if (( SPLIT_PCT == 0 )) then
        # Caluclate the optimal percentage taken by the new tmux pane (ideal pane_width 155)
        # Percantage range is [40, 70]
        current_pane_width=$(tmux display-message -p "#{pane_width}")
        ideal_pct=$(( 155 * 100 / current_pane_width ))
        SPLIT_PCT=$(( ideal_pct < 40 ? 40 : ideal_pct > 70 ? 70 : ideal_pct ))
    fi
    tmux split-window -h -p "$SPLIT_PCT" -c "$START_PATH" "$CMD"
    exit
fi
