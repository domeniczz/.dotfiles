# -----------------------------------------------------------------------------
# Launch programs within tmux
#
# Usage:
#   <script-name> [--program PROGRAM] [--mode MODE] [--sudo] [--winname WINNAME]
# 
# Options:
#   --program PROGRAM  Program to launch
#   --mode MODE        Launch mode: split, or newwin (default: newwin)
#   --sudo             Run program with sudo privileges
#   --winname          Newly created tmux window name (default: <program-name>)
# 
# Examples:
#   ./<script-name> --mode split
#   ./<script-name> --mode newwin --sudo
#   ./<script-name> --program htop --sudo
# -----------------------------------------------------------------------------

# Variables
LAUNCH_MODE="newwin"
PROGRAM=""
USE_SUDO=0
WIN_NAME=""
START_PATH=$(tmux display-message -p "#{pane_current_path}")

# -----------------------------------------------------------------------------
# Aruguments parsing
# -----------------------------------------------------------------------------

# Parse command line arguments
while [[ $# -gt 0 ]]; do
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
      PROGRAM="$2"
      shift 2
      ;;
    --sudo)
      USE_SUDO=1
      shift 1
      ;;
    --winname)
      WIN_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Default window name to program name if empty
WIN_NAME=${WIN_NAME:-$PROGRAM}

# -----------------------------------------------------------------------------
# Additional handling
# -----------------------------------------------------------------------------

# If the program to launch is lazygit, get the git root path (launch in the root path of the git repo)
# If can not find a git root path, then display a message
if [[ "$PROGRAM" == "lazygit" ]]; then
  # Find git repository root directory
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
      ((iterations++))
    done
    
    return 1
  }
  # Call the function to get git root directory
  START_PATH=$(find_git_root "$START_PATH")
  # If not found, then exit
  res=$?
  if [[ $res -ne 0 || -z "$START_PATH" ]]; then
    tmux display-message -d 1000 "No git repository found"
    exit
  fi
fi

# ------------------------------------------------------------------------------
# Launch logics
# ------------------------------------------------------------------------------

# Check if the program is installed
if ! command -v $PROGRAM >/dev/null 2>&1; then
  echo "'$PROGRAM' is not installed!"
  exit 1
fi

# Prepare the launch command with optional sudo
if [ "$USE_SUDO" -eq 1 ]; then
  CMD="sudo -E $PROGRAM"
else
  CMD="$PROGRAM"
fi

# Launch in vertically split pane within current window
if [[ "$LAUNCH_MODE" = "split" && -n "$START_PATH" ]]; then
  # Caluclate the optimal percentage taken by the new tmux pane (ideal pane_width 155)
  # Percantage range is [40, 70]
  current_pane_width=$(tmux display-message -p "#{pane_width}")
  ideal_pct=$((155 * 100 / current_pane_width))
  split_pct=$((ideal_pct < 40 ? 40 : ideal_pct > 70 ? 70 : ideal_pct))
  tmux split-window -h -p "$split_pct" -c "$START_PATH" $CMD
  exit
fi

# Launch in new window
if [[ "$LAUNCH_MODE" = "newwin" && -n "$START_PATH" ]]; then
  tmux new-window -c "$START_PATH" -n "$WIN_NAME" $CMD
  exit
fi

# # Get the current pane's PID
# pane_pid=$(tmux display-message -p '#{pane_pid}')
# 
# # Check if vim/nvim is running in the process tree of current pane
# if command -v rg >/dev/null 2>&1; then
#   is_editor_running=$(ps -o comm= -p $(pstree -p $pane_pid | rg -o '\(\d+\)' | tr -d '()') | rg "^(vi|vim|nvim|nano|emacs|$PROGRAM)$")
# else
#   is_editor_running=$(ps -o comm= -p $(pstree -p $pane_pid | grep -o '([0-9]\+)' | tr -d '()') | grep -E "^(vi|vim|nvim|nano|emacs|$PROGRAM)$")
# fi
# 
# if [[ -n "$is_editor_running" ]]; then
#   # If editor is running, launch in new window
#   tmux new-window -n "$WIN_NAME" $CMD
# else
#   # If no editor is running, launch in current window
#   tmux send-keys "$CMD" C-m
# fi

