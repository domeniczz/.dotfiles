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

shopt -s histappend
shopt -s histverify
shopt -s cmdhist
shopt -s lithist
shopt -s autocd
shopt -s globstar
shopt -s checkwinsize
shopt -s checkjobs
shopt -s direxpand

source /usr/share/bash-completion/bash_completion

source $XDG_CONFIG_HOME/shell/shellrc
source $XDG_CONFIG_HOME/shell/alias
source $XDG_CONFIG_HOME/shell/teleport
