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

###############################################################################
# System
###############################################################################
echo ""
echo "› System:"

echo "› Disable the sound effects on boot"
sudo nvram SystemAudioVolume=" "

echo "  › Show the ~/Library folder"
chflags nohidden ~/Library

echo "  › Show the /Volumes folder"
sudo chflags nohidden /Volumes

echo "  › Turn off keyboard illumination when computer is not used for 5 minutes"
defaults write com.apple.BezelServices kDimTime -int 300

echo "  › Enable dark mode"
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

echo "  › Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

echo "  › Enable text replacement almost everywhere"
defaults write -g WebAutomaticTextReplacementEnabled -bool true

echo "  › Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true

echo "  › Avoid the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo "  › Disable the 'Are you sure you want to open this application?' dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo "  › Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

echo "  › Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo "  › Disable Resume system-wide"
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

################################################################################
# UI
################################################################################
echo ""
echo "› UI:"
echo "  › Always show scrollbars"
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

echo "  › Don't automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

echo "  › Increase the window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo "  › Show battery percent"
defaults write com.apple.menuextra.battery ShowPercent -bool true
defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true

echo "  › Configure Menu Icons"
defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Bluetooth -int 18
defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist NowPlaying -int 8
defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist Sound -int 18

echo "  › Disable Notification Center and remove the menu bar icon"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null


################################################################################
# SCROLLING
################################################################################
echo ""
echo "› Scrolling:"

# Possible values: `WhenScrolling`, `Automatic` and `Always`
SCROLLBAR="WhenScrolling"
printf "Show scroll bars %s.\n" $SCROLLBAR
defaults write NSGlobalDomain AppleShowScrollBars -string $SCROLLBAR

echo "  › Disable natural scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

################################################################################
# GENERAL SETTINGS
################################################################################
echo ""
echo "› General Settings:"

set -x
echo "  › Set standby delay to 24 hours (default is 1 hour)"
sudo pmset -a standbydelay 86400

echo "  › Have the system automatically restart upon freezing"
sudo systemsetup -setrestartfreeze on

SCREENSHOTS_FOLDER="$HOME/Pictures/Screenshots"

# Check screenshots folder exits.
if [ ! -d $SCREENSHOTS_FOLDER ]
then
    mkdir $SCREENSHOTS_FOLDER
fi

echo "  › Save screenshots to the Pictures folder"
defaults write com.apple.screencapture location -string $SCREENSHOTS_FOLDER

echo "  › Set default screenshot type to be '.png'"
defaults write com.apple.screencapture type -string "png"

echo "  › Disable shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

echo "  › Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 1

echo "  › Enable font smoothing to ensure that fonts render crisp on a retina display"
defaults write -g CGFontRenderingFontSmoothingDisabled -bool NO
defaults -currentHost write -globalDomain AppleFontSmoothing -int 2

echo "  › Enable HiDPI display modes (requires restart)"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

echo "  › Disable automatic termination of inactive apps"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

echo "  › Disable the crash reporter"
defaults write com.apple.CrashReporter DialogType -string "none"

echo "  › Set Help Viewer windows to non-floating mode"
defaults write com.apple.helpviewer DevMode -bool true

################################################################################
# FINDER
################################################################################
echo ""
echo "› Finder:"

echo "  › New Finder window opens HOME directory"
defaults write com.apple.finder NewWindowTarget -string 'PfHm'

echo "  › Display file extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "  › Always open everything in Finder's list view"
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

echo "  › Set the Finder prefs for showing a few different volumes on the Desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo "  › Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

echo "  › Set sidebar icon size to small"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

echo "  › Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

echo "  › Show path bar"
defaults write com.apple.finder ShowPathbar -bool true

echo "  › Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool false

echo "  › Save to disk by default, instead of iCloud"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo "  › Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

echo "  › Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "  › Removing duplicates in the 'Open With' menu"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
  -kill -r -domain local -domain system -domain user

echo "  › Setting all files (including hidden files) to be visible."
defaults write com.apple.finder AppleShowAllFiles -bool true

echo "  › Expand File Info pane with 'General', 'Open with', and 'Sharing & Permissions'"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
    General -bool true \
    OpenWith -bool true \
    Privileges -bool true

echo "  › When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

echo "  › Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true

echo "  › Show icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

echo "  › Keep folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo "  › Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "  › Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

################################################################################
# SAFARI
################################################################################
echo ""
echo "› Safari:"

echo "  › Privacy: don't send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

