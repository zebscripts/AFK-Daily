#!/bin/bash
# ##############################################################################
# Script Name   : deploy.sh
# Description   : Used to run afk-daily on phone
# Args          : [-h, --help] [-a, --account [ACCOUNT]] [-c, --check]
#                 [-d, --device [DEVICE]] [-e, --event [EVENT]] [-f, --fight]
#                 [-i, --ini [SUB]] [-n] [-o, --output [OUTPUT_FILE]]
#                 [-p, --port [PORT]] [-r]
#                 [-s <X>,<Y>[,<COLOR_TO_COMPARE>[,<REPEAT>[,<SLEEP>]]]]
#                 [-t, --test] [-v, --verbose [DEBUG]] [-w, --weekly]
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
memuDirectory="storage/emulated/0"
noxDirectory="data"
configFile="config/config.ini"
tempFile="account-info/acc.ini"
device="default"
evt="" # Default dev evt

# Do not modify
script_scr="$0"
script_args="$*"
adb=adb
devMode=false
doCheckGitUpdate=true
forceFightCampaign=false
forceWeekly=false
hexdumpSu=false
ignoreResolution=false
disableNotif=false
testServer=false
debug=0
output=""
totest=""
custom_port=""

# ##############################################################################
# Section       : Functions
# ##############################################################################

# ##############################################################################
# Function Name : checkFolders
# Description   : Check if folders are present in the Repo
# ##############################################################################
checkFolders() {
    printTask "Checking folders..."
    if [ ! -d "account-info" ]; then
        mkdir account-info
    fi
    if [ ! -d "config" ]; then
        mkdir config
    fi
    printSuccess "Done!"
}

# ##############################################################################
# Function Name : checkAdb
# Description   : Checks for ADB and installs if not present
# ##############################################################################
checkAdb() {
    if [ $device = "Nox" ]; then
        printTask "Checking for nox_adb.exe"
        if [ -f "$adb" ]; then
            printSuccess "Found!"
        else
            printSuccess "Not found!"
        fi
        return 0
    fi
    printTask "Checking for adb..."
    if [ ! -d "./adb/platform-tools" ]; then # Check for custom adb directory
        if command -v adb &>/dev/null; then  # Check if ADB is already installed (with Path)
            printSuccess "Found in PATH!"
        else # If not, install it locally for this script
            printWarn "Not found!"
            printTask "Installing adb..."
            echo
            echo
            mkdir -p adb       # Create directory
            cd ./adb || exit 1 # Change to new directory

            case "$OSTYPE" in # Install depending on installed OS
            "msys")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-windows.zip # Windows
                unzip -qq ./platform-tools-latest-windows.zip                                       # Unzip
                rm ./platform-tools-latest-windows.zip                                              # Delete .zip
                ;;
            "darwin")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-darwin.zip # MacOS
                unzip -qq ./platform-tools-latest-darwin.zip                                       # Unzip
                rm ./platform-tools-latest-darwin.zip                                              # Delete .zip
                ;;
            "linux-gnu")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-linux.zip # Linux
                unzip -qq ./platform-tools-latest-linux.zip                                       # Unzip
                rm ./platform-tools-latest-linux.zip                                              # Delete .zip
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

            cd .. || exit 1              # Change directory back
            adb=./adb/platform-tools/adb # Set adb path
            echo
            printSuccess "Installed!"
        fi
    else
        printSuccess "Found locally!"
        adb=./adb/platform-tools/adb
    fi
}

# ##############################################################################
# Function Name : checkDate
# Description   : Check date to decide whether to beat campaign or not.
# ##############################################################################
checkDate() {
    printTask "Checking last time script was run..."
    if [ -f $tempFile ]; then
        source $tempFile
        if [ "$doChallengeBoss" = true ] && [ "$(datediff "$lastCampaign")" -le -3 ]; then
            forceFightCampaign=true
        fi
        if [ "$(datediff "$lastWeekly")" -lt -7 ]; then
            forceWeekly=true
        fi
    else
        if [ "$doChallengeBoss" = true ]; then
            forceFightCampaign=true
        fi
        forceWeekly=true
    fi
    printSuccess "Done!"
}

