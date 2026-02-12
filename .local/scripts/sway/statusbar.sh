#!/usr/bin/env bash

# set -euo pipefail

# ------------------------------------------------------------------------------
# Sway window manager status bar
# ------------------------------------------------------------------------------

# The Sway configuration file in ~/.config/sway/config calls this script.
# You should see changes to the status bar after saving this script.
# If not, do "killall swaybar" and $mod+Shift+c to reload the configuration.

declare -gr BATTERY_CRITICAL_THRESHOLD=25

declare -g REFRESH_INTERVAL=0.2

# Nerd font icons
declare -gr battery_icons=("󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
declare -gr battery_charging_icons=("󰢟" "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
declare -gr volume_icons=("󰖁" "󰕿" "󰖀" "󰕾")
declare -gr brightness_icons=("󰃞" "󰃟" "󰃠")
declare -gr wifi_icons=("󰖪" "󰖩")
declare -gr ethernet_icon="󰈀"
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

for path in /sys/class/power_supply/BAT*; do
    [[ -d "$path" ]] || continue
    capacity_file="$path/capacity"
    present_file="$path/present"
    [[ -f "$capacity_file" ]] || continue
    if [[ -f "$present_file" ]]; then
        (( $(cat "$present_file" 2>/dev/null || echo "0") == 1 )) || continue
    fi
    declare -gr BAT_PATH="$capacity_file"
    break
done

for path in /sys/class/power_supply/{AC,ADP,ACAD}*/online; do
    [[ -f "$path" ]] && {
        declare -gr AC_PATH=$path
        break
    }
done

for path in /sys/class/backlight/*/brightness; do
    [[ -f "$path" ]] && {
        declare -gr BACKLIGHT_PATH=$path
        declare -gr BACKLIGHT_MAX_PATH="${path%/*}/max_brightness"
        break
    }
done

declare -g CACHE_BACKLIGHT_MAX="$(cat "$BACKLIGHT_MAX_PATH" || echo "255")"

# ------------------------------------------------------------------------------
# Monitor network interface & connection changes
# ------------------------------------------------------------------------------

declare -g WIFI_NAME_FILE="/tmp/wifi_name"
declare -a NETWORK_INTERFACES
declare -g NETWORK_INTERFACE_FILE="/tmp/network_interface"
declare -g IFACE_MONITOR_PID=""

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
    local prev_iface=""
    while true; do
        if (( ${#NETWORK_INTERFACES[@]} == 0 )); then
            echo "" > $NETWORK_INTERFACE_FILE
            echo "" > $WIFI_NAME_FILE
            sleep 5
            get_all_network_interfaces
            continue
        fi
        local found_up_iface=false
        for iface in "${NETWORK_INTERFACES[@]}"; do
            [[ ! -f "/sys/class/net/${iface}/operstate" ]] && continue
            state=$(cat "/sys/class/net/${iface}/operstate" || echo "err")
            if [[ "$state" == "up" ]]; then
                echo "${iface}" > $NETWORK_INTERFACE_FILE
                current_network_conn=$(nmcli --terse --fields NAME connection show --active | head -n1 || echo "err")
                echo "$current_network_conn" > "$WIFI_NAME_FILE"
                if [[ "$iface" != "$prev_iface" ]]; then
                    prev_iface="$iface"
                fi
                found_up_iface=true
                break
            fi
        done
        if [[ $found_up_iface == "false" ]]; then
            echo "" > $NETWORK_INTERFACE_FILE
            echo "" > $WIFI_NAME_FILE
            prev_iface=""
        fi
        sleep 2
    done
}

monitor_active_interfaces &
IFACE_MONITOR_PID=$!

# ------------------------------------------------------------------------------
# Get status
# ------------------------------------------------------------------------------

function send_battery_alert() {
    notify-send \
        --urgency=critical \
        --app-name="Battery Monitor" \
        "Critical Battery Alert" \
        "Battery level is below ${BATTERY_CRITICAL_THRESHOLD}%\nPlease charge immediately!" \
        || true
    }

function get_battery() {
    [[ -z "${BAT_PATH:-}" ]] && return
    local battery_pct battery_color ac_state icon
    local battery_color="#ffffff"
    battery_pct=$(cat "$BAT_PATH" 2>/dev/null || echo "0")
    ac_state=$(cat "$AC_PATH" 2>/dev/null || echo "0")
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

function get_volume() {
    local volume_info volume_pct icon icon_index
    volume_pct=$(pactl get-sink-volume @DEFAULT_SINK@ | sed -n '/Volume:/{s/.*\/[[:space:]]*\([0-9]\+\)%.*/\1/p;q}' || echo "0")
    volume_is_mute=$(pactl get-sink-mute @DEFAULT_SINK@ | cut -d' ' -f2 || echo "yes")
    if [[ $volume_is_mute == "yes" ]]; then
        icon_index=0
    else
        icon_index=$(( (volume_pct == 0) ? 0 : 1 + (volume_pct > 50) + (volume_pct > 10) ))
    fi
    icon=${volume_icons[icon_index]}
    FUNC_OUTPUTS[volume]="{\"name\":\"volume\",\"full_text\":\"$icon $volume_pct%\"},"
}

