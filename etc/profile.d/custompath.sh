# export PATH="$PATH:$(find $HOME/.local/scripts -type d -printf %p:)"
if [ -d "$HOME/.local/scripts" ]; then
    script_paths="$(find "$HOME/.local/scripts" -type d -printf '%p:' 2>/dev/null)"
    case ":$PATH:" in
        *"$script_paths"*) ;;
        *) export PATH="$PATH:${script_paths%:}" ;;
    esac
fi