# ##############################################################################
# Function Name : checkDevice
# Description   : Check if adb recognizes a device.
# Args          : <PLATFORM>
# ##############################################################################
checkDevice() {
    if [ "$#" -gt "0" ]; then            # If parameters are sent
        if [ "$1" = "Bluestacks" ]; then # Bluestacks
            # Use custom port if set
            if [ -n "$custom_port" ]; then
                "$adb" connect localhost:"$custom_port" 1>/dev/null
            fi

            printTask "Searching for Bluestacks through ADB... "
            if ! "$adb" get-state 1>/dev/null 2>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Bluestacks!"
                deploy "Bluestacks" "$bluestacksDirectory"
            fi
        elif [ "$1" = "Memu" ]; then # Memu
            printTask "Searching for Memu through ADB..."
            # Use custom port if set
            if [ -n "$custom_port" ]; then
                "$adb" connect localhost:"$custom_port" 1>/dev/null
            else
                "$adb" connect localhost:21503 1>/dev/null
            fi

            # Check for device
            if ! "$adb" get-state 1>/dev/null 2>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Memu!"
                deploy "Memu" "$memuDirectory"
            fi
        elif [ "$1" = "Nox" ]; then # Nox
            printTask "Searching for Nox through ADB..."
            # Use custom port if set
            if [ -n "$custom_port" ]; then
                "$adb" connect localhost:"$custom_port" 1>/dev/null
            else
                "$adb" connect localhost:62001 1>/dev/null # If it's not working, try with 127.0.0.1 instead of localhost
            fi

            # Check for device
            if ! "$adb" get-state 1>/dev/null 2>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Nox!"
                deploy "Nox" "$noxDirectory"
            fi
        fi
    else # If parameters aren't sent
        printTask "Searching for device through ADB..."
        # Use custom port if set
        if [ -n "$custom_port" ]; then
            "$adb" connect localhost:"$custom_port" 1>/dev/null
        fi

        # Check for device
        if ! "$adb" get-state 1>/dev/null 2>&1; then # Checks if adb finds device
            printError "No device found!"
            printInfo "Please make sure it's connected."
            exit
        else
            if [[ $("$adb" devices) =~ emulator ]]; then # Bluestacks
                printSuccess "Emulator found!"
                deploy "Emulator" "$bluestacksDirectory"
            else # Personal
                printSuccess "Device found!"
                deploy "Personal" "$personalDirectory"
            fi
        fi
    fi
}

# ##############################################################################
# Function Name : checkEOL
# Description   : Check if afk-daily.sh has correct Line endings (LF)
# Args          : <FILE>
# ##############################################################################
checkEOL() {
    if [ -f "$1" ]; then
        printTask "Checking Line endings of file ${cCyan}$1${cNc}..."
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
    fi
}

# ##############################################################################
# Function Name : checkResolution
# Description   : Check device resolution
# ##############################################################################
checkResolution() {
    # Prints info related to debugging the resolution
    printDebugResolution() {
        printInfo "$("$adb" shell wm size)"
        printInfo "$("$adb" shell wm density)"
        # "$adb" shell dumpsys display
        printWarn "In case you're having trouble, join our Discord server and ask in the #need-help channel."
        printWarn "If you're sure your device settings are correct and want to force the script to run regardless, use the -r flag."
        printWarn "The script does NOT work on resolutions other than 1080x1920 (Portrait) or 1920x1080 (Landscape)!"
        exit
    }

    if [[ $("$adb" shell wm size) != *"Physical size: 1080x1920"* ]] && [[ $("$adb" shell wm size) != *"Physical size: 1920x1080"* ]]; then # Check for resolution
        echo
        printError "It seems like your device does not have the correct resolution!"
        printWarn "Please use a resolution of 1080x1920 (Portrait) or 1920x1080 (Landscape)."

        if [ $ignoreResolution = false ]; then
            printDebugResolution
        else
            printWarn "Running script regardless..."
        fi
    elif [[ $("$adb" shell wm size) == *"Override"* ]]; then # Check for Override
        echo
        printError "It seems like your device is overriding the default resolution!"
        printWarn "This may break the script."

        if [ $ignoreResolution = false ]; then
            if printQuestion "Do you want the script to try to fix the resolution for you? (y/n)"; then
                resetResolution
            else
                printDebugResolution
            fi
        else
            printWarn "Running script regardless..."
        fi
    fi
}