function get_brightness() {
    [[ -z "${BACKLIGHT_PATH:-}" ]] && return
    local brightness_pct icon
    current_brightness=$(cat "$BACKLIGHT_PATH" || echo "0")
    brightness_pct=$(( (current_brightness * 100 + CACHE_BACKLIGHT_MAX / 2) / CACHE_BACKLIGHT_MAX ))
    icon=${brightness_icons[$(( (brightness_pct * 3 - 1) / 100 ))]}
    FUNC_OUTPUTS[brightness]="{\"name\":\"brightness\",\"full_text\":\"$icon $brightness_pct%\"},"
}

function get_internet() {
    local conn_name icon
    local active_interface
    [[ -f "$NETWORK_INTERFACE_FILE" ]] && active_interface=$(cat "$NETWORK_INTERFACE_FILE" || echo "")
    [[ -f "$WIFI_NAME_FILE" ]] && conn_name=$(cat "$WIFI_NAME_FILE" || echo "")
    if [[ -z "$active_interface" || -z "$conn_name" ]]; then
        icon=${wifi_icons[0]}
        FUNC_OUTPUTS[internet]="{\"name\":\"internet\",\"full_text\":\"$icon Disconnected\"},"
        return
    fi
    if [[ -d "/sys/class/net/$active_interface/wireless" ]]; then
        icon=${wifi_icons[1]}
    else
        icon=$ethernet_icon
    fi
    FUNC_OUTPUTS[internet]="{\"name\":\"internet\",\"full_text\":\"$icon $conn_name\"},"
}

