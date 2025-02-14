# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='$([[ $EUID == 0 ]] && echo "\u@" || echo "")\h \W\$ '

HISTSIZE=1000
HISTFILESIZE=10000
HISTFILE=$HOME/.bash_history
# Do not put duplicate lines or lines starting starting with space into history
HISTCONTROL=ignoreboth

[[ -n $INCOGNITO ]] && unset HISTFILE && PS1="[Incognito] $PS1"

source $HOME/.config/shell/shellrc
source $HOME/.config/shell/alias
source $HOME/.config/shell/teleport
