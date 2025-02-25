# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLE
# -----------------------------------------------------------------------------

export VISUAL=nvim
export EDITOR=nvim
export PAGER=less
export TERMINAL=ghostty

export XDG_SESSION_TYPE=wayland
export QT_WAYLAND_FORCE_DPI=physical
export QT_ENABLE_HIGHDPI_SCALING=1
export QT_QPA_PLATFORM=wayland

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

export MOZ_ENABLE_WAYLAND=1

export STARDICT_DATA_DIR=$HOME/.local/share/stardict

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
