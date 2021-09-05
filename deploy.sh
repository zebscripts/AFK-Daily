#!/bin/bash
# ##############################################################################
# Script Name   : deploy.sh
# Description   : Used to run afk-daily on phone
# Args          : [-h, --help] [-a, --account [ACCOUNT]] [-c, --check]
#                 [-d, --device [DEVICE]] [-e, --event [EVENT]] [-f, --fight]
#                 [-i, --ini [SUB]] [-n] [-o, --output [OUTPUT_FILE]] [-r]
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
adb=adb
forceFightCampaign=false
forceWeekly=false
ignoreResolution=false
disableNotif=false
testServer=false
debug=0
output=""
totest=""

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
            mkdir -p adb       # Create directory
            cd ./adb || exit 1 # Change to new directory

            case "$OSTYPE" in # Install depending on installed OS
            "msys")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-windows.zip # Windows
                unzip ./platform-tools-latest-windows.zip                                           # Unzip
                rm ./platform-tools-latest-windows.zip                                              # Delete .zip
                ;;
            "darwin")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-darwin.zip # MacOS
                unzip ./platform-tools-latest-darwin.zip                                           # Unzip
                rm ./platform-tools-latest-darwin.zip                                              # Delete .zip
                ;;
            "linux-gnu")
                curl -LO https://dl.google.com/android/repository/platform-tools-latest-linux.zip # Linux
                unzip ./platform-tools-latest-linux.zip                                           # Unzip
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
        printf '# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #

# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt="championship"
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=5
maxKingsTowerFights=5
totalAmountArenaTries=2+0
totalAmountTournamentTries=0
totalAmountGuildBossTries=2+0
totalAmountTwistedRealmBossTries=1

# Store
buyStoreDust=true
buyStorePoeCoins=true
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedGoldOffer=false
buyStoreLimitedDiamOffer=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

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
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=true

# End
doCollectQuestChests=true
doCollectMail=true
doCollectMerchantFreebies=false
' >$configFile
        printSuccess "Created!\n"
        printInfo "Please edit $configFile if necessary and run this script again."
        exit
    fi

    validateConfig # Validate config file
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
            printTask "Searching for Bluestacks through ADB... "
            if ! "$adb" get-state 1>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Bluestacks!"
            fi
        elif [ "$1" = "Memu" ]; then # Memu
            printTask "Searching for Memu through ADB..."
            "$adb" connect localhost:21503 1>/dev/null
            if ! "$adb" get-state 1>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Memu!"
            fi
        elif [ "$1" = "Nox" ]; then # Nox
            printTask "Searching for Nox through ADB..."
            "$adb" connect localhost:62001 1>/dev/null
            if ! "$adb" get-state 1>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Nox!"
            fi
        fi
    else # If parameters aren't sent
        printTask "Searching for device through ADB..."

        if ! "$adb" get-state 1>/dev/null 2>&1; then # Checks if adb finds device
            printError "No device found!"
            printInfo "Please make sure it's connected."
            exit
        else
            if [[ $("$adb" devices) =~ emulator ]]; then # Bluestacks
                printSuccess "Found Bluestacks!"
                deploy "Bluestacks" "$bluestacksDirectory"
            else # Personal
                printSuccess "Found Personal Device!"
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
# Function Name : checkGitUpdate
# Description   : Checks for script update (with git)
# ##############################################################################
checkGitUpdate() {
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
    else
        printTask "Checking for updates..."
        if ./lib/update_git.sh; then
            printSuccess "Checked/Updated!"
        else
            printWarn "Update found! Please download the last version on github."
            printWarn "Link: https://github.com/zebscripts/AFK-Daily"
        fi
    fi
}

