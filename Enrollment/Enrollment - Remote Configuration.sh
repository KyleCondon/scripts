#!/bin/sh
#
#	Script Name: Enrollment - Remote Configuration.sh
#	Version: 2.2
#	Requirements:
#		- CocoaDialog
#		- Pashua
#
#	Change Log:
#		6/27/17
#			Total script rewrite streamlining enrollment process.
#		7/7/17
#			Added logic to only force unbind if the computer is aleady bound.
#		7/12/17
#			Adjusted workflow: Created a LaunchDaemon (/Library/LaunchDaemons/com.pcps.firstrun) to run on
#			15 second intervals until the user that is logged in is not a system-level user.
#		7/28/17
#			Added logic to install GUI tools. If it cannot install after 3 attempts, alert user and exit error 1.
#			Added logic to test if AD Bind actually succeeded. If not, it will retry until it is successful.
#		8/15/17
#			Fixed error with computers that were connected to internet via dongles
#
##################################################

# Get currently logged in user
loggedInUser=$(stat -f%Su /dev/console)

# Check if currently logged in user is NOT a system-level user.
if [[ "$loggedInUser" == "_mbsetupuser" ]] || [[ "$loggedInUser" == "root" ]]; then
	echo "Currently logged in user: ${loggedInUser}. Exiting..."
    exit 0
fi

jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
aduser="netadmin-9821b"
adpass="Queenie14"
AD_DOMAIN="polk-fl.net"
COMPUTERS_OU="CN=Computers,DC=polk-fl,DC=net"
MYDIR="/Library/PCPS/apps/"
resourcesDIR="/Library/PCPS/resources"
locationList="http://itvdb.polk-fl.net/downloads/enrollment/locations.txt"

adminLocation="$4"
adminSAP="$5"
adminUser="$6"
adminRole="$7"

if [ $4 == "" ]; then
	echo "Admin did not specify a location number!"
	exit 1
fi

if [ $5 == "" ]; then
	echo "Admin did not specify an SAP number!"
	exit 1
fi

if [ $6 == "" ]; then
	echo "Admin did not specify a user!"
	exit 1
fi

if [ $7 == "" ]; then
	echo "Admin did not specify a role! Using Student as default..."
	adminRole="S"
fi



################
# SCRIPT START #
################
# Install PCPS GUI Tools
# A notification is sent to the user stating enrollment will begin
# Check that GUI tools installed correctly.
# If not, attempt to install it two more times. If it still fails, alert user and exit enrollment.
ATTEMPTS=0
SUCCESS=
while [ -z "${SUCCESS}" ]; do
	if [ ${ATTEMPTS} -le 3 ]; then
		$jamfBinary policy -event main-gui

		if [ -e "/Applications/Pashua.app" ]; then
			SUCCESS="YES"
			sleep 1
		else
			sleep 1
			ATTEMPTS=`expr ${ATTEMPTS} + 1`
		fi

	else
		SUCCESS="NO"
		echo "Could not install PCPS GUI tools."
	fi
done

# Grab location number from hosted txt file
schoolName=`curl -s $locationList | grep "$adminLocation" | awk -F":" '{print $3}'`

if [ $schoolName == "" ]; then
	echo "There was an error retrieving the school's name. Most likely there is an issue with the ethernet dongle."
	exit 1
fi

# Echo details about computer for future diagnostic purposes
echo " "
echo "--- GENERATED INFORMATION ---"
echo "Location Number: $adminLocation"
echo "School Name: $schoolName"
echo "Computer SAP: $adminSAP"
echo "Assigned User: $adminUser"
echo "Assigned Role: $adminRole"
echo " "

# Setup CocoaDialog's progressbar
# create a named pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

# create a background job which takes its input from the named pipe
$CD progressbar --title "PCPS Mac Registration" < /tmp/hpipe &

# associate file descriptor 3 with that pipe and send a character through the pipe
exec 3<> /tmp/hpipe
echo -n . >&3

echo "4% Setting Time Zone..." >&3
echo "Setting Time Zone..." 2>&1
# Set time zone in preparation for AD binding
/usr/sbin/systemsetup -settimezone "America/New_York"
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com"
ntpdate -u time.apple.com
sleep 1

