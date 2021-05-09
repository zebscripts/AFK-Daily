#!/bin/bash
# ##############################################################################
# Script Name   : deploy.sh
# Description   : Used to run afk-daily on phone
# Args          : [bs/nox]
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# Has to be saved with LF line endings!

# Source
source ./lib/print.sh

# ##############################################################################
# Section       : Variables
# ##############################################################################
# Probably you don't need to modify this. Do it if you know what you're doing,
# I won't blame you (unless you blame me).
personalDirectory="storage/emulated/0"
bluestacksDirectory="storage/emulated/0"
noxDirectory="data"
configFile="config.sh"
tempFile=".afkscript.tmp"

# Do not modify
adb=adb
forceFightCampaign=false

# ##############################################################################
# Section       : Functions
# ##############################################################################

# ##############################################################################
# Function Name : checkForUpdate
# Description   : Checks for script update (with git)
# ##############################################################################
checkForUpdate() {
    if command -v git &>/dev/null; then
        printTask "Checking for updates..."
        if git pull &>/dev/null; then
            printSuccess "Checked/Updated!"
        elif git fetch --all &>/dev/null && git reset --hard origin/master; then
            printSuccess "Checked/Updated!"
        else
            printWarn "Couldn't check for updates. Please do it manually from time to time with 'git pull'."
            printWarn "Refer to: https://github.com/zebscripts/AFK-Daily#troubleshooting"
        fi
    fi
}

# ##############################################################################
# Function Name : checkAdb
# Description   : Checks for ADB and installs if not present
# ##############################################################################
checkAdb() {
    printTask "Checking for adb..."
    if [ ! -d "./adb/platform-tools" ]; then    # Check for custom adb directory
        if command -v adb &>/dev/null; then     # Check if ADB is already installed (with Path)
            printSuccess "Found in PATH!"
        else                                    # If not, install it locally for this script
            printWarn "Not found!"
            printTask "Installing adb..."
            mkdir -p adb                        # Create directory
            cd ./adb || exit                    # Change to new directory

            case "$OSTYPE" in                   # Install depending on installed OS
            "msys")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-windows.zip     # Windows
                unzip ./platform-tools-latest-windows.zip                                               # Unzip
                rm ./platform-tools-latest-windows.zip                                                  # Delete .zip
                ;;
            "darwin")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-darwin.zip      # MacOS
                unzip ./platform-tools-latest-darwin.zip                                                # Unzip
                rm ./platform-tools-latest-darwin.zip                                                   # Delete .zip
                ;;
            "linux-gnu")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-linux.zip       # Linux
                unzip ./platform-tools-latest-linux.zip                                                 # Unzip
                rm ./platform-tools-latest-linux.zip                                                    # Delete .zip
                ;;
            *)
                printError "Couldn't find OS."
                printInfo "Please download platform-tools for your respective OS, unzip it into the ./adb folder and"
                printInfo "run this script again."
                printInfo " Windows: https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
                printInfo " MacOS: https://dl.google.com/android/repository/platform-tools-latest-darwin.zip"
                printInfo " Linux: https://dl.google.com/android/repository/platform-tools-latest-linux.zip"
                exit
                ;;
            esac

            cd .. || exit                       # Change directory back
            adb=./adb/platform-tools/adb        # Set adb path
            printSuccess "Installed!"
        fi
    else
        printSuccess "Found locally!"
        adb=./adb/platform-tools/adb
    fi
}