# ##############################################################################
# Function Name : resetResolution
# Description   : Reset device resolution and density
# ##############################################################################
resetResolution() {
    printTask "Reseting screen resolution..."
    "$adb" shell wm size reset # Reset resolution
    printSuccess "Done!"
}

# ##############################################################################
# Function Name : checkHexdump
# Description   : Check if device is able to run hexdump command
# ##############################################################################
checkHexdump() {
    printTask "Checking hexdump support..."

    # Check if hexdump is found
    if ! "$adb" shell 'command -v hexdump 1>/dev/null'; then
        echo
        printError "Hexdump not found on device."
        printInfo "If you are runing the script on your personal device, make sure BusyBox is installed."
        printInfo "More info here: https://github.com/zebscripts/AFK-Daily/wiki/Supported-Devices#personal-android-device"
        exit 1
    fi

    # Check if hexdump needs to be run with su
    if "$adb" shell 'hexdump --help 2>&1' | grep -q 'Permission denied'; then
        hexdumpSu=true
    fi

    printSuccess "Done!"
}

# ##############################################################################
# Function Name : checkGitUpdate
# Description   : Checks for script update (with git)
# ##############################################################################
checkGitUpdate() {
    printTask "Checking for updates..."

    # Check if there's a new script version
    if ./lib/update_git.sh; then
        printSuccess "Checked!"
    else
        printSuccess "Update found!"

        # Check if git is installed and there's a .git folder
        if command -v git &>/dev/null && [ -d "./.git" ]; then
            # Fetch latest script version
            git fetch --all &>/dev/null

            # Check if there are local modifications present
            if [ -n "$(git status --porcelain)" ]; then
                # Ask if user wants to overwrite local changes
                if printQuestion "Local changes found! Do you want \
to overwrite them and get the latest script version? Config files will not be overwritten. (y/n)"; then
                    git reset --hard origin/master &>/dev/null
                else
                    printInfo "Alright, not updating. Use -z flag to not check for updates."
                    return 0
                fi
            fi

            # Update script with git
            printTask "Updating..."
            if git pull origin master &>/dev/null; then
                printSuccess "Updated!"
            else
                printError "Failed to update script."
                printInfo "Refer to: https://github.com/zebscripts/AFK-Daily/wiki/Troubleshooting"
                if printQuestion "Do you want to run the script regardless? (y/n)"; then return 0; else exit 1; fi
            fi

            # Force script restart to update correctly
            # shellcheck disable=SC2086
            exec "$script_scr" $script_args
        else
            # git is not installed/available
            printWarn "git is not installed/available."
            printTask "Attempting to auto-update..."

            cd ..
            curl -sLO https://github.com/zebscripts/AFK-Daily/archive/master.zip
            unzip -qqo master.zip
            rm master.zip

            printSuccess "Done!"

            # Force script restart to update correctly
            # shellcheck disable=SC2086
            exec "$script_scr" $script_args
        fi
    fi
}

