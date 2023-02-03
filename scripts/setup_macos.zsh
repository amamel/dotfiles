#!/usr/bin/env zsh


#Make sure this is a mac and bail out if not

case $OSTYPE in
  darwin* ) echo "\n<<< Starting macOS Setup >>>\n";;
  * ) echo "This is not a mac - moving on." ; exit 0 ;;
esac

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

################################################################################
# BOOT
################################################################################
echo ""
echo "› Boot:"
printf "Setting machine to write to disk by default; not iCloud.\n"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

printf 'Disable the sound effects on boot'
sudo nvram SystemAudioVolume=" "

###############################################################################
# System
###############################################################################
echo ""
echo "› System:"

# Enable Dark Mode
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
defaults write NSGlobalDomain AppleMetricUnits -bool false


################################################################################
# SCROLLING
################################################################################
echo ""
echo "› Scrolling:"

# Possible values: `WhenScrolling`, `Automatic` and `Always`
SCROLLBAR="WhenScrolling"
printf "Show scroll bars %s.\n" $SCROLLBAR
defaults write NSGlobalDomain AppleShowScrollBars -string $SCROLLBAR

printf 'Fuck natural scrolling.\n'
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

################################################################################
# GENERAL SETTINGS
################################################################################
echo ""
echo "› General Settings:"

set -x
# Set standby delay to 24 hours (default is 1 hour)
sudo pmset -a standbydelay 86400

printf 'Have the system automatically restart upon freezing.\n'
sudo systemsetup -setrestartfreeze on

SCREENSHOTS_FOLDER="$HOME/Pictures/Screenshots"

# Check screenshots folder exits.
if [ ! -d $SCREENSHOTS_FOLDER ]
then
    mkdir $SCREENSHOTS_FOLDER
fi

printf 'Save screenshots to the Pictures folder\n'
defaults write com.apple.screencapture location -string $SCREENSHOTS_FOLDER

printf 'Set default screenshot type to be ".png"\n'
defaults write com.apple.screencapture type -string "png"

printf 'Disable shadow in screenshots\n'
defaults write com.apple.screencapture disable-shadow -bool true

printf 'Enable subpixel font rendering on non-Apple LCDs\n'
defaults write NSGlobalDomain AppleFontSmoothing -int 1

printf 'Enable HiDPI display modes (requires restart)\n'
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Set Help Viewer windows to non-floating mode
defaults write com.apple.helpviewer DevMode -bool true

# Restart automatically if the computer freezes
sudo systemsetup -setrestartfreeze on

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


################################################################################
# FINDER
################################################################################
echo ""
echo "› Finder:"

printf 'Setting all files (including hidden files) to be visible.\n'
defaults write com.apple.finder AppleShowAllFiles -bool true

printf 'Show all file extensions.\n'
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

printf 'Show the status bar.\n'
defaults write com.apple.finder ShowStatusBar -bool true

printf 'Show the path bar.\n'
defaults write com.apple.finder ShowPathbar -bool true

printf 'Show the full POSIX path in window title.\n'
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

printf 'Disable the warning when changing a file extension.\n'
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

printf 'Show the the ~/Library and /Volumes folder.\n'
chflags nohidden ~/Library
sudo chflags nohidden /Volumes

printf 'Expand File Info pane with "General", "Open with", and "Sharing & Permissions".\n'
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Disable the warning before emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Finder: allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Enable spring loading for directories
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

################################################################################
# SAFARI
################################################################################
echo ""
echo "› Safari:"

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Press Tab to highlight each item on a web page
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# Set Safari’s home page to `about:blank` for faster loading
defaults write com.apple.Safari HomePage -string "about:blank"

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Disable auto-correct
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Disable AutoFill
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

printf 'Enabling the developer menu and dev options for Safari.\n'
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

printf 'Enable Safari "Do Not Track".\n'
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

################################################################################
# TERMINAL
################################################################################
echo ""
echo "› Terminal:"

printf 'Making iTerm2 nag less on quitting.\n'
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# Activity Monitor                                                            #
###############################################################################
echo ""
echo "› Activity Monitor:"

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

################################################################################
# APP STORE
################################################################################
echo ""
echo "› App Store:"

printf 'Enable the WebKit Developer Tools in the Mac App Store.\n'
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

