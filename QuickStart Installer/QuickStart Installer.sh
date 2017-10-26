#!/bin/bash
#
# Script Name: QuickStart Installer.sh
# Version: 1.0
# Last Update: 10/12/2016
# Requirements:
#   - CocoaDialog
#   - Pashua
#
##################################################
jamfBinary="/usr/local/jamf/bin/jamf"
CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
icon="/Library/PCPS/resources/icon-systempreferences.png"

MYDIR="/Library/PCPS/apps/"
source "$MYDIR/pashua.sh"

conf="
  # Window Title
  *.title = QuickStart Installer

  # Introductory text
  txt.type = text
  txt.default = QuickStart can automatically install some of the more popular applications from Self Service for you.[return][return]Check the software you would like installed below:

  # Browsers label
  browserLabel.type = text
  browserLabel.default = Browsers
  browserLabel.rely = -15

  # Browsers
  browserChrome.type = checkbox
  browserChrome.label = Google Chrome
  browserChrome.rely = -20
  browserFirefox.type = checkbox
  browserFirefox.label = Mozilla Firefox

  # Productivity label
  prodLabel.type = text
  prodLabel.default = Productivity
  prodLabel.rely = -15

  # Productivity
  prodOffice.type = checkbox
  prodOffice.label = Microsoft Office 2016
  prodOffice.rely = -20
  prodOffice.default = 1
  prodNotebook.type = checkbox
  prodNotebook.label = SMART NoteBook

  # PCPS label
  pcpsLabel.type = text
  pcpsLabel.default = Polk County Public Schools
  pcpsLabel.rely = -15

  # PCPS
  pcpsVPN.type = checkbox
  pcpsVPN.label = Cisco AnyConnect VPN
  pcpsVPN.rely = -20
  pcpsSAP.type = checkbox
  pcpsSAP.label = SAP GUI

  # Cancel button
  cb.type = cancelbutton
  cb.label = Skip
  cb.tooltip = Skip installing software.

  db.type = defaultbutton
  db.label = Install
  db.tooltip = Start installing selected software.
  "
  
if [ -d '/Volumes/Pashua/Pashua.app' ]; then
  # Looks like the Pashua disk image is mounted. Run from there.
  customLocation='/Volumes/Pashua'
else
  # Search for Pashua in the standard locations
  customLocation=''
fi

pashua_run "$conf" "$customLocation"


if [ $cb = 1 ]; then
  echo "User chose to skip software installation. Exiting..."
  exit 0
else
  # Start software installation
  rm -f /tmp/hpipe
  mkfifo /tmp/hpipe

  $CD progressbar --title "QuickStart Installer" < /tmp/hpipe &

  exec 3<> /tmp/hpipe
  echo -n . >&3

  if [ "$browserChrome" == "1" ]; then
    echo "1% Installing: Google Chrome..." >&3
    $jamfBinary policy -event installChrome
  fi

  if [ "$browserFirefox" == "1" ]; then
    echo "17% Installing: Mozilla Firefox..." >&3
    $jamfBinary policy -event installFirefox
  fi

  if [ "$prodOffice" == "1" ]; then
    echo "34% Installing: Microsoft Office 2016..." >&3
    $jamfBinary policy -event installExcel
    echo "37% Installing: Microsoft Office 2016..." >&3
    $jamfBinary policy -event installLync
    echo "40% Installing: Microsoft Office 2016..." >&3
    $jamfBinary policy -event installOneNote
    echo "43% Installing: Microsoft Office 2016..." >&3
    $jamfBinary policy -event installOutlook
    echo "46% Installing: Microsoft Office 2016..." >&3
    $jamfBinary policy -event installPowerPoint
    echo "49% Installing: Microsoft Office 2016..." >&3
    $jamfBinary policy -event installWord
  fi

  if [ "$prodNotebook" == "1" ]; then
    echo "51% Installing: SMART NoteBook..." >&3
    $jamfBinary policy -event installNotebook
  fi

  if [ "$pcpsVPN" == "1" ]; then
    echo "68% Installing: Cisco AnyConnect VPN..." >&3
    $jamfBinary policy -event installVPN
  fi

  if [ "$pcpsSAP" == "1" ]; then
    echo "85% Installing: SAP GUI..." >&3
    $jamfBinary policy -event installSAP
  fi

  echo "100% Complete! Rebooting..." >&3
  sleep 3
  
  exec 3>&-
  rm -f /tmp/hpipe
fi

exit 0