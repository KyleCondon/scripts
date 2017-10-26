#!/bin/bash
#
#	Script Name: uninstall - Office 2011.sh
#	Version: 1.0
#	Last Update: 10/12/2016
#	Requirements:
#		- CDockUtil
#
##################################################
dockutil="/usr/local/bin/dockutil"

$dockutil --remove 'Microsoft Communicator' --allhomes --no-restart
$dockutil --remove 'Microsoft Lync' --allhomes --no-restart
$dockutil --remove 'Microsoft Messenger' --allhomes --no-restart
$dockutil --remove 'Microsoft Document Connection' --allhomes --no-restart
$dockutil --remove 'Microsoft Excel' --allhomes --no-restart
$dockutil --remove 'Microsoft Outlook' --allhomes --no-restart
$dockutil --remove 'Microsoft PowerPoint' --allhomes --no-restart
$dockutil --remove 'Microsoft Word' --allhomes --no-restart
$dockutil --remove 'Remote Desktop Connection' --allhomes --no-restart
$dockutil --remove 'Microsoft Entourage' --allhomes --no-restart
$dockutil --remove 'Microsoft AutoUpdate' --allhomes --no-restart
$dockutil --remove 'Microsoft Error Reporting' --allhomes

	osascript -e 'tell application "Microsoft Database Daemon" to quit'
	osascript -e 'tell application "Microsoft AU Daemon" to quit'
	osascript -e 'tell application "Office365Service" to quit'
	rm -R '/Applications/Microsoft Communicator.app/'
	rm -R '/Applications/Microsoft Lync.app/'
	rm -R '/Applications/Microsoft Messenger.app/'
	rm -R '/Applications/Microsoft Office 2011/'
	rm -R '/Applications/Remote Desktop Connection.app/'
	rm -R '/Library/Application Support/Microsoft/'
	rm -R /Library/Automator/*Excel*
	rm -R /Library/Automator/*Office*
	rm -R /Library/Automator/*Outlook*
	rm -R /Library/Automator/*PowerPoint*
	rm -R /Library/Automator/*Word*
	rm -R /Library/Automator/*Workbook*
	rm -R '/Library/Automator/Get Parent Presentations of Slides.action'
	rm -R '/Library/Automator/Set Document Settings.action'
	rm -R /Library/Fonts/Microsoft/
	mv '/Library/Fonts Disabled/Arial Bold Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Arial Bold.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Arial Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Arial.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Brush Script.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman Bold Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman Bold.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Times New Roman.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana Bold Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana Bold.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana Italic.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Verdana.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Wingdings 2.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Wingdings 3.ttf' /Library/Fonts
	mv '/Library/Fonts Disabled/Wingdings.ttf' /Library/Fonts
	rm -R /Library/Internet\ Plug-Ins/SharePoint*
	rm -R /Library/LaunchDaemons/com.microsoft.*
	rm -R /Library/Preferences/com.microsoft.*
	rm -R /Library/PrivilegedHelperTools/com.microsoft.*
	OFFICERECEIPTS=$(pkgutil --pkgs=com.microsoft.office.*)
	for ARECEIPT in $OFFICERECEIPTS
	do
		pkgutil --forget $ARECEIPT
	done
exit 0