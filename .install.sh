#!/bin/bash

readonly LOG_FILE="$HOME/install.log"
readonly PACMAN_FLAGS="--noconfirm --disable-download-timeout"
readonly YAY_FLAGS=""

declare -a PACMAN_PKGS=(
  "nerd-fonts"
  "noto-fonts"
  "noto-fonts-cjk"
  "noto-fonts-emoji"

  "bluez"
  "bluez-libs"
  "bluez-utils"

  "pipewire"
  "pipewire-alsa"
  "pipewire-pulse"
  "pipewire-jack"

  # "intel-ucode"
  # "amd-ucode

  "fcitx5-im"
  "fcitx5-chinese-addons"
  "fcitx5-material-color"

  "zsh"
  "cronie"
  "bemenu-wayland"
  "neovim"
  "joshuto"
  "fd"
  "ripgrep"
  "fzf"
  "btop"
  "bat"
  "eza"
  "zoxide"
  "man-db"
  "tldr"
  "tree-sitter"
  "alacritty"
  "playerctl"
  "mako"
  "zip"
  "unzip"
  "imv"
  "swayimg"
  "mpv"
  "fastfetch"
  "wl-clipboard"
  "cliphist"
  "tmux"
  "pacman-contrib"
  "tlp"
  "git"
  "base-devel"

  "thunar"
  "gvfs"
  "timeshift"
  "xorg-xhost"
  "goldendict-ng"
  "zathura"
  "zathura-pdf-mupdf"
  # "libreoffice-still"

  "linuxqq"
  "wechat-bin"
  "dingtalk-bin"
  "discord_arch_electron"

  "v2ray"
  "v2raya"

  # "localsend"

  "texlive-latex"
  "texlive-latexextra"
  "texlive-bibtexextra"
  "texlive-binextra"
  "texlive-fontsrecommended"
  "perl-tk"
  "pandoc-cli"

  # "flatpak"

  "firefox"
  "qutebrowser"
  "qt6-wayland"
  "python-adblock"

  # "docker"

  "udisk2"
  "udiskie"

  "wine"
  "winetricks"
  "wine-mono"
  "wine-gecko"
  "lib32-pipewire"
  "lib32-libpulse"

  "rclone"

  "yt-dlp"

  "lua-language-server"
  "pyright"
  "libsynctex"
)

declare -a YAY_PKGS=(
  "smem"
  # "visual-studio-code-bin"
  "spotify"
  "spotify-player-full"
)

log_message() {
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[${timestamp}] $1" >> "${LOG_FILE}"
}

pacman_install() {
  local package=$1
  local exit_status
  log_message "Starting pacman installation of ${package}"
  if sudo pacman -S ${PACMAN_FLAGS} "${package}" &>> "${LOG_FILE}"; then
    log_message "Successfully installed ${package} using pacman"
    return 0
  else
    exit_status=$?
    log_message "Failed to install ${package} using pacman. Exit code: ${exit_status}"
    return "${exit_status}"
  fi
}

yay_install() {
  local package=$1
  local exit_status
  log_message "Starting yay installation of ${package}"
  if yay -S ${YAY_FLAGS} "${package}" &>> "${LOG_FILE}"; then
    log_message "Successfully installed ${package} using yay"
    return 0
  else
    exit_status=$?
    log_message "Failed to install ${package} using yay. Exit code: ${exit_status}"
    return "${exit_status}"
  fi
}

install_packages() {
  local failed_packages=()
  local success_count=0
  local total_packages=$((${#PACMAN_PKGS[@]} + ${#YAY_PKGS[@]}))
  log_message "Starting installation of ${total_packages} packages"
  log_message "Starting pacman package installations"
  for package in "${PACMAN_PKGS[@]}"; do
    if pacman_install "${package}"; then
      ((success_count++))
    else
      failed_packages+=("pacman:${package}")
    fi
  done
  log_message "Starting yay package installations"
  for package in "${YAY_PKGS[@]}"; do
    if yay_install "${package}"; then
      ((success_count++))
    else
      failed_packages+=("yay:${package}")
    fi
  done
  log_message "Installation complete. Successfully installed ${success_count}/${total_packages} packages"
  if [[ ${#failed_packages[@]} -gt 0 ]]; then
    log_message "Failed packages: ${failed_packages[*]}"
    return 1
  fi
  return 0
}

setup_pacman() {
  log_message "Setting up pacman..."
  if [[ ! -f "/etc/pacman.conf" ]]; then
    log_message "Error: /etc/pacman.conf not found"
    return 1
  fi
  local readonly PACMAN_REPO='
[archlinuxcn]
SigLevel = Never
Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch
'
  if grep -q '^\[archlinuxcn\]' /etc/pacman.conf; then
    log_message "archlinuxcn repository already configured"
  else
    log_message "Adding archlinuxcn repository to pacman.conf"
    if ! echo "${PACMAN_REPO}" | sudo tee -a /etc/pacman.conf > /dev/null; then
      log_message "Failed to add repository configuration"
      return 1
    fi
  fi
  log_message "Updating package database..."
  if ! sudo pacman -Syy &>> "${LOG_FILE}"; then
    log_message "Failed to update package database"
    return 1
  fi
  log_message "Installing archlinuxcn-keyring..."
  if ! pacman_install "archlinuxcn-keyring" &>> "${LOG_FILE}"; then
    log_message "Failed to install archlinuxcn-keyring"
    return 1
  fi
  return 0
}

setup_yay() {
  log_message "Setting up yay..."
  (
    sudo pacman -Syu --disable-download-timeout &&
    sudo pacman -S --needed --noconfirm --disable-download-timeout git base-devel &&
    git clone https://aur.archlinux.org/yay.git "$HOME/yay" &&
    cd "$HOME/yay" &&
    makepkg -si --noconfirm
  ) &>> "${LOG_FILE}"

  local exit_status=$?
  rm -rf "$HOME/yay"

  if command -v yay &> /dev/null; then
    log_message "yay setup completed successfully"
    return 0
  else
    log_message "yay setup failed with status: ${exit_status}"
    return 1
  fi
}

main() {
  touch "${LOG_FILE}"
  log_message "Starting package installation"
  setup_pacman
  if [[ ${#YAY_PKGS[@]} -gt 0 ]] && ! command -v yay &> /dev/null; then
    setup_yay
  }
  if install_packages; then
    log_message "All packages installed successfully"
    echo "Installation completed successfully. Check ${LOG_FILE} for details."
  else
    log_message "Some packages failed to install"
    echo "Some packages failed to install. Check ${LOG_FILE} for details."
    exit 1
  fi
}

main
