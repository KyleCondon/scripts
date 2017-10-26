#!/bin/sh
#
#	Script Name: Enrollment - Configuration 2.0.sh
#	Version: 2.0.1
#	Last Update: 7/7/2017
#	Requirements:
#		- CocoaDialog
#		- Pashua
#
#	Change Log:
#		6/27/17
#			Total script rewrite streamlining enrollment process.
#		7/7/17
#			Added logic to only force unbind if the computer is aleady bound.
#
##################################################
jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
aduser="$4"
adpass="$5"
AD_DOMAIN="polk-fl.net"
COMPUTERS_OU="CN=Computers,DC=polk-fl,DC=net"
MYDIR="/Library/PCPS/apps/"
resourcesDIR="/Library/PCPS/resources"

# Install PCPS GUI Tools
# A notification is sent to the user stating enrollment will begin
$jamfBinary policy -event main-gui

# Check that GUI tools installed correctly.
# If not, alert user and exit enrollment.
if [ ! -e "/Applications/Pashua.app" ]; then
	$CD msgbox --title "PCPS Mac Enrollment" --icon "caution" --text "Required application not found. Contact Justin Phillips at 647-4256" --button1 "OK"
	exit 1
fi

# Include pashua.sh to be able to use the 2 functions defined in that file
source "$MYDIR/pashua.sh"

# Checking for required hard-wired Ethernet
en0=`ifconfig en0 | grep "inet " | awk '{print $2}' | cut -c1-6`
en1=`ifconfig en1 | grep "inet " | awk '{print $2}' | cut -c1-6`
en2=`ifconfig en2 | grep "inet " | awk '{print $2}' | cut -c1-6`

ipAddress=""

if [ ! -z $en0 ]; then
	ipAddress=$en0
elif [ ! -z $en1 ]; then
	ipAddress=$en1
elif [ ! -z $en2 ]; then
	ipAddress=$en2
fi

echo "Truncated IP Address: $ipAddress"

school=""
locationNumber=""

if [ $ipAddress == "10.228" ]; then
	school="Alta Vista Elementary"
	locationNumber=0331
elif [ $ipAddress == "10.186" ]; then
	school="Alturas Elementary"
	locationNumber=1041
elif [ $ipAddress == "10.160" ]; then
	school="Auburndale Central Elementary"
	locationNumber=0851
elif [ $ipAddress == "10.240" ]; then
	school="Auburndale Senior"
	locationNumber=0811
elif [ $ipAddress == "10.166" ]; then
	school="Bartow Middle"
	locationNumber=0931
elif [ $ipAddress == "10.1.3" ]; then
	school="Bartow Municipal Airport"
	locationNumber=9365
elif [ $ipAddress == "10.161" ]; then
	school="Bartow Senior"
	locationNumber=0901
elif [ $ipAddress == "10.183" ]; then
	school="Ben Hill Griffin Jr Elementary"
	locationNumber=1921
elif [ $ipAddress == "10.169" ]; then
	school="Bethune Academy"
	locationNumber=0391
elif [ $ipAddress == "10.221" ]; then
	school="Bill Duncan Opportunity Center"
	locationNumber=2001
elif [ $ipAddress == "10.189" ]; then
	school="Blake Academy"
	locationNumber=1861
elif [ $ipAddress == "10.229" ]; then
	school="Boone Middle"
	locationNumber=0321
elif [ $ipAddress == "10.178" ]; then
	school="Boswell Elementary"
	locationNumber=1811
elif [ $ipAddress == "10.170" ]; then
	school="Brigham Academy"
	locationNumber=0531
elif [ $ipAddress == "10.230" ]; then
	school="Caldwell Elementary"
	locationNumber=0861
elif [ $ipAddress == "10.194" ]; then
	school="Carlton Palmore Elementary"
	locationNumber=0061
elif [ $ipAddress == "10.248" ]; then
	school="Chain of Lakes Elementary"
	locationNumber=0933
elif [ $ipAddress == "10.145" ]; then
	school="Churchwell Elementary"
	locationNumber=1841
