#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Get cheat sheet of specific thing of specific language with chubin/cheat.sh
# ------------------------------------------------------------------------------

TMUX_CONF_PATH="$XDG_CONFIG_HOME/tmux"

selected=$(cat $TMUX_CONF_PATH/.tmux-cht-languages $TMUX_CONF_PATH/.tmux-cht-command | sort --reverse | fzf --prompt='cheat sheet > ')

[[ -z $selected ]] && exit 0

tput cup $(($(tput lines)-1)) 0
tput el
read -p "search query: " query

query=$(echo $query | tr ' ' '+')

LESS_CMD="less --use-color --wordwrap --RAW-CONTROL-CHARS --incsearch --ignore-case --mouse"

if grep -qs "$selected" "$TMUX_CONF_PATH/.tmux-cht-languages"; then
  tmux new-window -n "ctsh" bash -c "curl -s cht.sh/$selected/$query | $LESS_CMD"
else
  tmux new-window -n "ctsh" bash -c "curl -s cht.sh/$selected~$query | $LESS_CMD"
fi
