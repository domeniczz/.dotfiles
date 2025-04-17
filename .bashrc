# If not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTSIZE=2000
HISTFILESIZE=100000
HISTFILE=$XDG_DATA_HOME/.bash_history
HISTCONTROL=ignoreboth

shopt -s histappend
shopt -s histverify
shopt -s cmdhist
shopt -s lithist
shopt -s autocd
shopt -s globstar
shopt -s checkwinsize
shopt -s checkjobs
shopt -s direxpand

function git_branch_info {
    local ref=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
    [[ -z "$ref" ]] && ref=$(git describe --tags --always 2>/dev/null)
    [[ -n "$ref" ]] && echo "\[\e[48;2;0;101;50m\]\[\e[38;2;240;240;240m\] $ref \[\e[0m\]"
}

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
    local git=$(git_branch_info)
    PS1="${bg2}${fg} bash ${bg1} \u ${bg2} ${pwd} ${git}${reset} ❯ "
    if ((INCOGNITO == 1)); then
        local incog_bg="\[\e[48;2;27;82;126m\]"
        PS1="${incog_bg}${fg} incognito ${reset}$PS1"
    fi
}

PROMPT_COMMAND=prompt_command

((INCOGNITO == 1)) && history -r && HISTFILE=/dev/null

set -o vi

source /usr/share/bash-completion/bash_completion

source $XDG_CONFIG_HOME/shell/shellrc
source $XDG_CONFIG_HOME/shell/alias
source $XDG_CONFIG_HOME/shell/teleport
