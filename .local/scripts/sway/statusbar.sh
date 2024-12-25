#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Sway window manager status bar
# -----------------------------------------------------------------------------

# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

readonly BATTERY_CRITICAL_THRESHOLD=15

REFRESH_INTERVAL=1
# Update refresh_interval when receiving signal from other process
trap 'REFRESH_INTERVAL=$(cat /tmp/sway_refresh_interval)' SIGUSR1

# Nerd font icons
readonly battery_icons=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
readonly battery_charging_icons=("󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
readonly volume_icons=("󰖁" "󰕿" "󰖀" "󰕾")
readonly wifi_icons=("󰖪" "󰖩")
readonly bluetooth_icons=("󰂲" "󰂱")

# State variables
BLUETOOTH_COUNT=0
BLUETOOTH_PREV_COUNT=0
BATTERY_ALERT_STATE=0

declare -A FUNC_OUTPUTS

readonly BAT_PATH="/sys/class/power_supply/BAT0/capacity"
for path in /sys/class/power_supply/{AC,ADP,ACAD}*/online; do
  [[ -f "$path" ]] && { readonly AC_PATH=$path; break; }
done

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------

send_battery_alert() {
  notify-send \
    --urgency=critical \
    --expire-time=0 \
    --app-name="Battery Monitor" \
    --category="device.warning" \
    "Critical Battery Alert" \
    "Battery level is below ${BATTERY_CRITICAL_THRESHOLD}%\nPlease charge immediately"
}

get_battery() {
  local battery_pct ac_state icon
  battery_pct=$(<"$BAT_PATH")
  ac_state=$(<"$AC_PATH")

  if [[ "$ac_state" == "1" ]]; then
    icon=${battery_charging_icons[$((battery_pct/10))]}
  else
    icon=${battery_icons[$((battery_pct/10))]}
    if ((battery_pct <= BATTERY_CRITICAL_THRESHOLD && BATTERY_ALERT_STATE == 0)); then
      send_battery_alert
      BATTERY_ALERT_STATE=1
      battery_color="#f52b0f"
    elif ((battery_pct > BATTERY_CRITICAL_THRESHOLD && BATTERY_ALERT_STATE == 1)); then
      BATTERY_ALERT_STATE=0
      battery_color="#ffffff"
    fi
  fi
  # FUNC_OUTPUTS[battery]="$icon $battery_pct%"
  FUNC_OUTPUTS[battery]="{\"name\":\"battery\",\"full_text\":\"$icon $battery_pct%\",\"color\":\"$battery_color\"},"
}

get_volume() {
  local volume_info volume_pct icon
  volume_pct=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
  volume_is_mute=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
  if [[ $volume_is_mute == "yes" ]]; then
    icon=${volume_icons[0]}
  else
    icon=${volume_icons[$(($volume_pct == 0 ? 0 : 1 + ($volume_pct > 50) + ($volume_pct > 10)))]}
  fi
  # FUNC_OUTPUTS[volume]="$icon $volume_pct%"
  FUNC_OUTPUTS[volume]="{\"name\":\"volume\",\"full_text\":\"$icon $volume_pct%\"},"
}

get_wifi() {
  local wifi_name
  wifi_name=$(nmcli -t -f NAME connection show --active | rg -m 1 "^.*$")
  if [[ -z "$wifi_name" ]]; then
    icon=${wifi_icons[0]}
  else
    icon=${wifi_icons[1]}
  fi
  # FUNC_OUTPUTS[wifi]="$icon $wifi_name"
  FUNC_OUTPUTS[wifi]="{\"name\":\"wifi\",\"full_text\":\"$icon $wifi_name\"},"
}

get_bluetooth() {
  local bluetooth_device icon
  BLUETOOTH_COUNT=$(bluetoothctl devices Connected | wc -l)
  # Pause media playback on bluetooth disconnect
  if [[ "$BLUETOOTH_COUNT" -lt "$BLUETOOTH_PREV_COUNT" ]]; then
    playerctl pause
  fi
  BLUETOOTH_PREV_COUNT=$BLUETOOTH_COUNT
  bluetooth_device=$(bluetoothctl devices Connected | cut -d' ' -f3-)
  if [[ -z "$bluetooth_device" ]]; then
    icon=${bluetooth_icons[0]}
  else
    icon=${bluetooth_icons[1]}
  fi
  # FUNC_OUTPUTS[bluetooth]="$icon $bluetooth_device"
  FUNC_OUTPUTS[bluetooth]="{\"name\":\"bluetooth\",\"full_text\":\"$icon $bluetooth_device\"},"
}

get_date() {
  FUNC_OUTPUTS[date]="{\"name\":\"date\",\"full_text\":\"$(date "+%a %F %H:%M:%S")\"},"
}

# -----------------------------------------------------------------------------
# Main loop
# -----------------------------------------------------------------------------

echo '{"version":1,"click_events":true}'
echo '[[],'

while true; do
  if ((REFRESH_INTERVAL == 1)); then
    get_bluetooth
    get_wifi
    get_battery
  fi
  get_volume
  get_date

  blocks=""
  blocks+="${FUNC_OUTPUTS[bluetooth]}"
  blocks+="${FUNC_OUTPUTS[wifi]}"
  blocks+="${FUNC_OUTPUTS[battery]}"
  blocks+="${FUNC_OUTPUTS[volume]}"
  blocks+="${FUNC_OUTPUTS[date]}"
  printf '[%s],' "$blocks"

  # printf "%s | %s | %s | %s | %s" \
  #   "${FUNC_OUTPUTS[bluetooth]}" \
  #   "${FUNC_OUTPUTS[wifi]}" \
  #   "${FUNC_OUTPUTS[volume]}" \
  #   "${FUNC_OUTPUTS[battery]}" \
  #   "$(date "+%a %F %H:%M:%S")"
      
  sleep $REFRESH_INTERVAL
done
