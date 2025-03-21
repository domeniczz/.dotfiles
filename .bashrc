# If not running interactively, don't do anything
[[ $- != *i* ]] && return

function prompt_command {
  local pwd=${PWD/#$HOME/\~}
  local depth=$(echo "$pwd" | tr -cd '/' | wc -c)
  if ((depth >= 3)); then
    pwd=$(echo "$pwd" | rev | cut -d'/' -f1-3 | rev)
  fi
  local bg1="\[\e[48;2;58;64;85m\]"
  local bg2="\[\e[48;2;76;86;106m\]"
  local fg="\[\e[38;2;240;240;240m\]"
  local reset="\[\e[0m\]"
  PS1="${bg2}${fg} bash ${bg1} \u ${bg2} ${pwd} ${reset} ❯ "
  if ((INCOGNITO == 1)); then
    local incog_bg="\[\e[48;2;27;82;126m\]"
    PS1="${incog_bg}${fg} incognito ${reset}$PS1"
  fi
}

PROMPT_COMMAND=prompt_command

HISTSIZE=2000
HISTFILESIZE=100000
HISTFILE=$HOME/.bash_history
HISTCONTROL=ignoreboth

((INCOGNITO == 1)) && HISTFILESIZE=0

set -o vi

shopt -s autocd
shopt -s histappend
shopt -s histverify
shopt -s cmdhist
shopt -s lithist

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

bind "set completion-ignore-case on"
bind "set show-all-if-ambiguous on"
bind "set colored-stats on"
bind "set mark-symlinked-directories on"
bind "set show-all-if-unmodified on"
bind "set completion-map-case on"
bind "set menu-complete-display-prefix on"
bind 'set keyseq-timeout 5'

bind 'set show-mode-in-prompt on'
bind 'set vi-ins-mode-string "\1\e[2 q\2"'
bind 'set vi-cmd-mode-string "\1\e[4 q\2"'

source $XDG_CONFIG_HOME/shell/shellrc
source $XDG_CONFIG_HOME/shell/alias
source $XDG_CONFIG_HOME/shell/teleport