printf 'Enable Debug Menu in the Mac App Store.\n'
defaults write com.apple.appstore ShowDebugMenu -bool true

printf 'Enable the automatic update check.\n'
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

printf 'Check for software updates daily, not just once per week.\'
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

printf 'Download newly available updates in background.\n'
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

printf 'Install System data files & security updates.\n'
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

printf 'Automatically download apps purchased on other Macs.\n'
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

printf 'Turn on app auto-update.\n'
defaults write com.apple.commerce AutoUpdate -bool true

printf 'Do NOT allow the App Store to reboot machine on macOS updates.\n'
defaults write com.apple.commerce AutoUpdateRestartRequired -bool false



###############################################################################
# Photos                                                                      #
###############################################################################
echo ""
echo "› Photos:"

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true


###############################################################################
# Messages                                                                    #
###############################################################################
echo ""
echo "› Messages:"

# Disable automatic emoji substitution (i.e. use plain text smileys)
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

# Disable smart quotes as it’s annoying for messages that contain code
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

# Disable continuous spell checking
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################
echo ""
echo "› Google Chrome & Google Canary:"

# Disable the all too sensitive backswipe on trackpads
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

# Disable the all too sensitive backswipe on Magic Mouse
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

# Use the system-native print preview dialog
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

###############################################################################
# GPGMail 2                                                                   #
###############################################################################
echo ""
echo "› GPGMail 2:"

# Disable signing emails by default
defaults write ~/Library/Preferences/org.gpgtools.gpgmail SignNewEmailsByDefault -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################
echo ""
echo "› Trackpad, mouse, keyboard, Bluetooth accessories, and input:"

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# System Preferences > Accessibility > Pointer Control > Mouse & Trackpad > Trackpad Options > Enable Dragging > Three Finger Drag (NOTE: The GUI doesn't update)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Use scroll gesture with the Ctrl (^) modifier key to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# Follow the keyboard focus while zoomed in
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true



###############################################################################
# Energy saving
###############################################################################
echo ""
echo "› Energy Saving:"

# Enable lid wakeup
sudo pmset -a lidwake 1

# Sleep the display after 15 minutes
sudo pmset -a displaysleep 15

# Disable machine sleep while charging
sudo pmset -c sleep 0

# Set machine sleep to 5 minutes on battery
sudo pmset -b sleep 20



###############################################################################
# Screen
###############################################################################
echo ""
echo "› Screen:"

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

################################################################################
# SSD-specific tweaks
################################################################################
echo ""
echo "› SSD-specific tweaks:"

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
# Dock, Dashboard, and hot corners
###############################################################################
echo ""
echo "› Dock, Dashboard, and hot corners:"

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

printf 'Automatically hide and show the Dock.\n'
defaults write com.apple.dock autohide -bool true

# Change or Disable Auto-Hide Delay
defaults write com.apple.dock autohide-time-modifier -float 0.8;

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Don’t animate opening applications from the Dock
defaults write com.apple.dock launchanim -bool false

###############################################################################
# Top Bar
###############################################################################
echo ""
echo "› Top Bar:"

# Menu bar: show battery percentage
defaults write com.apple.menuextra.battery -bool true

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################
echo ""
echo "› Address Book, Dashboard, iCal, TextEdit, and Disk Utility:"

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


###############################################################################
# Terminal/iTerm2
###############################################################################
echo ""
echo "› Terminal/iTerm2:"

# Install the Solarized Dark theme for iTerm
open "${HOME}/.dotfiles/iterm2/Snazzy.itermcolors"

# Don’t display the annoying prompt when quitting iTerm
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# iTerm2 Settings
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.dotfiles/iterm2"
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true

echo
echo "OSX defaults successfully set!"
echo

clear

###############################################################################
# Kill affected applications                                                  #
###############################################################################
echo ""
echo "› Finishing Up..."

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
    "Dock" "Finder" "Google Chrome" "Google Chrome Canary" "Mail" "Messages" \
    "Opera" "Photos" "Safari" "SizeUp" "Spectacle" "SystemUIServer" "Terminal" \
    "Transmission" "iCal"; do
    killall "${app}" &> /dev/null
done
set +x
echo "\n<<< macOS Setup Complete. 
Note that some of these changes require a logout/restart to take effect. >>>\n"

