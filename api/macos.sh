#!/bin/env bash

# Get dotfiles directory to (so run this script from anywhere)
export DOTFILES_DIR
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Update the user's cached credentials, authenticating the user if necessary.
# keep-alive to update existing `sudo` time stamp until script has finished.

clear

###############################################################################
# ERROR: Let the user know if the script fails
###############################################################################

trap 'ret=$?; test $ret -ne 0 && printf "\n   \e[31m\033[0m  Script failed  \e[31m\033[0m\n" >&2; exit $ret' EXIT

set -e

###############################################################################
# Release the hounds
###############################################################################
printf "
_________       _____ _____________ ______              
______  /______ __  /____  __/___(_)___  /_____ ________
_  __  / _  __ \_  __/__  /_  __  / __  / _  _ \__  ___/
/ /_/ /  / /_/ // /_  _  __/  _  /  _  /  /  __/_(__  ) 
\__,_/   \____/ \__/  /_/     /_/   /_/   \___/ /____/  
╭───────────────────────────────────────────────────╮
│ ${bold}System dotfiles automation${normal}.       │
│───────────────────────────────────────────────────│
│  Safe to run multiple times on the same machine.  │
│  It ${green}installs${reset}, ${blue}upgrades${reset}, or ${yellow}skips${reset} packages based   │
│  on what is already installed on the machine.     │
╰───────────────────────────────────────────────────╯
   ${dim}$(get_os) $(get_os_version) ${normal} // ${dim}$BASH ${normal} // ${dim}$BASH_VERSION${reset}
"

###############################################################################
# CHECK: Internet
###############################################################################
echo "Checking internet connection…"
check_internet_connection

###############################################################################
# PROMPT: Password
###############################################################################
echo "Caching password…"
ask_for_sudo

###############################################################################
# PROMPT: SSH Key
###############################################################################
echo "Checking for SSH key…"
ssh_key_setup


###############################################################################
# INSTALL: Dependencies
###############################################################################
echo "Installing Dependencies…"

# -----------------------------------------------------------------------------
# XCode
# -----------------------------------------------------------------------------
install_xcode () {
if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
	test -d "${xpath}" && test -x "${xpath}" ; then
	print_success_muted "Xcode already installed. Skipping."
else
	step "Installing Xcode…"
	xcode-select --install
	print_success "Xcode installed!"
fi

if [ ! -d "$HOME/.bin/" ]; then
	mkdir "$HOME/.bin"
fi
}
# -----------------------------------------------------------------------------
# NVM
# -----------------------------------------------------------------------------

install_nvm () {
if [ -x nvm ]; then
	step "Installing NVM…"
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
	print_success "NVM installed!"
	step "Installing latest Node…"
	nvm install node
	nvm use node
	nvm run node --version
	nodev=$(node -v)
	print_success "Using Node $nodev!"
else
	print_success_muted "NVM/Node already installed. Skipping."
fi
}

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



update_dotfiles() {
    [ -d "$DOTFILES_DIR/.git" ] && git --work-tree="$DOTFILES_DIR" --git-dir="$DOTFILES_DIR/.git" pull origin master
}

echo "=> Install Xcode"
install_xcode

echo "=> Install Homebrew, Git and tools we need for running dotfiles."
install_setup

echo "=> Updating Homebrew formulae…"
update_homebrew

echo "=> Cleanup Homebrew cache and remove installation files"
cleanup_homebrew

echo "=> Install NVM"
install_nvm

echo "=> Update dotfiles repository itself."
update_dotfiles

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
# Directories
###############################################################################

DIRECTORIES=(
    $HOME/design
    $HOME/github
    $HOME/sync
    $HOME/GIFs
    $HOME/Desktop/projects
    $HOME/Desktop/temp
)

step "Making directories…"
for dir in ${DIRECTORIES[@]}; do
    mkd $dir
done



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
# Chrome
###############################################################################

# Prevent left and right swipe through history in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false


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
    ack
    bash-completion
    bash-snippets
    broot 
    calcurse
    chkrootkit
    cointop
    coreutils --with-gmp
    ctop
    ddgr
    docker-compose
    findutils --with-default-names
    moreutils
    osxutils
    bat
    bpytop
    fd
    fzf
    gh
    git
    git-lfs
    glances
    go
    htop
    httpie
    ideviceinstaller ios-deploy cocoapods
    jq
    lazydocker
    --HEAD libimobiledevice
    mas
    neofetch
    nmap
    pup
    pyenv
    python3
    ranger
    rbenv
    recode
    ripgrep
    rust
    starship
    stow
    tig
    tldr
    tmux
    tree
    vim --with-lu --override-system-vi
    wget
    yarn
    z
    zoxide
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

    homebrew/cask-versions/brave-browser-nightly
    homebrew/cask-versions/firefox-nightly
    #homebrew/cask-versions/google-chrome-canary
    homebrew/cask-versions/iterm2-nightly
    homebrew/cask-versions/signal-beta
    homebrew/cask-versions/sublime-text-dev
    #homebrew/cask-versions/telegram-desktop-beta
    homebrew/cask-versions/transmission-nightly
    homebrew/cask-versions/visual-studio-code-insiders
    homebrew/cask-versions/vlc-nightly
    #1password
    #1password-cli
    adobe-creative-cloud
    adobe-digital-editions
    adobe-dng-converter
    alfred
    #android-file-transfer
    android-sdk
    android-studio
    #anki
    anvil
    arq
    automute
    #axure-rp
    balenaetcher
    bartender
    battle-net
    binance
    boxer
    caffeine
    calibre
    cheatsheet
    cityofzion-neon
    clipmenu
    daisydisk
    dash
    docker
    dropbox
    eve
    #exodus
    figma
    firefly
    flutter
    flux
    #folding-at-home
    github-desktop
    #gitter
    #google-backup-and-sync
    gpg-suite
    gyazo
    hazel
    imagealpha
    imageoptim
    #imazing
    install-disk-creator
    kitematic
    ledger-live
    licecap
    little-snitch
    local
    macfuse #needed for veracrypt
    macvim
    micro-snitch
    #microsoft-office
    #microsoft-outlook
    nault
    #notion
    openemu
    overdrive-media-console
    plex-media-server
    #postgres
    postico
    postman
    protonvpn
    raspberry-pi-imager
    #slack
    sequel-pro
    shortcat
    shottr
    sia-ui
    sip
    spectacle
    spotify
    #steam
    thonny
    transmit
    #tuxera-ntfs
    veracrypt
    #xld
    zoom

)
brew install --cask "${casks_to_install[@]}"

echo
echo "Casks successfully installed!"
echo
clear


# Install quicklook casks

echo
echo "Installing Quicklook plugins..."
echo

quicklook_casks_to_install=(
ePub-quicklook
EPSQLPlugIn
BetterZipQL
qlmarkdown
qlMoviePreview
qlstephen
QLTorrent
qlvideo
qlwoff
QuickNFO
QuickJSON
syntax-highlight
WebPQuickLook

)
brew install --cask --no-quarantine "${quicklook_casks_to_install[@]}"

echo
echo "Quicklook plugins successfully installed!"
echo
clear


# Brew cleanup
brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup

###############################################################################
# INSTALL: npm packages
###############################################################################
source ./api/npm.sh


cargo install ttyper

# Install tuxi
sudo curl -sL "https://raw.githubusercontent.com/Bugswriter/tuxi/main/tuxi" -o /usr/local/bin/tuxi
sudo chmod +x /usr/local/bin/tuxi

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