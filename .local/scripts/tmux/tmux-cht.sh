#!/usr/bin/env bash

set -euo pipefail

# ------------------------------------------------------------------------------
# Get cheat sheet of specific thing of specific language with chubin/cheat.sh
# ------------------------------------------------------------------------------

TMUX_CONF_PATH="$XDG_CONFIG_HOME/tmux"

selected=`cat $TMUX_CONF_PATH/.tmux-cht-languages $TMUX_CONF_PATH/.tmux-cht-command | sort --reverse | fzf`

if [[ -z $selected ]]; then
  exit 0
fi

read -p "Enter Query: " query

query=`echo $query | tr ' ' '+'`

if grep -qs "$selected" $TMUX_CONF_PATH/.tmux-cht-languages; then
  tmux new-window -n "ctsh" bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
else
  tmux new-window -n "ctsh" bash -c "curl -s cht.sh/$selected~$query | less"
fi