# ##############################################################################
# Function Name : checkSetupUpdate
# Description   : Checks for setup update (.*afkscript.ini, config*.ini)
# ##############################################################################
checkSetupUpdate() {
    checkSetupUpdate_updated=false
    printTask "Checking for setup updates..."
    # .*afkscript.ini
    for f in .*afkscript.* ./account-info/acc*.ini; do
        if [ -e "$f" ]; then
            printInNewLine "$(./lib/update_setup.sh -a)"
            break
        fi
    done
    # config
    for f in config*.* ./config/config*.ini; do
        if [ -e "$f" ]; then
            checkSetupUpdate_config="$(./lib/update_setup.sh -c)"
            printInNewLine "$checkSetupUpdate_config"
            if [[ $checkSetupUpdate_config =~ "updated" ]]; then
                checkSetupUpdate_updated=true
            fi
            break
        fi
    done
    if [ "$checkSetupUpdate_updated" = false ]; then
        printSuccess "Checked!"
    else
        printSuccess "Updated!"
        printInfo "Please edit ${cCyan}$configFile${cNc} if necessary and run this script again."
        exit
    fi
}

# ##############################################################################
# Function Name : datediff
# Args          : <DATE1> [<DATE2>]
# Description   : Quickly calculate date differences
# Output        : stdout <days>
# ##############################################################################
datediff() {
    if date -v -1d >/dev/null 2>&1; then
        d1=$(date -v "${1:-"$(date +%Y%m%d)"}" +%s)
        d2=$(date -v "${2:-"$(date +%Y%m%d)"}" +%s)
    else
        d1=$(date -d "${1:-"$(date +%Y%m%d)"}" +%s)
        d2=$(date -d "${2:-"$(date +%Y%m%d)"}" +%s)
    fi
    echo $(((d1 - d2) / 86400))
}

# ##############################################################################
# Function Name : deploy
# Description   : Makes a Dir (if it doesn't exist), pushes script into Dir, Executes script in Dir.
# Args          : <PLATFORM> <DIRECTORY>
# ##############################################################################
deploy() {
    checkResolution # Check Resolution
    checkHexdump    # Check if hexdump should be run with su

    echo
    printInfo "Platform: ${cCyan}$1${cNc}"
    printInfo "Script Directory: ${cCyan}$2/scripts/afk-arena${cNc}"
    if [ $disableNotif = true ]; then
        "$adb" shell settings put global heads_up_notifications_enabled 0
        printInfo "Notifications: ${cCyan}OFF${cNc}"
    fi
    printInfo "Latest tested patch: ${cCyan}$testedPatch${cNc}\n"

    "$adb" shell mkdir -p "$2"/scripts/afk-arena                # Create directories if they don't already exist
    "$adb" push afk-daily.sh "$2"/scripts/afk-arena 1>/dev/null # Push script to device
    "$adb" push $configFile "$2"/scripts/afk-arena 1>/dev/null  # Push config to device

    args="-v $debug -i $configFile -l $2"
    if [ $hexdumpSu = true ]; then args="$args -g"; fi
    if [ $forceFightCampaign = true ]; then args="$args -f"; fi
    if [ $forceWeekly = true ]; then args="$args -w"; fi
    if [ $testServer = true ]; then args="$args -t"; fi
    if [ "$device" == "Nox" ]; then args="$args -c"; fi
    if [ -n "$totest" ]; then args="$args -s $totest"; fi
    if [ -n "$evt" ]; then args="$args -e $evt"; fi
    "$adb" shell sh "$2"/scripts/afk-arena/afk-daily.sh "$args" && saveDate

    # Enable notifications in case they got deactivated before
    if [ $disableNotif = true ]; then
        "$adb" shell settings put global heads_up_notifications_enabled 1
        printInfo "Notifications: ${cCyan}ON${cNc}\n"
    fi
}

# ##############################################################################
# Function Name : getLatestPatch
# Description   : Get latest patch script was tested on
# ##############################################################################
getLatestPatch() {
    while IFS= read -r line; do
        if [[ "$line" == *"badge/Patch-"* ]]; then
            testedPatch=${line:90:7}
            break
        fi
    done <"README.md"
}

# ##############################################################################
# Function Name : restartAdb
# Description   : Restarts ADB server
# ##############################################################################
restartAdb() {
    printTask "Restarting ADB..."
    printInNewLine "$($adb kill-server 1>/dev/null 2>&1)"
    printInNewLine "$($adb start-server 1>/dev/null 2>&1)"
    printSuccess "Restarted!"
}

