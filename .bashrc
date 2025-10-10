[[ $- != *i* ]] && return

shopt -s histappend
shopt -s histverify
shopt -s cmdhist
shopt -s lithist
shopt -s autocd
shopt -s globstar
shopt -s checkwinsize
shopt -s checkjobs
shopt -s direxpand
shopt -s extglob

HISTFILE=$XDG_DATA_HOME/bash_history
HISTSIZE=2000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth
HISTIGNORE="ls:cd:history:[bf]g:pwd:whoami:clear:exit"

function git_branch_info {
    local ref=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
    [[ -z "$ref" ]] && ref=$(git describe --tags --always 2>/dev/null)
    [[ -n "$ref" ]] && echo -n "\e[48;2;0;101;50m\e[38;2;255;255;255m $ref \e[0m"
}

function prompt_command {
    local pwd=${PWD/#$HOME/\~}
    local depth=$(echo "$pwd" | tr -cd '/' | wc -c)
    if ((depth >= 3)); then
        pwd=$(echo "$pwd" | rev | cut -d'/' -f1-3 | rev)
    fi
    local bg1="\[\e[48;2;58;64;85m\]"
    local bg2="\[\e[48;2;76;86;106m\]"
    local fg="\[\e[38;2;255;255;255m\]"
    local reset="\[\e[0m\]"
    local git="\[$(git_branch_info)\]"
    local shell_name=""
    [[ "${SHELL##*/}" != "bash" ]] && shell_name="${bg2}${fg} bash "
    PS1="${shell_name}${bg1}${fg} \u ${bg2}${fg} ${pwd} ${git}${reset} ❯ "
    if ((INCOGNITO == 1)); then
        local incog_bg="\[\e[48;2;27;82;126m\]"
        PS1="${incog_bg}${fg} incognito ${reset}$PS1"
    fi
}

PROMPT_COMMAND=prompt_command

((INCOGNITO == 1)) && history -r && HISTFILE=/dev/null

[[ -f /usr/share/bash-completion/bash_completion ]] && \
    source /usr/share/bash-completion/bash_completion

source $XDG_CONFIG_HOME/shell/shellrc
source $XDG_CONFIG_HOME/shell/alias
source $XDG_CONFIG_HOME/shell/teleport
