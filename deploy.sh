#!/bin/bash
# ##############################################################################
# Script Name   : deploy.sh
# Description   : Used to run afk-daily on phone
# Args          : [-h] [-d <DEVICE>] [-a <ACCOUNT>] [-f] [-t] [-w]
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
configFile="config.ini"
tempFile=".afkscript.ini"
device="default"

# Do not modify
adb=adb
forceFightCampaign=false
forceWeekly=false
ignoreResolution=false
testServer=false
debug=0
output=""
totest=""

# ##############################################################################
# Section       : Functions
# ##############################################################################

# ##############################################################################
# Function Name : checkAdb
# Description   : Checks for ADB and installs if not present
# ##############################################################################
checkAdb() {
    printTask "Checking for adb..."
    if [ ! -d "./adb/platform-tools" ]; then # Check for custom adb directory
        if command -v adb &>/dev/null; then  # Check if ADB is already installed (with Path)
            printSuccess "Found in PATH!"
        else # If not, install it locally for this script
            printWarn "Not found!"
            printTask "Installing adb..."
            mkdir -p adb     # Create directory
            cd ./adb || exit # Change to new directory

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

            cd .. || exit                # Change directory back
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
doCollectOakPresents=false

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
    if [ "$#" -gt "0" ]; then     # If parameters are sent
        if [ "$1" = "Nox" ]; then # Nox
            printTask "Searching for Nox through ADB..."
            $adb connect localhost:62001 1>/dev/null
            if ! $adb get-state 1>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Nox!"
            fi
        elif [ "$1" = "Bluestacks" ]; then # Bluestacks
            printTask "Searching for Bluestacks through ADB... "
            if ! $adb get-state 1>/dev/null; then
                printError "Not found!"
                exit
            else
                printSuccess "Found Bluestacks!"
            fi
        fi
    else # If parameters aren't sent
        printTask "Searching for device through ADB..."

        if ! $adb get-state 1>/dev/null 2>&1; then # Checks if adb finds device
            printError "No device found!"
            printInfo "Please make sure it's connected."
            exit
        else
            if [[ $($adb devices) =~ emulator ]]; then # Bluestacks
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
    fi
}

# ##############################################################################
# Function Name : checkSetupUpdate
# Description   : Checks for setup update (.*afkscript.ini, config*.ini)
# ##############################################################################
checkSetupUpdate() {
    printTask "Checking for setup updates..."
    for f in .*afkscript.*; do
        if [ -e "$f" ]; then
            printInNewLine "$(./update_setup.sh -a)"
            break
        fi
    done
    for f in config*.*; do
        if [ -e "$f" ]; then
            printInNewLine "$(./update_setup.sh -c)"
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
    # TODO: Check why this does not always work
    if [[ $($adb shell wm size) = "*1080x1920*" ]] || [[ $($adb shell wm size) = "*1920x1080*" ]]; then # Check for resolution
        printWarn "Device does not have the correct resolution! Please use a resolution of 1080x1920."
        printWarn "If your settings are fine, please open an issue with screen capture or it and a copy of the log."
        $adb shell wm size
        $adb shell wm density
        $adb shell dumpsys display
        if [ $ignoreResolution = false ]; then
            printWarn "The script may not work properly. If you want to continue please add -r option."
            exit
        fi
    fi

    printf "\n"
    printInfo "Platform: ${cCyan}$1${cNc}"
    printInfo "Script Directory: ${cCyan}$2/scripts/afk-arena${cNc}"
    printInfo "Latest tested patch: ${cCyan}$testedPatch${cNc}\n"

    $adb shell mkdir -p "$2"/scripts/afk-arena                # Create directories if they don't already exist
    $adb push afk-daily.sh "$2"/scripts/afk-arena 1>/dev/null # Push script to device
    $adb push $configFile "$2"/scripts/afk-arena 1>/dev/null  # Push config to device
    # Run script. Comment line if you don't want to run the script after pushing to device
    args="-d $debug -i $configFile -l $2"
    if [ $forceFightCampaign = true ]; then args="$args -f"; fi
    if [ $forceWeekly = true ]; then args="$args -w"; fi
    if [ $testServer = true ]; then args="$args -t"; fi
    if [ -n "$totest" ]; then args="$args -s $totest"; fi
    $adb shell sh "$2"/scripts/afk-arena/afk-daily.sh "$args" && saveDate
}

# ##############################################################################
# Function Name : getLatestPatch
# Description   : Get latest patch script was tested on
# ##############################################################################
getLatestPatch() {
    while IFS= read -r line; do
        if [[ "$line" == *"badge/Patch-"* ]]; then
            testedPatch=${line:79:7}
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

        if [ "$OSTYPE" = "msys" ]; then attrib +h $tempFile; fi # Make file invisible if on windows
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
        printInfo "Please either delete $configFile and run the script again to generate a new one,"
        printInfo "or run ./update_setup.sh -c"
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
    checkAdb
    # TODO: Uncomment this when releasing
    # checkGitUpdate
    checkSetupUpdate
    checkConfig
    checkEOL $configFile
    checkEOL "afk-daily.sh"
}

