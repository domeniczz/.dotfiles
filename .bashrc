# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='bash > $([[ $EUID == 0 ]] && echo "\u@" || echo "")\W \$ '

HISTSIZE=1000
HISTFILESIZE=50000
HISTFILE=$HOME/.bash_history
# Do not put duplicate lines or lines starting starting with space into history
HISTCONTROL=ignoreboth

shopt -s autocd
shopt -s histverify

[[ -n $INCOGNITO ]] && HISTFILESIZE=0 && PS1="\[\e[34m\][Incognito]\[\e[0m\] $PS1"

source $HOME/.config/shell/shellrc
source $HOME/.config/shell/alias
source $HOME/.config/shell/teleport
