# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PROMPT="%K{#3a4055}%F{#f0f0f0} %n %K{#4c566a} %3~ %f%k ❯ "

HISTFILE=$HOME/.zsh_history
HISTSIZE=2000
SAVEHIST=100000
HISTCONTROL=ignoreboth
KEYTIMEOUT=5
LISTMAX=200

((INCOGNITO == 1)) && SAVEHIST=0 && PROMPT="%K{#1b527e}%F{#f0f0f0} incognito %f%k$PROMPT"

setopt append_history inc_append_history share_history extended_history
setopt hist_ignore_dups hist_ignore_space hist_reduce_blanks hist_verify
setopt autocd check_jobs

bindkey -v

zstyle ":completion:*" menu select completer _expand _complete _ignored _approximate
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit; compinit

ZSH_PLUGINS_DIR=/usr/share/zsh/plugins
source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

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

# Set key bindings by using string capabilities from terminfo
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  autosuggest-accept
[[ -n "${key[Control-P]}" ]] && bindkey -- "${key[Control-P]}"  history-beginning-search-backward
[[ -n "${key[Control-N]}" ]] && bindkey -- "${key[Control-N]}"  history-beginning-search-forward

# Fallback binding, will be overridden by the terminfo bindings if available
bindkey "^?" backward-delete-char
bindkey "^[[3~" delete-char
bindkey "^[[Z" autosuggest-accept
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

function zle-line-init {
  echo -ne '\e[2 q'
}
zle -N zle-line-init

function zle-keymap-select {
  case $KEYMAP in
    vicmd)
      echo -ne '\e[4 q'
      ;;
    viins|main)
      echo -ne '\e[2 q'
      ;;
  esac
}
zle -N zle-keymap-select

source $XDG_CONFIG_HOME/shell/shellrc
source $XDG_CONFIG_HOME/shell/alias
source $XDG_CONFIG_HOME/shell/teleport
