#!/usr/bin/env bash

ACTION=""
VALUE=5

# -----------------------------------------------------------------------------
# Aruguments parsing
# -----------------------------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case $1 in
    --action)
      if [[ $2 =~ ^(up|down|mute|micmute)$ ]]; then
        ACTION="$2"
      else
        exit 1
      fi
      shift 2
      ;;
    --val)
      if [[ $2 =~ ^[0-9]+$ ]]; then
        VALUE="$2"
      else
        exit 1
      fi
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$ACTION" ]]; then
  echo "Error: --action is required"
  echo "Usage: $0 --action <up|down|mute|micmute> [--val <percentage>]"
  exit 1
fi

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

get_current_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]\+%' | head -1 | tr -d '%'
}

get_mute_status() {
  pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

show_sway_statusbar() {
  local pid_file="/tmp/sway_bar_show_timer.pid"
  
  swaymsg bar hidden_state show
  
  if [ -f "$pid_file" ]; then
    kill $(cat "$pid_file") 2>/dev/null
  else
    # Send signal to statusbar.sh to update sleep duration between while loop to update info quicker
    echo "0.1" > /tmp/sway_refresh_interval
    pkill -SIGUSR1 -f "statusbar.sh"
  fi
  
  {
    sleep 1.5
    swaymsg bar hidden_state hide
    rm -f "$pid_file"
    echo "1" > /tmp/sway_refresh_interval
    pkill -SIGUSR1 -f "statusbar.sh"
  } &
  echo $! > "$pid_file"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

case $ACTION in
  up)
    if [[ "$(get_mute_status)" == "yes" ]]; then
      pactl set-sink-mute @DEFAULT_SINK@ 0
    fi
    current_vol=$(get_current_volume)
    new_vol=$((current_vol + $VALUE))
    if [[ $new_vol -gt 100 ]]; then
      pactl set-sink-volume @DEFAULT_SINK@ 100%
    else
      pactl set-sink-volume @DEFAULT_SINK@ +${VALUE}%
    fi
    show_sway_statusbar
    ;;
  down)
    if [[ "$(get_mute_status)" == "yes" ]]; then
      pactl set-sink-mute @DEFAULT_SINK@ 0
    fi
    pactl set-sink-volume @DEFAULT_SINK@ -${VALUE}%
    show_sway_statusbar
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    show_sway_statusbar
    ;;
  micmute)
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
    show_sway_statusbar
    ;;
esac