# ##############################################################################
# Function Name : run
# ##############################################################################
run() {
    check_all

    checkDate
    getLatestPatch

    if [ "$device" == "Bluestacks" ]; then
        restartAdb
        checkDevice "Bluestacks"
        deploy "Bluestacks" "$bluestacksDirectory"
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
    echo "USAGE: deploy.sh [OPTIONS]"
    echo
    echo "DESCRIPTION"
    echo "   Automate daily activities within the AFK Arena game."
    echo "   More info: https://github.com/zebscripts/AFK-Daily"
    echo
    echo "OPTIONS"
    echo "   -h, --help"
    echo "      Show help"
    echo
    echo "   -a, --account [ACCOUNT]"
    echo "      Use .afkscript.ini with a tag (multiple accounts)"
    echo "      Remark: Please don't use spaces!"
    echo "      Example: -a account1"
    echo
    echo "   -c, --check"
    echo "      Check if script is ready to be run"
    echo
    echo "   -d, --device [DEVICE]"
    echo "      Specify target device"
    echo "      Values for [DEVICE]: bs, dev"
    echo
    echo "   -f, --fight"
    echo "      Force campaign battle (ignore 3 day optimisation)"
    echo
    echo "   -i, --ini [SUB]"
    echo "      Specify config: \"config-[SUB].ini\""
    echo
    echo "   -o, --output [OUTPUT_FILE]"
    echo "      Write log in OUTPUT_FILE"
    echo
    echo "   -r"
    echo "      Ignore resolution warning. Use this at your own risks."
    echo
    echo "   -s <X>,<Y>[,<COLOR_TO_COMPARE>[,<REPEAT>[,<SLEEP>]]]"
    echo "      Test color of a pixel"
    echo
    echo "   -t, --test"
    echo "      Launch on test server (experimental)"
    echo
    echo "   -v, --verbose [DEBUG]"
    echo "      Show DEBUG informations"
    echo "         DEBUG  = 0    Show no debug"
    echo "         DEBUG >= 1    Show getColor calls > value"
    echo "         DEBUG >= 2    Show test calls"
    echo "         DEBUG >= 3    Show all core functions calls"
    echo "         DEBUG >= 4    Show all functions calls"
    echo "         DEBUG >= 9    Show all calls"
    echo
    echo "   -w, --weekly"
    echo "      Force weekly"
    echo
    echo "EXAMPLES"
    echo "   Run script for Bluestacks (default)"
    echo "      ./deploy.sh -d bs"
    echo
    echo "   Run script on test server"
    echo "      ./deploy.sh -t"
    echo
    echo "   Run script forcing fight & weekly"
    echo "      ./deploy.sh -fw"
    echo
    echo "   Run script for color testing"
    echo "      ./deploy.sh -s 800,600"
    echo
    echo "   Run script with output file (folder need to be created)"
    echo "      ./deploy.sh -o \".history/\$(date +%Y%m%d).log\""
    echo
    echo "   Run script on test server with output file (folder need to be created)"
    echo "      ./deploy.sh -t -a \"test\" -i \"test\" -o \".history/\$(date +%Y%m%d).test.log\""
}

for arg in "$@"; do
    shift
    case "$arg" in
    "--account") set -- "$@" "-a" ;;
    "--check") set -- "$@" "-c" ;;
    "--device") set -- "$@" "-d" ;;
    "--fight") set -- "$@" "-f" ;;
    "--help") set -- "$@" "-h" ;;
    "--ini") set -- "$@" "-i" ;;
    "--output") set -- "$@" "-o" ;;
    "--test") set -- "$@" "-t" ;;
    "--verbose") set -- "$@" "-v" ;;
    "--weekly") set -- "$@" "-w" ;;
    *) set -- "$@" "$arg" ;;
    esac
done

while getopts ":a:cd:fhi:o:rs:tv:w" option; do
    # TODO: Add an -s flag for testing hex value of a coordinate.
    # TODO: For example ./deploy.sh -s 320 400 would test the color for 3 times with 0.5 seconds in between each test and give the output
    # TODO: This is nice because I'm sick of scrolling the whole script just to run one test function
    # TODO: Now that I think about it, this will probably be meh to implement with the current way stuff works. I think the best way to fix
    # TODO: this is by adding a optargs inside afk-daily.sh if possible, of course adding all the already existing parameters the script
    # TODO: accepts. That would be dope! I wonder if .sh supports optarg(s) though...
    case $option in
    a)
        tempFile=".afkscript-${OPTARG}.ini"
        ;;
    c)
        check_all
        exit
        ;;
    d)
        if [ "$OPTARG" == "bluestacks" ] || [ "$OPTARG" == "bs" ]; then
            device="Bluestacks"
        elif [ "$OPTARG" == "dev" ]; then
            device="dev"
        fi
        ;;
    f)
        forceFightCampaign=true
        ;;
    h)
        show_help
        exit 0
        ;;
    i)
        configFile="config-${OPTARG}.ini"
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
