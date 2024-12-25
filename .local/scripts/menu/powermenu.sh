#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Power buttons menu
# -----------------------------------------------------------------------------

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
  --tf "#cdd6f4" \
  --nb "#1e1e2e" \
  --nf "#cdd6f4" \
  --hb "#89b4fa" \
  --hf "#1e1e2e" \
  --fb "#1e1e2e" \
  --ff "#cdd6f4" \
  --ab "#1e1e2e" \
  --af "#cdd6f4")

case $selected in
  *"Suspend"*)
    systemctl suspend
    ;;
  *"Hibernate"*)
    systemctl hibernate
    ;;
  *"Reboot"*)
    systemctl reboot
    ;;
  *"Shutdown"*)
    systemctl poweroff
    ;;
esac