# Check if already bound. If yes, unbind.
bindingCheck=`dsconfigad -show | grep "Active Directory Domain"`
if [[ -z $bindingCheck ]]; then
	echo "Not bound. Skipping unbind..."
else
	echo "Computer already bound. Unbinding..."
	echo "8% Updating Active Directory records..." >&3
	echo "Updating Active Directory records..." 2>&1
	dsconfigad -force -remove -u bogusUsername -p bogusPassword
	sleep 2
fi

# Change ComputerName, HostName, and LocalHostName
echo "12% Setting computer name..." >&3
echo "Setting computer name..." 2>&1
echo "*** Setting the following paramters:"
echo "*** ComputerName: $schoolName - $adminSAP"
echo "*** HostName: $schoolName - $adminSAP"
/usr/sbin/scutil --set ComputerName "${schoolName} - ${adminSAP}"
/usr/sbin/scutil --set HostName "${schoolName} - ${adminSAP}"

computerID="L$adminLocation$adminRole-$adminSAP"
echo "*** LocalHostName: $computerID" 2>&1
/usr/sbin/scutil --set LocalHostName $computerID
sleep 1

echo "16% Assigning user and SAP to computer..." >&3
echo "Assigning user and SAP to computer..." 2>&1
/usr/local/jamf/bin/jamf recon -endUsername $adminUser -assetTag $adminSAP

# Attempt to ind to Active Directory up to 3 times. If failed, alert user and Exit error
ATTEMPTS=0
SUCCESS=
while [ -z "${SUCCESS}" ]; do
  
  if [ ${ATTEMPTS} -le 3 ]; then
  	echo "20% Updating Active Directory records..." >&3
	echo "Updating Active Directory records..." 2>&1
    dsconfigad -add "polk-fl.net" -computer "${computerID}" -ou "${COMPUTERS_OU}" -username "${aduser}" -password "${adpass}" -force
    sleep 2
    IS_BOUND=`dsconfigad -show | grep "Active Directory Domain"`
    
    if [ -n "${IS_BOUND}" ]; then
      SUCCESS="YES"
      echo "24% Update successful!" >&3
      sleep 1
    else
      echo "20% Binding error! Retrying..." >&3
      echo "Binding error! Retrying..." 2>&1
      sleep 3
      ATTEMPTS=`expr ${ATTEMPTS} + 1`
    fi

  else
    echo "20% Binding error after 3 attempts." >&3
	echo "Binding error after 3 attempts." 2>&1
    SUCCESS="NO"
    echo "Binding failed after 3 attempts."
	exit 2
  fi

done

# Setup AD plugin options
echo "28% Updating Active Directory plugin options..." >&3
echo "Updating Active Directory plugin options..." 2>&1
dsconfigad -mobile enable 2>&1
echo "29% Updating Active Directory plugin options..." >&3
dsconfigad -mobileconfirm disable 2>&1
echo "30% Updating Active Directory plugin options..." >&3
dsconfigad -localhome enable 2>&1
echo "31% Updating Active Directory plugin options..." >&3
dsconfigad -useuncpath disable 2>&1
echo "32% Updating Active Directory plugin options..." >&3
dsconfigad -protocol smb 2>&1
echo "33% Updating Active Directory plugin options..." >&3
dsconfigad -packetsign allow 2>&1
echo "34% Updating Active Directory plugin options..." >&3
dsconfigad -packetencrypt allow 2>&1
echo "35% Updating Active Directory plugin options..." >&3
dsconfigad -passinterval 0 2>&1
echo "36% Updating Active Directory plugin options..." >&3
echo "40% Plugin completely updated." >&3
sleep 1

