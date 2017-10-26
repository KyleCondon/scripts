#!/bin/sh
#
#	Script Name: Active Directory unbinder.sh
#	Version: 1.0
#	Last Update: 10/12/2016
#	Requirements:
#		- CocoaDialog
#		- Pashua
#
##################################################
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jamfBinary="/usr/local/jamf/bin/jamf"
aduser="$4"
adpass="$5"


# WELCOME DIALOG
WELCOME=`$CD ok-msgbox --title "Active Directory Unbinder" --text "Welcome to the IST AD Unbinder" \
--informative-text "This will remove the Active Directory association from this computer." \
--icon computer --no-newline --float`

if [ "$WELCOME" == "1" ]; then
	dsconfigad -force -remove -u ${aduser} -p ${adpass}
	$jamfBinary recon
else
	echo "User canceled unbinding. Exiting..."
	exit 0
fi

exit 0