# ##############################################################################
# Function Name : saveDate
# Description   : Overwrite temp file with date if has been greater than 3 days or it doesn't exist
# ##############################################################################
saveDate() {
    if [ $forceFightCampaign = true ] || [ $forceWeekly = true ] || [ ! -f $tempFile ]; then
        if [ $forceFightCampaign = true ] || [ ! -f $tempFile ]; then
            newLastCampaign=$(date +%Y%m%d)
        fi
        if [ $forceWeekly = true ] || [ ! -f $tempFile ]; then
            if date -v -1d >/dev/null 2>&1; then
                newLastWeekly=$(date -v -sat +%Y%m%d)
            else
                newLastWeekly=$(date -dlast-saturday +%Y%m%d)
            fi
        fi

        echo -e "# afk-daily\n\
lastCampaign=${newLastCampaign:-$lastCampaign}\n\
lastWeekly=${newLastWeekly:-$lastWeekly}" >"$tempFile"
    fi
}

# ##############################################################################
# Section       : Script Start
# ##############################################################################

# ##############################################################################
# Function Name : check_all
# ##############################################################################
check_all() {
    checkFolders
    checkAdb
    if [ $doCheckGitUpdate = true ]; then checkGitUpdate; fi
    touch $configFile # Create if not already existing
    checkSetupUpdate
    checkEOL $tempFile
    checkEOL $configFile
    checkEOL "afk-daily.sh"
    checkDate
}

# ##############################################################################
# Function Name : run
# ##############################################################################
run() {
    check_all
    getLatestPatch

    if [ "$devMode" = false ]; then
        restartAdb
    fi

    if [ "$device" == "Bluestacks" ]; then
        checkDevice "Bluestacks"
    elif [ "$device" == "Memu" ]; then
        checkDevice "Memu"
    elif [ "$device" == "Nox" ]; then
        checkDevice "Nox"
    else checkDevice; fi
}

