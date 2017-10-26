#!/bin/bash
#
# Script Name: App License Check.sh
# Version: 1.2
# Last Update: 11/4/2016
# Requirements:
#   - CocoaDialog
#   - DockUtil
#
##################################################

CD="/Library/PCPS/apps/cocoaDialog.app/Contents/MacOS/cocoaDialog"
dockutil="/usr/local/bin/dockutil"
jamfBinary="/usr/local/jamf/bin/jamf"
jssURL="https://jss.polk-fl.net:8443"
apiuser="$4"
apipass="$5"
licenseRecordID="$6"
softwareTitle="$7"
policy="$8"
containingFolder="$9"

echo "${containingFolder}${softwareTitle}.app"

if [ -d "${containingFolder}${softwareTitle}.app" ]; then
    msg=`$CD msgbox --no-newline \
    --icon "notice" \
    --title "License Check" \
    --text "${softwareTitle} Already Installed" \
    --informative-text "Would you like to add it to the Dock?" \
    --button1 "Add to Dock" \
    --button2 "Cancel"`

    if [ "${msg}" == "1" ]; then
        $dockutil --add "${containingFolder}${softwareTitle}.app" --allhomes
    fi
else
    ## Pull the license count and the total licenses in use
    licenseCount=$(curl -H "Accept: application/xml" -sfku "${apiuser}:${apipass}" "${jssURL}/JSSResource/licensedsoftware/id/${licenseRecordID}" | awk -F'<license_count>|</license_count>' '{print $2}')
    usage=$(curl -H "Accept: application/xml" -sfku "${apiuser}:${apipass}" "${jssURL}/JSSResource/licensedsoftware/id/${licenseRecordID}" | xmllint --format - | awk -F'>|<' '/<computers>/,/<\/computers>/{print $3}' | sed '/^$/d')

    for i in $usage; do
        usageCount+=($i)
    done

    echo "License count is: $licenseCount"
    echo "Total use count is: ${#usageCount[@]}"

    if [ "${#usageCount[@]}" -ge "$licenseCount" ]; then
        ## Don't do the installation. Alert user
        echo "No licenses available. Alerting User..."
        msg=`$CD msgbox --no-newline \
        --icon "notice" \
        --title "License Check" \
        --text "Licenses Unavailable" \
        --informative-text "There are no more licenses available for ${softwareTitle}. Please try again later." \
        --button1 "OK"`
        exit 0
    else
        ## Do installation
        echo "Licenses available. Kicking off policy."
        $jamfBinary policy -event $policy
        exit 0
    fi
fi