echo "  › Press Tab to highlight each item on a web page"
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

echo "  › Show the full URL in the address bar (note: this still hides the scheme)"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

echo "  › Set Safari's home page to `about:blank` for faster loading"
defaults write com.apple.Safari HomePage -string "about:blank"

echo "  › Prevent Safari from opening 'safe' files automatically after downloading"
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

echo "  › Allow hitting the Backspace key to go to the previous page in history"
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

echo "  › Hide Safari's bookmarks bar by default"
defaults write com.apple.Safari ShowFavoritesBar -bool false

echo "  › Hide Safari's sidebar in Top Sites"
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

echo "  › Disable Safari's thumbnail cache for History and Top Sites"
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

echo "  › Enable Safari's debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

echo "  › Make Safari's search banners default to Contains instead of Starts With"
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

echo "  › Enable the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

echo "  › Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo "  › Disable auto-correct"
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

echo "  › Disable autofill"
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

echo "  › Always warn about fraudulent websites"
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

echo "  › Enabling the developer menu and dev options for Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

echo "  › Enable Safari 'Do Not Track'"
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

################################################################################
# TERMINAL
################################################################################
echo ""
echo "› Terminal:"
echo "  › Making iTerm2 nag less on quitting"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

###############################################################################
# Time Machine                                                                #
###############################################################################

echo "  › Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "  › Disable local Time Machine backups"
hash tmutil &> /dev/null && sudo tmutil disablelocal

###############################################################################
# Activity Monitor                                                            #
###############################################################################
echo ""
echo "› Activity Monitor:"

echo "  › Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

echo "  › Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5

echo "  › Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

echo "  › Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

################################################################################
# APP STORE
################################################################################
echo ""
echo "› App Store:"

echo "  › Enable the WebKit Developer Tools in the Mac App Store."
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

echo "  › Enable Debug Menu in the Mac App Store."
defaults write com.apple.appstore ShowDebugMenu -bool true

echo "  › Enable the automatic update check."
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

echo "  › Check for software updates daily, not just once per week."
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo "  › Download newly available updates in background."
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

echo "  › Install System data files & security updates."
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

echo "  › Automatically download apps purchased on other Macs."
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

echo "  › Turn on app auto-update."
defaults write com.apple.commerce AutoUpdate -bool true

echo "  › Do NOT allow the App Store to reboot machine on macOS updates."
defaults write com.apple.commerce AutoUpdateRestartRequired -bool false

###############################################################################
# Photos                                                                      #
###############################################################################
echo ""
echo "› Photos:"

echo "  › Disable it from starting everytime a device is plugged in"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Messages                                                                    #
###############################################################################
echo ""
echo "› Messages:"

echo "  › Disable automatic emoji substitution (i.e. use plain text smileys)"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false

echo "  › Disable smart quotes as it's annoying for messages that contain code"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

echo "  › Disable continuous spell checking"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################
echo ""
echo "› Google Chrome & Google Canary:"

echo "  › Disable the all too sensitive backswipe on trackpads"
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableSwipeNavigateWithScrolls -bool false

echo "  › Disable the all too sensitive backswipe on Magic Mouse"
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

echo "  › Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true
defaults write com.google.Chrome.canary DisablePrintPreview -bool true

###############################################################################
# GPGMail 2                                                                   #
###############################################################################
echo ""
echo "› GPGMail 2:"

echo "  › Disable signing emails by default"
defaults write ~/Library/Preferences/org.gpgtools.gpgmail SignNewEmailsByDefault -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
###############################################################################
echo ""
echo "› Trackpad, Keyboard/Mouse, Bluetooth accessories, and input:"
echo "  › Disable press-and-hold for keys in favor of key repeat"
defaults write -g ApplePressAndHoldEnabled -bool false

echo "  › Set a really fast key repeat"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo "  › Disable smart quotes and smart dashes as they're annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

echo "  › Disable auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "  › Disable auto-capitalization and double-space period"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -int 0

echo "  › Use function keys on external keyboards"
defaults write NSGlobalDomain com.apple.keyboard.fnState -int 1

echo "  › Set up trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 3
defaults write -g com.apple.mouse.scaling 3

echo "  › Enable tap to click for trackpad"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "  › Set touchbar to app controls with control strip"
defaults write com.apple.touchbar.agent PresentationModeGlobal -string appWithControlStrip

echo "  › Map bottom right corner to right-click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