# ##############################################################################
# Function Name : show_help
# ##############################################################################
show_help() {
    echo -e "${cWhite}"
    echo -e "    _     ___   _  __        ___           _   _         "
    echo -e "   /_\   | __| | |/ /  ___  |   \   __ _  (_) | |  _  _  "
    echo -e "  / _ \  | _|  | ' <  |___| | |) | / _\` | | | | | | || | "
    echo -e " /_/ \_\ |_|   |_|\_\       |___/  \__,_| |_| |_|  \_, | "
    echo -e "                                                   |__/  "
    echo -e
    echo -e "USAGE: ${cYellow}deploy.sh${cWhite} ${cCyan}[OPTIONS]${cWhite}"
    echo -e
    echo -e "DESCRIPTION"
    echo -e "   Automate daily activities within the AFK Arena game."
    echo -e "   More info: https://github.com/zebscripts/AFK-Daily"
    echo -e
    echo -e "OPTIONS"
    echo -e "   ${cCyan}-h${cWhite}, ${cCyan}--help${cWhite}"
    echo -e "      Show help"
    echo -e
    echo -e "   ${cCyan}-a${cWhite}, ${cCyan}--account${cWhite} ${cGreen}[ACCOUNT]${cWhite}"
    echo -e "      Specify account: \"acc-${cGreen}[ACCOUNT]${cWhite}.ini\""
    echo -e "      Remark: Please don't use spaces!"
    echo -e
    echo -e "   ${cCyan}-d${cWhite}, ${cCyan}--device${cWhite} ${cGreen}[DEVICE]${cWhite}"
    echo -e "      Specify target device."
    echo -e "      Values for ${cGreen}[DEVICE]${cWhite}: bs (default), nox, memu"
    echo -e
    echo -e "   ${cCyan}-e${cWhite}, ${cCyan}--event${cWhite} ${cGreen}[EVENT]${cWhite}"
    echo -e "      Specify active event."
    echo -e "      Values for ${cGreen}[EVENT]${cWhite}: hoe"
    echo -e
    echo -e "   ${cCyan}-f${cWhite}, ${cCyan}--fight${cWhite}"
    echo -e "      Force campaign battle (ignore 3-day optimisation)."
    echo -e
    echo -e "   ${cCyan}-i${cWhite}, ${cCyan}--ini${cWhite} ${cGreen}[CONFIG]${cWhite}"
    echo -e "      Specify config: \"config-${cGreen}[CONFIG]${cWhite}.ini\""
    echo -e "      Remark: Please don't use spaces!"
    echo -e
    echo -e "   ${cCyan}-n${cWhite}"
    echo -e "      Disable heads-up notifications while script is running."
    echo -e
    echo -e "   ${cCyan}-p${cWhite}, ${cCyan}--port${cWhite}  ${cGreen}[PORT]${cWhite}"
    echo -e "      Specify ADB port."
    echo -e
    echo -e "   ${cCyan}-r${cWhite}"
    echo -e "      Ignore resolution warning. Use this at your own risk."
    echo -e
    echo -e "   ${cCyan}-t${cWhite}, ${cCyan}--test${cWhite}"
    echo -e "      Launch on test server (experimental)."
    echo -e
    echo -e "   ${cCyan}-w${cWhite}, ${cCyan}--weekly${cWhite}"
    echo -e "      Force weekly."
    echo -e
    echo -e "DEV OPTIONS"
    echo -e
    echo -e "   ${cCyan}-b${cWhite}"
    echo -e "      Dev mode: do not restart adb."
    echo -e
    echo -e "   ${cCyan}-c${cWhite}, ${cCyan}--check${cWhite}"
    echo -e "      Check if script is ready to be run."
    echo -e
    echo -e "   ${cCyan}-o${cWhite}, ${cCyan}--output${cWhite} ${cGreen}[OUTPUT_FILE]${cWhite}"
    echo -e "      Write log in ${cGreen}[OUTPUT_FILE]${cWhite}"
    echo -e "      Remark: Folder needs to be created"
    echo -e
    echo -e "   ${cCyan}-s${cWhite} ${cGreen}<X>,<Y>[,<COLOR_TO_COMPARE>[,<REPEAT>[,<SLEEP>]]]${cWhite}"
    echo -e "      Test color of a pixel."
    echo -e
    echo -e "   ${cCyan}-v${cWhite}, ${cCyan}--verbose${cWhite} ${cGreen}[DEBUG]${cWhite}"
    echo -e "      Show DEBUG informations"
    echo -e "         DEBUG  = 0    Show no debug"
    echo -e "         DEBUG >= 1    Show getColor calls > value"
    echo -e "         DEBUG >= 2    Show test calls"
    echo -e "         DEBUG >= 3    Show all core functions calls"
    echo -e "         DEBUG >= 4    Show all functions calls"
    echo -e "         DEBUG >= 9    Show all calls"
    echo -e
    echo -e "   ${cCyan}-z${cWhite}"
    echo -e "      Disable auto update."
    echo -e
    echo -e "EXAMPLES"
    echo -e "   Run script"
    echo -e "      ${cYellow}./deploy.sh${cWhite}"
    echo -e
    echo -e "   Run script with specific emulator (for example Nox)"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-d${cWhite} ${cGreen}nox${cWhite}"
    echo -e
    echo -e "   Run script with specific port (for example 52086)"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-p${cWhite} ${cGreen}52086${cWhite}"
    echo -e
    echo -e "   Run script on test server"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-t${cWhite}"
    echo -e
    echo -e "   Run script forcing fight & weekly"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-fw${cWhite}"
    echo -e
    echo -e "   Run script with custom config.ini file named 'config-Push_Campaign.ini'"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-i${cWhite} ${cGreen}\"Push_Campaign\"${cWhite}"
    echo -e
    echo -e "   Run script for color testing"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-s${cWhite} ${cGreen}800,600${cWhite}"
    echo -e
    echo -e "   Run script with output file and with disabled notifications"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-no${cWhite} ${cGreen}\".history/\$(date +%Y%m%d).log\"${cWhite}"
    echo -e
    echo -e "   Run script on test server with output file and with disabled notifications"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-nta${cWhite} ${cGreen}\"test\"${cWhite} ${cCyan}-i${cWhite} ${cGreen}\"test\"${cWhite} ${cCyan}-o${cWhite} ${cGreen}\".history/\$(date +%Y%m%d).test.log\"${cNc}"
}

