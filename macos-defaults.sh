#!/usr/bin/env zsh

# ==============================================================================
# To revert any setting to its factory default, use `defaults delete`.
#
# e.g.
#   defaults delete -g ApplePressAndHoldEnabled
#   defaults delete com.apple.dock autohide
#
# Quit and reopen affected apps, or log out and back in, to take effect.
# ==============================================================================

# Appearance and general behavior
defaults write -g AppleInterfaceStyleSwitchesAutomatically -bool true
defaults write -g AppleActionOnDoubleClick -string "Fill"
defaults write -g AppleShowScrollBars -string "WhenScrolling"
defaults write -g AppleScrollerPagingBehavior -bool true
defaults write -g AppleSpacesSwitchOnActivate -bool true
defaults write -g AppleWindowTabbingMode -string "fullscreen"
defaults write -g NSQuitAlwaysKeepsWindows -bool true

# Language, region, and keyboard
defaults write -g AppleLanguages -array "en-CN" "zh-Hans-CN"
defaults write -g AppleLocale -string "en_CN"
defaults write -g AppleFirstWeekday -dict gregorian 2
defaults write -g InitialKeyRepeat -int 25
defaults write -g KeyRepeat -int 2
defaults write -g "com.apple.keyboard.fnState" -bool true
defaults write -g NSAutomaticCapitalizationEnabled -bool true
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g WebAutomaticSpellingCorrectionEnabled -bool false

# Enable holding keys to repeat them instead of showing the accent menu
defaults write -g ApplePressAndHoldEnabled -bool false

# Control + Command and left click to drag window from anywhere
defaults write -g NSWindowShouldDragOnGesture -bool true

# Trackpad preferences, including an external Magic Trackpad
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write -g "com.apple.trackpad.scaling" -float 2

# Automatically hide the Dock
defaults write com.apple.dock autohide -bool true
# Show Dock without delay
defaults write com.apple.dock autohide-delay -float 0
# Set Dock icon size
defaults write com.apple.dock tilesize -int 34
# Group windows by app in Mission Control
defaults write com.apple.dock expose-group-apps -bool true
# Keep Spaces in their configured order
defaults write com.apple.dock mru-spaces -bool false
# Do not show suggested/recent apps in the Dock
defaults write com.apple.dock show-recents -bool false
# Show the running-app indicator in the Dock
defaults write com.apple.dock show-process-indicators -bool true
# Require Shift for all configured hot corners
defaults write com.apple.dock wvous-bl-corner -int 11
defaults write com.apple.dock wvous-bl-modifier -int 131072
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 131072
defaults write com.apple.dock wvous-tl-corner -int 3
defaults write com.apple.dock wvous-tl-modifier -int 131072
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 131072

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
# Show mounted external disks and servers on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# Remove items from Trash after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# Window management
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Menu bar clock
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -bool true
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool true

killall Dock
killall Finder
killall SystemUIServer

# Disable google chrome auto-update
echo '{"updatePolicies":{"global":{"UpdateDefault":2}}}' | sudo plutil -convert xml1 - -o /Library/Managed\ Preferences/com.google.Keystone.plist