function get_bluetooth() {
    local bluetooth_device icon
    local bluetooth_device_text=""
    BLUETOOTH_COUNT=$(bluetoothctl devices Connected | grep --fixed-strings --color=never 'Device ' | wc -l || echo "-1")
    (( BLUETOOTH_COUNT < BLUETOOTH_PREV_COUNT )) && playerctl pause || true
    BLUETOOTH_PREV_COUNT=$BLUETOOTH_COUNT
    if (( BLUETOOTH_COUNT > 0 )); then
        icon=${bluetooth_icons[1]}
        while IFS= read -r device; do
            [[ -n "$bluetooth_device_text" ]] && bluetooth_device_text+=" "
            bluetooth_device_text+="$icon $device"
        done < <(bluetoothctl devices Connected | grep --fixed-strings --color=never 'Device ' | cut -d' ' -f3- || echo "err")
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
    [[ -f "$NETWORK_INTERFACE_FILE" ]] && active_interface=$(cat "$NETWORK_INTERFACE_FILE" || echo "err")
    if [[ -n "$active_interface" ]]; then
        local rx_bytes=$(cat "/sys/class/net/$active_interface/statistics/rx_bytes" || echo "0")
        local tx_bytes=$(cat "/sys/class/net/$active_interface/statistics/tx_bytes" || echo "0")
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

function get_cpu_usage() {
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

function get_active_window() {
    local window_name
    window_name=$(swaymsg -t get_tree 2>/dev/null | jq -r 'first(.. | objects | select(.focused==true)).name // empty' 2>/dev/null || echo "")
    if [[ -n "$window_name" ]]; then
        (( ${#window_name} > 60 )) && window_name="${window_name:0:57}..."
        FUNC_OUTPUTS[active_window]="{\"name\":\"active_window\",\"full_text\":\"$window_name\"},"
    else
        FUNC_OUTPUTS[active_window]=""
    fi
}

function get_date() {
    FUNC_OUTPUTS[date]="{\"name\":\"date\",\"full_text\":\"$(date "+%a %F %H:%M:%S")\"},"
}

# ------------------------------------------------------------------------------
# Utils
# ------------------------------------------------------------------------------

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

function log_abort() {
    local log_file="/tmp/statusbar.log"
    local line="${BASH_LINENO[0]}"
    local source="${BASH_SOURCE[1]:-$0}"
    local command="${BASH_COMMAND}"
    printf "[%s] SIGNAL: abort received during '%s' at %s:%s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$command" "$source" "$line" >> "$log_file"
    printf "[%s] Process terminating due to signal abort\n" "$(date '+%Y-%m-%d %H:%M:%S')" >> "$log_file"
}

trap log_abort ABRT

function cleanup() {
    if [[ -n "$IFACE_MONITOR_PID" && -e /proc/$IFACE_MONITOR_PID ]]; then
        kill $IFACE_MONITOR_PID 2>/dev/null
    fi
    rm -f "$WIFI_NAME_FILE" "$NETWORK_INTERFACE_FILE"
    exit 0
}

trap cleanup EXIT INT TERM QUIT PIPE

# ------------------------------------------------------------------------------
# Main function
# ------------------------------------------------------------------------------

echo '{"version":1,"click_events":false}'
echo '[[],'

function main() {
    local iteration_count=0

    local -a funcs=(
        "get_date"
        "get_volume"
        "get_bluetooth"
        "get_internet"
        "get_battery"
        "get_brightness"
        "get_internet_speed"
        "get_cpu_usage"
        "get_active_window"
    )

    for func in "${funcs[@]}"; do
        $func || true
    done
    while true; do
        if [[ -n "$IFACE_MONITOR_PID" && ! -e /proc/$IFACE_MONITOR_PID ]]; then
            cleanup
            monitor_active_interfaces &
            IFACE_MONITOR_PID=$!
        fi

        for func in "${funcs[@]}"; do
            if [[ "$func" == "get_active_window" ]]; then
                $func || true
            elif [[ "$func" == "get_battery" ]] && (( iteration_count % 10 == 0 )); then
                $func || true
            elif (( iteration_count % 5 == 0 )); then
                $func || true
            fi
        done

        printf '[%s%s%s%s%s%s%s%s%s],' \
            "${FUNC_OUTPUTS[active_window]:-}" \
            "${FUNC_OUTPUTS[internet_speed]:-}" \
            "${FUNC_OUTPUTS[cpu]:-}" \
            "${FUNC_OUTPUTS[bluetooth]:-}" \
            "${FUNC_OUTPUTS[internet]:-}" \
            "${FUNC_OUTPUTS[brightness]:-}" \
            "${FUNC_OUTPUTS[volume]:-}" \
            "${FUNC_OUTPUTS[battery]:-}" \
            "${FUNC_OUTPUTS[date]:-}"

        (( iteration_count++ ))
        sleep $REFRESH_INTERVAL
    done
}

main