GROUP_MEMBERS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow GroupMembers 2>/dev/null`
NESTED_GROUPS=`dscl /Local/Default -read /Groups/com.apple.access_loginwindow NestedGroups 2>/dev/null`
if [ -z "${GROUP_MEMBERS}" ] && [ -z "${NESTED_GROUPS}" ]; then
	echo "Enabling network users login..." 2>&1
	echo "44% Enabling network users login..." >&3
	dseditgroup -o edit -n /Local/Default -a netaccounts -t group com.apple.access_loginwindow 2>/dev/null
fi

echo "48% Creating local Administrator account..." >&3
echo "Creating local Administrator account..." 2>&1
# Create Administrator account
adminAccount="/Users/administrator"

if [ -d "$adminAccount" ]; then
	echo "Administrator account exists. Ensuring correct password: EERS@$adminLocation"
	dscl . -passwd /Users/administrator "EERS@$adminLocation"
else
	echo "Administrator account does not exist. Creating one with password: EERS@$adminLocation"
	# Create Local Administrator based on Network Segment
	LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
    NextID=$((LastID + 1))

	dscl . create /Users/administrator
	dscl . create /Users/administrator RealName "Administrator"
	dscl . create /Users/administrator hint "Location"
	dscl . create /Users/administrator picture "/Library/User Pictures/Animals/Eagle.tif"
	dscl . passwd /Users/administrator "EERS@$adminLocation"
	dscl . create /Users/administrator UniqueID $NextID
	dscl . create /Users/administrator PrimaryGroupID 80
	dscl . create /Users/administrator UserShell /bin/bash
	dscl . create /Users/administrator NFSHomeDirectory /Users/administrator
	dscl . -append /Groups/admin GroupMembership administrator
	cp -R /System/Library/User\ Template/English.lproj /Users/administrator
	chown -R administrator:staff /Users/administrator
fi

echo "52% Configuring: System Settings..." >&3
echo "Configuring: System Settings..." 2>&1
# Disable Time Machine's pop-up message whenever an external drive is plugged in
/usr/bin/defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

echo "56% Configuring: System Settings..." >&3
# Disable GateKeeper
spctl --master-disable

echo "60% Configuring: System Settings..." >&3
# Enable and configure Apple Remote Desktop
ARD="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
$ARD -configure -activate
$ARD -configure -access -on
$ARD -configure -allowAccessFor -specifiedUsers
$ARD -configure -access -on -users jamfadmin -privs -all
$ARD -configure -access -on -users administrator -privs -all

echo "64% Configuring: System Settings..." >&3
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

echo "68% Configuring System Settings..." >&3
# LOGIN WINDOW CONFIGURATION
# Set diaplay to username and password text fields
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName
/usr/bin/defaults write /Library/Preferences/com.apple.loginwindow EnableExternalAccounts -bool false

echo "72% Configuring System Settings..." >&3
# DISABLE ICLOUD SETUO
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

echo "76% Configuring System Settings..." >&3
# DISABLE DIAGNOSTIC REPORTS
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

echo "80% Configuring System Settings..." >&3
# ENABLE FINDER SCROLL BARS
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

echo "84% Installing: iBoss Agent..." >&3
echo "Installing: iBoss Agent..." 2>&1
# Create Administrator account
$jamfBinary policy -event main-iboss

# Install Adobe Flash
echo "88% Installing: Adobe Flash Player..." >&3
$jamfBinary policy -event main-flash

# Uninstall Munki, if exists
if [ -d "/Applications/Managed Software Center.app" ]; then
	echo "90% Removing Managed Software Center components..." >&3
    $jamfBinary policy -event uninstallMunki
else
	echo "Managed Software Center not found. Skipping removal..."
fi

# Uninstall StarDeploy, if exists
if [ -e "/Library/LaunchDaemons/sssd.plist" ]; then
  echo "92% Removing StarDeploy  components..." >&3
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

# Install all pending Apple software updates
echo "96% Installing software updates. This may take some time..." >&3
softwareupdate -i -a

# Clean up
echo "99% Cleaning up..." >&3
# Create /Library/PCPS/resources directory if it does not exist
if [ ! -d "${resourcesDIR}" ]; then
	mkdir -p $resourcesDIR
fi

# Add the enroll file so that the JSS will know enrollment completed
touch ${resourcesDIR}/enrolled

# Remove LaunchDaemon
rm /Library/LaunchDaemons/com.pcps.firstrun.plist

# Create enrollWebsite file so that the JSS will display the completed website page on next login.
touch /Library/PCPS/resources/enrollWebsite

# Run a final recon
echo "100% Registration complete! Restarting in about 1 minute..." >&3
$jamfBinary recon

exec 3>&-
rm -f /tmp/hpipe

# Force computer restart
sudo shutdown -r now