# ##############################################################################
# Function Name : checkSetupUpdate
# Description   : Checks for setup update (.*afkscript.ini, config*.ini)
# ##############################################################################
checkSetupUpdate() {
    printTask "Checking for setup updates..."
    # .*afkscript.ini
    for f in .*afkscript.*  ./account-info/acc*.ini; do
        if [ -e "$f" ]; then
            printInNewLine "$(./lib/update_setup.sh -a)"
            break
        fi
    done
    # config
    for f in config*.* ./config/config*.ini; do
        if [ -e "$f" ]; then
            printInNewLine "$(./lib/update_setup.sh -c)"
            break
        fi
    done
    printSuccess "Checked/Updated!"
}

# ##############################################################################
# Function Name : datediff
# Args          : <DATE1> [<DATE2>]
# Description   : Quickly calculate date differences
# Output        : stdout <days>
# ##############################################################################
datediff() {
    case "$(uname -s)" in # Check OS
    Darwin | Linux)       # Mac / Linux
        d1=$(date -v "${1:-"$(date +%Y%m%d)"}" +%s)
        d2=$(date -v "${2:-"$(date +%Y%m%d)"}" +%s)
        ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) # Windows
        d1=$(date -d "${1:-"$(date +%Y%m%d)"}" +%s)
        d2=$(date -d "${2:-"$(date +%Y%m%d)"}" +%s)
        ;;
    esac
    echo $(((d1 - d2) / 86400))
}

