#!/bin/bash

# Get dotfiles directory to (so run this script from anywhere)
export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Update the user's cached credentials, authenticating the user if necessary.
# keep-alive to update existing `sudo` time stamp until script has finished.

clear

echo "system .dotfiles automation"
echo "Administrator password required to run script"
echo "Note: You may be asked to input your password again during the installation"
echo

# Update macOS and install xcode
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
clear # clear the screen

sudo softwareupdate -i -a
xcode-select --install


###############################################################################
# Install Homebrew, Git and tools we need for running dotfiles.
###############################################################################

install_setup() {

# First check for Homebrew
if test ! $(which brew)
then
    echo "  Installing 🍺 Homebrew for you."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
fi
#  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install git --with-openssl --with-curl
    brew install git-extras
    brew install development tools
}

update_homebrew() {
    brew update # Check for latest version of Homebrew.
    brew upgrade --all # Upgrade any already-installed formulae.
    brew upgrade
    brew cask outdated | cut -f 1 | xargs brew cask reinstall
}

cleanup_homebrew() {
    brew cleanup # Remove installation files.
    rm -f -r /Library/Caches/Homebrew/* # Delete installation cache files
}

update_dotiles() {
    [ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master
}

echo "=> Install Homebrew, Git and tools we need for running dotfiles."
install_setup

echo "=> Update Homebrew formulas"
update_homebrew

echo "=> Cleanup Homebrew cache and remove installation files"
cleanup_homebrew

echo "=> Update dotfiles repository itself."
update_dotiles

clear # clear the screen

echo
echo "********************"
echo "*** OSX Defaults ***"
echo "********************"
echo
echo "Setting OSX defaults..."
echo

###############################################################################
# System
###############################################################################

COMPUTER_NAME="raiz"

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
# Enable Dark Mode
defaults write /Library/Preferences/.GlobalPreferences AppleInterfaceTheme Dark
# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "
# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

###############################################################################
# General UI/UX
###############################################################################

# Disable Notification Center and remove the menu bar icon
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null
# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Trackpad: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
# Trackpad: set sensitivity

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 0

###############################################################################
# Energy saving
###############################################################################

# Enable lid wakeup
sudo pmset -a lidwake 1
# Sleep the display after 15 minutes
sudo pmset -a displaysleep 15
# Disable machine sleep while charging
sudo pmset -c sleep 0
# Set machine sleep to 5 minutes on battery
sudo pmset -b sleep 5

###############################################################################
# Screen
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

SCREENSHOTS_FOLDER="$HOME/Pictures/Screenshots"

# Check screenshots folder exits.
if [ ! -d $SCREENSHOTS_FOLDER ]
then
    mkdir $SCREENSHOTS_FOLDER
fi

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string $SCREENSHOTS_FOLDER

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true
# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 1

# Enable HiDPI display modes (requires restart)
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

################################################################################
# SSD-specific tweaks
################################################################################

# Disable local Time Machine snapshots
sudo tmutil disablelocal

# Disable hibernation (speeds up entering sleep mode)
sudo pmset -a hibernatemode 0

# Remove the sleep image file to save disk space
sudo rm /Private/var/vm/sleepimage
# Create a zero-byte file instead…
sudo touch /Private/var/vm/sleepimage
# …and make sure it can’t be rewritten
sudo chflags uchg /Private/var/vm/sleepimage

# Disable the sudden motion sensor as it’s not useful for SSDs
sudo pmset -a sms 0

###############################################################################
# Finder
###############################################################################

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable disk image verification
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Use list view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

###############################################################################
# Dock, Dashboard, and hot corners
###############################################################################

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool true

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 38

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Dock in the left of the screen
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock pinning -string "end"

defaults write com.apple.dock tilesize -int 35 # icon size
defaults write com.apple.dock size-immutable -bool YES

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Change or Disable Auto-Hide Delay
defaults write com.apple.dock autohide-time-modifier -float 0.8;

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

# ###############################################################################
# Mac App Store
# ###############################################################################

# Enable the WebKit Developer Tools in the Mac App Store
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

# Enable Debug Menu in the Mac App Store
defaults write com.apple.appstore ShowDebugMenu -bool true


###############################################################################
# Top Bar
###############################################################################

# Menu bar: show battery percentage
defaults write com.apple.menuextra.battery -bool true


###############################################################################
# iTerm2
###############################################################################

# Install the Solarized Dark theme for iTerm
open "${HOME}/.dotfiles/themes/Snazzy.itermcolors"
# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

# Enable the debug menu in Address Book
defaults write com.apple.addressbook ABShowDebugMenu -bool true

# Enable Dashboard dev mode (allows keeping widgets on the desktop)
defaults write com.apple.dashboard devmode -bool true

# Enable the debug menu in iCal (pre-10.8)
defaults write com.apple.iCal IncludeDebugMenu -bool true

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0
# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

echo
echo "OSX defaults successfully set!"
echo

clear

###############################################################################
# Packages and binaries
###############################################################################

echo
echo "Installing packages and binaries..."
echo


packages_to_install=(
    coreutils --with-gmp
    findutils --with-default-names
    moreutils
    osxutils
    bat
    bpytop
    docker
    git
    git-lfs
    htop
    httpie
    neofetch
    nmap
    node
    npm
    stow
    tig
    tmux
    tree
    vim --with-lu --override-system-vi
    yarn
    z
    zsh
)
brew install "${packages_to_install[@]}"

echo
echo "Packages and binaries successfully installed!"
echo
clear


# Install fonts

echo
echo "Installing fonts..."
echo


brew tap homebrew/cask-fonts

fonts_to_install=(
    font-atkinson-hyperlegible
    font-blokk
    font-blokk-neue
    font-fira-code
    font-cascadia-code
    font-ingonsolata-for-powerline
    font-inconsolata-for-powerline-bold
    font-inconsolata-g-for-powerline
    font-inconsolata-dz
    font-inconsolata-dz-for-powerline
    font-open-sans
    font-open-sans-condensed
    font-source-code-pro
    font-source-code-pro-for-powerline
)
brew cask install "${fonts_to_install[@]}"

echo
echo "Fonts successfully installed!"
echo
clear

# Install casks

echo
echo "Installing casks..."
echo

tap homebrew/cask-versions

casks_to_install=(
    homebrew/cask-versions/1password-beta
    homebrew/cask-versions/alfred3
    homebrew/cask-versions/arduino-nightly
    homebrew/cask-versions/arq5
    homebrew/cask-versions/brave-browser-nightly
    homebrew/cask-versions/calibre4
    homebrew/cask-versions/firefox-nightly
    homebrew/cask-versions/google-chrome-canary
    homebrew/cask-versions/gpg-suite-nightly
    homebrew/cask-versions/hyper-canary
    homebrew/cask-versions/iterm2-nightly
    homebrew/cask-versions/kitematic0176
    homebrew/cask-versions/little-snitch4
    homebrew/cask-versions/signal-beta
    homebrew/cask-versions/slack-beta
    homebrew/cask-versions/sublime-text-dev
    homebrew/cask-versions/telegram-desktop-dev
    #homebrew/cask-versions/transmission-nightly
    homebrew/cask-versions/visual-studio-code-insiders
    homebrew/cask-versions/vlc-nightly
    1password-cli
    adobe-creative-cloud
    adobe-digital-editions
    adobe-dng-converter
    #android-file-transfer
    #anki
    anvil
    automute
    #axure-rp
    balenaetcher
    bartender
    battle-net
    #binance
    boxer
    caffeine
    cheatsheet
    clipmenu
    daisydisk
    docker
    docker-toolbox
    dropbox
    eve
    exodus
    figma
    flux
    folding-at-home
    github-desktop
    #gitter
    #google-backup-and-sync
    gyazo
    hazel
    heroku update
    heroku-toolbelt
    imagealpha
    imageoptim
    #imazing
    install-disk-creator
    iota-wallet
    ledger-live
    licecap
    local-by-flywheel
    macvim
    micro-snitch
    nault
    #notion
    openemu
    overdrive-media-console
    plex-media-server
    postgres
    postico
    protonvpn
    sequel-pro
    shortcat
    sia-ui
    sip
    spectacle
    spotify
    steam
    transmit
    tuxera-ntfs
    #xld
    zoom
)
brew cask install "${casks_to_install[@]}"

echo
echo "Casks successfully installed!"
echo
clear

# Brew cleanup
brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup

# Install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# Install oh my zsh packages
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# Install pure theme for ZSH
npm install --global pure-prompt

###############################################################################
# Symlink dotfiles
###############################################################################

# Symlink dotfiles using gnu stow
stow git vim zsh

###############################################################################
# Apply changes
###############################################################################

# Configure git lfs
git lfs install

# Apply macOS changes
for app in "Address Book" "Calendar" "Contacts" "Dock" "Finder" "Mail" "SystemUIServer" "iCal"; do
    killall "${app}" &> /dev/null
done

killall SystemUIServer

echo "Done. Some changes may require a logout/restart to take effect."

cat $DOTFILES_DIR/assets/congratulations.txt
exit 1