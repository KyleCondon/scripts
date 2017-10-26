#!/bin/bash
#
# Script Name: Enrollment Configuration.sh
# Version: 1.9
# Last Update: 1/21/2017
# Requirements:
#   - CocoaDialog
#   - Pashua
#
# Change History
#	2/10/17
#		Rearranged workflow to get GUI in front of user more quickly
#	2/3/17
#		Added internet connection check so that enrollment does not try to proceed without internet.
#		Rearranged the starting process so that the enrollment can begin more quckly
#   1/21/17
#    	Separated resources installs into their own policies. This makes it easier to update apps for deployment.
#   1/20/17
#     Added an optional custom event to be triggered before software updates occur.
#   12/5/16
#     Created a "registration" screen
#
##################################################
jamfBinary="/usr/local/jamf/bin/jamf"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
adUser="$4"
adPass="$5"

#internetConnection="Down"
#until [  $internetConnection == "Up" ]; do
#  if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
#    echo "Up"
#    internetConnection="Up"
#  else
#    echo "Down"
#    internetConnection="Down"
#    sleep 2
#  fi
#done

# Install icons for GUI
$jamfBinary policy -event main-pashua

# Unbind from Active Directory
dsconfigad -remove -username $adUser -password $adPass

# Launch Mac Registration screen AD Binding script
$jamfBinary policy -event enrollBindToAD

# Setup CocoaDialog's progressbar
# create a named pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

# create a background job which takes its input from the named pipe
$CD progressbar --posY "425" --title "System Configuration" < /tmp/hpipe &

# associate file descriptor 3 with that pipe and send a character through the pipe
exec 3<> /tmp/hpipe
echo -n . >&3

echo "7% Installing: DockUtil..." >&3
$jamfBinary policy -event main-dockutil

echo "14% Installing: iBoss Agent..." >&3
$jamfBinary policy -event enrolliBoss

echo "21% Configuring System Settings..." >&3
# Disable Time Machine's pop-up message whenever an external drive is plugged in
/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "28% Configuring System Settings..." >&3
# Disable GateKeeper
spctl --master-disable

echo "35% Configuring System Settings..." >&3
# Enable and configure Apple Remote Desktop
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
$ARD -configure -activate
$ARD -configure -access -on
$ARD -configure -allowAccessFor -specifiedUsers
$ARD -configure -access -on -users jamfadmin -privs -all
$ARD -configure -access -on -users administrator -privs -all

echo "42% Configuring System Settings..." >&3
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

echo "49% Configuring System Settings..." >&3
################################################
# LOGIN WINDOW CONFIGURATION
################################################
# Set diaplay to username and password text fields
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow EnableExternalAccounts -bool false

echo "56% Configuring System Settings..." >&3
################################################
# DISABLE ICLOUD SETUO
################################################
# Get OS Version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
sw_vers=$(sw_vers -productVersion)