elif [ $ipAddress == "10.114" ]; then
    school="Citrus Ridge Civics Academy"
	locationNumber=1032
elif [ $ipAddress == "10.146" ]; then
	school="Cleveland Court Elementary"
	locationNumber=0081
elif [ $ipAddress == "10.216" ]; then
	school="Combee Elementary"
	locationNumber=0091
elif [ $ipAddress == "10.231" ]; then
	school="Crystal Lake Elementary"
	locationNumber=0101
elif [ $ipAddress == "10.156" ]; then
	school="Crystal Lake Middle"
	locationNumber=1501
elif [ $ipAddress == "10.245" ]; then
	school="Daniel Jenkins Academy"
	locationNumber=0311
elif [ $ipAddress == "10.223" ]; then
	school="Davenport School of the Arts"
	locationNumber=0401
elif [ $ipAddress == "10.155" ]; then
	school="Denison Middle"
	locationNumber=0491
elif [ $ipAddress == "10.225" ]; then
	school="Dixieland Elementary"
	locationNumber=0131
elif [ $ipAddress == "10.137" ]; then
	school="Don Woods Opportunity Center"
	locationNumber=0421
elif [ $ipAddress == "10.216" ]; then
	school="Doris A Sanders Learning Center"
	locationNumber=0092
elif [ $ipAddress == "10.246" ]; then
	school="Dr. N.E. Roberts Elementary"
	locationNumber=1821
elif [ $ipAddress == "10.149" ]; then
	school="Dundee Academy"
	locationNumber=1781
elif [ $ipAddress == "10.243" ]; then
	school="Dundee Ridge Middle"
	locationNumber=1981
elif [ $ipAddress == "10.234" ]; then
	school="Eagle Lake Elementary"
	locationNumber=1701
elif [ $ipAddress == "10.235" ]; then
	school="East Area Adult School"
	locationNumber=0871
elif [ $ipAddress == "10.236" ]; then
	school="Eastside Elementary"
	locationNumber=0361
elif [ $ipAddress == "10.237" ]; then
	school="Elbert Elementary"
	locationNumber=0591
elif [ $ipAddress == "10.135" ]; then
	school="Floral Avenue Elementary"
	locationNumber=0961
elif [ $ipAddress == "10.192" ]; then
	school="Fort Meade Middle-Senior"
	locationNumber=0791
elif [ $ipAddress == "10.182" ]; then
	school="Frostproof Elementary"
	locationNumber=1291
elif [ $ipAddress == "10.162" ]; then
	school="Frostproof Middle-Senior"
	locationNumber=1801
elif [ $ipAddress == "10.181" ]; then
	school="Garden Grove Elementary"
	locationNumber=1711
elif [ $ipAddress == "10.202" ]; then
	school="Garner Elementary"
	locationNumber=0601
elif [ $ipAddress == "10.201" ]; then
	school="Gause Academy"
	locationNumber=1491
elif [ $ipAddress == "10.164" ]; then
	school="George Jenkins Senior"
	locationNumber=1931
elif [ $ipAddress == "10.205" ]; then
	school="Gibbons Street Elementary"
	locationNumber=0981
elif [ $ipAddress == "10.185" ]; then
	school="Griffin Elementary"
	locationNumber=1231
elif [ $ipAddress == "10.148" ]; then
	school="Haines City Senior"
	locationNumber=1791
elif [ $ipAddress == "10.121" ]; then
	school="Harrison School for the Arts"
	locationNumber=0033
elif [ $ipAddress == "10.199" ]; then
	school="Highland City Elementary"
	locationNumber=1061
elif [ $ipAddress == "10.130" ]; then
	school="Highlands Grove Elementary"
	locationNumber=1281
elif [ $ipAddress == "10.210" ]; then
	school="Horizons Elementary"
	locationNumber=1362
elif [ $ipAddress == "10.133" ]; then
	school="Inwood Elementary"
	locationNumber=0611
elif [ $ipAddress == "10.123" ]; then
	school="Jean O'Dell Learning Center"
	locationNumber=0000
elif [ $ipAddress == "10.224" ]; then
	school="Jesse Keen Elementary"
	locationNumber=1241
