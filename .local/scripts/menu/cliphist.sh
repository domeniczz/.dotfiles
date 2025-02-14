#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Clipboard history menu
# -----------------------------------------------------------------------------

selected_clip=$(cliphist list  | bemenu \
  --single-instance \
  --no-overlap \
  --prompt "" \
  --list 15 \
  --prefix "" \
  --ignorecase \
  --fork \
  --center \
  --no-spacing \
  --scrollbar "none" \
  --ch 20 \
  --cw 2 \
  --width-factor 0.45 \
  --border 1 \
  --border-radius 6 \
  --line-height 30 \
  --fn "hack nerd font 10" \
  --bdr "#f5b223" \
  --tb "#434446" \
  --fb "#434446" \
  --ab "#434446" \
  --nb "#434446" \
  --tf "#f5b223" \
  --ff "#f5b223" \
  --hf "#ffc23f" \
  --af "#ffffff" \
  --nf "#ffffff"
)

if [[ -n "$selected_clip" ]]; then
  echo "$selected_clip" | cliphist decode | wl-copy
fi
