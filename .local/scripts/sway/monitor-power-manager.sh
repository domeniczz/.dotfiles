#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Enable/Disable swayidle and sleep conditionally
# - When external monitor connected, disable swayidle and sleep
# - When no external monitors are connected, enable swayidle and sleep
# ------------------------------------------------------------------------------

declare -gr INHIBIT_LOCK="/tmp/monitor_sleep_inhibit_lock"
declare -gr LOG_FILE="/tmp/monitor-power-manager.log"

declare -gi PREV_MONITOR_STATUS=-1

declare -gr SWAYIDLE_CMD="swayidle -w \\
  timeout 1200 'brightnessctl set 5% -s' resume 'brightnessctl -r' \\
  timeout 2700 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"' \\
  before-sleep ''"

declare -gr SYSTEMD_INHIBIT_CMD="systemd-inhibit --what=sleep:hibernate:hybrid-sleep:suspend-then-hibernate \\
  --who=\"ExternalMonitor\" \\
  --why=\"External monitor connected\" \\
  --mode=block tail -f /dev/null"

function check_monitors() {
  local counts=$(swaymsg -t get_outputs -r | jq -r '
    {
      external: [.[] | select(.active == true and .name != "eDP-1")] | length,
      internal: [.[] | select(.active == true and .name == "eDP-1")] | length,
      total: [.[] | select(.active == true)] | length
    } | "\(.external) \(.internal) \(.total)"
  ')
  read -r external_active internal_active total_active <<< "$counts"
  local msg_counts="External_active=$external_active; Internal_active=$internal_active; Total_active=$total_active"
  if (( external_active > 0 )); then
    log "$msg_counts - External monitor active"
    return 0
  elif (( internal_active == 1 && total_active == 1 )); then
    log "$msg_counts - Only internal monitor active"
    return 1
  else
    log "$msg_counts - No active monitors"
    return 1
  fi
}

function manage_idle() {
  pkill swayidle 2>/dev/null
  local monitor_status=$1
  if (( monitor_status == 0 )); then
    log "External monitor connected, disabled swayidle"
  else
    eval "$SWAYIDLE_CMD" &
    log "External monitor disconnected, enable swayidle"
  fi
}

function manage_inhibitor() {
  local monitor_status=$1
  if (( monitor_status == 0 )); then
    [[ -f "$INHIBIT_LOCK" ]] && return
    eval "$SYSTEMD_INHIBIT_CMD" &
    echo $! > "$INHIBIT_LOCK"
    log "Created systemd inhibitor (PID: $!)"
  else
    cleanup
    log "Removed systemd inhibitor (PID: $pid)"
  fi
}

function execution_flow() {
  check_monitors
  local monitor_status=$?
  (( monitor_status != PREV_MONITOR_STATUS )) && {
    log "Monitor status changed"
    manage_idle $monitor_status
    manage_inhibitor $monitor_status
    PREV_MONITOR_STATUS=$monitor_status
  }
}

function log() {
  local message="$1"
  echo -e "$message" >> "$LOG_FILE"
}

function cleanup() {
  [[ ! -f "$INHIBIT_LOCK" ]] && return
  pid=$(cat "$INHIBIT_LOCK")
  pkill -P $pid 2>/dev/null
  kill $pid 2>/dev/null
  rm "$INHIBIT_LOCK"
}

function after() {
  cleanup
  log "\n$(date "+%F %H:%M:%S"): Clean up"
  exit 0
}

trap after SIGINT SIGTERM EXIT

log "$(date "+%F %H:%M:%S"): Start monitor-power-manager"
execution_flow

while true; do
  swaymsg -t subscribe '["output"]' 2>/dev/null | while read -r line; do
    log "\n$(date "+%F %H:%M:%S")"
    execution_flow
  done
  sleep 1
done