elif [ $ipAddress == "10.204" ]; then
	school="Jewett Middle Academy"
	locationNumber=0711
elif [ $ipAddress == "10.220" ]; then
	school="Jewett School of the Arts"
	locationNumber=0712
elif [ $ipAddress == "10.188" ]; then
	school="Karen M. Siegal Academy"
	locationNumber=0661
elif [ $ipAddress == "10.177" ]; then
	school="Kathleen Elementary"
	locationNumber=1221
elif [ $ipAddress == "10.176" ]; then
	school="Kathleen Middle"
	locationNumber=1191
elif [ $ipAddress == "10.175" ]; then
	school="Kathleen Senior"
	locationNumber=1181
elif [ $ipAddress == "10.232" ]; then
	school="Kingsford Elementary"
	locationNumber=
elif [ $ipAddress == "10.198" ]; then
	school="Lake Alfred Elementary"
	locationNumber=0651
elif [ $ipAddress == "10.197" ]; then
	school="Lake Alfred-Addair Middle"
	locationNumber=1662
elif [ $ipAddress == "10.226" ]; then
	school="Lake Gibson Middle"
	locationNumber=1761
elif [ $ipAddress == "10.153" ]; then
	school="Lake Gibson Senior"
	locationNumber=1762
elif [ $ipAddress == "10.128" ]; then
	school="Lake Marion Creek Middle"
	locationNumber=1831
elif [ $ipAddress == "10.163" ]; then
	school="Lake Region Senior"
	locationNumber=1991
elif [ $ipAddress == "10.206" ]; then
	school="Lake Shipp Elementary"
	locationNumber=0621
elif [ $ipAddress == "10.174" ]; then
	school="Lake Wales Senior"
	locationNumber=1721
elif [ $ipAddress == "10.195" ]; then
	school="Lakeland Highlands Middle"
	locationNumber=1771
elif [ $ipAddress == "10.158" ]; then
	school="Lakeland Senior"
	locationNumber=0031
elif [ $ipAddress == "10.126" ]; then
	school="Laurel Elementary"
	locationNumber=1611
elif [ $ipAddress == "10.173" ]; then
	school="Lawton Chiles Middle Academy"
	locationNumber=0043
elif [ $ipAddress == "10.222" ]; then
	school="Lena Vista Elementary"
	locationNumber=0841
elif [ $ipAddress == "10.217" ]; then
	school="Lewis Elementary - Anna Woodbury Campus"
	locationNumber=0802
elif [ $ipAddress == "10.212" ]; then
	school="Lewis Elementary - Lewis Campus"
	locationNumber=0771
elif [ $ipAddress == "10.144" ]; then
	school="Lincoln Avenue Academy"
	locationNumber=0251
elif [ $ipAddress == "10.138" ]; then
	school="Loughman Oaks Elementary"
	locationNumber=1941
elif [ $ipAddress == "10.167" ]; then
	school="McLaughlin Academy"
	locationNumber=1341
elif [ $ipAddress == "10.193" ]; then
	school="Medulla Elementary"
	locationNumber=0181
elif [ $ipAddress == "10.179" ]; then
	school="Mulberry Middle"
	locationNumber=1161
elif [ $ipAddress == "10.159" ]; then
	school="Mulberry Senior"
	locationNumber=1131
elif [ $ipAddress == "10.215" ]; then
	school="North Lakeland Elementary"
	locationNumber=0201
elif [ $ipAddress == "10.239" ]; then
	school="Oscar J Pope Elementary"
	locationNumber=1521
elif [ $ipAddress == "10.147" ]; then
	school="Padgett Elementary"
	locationNumber=1451
elif [ $ipAddress == "10.129" ]; then
	school="Palmetto Elementary"
	locationNumber=1702
elif [ $ipAddress == "10.227" ]; then
	school="Philip O'Brien Elementary"
	locationNumber=0151
elif [ $ipAddress == "10.184" ]; then
	school="Pinewood Elementary"
	locationNumber=1731
#elif [ $ipAddress == "10.164" ]; then
#	school="Polk Avenue Elementary"
#	locationNumber=1351
elif [ $ipAddress == "10.200" ]; then
	school="Polk City Elementary"
	locationNumber=0881
