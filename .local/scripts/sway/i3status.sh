#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Sway window manager status bar with i3status
# ------------------------------------------------------------------------------

declare -gr BATTERY_CRITICAL_THRESHOLD=25

declare -gr bluetooth_icons=("󰂲" "󰂱")
declare -gr internet_speed_icons=("" "")

declare -g BLUETOOTH_COUNT=0
declare -g BLUETOOTH_PREV_COUNT=0
declare -g PREV_RX_BYTES=0
declare -g PREV_TX_BYTES=0
declare -g PREV_SPEED_TIME=0

declare -A FUNC_OUTPUTS

declare -gr BAT_PATH="/sys/class/power_supply/BAT0/capacity"

for path in /sys/class/power_supply/{AC,ADP,ACAD}*/online; do
  [[ -f "$path" ]] && { declare -gr AC_PATH=$path; break; }
done

# ------------------------------------------------------------------------------
# Traps
# ------------------------------------------------------------------------------

function log_error() {
  local log_file="/tmp/statusbar.log"
  local line="${BASH_LINENO[0]}"
  local source="${BASH_SOURCE[1]:-$0}"
  local command="${BASH_COMMAND}"
  local exit_code=$?
  printf "[%s] ERROR (code: %d): '%s' failed at %s:%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$exit_code" "$command" "$source" "$line" >> "$log_file"
  if [[ "$command" =~ \$\{?[a-zA-Z_][a-zA-Z0-9_]*(\[\])?\}? ]]; then
    printf "[%s] Hint: Possible unbound variable (-u)\n" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
  elif [[ "$command" == *"|"* ]]; then
    printf "[%s] Hint: Command contains a pipe, check pipefail (-o pipefail)\n" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
  fi
}

trap log_error ERR

function cleanup() {
  # Kill the background process
  if [[ -n "$IFACE_MONITOR_PID" && -e /proc/$IFACE_MONITOR_PID ]]; then
    kill $IFACE_MONITOR_PID 2>/dev/null
  fi
  # Remove temporary files
  rm -f "$NETWORK_INTERFACE_FILE"
  exit 0
}

trap cleanup EXIT SIGINT SIGTERM

# ------------------------------------------------------------------------------
# Monitor network interface & connection changes
# ------------------------------------------------------------------------------

declare -a NETWORK_INTERFACES
declare -g NETWORK_INTERFACE_FILE="/tmp/network_interface"

function get_all_network_interfaces() {
  for iface in /sys/class/net/*; do
    name=$(basename "$iface")
    if ! readlink "$iface" | command grep -q "virtual/"; then
      NETWORK_INTERFACES+=("$name")
    fi
  done
}

get_all_network_interfaces

function monitor_active_interfaces() {
  while true; do
    if (( ${#NETWORK_INTERFACES[@]} == 0 )); then
      echo "" > $NETWORK_INTERFACE_FILE
      sleep 5
      get_all_network_interfaces
      continue
    fi
    for iface in "${NETWORK_INTERFACES[@]}"; do
      if [[ -f "/sys/class/net/${iface}/operstate" ]]; then
        state=$(timeout 0.2s cat "/sys/class/net/${iface}/operstate" || echo "err")
        if [[ "$state" == "up" ]]; then
          echo "${iface}" > $NETWORK_INTERFACE_FILE
        else
          echo "" > $NETWORK_INTERFACE_FILE
        fi
      fi
    done
    sleep 2
  done
}

declare -g IFACE_MONITOR_PID=""
monitor_active_interfaces &
IFACE_MONITOR_PID=$!

# ------------------------------------------------------------------------------
# Get status
# ------------------------------------------------------------------------------

function get_bluetooth() {
  local bluetooth_device icon
  local bluetooth_device_text=""
  BLUETOOTH_COUNT=$(timeout 0.2s bluetoothctl devices Connected | wc -l || echo "-1")
  (( BLUETOOTH_COUNT < BLUETOOTH_PREV_COUNT )) && timeout 0.2s playerctl pause || true
  BLUETOOTH_PREV_COUNT=$BLUETOOTH_COUNT
  if (( BLUETOOTH_COUNT > 0 )); then
    icon=${bluetooth_icons[1]}
    while IFS= read -r device; do
      [[ -n "$bluetooth_device_text" ]] && bluetooth_device_text+=" "
      bluetooth_device_text+="$icon $device"
    done < <(timeout 0.2s bluetoothctl devices Connected | cut -d' ' -f3- || echo "err")
  else
    icon=${bluetooth_icons[0]}
    bluetooth_device_text="$icon "
  fi
  FUNC_OUTPUTS[bluetooth]="{\"name\":\"bluetooth\",\"full_text\":\"$bluetooth_device_text\"},"
}

function get_internet_speed() {
  local speed_text
  local current_time=$SECONDS
  local time_diff=$(( current_time - PREV_SPEED_TIME ))
  (( time_diff < 1 )) && return
  local active_interface
  [[ -f "$NETWORK_INTERFACE_FILE" ]] && active_interface=$(timeout 0.2s cat "$NETWORK_INTERFACE_FILE" || echo "err")
  if [[ -n "$active_interface" ]]; then
    local rx_bytes=$(timeout 0.2s cat "/sys/class/net/$active_interface/statistics/rx_bytes" || echo "0")
    local tx_bytes=$(timeout 0.2s cat "/sys/class/net/$active_interface/statistics/tx_bytes" || echo "0")
    if (( PREV_RX_BYTES > 0 )); then
      local rx_speed=$((( rx_bytes - PREV_RX_BYTES) / time_diff ))
      local tx_speed=$((( tx_bytes - PREV_TX_BYTES) / time_diff ))
      local download_speed=$(format_network_speed $rx_speed)
      local upload_speed=$(format_network_speed $tx_speed)
      speed_text="${internet_speed_icons[0]} $download_speed ${internet_speed_icons[1]} $upload_speed"
    else
      speed_text="calculating..."
    fi
    PREV_RX_BYTES=$rx_bytes
    PREV_TX_BYTES=$tx_bytes
    PREV_SPEED_TIME=$current_time
  else
    speed_text=""
  fi
  FUNC_OUTPUTS[internet_speed]="{\"name\":\"internet_speed\",\"full_text\":\"$speed_text\"},"
}

# -----------------------------------------------------------------------------
# Utils
# -----------------------------------------------------------------------------

function format_network_speed() {
  local bytes=$1
  if (( bytes >= 1073741824 )); then
    printf "%.1f GB/s" "$(( bytes * 10 / 1073741824 ))e-1"
  elif (( bytes >= 1048576 )); then
    printf "%.1f MB/s" "$(( bytes * 10 / 1048576 ))e-1"
  elif (( bytes >= 1024 )); then
    printf "%.1f KB/s" "$(( bytes * 10 / 1024 ))e-1"
  else
    printf "%d B/s" "$bytes"
  fi
}

# -----------------------------------------------------------------------------
# Main loop
# -----------------------------------------------------------------------------

i3status | while :
do
  read line
  for func in get_internet_speed get_bluetooth; do
    $func || true
  done
  echo "$line" | sed 's|{\"name|'"${FUNC_OUTPUTS[internet_speed]:-}${FUNC_OUTPUTS[bluetooth]:-}"'{\"name|' || exit 1
done