# ##############################################################################
# Function Name : deploy
# Description   : Makes a Dir (if it doesn't exist), pushes script into Dir, Executes script in Dir.
# Args          : <PLATFORM> <DIRECTORY>
# ##############################################################################
deploy() {
    if [[ $("$adb" shell wm size) != *"1080x1920"* ]] && [[ $("$adb" shell wm size) != *"1920x1080"* ]]; then # Check for resolution
        echo
        printWarn "It seems like your device does not have the correct resolution! Please use a resolution of 1080x1920."
        if [ $ignoreResolution = false ]; then
            printInfo "$(adb shell wm size)"
            printInfo "$(adb shell wm density)"
            # "$adb" shell dumpsys display
            printWarn "Please let us know by opening an issue with a screenshot of this terminal output."
            printWarn "If you're sure your device settings are correct and want to force the script to run regardless, use the -r flag."
            printWarn "The script does NOT work on resolutions other than 1080x1920!"
            exit
        else
            printWarn "Running script regardless..."
        fi
    fi

    printf "\n"
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

    args="-d $debug -i $configFile -l $2"
    if [ $forceFightCampaign = true ]; then args="$args -f"; fi
    if [ $forceWeekly = true ]; then args="$args -w"; fi
    if [ $testServer = true ]; then args="$args -t"; fi
    if [ -n "$totest" ]; then args="$args -s $totest"; fi
    if [ -n "$evt" ]; then args="$args -e $evt"; fi
    "$adb" shell sh "$2"/scripts/afk-arena/afk-daily.sh "$args" && saveDate

    if [ $disableNotif = true ]; then
        echo
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
            case "$(uname -s)" in # Check OS
            Darwin | Linux)       # Mac / Linux
                newLastWeekly=$(date -v -sat +%Y%m%d)
                ;;
            CYGWIN* | MINGW32* | MSYS* | MINGW*) # Windows
                newLastWeekly=$(date -dlast-saturday +%Y%m%d)
                ;;
            esac
        fi

        echo -e "# afk-daily\n\
lastCampaign=${newLastCampaign:-$lastCampaign}\n\
lastWeekly=${newLastWeekly:-$lastWeekly}" >"$tempFile"
    fi
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
        $totalAmountTournamentTries || -z \
        $totalAmountGuildBossTries || -z \
        $totalAmountTwistedRealmBossTries || -z \
        $buyStoreDust || -z \
        $buyStorePoeCoins || -z \
        $buyStorePrimordialEmblem || -z \
        $buyStoreAmplifyingEmblem || -z \
        $buyStoreSoulstone || -z \
        $buyStoreLimitedGoldOffer || -z \
        $buyStoreLimitedDiamOffer || -z \
        $buyWeeklyGuild || -z \
        $buyWeeklyLabyrinth || -z \
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
        $guildBattleType || -z \
        $doTwistedRealmBoss || -z \
        $doBuyFromStore || -z \
        $doStrengthenCrystal || -z \
        $allowCrystalLevelUp || -z \
        $doTempleOfAscension || -z \
        $doCompanionPointsSummon || -z \
        $doCollectOakPresents || -z \
        $doCollectQuestChests || -z \
        $doCollectMail || -z \
        $doCollectMerchantFreebies ]]; then
        printError "$configFile has missing/wrong entries."
        echo
        printInfo "Please either delete $configFile and run the script again to generate a new one,"
        printInfo "or run ./lib/update_setup.sh -c"
        printInfo "or check the following link for help:"
        printInfo "https://github.com/zebscripts/AFK-Daily#configvariables"
        exit
    fi
    printSuccess "Passed!"
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
    checkGitUpdate
    checkSetupUpdate
    checkConfig
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

    if [ "$device" == "Bluestacks" ]; then
        restartAdb
        checkDevice "Bluestacks"
        deploy "Bluestacks" "$bluestacksDirectory"
    elif [ "$device" == "Memu" ]; then
        restartAdb
        checkDevice "Memu"
        deploy "Memu" "$memuDirectory"
    elif [ "$device" == "Nox" ]; then
        restartAdb
        checkDevice "Nox"
        deploy "Nox" "$noxDirectory"
    elif [ "$device" == "dev" ]; then
        checkDevice
    else
        restartAdb
        checkDevice
    fi
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
    echo -e "      Values for ${cGreen}[DEVICE]${cWhite}: bs (default), dev, nox, memu"
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
    echo -e "EXAMPLES"
    echo -e "   Run script"
    echo -e "      ${cYellow}./deploy.sh${cWhite}"
    echo -e
    echo -e "   Run script with specific emulator (for example Nox)"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-d${cWhite} ${cGreen}nox${cWhite}"
    echo -e
    echo -e "   Run script on test server"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-t${cWhite}"
    echo -e
    echo -e "   Run script forcing fight & weekly"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-fw${cWhite}"
    echo -e
    echo -e "   Run script for color testing"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-s${cWhite} ${cGreen}800,600${cWhite}"
    echo -e
    echo -e "   Run script with output file and with disabled notifications"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-n${cWhite} ${cCyan}-o${cWhite} ${cGreen}\".history/\$(date +%Y%m%d).log\"${cWhite}"
    echo -e
    echo -e "   Run script on test server with output file and with disabled notifications"
    echo -e "      ${cYellow}./deploy.sh${cWhite} ${cCyan}-n${cWhite} ${cCyan}-t${cWhite} ${cCyan}-a${cWhite} ${cGreen}\"test\"${cWhite} ${cCyan}-i${cWhite} ${cGreen}\"test\"${cWhite} ${cCyan}-o${cWhite} ${cGreen}\".history/\$(date +%Y%m%d).test.log\"${cNc}"
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
    "--resolution") set -- "$@" "-r" ;;
    "--hex") set -- "$@" "-s" ;;
    "--test") set -- "$@" "-t" ;;
    "--verbose") set -- "$@" "-v" ;;
    "--weekly") set -- "$@" "-w" ;;
    *) set -- "$@" "$arg" ;;
    esac
done

while getopts ":a:cd:e:fhi:no:rs:tv:w" option; do
    case $option in
    a)
        tempFile="account-info/acc-${OPTARG}.ini"
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
            adb="$(ps -W | grep -i nox_adb.exe | tr -s ' ' | cut -d ' ' -f 9-100 | sed -e 's/^/\//' -e 's/://' -e 's#\\#/#g')"
            if [ -z "$adb" ]; then
                printError "nox_adb.exe not found, please check your Nox settings"
                exit 1
            fi
        elif [ "$OPTARG" == "dev" ]; then
            device="dev"
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
    touch "$output"
    run 2>&1 | tee -a "$output"
else
    run
fi