#elif [ $ipAddress == "10.164" ]; then
#	school="Polk Life and Learning Center"
#	locationNumber=0962
elif [ $ipAddress == "10.132" ]; then
	school="Purcell Elementary"
	locationNumber=1141
elif [ $ipAddress == "10.247" ]; then
	school="R. Bruce Wagner Elementary"
	locationNumber=0191
elif [ $ipAddress == "10.249" ]; then
	school="Ridge Community Senior"
	locationNumber=0937
elif [ $ipAddress == "10.208" ]; then
	school="Rochelle School of the Arts"
	locationNumber=0261
elif [ $ipAddress == "10.219" ]; then
	school="Roosevelt Academy"
	locationNumber=1381
elif [ $ipAddress == "10.142" ]; then
	school="Sandhill Elementary"
	locationNumber=0341
elif [ $ipAddress == "10.187" ]; then
	school="Scott Lake Elementary"
	locationNumber=1681
elif [ $ipAddress == "10.213" ]; then
	school="Sikes Elementary"
	locationNumber=1821
elif [ $ipAddress == "10.131" ]; then
	school="Sleepy Hill Elementary"
	locationNumber=1271
elif [ $ipAddress == "10.244" ]; then
	school="Sleepy Hill Middle"
	locationNumber=1971
elif [ $ipAddress == "10.191" ]; then
	school="Snively Elementary"
	locationNumber=0631
elif [ $ipAddress == "10.134" ]; then
	school="Socrum Elementary"
	locationNumber=1901
elif [ $ipAddress == "10.141" ]; then
	school="Southwest Elementary"
	locationNumber=0231
elif [ $ipAddress == "10.140" ]; then
	school="Southwest Middle"
	locationNumber=0051
elif [ $ipAddress == "10.211" ]; then
	school="Spessard L. Holland Elementary"
	locationNumber=1908
elif [ $ipAddress == "10.151" ]; then
	school="Spook Hill Elementary"
	locationNumber=1371
elif [ $ipAddress == "10.171" ]; then
	school="Stambaugh Middle"
	locationNumber=0821
elif [ $ipAddress == "10.209" ]; then
	school="Stephens Elementary"
	locationNumber=1751
elif [ $ipAddress == "10.139" ]; then
	school="Tenoroc Senior"
	locationNumber=1051
elif [ $ipAddress == "10.152" ]; then
	school="Traviss Career Center"
	locationNumber=1591
elif [ $ipAddress == "10.207" ]; then
	school="Union Academy"
	locationNumber=0971
elif [ $ipAddress == "10.154" ]; then
	school="Valleyview Elementary"
	locationNumber=1891
elif [ $ipAddress == "10.136" ]; then
	school="Wahneta Elementary"
	locationNumber=0681
elif [ $ipAddress == "10.241" ]; then
	school="Wendell Watson Elementary"
	locationNumber=1881
elif [ $ipAddress == "10.242" ]; then
	school="Westwood Middle"
	locationNumber=0571
elif [ $ipAddress == "10.143" ]; then
	school="Winston Academy"
	locationNumber=1251
elif [ $ipAddress == "10.157" ]; then
	school="Winter Haven Senior"
	locationNumber=0481
fi

# Get serial number
serialNumber=`/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial\ Number\ \(system\)/ {print $NF}'`

# Determine computer model to select correct image
computerModel=`system_profiler SPHardwareDataType | grep "Model Name:" | awk '{print $3}'`

# Create /Library/PCPS/resources directory if it does not exist
resourcesDIR="/Library/PCPS/resources"
if [ ! -d "${resourcesDIR}" ]; then
	mkdir -p $resourcesDIR
fi

