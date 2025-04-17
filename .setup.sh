################
##### Font #####
################

# Simplified Chinese fonts
sudo pacman -S --noconfirm --disable-download-timeout adobe-source-han-sans-cn-fonts
# Other fonts
sudo pacman -S --noconfirm --disable-download-timeout nerd-fonts
# sudo pacman -S --noconfirm --disable-download-timeout noto-fonts


############################################################
##### Add china archlinux mirror repo to pacman config #####
############################################################

# PACMAN_CONFIG='
# [archlinuxcn]
# SigLevel = Never
# Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch
# '
#
# # Check if the repository section already exist to avoid duplicate entries
# if grep -q '^\[archlinuxcn\]' /etc/pacman.conf; then
#   echo "The [archlinuxcn] repository is already in /etc/pacman.conf"
# else
#   # Append the content to /etc/pacman.conf
#   echo "Adding the [archlinuxcn] repository to /etc/pacman.conf"
#   echo "$PACMAN_CONFIG" | sudo tee -a /etc/pacman.conf >/dev/null
#   echo "Repository added successfully."
# fi
#
# # Update source
# sudo pacman -Syy
# # Install archlinuxcn-keyring
# sudo pacman -S --noconfirm archlinuxcn-keyring


##################################################################
##### Fetch the fastest pacman mirror and update mirror list #####
##################################################################

# sudo pacman -S --noconfirm --disable-download-timeout reflector
# sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak  # backup default mirror list
# sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist


#############################
##### Bluetooth utility #####
#############################

sudo pacman -S --noconfirm --disable-download-timeout bluez bluez-libs bluez-utils
sudo systemctl enable --now bluetooth.service


################################
##### Multimedia framework #####
################################

sudo pacman -S --noconfirm --disable-download-timeout pipewire pipewire-alsa pipewire-pulse pipewire-jack


#################################
##### Update CPU microcode ######
#################################

# sudo pacman -S --noconfirm intel-ucode
# sudo pacman -S --noconfirm amd-ucode


############################
##### Power management #####
############################

# sudo pacman -S --noconfirm --disable-download-timeout tlp
# systemctl enable --now tlp.service
# sudo systemctl mask systemd-rfkill.service
# sudo systemctl mask systemd-rfkill.socket


##################
##### v2raya #####
##################

sudo pacman -S --noconfirm --disable-download-timeout v2ray v2raya
sudo systemctl enable --now v2raya


###############
##### yay #####
###############

sudo pacman -Syu --disable-download-timeout
sudo pacman -S --needed --noconfirm --disable-download-timeout git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay --version
cd


#####################################
##### Useful Command-Line Tools #####
#####################################

sudo pacman -S --noconfirm --disable-download-timeout zsh
# Change default shell to Zsh (Takes effect after login again)
chsh -l
chsh -s /usr/bin/zsh

sudo pacman -S --nocomfirm --disable-download-timeout cronie
sudo pacman -S --nocomfirm --disable-download-timeout bemenu-wayland
sudo pacman -S --nocomfirm --disable-download-timeout neovim
sudo pacman -S --nocomfirm --disable-download-timeout joshuto
sudo pacman -S --nocomfirm --disable-download-timeout fd
sudo pacman -S --nocomfirm --disable-download-timeout ripgrep
sudo pacman -S --nocomfirm --disable-download-timeout fzf
sudo pacman -S --nocomfirm --disable-download-timeout btop
sudo pacman -S --nocomfirm --disable-download-timeout bat
sudo pacman -S --nocomfirm --disable-download-timeout eza
sudo pacman -S --nocomfirm --disable-download-timeout zoxide
sudo pacman -S --nocomfirm --disable-download-timeout man-db
sudo pacman -S --nocomfirm --disable-download-timeout tldr
sudo pacman -S --nocomfirm --disable-download-timeout tree-sitter
sudo pacman -S --nocomfirm --disable-download-timeout alacritty

sudo pacman -S --nocomfirm --disable-download-timeout playerctl

# Notification daemon
sudo pacman -S --nocomfirm --disable-download-timeout mako

sudo pacman -S --nocomfirm --disable-download-timeout zip unzip
# sudo pacman -S --nocomfirm --disable-download-timeout hyperfine
sudo pacman -S --nocomfirm --disable-download-timeout imv
sudo pacman -S --nocomfirm --disable-download-timeout swayimg
sudo pacman -S --nocomfirm --disable-download-timeout mpv

sudo pacman -S --nocomfirm --disable-download-timeout fastfetch

# Install theme for bat
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build
cd

# # Install oh-my-zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# # Install zsh-autosuggestions plugin
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Check if wayland protocol is used
check_wayland() {
    if [ "$XDG_SESSION_TYPE"="wayland" ]; then
        return 0
    fi
    return 1
}

if check_wayland; then
    sudo pacman -S --noconfirm --disable-download-timeout wl-clipboard
fi

