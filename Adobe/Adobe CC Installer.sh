#!/bin/bash
#test
CD_APP="/Library/PCPS/apps/CocoaDialog.app/Contents/MacOS/CocoaDialog"
JAMF="/usr/local/bin/jamf"
Dockutil="/usr/local/bin/dockutil"
MYDIR="/Library/PCPS/apps/"
source "$MYDIR/pashua.sh"

##################
# FUNCTION SETUP #
##################

function cc2015 {
	conf="
	# Window Title
	*.title = Adobe Creative Cloud 2015
	*.floating = 1

	# Select apps
	appList.type = text
	appList.rely = -15
	appList.default = Select the apps to install:

	# APP list
	appFlashPro.type = checkbox
	appFlashPro.relx = 20
	appFlashPro.label = Flash Professional
	premiereText.type = text
	premiereText.default = Premiere Pro:
	premiereText.rely = -15
	appPremiere.type = radiobutton
	appPremiere.relx = 20
	appPremiere.default = None
	appPremiere.option = None
	appPremiere.option = English
	appPremiere.option = French
	appPremiere.option = Spanish

	options.type = text
	options.default = Additional Options
	options.rely = -15
	opUninstall.type = checkbox
	opUninstall.relx = 20
	opUninstall.rely = -15
	opUninstall.default = 1
	opUninstall.label = Uninstall previous verions (if installed)
	opDock.type = checkbox
	opDock.relx = 20
	opDock.default = 1
	opDock.label = Add application icons to Dock for all users
	"
	pashua_run "$conf" "$customLocation"
}

function cc2017 {
	conf="
	# Window Title
	*.title = Adobe Creative Cloud 2017
	*.floating = 1

	# Select apps
	appList.type = text
	appList.rely = -15
	appList.default = Select the apps to install:

	# APP list
	appAfterEffects.type = checkbox
	appAfterEffects.relx = 20
	appAfterEffects.rely = -15
	appAfterEffects.label = After Effects
	appPhotoshop.type = checkbox
	appPhotoshop.relx = 20
	appPhotoshop.rely = -15
	appPhotoshop.label = Photoshop
	premiereText.type = text
	premiereText.default = Premiere Pro:
	premiereText.rely = -15
	appPremiere.type = radiobutton
	appPremiere.relx = 20
	appPremiere.default = None
	appPremiere.option = None
	appPremiere.option = English
	appPremiere.option = French
	appPremiere.option = Spanish

	options.type = text
	options.default = Additional Options
	options.rely = -15
	opUninstall.type = checkbox
	opUninstall.relx = 20
	opUninstall.rely = -15
	opUninstall.default = 1
	opUninstall.label = Uninstall previous verions (if installed)
	opDock.type = checkbox
	opDock.relx = 20
	opDock.default = 1
	opDock.label = Add application icons to Dock for all users
	"
	pashua_run "$conf" "$customLocation"
}

function cc2018 {
	conf="
	# Window Title
	*.title = Adobe Creative Cloud 2018
	*.floating = 1

	# Select apps
	appList.type = text
	appList.rely = -15
	appList.default = Select the apps to install:

	# APP list
	appAcrobatDC.type = checkbox
	appAcrobatDC.relx = 20
	appAcrobatDC.rely = -15
	appAcrobatDC.label = Acrobat DC
	appAfterEffects.type = checkbox
	appAfterEffects.relx = 20
	appAfterEffects.rely = -15
	appAfterEffects.label = After Effects
	appAnimate.type = checkbox
	appAnimate.relx = 20
	appAnimate.rely = -15
	appAnimate.label = Animate
	appAudition.type = checkbox
	appAudition.relx = 20
	appAudition.rely = -15
	appAudition.label = Audition
	appBridge.type = checkbox
	appBridge.relx = 20
	appBridge.rely = -15
	appBridge.label = Bridge
	appDreamweaver.type = checkbox
	appDreamweaver.relx = 20
	appDreamweaver.rely = -15
	appDreamweaver.label = Dreamweaver
	appIllustrator.type = checkbox
	appIllustrator.relx = 20
	appIllustrator.rely = -15
	appIllustrator.label = Illustrator
	appInDesign.type = checkbox
	appInDesign.relx = 20
	appInDesign.rely = -15
	appInDesign.label = In Design
	appInCopy.type = checkbox
	appInCopy.relx = 20
	appInCopy.rely = -15
	appInCopy.label = InCopy
	appPhotoshop.type = checkbox
	appPhotoshop.relx = 20
	appPhotoshop.rely = -15
	appPhotoshop.label = Photoshop
	appPrelude.type = checkbox
	appPrelude.relx = 20
	appPrelude.rely = -15
	appPrelude.label = Prelude
	premiereText.type = text
	premiereText.default = Premiere Pro:
	premiereText.rely = -15
	appPremiere.type = radiobutton
	appPremiere.relx = 20
	appPremiere.default = None
	appPremiere.option = None
	appPremiere.option = English
	appPremiere.option = French
	appPremiere.option = Spanish

	options.type = text
	options.default = Additional Options
	options.rely = -15
	opUninstall.type = checkbox
	opUninstall.relx = 20
	opUninstall.rely = -15
	opUninstall.default = 1
	opUninstall.label = Uninstall previous verions (if installed)
	opDock.type = checkbox
	opDock.relx = 20
	opDock.default = 1
	opDock.label = Add application icons to Dock for all users

	# Cancel button
	cb.type = cancelbutton

	# Install button
	db.type = defaultbutton
	db.label = Install
	"
	pashua_run "$conf" "$customLocation"
}