# For FUture Users
for USER_TEMPLATE in "/System/Library/User Template"/*
	do
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool true
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
		/usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
	done

# For Current Users
for USER_HOME in /Users/*
	do
		USER_UID=`basename "${USER_HOME}"`
		if [ ! "${USER_UID}" = "Shared" ]; then
			if [ ! -d "${USER_HOME}"/Library/Preferences ]; then
				mkdir -p "${USER_HOME}"/Library/Preferences
				chown "${USER_UID}" "${USER_HOME}"/Library
				chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
			fi
		if [ -d "${USER_HOME}"/Library/Preferences ]; then
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool true
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant GestureMovieSeen none
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenCloudProductVersion "${sw_vers}"
			/usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant LastSeenBuddyBuildVersion "${sw_build}"
			chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/com.apple.SetupAssistant.plist
		fi
	fi
	done

echo "63% Configuring System Settings..." >&3
################################################
# DISABLE DIAGNOSTIC REPORTS
################################################
# Define variables
SUBMIT_TO_APPLE=NO
SUBMIT_TO_APP_DEVELOPERS=NO

# For future users
PlistBuddy="/usr/libexec/PlistBuddy"
os_rev_major=`/usr/bin/sw_vers -productVersion | awk -F "." '{ print $2 }'`
if [ $os_rev_major -ge 10 ]; then
  CRASHREPORTER_SUPPORT="/Library/Application Support/CrashReporter"
  CRASHREPORTER_DIAG_PLIST="${CRASHREPORTER_SUPPORT}/DiagnosticMessagesHistory.plist"

  if [ ! -d "${CRASHREPORTER_SUPPORT}" ]; then
    mkdir "${CRASHREPORTER_SUPPORT}"
    chmod 775 "${CRASHREPORTER_SUPPORT}"
    chown root:admin "${CRASHREPORTER_SUPPORT}"
  fi

  for key in AutoSubmit AutoSubmitVersion ThirdPartyDataSubmit ThirdPartyDataSubmitVersion; do
    $PlistBuddy -c "Delete :$key" "${CRASHREPORTER_DIAG_PLIST}" 2> /dev/null
  done

  $PlistBuddy -c "Add :AutoSubmit bool ${SUBMIT_TO_APPLE}" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :AutoSubmitVersion integer 4" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :ThirdPartyDataSubmit bool ${SUBMIT_TO_APP_DEVELOPERS}" "${CRASHREPORTER_DIAG_PLIST}"
  $PlistBuddy -c "Add :ThirdPartyDataSubmitVersion integer 4" "${CRASHREPORTER_DIAG_PLIST}"
fi

echo "70% Configuring System Settings..." >&3
################################################
# ENABLE FINDER SCROLL BARS
################################################
# For future users
for USER_TEMPLATE in "/System/Library/User Template"/*
  do
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences
     fi
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences/ByHost
     fi
     if [ -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
     fi
  done

 # For current users
 for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ] 
     then 
      if [ ! -d "${USER_HOME}"/Library/Preferences ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ ! -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences/ByHost
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
	chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost
      fi
      if [ -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/.GlobalPreferences.*
      fi
    fi
  done

# Uninstall MSC if exists
if [ -d "/Applications/Managed Software Center.app" ]; then
	echo "75% Removing Managed Software Center components..." >&3
    $jamfBinary policy -event uninstallMunki
else
	echo "Managed Software Center not found. Skipping removal..."
fi

# Uninstall StarDeploy if exists
if [ -e "/Library/LaunchDaemons/sssd.plist" ]; then
  echo "78% Removing StarDeploy  components..." >&3
  launchctl unload -wF sssd.plist
  rm -R /usr/bin/sssd
  rm -R /Library/Application\ Support/sssd 
  rm -R /Library/PreferencePanes/sssd.prefPane 
  rm -R /Library/LaunchDaemons/sssd.plist
  rm -R /Library/Preferences/com.sssd.plist
  rm -R /private/var/db/sssd
  rm -R /Library/LaunchDaemons/com.stardeploy.sssd.plist
  rm -R /Library/Preferences/com.stardeploy.sssd.plist
  rm -R /Library/Application\ Support/StarDeploy
else
  echo "StarDeploy not found. Skipping removal..."
fi

# Install Adobe Flash
echo "85% Installing: Adobe Flash Player..." >&3
$jamfBinary policy -event enrollFlash

if [ "$6" == "" ]; then
  echo "No custom event found. Skipping..."
else
  echo "Executing event: ${6}"
  echo "90% Finalizing configurations..." >&3
  $jamfBinary policy -event $6
fi

# Launch Software Update script
echo "95% Checking for software updates..." >&3
$jamfBinary policy -event enrollUpdates

# Enrollment complete. Run recon, close cocoaDialog, then reboot computer
echo "100% Enrollment complete! Restarting in 1 minute..." >&3


$jamfBinary recon
exec 3>&-
rm -f /tmp/hpipe

sudo shutdown -r now

exit 0