for arg in "$@"; do
    shift
    case "$arg" in
    "--help") set -- "$@" "-h" ;;
    "--account") set -- "$@" "-a" ;;
    "--check") set -- "$@" "-c" ;;
    "--device") set -- "$@" "-d" ;;
    "--event") set -- "$@" "-e" ;;
    "--fight") set -- "$@" "-f" ;;
    "--ini") set -- "$@" "-i" ;;
    "--notifications") set -- "$@" "-n" ;;
    "--output") set -- "$@" "-o" ;;
    "--port") set -- "$@" "-p" ;;
    "--resolution") set -- "$@" "-r" ;;
    "--hex") set -- "$@" "-s" ;;
    "--test") set -- "$@" "-t" ;;
    "--verbose") set -- "$@" "-v" ;;
    "--weekly") set -- "$@" "-w" ;;
    *) set -- "$@" "$arg" ;;
    esac
done

while getopts ":a:bcd:e:fhi:no:p:rs:tv:wz" option; do
    case $option in
    a)
        tempFile="account-info/acc-${OPTARG}.ini"
        ;;
    b)
        devMode=true
        ;;
    c)
        check_all
        exit
        ;;
    d)
        if [ "$OPTARG" == "Bluestacks" ] || [ "$OPTARG" == "bluestacks" ] || [ "$OPTARG" == "bs" ]; then
            device="Bluestacks"
        elif [ "$OPTARG" == "Memu" ] || [ "$OPTARG" == "memu" ]; then
            device="Memu"
        elif [ "$OPTARG" == "Nox" ] || [ "$OPTARG" == "nox" ]; then
            device="Nox"
            case "$(uname -s)" in # Check OS
            Darwin | Linux)       # Mac / Linux
                adb="$(ps | grep -i nox_adb.exe | tr -s ' ' | cut -d ' ' -f 9-100 | sed -e 's/^/\//' -e 's/://' -e 's#\\#/#g')"
                ;;
            CYGWIN* | MINGW32* | MSYS* | MINGW*) # Windows
                adb="$(ps -W | grep -i nox_adb.exe | tr -s ' ' | cut -d ' ' -f 9-100 | sed -e 's/^/\//' -e 's/://' -e 's#\\#/#g')"
                ;;
            esac
            if [ -z "$adb" ]; then
                printError "nox_adb.exe not found, please check your Nox settings"
                exit 1
            fi
        fi
        ;;
    e)
        evt="${OPTARG}"
        ;;
    f)
        forceFightCampaign=true
        ;;
    h)
        show_help
        exit 0
        ;;
    i)
        configFile="config/config-${OPTARG}.ini"
        ;;
    n)
        disableNotif=true
        ;;
    o)
        output="${OPTARG}"
        ;;
    p)
        custom_port="${OPTARG}"
        ;;
    r)
        ignoreResolution=true
        ;;
    s)
        totest=${OPTARG}
        ;;
    t)
        testServer=true
        ;;
    v)
        debug=${OPTARG}
        ;;
    w)
        forceWeekly=true
        ;;
    z)
        doCheckGitUpdate=false
        ;;
    :)
        printWarn "Argument required by this option: $OPTARG"
        exit 1
        ;;
    \?)
        printError "$OPTARG : Invalid option"
        exit 1
        ;;
    esac
done

clear
if [ "$output" != "" ]; then
    mkdir -p "$(dirname "$output")"
    touch "$output"
    run 2>&1 | tee -a "$output"
else
    run
fi
