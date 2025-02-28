#!/usr/bin/env bash

declare -gr BATTERY_CRITICAL_THRESHOLD=15

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

# -----------------------------------------------------------------------------
# Monitor network interface & connection changes
# -----------------------------------------------------------------------------

declare -a NETWORK_INTERFACES
declare -g NETWORK_INTERFACE_FILE="/tmp/network_interface"

get_all_network_interfaces() {
  for iface in /sys/class/net/*; do
    name=$(basename "$iface")
    if [[ "$name" != "lo" ]]; then
      NETWORK_INTERFACES+=("$name")
    fi
  done
}

get_all_network_interfaces

monitor_active_interfaces() {
  while true; do
    if ((${#NETWORK_INTERFACES[@]} == 0)); then
      echo "" > $NETWORK_INTERFACE_FILE
      sleep 5
      get_all_network_interfaces
      continue
    fi
    for iface in "${NETWORK_INTERFACES[@]}"; do
      if [[ -f "/sys/class/net/${iface}/operstate" ]]; then
        state=$(timeout 0.2s cat "/sys/class/net/${iface}/operstate")
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

monitor_active_interfaces &

# -----------------------------------------------------------------------------
# Get status
# -----------------------------------------------------------------------------

get_bluetooth() {
  local bluetooth_device icon
  BLUETOOTH_COUNT=$(timeout 0.2s bluetoothctl devices Connected | wc -l || echo "-1")
  ((BLUETOOTH_COUNT < BLUETOOTH_PREV_COUNT)) && timeout 0.2s playerctl pause
  if ((BLUETOOTH_COUNT > 0)); then
    bluetooth_device=$(timeout 0.2s bluetoothctl devices Connected | cut -d' ' -f3- || echo "Error")
    icon=${bluetooth_icons[1]}
  else
    icon=${bluetooth_icons[0]}
  fi
  FUNC_OUTPUTS[bluetooth]="{\"name\":\"bluetooth\",\"full_text\":\"$icon $bluetooth_device\"},"
}

get_internet_speed() {
  local speed_text
  local current_time=$SECONDS
  local time_diff=$((current_time - PREV_SPEED_TIME))
  ((time_diff < 1)) && return
  local active_interface
  [[ -f "$NETWORK_INTERFACE_FILE" ]] && active_interface=$(timeout 0.2s cat "$NETWORK_INTERFACE_FILE" || echo "Error")
  if [[ -n "$active_interface" ]]; then
    local rx_bytes=$(timeout 0.2s cat "/sys/class/net/$active_interface/statistics/rx_bytes" || echo "0")
    local tx_bytes=$(timeout 0.2s cat "/sys/class/net/$active_interface/statistics/tx_bytes" || echo "0")
    if ((PREV_RX_BYTES > 0)); then
      local rx_speed=$(((rx_bytes - PREV_RX_BYTES) / time_diff))
      local tx_speed=$(((tx_bytes - PREV_TX_BYTES) / time_diff))
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

format_network_speed() {
  local bytes=$1
  if ((bytes >= 1073741824)); then
    printf "%.1f GB/s" "$((bytes * 10 / 1073741824))e-1"
  elif ((bytes >= 1048576)); then
    printf "%.1f MB/s" "$((bytes * 10 / 1048576))e-1"
  elif ((bytes >= 1024)); then
    printf "%.1f KB/s" "$((bytes * 10 / 1024))e-1"
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
  echo "$line" | sed 's|{\"name|'"${FUNC_OUTPUTS[internet_speed]}${FUNC_OUTPUTS[bluetooth]}"'{\"name|' || exit 1
done
