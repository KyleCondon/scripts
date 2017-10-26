#!/bin/sh
jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
locationList="http://itvdb.polk-fl.net/downloads/enrollment/locations.txt"

# Checking for required hard-wired Ethernet
en0=`ifconfig en0 | grep "inet " | awk '{print $2}' | cut -c1-6`
en1=`ifconfig en1 | grep "inet " | awk '{print $2}' | cut -c1-6`
en2=`ifconfig en2 | grep "inet " | awk '{print $2}' | cut -c1-6`
en3=`ifconfig en3 | grep "inet " | awk '{print $2}' | cut -c1-6`
en4=`ifconfig en4 | grep "inet " | awk '{print $2}' | cut -c1-6`
en5=`ifconfig en5 | grep "inet " | awk '{print $2}' | cut -c1-6`
en6=`ifconfig en6 | grep "inet " | awk '{print $2}' | cut -c1-6`

ipAddress=""

if [ ! -z $en0 ]; then
	ipAddress=$en0
elif [ ! -z $en1 ]; then
	ipAddress=$en1
elif [ ! -z $en2 ]; then
	ipAddress=$en2
elif [ ! -z $en3 ]; then
	ipAddress=$en3
elif [ ! -z $en4 ]; then
	ipAddress=$en4
elif [ ! -z $en5 ]; then
	ipAddress=$en5
elif [ ! -z $en6 ]; then
	ipAddress=$en6
fi

# Grab location number from hosted txt file
schoolNumber=`curl -s $locationList | grep "$ipAddress" | awk -F":" '{print $2}'`

# Echo details about computer for future diagnostic purposes
echo " "
echo "--- AUTOMATICALLY GENERATED INFORMATION ---"
echo "Truncated IP Address: $ipAddress"
echo "School Number: $schoolNumber"
echo " "

if [ "$schoolNumber" == "" ]; then
	#do nothing
	echo "No School Number returned."
else
	# Create Administrator account
	adminAccount="/Users/administrator"

	if [ -d "$adminAccount" ]; then
		echo "Administrator account exists. Ensuring correct password: EERS@$schoolNumber"
		#dscl . -passwd /Users/administrator "EERS@$schoolNumber"
	else
		echo "Administrator account does not exist. Creating one with password: EERS@$schoolNumber"
		# Create Local Administrator based on Network Segment
		LastID=`dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1`
	    NextID=$((LastID + 1))

		dscl . create /Users/administrator
		dscl . create /Users/administrator RealName "Administrator"
		dscl . create /Users/administrator hint "Location"
		dscl . create /Users/administrator picture "/Library/User Pictures/Animals/Eagle.tif"
		dscl . passwd /Users/administrator "EERS@$schoolNumber"
		dscl . create /Users/administrator UniqueID $NextID
		dscl . create /Users/administrator PrimaryGroupID 80
		dscl . create /Users/administrator UserShell /bin/bash
		dscl . create /Users/administrator NFSHomeDirectory /Users/administrator
		dscl . -append /Groups/admin GroupMembership administrator
		cp -R /System/Library/User\ Template/English.lproj /Users/administrator
		chown -R administrator:staff /Users/administrator
	fi
fi