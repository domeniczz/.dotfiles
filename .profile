# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLE
# -----------------------------------------------------------------------------

export VISUAL=nvim
export EDITOR=nvim
export PAGER=less
export TERMINAL=ghostty
export SYSTOP=btop
export FILEMANAGER=vifm
export LESS="--use-color --wordwrap --RAW-CONTROL-CHARS --incsearch --ignore-case --mouse"

export XDG_SESSION_TYPE=wayland
export QT_WAYLAND_FORCE_DPI=physical
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=gtk2

export ELECTRON_OZONE_PLATFORM_HINT=wayland

export GTK_IM_MODULE=wayland
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

export MOZ_ENABLE_WAYLAND=1

export XDG_CONFIG_HOME="$HOME"/.config
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_STATE_HOME="$HOME"/.local/state
export XDG_CACHE_HOME="$HOME"/.cache

export NVM_DIR="$XDG_DATA_HOME"/nvm
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GOPATH="$XDG_DATA_HOME"/go
export GOMODCACHE="$XDG_CACHE_HOME"/go/mod
export TEXMFHOME="$XDG_DATA_HOME"/texmf
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export TEXMFCONFIG="$XDG_CONFIG_HOME"/texlive/texmf-config
export STARSHIP_CONFIG="$XDG_CONFIG_HOME"/starship/starship.toml
export BASH_COMPLETION_USER_FILE="$XDG_CONFIG_HOME"/bash-completion/bash_completion
export FFMPEG_DATADIR="$XDG_CONFIG_HOME"/ffmpeg
export WGETRC="$XDG_CONFIG_HOME"/wget/wgetrc
export W3M_DIR="$XDG_STATE_HOME"/w3m
export OLLAMA_MODELS="$XDG_DATA_HOME"/ollama/models

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