echo "  › System Preferences > Accessibility > Pointer Control > Mouse & Trackpad > Trackpad Options > Enable Dragging > Three Finger Drag (NOTE: The GUI doesn't update)"
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

echo "  › Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

echo "  › Enable full keyboard access for all controls"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo " › Use scroll gesture with the Ctrl (^) modifier key to zoom"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

echo " › Follow the keyboard focus while zoomed in"
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

###############################################################################
# Energy saving
###############################################################################
echo ""
echo "› Energy Saving:"

echo " › Enable lid wakeup"
sudo pmset -a lidwake 1

echo " › Sleep the display after 15 minutes"
sudo pmset -a displaysleep 15

echo " › Disable machine sleep while charging"
sudo pmset -c sleep 0

echo " › Set machine sleep to 10 minutes on battery"
sudo pmset -b sleep 10

###############################################################################
# Screen
###############################################################################
echo ""
echo "› Screen:"
echo " › Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

################################################################################
# SSD-specific tweaks
################################################################################
echo ""
echo "› SSD-specific tweaks:"

echo "› Disable local Time Machine snapshots"
sudo tmutil disablelocal

echo "› Disable hibernation (speeds up entering sleep mode)"
sudo pmset -a hibernatemode 0

echo "› Remove the sleep image file to save disk space"
sudo rm /Private/var/vm/sleepimage

echo "› Create a zero-byte file instead…"
sudo touch /Private/var/vm/sleepimage

echo "› …and make sure it can't be rewritten"
sudo chflags uchg /Private/var/vm/sleepimage

echo "› Disable the sudden motion sensor as it's not useful for SSDs"
sudo pmset -a sms 0


###############################################################################
# Dock, Dashboard, and hot corners
###############################################################################
echo ""
echo "› Dock, Dashboard, and hot corners:"
echo "  › Setting the icon size of Dock items to 48 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 48

echo "  › Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock showAppExposeGestureEnabled -int 1

echo "  › Remove the auto-hiding Dock delay"
defaults write com.apple.dock autohide-delay -float 0

echo "  › Remove the animation when hiding/showing the Dock"
defaults write com.apple.dock autohide-time-modifier -float 0

echo "  › Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

echo "  › Don't animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool false

echo "  › Show App Switcher on all displays"
defaults write com.apple.dock appswitcher-all-displays -bool true

echo "  › Minimize windows into their application’s icon"
defaults write com.apple.dock minimize-to-application -bool true

echo "  › Don't show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

echo "  › Dock in the left of the screen"
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock pinning -string "end"

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################
echo ""
echo "› Address Book, Dashboard, iCal, TextEdit, and Disk Utility:"

echo "  › Enable the debug menu in Address Book"
defaults write com.apple.addressbook ABShowDebugMenu -bool true

echo "  › Enable Dashboard dev mode (allows keeping widgets on the desktop)"
defaults write com.apple.dashboard devmode -bool true

echo "  › Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0

echo "  › Open and save files as UTF-8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4


###############################################################################
# Terminal/iTerm2
###############################################################################
echo ""
echo "› Terminal/iTerm2:"

echo "  › Install the Solarized Dark theme for iTerm"
open "${HOME}/.dotfiles/iterm2/Snazzy.itermcolors"

echo "  › Don't display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

echo "  › Only use UTF-8 in Terminal.app"
defaults write com.apple.terminal StringEncodings -array 4

echo "  › iTerm2 Settings"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.dotfiles/iterm2"
defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true

###############################################################################
# Security
###############################################################################
echo ""
echo "› Security:"

echo "  › Configure Spoof Mac to run @ startup"
echo "  › Download the startup file for launchd"
curl https://raw.githubusercontent.com/feross/SpoofMAC/master/misc/local.macspoof.plist > local.macspoof.plist

echo "  › Customize location of `spoof-mac.py` to match your system"
cat local.macspoof.plist | sed "s|/usr/local/bin/spoof-mac.py|`which spoof-mac.py`|" | tee local.macspoof.plist

echo "  › Copy file to the OS X launchd folder"
sudo cp local.macspoof.plist /Library/LaunchDaemons

echo "  › Set file permissions"
cd /Library/LaunchDaemons
sudo chown root:wheel local.macspoof.plist
sudo chmod 0644 local.macspoof.plist
echo "  › Done"

# By default, the above will randomize your MAC address on computer startup.
# You can change the command that gets run at startup by editing the local.macspoof.plist file.
# sudo vim /Library/LaunchDaemons/local.macspoof.plist

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

