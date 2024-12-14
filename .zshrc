# If not running interactively, don't do anything
[[ $- != *i* ]] && return


# -----------------------------------------------------------------------------
# Oh-my-zsh config
# -----------------------------------------------------------------------------

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
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

# Plugins to load.
plugins=(
  git
  zsh-autosuggestions
)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh


# -----------------------------------------------------------------------------
# Zsh scripts
# -----------------------------------------------------------------------------

# Autocompletion Config
zstyle ':completion:*' menu select completer _expand _complete _ignored _approximate
zstyle :compinstall filename "$HOME/.zshrc"
autoload -Uz compinit; compinit
bindkey '\t\t' autosuggest-accept  # Tab to accept autosuggestion

# Command history
HISTFILE=$HOME/.zsh_history
HISTSIZE=1000
SAVEHIST=5000

bindkey -v

# Default terminal editor
export EDITOR='nvim'
# Set default systemd editor
# AND `sudo visudo` then add: Defaults env_keep += "SYSTEMD_EDITOR"
# Start a new bash session to take effect
export SYSTEMD_EDITOR='nvim'

# Activate anaconda3 environment
condainit() {
  source $HOME/Programs/anaconda3/bin/activate
}

# Initialize nvm environment
nvminit() {
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

export TMUX_CONF_PATH="$HOME/.config/tmux/tmux.conf"
# Attach to tmux "general" session when startup
# Check if tmux exists on the system
if command -v tmux &> /dev/null; then
  # Check if we're already inside a tmux session
  if [ -z "$TMUX" ]; then
    tmux new-session -A -s general
  fi
else
  echo "tmux is not installed"
fi

# Setup fzf keybinding and fuzzy completion
# Credit: https://www.josean.com/posts/7-amazing-cli-tools
eval "$(fzf --zsh)"
# Configure FZF settings
if command -v rg >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --no-require-git'
fi
# if type fd &> /dev/null; then
#   export FZF_DEFAULT_COMMAND='fd --type file --hidden --exclude .git'
#   export FZF_ALT_C_COMMAND='fd --type directory --hidden'
# fi
# if type ag &> /dev/null; then
#   export FZF_DEFAULT_COMMAND="ag -p $HOME/.gitignore -g ''"
# fi
export FZF_DEFAULT_OPTS='-m --height 60% --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)           fzf --preview 'eza --tree --level=2 --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}
# Load key bindings for searching Git objects
# Repo: https://github.com/junegunn/fzf-git.sh
# - CTRL-G-F for Files
# - CTRL-G-B for Branches
# - CTRL-G-T for Tags
# - CTRL-G-R for Remotes
# - CTRL-G-H for commit Hashes
# - CTRL-G-S for Stashes
# - CTRL-G-L for reflogs
# - CTRL-G-W for Worktrees
# - CTRL-G-E for Each ref (git for-each-ref)
if [ -f $HOME/clone/fzf-git.sh/fzf-git.sh ]; then
  source $HOME/clone/fzf-git.sh/fzf-git.sh
fi

# eval $(thefuck --alias)
# eval $(thefuck --alias fk)
eval "$(zoxide init zsh)"

export BAT_THEME=tokyonight_night

# Install or update all nnn plugins
# sh -c "$(curl -L https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"


# -----------------------------------------------------------------------------
# Custom alias
# -----------------------------------------------------------------------------

alias hibernate="systemctl hibernate"
alias vi="nvim"
alias grep="grep --color=auto"

alias tmuxa='tmux new-session -A -s general'
alias ls="eza --group-directories-first --color=always --git --git-repos-no-status --long --no-filesize"  # Eza (better ls)
alias cd="z"  # Zoxide (better cd)
alias cat="bat"  # Bat (better cat)
alias fm='joshuto'
alias FM='sudo joshuto'

