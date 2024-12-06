#!/bin/bash

###########################################
##### Install simplified Chinese font #####
###########################################

sudo pacman -S --noconfirm --disable-download-timeout adobe-source-han-sans-cn-fonts


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
#     echo "The [archlinuxcn] repository is already in /etc/pacman.conf"
# else
#     # Append the content to /etc/pacman.conf
#     echo "Adding the [archlinuxcn] repository to /etc/pacman.conf"
#     echo "$PACMAN_CONFIG" | sudo tee -a /etc/pacman.conf > /dev/null
#     echo "Repository added successfully."
# fi
#
# # Update source
# sudo pacman -Syy
# # Install archlinuxcn-keyring
# sudo pacman -S --noconfirm archlinuxcn-keyring


##################################################################
##### Fetch the fastest pacman mirror and update mirror list #####
##################################################################

sudo pacman -S --noconfirm --disable-download-timeout reflector
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak  # backup default mirror list
sudo reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist


####################################
##### Enable bluetooth utility #####
####################################

sudo pacman -S --noconfirm --disable-download-timeout bluez
sudo systemctl start bluetooth.service
sudo systemctl enable bluetooth.service


#################################
##### Update CPU microcode ######
#################################

# sudo pacman -S --noconfirm intel-ucode
# sudo pacman -S --noconfirm amd-ucode


##########################
##### Install v2raya #####
##########################

# sudo pacman -S --noconfirm --disable-download-timeout v2ray v2raya
# sudo systemctl enable v2raya
# sudo systemctl start v2raya

# Nexitally:
# https://iwkpox.xyz/?L2Rvd25sb2FkQ29uZmlnL1NoYWRvd1JvY2tldEltcG9ydFNlcnZpY2UuYXNweD90PXNzbiZ1cms9ZDQ1ZmJhZWUtZGE3NS00MWVjLWJiZWItMTBmZjMxMzQxNzdmJm1tPTIwNzMyOSZlZGRjMDRjNmJmZjk0NmI2YmY4NGYxOWQ4Mg==


#####################################
##### Useful Command-Line Tools #####
#####################################

sudo pacman -S --noconfirm --disable-download-timeout zsh
# chsh -l
# chsh -s /usr/bin/zsh

sudo pacman -S --nocomfirm --disable-download-timeout neovim ranger fd ripgrep fzf btop bat eza thefuck zoxide man tree-sitter

# Install theme for bat
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build
cd

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Install zsh-autosuggestions plugin
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

###################################################
##### Enable install application from flathub #####
###################################################

sudo pacman -S --noconfirm --disable-download-timeout install flatpak


###########################
##### Install Firefox #####
###########################

# flatpak install flathub org.mozilla.firefox

sudo pacman -S --noconfirm --disable-download-timeout firefox
sudo pacman -S --noconfirm --disable-download-timeout xdg-desktop-portal-gtk


###############################
##### Install LibreOffice #####
###############################

sudo pacman -S --noconfirm --disable-download-timeout libreoffice-still

#############################
##### Install localsend #####
#############################

flatpak install flathub org.localsend.localsend_app


#######################
##### Install yay #####
#######################

sudo pacman -Syu --disable-download-timeout
sudo pacman -S --noconfirm --disable-download-timeout git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay --version


###############################################
##### Install official visual studio code #####
###############################################

yay -Sy visual-studio-code-bin


########################
##### Install Tmux #####
########################

sudo pacman -S --noconfirm --disable-download-timeout tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm


############################
##### Install Anaconda #####
############################

# pacman -S --nocomfirm --disable-download-timeout libxau libxi libxss libxtst libxcursor libxcomposite libxdamage libxfixes libxrandr libxrender mesa-libgl alsa-lib libglvnd
#
# is_anaconda_version_valid() {
#     if [ -z "$1" ]; then
#         return 1
#     fi
#     return 0
# }
#
# while true; do
#     echo -e "View a full list of Anaconda Distribution installers at https://repo.anaconda.com/archive/\nInput the anacoonda version (Anaconda3-<INSTALLER_VERSION>-Linux-x86_64.sh): "
#     read anaconda_installer_version
#     if is_anaconda_version_valid "$anaconda_installer_version"; then
#         break
#     else
#         echo "Invalid installer version"
#     fi
# done
#
# anaconda_installer_url="https://repo.anaconda.com/archive/Anaconda3-${anaconda_installer_version}-Linux-x86_64.sh"
# echo "Downloading anaconda installer from: $anaconda_installer_url"
#
# curl -o "$anaconda_installer_url"
#
# bash Anaconda3-2024.10-1-Linux-x86_64.sh


##########################
##### Install Docker #####
##########################

sudo pacman -S --noconfirm --disable-download-timeout docker
sudo systemctl enable docker.service
sudo systemctl start docker.service


########################
##### Sytem Reboot #####
########################

reboot_countdown = 5
while [ $reboot_countdown -gt 0 ]; do
    echo -ne "Rebooting in $reboot_countdown seconds...\r"
    sleep 1
    reboot_countdown=$((reboot_countdown - 1))
done

sudo reboot

