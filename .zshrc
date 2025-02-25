# If not running interactively, don't do anything
[[ $- != *i* ]] && return

HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=50000
HISTCONTROL=ignoreboth

# -----------------------------------------------------------------------------
# Oh-my-zsh config
# -----------------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Case-sensitive completion.
# CASE_SENSITIVE="true"

# Hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Command auto-correction.
# ENABLE_CORRECTION="true"

# Disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(
  # git
  zsh-autosuggestions
  vi-mode
)

source $ZSH/oh-my-zsh.sh

# VI-Mode
VI_MODE_SET_CURSOR=true
VI_MODE_CURSOR_NORMAL=4
VI_MODE_CURSOR_INSERT=2

# -----------------------------------------------------------------------------
# Zsh scripts
# -----------------------------------------------------------------------------

zstyle ':completion:*' menu select completer _expand _complete _ignored _approximate
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit; compinit

# Reliably re-bind Shift+Tab for zsh-autosuggestion acceptance
# Executes only once at initial prompt and self-terminates, minimal runtime overhead
# Can maintaining binding persistence against potential conflicts from oh-my-zsh
function zshrc_load_hook() {
  [[ -n "${precmd_functions[(r)zshrc_load_hook]}" ]] && {
    bindkey -r '^[[Z'
    bindkey '^[[Z' autosuggest-accept
    precmd_functions[(r)zshrc_load_hook]=()
  }
}
precmd_functions+=(zshrc_load_hook)

# Enable vi mode in zsh
bindkey -v

[[ -n $INCOGNITO ]] && SAVEHIST=0 && PROMPT="%F{blue}[Incognito]%f %~ %F{green}x%f "

source $HOME/.config/shell/shellrc
source $HOME/.config/shell/alias
source $HOME/.config/shell/teleport
