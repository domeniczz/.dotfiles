# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='$([[ $EUID == 0 ]] && echo "\u@" || echo "")\h \W\$ '

HISTSIZE=5000
HISTFILESIZE=
HISTFILE=$HOME/.bash_history
# Do not put duplicate lines or lines starting starting with space into history
HISTCONTROL=ignoreboth

source $HOME/.shellrc
source $HOME/.alias
