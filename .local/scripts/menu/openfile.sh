#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Open files selected with Sway window manager
#
# Usage:
#   <script-name> [--file FILEPATH] [--debug FLAG]
#
# Options:
#   --file FILEPATH  File to open
#   --debug FLAG     Flag of enabling debug
#
# Examples:
#   ./<script-name> --file <file-path>
#   ./<script-name> --file <file-path> --debug true
# ------------------------------------------------------------------------------

menu_cmd="rg --files --hidden --no-require-git | bemenu \
  --single-instance \
  --no-overlap \
  --prompt "" \
  --list 20 \
  --prefix "" \
  --ignorecase \
  --fork \
  --center \
  --no-spacing \
  --scrollbar "none" \
  --ch 20 \
  --cw 2 \
  --width-factor 0.60 \
  --border 1 \
  --border-radius 6 \
  --line-height 30 \
  --fn \"hack nerd font 10\" \
  --bdr \"#32d841\" \
  --tb \"#434446\" \
  --fb \"#434446\" \
  --ab \"#434446\" \
  --nb \"#434446\" \
  --tf \"#32d841\" \
  --ff \"#32d841\" \
  --hf \"#30fd42\" \
  --af \"#ffffff\" \
  --nf \"#ffffff\""

DEBUG=0
FILE=""

# -----------------------------------------------------------------------------
# Utility functions
# -----------------------------------------------------------------------------

debug_log() {
  if (( $DEBUG == 1 )); then
    echo "$(date): $1" | tee -a "/tmp/openfile.log"
  fi
}

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$@" || echo "Failed to send notification: $*" >&2
  else
    echo "Notification: $*" >&2
  fi
}

launch_detached() {
  local cmd="$1"
  debug_log "Launching detached: $cmd"
  nohup sh -c "$cmd" >/dev/null 2>&1 &
  disown
}


show_usage_help() {
  echo -e "Usage: $(basename "$0") --file <file-path> [--debug true|false]\n\
Options:\n\
  --file <file-path>    Path to the file to open (required)\n\
  --debug true|false    Enable or disable debug logging (default: false)"
  exit 1
}


get_terminal() {
  if [[ -n $TERMINAL ]]; then
    echo "$TERMINAL"
    return
  else
    notify "Error" "No terminal emulator specified"
    exit 1
  fi
}

# -----------------------------------------------------------------------------
# Aruguments parsing
# -----------------------------------------------------------------------------

while (( $# > 0 )); do
  case $1 in
    --file)
      if [[ -n "$2" ]]; then
        # Exapnd the leading tilde ~ (if any) with the value of $HOME
        FILE="${2/#\~/$HOME}"
      else
        echo "Error: --file requires a path argument"
        show_usage_help
      fi
      shift 2
      ;;
    --debug)
      if [[ "$2" == "true" ]]; then
        DEBUG=1
      elif [[ "$2" == "false" ]]; then
        DEBUG=0
      else
        echo "Error: --debug requires 'true' or 'false'"
        show_usage_help
      fi
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      show_usage_help
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Initializations and validations
# -----------------------------------------------------------------------------

if [[ -z "$FILE" ]]; then
  FILE=$(eval $menu_cmd)
  if [[ -z "$FILE" ]]; then
    echo "Error: --file argument is required"
    show_usage_help
  fi
fi

if (( $DEBUG == 1 )); then
  exec 1> >(tee -a "/tmp/openfile.log")
  exec 2>&1
  debug_log "Script started with file: $FILE"
fi

# Get the absolute path of the file
# Resolving symbolic link, remove redundant path components
file="$(readlink -f "$FILE")"
debug_log "Absolute path: $file"

if [[ ! -f "$file" ]]; then
  notify-send "Error" "File not found: $file"
  debug_log "Error: File not found: $file"
  exit 1
fi

mime_type=$(file --mime-type -b "$file")
debug_log "MIME type: $mime_type"

is_executable=$(test -x "$file" && echo true || echo false)
debug_log "Is executable: $is_executable"

# -----------------------------------------------------------------------------
# File open logic
# -----------------------------------------------------------------------------

case "$mime_type" in
  text/*|application/json|application/xml|application/javascript)
    debug_log "Opening text file with nvim"
    launch_detached "$(get_terminal) -e nvim \"$file\""
    ;;

  application/pdf|application/epub+zip)
    debug_log "Opening PDF with zathura"
    swaymsg exec "zathura \"$file\""
    ;;

  image/*)
    debug_log "Opening image with imv"
    swaymsg exec "imv \"$file\""
    ;;

  video/*)
    debug_log "Opening video with mpv"
    swaymsg exec "mpv \"$file\""
    ;;

  audio/*)
    debug_log "Opening audio with mpv"
    swaymsg exec "mpv \"$file\""
    ;;

  application/x-executable|application/x-sharedlib)
    if [[ "$file" == *.AppImage || -n "$is_executable" ]]; then
      debug_log "Executing binary file"
      swaymsg exec "$file"
    else
      debug_log "Binary file is not executable"
      notify "Error" "File is binary and not executable"
    fi
    ;;

  *)
    debug_log "Unknown file type, showing menu"
    action=$(echo -e "Open with editor\nExecute\nCancel" | bemenu \
      --prompt "How to open?" \
      --list 3)

    debug_log "User selected: $action"
    case "$action" in
      "Open with editor")
        foot -e nvim "$file"
        ;;
      "Execute")
        if [[ -n "$is_executable" ]]; then
          swaymsg exec "$file"
        else
          notify "Error" "File is not executable"
        fi
        ;;
      *)
        notify "Cancelled" "Operation cancelled"
        ;;
    esac
    ;;
esac

debug_log "Script completed successfully"
exit 0
