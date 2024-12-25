#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Application launch menu
# -----------------------------------------------------------------------------

application=$(bemenu-run \
  --single-instance \
  --no-overlap \
  --accept-single \
  --prompt "" \
  --list 10 \
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

if [[ -n "$selected_clip" ]]; then
  swaymsg exec $application
fi