# ##############################################################################
# Function Name : checkConfig
# Description   : Creates a $configFile file if not found
# ##############################################################################
checkConfig() {
    printTask "Searching for $configFile file..."
    if [ -f "$configFile" ]; then
        printSuccess "Found!"
    else
        printWarn "Not found!"
        printTask "Creating new $configFile file..."
        printf '#!/bin/bash
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt="championship"

# Repetitions
maxCampaignFights=5
maxKingsTowerFights=5
totalAmountArenaTries=2+0
totalAmountGuildBossTries=2+0

# Store
buyStoreDust=true
buyStorePoeCoins=true
buyStoreEmblems=false

# --- Actions --- #
# Campaign
doLootAfkChest=true
doChallengeBoss=true
doFastRewards=true
doCollectFriendsAndMercenaries=true

# Dark Forest
doSoloBounties=true
doTeamBounties=true
doArenaOfHeroes=true
doLegendsTournament=true
doKingsTower=true

# Ranhorn
doGuildHunts=true
doTwistedRealmBoss=true
doBuyFromStore=true
doStrengthenCrystal=true
doCompanionPointsSummon=false
# Only works if "Hide Inn Heroes" is enabled under "Settings -> Memory"
doCollectOakPresents=false

# End
doCollectQuestChests=true
doCollectMail=true
doCollectMerchantFreebies=false
' > $configFile
        printSuccess "Created!\n"
        printInfo "Please edit $configFile if necessary and run this script again."
        exit
    fi

    validateConfig                              # Validate config file
}

# ##############################################################################
# Function Name : validateConfig
# Description   : Checks for every necessary variable that needs to be defined in $configFile
# ##############################################################################
validateConfig() {
    source $configFile
    printTask "Validating $configFile..."
    if [[ -z $canOpenSoren || -z \
        $arenaHeroesOpponent || -z \
        $waitForUpdate || -z \
        $endAt || -z \
        $maxCampaignFights || -z \
        $maxKingsTowerFights || -z \
        $totalAmountArenaTries || -z \
        $totalAmountGuildBossTries || -z \
        $buyStoreDust || -z \
        $buyStorePoeCoins || -z \
        $buyStoreEmblems || -z \
        $doLootAfkChest || -z \
        $doChallengeBoss || -z \
        $doFastRewards || -z \
        $doCollectFriendsAndMercenaries || -z \
        $doSoloBounties || -z \
        $doTeamBounties || -z \
        $doArenaOfHeroes || -z \
        $doLegendsTournament || -z \
        $doKingsTower || -z \
        $doGuildHunts || -z \
        $doTwistedRealmBoss || -z \
        $doBuyFromStore || -z \
        $doStrengthenCrystal || -z \
        $doCompanionPointsSummon || -z \
        $doCollectOakPresents || -z \
        $doCollectQuestChests || -z \
        $doCollectMail || -z \
        $doCollectMerchantFreebies ]]; then
        printError "$configFile has missing/wrong entries."
        printInfo "Please either delete $configFile and run the script again to generate a new one,"
        printInfo "or check the following link for help:"
        printInfo "https://github.com/zebscripts/AFK-Daily#configvariables"
        exit
    fi
    printSuccess "Passed!"
}

# ##############################################################################
# Function Name : checkLineEndings
# Description   : Check if afk-daily.sh has correct Line endings (LF)
# Args          : <FILE>
# ##############################################################################
checkLineEndings() {
    printTask "Checking Line endings of file ${cBlue}$1${cNc}..."
    if [[ $(head -1 "$1" | cat -A) =~ \^M ]]; then
        printWarn "Found CLRF!"
        printTask "Converting to LF..."
        dos2unix "$1" 2>/dev/null

        if [[ $(head -1 "$1" | cat -A) =~ \^M ]]; then
            printError "Failed to convert $1 to LF. Please do it yourself."
            exit
        else
            printSuccess "Converted!"
        fi
    else
        printSuccess "Passed!"
    fi
}

# ##############################################################################
# Function Name : restartAdb
# Description   : Restarts ADB server
# ##############################################################################
restartAdb() {
    printTask "Restarting ADB..."
    $adb kill-server
    $adb start-server 1>/dev/null 2>&1
    printSuccess "Restarted!"
}

