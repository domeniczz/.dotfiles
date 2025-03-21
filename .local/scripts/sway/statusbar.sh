#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Sway window manager status bar
# ------------------------------------------------------------------------------

# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

declare -gr BATTERY_CRITICAL_THRESHOLD=25

declare -g REFRESH_INTERVAL=1

# Nerd font icons
declare -gr battery_icons=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
declare -gr battery_charging_icons=("󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
declare -gr volume_icons=("󰖁" "󰕿" "󰖀" "󰕾")
declare -gr brightness_icons=("󰃞" "󰃟" "󰃠")
declare -gr wifi_icons=("󰖪" "󰖩")
declare -gr bluetooth_icons=("󰂲" "󰂱")
declare -gr internet_speed_icons=("" "")
declare -gr cpu_usage_icon=""

declare -g BATTERY_ALERT_STATE=0
declare -g BLUETOOTH_COUNT=0
declare -g BLUETOOTH_PREV_COUNT=0
declare -g PREV_RX_BYTES=0
declare -g PREV_TX_BYTES=0
declare -g PREV_SPEED_TIME=0
declare -g PREV_CPU_STATS=""

declare -A FUNC_OUTPUTS

declare -gr CPU_STAT_PATH="/proc/stat"
declare -gr BAT_PATH="/sys/class/power_supply/BAT0/capacity"

for path in /sys/class/power_supply/{AC,ADP,ACAD}*/online; do
  [[ -f "$path" ]] && { declare -gr AC_PATH=$path; break; }
done

for path in /sys/class/backlight/*/actual_brightness; do
  [[ -f "$path" ]] && {
    declare -gr BACKLIGHT_PATH=$path
    declare -gr BACKLIGHT_MAX_PATH="${path%/*}/max_brightness"
    break
  }
done

# ------------------------------------------------------------------------------
# Monitor network interface & connection changes
# ------------------------------------------------------------------------------

declare -g WIFI_NAME_FILE="/tmp/wifi_name"
declare -a NETWORK_INTERFACES
declare -g NETWORK_INTERFACE_FILE="/tmp/network_interface"

get_all_network_interfaces() {
  for iface in /sys/class/net/*; do
    name=$(basename "$iface")
    [[ "$name" == "lo" ]] && continue
    NETWORK_INTERFACES+=("$name")
  done
}

get_all_network_interfaces

monitor_active_interfaces() {
  local prev_iface=""
  while true; do
    if (( ${#NETWORK_INTERFACES[@]} == 0 )); then
      echo "" > $NETWORK_INTERFACE_FILE
      echo "" > $WIFI_NAME_FILE
      sleep 5
      get_all_network_interfaces
      continue
    fi
    for iface in "${NETWORK_INTERFACES[@]}"; do
      [[ ! -f "/sys/class/net/${iface}/operstate" ]] && continue
      state=$(timeout 0.2s cat "/sys/class/net/${iface}/operstate")
      if [[ "$state" == "up" ]]; then
        echo "${iface}" > $NETWORK_INTERFACE_FILE
        current_network_conn=$(timeout 0.2s nmcli --terse --fields NAME connection show --active | head -n1 || echo "Error")
        echo "$current_network_conn" > "$WIFI_NAME_FILE"
        if [[ "$iface" != "$prev_iface" ]]; then
          prev_iface="$iface"
        fi
        break
      else
        echo "" > $NETWORK_INTERFACE_FILE
        prev_iface=""
      fi
    done
    sleep 2
  done
}

monitor_active_interfaces &

# ------------------------------------------------------------------------------
# Get status
# ------------------------------------------------------------------------------

send_battery_alert() {
  timeout 0.2s notify-send \
    --urgency=critical \
    --app-name="Battery Monitor" \
    --category="device.warning" \
    "Critical Battery Alert" \
    "Battery level is below ${BATTERY_CRITICAL_THRESHOLD}%\nPlease charge immediately!"
}

get_battery() {
  local battery_pct battery_color ac_state icon
  local battery_color="#ffffff"
  battery_pct=$(timeout 0.2s cat "$BAT_PATH" 2>/dev/null || echo "0")
  ac_state=$(timeout 0.2s cat "$AC_PATH" 2>/dev/null || echo "0")
  if (( ac_state == 1 )); then
    icon=${battery_charging_icons[$((battery_pct/10))]}
  else
    icon=${battery_icons[$((battery_pct/10))]}
    if (( battery_pct <= BATTERY_CRITICAL_THRESHOLD )); then
      battery_color="#f52d14"
    fi
    if (( battery_pct <= BATTERY_CRITICAL_THRESHOLD && BATTERY_ALERT_STATE == 0 )); then
      send_battery_alert
      BATTERY_ALERT_STATE=1
    elif (( battery_pct > BATTERY_CRITICAL_THRESHOLD && BATTERY_ALERT_STATE == 1 )); then
      BATTERY_ALERT_STATE=0
    fi
  fi
  FUNC_OUTPUTS[battery]="{\"name\":\"battery\",\"full_text\":\"$icon $battery_pct%\",\"color\":\"$battery_color\"},"
}

get_volume() {
  local volume_info volume_pct icon icon_index
  volume_pct=$(timeout 0.2s pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//' || echo "0")
  volume_is_mute=$(timeout 0.2s pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}' || echo "yes")
  if [[ $volume_is_mute == "yes" ]]; then
    icon_index=0
  else
    icon_index=$(( (volume_pct == 0) ? 0 : 1 + (volume_pct > 50) + (volume_pct > 10) ))
  fi
  icon=${volume_icons[icon_index]}
  FUNC_OUTPUTS[volume]="{\"name\":\"volume\",\"full_text\":\"$icon $volume_pct%\"},"
}

get_brightness() {
  local brightness_pct icon
  current_brightness=$(timeout 0.2s cat "$BACKLIGHT_PATH" || echo "0")
  max_brightness=$(timeout 0.2s cat "$BACKLIGHT_MAX_PATH" || echo "0")
  brightness_pct=$(( current_brightness * 100 / max_brightness ))
  icon=${brightness_icons[$(( (brightness_pct * 3 - 1) / 100 ))]}
  FUNC_OUTPUTS[brightness]="{\"name\":\"brightness\",\"full_text\":\"$icon $brightness_pct%\"},"
}

get_wifi() {
  local wifi_name
  [[ -f "$WIFI_NAME_FILE" ]] && wifi_name=$(timeout 0.2s cat "$WIFI_NAME_FILE" || echo "Error")
  if [[ -z "$wifi_name" || "$wifi_name" == "lo" ]]; then
    icon=${wifi_icons[0]}
  else
    icon=${wifi_icons[1]}
  fi
  FUNC_OUTPUTS[wifi]="{\"name\":\"wifi\",\"full_text\":\"$icon $wifi_name\"},"
}

get_bluetooth() {
  local bluetooth_device icon
  BLUETOOTH_COUNT=$(timeout 0.2s bluetoothctl devices Connected | wc -l || echo "-1")
  (( BLUETOOTH_COUNT < BLUETOOTH_PREV_COUNT )) && timeout 0.2s playerctl pause
  BLUETOOTH_PREV_COUNT=$BLUETOOTH_COUNT
  if (( BLUETOOTH_COUNT > 0 )); then
    bluetooth_device=$(timeout 0.2s bluetoothctl devices Connected | cut -d' ' -f3- || echo "Error")
    icon=${bluetooth_icons[1]}
  else
    bluetooth_device=""
    icon=${bluetooth_icons[0]}
  fi
  FUNC_OUTPUTS[bluetooth]="{\"name\":\"bluetooth\",\"full_text\":\"$icon $bluetooth_device\"},"
}

get_internet_speed() {
  local speed_text
  local current_time=$SECONDS
  local time_diff=$(( current_time - PREV_SPEED_TIME ))
  (( time_diff < 1 )) && return
  local active_interface
  [[ -f "$NETWORK_INTERFACE_FILE" ]] && active_interface=$(timeout 0.2s cat "$NETWORK_INTERFACE_FILE" || echo "Error")
  if [[ -n "$active_interface" ]]; then
    local rx_bytes=$(timeout 0.2s cat "/sys/class/net/$active_interface/statistics/rx_bytes" || echo "0")
    local tx_bytes=$(timeout 0.2s cat "/sys/class/net/$active_interface/statistics/tx_bytes" || echo "0")
    if (( PREV_RX_BYTES > 0 )); then
      local rx_speed=$(( (rx_bytes - PREV_RX_BYTES) / time_diff ))
      local tx_speed=$(( (tx_bytes - PREV_TX_BYTES) / time_diff ))
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

get_cpu_usage() {
  local cpu_stats current_stats
  local user_1 nice_1 system_1 idle_1 total_1
  local user_2 nice_2 system_2 idle_2 total_2
  local cpu_usage_text=""
  read -r cpu_stats < "$CPU_STAT_PATH" || return
  if [[ -z "$PREV_CPU_STATS" ]]; then
    PREV_CPU_STATS="$cpu_stats"
    FUNC_OUTPUTS[cpu]=""
    return
  fi
  read -r _ user_1 nice_1 system_1 idle_1 _ <<< "$PREV_CPU_STATS"
  total_1=$(( user_1 + nice_1 + system_1 + idle_1 ))
  read -r _ user_2 nice_2 system_2 idle_2 _ <<< "$cpu_stats"
  total_2=$(( user_2 + nice_2 + system_2 + idle_2 ))
  local delta_total=$(( total_2 - total_1 ))
  local delta_idle=$(( idle_2 - idle_1 ))
  if ((delta_total > 0)); then
    local cpu_usage=$(( 100 * (delta_total - delta_idle) / delta_total ))
    cpu_usage_text="$cpu_usage_icon $cpu_usage%"
  fi
  PREV_CPU_STATS="$cpu_stats"
  FUNC_OUTPUTS[cpu]="{\"name\":\"cpu\",\"full_text\":\"${cpu_usage_text}\"},"
}

get_date() {
  FUNC_OUTPUTS[date]="{\"name\":\"date\",\"full_text\":\"$(date "+%a %F %H:%M:%S")\"},"
}

# ------------------------------------------------------------------------------
# Utils
# ------------------------------------------------------------------------------

format_network_speed() {
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

# ------------------------------------------------------------------------------
# Main loop
# ------------------------------------------------------------------------------

echo '{"version":1,"click_events":false}'
echo '[[],'

while true; do
  for func in get_volume get_date get_bluetooth get_wifi get_battery get_brightness get_internet_speed get_cpu_usage; do
    $func || true
  done

  printf '[%s%s%s%s%s%s%s%s],' \
    "${FUNC_OUTPUTS[internet_speed]:-}" \
    "${FUNC_OUTPUTS[cpu]:-}" \
    "${FUNC_OUTPUTS[bluetooth]:-}" \
    "${FUNC_OUTPUTS[wifi]:-}" \
    "${FUNC_OUTPUTS[brightness]:-}" \
    "${FUNC_OUTPUTS[battery]:-}" \
    "${FUNC_OUTPUTS[volume]:-}" \
    "${FUNC_OUTPUTS[date]:-}"

  sleep $REFRESH_INTERVAL
done
