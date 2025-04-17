#!/usr/bin/env bash

set -euo pipefail

# -----------------------------------------------------------------------------
# Adjust the system volume
# Disaply wob progress bar while changing volume
# -----------------------------------------------------------------------------

ACTION=""
VALUE=5

# ------------------------------------------------------------------------------
# Aruguments parsing
# ------------------------------------------------------------------------------

while (( $# > 0 )); do
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

# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

function get_current_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]\+%' | head -1 | tr -d '%'
}

function get_mute_status() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

function toggle_wob_progress_bar() {
    echo "$1" > /tmp/volume-wob-pipe
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

current_vol=$(get_current_volume)

case $ACTION in
    up)
        if [[ "$(get_mute_status)" == "yes" ]]; then
            pactl set-sink-mute @DEFAULT_SINK@ 0
        fi
        new_vol=$(( current_vol + VALUE ))
        if [[ $new_vol -gt 100 ]]; then
            pactl set-sink-volume @DEFAULT_SINK@ 100%
            toggle_wob_progress_bar 100
        else
            pactl set-sink-volume @DEFAULT_SINK@ +${VALUE}%
            toggle_wob_progress_bar "$new_vol"
        fi
        ;;
    down)
        if [[ "$(get_mute_status)" == "yes" ]]; then
            pactl set-sink-mute @DEFAULT_SINK@ 0
        fi
        pactl set-sink-volume @DEFAULT_SINK@ -${VALUE}%
        toggle_wob_progress_bar $(( current_vol > VALUE ? current_vol - VALUE : 0 ))
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        toggle_wob_progress_bar 0
        ;;
    micmute)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        ;;
esac
