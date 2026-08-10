#!/usr/bin/env zsh

# ==============================================================================
# To revert any setting to its factory default, use `defaults delete`.
#
# e.g.
#   defaults delete -g ApplePressAndHoldEnabled
#   defaults delete com.apple.dock autohide
#
# Log out and log back in to take effect.
# ==============================================================================

# Enable holding keys to repeat them instead of showing the accent menu
defaults write -g ApplePressAndHoldEnabled -bool false

# Control + Command and left click to drag window from anywhere
defaults write -g NSWindowShouldDragOnGesture -bool true

# Automatically hide the Dock
defaults write com.apple.dock autohide -bool true
# Show Dock without delay
defaults write com.apple.dock autohide-delay -float 0
# Set Dock icon size
defaults write com.apple.dock tilesize -int 34

# Stop macOS from littering USB/Network drives with hidden .DS_Store junk files
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Always show hidden files in Finder
# defaults write com.apple.finder AppleShowAllFiles -boolean true
# Always show folders at top when sort by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

killall Dock
killall Finder

# Disable google chrome auto-update
echo '{"updatePolicies":{"global":{"UpdateDefault":2}}}' | sudo plutil -convert xml1 - -o /Library/Managed\ Preferences/com.google.Keystone.plist
