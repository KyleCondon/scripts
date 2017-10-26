#!/bin/sh
#
#	Script Name: Install - Office 2016.sh
#	Version: 1.0
#	Last Update: 10/12/2016
#	Requirements:
#		- CocoaDialog
#
#   Change Log:
##################################################
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
jamfBinary="/usr/local/jamf/bin/jamf"

if [ -e "${CD}" ]; then
	# Setup CocoaDialog's progressbar
	# create a named pipe
	rm -f /tmp/hpipe
	mkfifo /tmp/hpipe

	# create a background job which takes its input from the named pipe
	$CD progressbar --title "Microsoft Office 2016 Installer" < /tmp/hpipe &

	# associate file descriptor 3 with that pipe and send a character through the pipe
	exec 3<> /tmp/hpipe
	echo -n . >&3

	echo "0% Preparing..." >&3

	sleep 3

	echo "13% Installing: Outlook..." >&3
	$jamfBinary policy -event main-outlook
	sleep 1

	echo "26% Installing: OneNote..." >&3
	$jamfBinary policy -event main-onenote
	sleep 1

	echo "39% Installing: Word..." >&3
	$jamfBinary policy -event main-word
	sleep 1

	echo "52% Installing: Excel..." >&3
	$jamfBinary policy -event main-excel
	sleep 1

	echo "65% Installing: PowerPoint..." >&3
	$jamfBinary policy -event main-powerpoint
	sleep 1

	echo "78% Installing: Skype for Business..." >&3
	$jamfBinary policy -event main-skype
	sleep 1
	
	echo "91% Submitting install information..." >&3
	$jamfBinary recon

	echo "100% Installation complete!S" >&3
	sleep 2

	exec 3>&-

	# wait for all background jobs to exit
	rm -f /tmp/hpipe

else
	$jamfBinary policy -event main-outlook
	sleep 1
	$jamfBinary policy -event main-onenote
	sleep 1
	$jamfBinary policy -event main-word
	sleep 1
	$jamfBinary policy -event main-excel
	sleep 1
	$jamfBinary policy -event main-powerpoint
	sleep 1
	$jamfBinary policy -event main-skype
	sleep1
	
	$jamfBinary recon
fi

exit 0