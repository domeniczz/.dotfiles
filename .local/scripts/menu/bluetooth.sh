#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Bluetooth devices menu
# ------------------------------------------------------------------------------

declare -a device_names=()
declare -A device_map=()

get_saved_devices() {
  while read -r _ mac name; do
    device_names+=("$name")
    device_map["$name"]="$mac"
  done < <(bluetoothctl devices)

  if [[ ${#device_names[@]} -eq 0 ]]; then
    echo "No Bluetooth devices found" >&2
    exit 1
  fi
}

connect_device() {
  local device_name="$1"
  local mac="${device_map[$device_name]}"

  if [[ -n "$mac" ]]; then
    bluetoothctl connect "$mac"
  else
    exit 1
  fi
}

get_saved_devices

selected_device=$(printf '%s\n' "${device_names[@]}" | bemenu \
  --single-instance \
  --no-overlap \
  --prompt "Connect bluetooth device:" \
  --list ${#device_names[@]} \
  --prefix "" \
  --ignorecase \
  --fork \
  --center \
  --no-spacing \
  --scrollbar "none" \
  --ch 20 \
  --cw 2 \
  --width-factor 0.25 \
  --border 1 \
  --border-radius 6 \
  --line-height 30 \
  --fn "hack nerd font 10" \
  --bdr "#3d86ae" \
  --tb "#434446" \
  --fb "#434446" \
  --ab "#434446" \
  --nb "#434446" \
  --tf "#2596be" \
  --ff "#2596be" \
  --hf "#31f6ff" \
  --af "#ffffff" \
  --nf "#ffffff"
)

if [[ -n "$selected_device" ]]; then
  connect_device "$selected_device"
else
  echo "No device selected" >&2
  exit 1
fi
