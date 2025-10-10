[[ $- != *i* ]] && return

setopt prompt_subst
setopt append_history inc_append_history share_history extended_history
setopt hist_ignore_dups hist_ignore_all_dups hist_expire_dups_first
setopt hist_ignore_space hist_reduce_blanks hist_verify
setopt autocd check_jobs
setopt extended_glob

HISTFILE=$XDG_DATA_HOME/zsh_history
HISTSIZE=2000
SAVEHIST=100000
HISTORY_IGNORE="(ls|cd|history|[bf]g|pwd|whoami|clear|exit)"
KEYTIMEOUT=5
LISTMAX=150

function git_branch_info() {
    local ref=$(git symbolic-ref --quiet --short HEAD 2>/dev/null)
    [[ -z "$ref" ]] && ref=$(git describe --tags --always 2>/dev/null)
    [[ -n "$ref" ]] && echo "%K{#006532}%F{#ffffff} $ref %f%k"
}

[[ "${SHELL##*/}" != "zsh" ]] && PROMPT_SHELL_NAME="%K{#4c566a}%F{#fffff} zsh %f%k"
PROMPT_INCOGNITO="%K{#1b527e}%F{#ffffff} incognito %f%k"
PROMPT_USER="%K{#3a4055}%F{#ffffff} %n "
PROMPT_DIR="%K{#4c566a}%F{#ffffff} %3~ %f%k"
PROMPT_GIT="$(git_branch_info)"
PROMPT_SYMBOL=" ❯ "

PROMPT="$PROMPT_SHELL_NAME$PROMPT_USER$PROMPT_DIR$PROMPT_GIT$PROMPT_SYMBOL"

((INCOGNITO == 1)) && SAVEHIST=0 && PROMPT="$PROMPT_INCOGNITO$PROMPT"

bindkey -v

zstyle ":completion:*" menu select completer _expand _complete _ignored _approximate
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit; compinit -d "$XDG_CACHE_HOME/zcompdump"

autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic

# ZSH_PLUGINS_DIR=/usr/share/zsh/plugins
# source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
# source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

[[ -f /usr/share/zsh-antidote/antidote.zsh ]] && \
    source /usr/share/zsh-antidote/antidote.zsh && \
    antidote load ${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/zsh_plugins.txt

# Create a zkbd compatible hash for terminfo key mapping
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Control-P]="^P"
key[Control-N]="^N"

bindkey "^?" backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[[Z" reverse-menu-complete
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

function zle-line-init {
    echo -ne '\e[5 q'
}
zle -N zle-line-init

function zle-keymap-select {
    case $KEYMAP in
        vicmd)
            echo -ne '\e[2 q'
            ;;
        viins|main)
            echo -ne '\e[5 q'
            ;;
    esac
}
zle -N zle-keymap-select

source $XDG_CONFIG_HOME/shell/shellrc
source $XDG_CONFIG_HOME/shell/alias
source $XDG_CONFIG_HOME/shell/teleport
