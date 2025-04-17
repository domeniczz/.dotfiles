#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Power buttons menu
# ------------------------------------------------------------------------------

options=" Suspend\n⏼ Hibernate\n Reboot\n Shutdown"

selected=$(echo -e $options | bemenu \
    --single-instance \
    --no-overlap \
    --prompt "" \
    --list 4 \
    --ignorecase \
    --center \
    --no-spacing \
    --scrollbar "none" \
    --ch 20 \
    --cw 2 \
    --width-factor 0.15 \
    --border 1 \
    --border-radius 6 \
    --line-height 30 \
    --fn "hack nerd font 10" \
    --tb "#1e1e2e" \
    --fb "#1e1e2e" \
    --ab "#1e1e2e" \
    --nb "#1e1e2e" \
    --hb "#89b4fa" \
    --tf "#cdd6f4" \
    --ff "#cdd6f4" \
    --hf "#1e1e2e" \
    --af "#cdd6f4" \
    --nf "#cdd6f4")

case $selected in
    *"Suspend"*)
        playerctl --all-players stop || true
        systemctl suspend
        ;;
    *"Hibernate"*)
        brightnessctl set 100%
        playerctl --all-players stop || true
        systemctl hibernate
        ;;
    *"Reboot"*)
        systemctl reboot
        ;;
    *"Shutdown"*)
        systemctl poweroff
        ;;
esac
