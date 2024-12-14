#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

HISTSIZE=5000
HISTFILESIZE=
HISTFILE=$HOME/.bash_history

# Default terminal editor
export EDITOR='nvim'

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
eval "$(fzf --bash)"
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
eval "$(zoxide init bash)"

export BAT_THEME=tokyonight_night

# Install or update all nnn plugins
# sh -c "$(curl -L https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"


# -----------------------------------------------------------------------------
# Custom alias
# -----------------------------------------------------------------------------

alias hibernate="systemctl hibernate"
alias vi="nvim"
alias grep="grep --color=auto"

alias ls="eza --group-directories-first --color=always --git --git-repos-no-status --long --no-filesize"  # Eza (better ls)
alias cd="z"  # Zoxide (better cd)
alias cat="bat"  # Bat (better cat)
alias nnp="nnn -PP"  # nnn file manager with preview-tui enabled
alias NNP='sudo -E nnn -PP'
alias tmuxa='tmux new-session -A -s general'

