#!/bin/sh
set -e

# ~/.macos — https://mths.be/macos

# Show banner
echo
echo "#################################"
echo "# Setting Mac OS X defaults ... #"
echo "#################################"
echo

printf "\033[1mPlease select if you want to apply the custom Mac OSX configuration\033[0m:\n"
echo "[1] Apply the configuration"
echo "[2] Skip applying the configuration"
echo
printf "Enter your decision: "
echo

# The installation of OSX defaults can be forced. This is used in CI environments where there is no possibility to read the input.
if [ -z "$CI" ]; then
  read -r applyConfiguration
else
  applyConfiguration="1"
fi

case $applyConfiguration in
    "1")
        # Close any open System Preferences panes, to prevent them from overriding
        # settings we’re about to change
        osascript -e 'tell application "System Preferences" to quit'

        # Ask for the administrator password upfront
        echo "We need sudo right to set some Mac OS X defaults."
        sudo true

        # The installation of OSX defaults can be forced. This is used in CI environments where there is no possibility to read the input.
        if [ -z "$CI" ]; then
            # Set computer name (as done via System Preferences → Sharing)
            printf "Enter the hostname: "

            # read the hostname
            read -r hostname

            sudo scutil --set ComputerName "$hostname"
            sudo scutil --set HostName "$hostname"
            sudo scutil --set LocalHostName "$hostname"
            sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$hostname"
        fi

        ###############################################################################
        echo
        printf "\t General UI/UX\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Set standby delay to 24 hours (default is 1 hour)\n"
        sudo pmset -a standbydelay 86400

        printf "\t- Set sidebar icon size to medium\n"
        defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

        printf "\t- Disabling OS X Gate Keeper\n"
        printf "\t\t- (You'll be able to install any app you want from here on, not just Mac App Store apps)\n"
        sudo spctl --master-disable
        sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
        defaults write com.apple.LaunchServices LSQuarantine -bool false

        printf "\t- Expanding the save panel by default\n"
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
        defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
        defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
        defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

        printf "\t- Automatically quit printer app once the print jobs complete\n"
        defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

        printf "\t- Saving to disk (not to iCloud) by default\n"
        defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

        printf "\t- Disabling the \"Are you sure you want to open this application?\" dialog\n"
        defaults write com.apple.LaunchServices LSQuarantine -bool false

        ###############################################################################
        echo
        printf "\t SSD-specific tweaks\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Disable hibernation (speeds up entering sleep mode)\n"
        sudo pmset -a hibernatemode 0

        ###############################################################################
        echo
        printf "\t Trackpad, mouse, keyboard, Bluetooth accessories, and input\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)\n"
        defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

        printf "\t- Disabling press-and-hold for keys in favor of a key repeat\n"
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

        printf "\t- Setting a fast keyboard repeat rate\n"
        defaults write NSGlobalDomain KeyRepeat -int 2
        defaults write NSGlobalDomain InitialKeyRepeat -int 15

        printf "\t- Setting trackpad & mouse speed to a reasonable number\n"
        defaults write -g com.apple.trackpad.scaling 2
        defaults write -g com.apple.mouse.scaling 2.5

        printf "\t- Turn off keyboard illumination when computer is not used for 1 minute\n"
        defaults write com.apple.BezelServices kDimTime -int 60

        printf "\t- Enabling tap to click for this user and for the login screen\n"
        defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
        defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
        defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

        printf "\t- Enable 'natural' (Lion-style) scrolling\n"
        defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

        printf "\t- Set language and text formats\n"
        # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
        # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
        defaults write NSGlobalDomain AppleLanguages -array "en" "de"
        defaults write NSGlobalDomain AppleLocale -string "en_US@currency=EUR"
        defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
        defaults write NSGlobalDomain AppleMetricUnits -bool true

        printf "\t- Set the timezone; see 'sudo systemsetup -listtimezones' for other values\n"
        sudo systemsetup -settimezone "Europe/Berlin" > /dev/null

        ###############################################################################
        echo
        printf "\t Screen\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Save screenshots to the desktop\n"
        defaults write com.apple.screencapture location -string "${HOME}/Desktop"

        printf "\t- Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)\n"
        defaults write com.apple.screencapture type -string "png"

        printf "\t- Disable shadow in screenshots\n"
        defaults write com.apple.screencapture disable-shadow -bool true

        ###############################################################################
        echo
        printf "\t Finder\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons\n"
        defaults write com.apple.finder QuitMenuItem -bool true

        printf "\t- Finder: disable window animations and Get Info animations\n"
        defaults write com.apple.finder DisableAllAnimations -bool true

        printf "\t- Set home folder as the default location for new Finder windows\n"
        # For other paths, use `PfLo` and `file:///full/path/here/`
        defaults write com.apple.finder NewWindowTarget -string "PfDe"
        defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

        printf "\t- Showing all filename extensions in Finder by default\n"
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true

        printf "\t- Showing status bar in Finder by default\n"
        defaults write com.apple.finder ShowStatusBar -bool true

        printf "\t- Showing path bar in Finder by default\n"
        defaults write com.apple.finder ShowPathbar -bool true

        printf "\t- Allowing text selection in Quick Look/Preview in Finder by default\n"
        defaults write com.apple.finder QLEnableTextSelection -bool true

        printf "\t- Displaying full POSIX path as Finder window title\n"
        defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

        printf "\t- Keep folders on top when sorting by name\n"
        defaults write com.apple.finder _FXSortFoldersFirst -bool true

        printf "\t- When performing a search, search the current folder by default\n"
        defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

        printf "\t- Enable spring loading for directories\n"
        defaults write NSGlobalDomain com.apple.springing.enabled -bool true

        printf "\t- Disable disk image verification\n"
        defaults write com.apple.frameworks.diskimages skip-verify -bool true
        defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
        defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

        printf "\t- Automatically open a new Finder window when a volume is mounted\n"
        defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
        defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
        defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

        printf "\t- Enable AirDrop over Ethernet and on unsupported Macs running Lion\n"
        defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

        printf "\t- Disabling the warning when changing a file extension\n"
        defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

        printf "\t- Use list view in all Finder windows by default\n"
        defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

        printf "\t- Avoiding the creation of .DS_Store files on network volumes\n"
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

        printf "\t- Avoiding the creation of .DS_Store files on USB volumes\n"
        defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

        printf "\t- Show hidden files in all Finder windows by default\n"
        defaults write com.apple.finder AppleShowAllFiles -bool true

        printf "\t- Show item info near icons on the desktop and in other icon views\n"
        /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
        /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

        printf "\t- Expand the following File Info panes: 'General', 'Open with', and 'Sharing & Permissions'\n"
        defaults write com.apple.finder FXInfoPanesExpanded -dict \
        	General -bool true \
        	OpenWith -bool true \
        	Privileges -bool true

        printf "\t- Enabling snap-to-grid for icons on the desktop and in other icon views\n"
        /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
        /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

        printf "\t- Showing the ~/Library folder\n"
        chflags nohidden ~/Library

        printf "\t- Showing the /Volumes folder\n"
        sudo chflags nohidden /Volumes

        # Kill all finder instances to reload the new configuration
        killall Finder

        ###############################################################################
        echo
        printf "\t Dock, Dashboard, and hot corners\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Enable highlight hover effect for the grid view of a stack (Dock)\n"
        defaults write com.apple.dock mouse-over-hilite-stack -bool true

        printf "\t- Set the icon size of Dock items to 36 pixels\n"
        defaults write com.apple.dock tilesize -int 36

        printf "\t- Change minimize/maximize window effect\n"
        defaults write com.apple.dock mineffect -string "scale"

        printf "\t- Minimize windows into their application’s icon\n"
        defaults write com.apple.dock minimize-to-application -bool true

        printf "\t- Enable spring loading for all Dock items\n"
        defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

        printf "\t- Show indicator lights for open applications in the Dock\n"
        defaults write com.apple.dock show-process-indicators -bool true

        printf "\t- Wipe all (default) app icons from the Dock\n"
        # This is only really useful when setting up a new Mac, or if you don’t use
        # the Dock to launch apps.
        defaults write com.apple.dock persistent-apps -array

        printf "\t- Show only open applications in the Dock\n"
        defaults write com.apple.dock static-only -bool true

        printf "\t- Don’t animate opening applications from the Dock\n"
        defaults write com.apple.dock launchanim -bool false

        printf "\t- Speed up Mission Control animations\n"
        defaults write com.apple.dock expose-animation-duration -float 0.1

        printf "\t- Disable Dashboard\n"
        defaults write com.apple.dashboard mcx-disabled -bool true

        printf "\t- Don’t show Dashboard as a Space\n"
        defaults write com.apple.dock dashboard-in-overlay -bool true

        printf "\t- Don’t automatically rearrange Spaces based on most recent use\n"
        defaults write com.apple.dock mru-spaces -bool false

        printf "\t- Remove the auto-hiding Dock delay\n"
        defaults write com.apple.dock autohide-delay -float 0

        printf "\t- Remove the animation when hiding/showing the Dock\n"
        defaults write com.apple.dock autohide-time-modifier -float 0

        printf "\t- Automatically hide and show the Dock\n"
        defaults write com.apple.dock autohide -bool true

        printf "\t- Make Dock icons of hidden applications translucent\n"
        defaults write com.apple.dock showhidden -bool true

        printf "\t- Disable the Launchpad gesture (pinch with thumb and three fingers)\n"
        defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

        printf "\t- Reset Launchpad, but keep the desktop wallpaper intact\n"
        find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

        # Hot corners
        # Possible values:
        #  0: no-op
        #  2: Mission Control
        #  3: Show application windows
        #  4: Desktop
        #  5: Start screen saver
        #  6: Disable screen saver
        #  7: Dashboard
        # 10: Put display to sleep
        # 11: Launchpad
        # 12: Notification Center
        printf "\t- Hot corners: Top left screen corner → Put display to sleep\n"
        defaults write com.apple.dock wvous-tl-corner -int 10
        defaults write com.apple.dock wvous-tl-modifier -int 0

        ###############################################################################
        echo
        printf "\t Spotlight\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Change indexing order and disable some search results\n"
        # Yosemite-specific search results (remove them if you are using macOS 10.9 or older):
        # 	MENU_DEFINITION
        # 	MENU_CONVERSION
        # 	MENU_EXPRESSION
        # 	MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
        # 	MENU_WEBSEARCH             (send search queries to Apple)
        # 	MENU_OTHER
        defaults write com.apple.spotlight orderedItems -array \
        	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
        	'{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
        	'{"enabled" = 1;"name" = "DIRECTORIES";}' \
        	'{"enabled" = 1;"name" = "PDF";}' \
        	'{"enabled" = 1;"name" = "FONTS";}' \
        	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
        	'{"enabled" = 0;"name" = "MESSAGES";}' \
        	'{"enabled" = 0;"name" = "CONTACT";}' \
        	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
        	'{"enabled" = 0;"name" = "IMAGES";}' \
        	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
        	'{"enabled" = 0;"name" = "MUSIC";}' \
        	'{"enabled" = 0;"name" = "MOVIES";}' \
        	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
        	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
        	'{"enabled" = 0;"name" = "SOURCE";}' \
        	'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
        	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
        	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
        	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
        	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
        	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

        printf "\t- Load new settings before rebuilding the index\n"
        sudo killall mds > /dev/null 2>&1

        printf "\t- Make sure indexing is enabled for the main volume\n"
        sudo mdutil -i on / > /dev/null

        printf "\t- Rebuild the index from scratch\n"
        sudo mdutil -E / > /dev/null

        ###############################################################################
        echo
        printf "\t Terminal\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Only use UTF-8 in Terminal.app\n"
        defaults write com.apple.terminal StringEncodings -array 4

        ###############################################################################
        echo
        printf "\t Time Machine\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Prevent Time Machine from prompting to use new hard drives as backup volume\n"
        defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

        ###############################################################################
        echo
        printf "\t Activity Monitor\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Show the main window when launching Activity Monitor\n"
        defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

        printf "\t- Visualize CPU usage in the Activity Monitor Dock icon\n"
        defaults write com.apple.ActivityMonitor IconType -int 5

        printf "\t- Show all processes in Activity Monitor\n"
        defaults write com.apple.ActivityMonitor ShowCategory -int 0

        printf "\t- Sort Activity Monitor results by CPU usage\n"
        defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
        defaults write com.apple.ActivityMonitor SortDirection -int 0

        ###############################################################################
        echo
        printf "\t Address Book, Dashboard, iCal, TextEdit, and Disk Utility\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Enable the debug menu in Address Book\n"
        defaults write com.apple.addressbook ABShowDebugMenu -bool true

        printf "\t- Enable Dashboard dev mode (allows keeping widgets on the desktop)\n"
        defaults write com.apple.dashboard devmode -bool true

        printf "\t- Enable the debug menu in iCal (pre-10.8)\n"
        defaults write com.apple.iCal IncludeDebugMenu -bool true

        printf "\t- Use plain text mode for new TextEdit documents\n"
        defaults write com.apple.TextEdit RichText -int 0

        printf "\t- Open and save files as UTF-8 in TextEdit\n"
        defaults write com.apple.TextEdit PlainTextEncoding -int 4
        defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

        printf "\t- Enable the debug menu in Disk Utility\n"
        defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
        defaults write com.apple.DiskUtility advanced-image-options -bool true

        ###############################################################################
        echo
        printf "\t Mac App Store\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Enable the WebKit Developer Tools in the Mac App Store\n"
        defaults write com.apple.appstore WebKitDeveloperExtras -bool true

        printf "\t- Enable Debug Menu in the Mac App Store\n"
        defaults write com.apple.appstore ShowDebugMenu -bool true

        printf "\t- Enable the automatic update check\n"
        defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

        printf "\t- Install System data files & security updates\n"
        defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

        ###############################################################################
        echo
        printf "\t Photos\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Prevent Photos from opening automatically when devices are plugged in\n"
        defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

        ###############################################################################
        echo
        printf "\t Messages\n"
        printf "\t #################################\n"
        echo
        ###############################################################################

        printf "\t- Disable smart quotes as it's annoying for messages that contain code\n"
        defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false

        # Disable continuous spell checking
        defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false

        ###############################################################################
        echo
        printf "\t Google Chrome\n"
        printf "\t #################################\n"
        echo

        printf "\t- Disable the all too sensitive backswipe on trackpads\n"
        defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false

        printf "\t- Disable the all too sensitive backswipe on Magic Mouse\n"
        defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false

        printf "\t- Use the system-native print preview dialog\n"
        defaults write com.google.Chrome DisablePrintPreview -bool true

        printf "\t- Expand the print dialog by default\n"
        defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true


        ###############################################################################
        echo
        printf "\t OSX defaults applied. Please do a restart after these changes.\n"
        printf "\t #################################\n"
        echo
        ;;
    *)
        echo
        printf "\033[1mSkipped applying custom Mac OSX configuration\033[0m\n"
        ;;
esac