# ##############################################################################
# Function Name : checkForDevice
# Description   : Check if adb recognizes a device.
# Args          : <PLATFORM>
# ##############################################################################
checkForDevice() {
    if [ "$#" -gt "0" ]; then                   # If parameters are sent
        if [ "$1" = "Nox" ]; then               # Nox
            printTask "Searching for Nox through ADB..."
            $adb connect localhost:62001 1>/dev/null
            if ! $adb get-state 1>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Nox!"
            fi
        elif [ "$1" = "Bluestacks" ]; then      # Bluestacks
            printTask "Searching for Bluestacks through ADB... "
            if ! $adb get-state 1>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Bluestacks!"
            fi
        fi
    else                                        # If parameters aren't sent
        printTask "Searching for device through ADB..."

        if ! $adb get-state 1>/dev/null 2>&1; then                              # Checks if adb finds device
            printError "No device found!"
            printInfo "Please make sure it's connected."
            printTip "If you're trying to use Nox, please run this script with './deploy nox'!"
            exit
        else
            if [[ $($adb devices) =~ emulator ]]; then                          # Bluestacks
                printSuccess "Found Bluestacks!"
                deploy "Bluestacks" "$bluestacksDirectory"
            else                                                                # Personal
                printSuccess "Found Personal Device!"
                deploy "Personal" "$personalDirectory"
            fi
        fi
    fi
}

# ##############################################################################
# Function Name : checkDate
# Description   : Check date to decide whether to beat campaign or not.
# ##############################################################################
checkDate() {
    printTask "Checking last time script was run..."
    if [ -f $tempFile ]; then
        value=$(< $tempFile)                    # Time of last beat campaign
        now=$(date +%s)                         # Current time
        difference=$((now - value))             # Time since last beat campaign

        if [ "$difference" -gt 255600 ]; then   # If been longer than 3 days, set forceFightCampaign=true
            forceFightCampaign=true
        fi
    fi
}

# ##############################################################################
# Function Name : saveDate
# Description   : Overwrite temp file with date if has been greater than 3 days or it doesn't exist
# ##############################################################################
saveDate(){
    if [ $forceFightCampaign = true ] || [ ! -f $tempFile ]; then
        date +%s > $tempFile                    # Write date to file

        if [ "$OSTYPE" = "msys" ]; then attrib +h $tempFile; fi                 # Make file invisible if on windows
    fi
}

# ##############################################################################
# Function Name : deploy
# Description   : Makes a Dir (if it doesn't exist), pushes script into Dir, Executes script in Dir.
# Args          : <PLATFORM> <DIRECTORY>
# ##############################################################################
deploy() {
    if [[ $($adb shell wm size) != *"1080x1920"* ]]; then                       # Check for resolution
        printError "Device does not have the correct resolution! Please use a resolution of 1080x1920."
        exit
    fi

    printf "\n"
    printInfo "Platform: ${cBlue}$1${cNc}"
    printInfo "Script Directory: ${cBlue}$2/scripts/afk-arena${cNc}\n"

    $adb shell mkdir -p "$2"/scripts/afk-arena                                  # Create directories if they don't already exist
    $adb push afk-daily.sh "$2"/scripts/afk-arena 1>/dev/null                   # Push script to device
    $adb push $configFile "$2"/scripts/afk-arena 1>/dev/null                    # Push config to device
    # Run script. Comment line if you don't want to run the script after pushing to device
    $adb shell sh "$2"/scripts/afk-arena/afk-daily.sh "$2" "$forceFightCampaign" && saveDate
}

# ##############################################################################
# Section       : Script Start
# ##############################################################################
clear

checkAdb
#checkForUpdate
checkConfig
checkLineEndings $configFile
checkLineEndings "afk-daily.sh"
checkDate

# Check where to deploy
if [ "$1" ]; then
    # BlueStacks
    if [ "$1" = "bluestacks" ] || [ "$1" = "bs" ] || [ "$1" = "-bluestacks" ] || [ "$1" = "-bs" ]; then
        restartAdb
        checkForDevice "Bluestacks"
        deploy "Bluestacks" "$bluestacksDirectory"

    # Nox
    elif [ "$1" = "nox" ] || [ "$1" = "n" ] || [ "$1" = "-nox" ] || [ "$1" = "-n" ]; then
        restartAdb
        checkForDevice "Nox"
        deploy "Nox" "$noxDirectory"

    elif [ "$1" = "dev" ]; then                 # Interactive Options
        deploy "Personal" "$personalDirectory"
    fi
else                                            # Try to recognize device automatically
    restartAdb
    checkForDevice
fi
