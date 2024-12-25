# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLE
# -----------------------------------------------------------------------------

export XDG_SESSION_TYPE=wayland
export QT_WAYLAND_FORCE_DPI=physical

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
