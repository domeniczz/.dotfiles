#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Launch programs within tmux
#
# Usage:
#   <script-name> [--program PROGRAM] [--mode MODE] ...
#
# Options:
#   --program PROGRAM  Program to launch, USER_INPUT, FZF_SEARCH
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
PROGRAM=""
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

# Default window name to program name if empty
WIN_NAME=${WIN_NAME:-$PROGRAM}

# ------------------------------------------------------------------------------
# Additional handling
# ------------------------------------------------------------------------------

# If the program to launch is lazygit, get the git root path (launch in the root path of the git repo)
# If can not find a git root path, then display a message
if [[ "$PROGRAM" == "lazygit" ]]; then
  find_git_root() {
    local max_iterations=10
    local path="$1"
    local iterations=0
    local home_path=$(realpath $HOME)
    while [ "$iterations" -lt "$max_iterations" ]; do
      # Check if we've reached or passed HOME directory
      if [[ "$(realpath "$path")" == "$home_path" || "$(realpath "$path")" == "/" ]]; then
        if [ -d "${path}/.git" ]; then
          echo "$path"
          return 0
        else
          return 1
        fi
      fi
      # Check if .git exists in current directory
      if [ -d "${path}/.git" ]; then
        echo "$path"
        return 0
      fi
      # Move to parent directory
      path="$(dirname "$path")"
      (( iterations++ ))
    done
    return 1
  }
  START_PATH=$(find_git_root "$START_PATH") || {
    tmux display-message -d 1000 "No git repository found"
    exit 0
  }
fi

# -------------------------------------------------------------------------------
# Launch logic
# -------------------------------------------------------------------------------

if ! command -v $PROGRAM >/dev/null 2>&1; then
  echo "'$PROGRAM' is not installed!"
  exit 1
fi

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