##################
# BEGIN SCRIPT #
##################

YearSelectionBox=`$CD_APP dropdown \
	--title "Adobe Creative Cloud" \
	--text "Select a version to install:" \
	--icon "installer" \
	--items "Adobe CC 2018" "Adobe CC 2017" "Adobe CC 2015" \
	--button1 "Next" \
	--button2 "Cancel"`

UserSelection=`echo $YearSelectionBox | awk '{print $1}'`
Year=`echo $YearSelectionBox | awk '{print $2}'`



if [[ "$UserSelection" == "1" ]]; then
	if [[ "$Year" == "0" ]]; then
		cc2018

		if [ "$db" == "1" ]; then
			# create a named pipe
			rm -f /tmp/hpipe
			mkfifo /tmp/hpipe

			# create a background job which takes its input from the named pipe
			$CD_APP progressbar --indeterminate --float --title "Adobe Creative Cloud 2018 Installer" --text "Please wait..." < /tmp/hpipe &

			# associate file descriptor 3 with that pipe and send a character through the pipe
			exec 3<> /tmp/hpipe
			echo -n . >&3

			if [[ "$appAcrobatDC" == "1" ]]; then
				echo "Acrobat DC"
				echo "0 Installing: Acrobat DC..." >&3
				sleep 2
			fi

			if [[ "$appAfterEffects" == "1" ]]; then
				echo "After Effects"
				echo "0 Installing: After Effects..." >&3
				sleep 2
			fi

			if [[ "$appAnimate" == "1" ]]; then
				echo "Animate"
				echo "0 Installing: Animate..." >&3
				sleep 2
			fi

			if [[ "$appAudition" == "1" ]]; then
				echo "Audition"
				echo "0 Installing: Audition..." >&3
				sleep 2
			fi

			if [[ "$appBridge" == "1" ]]; then
				echo "Bridge"
				echo "0 Installing: Bridge..." >&3
				sleep 2
			fi

			if [[ "$appDreamweaver" == "1" ]]; then
				echo "Dreamweaver"
				echo "0 Installing: Dreamweaver..." >&3
				sleep 2
			fi

			if [[ "$appIllustrator" == "1" ]]; then
				echo "Illustrator"
				echo "0 Installing: Illustrator..." >&3
				sleep 2
			fi

			if [[ "$appInDesign" == "1" ]]; then
				echo "In Design"
				echo "0 Installing: In Design..." >&3
				sleep 2
			fi

			if [[ "$appInCopy" == "1" ]]; then
				echo "InCopy"
				echo "0 Installing: InCopy..." >&3
				sleep 2
			fi

			if [[ "$appPhotoshop" == "1" ]]; then
				echo "0 Installing: Photoshop..." >&3
				sleep 2
				$JAMF policy -event main-adobe-photoshop-2018
					if [[ "$opDock" == "1" ]]; then
						$Dockutil --add "/Applications/Adobe Photoshop CC 2018/Adobe Photoshop CC 2018.app"
					fi
			fi

			if [[ "$appPrelude" == "1" ]]; then
				echo "Prelude"
				echo "0 Installing: Prelude..." >&3
				sleep 2
			fi
			
			if [[ "$appPremiere" == "None" ]]; then
				echo "None"
			elif [[ "$appPremiere" == "English" ]]; then
				echo "English"
				echo "0 Installing: Premiere Pro (English)..." >&3
				sleep 2
			elif [[ "$appPremiere" == "French" ]]; then
				echo "French"
				echo "0 Installing: Premiere Pro (French)..." >&3
				sleep 2
			elif [[ "$appPremiere" == "Spanish" ]]; then
				echo "Spanish"
				echo "0 Installing: Premiere Pro (Spanish)..." >&3
				sleep 2
			fi

			# now turn off the progress bar by closing file descriptor 3
			exec 3>&-

			# wait for all background jobs to exit
			wait
			rm -f /tmp/hpipe
		fi

	elif [[ "$Year" == "1" ]]; then
		cc2017
		if [[ "$appAfterEffects" == "1" ]]; then
			echo "After Effects"
		fi

		if [[ "$appPhotoshop" == "1" ]]; then
			echo "Photoshop"
		fi

		if [[ "$appPremiere" == "None" ]]; then
			echo "None"
		elif [[ "$appPremiere" == "English" ]]; then
			echo "2017 English"
		elif [[ "$appPremiere" == "French" ]]; then
			echo "2017 French"
		elif [[ "$appPremiere" == "Spanish" ]]; then
			echo "2017 Spanish"
		fi

	elif [[ "$Year" == "2" ]]; then
		cc2015
		if [[ "$appFlashPro" == "1" ]]; then
			echo "install flash pro"
		fi

		if [[ "$appPremiere" == "None" ]]; then 
			echo "premiere None"
		elif [[ "$appPremiere" == "English" ]]; then
			echo "Premiere English"
		elif [[ "$appPremiere" == "French" ]]; then
			echo "Premiere French"
		elif [[ "$appPremiere" == "Spanish" ]]; then
			echo "Premiere Spanish"
		fi
	fi
	
fi