sudo pacman -S --noconfirm --disable-download-timeout cliphist

# Tmux
sudo pacman -S --noconfirm --disable-download-timeout tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Contributed scripts to pacman (e.g. paccache)
sudo pacman -S --noconfirm --disable-download-timeout pacman-contrib
# Autorun paccache serive
sudo systemctl enable --now paccache.service

# cheat.sh
curl -s https://cht.sh/:cht.sh | sudo tee /usr/local/bin/cht.sh && sudo chmod +x /usr/local/bin/cht.sh


########################################
##### Useful Applications with GUI #####
########################################

# Xfce Thunar File Manager
sudo pacman -S --noconfirm --disable-download-timeout thunar
sudo pacman -S --noconfirm --disable-download-timeout gvfs

yay -Sy fsearch

# flatpak install flathub org.localsend.localsend_app
yay -Sy localsend-bin

# Timeshift
sudo pacman -S --noconfirm --disable-download-timeout timeshift
# xorg-xhost is required to start Timeshift GUI
# https://wiki.archlinux.org/title/Timeshift#Timeshift_GUI_not_launching_on_Wayland
sudo pacman -S --noconfirm --disable-download-timeout xorg-xhost

# Dictionary
sudo pacman -S --noconfirm --disable-download-timeout goldendict-ng

# Document viewer
sudo pacman -S --noconfirm --disable-download-timeout zathura zathura-pdf-mupdf

# Spotify
yay -Sy spotify


#################
##### LaTeX #####
#################

sudo pacman -S --noconfirm --disable-download-timeout texlive-latex texlive-latexextra texlive-bibtexextra
sudo pacman -S --noconfirm --disable-download-timeout texlive-binextra
sudo pacman -S --noconfirm --disable-download-timeout perl-tk


###################################################
##### Enable install application from flathub #####
###################################################

# sudo pacman -S --noconfirm --disable-download-timeout flatpak


###################
##### Broswer #####
###################

# flatpak install flathub org.mozilla.firefox
sudo pacman -S --noconfirm --disable-download-timeout firefox

sudo pacman -S --noconfirm --disable-download-timeout qutebrowser
sudo pacman -S --noconfirm --disable-download-timeout qt6-wayland
sudo pacman -S --noconfirm --disable-download-timeout python-adblock

ln -s /usr/share/qutebrowser/scripts/open_url_in_instance.sh /home/domenic/.local/bin/qutebrowser


#######################
##### LibreOffice #####
#######################

# sudo pacman -S --noconfirm --disable-download-timeout libreoffice-still


###########################
##### Official VSCode #####
###########################

yay -Sy visual-studio-code-bin


####################################
##### Node version manager nvm #####
####################################

# curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash


####################
##### Anaconda #####
####################

# pacman -S --nocomfirm --disable-download-timeout libxau libxi libxss libxtst libxcursor libxcomposite libxdamage libxfixes libxrandr libxrender mesa-libgl alsa-lib libglvnd
#
# is_anaconda_version_valid() {
#   if [ -z "$1" ]; then
#     return 1
#   fi
#   return 0
# }
#
# while true; do
#   echo -e "View a full list of Anaconda Distribution installers at https://repo.anaconda.com/archive/\nInput the anacoonda version (Anaconda3-<INSTALLER_VERSION>-Linux-x86_64.sh): "
#   read anaconda_installer_version
#   if is_anaconda_version_valid "$anaconda_installer_version"; then
#     break
#  else
#     echo "Invalid installer version"
#   fi
# done
#
# anaconda_installer_url="https://repo.anaconda.com/archive/Anaconda3-${anaconda_installer_version}-Linux-x86_64.sh"
# echo "Downloading anaconda installer from: $anaconda_installer_url"
#
# curl -o "$anaconda_installer_url"
#
# bash Anaconda3-2024.10-1-Linux-x86_64.sh


##################
##### Docker #####
##################

sudo pacman -S --noconfirm --disable-download-timeout docker
sudo systemctl enable --now docker.service


############################
##### System Utilities #####
############################

# USB devices auto mounting
sudo pacman -S --noconfirm --disable-download-timeout udisk2 udiskie


#################################
##### Create Symbolic Links #####
#################################

# Trash folder
ln -s ~/.local/share/Trash ~/Trash
# USB device folder
ln -s /run/media/domenic ~/usb


###########################
##### Apply dotfiles #####
##########################

cd
git clone https://github.com/domeniczz/.dotfiles.git
cd ~/.dotfiles

sudo pacman -S --noconfirm --disable-download-timeout stow
# Apply all the dotfiles
stow . --adopt
git restore .


#######################
##### Sytem Reboot #####
########################

reboot_countdown = 5
while [ $reboot_countdown -gt 0 ]; do
    echo -ne "Rebooting in $reboot_countdown seconds...\r"
    sleep 1
    reboot_countdown=$((reboot_countdown - 1))
done

sudo reboot