# Download image based on computer model. If model can't be determined, use the Self Service icon.
computerIcon=""
if [ "${computerModel}" == "iMac" ]; then
		curl -o ${resourcesDIR}/model-iMac.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-iMac.png
		computerIcon="model-iMac.png"
	elif [ "${computerModel}" == "MacBook" ]; then
		curl -o ${resourcesDIR}/model-MacBook.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacBook.png
		computerIcon="model-MacBook.png"
	elif [ "${computerModel}" == "Mac" ]; then
		curl -o ${resourcesDIR}/model-MacMini.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacMini.png
		computerIcon="model-MacMini.png"
	elif [ "${computerModel}" == "MacPro" ]; then
		curl -o ${resourcesDIR}/model-MacPro.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-MacPro.png
		computerIcon="model-MacPro.png"
	else
		curl -o ${resourcesDIR}/model-All.png http://itvdb.polk-fl.net/downloads/MacEnroller/images/model-All.png
		computerIcon="model-All.png"
fi

# Check if image downloaded correctly. If not, use the Self Service icon.
iconFullPath="/Library/PCPS/resources/${computerIcon}"
if [ ! -e "$iconFullPath" ]; then
	iconFullPath="/Applications/Self Service.app/Contents/resources/Self Service.icns"
fi

# Define the registration screen function
function registerScreen {
db=""
while [ "$db" == "" ]; do	
	conf="
	# Window Title
	*.title = Mac Registration
	*.floating = 1
	*.y = 25

	# Computer image
	img.type = image
	img.maxwidth = 200
	img.relx = 47
	img.path = ${iconFullPath}

	# Serial Number
	serial.type = text
	serial.relx = 45
	serial.default = Computer Serial: ${serialNumber}

	# Textfield: Location
	location.type = textfield
	location.label = School or Department location number:
	location.width = 40
	location.mandatory = TRUE
	location.default = ${locationNumber}

	# Textfield: sap
	sap.type = textfield
	sap.width = 75
	sap.label = Computer's eight-digit SAP:
	sap.placeholder = 50123456
	sap.mandatory = TRUE

	# Textfield: username
	clientUser.type = textfield
	clientUser.label = Assign computer to a user in the form of "john.smith":
	clientUser.placeholder = First.LastName
	clientUser.mandatory = TRUE

	# Radio: Computer's User Environment
	environment.type = radiobutton
	environment.label = Select the computer's primary role (student if unsure):
	environment.mandatory = TRUE
	environment.default = Student
	environment.option = Administrator
	environment.option = Lab
	environment.option = Student
	environment.option = Teacher

	# Cancel button
	cb.type = cancelbutton
	cb.disabled = 1

	# Register button
	db.type = defaultbutton
	db.label = Register
	db.tooltip = Register this computer.
	"
		
	if [ -d '/Volumes/Pashua/Pashua.app' ]; then
		# Looks like the Pashua disk image is mounted. Run from there.
		customLocation='/Volumes/Pashua'
	else
		# Search for Pashua in the standard locations
		customLocation=''
	fi

	pashua_run "$conf" "$customLocation"
done
}

# Display Registration screen to user
registerScreen

# If user closes or quits Pashua, alert them that it cannot be skipped.
if [ "$db" == "0" ]; then
	$CD msgbox --title "Mac Enrollment" --icon "caution" --text "Registration cannot be skipped." --button1 "OK"
fi

#
# Below is when user has selected the Register button
#
if [ "$school" == "" ]; then
	school="Not Found"
fi
if [ "$locationNumber" == "" ]; then
	locationNumber="Not Found"
fi

# Echo details about computer for future diagnostic purposes
echo " "
echo "--- AUTOMATIC INFORMATION ---"
echo "Truncated IP Address: $ipAddress"
echo "School: $school"
echo "Location Number: $locationNumber"
echo " "

# Redfine the environment variables as their first letter, due to the PCPS naming convention
environment=`echo $environment | cut -c1-1`

# Department location numbers cannot be identified by IP address
# Assign department names to specified location numbers.
# This should be updated by adding departments in the future
if [ "$location" == "9107" ]; then
	school="Acceleration & Innovation"
elif [ "$location" == "9802" ]; then
	school="EERS"
elif [ "$location" == "9345" ]; then
	school="ESOL"
elif [ "$location" == "9801" ]; then
	school="IST"
elif [ "$location" == "9822" ]; then
	school="ITV"
