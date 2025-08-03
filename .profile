# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLE
# -----------------------------------------------------------------------------

export VISUAL=nvim
export EDITOR=nvim
# To take effect, `sudo visudo` and add: Defaults env_keep += "SYSTEMD_EDITOR"
export SYSTEMD_EDITOR=nvim
export PAGER=less
export TERMINAL=footclient
export FILE_MANAGER=vifm

export XDG_SESSION_TYPE=wayland
export QT_WAYLAND_FORCE_DPI=physical
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=gtk2
# export QT_DEBUG_PLUGINS=1

export ELECTRON_OZONE_PLATFORM_HINT=wayland
export MOZ_ENABLE_WAYLAND=1

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

export XDG_CONFIG_HOME="$HOME"/.config
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state
export XDG_CACHE_HOME="$HOME"/.cache

export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export MACHINE_STORAGE_PATH="$XDG_DATA_HOME"/docker-machine
export KUBECONFIG="$XDG_CONFIG_HOME"/kube
export KUBECACHEDIR="$XDG_CACHE_HOME"/kube
export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
export NVM_DIR="$XDG_DATA_HOME"/nvm
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME"/python
export PYTHONUSERBASE="$XDG_DATA_HOME"/python
export PYTHON_HISTORY="$XDG_DATA_HOME"/python_history

export TEXMFHOME="$XDG_DATA_HOME"/texmf
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export TEXMFCONFIG="$XDG_CONFIG_HOME"/texlive/texmf-config

export OLLAMA_MODELS="$XDG_DATA_HOME"/ollama/models
export W3M_DIR="$XDG_STATE_HOME"/w3m
export LYNX_CFG="$XDG_CONFIG_HOME"/lynx/lynx.cfg
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export STARSHIP_CONFIG="$XDG_CONFIG_HOME"/starship/starship.toml
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass
export BASH_COMPLETION_USER_FILE="$XDG_CONFIG_HOME"/bash-completion/bash_completion
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export RIPGREP_CONFIG_PATH="$XDG_CONFIG_HOME"/ripgrep/ripgreprc
export FZF_DEFAULT_OPTS_FILE="$XDG_CONFIG_HOME"/fzf/fzfrc

# -----------------------------------------------------------------------------
# PATH
# -----------------------------------------------------------------------------

# $HOME/.local/scripts and all its subdirectories
if [ -d "$HOME/.local/scripts" ]; then
    script_paths=""
    for dir in $(find "$HOME/.local/scripts" -type d 2>/dev/null); do
        case ":$PATH:" in
            *":$dir:"*) ;;
            *) script_paths="$script_paths:$dir" ;;
        esac
    done
    if [ -n "$script_paths" ]; then
        PATH="$PATH${script_paths}"
    fi
fi

case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac
