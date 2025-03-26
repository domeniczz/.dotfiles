#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Disable laptop display on lid off when connected to an external monitor
# Otherwise, only turn off laptop display without disabling it
# ------------------------------------------------------------------------------

ACTION=$1
LAPTOP="eDP-1"

function has_external_display() {
  external_displays=$(swaymsg -t get_outputs | jq -r '.[] | select(.name != "'$LAPTOP'" and .active == true) | .name')
  [[ -n "$external_displays" ]]
}

function any_display_active() {
  active_displays=$(swaymsg -t get_outputs | jq -r '.[] | select(.active == true) | .name')
  [[ -n "$active_displays" ]]
}

if [[ "$ACTION" == "close" ]]; then
  if has_external_display; then
    swaymsg "output $LAPTOP disable"
    swaymsg "output $LAPTOP dpms off"
  else
    swaymsg "output $LAPTOP dpms off"
  fi
elif [[ "$ACTION" == "open" ]]; then
  if has_external_display || ! any_display_active; then
    swaymsg "output $LAPTOP enable"
    swaymsg "output $LAPTOP dpms on"
  else
    swaymsg "output $LAPTOP dpms on"
  fi
fi
