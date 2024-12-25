#!/usr/bin/env bash

selected=`cat $TMUX_CONF_PATH/.tmux-cht-languages $TMUX_CONF_PATH/.tmux-cht-command | fzf`

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