elif [ "$location" == "9340" ]; then
	school="LMS"
elif [ "$location" == "9803" ]; then
	school="Networking"
elif [ "$location" == "9302" ]; then
	school="PD"
elif [ "$location" == "9108" ]; then
	school="PR"
elif [ "$location" == "9821" ]; then
	school="STS"
else
	school="Unknown"
fi

# Display variables for future diagnostic purposes
echo " "
echo "--- USER PROVIDED INFORMATION ---"
echo "Location Number: $location"
echo "Matching School: $school"
echo "SAP: $sap"
echo "Client: $clientUser"
echo "Environment: $environment"
echo " "

# Setup CocoaDialog's progressbar
# create a named pipe
rm -f /tmp/hpipe
mkfifo /tmp/hpipe

# create a background job which takes its input from the named pipe
$CD progressbar --title "PCPS Mac Enrollment" < /tmp/hpipe &

# associate file descriptor 3 with that pipe and send a character through the pipe
exec 3<> /tmp/hpipe
echo -n . >&3

echo "4% Setting Time Zone..." >&3
echo "Setting Time Zone..." 2>&1
# Set time zone in preparation for AD binding
/usr/sbin/systemsetup -settimezone "America/New_York"
/usr/sbin/systemsetup -setusingnetworktime on
/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com"
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
	sleep 1
fi


# Change ComputerName, HostName, and LocalHostName
echo "12% Setting computer name..." >&3
echo "Setting computer name..." 2>&1
echo "*** Setting the following paramters:"
echo "*** ComputerName: $school - $sap"
echo "*** HostName: $school - $sap"
/usr/sbin/scutil --set ComputerName "${school} - ${sap}"
/usr/sbin/scutil --set HostName "${school} - ${sap}"

computerID="L$location$environment-$sap"
echo "*** LocalHostName: $computerID" 2>&1
/usr/sbin/scutil --set LocalHostName $computerID
sleep 1

echo "16% Assigning user and SAP to computer..." >&3
echo "Assigning user and SAP to computer..." 2>&1
/usr/local/jamf/bin/jamf recon -endUsername $clientUser -assetTag $sap


echo "20% Updating Active Directory records..." >&3
echo "Updating Active Directory records..." 2>&1
dsconfigad -add "polk-fl.net" -computer "${computerID}" -ou "${COMPUTERS_OU}" -username "${aduser}" -password "${adpass}" -force 2>&1

IS_BOUND=`dsconfigad -show | grep "Active Directory Domain"`
if [ -n "${IS_BOUND}" ]; then
	echo "24% Update successful!" >&3
  sleep 1
else
	echo "An error occured while trying to bind this computer to AD." 2>&1
    echo "20% An error occured while binding to Active Directory." >&3
fi

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
	echo "Administrator account exists. Ensuring correct password: EERS@$location"
	dscl . -passwd /Users/administrator "EERS@$location"
else
	echo "Administrator account does not exist. Creating one with password: EERS@$location"
	# Create Local Administrator based on Network Segment
	LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
    NextID=$((LastID + 1))

	dscl . create /Users/administrator
	dscl . create /Users/administrator RealName "Administrator"
	dscl . create /Users/administrator hint "Location"
	dscl . create /Users/administrator picture "/Library/User Pictures/Animals/Eagle.tif"
	dscl . passwd /Users/administrator "EERS@$locationNumber"
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
$jamfBinary policy -event enrolliBoss

# Install Adobe Flash
echo "88% Installing: Adobe Flash Player..." >&3
$jamfBinary policy -event enrollFlash

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
echo "96% Installing available software updates. Do not shutdown your computer as this may take a few moments..." >&3
softwareupdate -i -a

# Enrollment complete. Run recon, close cocoaDialog, then reboot computer
echo "100% Enrollment complete! Restarting in 1 minute..." >&3

# Add the enroll file to /Library/PCPS/resources directory
touch ${resourcesDIR}/enrolled

# Run a final recon so that the JSS can ne fully up to date
$jamfBinary recon

exec 3>&-
rm -f /tmp/hpipe

# Force computer restart
sudo shutdown -r now
exit 0