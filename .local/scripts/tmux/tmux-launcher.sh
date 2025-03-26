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

# ------------------------------------------------------------------------------
# Aruguments parsing
# ------------------------------------------------------------------------------

while (( $# > 0 )); do
  case $1 in
    --mode)
      if [[ $2 =~ ^(split|newwin)$ ]]; then
        LAUNCH_MODE="$2"
      else
        echo "Invalid mode. Available: normal, split, or newwin"
        exit 1
      fi
      shift 2
      ;;
    --program)
      if [[ "$2" == "USER_INPUT" ]]; then
        PROGRAM=$(tmux command-prompt -p "Program to run:" "display-message -p '%%'")
      elif [[ "$2" == "FZF_SEARCH" ]]; then
        PROGRAM=$(fd . /usr/bin --type f --color=never --format="{/}" | fzf-tmux -p "40%,60%" --prompt="launch: ") || exit 0
      else
        PROGRAM="$2"
      fi
      shift 2
      ;;
    --sudo)
      USE_SUDO=1
      shift 1
      ;;
    --path)
      START_PATH="$2"
      shift 2
      ;;
    --winname)
      WIN_NAME="$2"
      shift 2
      ;;
    --splitpct)
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

if ! command -v "$PROGRAM" >/dev/null 2>&1; then
  tmux display-message -d 1000 "Program \"$PROGRAM\" does not exist!"
  exit 1
fi

WIN_NAME=$(basename "${WIN_NAME:-$PROGRAM}" | tr '.' '_' | cut -c1-20)

if (( $USE_SUDO == 1 )); then
  CMD="sudo --preserve-env $PROGRAM"
else
  CMD="$PROGRAM"
fi

if [[ "$LAUNCH_MODE" = "newwin" && -n "$START_PATH" ]]; then
  # WRAPPER_CMD is used for not closing window after exit program
  # WRAPPER_CMD="bash -c '$CMD; if [ \$(tmux list-windows | wc -l) -eq 1 ]; then tmux new-window; tmux kill-window -t !; else tmux kill-window; fi'"
  # tmux new-window -c "$START_PATH" -n "$WIN_NAME" "$WRAPPER_CMD"
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
