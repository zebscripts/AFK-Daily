#!/system/bin/sh
# ##############################################################################
# Script Name   : afk-daily.sh
# Description   : Script automating daily
# Args          : [-c] [-e EVENT] [-f] [-i INI] [-l LOCATION]
#                 [-s TOTEST] [-t] [-v DEBUG] [-w]
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# ##############################################################################
# Section       : Variables
# ##############################################################################
# Probably you don't need to modify this. Do it if you know what you're doing, I won't blame you (unless you blame me).
DEVICEWIDTH=1080
DEBUG=0
# DEBUG  = 0    Show no debug
# DEBUG >= 1    Show getColor calls > $HEX value
# DEBUG >= 2    Show test calls
# DEBUG >= 3    Show all core functions calls
# DEBUG >= 4    Show all functions calls
# DEBUG >= 9    Show tap calls
DEFAULT_DELTA=3 # Default delta for colors
DEFAULT_SLEEP=2 # equivalent to wait (default 2)
eventHoe=false  # Set to `true` if "Heroes of Esperia" event is live
totalAmountOakRewards=3

# Do not modify
activeTab="Start"
activeEvents=""
currentPos="default"
dayofweek=$(TZ=UTC date +%u)
forceFightCampaign=false
forceWeekly=false
hasEnded=false
HEX=00000000
INILOCATION="/storage/emulated/0/scripts/afk-arena/"
INIFILE="config.ini"
oakRes=0
screenshotRequired=true
testServer=false
SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.dump"
withColors=true

# Colors
cNc="\033[0m"        # Text Reset
cRed="\033[0;91m"    # [ERROR]
cGreen="\033[0;92m"  # [OK]
cYellow="\033[0;93m" # [WARN]
cBlue="\033[0;94m"   # Values
cPurple="\033[0;95m" # [DEBUG]
cCyan="\033[0;96m"   # [INFO]

while getopts "ce:fi:l:s:tv:w" opt; do
    case $opt in
    c)
        withColors=false
        ;;
    e)
        buIFS=$IFS
        # Explication: https://stackoverflow.com/a/7718539/7295428
        IFS=','
        for i in $OPTARG; do
            case "$i" in
            "hoe") eventHoe=true;;
            esac
        done
        IFS=$buIFS
        ;;
    f)
        forceFightCampaign=true
        ;;
    i)
        INIFILE="${OPTARG#config/}"
        ;;
    l)
        SCREENSHOTLOCATION="/$OPTARG/scripts/afk-arena/screen.dump"
        INILOCATION="/$OPTARG/scripts/afk-arena/"
        ;;
    s)
        totest=$OPTARG
        ;;
    t)
        testServer=true
        ;;
    v)
        DEBUG=$OPTARG
        ;;
    w)
        forceWeekly=true
        ;;
    \?)
        echo "$OPTARG : Invalid option"
        exit 1
        ;;
    esac
done

. "$INILOCATION$INIFILE"
doLootAfkChest2="$doLootAfkChest"

# ##############################################################################
# Section       : Core Functions
# Description   : It's like a library of usefull functions
# ##############################################################################

# ##############################################################################
# Function Name : checkToDo
# Description   : Check if argument is ToDo
# Args          : <TODO>: name of the variable containing the boolean
# Output        : return 0/1
# ##############################################################################
checkToDo() {
    if [ "$(eval echo \$"$1")" = false ]; then
        return 1
    fi
    if [ "$1" = "$currentPos" ]; then
        tries=$((tries + 1))
        printInColor "DEBUG" "checkToDo > $currentPos [$tries]"
    else
        eval "$currentPos=false"
        currentPos="$1"
        tries=0
    fi
    if [ $tries -lt 3 ]; then
        return 0
    else
        eval "$1=false"
        return 1
    fi
}

# ##############################################################################
# Function Name : closeApp
# Descripton    : Closes AFK Arena
# ##############################################################################
closeApp() {
    if [ "$testServer" = true ]; then
        am force-stop com.lilithgames.hgame.gp.id >/dev/null 2>/dev/null
    else
        am force-stop com.lilithgame.hgame.gp >/dev/null 2>/dev/null
    fi
}

# ##############################################################################
# Function Name : disableOrientation
# Descripton    : Disables automatic orientation
# ##############################################################################
disableOrientation() {
    content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
}

# ##############################################################################
# Function Name : getColor
# Descripton    : Sets $HEX, <-f> to force the screenshot
# Args          : [<-f>] <X> <Y>
# ##############################################################################
getColor() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "getColor ${cPurple}$*${cNc}" >&2; fi
    for arg in "$@"; do
        shift
        case "$arg" in
        -f) screenshotRequired=true ;;
        *) set -- "$@" "$arg" ;;
        esac
    done
    takeScreenshot
    readHEX "$1" "$2"
    if [ "$DEBUG" -ge 1 ]; then printInColor "DEBUG" "getColor ${cPurple}$*${cNc} > HEX: ${cCyan}$HEX${cNc}" >&2; fi
}

# ##############################################################################
# Function Name : getCounterInColor
# Descripton    : Print counter in color
# Args          : <TYPE> <COUNTER>
# ##############################################################################
getCounterInColor() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: getCounterInColor <TYPE> <COUNTER>" >&2
        echo " <TYPE>: L, W" >&2
        return
    fi
    if [ "$2" -eq 0 ]; then
        echo "${cYellow}$2 $1${cNc}"
    else
        if [ "$1" = "L" ]; then
            echo "${cRed}$2 $1${cNc}"
        elif [ "$1" = "W" ]; then
            echo "${cGreen}$2 $1${cNc}"
        fi
    fi
}

# ##############################################################################
# Function Name : getCountersInColor
# Descripton    : Print counters in color
# Args          : <COUNTER_WIN> [<COUNTER_LOOSE>]
# ##############################################################################
getCountersInColor() {
    if [ "$#" -lt 1 ]; then
        echo "Usage: getCountersInColor <COUNTER_WIN> [<COUNTER_LOOSE>]" >&2
        return
    fi
    if [ "$#" -eq 1 ]; then
        echo "[$(getCounterInColor W "$1")]"
    elif [ "$#" -eq 2 ]; then
        echo "[$(getCounterInColor W "$1") / $(getCounterInColor L "$2")]"
    fi
}

# ##############################################################################
# Function Name : HEXColorDelta
# Args          : <COLOR1> <COLOR2>
# Output        : stdout [0 means similar colors, 100 means opposite colors]
# Source        : https://github.com/kevingrillet/ShellUtils/blob/main/utils/utils_colors.sh
# ##############################################################################
HEXColorDelta() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: HEXColorDelta <COLOR1> <COLOR2>" >&2
        echo " 0 means similar colors, 100 means opposite colors" >&2
        return
    fi
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "HEXColorDelta ${cPurple}$*${cNc}" >&2; fi
    r=$((0x${1:0:2} - 0x${2:0:2}))
    g=$((0x${1:2:2} - 0x${2:2:2}))
    b=$((0x${1:4:2} - 0x${2:4:2}))
    d=$((((765 - (${r#-} + ${g#-} + ${b#-})) * 100) / 765)) # 765 = 3 * 255
    d=$((100 - d))                                          # Delta is a distance... 0=same, 100=opposite need to reverse it
    echo $d
}

# ##############################################################################
# Function Name : inputSwipe
# Descripton    : Swipe
# Args          : <X> <Y> <XEND> <YEND> <TIME>
# ##############################################################################
inputSwipe() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "inputSwipe ${cPurple}$*${cNc}" >&2; fi
    input swipe "$1" "$2" "$3" "$4" "$5"
    screenshotRequired=true
}

# ##############################################################################
# Function Name : inputTapSleep
# Descripton    : input tap <X> <Y>, then SLEEP with default value DEFAULT_SLEEP
# Args          : <X> <Y> [<SLEEP>]
# ##############################################################################
inputTapSleep() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "inputTapSleep ${cPurple}$*${cNc}" >&2; fi
    input tap "$1" "$2"          # tap
    sleep "${3:-$DEFAULT_SLEEP}" # sleep
    screenshotRequired=true
}

# ##############################################################################
# Function Name : loopUntilNotRGB
# Descripton    : Loops until HEX is not equal
# Args          : <SLEEP> <X> <Y> <COLOR> [<COLOR> ...]
# ##############################################################################
loopUntilNotRGB() {
    if [ "$DEBUG" -ge 2 ]; then printInColor "DEBUG" "loopUntilNotRGB ${cPurple}$*${cNc}" >&2; fi
    sleep "$1"
    shift
    until testColorNAND -f "$@"; do
        sleep 1
    done
}

# ##############################################################################
# Function Name : loopUntilRGB
# Descripton    : Loops until HEX is equal
# Args          : <SLEEP> <X> <Y> <COLOR> [<COLOR> ...]
# ##############################################################################
loopUntilRGB() {
    if [ "$DEBUG" -ge 2 ]; then printInColor "DEBUG" "loopUntilRGB ${cPurple}$*${cNc}" >&2; fi
    sleep "$1"
    shift
    until testColorOR -f "$@"; do
        sleep 1
    done
}

# ##############################################################################
# Function Name : printInColor
# Descripton    : Print message in color
# Args          : <TYPE> <MESSAGE>
# ##############################################################################
printInColor() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: printInColor <TYPE> <MESSAGE>" >&2
        echo " <TYPE>: DEBUG, DONE, ERROR, INFO, TEST, WARN" >&2
        return
    fi
    if [ "$1" = "DEBUG" ]; then
        msg="${cPurple}[DEBUG]${cNc} "
    elif [ "$1" = "DONE" ]; then
        msg="${cGreen}[DONE]${cNc}  "
    elif [ "$1" = "ERROR" ]; then
        msg="${cRed}[ERROR]${cNc} "
    elif [ "$1" = "INFO" ]; then
        msg="${cBlue}[INFO]${cNc}  "
    elif [ "$1" = "WARN" ]; then
        msg="${cYellow}[WARN]${cNc}  "
    else
        msg="        "
    fi
    shift
    msg="$msg$1${cNc}" # The ${cNc} is a security if we forgot to reset color at the end of our message
    if [ "$withColors" = false ]; then
        msg=$(echo "$msg" | sed $'s,\x1b\\[[0-9;]*[a-zA-Z],,g') # Source: https://stackoverflow.com/a/54648447
    fi
    echo "$msg"
}

# ##############################################################################
# Function Name : readHEX
# Descripton    : Gets pixel color
# Args          : <X> <Y>
# Output        : $HEX
# ##############################################################################
readHEX() {
    offset=$((DEVICEWIDTH * $2 + $1 + 3))
    HEX=$(dd if="$SCREENSHOTLOCATION" bs=4 skip="$offset" count=1 2>/dev/null | hexdump -C)
    HEX=${HEX:9:9}
    HEX="${HEX// /}"
}

# ##############################################################################
# Function Name : startApp
# Descripton    : Starts AFK Arena
# ##############################################################################
startApp() {
    if [ "$testServer" = true ]; then
        monkey -p com.lilithgames.hgame.gp.id 1 >/dev/null 2>/dev/null
    else
        monkey -p com.lilithgame.hgame.gp 1 >/dev/null 2>/dev/null
    fi
    sleep 1
    disableOrientation
}

# ##############################################################################
# Function Name : takeScreenshot
# Descripton    : Takes a screenshot and saves it if screenshotRequired=true
# Output        : $SCREENSHOTLOCATION
# ##############################################################################
takeScreenshot() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "takeScreenshot [screenshotRequired=${cCyan}$screenshotRequired${cNc}]" >&2; fi
    if [ $screenshotRequired = false ]; then return; fi
    screencap "$SCREENSHOTLOCATION"
    screenshotRequired=false
}

# ##############################################################################
# Function Name : testColorNAND
# Descripton    : Equivalent to:
#                 if getColor <X> <Y> && [ "$HEX" != <COLOR> ] && [ "$HEX" != <COLOR> ]; then
# Args          : [-f] [-d <DELTA>] <X> <Y> <COLOR> [<COLOR> ...]
# Output        : if true, return 0, else 1
# ##############################################################################
testColorNAND() {
    if [ "$DEBUG" -ge 2 ]; then printInColor "DEBUG" "testColorNAND ${cPurple}$*${cNc}" >&2; fi
    _testColorNAND_max_delta=0
    for arg in "$@"; do
        shift
        case "$arg" in
        -d)
            _testColorNAND_max_delta=$1
            shift
            ;;
        -f) screenshotRequired=true ;;
        *) set -- "$@" "$arg" ;;
        esac
    done
    getColor "$1" "$2" # looking for color
    shift
    shift                          # ignore arg
    for i in "$@"; do              # loop in colors
        if [ "$HEX" = "$i" ]; then # color found?
            if [ "$DEBUG" -ge 2 ]; then
                printInColor "DEBUG" "testColorNAND ${cCyan}$HEX${cNc} = ${cCyan}$i${cNc}" >&2
            fi
            return 1 # At the first color found NAND is break, return 1
        else
            if [ "$DEBUG" -ge 2 ] || [ "$_testColorNAND_max_delta" -gt "0" ]; then
                _testColorNAND_delta=$(HEXColorDelta "$HEX" "$i")
                if [ "$DEBUG" -ge 2 ]; then
                    printInColor "DEBUG" "testColorNAND ${cCyan}$HEX${cNc} != ${cCyan}$i${cNc} [Δ ${cCyan}$_testColorNAND_delta${cNc}%]" >&2
                fi
                if [ "$_testColorNAND_delta" -le "$_testColorNAND_max_delta" ]; then
                    return 1
                fi
            fi
        fi
    done
    return 0 # If no result > return 0
}

# ##############################################################################
# Function Name : testColorOR
# Descripton    : Equivalent to:
#                 if getColor <X> <Y> && { [ "$HEX" = <COLOR> ] || [ "$HEX" = <COLOR> ]; }; then
# Args          : [-f] [-d <DELTA>] <X> <Y> <COLOR> [<COLOR> ...]
# Output        : if true, return 0, else 1
# ##############################################################################
testColorOR() {
    if [ "$DEBUG" -ge 2 ]; then printInColor "DEBUG" "testColorOR ${cPurple}$*${cNc}" >&2; fi
    _testColorOR_max_delta=0
    for arg in "$@"; do
        shift
        case "$arg" in
        -d)
            _testColorOR_max_delta=$1
            shift
            ;;
        -f) screenshotRequired=true ;;
        *) set -- "$@" "$arg" ;;
        esac
    done
    getColor "$1" "$2" # looking for color
    shift
    shift                          # ignore arg
    for i in "$@"; do              # loop in colors
        if [ "$HEX" = "$i" ]; then # color found?
            if [ "$DEBUG" -ge 2 ]; then
                printInColor "DEBUG" "testColorOR ${cCyan}$HEX${cNc} = ${cCyan}$i${cNc}" >&2
            fi
            return 0 # At the first color found OR is break, return 0
        else
            if [ "$DEBUG" -ge 2 ] || [ "$_testColorOR_max_delta" -gt "0" ]; then
                _testColorOR_delta=$(HEXColorDelta "$HEX" "$i")
                if [ "$DEBUG" -ge 2 ]; then
                    printInColor "DEBUG" "testColorOR ${cCyan}$HEX${cNc} != ${cCyan}$i${cNc} [Δ ${cCyan}$_testColorOR_delta${cNc}%]" >&2
                fi
                if [ "$_testColorOR_delta" -le "$_testColorOR_max_delta" ]; then
                    return 0
                fi
            fi
        fi
    done
    return 1 # if no result > return 1
}

# ##############################################################################
# Function Name : testColorORTapSleep
# Descripton    : Equivalent to:
#                   if testColorOR <X> <Y> <COLOR>; then
#                       inputTapSleep <X> <Y> <SLEEP>
#                   fi
# Args          : <X> <Y> <COLOR> <SLEEP>
# ##############################################################################
testColorORTapSleep() {
    if [ "$DEBUG" -ge 2 ]; then printInColor "DEBUG" "testColorORTapSleep ${cPurple}$*${cNc}" >&2; fi
    if testColorOR "$1" "$2" "$3"; then                # if color found
        inputTapSleep "$1" "$2" "${4:-$DEFAULT_SLEEP}" # tap & sleep
    fi
}

# ##############################################################################
# Function Name : verifyHEX
# Descripton    : Verifies if <X> and <Y> have specific HEX then print <MESSAGE_*>
# Args          : <X> <Y> <HEX> <MESSAGE_SUCCESS> <MESSAGE_FAILURE>
# Output        : stdout MessageSuccess, stderr MessageFailure
# ##############################################################################
verifyHEX() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "verifyHEX ${cPurple}$*${cNc}" >&2; fi
    getColor "$1" "$2"
    if [ "$HEX" != "$3" ]; then
        printInColor "ERROR" "verifyHEX: Failure! Expected ${cCyan}$3${cNc}, but got ${cCyan}$HEX${cNc} instead. [Δ ${cCyan}$(HEXColorDelta "$HEX" "$3")${cNc}%]" >&2
        printInColor "ERROR" "$5" >&2
        # WARN: The counter sometimes goes wrong. I did leave a print when tries > 0. Need to see if this bug comes back.
        printInColor "WARN" "Restarting for the ${cCyan}$((tries + 1))${cNc} time."
        init
        run
    else
        printInColor "DONE" "$4"
    fi
}

# ##############################################################################
# Function Name : wait
# Descripton    : Default wait time for actions
# ##############################################################################
wait() {
    sleep $DEFAULT_SLEEP
}

# ##############################################################################
# Section       : Game SubFunctions
# Description   : It's the extension of the Core for this specific game
# ##############################################################################

# ##############################################################################
# Function Name : doAuto
# Descripton    : Click on auto if not already enabled
# ##############################################################################
doAuto() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "doAuto" >&2; fi
    testColorORTapSleep 760 1440 332b2b 0 # On:743b29 Off:332b2b
}

# ##############################################################################
# Function Name : doSpeed
# Descripton    : Click on x4 if not already enabled
# ##############################################################################
doSpeed() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "doSpeed" >&2; fi
    testColorORTapSleep 990 1440 332b2b 0 # On:[x2: 753b29, x4: 743b29] Off:332b2b
}

# ##############################################################################
# Function Name : doSkip
# Descripton    : Click on skip if avaible
# ##############################################################################
doSkip() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "doSkip" >&2; fi
    testColorORTapSleep 760 1440 502e1d 0 # Exists: 502e1d
}

# ##############################################################################
# Function Name : switchTab
# Descripton    : Switches to another tab if required by config.
# Args          : <TAB_NAME> [<FORCE>]
#                   <TAB_NAME>: Campaign / Dark Forest / Ranhorn / Chat
#                   <FORCE>: true / false, default false
# ##############################################################################
switchTab() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "switchTab ${cPurple}$*${cNc} [activeTab=${cCyan}$activeTab${cNc}]" >&2; fi
    if [ "$1" = "$activeTab" ]; then
        return
    fi
    case "$1" in
    "Campaign")
        if [ "${2:-false}" = true ] ||
            [ "$doLootAfkChest" = true ] ||
            [ "$doChallengeBoss" = true ] ||
            [ "$doFastRewards" = true ] ||
            [ "$doCollectFriendsAndMercenaries" = true ] ||
            [ "$doLootAfkChest" = true ]; then
            inputTapSleep 550 1850
            activeTab="$1"
            verifyHEX 450 1775 cc9261 "Switched to the Campaign Tab." "Failed to switch to the Campaign Tab."
        fi
        ;;
    "Dark Forest")
        if [ "${2:-false}" = true ] ||
            [ "$doSoloBounties" = true ] ||
            [ "$doTeamBounties" = true ] ||
            [ "$doArenaOfHeroes" = true ] ||
            [ "$doLegendsTournament" = true ] ||
            [ "$doKingsTower" = true ]; then
            inputTapSleep 300 1850
            activeTab="$1"
            verifyHEX 240 1775 d49a61 "Switched to the Dark Forest Tab." "Failed to switch to the Dark Forest Tab."
        fi
        ;;
    "Ranhorn")
        if [ "${2:-false}" = true ] ||
            [ "$doGuildHunts" = true ] ||
            [ "$doTwistedRealmBoss" = true ] ||
            [ "$doBuyFromStore" = true ] ||
            [ "$doStrengthenCrystal" = true ] ||
            [ "$doTempleOfAscension" = true ] ||
            [ "$doCompanionPointsSummon" = true ] ||
            [ "$doCollectOakPresents" = true ] ||
            [ "$doCollectQuestChests" = true ] ||
            [ "$doCollectMail" = true ] ||
            [ "$doCollectMerchantFreebies" = true ]; then
            inputTapSleep 110 1850
            activeTab="$1"
            verifyHEX 20 1775 d49a61 "Switched to the Ranhorn Tab." "Failed to switch to the Ranhorn Tab."
        fi
        ;;
    "Chat")
        inputTapSleep 970 1850
        activeTab="$1"
        verifyHEX 550 1690 ffffff "Switched to the Chat Tab." "Failed to switch to the Chat Tab."
        ;;
    esac
}

# ##############################################################################
# Function Name : waitBattleFinish
# Descripton    : Waits until a battle has ended after <SECONDS>
# Args          : <SECONDS>
# ##############################################################################
waitBattleFinish() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "waitBattleFinish ${cPurple}$*${cNc}" >&2; fi
    sleep "$1"
    finished=false
    until [ $finished = true ]; do
        # First HEX local device, second bluestacks
        if testColorOR -f 560 350 b8894d b7894c; then # Victory
            battleFailed=false
            finished=true
        elif [ "$HEX" = '171932' ] || [ "$HEX" = "171d3c" ]; then # Failed & Failed in Challenger Tournament
            battleFailed=true
            finished=true
        # First HEX local device, second bluestacks
        elif [ "$HEX" = "45331d" ] || [ "$HEX" = "44331c" ]; then # Victory with reward
            battleFailed=false
            finished=true
        fi
        sleep 1
    done
}

# ##############################################################################
# Function Name : waitBattleStart
# Descripton    : Waits until battle starts
# ##############################################################################
waitBattleStart() {
    if [ "$DEBUG" -ge 3 ]; then printInColor "DEBUG" "waitBattleStart" >&2; fi
    _waitBattleStart_count=0 # Max loops = 10 (10x.5s=5s max)
    # Check if pause button is present && less than 10 tries
    until testColorOR -f 110 1465 482f1f || [ $_waitBattleStart_count -ge 10 ]; do
        # Maybe pause button doesn't exist, so instead check for a skip button
        if testColorOR 760 1440 502e1d; then return; fi

        _waitBattleStart_count=$((_waitBattleStart_count + 1)) # Increment
        sleep .5
        # In case none were found, try again starting with the pause button
    done
    sleep 1
}

# ##############################################################################
# Section       : Campaign
# ##############################################################################

# ##############################################################################
# Function Name : challengeBoss
# Descripton    : Challenges a boss in the campaign
# Remark        : Limited offers might screw this up.
# ##############################################################################
challengeBoss() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "challengeBoss" >&2; fi
    inputTapSleep 550 1650 3            # Begin
    if testColorOR 550 740 f2d79f; then # Check if boss
        inputTapSleep 550 1450 3        # Begin
    fi

    if [ "$forceFightCampaign" = "true" ]; then # Fight battle or not
        # Fight in the campaign because of Mythic Trick
        printInColor "INFO" "Fighting in the campaign until ${cCyan}$maxCampaignFights${cNc} defeat(s) because of Mythic Trick."
        _challengeBoss_LOOSE=0
        _challengeBoss_WIN=0

        # Check for battle screen
        until testColorNAND -d "$DEFAULT_DELTA" -f 200 1850 2b1a12 || [ "$maxCampaignFights" -le 0 ]; do
            inputTapSleep 550 1850 .5 # Battle
            waitBattleStart
            doAuto
            doSpeed
            waitBattleFinish 10 # Wait until battle is over

            # Check battle result
            if [ "$battleFailed" = false ]; then     # Win
                if testColorOR 550 1670 e2dddc; then # Check for next stage
                    inputTapSleep 550 1670 6         # Next Stage
                    sleep 6

                    # WARN: Limited offers will fuck this part of the script up. I'm yet to find a way to close any possible offers.
                    # Tap top of the screen to close any possible Limited Offers
                    # inputTapSleep 550 75

                    if testColorOR 550 740 f2d79f; then # Check if boss
                        inputTapSleep 550 1450 5
                    fi
                else
                    inputTapSleep 550 1670 3 # Continue to next battle

                    if testColorNAND -d "$DEFAULT_DELTA" -f 200 1850 2b1a12; then # For low levels, does not exists (before stage 4)
                        inputTapSleep 550 1650 3                                  # Begin
                        if testColorOR 550 740 f2d79f; then                       # Check if boss
                            inputTapSleep 550 1450 3                              # Begin
                        fi
                    fi
                fi
                _challengeBoss_WIN=$((_challengeBoss_WIN + 1)) # Increment
            else                                               # Loose
                inputTapSleep 550 1720 5                       # Try again

                if testColorNAND -d "$DEFAULT_DELTA" -f 200 1850 2b1a12; then # For low levels, does not exists (before stage 4)
                    inputTapSleep 550 1650 3                                  # Begin
                    if testColorOR 550 740 f2d79f; then                       # Check if boss
                        inputTapSleep 550 1450 3                              # Begin
                    fi
                fi

                _challengeBoss_LOOSE=$((_challengeBoss_LOOSE + 1)) # Increment
                maxCampaignFights=$((maxCampaignFights - 1))       # Dicrement
            fi
        done

        # Return to campaign
        if testColorNAND 450 1775 cc9261; then # For low levels, you are automatically kick out (before stage 4)
            inputTapSleep 60 1850              # Return
        fi

        testColorORTapSleep 715 1260 feffff # Check for confirm to exit button
    else
        # Quick exit battle
        inputTapSleep 550 1850 1 # Battle
        inputTapSleep 80 1460    # Pause
        inputTapSleep 230 960 1  # Exit

        if testColorNAND 450 1775 cc9261; then # Check for multi-battle
            inputTapSleep 70 1810
        fi
    fi

    wait
    if [ "$forceFightCampaign" = "true" ]; then
        verifyHEX 450 1775 cc9261 \
            "Challenged boss in campaign. $(getCountersInColor $_challengeBoss_WIN $_challengeBoss_LOOSE)" \
            "Failed to fight boss in Campaign. $(getCountersInColor $_challengeBoss_WIN $_challengeBoss_LOOSE)"
    else
        verifyHEX 450 1775 cc9261 "Challenged boss in campaign." "Failed to fight boss in Campaign."
    fi
}

# ##############################################################################
# Function Name : collectFriendsAndMercenaries
# Descripton    : Collects and sends companion points, as well as auto lending mercenaries
# ##############################################################################
collectFriendsAndMercenaries() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "collectFriendsAndMercenaries" >&2; fi
    inputTapSleep 970 810 1                                  # Friends
    inputTapSleep 930 1600                                   # Send & Recieve
    if testColorOR -d "$DEFAULT_DELTA" 825 1750 df1909; then # Check if its necessary to send mercenaries
        inputTapSleep 720 1760                               # Short-Term
        inputTapSleep 990 190                                # Manage
        inputTapSleep 630 1590                               # Apply
        inputTapSleep 750 1410 1                             # Auto Lend
        inputTapSleep 70 1810 0                              # Return
    else
        printInColor "INFO" "No mercenaries to lend..."
    fi
    inputTapSleep 70 1810 0 # Return

    wait
    verifyHEX 450 1775 cc9261 "Sent and recieved companion points, as well as auto lending mercenaries." "Failed to collect/send companion points or failed to auto lend mercenaries."
}

# ##############################################################################
# Function Name : fastRewards
# Descripton    : Collects fast rewards
# ##############################################################################
fastRewards() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "fastRewards" >&2; fi
    if testColorOR -d "$DEFAULT_DELTA" 980 1620 ef1e05; then # check red dot to see if free fast reward is avaible
        inputTapSleep 950 1660 1
        inputTapSleep 710 1260
        inputTapSleep 560 1800 1
        inputTapSleep 400 1250
    else
        printInColor "INFO" "Fast Rewards collected already, not collecting..."
    fi
    verifyHEX 450 1775 cc9261 "Fast rewards checked." "Failed to check fast rewards."
}

# ##############################################################################
# Function Name : lootAfkChest
# Descripton    : Loots afk chest
# ##############################################################################
lootAfkChest() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "lootAfkChest" >&2; fi
    inputTapSleep 550 1500 1
    inputTapSleep 750 1350 3
    inputTapSleep 550 1850 1 # Tap campaign in case of level up
    wait
    verifyHEX 450 1775 cc9261 "AFK Chest looted." "Failed to loot AFK Chest."
}

# ##############################################################################
# Section       : Dark Forest
# ##############################################################################

# ##############################################################################
# Function Name : arenaOfHeroes
# Descripton    : Does the daily arena of heroes battles
# ##############################################################################
arenaOfHeroes() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "arenaOfHeroes" >&2; fi
    inputTapSleep 740 1050 3
    if [ "$eventHoe" = false ]; then
        inputTapSleep 550 450 3
    else
        inputTapSleep 550 900 3
    fi
    if testColorOR -d "$DEFAULT_DELTA" 1050 1770 e72707; then # Red mark? old value: e52505 (d=5), fb1e0d (d=5)
        inputTapSleep 1000 1800                               # Record
        inputTapSleep 980 410                                 # Close
    fi
    inputTapSleep 540 1800 # Challenge

    if testColorNAND 200 1800 382314 382214; then # Check for new season
        _arenaOfHeroes_LOOSE=0
        _arenaOfHeroes_WIN=0
        printInColor "INFO" "Fighting in the Arena Of Heroes ${cCyan}$totalAmountArenaTries${cNc} time(s)."
        until [ "$totalAmountArenaTries" -le 0 ]; do # Repeat a battle for as long as totalAmountArenaTries
            # Refresh
            # inputTapSleep 815 540

            # Fight specific opponent
            #                                Free         x1
            #  Opponent 1: 820 700      ->        acf0bd
            #  Opponent 2: 820 870      ->  2eaab4      aff3be
            #  Opponent 3: 820 1050     ->        acf0bd
            #  Opponent 4: 820 1220     ->  2daab4      aff1b8
            #  Opponent 5: 820 1400     ->        adf1be
            case $arenaHeroesOpponent in
            1)
                if testColorOR -d "$DEFAULT_DELTA" 820 700 a7f1b7; then # Check if opponent exists
                    inputTapSleep 820 700 0                             # Fight opponent
                else
                    # Refresh opponents and try to fight opponent $arenaHeroesOpponent
                    arenaOfHeroes_tapClosestOpponent 1
                fi
                ;;
            2)
                if testColorOR -d "$DEFAULT_DELTA" 820 870 2daab4 aff3c0; then # Check if opponent exists
                    inputTapSleep 820 870 0                                    # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 2 # Try to fight the closest opponent to 2
                fi
                ;;
            3)
                if testColorOR -d "$DEFAULT_DELTA" 820 1050 a7f1b7; then # Check if opponent exists
                    inputTapSleep 820 1050 0                             # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 3 # Try to fight the closest opponent to 3
                fi
                ;;
            4)
                if testColorOR -d "$DEFAULT_DELTA" 820 1220 2daab4 aff3c0; then # Check if opponent exists
                    inputTapSleep 820 1220 0                                    # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 4 # Try to fight the closest opponent to 4
                fi
                ;;
            5)
                if testColorOR -d "$DEFAULT_DELTA" 820 1400 aaf2bb; then # Check if opponent exists
                    inputTapSleep 820 1400 0                             # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 5 # Try to fight the closest opponent to 5
                fi
                ;;
            *)
                # Invalid option
                echo "[WARN] Invalid arenaHeroesOpponent option in config, skipping..."
                break
                ;;
            esac

            # Check if return value of tapClosesopponent is 0. If it is 0, then it means a battle has been found.
            res=$?
            if [ $res = 0 ]; then
                wait
                if testColorOR -d "$DEFAULT_DELTA" 20 1200 eaca95; then
                    inputTapSleep 550 1850 0 # Battle
                    waitBattleStart
                    doSkip
                    waitBattleFinish 2
                    if [ "$battleFailed" = false ]; then
                        inputTapSleep 550 1550                         # Collect
                        _arenaOfHeroes_WIN=$((_arenaOfHeroes_WIN + 1)) # Increment
                    else
                        _arenaOfHeroes_LOOSE=$((_arenaOfHeroes_LOOSE + 1)) # Increment
                    fi
                    inputTapSleep 550 1550 3 # Finish battle
                else
                    printInColor "WARN" "Failed to enter battle in the Arena of Heroes."
                fi
            fi
            totalAmountArenaTries=$((totalAmountArenaTries - 1)) # Dicrement
        done

        inputTapSleep 1000 380
        sleep 4
    else
        printInColor "INFO" "Unable to fight in the Arena of Heroes because a new season is soon launching." >&2
    fi

    if [ "$doLegendsTournament" = false ]; then # Return to Tab if $doLegendsTournament = false
        inputTapSleep 70 1810
        inputTapSleep 70 1810
        verifyHEX 240 1775 d49a61 \
            "Checked the Arena of Heroes out. $(getCountersInColor $_arenaOfHeroes_WIN $_arenaOfHeroes_LOOSE)" \
            "Failed to check the Arena of Heroes out. $(getCountersInColor $_arenaOfHeroes_WIN $_arenaOfHeroes_LOOSE)"
    else
        inputTapSleep 70 1810
        verifyHEX 760 70 1f2d3a \
            "Checked the Arena of Heroes out. $(getCountersInColor $_arenaOfHeroes_WIN $_arenaOfHeroes_LOOSE)" \
            "Failed to check the Arena of Heroes out. $(getCountersInColor $_arenaOfHeroes_WIN $_arenaOfHeroes_LOOSE)"
    fi
}

# ##############################################################################
# Function Name : arenaOfHeroes_tapClosestOpponent
# Descripton    : Attempts to tap the closest Arena of Heroes opponent
# Args          : <OPPONENT>: 1/2/3/4/5
# Output        : If failed, return 1
# ##############################################################################
arenaOfHeroes_tapClosestOpponent() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "arenaOfHeroes_tapClosestOpponent ${cPurple}$*${cNc}" >&2; fi
    # Depending on the opponent number sent as a parameter ($1), this function
    # would attempt to check if there's an opponent above the one sent.
    # If there isn't, check the one above that one and so on until one is found.
    # When found, tap on the opponent and exit function.
    case $1 in
    1)
        # Refresh
        inputTapSleep 815 540

        # Attempt to fight $arenaHeroesOpponent opponent, and if not present, skip battle
        case $arenaHeroesOpponent in
        1)
            # Check if opponent 1 exists and fight if true
            if testColorOR -d "$DEFAULT_DELTA" 820 700 a7f1b7; then inputTapSleep 820 700 0; else return 1; fi
            ;;
        2)
            # Check if opponent 2 exists and fight if true
            if testColorOR -d "$DEFAULT_DELTA" 820 870 2daab4 aff3c0; then inputTapSleep 820 870 0; else return 1; fi
            ;;
        3)
            # Check if opponent 3 exists and fight if true
            if testColorOR -d "$DEFAULT_DELTA" 820 1050 a7f1b7; then inputTapSleep 820 1050 0; else return 1; fi
            ;;
        4)
            # Check if opponent 4 exists and fight if true
            if testColorOR -d "$DEFAULT_DELTA" 820 1220 2daab4 aff3c0; then inputTapSleep 820 1220 0; else return 1; fi
            ;;
        5)
            # Check if opponent 5 exists and fight if true
            if testColorOR -d "$DEFAULT_DELTA" 820 1400 aaf2bb; then inputTapSleep 820 1400 0; else return 1; fi
            ;;
        esac
        ;;
    2)
        if testColorOR -d "$DEFAULT_DELTA" 820 700 a7f1b7; then # Check if opponent 1 exists
            inputTapSleep 820 700 0                             # Fight opponent
        else
            arenaOfHeroes_tapClosestOpponent 1 # Try to fight the closest opponent to 2
        fi
        ;;
    3)
        if testColorOR -d "$DEFAULT_DELTA" 820 870 2daab4 aff3c0; then # Check if opponent 2 exists
            inputTapSleep 820 870 0                                    # Fight opponent
        else
            arenaOfHeroes_tapClosestOpponent 2 # Try to fight the closest opponent to 3
        fi
        ;;
    4)
        if testColorOR -d "$DEFAULT_DELTA" 820 1050 a7f1b7; then # Check if opponent 3 exists
            inputTapSleep 820 1050 0                             # Fight opponent
        else
            arenaOfHeroes_tapClosestOpponent 3 # Try to fight the closest opponent to 4
        fi
        ;;
    5)
        if testColorOR -d "$DEFAULT_DELTA" 820 1220 2daab4 aff3c0; then # Check if opponent 4 exists
            inputTapSleep 820 1220 0                                    # Fight opponent
        else
            arenaOfHeroes_tapClosestOpponent 4 # Try to fight the closest opponent to 5
        fi
        ;;
    esac
}

# ##############################################################################
# Function Name : kingsTower
# Descripton    : Try to battle in every Kings Tower
# ##############################################################################
kingsTower() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "kingsTower" >&2; fi
    inputTapSleep 500 870 5 # King's Tower
    printInColor "INFO" "Fighting King's Tower until ${cCyan}$maxKingsTowerFights${cNc} defeat(s)."

    if testColorOR 550 150 1a1212; then
        # King's Tower without Towers of Esperia unlocked (between stage 2-12 and 15-1)
        if [ "$doMainTower" = true ]; then
            printInColor "INFO" "Main Tower $(kingsTower_battle -1 -1)" # Main Tower
        fi
    else
        # King's Tower with Towers of Esperia unlocked (after stage 15-1)
        if [ "$doMainTower" = true ]; then
            printInColor "INFO" "Main Tower $(kingsTower_battle 550 800)" # Main Tower
        fi

        if [ "$doTowerOfLight" = true ] && { [ "$dayofweek" -eq 1 ] || [ "$dayofweek" -eq 5 ] || [ "$dayofweek" -eq 7 ]; }; then
            printInColor "INFO" "Tower of Light $(kingsTower_battle 300 950)" # Tower of Light
        fi

        if [ "$doTheBrutalCitadel" = true ] && { [ "$dayofweek" -eq 2 ] || [ "$dayofweek" -eq 5 ] || [ "$dayofweek" -eq 7 ]; }; then
            printInColor "INFO" "The Brutal Citadel $(kingsTower_battle 400 1250)" # The Brutal Citadel
        fi

        if [ "$doTheWorldTree" = true ] && { [ "$dayofweek" -eq 3 ] || [ "$dayofweek" -eq 6 ] || [ "$dayofweek" -eq 7 ]; }; then
            printInColor "INFO" "The World Tree $(kingsTower_battle 750 660)" # The World Tree
        fi

        if [ "$doCelestialSanctum" = true ] && { [ "$dayofweek" -eq 3 ] || [ "$dayofweek" -eq 5 ] || [ "$dayofweek" -eq 7 ]; }; then
            printInColor "INFO" "Celestial Sanctum $(kingsTower_battle 270 500)" # Celestial Sanctum
        fi

        if [ "$doTheForsakenNecropolis" = true ] && { [ "$dayofweek" -eq 4 ] || [ "$dayofweek" -eq 6 ] || [ "$dayofweek" -eq 7 ]; }; then
            printInColor "INFO" "The Forsaken Necropolis $(kingsTower_battle 780 1100)" # The Forsaken Necropolis
        fi

        if [ "$doInfernalFortress" = true ] && { [ "$dayofweek" -eq 4 ] || [ "$dayofweek" -eq 6 ] || [ "$dayofweek" -eq 7 ]; }; then
            printInColor "INFO" "Infernal Fortress $(kingsTower_battle 620 1550)" # Infernal Fortress
        fi
    fi

    # Exit
    inputTapSleep 70 1810
    verifyHEX 240 1775 d49a61 "Battled at the Kings Tower." "Failed to battle at the Kings Tower."
}

# ##############################################################################
# Function Name : kingsTower_battle
# Descripton    : Battles in King's Towers
# Args          : <X> <Y>
# Remark        : Limited offers might screw this up.
# ##############################################################################
kingsTower_battle() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "kingsTower_battle ${cPurple}$*${cNc}" >&2; fi
    _kingsTower_battle_COUNT=0 # Equivalent to loose
    _kingsTower_battle_WIN=0

    if [ "$1" -ge 0 ] && [ "$2" -ge 0 ]; then # Will be -1 if we already are in the tower
        inputTapSleep "$1" "$2" 2             # Tap chosen tower
    fi

    # Check if inside tower
    if testColorOR 550 150 1a1212; then
        inputTapSleep 540 1350 # Challenge

        # Battle until equal to maxKingsTowerFights & we haven't reached daily limit of 10 floors
        until [ "$_kingsTower_battle_COUNT" -ge "$maxKingsTowerFights" ] || testColorOR -f 550 150 1a1212; do
            inputTapSleep 550 1850 0 # Battle
            waitBattleFinish 2

            # Check if win or lose battle
            if [ "$battleFailed" = false ]; then
                _kingsTower_battle_WIN=$((_kingsTower_battle_WIN + 1)) # Increment
                inputTapSleep 550 1850 4                               # Collect
                inputTapSleep 550 170                                  # Tap on the top to close possible limited offer

                # WARN: Limited offers might screw this up. Tapping 550 170 might close an offer.
                # Tap top of the screen to close any possible Limited Offers
                # if testColorOR 550 150 1a1212; then # not on screen with Challenge button
                #     inputTapSleep 550 75        # Tap top of the screen to close Limited Offer
                #     if testColorOR 550 150 1a1212; then # think i remember it needs two taps to close offer
                #         inputTapSleep 550 75    # Tap top of the screen to close Limited Offer
                # fi

                inputTapSleep 540 1350 # Challenge
            elif [ "$battleFailed" = true ]; then
                inputTapSleep 550 1720                                     # Try again
                _kingsTower_battle_COUNT=$((_kingsTower_battle_COUNT + 1)) # Increment
            fi

            # Check if reached daily limit / kicked us out of battle screen
        done

        # Return from chosen tower / battle
        inputTapSleep 70 1810 3
        if [ "$1" -ge 0 ] && [ "$2" -ge 0 ]; then # Will be -1 if we already are in the tower (low level)
            if testColorOR 550 150 1a1212; then   # In case still in tower, exit once more
                inputTapSleep 70 1810 0
            fi
        fi
        sleep 2
    fi
    getCountersInColor $_kingsTower_battle_WIN $_kingsTower_battle_COUNT
}

# ##############################################################################
# Function Name : legendsTournament
# Descripton    : Does the daily Legends tournament battles
# Args          : <START_FROM_TAB>: true / false
# ##############################################################################
legendsTournament() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "legendsTournament ${cPurple}$*${cNc}" >&2; fi
    if [ "$1" = true ]; then # Check if starting from tab or already inside activity
        inputTapSleep 740 1050
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 740 1050 1
    ## End of testing ##
    if [ "$eventHoe" = false ]; then
        inputTapSleep 550 900 # Legend's Challenger Tournament
    else
        inputTapSleep 550 1450 # Legend's Challenger Tournament
    fi
    inputTapSleep 550 280 3  # Chest
    inputTapSleep 550 1550 3 # Collect

    if testColorOR -d "$DEFAULT_DELTA" 1040 1800 e72007; then # Red mark?
        inputTapSleep 1000 1800                               # Record
        inputTapSleep 990 380                                 # Close
    fi

    _legendsTournament_LOOSE=0
    _legendsTournament_WIN=0
    printInColor "INFO" "Fighting in the Legends' Challenger Tournament ${cCyan}$totalAmountTournamentTries${cNc} time(s)."
    until [ "$totalAmountTournamentTries" -le 0 ]; do # Repeat a battle for as long as totalAmountTournamentTries
        inputTapSleep 550 1840 4                      # Challenge
        inputTapSleep 800 1140 4                      # Third opponent

        if testColorOR -d "$DEFAULT_DELTA" 20 1200 eaca95; then
            inputTapSleep 550 1850 4 # Begin Battle
            # inputTapSleep 770 1470 4
            waitBattleStart
            doSkip
            waitBattleFinish 4
            if [ "$battleFailed" = false ]; then
                _legendsTournament_WIN=$((_legendsTournament_WIN + 1)) # Increment
            else
                _legendsTournament_LOOSE=$((_legendsTournament_LOOSE + 1)) # Increment
            fi
            inputTapSleep 550 800 4 # Tap anywhere to close
        else
            printInColor "WARN" "Failed to enter battle at the Legends Tournament."
        fi
        totalAmountTournamentTries=$((totalAmountTournamentTries - 1)) # Dicrement
    done

    inputTapSleep 70 1810
    inputTapSleep 70 1810
    verifyHEX 240 1775 d49a61 \
        "Battled at the Legends Tournament. $(getCountersInColor $_legendsTournament_WIN $_legendsTournament_LOOSE)" \
        "Failed to battle at the Legends Tournament. $(getCountersInColor $_legendsTournament_WIN $_legendsTournament_LOOSE)"
}

# ##############################################################################
# Function Name : soloBounties
# Descripton    : Starts Solo bounties
# ##############################################################################
soloBounties() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "soloBounties" >&2; fi
    inputTapSleep 600 1320 1
    inputTapSleep 780 1550 1 # Collect all
    inputTapSleep 350 1550   # Dispatch all
    inputTapSleep 550 1500 0 # Confirm

    if [ "$doTeamBounties" = false ]; then # Return to Tab if $doTeamBounties = false
        wait
        inputTapSleep 70 1810
        verifyHEX 240 1775 d49a61 "Collected/dispatched solo bounties." "Failed to collect/dispatch solo bounties."
    else
        wait
        verifyHEX 650 1740 a7541a "Collected/dispatched solo bounties." "Failed to collect/dispatch solo bounties."
    fi
}

# ##############################################################################
# Function Name : teamBounties
# Descripton    : Starts Team bounties
# Args          : <START_FROM_TAB>: true / false
# ##############################################################################
teamBounties() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "teamBounties ${cPurple}$*${cNc}" >&2; fi
    if [ "$1" = true ]; then # Check if starting from tab or already inside activity
        inputTapSleep 600 1320 1
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 600 1320 1
    ## End of testing ##
    inputTapSleep 910 1770
    inputTapSleep 780 1550 1 # Collect all
    inputTapSleep 350 1550   # Dispatch all
    inputTapSleep 550 1500   # Confirm
    inputTapSleep 70 1810
    verifyHEX 240 1775 d49a61 "Collected/dispatched team bounties." "Failed to collect/dispatch team bounties."
}

# ##############################################################################
# Section       : Ranhorn
# ##############################################################################

# ##############################################################################
# Function Name : buyFromStore
# Descripton    : Buy items from store
# ##############################################################################
buyFromStore() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "buyFromStore" >&2; fi
    inputTapSleep 330 1650 3

    if [ "$buyStoreDust" = true ]; then # Dust
        buyFromStore_buyItem 175 1100
    fi
    if [ "$buyStorePoeCoins" = true ]; then # Poe Coins
        buyFromStore_buyItem 675 1690
    fi
    # Primordial Emblem
    if [ "$buyStorePrimordialEmblem" = true ] && testColorOR -d "$DEFAULT_DELTA" 175 1690 c6ced5; then
        buyFromStore_buyItem 175 1690
    fi
    # Amplifying Emblem
    if [ "$buyStoreAmplifyingEmblem" = true ] && testColorOR -d "$DEFAULT_DELTA" 175 1690 c59e71 cca67a; then
        buyFromStore_buyItem 175 1690
    fi
    if [ "$buyStoreSoulstone" = true ]; then                     # Soulstone (widh 90 diamonds)
        if testColorOR -d "$DEFAULT_DELTA" 910 1100 cf9ced; then # row 1, item 4
            buyFromStore_buyItem 910 1100
        fi
        if testColorOR -d "$DEFAULT_DELTA" 650 1100 b165c0; then # row 1, item 3
            buyFromStore_buyItem 650 1100
        fi
    fi
    if [ "$buyStoreLimitedGoldOffer" = true ]; then # Limited Gold Offer
        buyFromStore_buyItem 420 820
    fi
    if [ "$buyStoreLimitedDiamOffer" = true ]; then # Limited Diam Offer
        buyFromStore_buyItem 670 820
    fi
    if [ "$forceWeekly" = true ]; then
        # Weekly - Purchase an item from the Guild Store once (check red dot first row for most useful item)
        if [ "$buyWeeklyGuild" = true ]; then
            inputTapSleep 530 1810 # Guild Store
            if testColorOR -d "5" 620 750 ef1f06; then
                buyFromStore_buyItem 550 820 # Limited
            elif testColorOR -d "5" 250 1040 b02004; then
                buyFromStore_buyItem 180 1100 # row 1, item 1
            elif testColorOR -d "5" 500 1040 ed1f06; then
                buyFromStore_buyItem 420 1100 # row 1, item 2
            elif testColorOR -d "5" 744 1040 ed1f06; then
                buyFromStore_buyItem 660 1100 # row 1, item 3
            elif testColorOR -d "5" 985 1040 ef1e06; then
                buyFromStore_buyItem 900 1100 # row 1, item 4
            fi
        fi
        if [ "$buyWeeklyLabyrinth" = true ]; then
            inputTapSleep 1020 1810          # Labyrinth Store
            inputSwipe 1050 1600 1050 750 50 # Swipe all the way down
            sleep 2
            if testColorOR -d "$DEFAULT_DELTA" 950 1570 2a2b64; then # row 6, item 4 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 900 1620
            elif testColorOR -d "$DEFAULT_DELTA" 710 1570 272861; then # row 6, item 3 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 660 1620
            elif testColorOR -d "$DEFAULT_DELTA" 465 1570 282962; then # row 6, item 2 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 420 1620
            elif testColorOR -d "$DEFAULT_DELTA" 220 1570 292a63; then # row 6, item 1 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 180 1620
            elif testColorOR -d "$DEFAULT_DELTA" 950 1280 292a63; then # row 5, item 4 > 120 Rare Hero Soulstone / 4800 Labyrinth Tokens
                buyFromStore_buyItem 900 1330
            elif testColorOR -d "$DEFAULT_DELTA" 710 1280 272861; then # row 5, item 3 > 120 Rare Hero Soulstone / 4800 Labyrinth Tokens
                buyFromStore_buyItem 660 1330
            else
                printInColor "INFO" "Can't buy item from Labyrinth store"
            fi
        fi
    fi
    inputTapSleep 70 1810 # Return
    verifyHEX 20 1775 d49a61 "Visited the Store." "Failed to visit the Store."
}

# ##############################################################################
# Function Name : buyFromStore_buyItem
# Descripton    : Buys an item from the Store
# Args          : <X> <Y>
# ##############################################################################
buyFromStore_buyItem() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "buyFromStore_buyItem ${cPurple}$*${cNc}" >&2; fi
    inputTapSleep "$1" "$2" 1 # Item
    inputTapSleep 550 1540 1  # Purchase
    inputTapSleep 550 1700    # Close popup
}

# ##############################################################################
# Function Name : buyFromStore_test
# Descripton    : Buy items from store ON TEST SERVER (old shop)
# Remark        : Should be removed if one day the test server has the new shop
# ##############################################################################
buyFromStore_test() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "buyFromStore_test" >&2; fi
    inputTapSleep 330 1650 3

    if [ "$buyStoreDust" = true ]; then # Dust
        buyFromStore_buyItem 180 840
    fi
    if [ "$buyStorePoeCoins" = true ]; then # Poe Coins
        buyFromStore_buyItem 670 1430
    fi
    # Primordial Emblem
    if [ "$buyStorePrimordialEmblem" = true ] && testColorOR -d "$DEFAULT_DELTA" 180 1430 9eabbd; then
        buyFromStore_buyItem 180 1430
    fi
    # Amplifying Emblem
    if [ "$buyStoreAmplifyingEmblem" = true ] && testColorOR -d "$DEFAULT_DELTA" 180 1430 d8995d; then
        buyFromStore_buyItem 180 1430
    fi
    if [ "$buyStoreSoulstone" = true ]; then                    # Soulstone (widh 90 diamonds)
        if testColorOR -d "$DEFAULT_DELTA" 910 850 a569d7; then # row 1, item 4
            buyFromStore_buyItem 910 850
        fi
        if testColorOR -d "$DEFAULT_DELTA" 650 850 57447b; then # row 1, item 3
            buyFromStore_buyItem 650 850
        fi
        if testColorOR -d "$DEFAULT_DELTA" 410 850 9787c9; then # row 1, item 2
            buyFromStore_buyItem 410 850
        fi
    fi
    if [ "$forceWeekly" = true ]; then
        # Weekly - Purchase an item from the Guild Store once (check red dot first row for most useful item)
        if [ "$buyWeeklyGuild" = true ]; then
            inputTapSleep 530 1810                                  # Guild Store
            if testColorOR -d "$DEFAULT_DELTA" 100 910 87b8e4; then # row 1, item 1
                if testColorOR -d "5" 250 740 ea1c09; then buyFromStore_buyItem 180 810; fi
            elif testColorOR -d "$DEFAULT_DELTA" 345 910 93c1ed; then # row 1, item 2
                if testColorOR -d "5" 500 740 ed240f; then buyFromStore_buyItem 420 810; fi
            elif testColorOR -d "$DEFAULT_DELTA" 590 910 3b2312; then # row 1, item 3
                if testColorOR -d "5" 740 740 f51f06; then buyFromStore_buyItem 660 810; fi
            elif testColorOR -d "$DEFAULT_DELTA" 835 910 81bde2; then # row 1, item 4
                if testColorOR -d "5" 980 740 f12f1e; then buyFromStore_buyItem 900 810; fi
            fi
        fi
        if [ "$buyWeeklyLabyrinth" = true ]; then
            inputTapSleep 1020 1810          # Labyrinth Store
            inputSwipe 1050 1600 1050 750 50 # Swipe all the way down
            wait
            if testColorOR -d "$DEFAULT_DELTA" 900 1500 36bae4; then # row 6, item 4 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 900 1500
            elif testColorOR -d "$DEFAULT_DELTA" 660 1500 7fd1e7; then # row 6, item 3 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 660 1500
            elif testColorOR -d "$DEFAULT_DELTA" 420 1500 91abac; then # row 6, item 2 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 420 1500
            elif testColorOR -d "$DEFAULT_DELTA" 180 1500 8fdbf4; then # row 6, item 1 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 180 1500
            elif testColorOR -d "$DEFAULT_DELTA" 900 1200 88d8ff; then # row 5, item 4 > 120 Rare Hero Soulstone / 4800 Labyrinth Tokens
                buyFromStore_buyItem 900 1200
            elif testColorOR -d "$DEFAULT_DELTA" 660 1200 67d2fc; then # row 5, item 3 > 120 Rare Hero Soulstone / 4800 Labyrinth Tokens
                buyFromStore_buyItem 660 1200
            else
                printInColor "INFO" "Can't buy item from Labyrinth store"
            fi
        fi
    fi
    inputTapSleep 70 1810 # Return
    verifyHEX 20 1775 d49a61 "Visited the Store." "Failed to visit the Store."
}

# ##############################################################################
# Function Name : guildHunts
# Descripton    : Battles against Guild boss Wrizz
# ##############################################################################
guildHunts() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "guildHunts" >&2; fi
    inputTapSleep 380 360 10

    # Check for fortune chest
    if testColorOR 380 500 8e4633; then
        inputTapSleep 560 1300
        inputTapSleep 540 1830
    fi
    wait

    inputTapSleep 290 860 3
    printInColor "INFO" "Fighting Wrizz ${cCyan}$totalAmountGuildBossTries${cNc} time(s)."
    guildHunts_quickBattle
    inputTapSleep 970 890 1              # Soren
    if testColorOR 715 1815 8ae5c4; then # If Soren is open
        printInColor "INFO" "Fighting Soren ${cCyan}$totalAmountGuildBossTries${cNc} time(s)."
        guildHunts_quickBattle
    elif [ "$canOpenSoren" = true ]; then # If Soren is closed
        printInColor "INFO" "Soren is closed."
        if testColorOR 580 1753 fae0ac; then # If soren is "openable"
            printInColor "INFO" "Oppening Soren."
            inputTapSleep 550 1850
            inputTapSleep 700 1250 1
            printInColor "INFO" "Fighting Soren ${cCyan}$totalAmountGuildBossTries${cNc} time(s)."
            guildHunts_quickBattle
        fi
    fi

    if [ "$doTwistedRealmBoss" = false ]; then # Return to Tab if $doTwistedRealmBoss = false
        inputTapSleep 70 1810 3
        inputTapSleep 70 1810 3
        verifyHEX 20 1775 d49a61 "Battled Wrizz and possibly Soren." "Failed to battle Wrizz and possibly Soren."
    else
        inputTapSleep 70 1810
        verifyHEX 70 1000 a9a95f "Battled Wrizz and possibly Soren." "Failed to battle Wrizz and possibly Soren."
    fi
}

# ##############################################################################
# Function Name : guildHunts_quickBattle
# Descripton    : Repeat a battle for as long as totalAmountGuildBossTries
# Remark        : May break because "some resources have exceeded their maximum limit"
# ##############################################################################
guildHunts_quickBattle() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "guildHunts_quickBattle" >&2; fi
    _guildHunts_quickBattle_COUNT=0
    # Check if possible to fight wrizz to secure totalAmountGuildBossTries -> Grey: a1a1a1 / Blue: 9de8be
    until [ "$_guildHunts_quickBattle_COUNT" -ge "$totalAmountGuildBossTries" ] || testColorOR 710 1840 a1a1a1; do
        if [ "$guildBattleType" = "challenge" ]; then
            inputTapSleep 350 1840   # Challenge
            inputTapSleep 550 1850 0 # Battle
            waitBattleStart
            doAuto
            doSpeed
            waitBattleFinish 10     # Wait until battle is over
            inputTapSleep 550 800 0 # Reward
            inputTapSleep 550 800 1 # Reward x2
        else
            inputTapSleep 710 1840 # Quick Battle
            # WARN: May break because "some resources have exceeded their maximum limit"
            inputTapSleep 720 1300 1 # Begin
            inputTapSleep 550 800 0  # Reward
            inputTapSleep 550 800 1  # Reward x2
        fi
        _guildHunts_quickBattle_COUNT=$((_guildHunts_quickBattle_COUNT + 1)) # Increment
    done
}

# ##############################################################################
# Function Name : nobleTavern
# Descripton    : Let's do a "free" summon with Companion Points
# ##############################################################################
nobleTavern() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "nobleTavern" >&2; fi
    inputTapSleep 280 1370 3 # The Noble Tavern
    inputTapSleep 600 1820 1 # The noble tavern again

    #until testColorOR 890 850 f4e38e; do       # Looking for heart
    until testColorOR -d "$DEFAULT_DELTA" 875 835 f39067; do # Looking for heart, old value: fc9473 (d=4)
        inputTapSleep 870 1630 1                             # Next pannel
    done

    inputTapSleep 320 1450 3 # Summon
    inputTapSleep 540 900 3  # Click on the card
    inputTapSleep 70 1810    # close
    inputTapSleep 550 1820 1 # Collect rewards

    inputTapSleep 70 1810
    verifyHEX 20 1775 d49a61 "Summoned one hero with Companion Points." "Failed to summon one hero with Companion Points."
}

# ##############################################################################
# Function Name : oakInnSpeedy
# Descripton    : Collect Oak Inn faster than oakInn()
# Concept       : https://github.com/Fortigate/AFK-Daily/blob/master/deploy.sh > collectInnGifts()
# ##############################################################################
oakInnSpeedy() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "oakInn" >&2; fi
    inputTapSleep 670 320 5 # Oak Inn
    printInColor "INFO" "Searching for presents to collect..."
    _oakInn_COUNT=0
    _oakInn_COLLECTED=0
    until [ "$_oakInn_COLLECTED" -ge "$totalAmountOakRewards" ] || [ "$_oakInn_COUNT" -ge $((totalAmountOakRewards * 10)) ]; do
        _oakInn_ROW_COUNT=0
        screenshotRequired=true
        until [ "$_oakInn_ROW_COUNT" -ge 100 ]; do
            if testColorOR -d 3 $((250 + _oakInn_ROW_COUNT * 5)) 1330 9b3e28 932017 e7af65 8d2911 ffd885; then
                inputTapSleep $((250 + _oakInn_ROW_COUNT * 5)) 1330 2 # Tap present
                if testColorOR 250 1200 eaddb8; then
                    inputTapSleep 540 1650 1                     # Ok
                    inputTapSleep 540 1650 .5                    # Collect reward
                    _oakInn_COLLECTED=$((_oakInn_COLLECTED + 1)) # Increment
                    break
                fi
            fi
            _oakInn_ROW_COUNT=$((_oakInn_ROW_COUNT + 1)) # Increment
        done
        _oakInn_COUNT=$((_oakInn_COUNT + 1)) # Increment
    done

    inputTapSleep 70 1810 0

    wait
    verifyHEX 20 1775 d49a61 \
        "Attempted to collect Oak Inn presents. [${cCyan}$_oakInn_COLLECTED${cNc}]" \
        "Failed to collect Oak Inn presents. [${cCyan}$_oakInn_COLLECTED${cNc}]"
}

# ##############################################################################
# Function Name : strengthenCrystal
# Descripton    : Strenghen Crystal
# ##############################################################################
strengthenCrystal() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "strengthenCrystal" >&2; fi
    if testColorOR -d "$DEFAULT_DELTA" 870 1115 ff1908; then # If red circle
        inputTapSleep 760 1030 3                             # Resonating Crystal

        # Detect if free slot, and take it.
        testColorORTapSleep 620 1250 82ead0 # Detected: 82ead0 / Not: e4c38e

        inputTapSleep 550 1850                                                    # Strenghen Crystal
        if testColorOR 700 1250 9aedc4 && [ "$allowCrystalLevelUp" = true ]; then # If Level up
            printInColor "INFO" "Level up."
            inputTapSleep 700 1250 3 # Confirm level up window
            inputTapSleep 200 1850 1 # Close level up window
            inputTapSleep 200 1850   # Close gift window
        else
            inputTapSleep 200 1850 # Close level up window
        fi
        inputTapSleep 200 1850 .5 # Better safe than sorry
        inputTapSleep 70 1810     # Exit
    else
        printInColor "INFO" "Not necessary to strengthen the resonating Crystal."
    fi
    verifyHEX 20 1775 d49a61 "Strenghened resonating Crystal." "Failed to Strenghen Resonating Crystal."
}

# ##############################################################################
# Function Name : templeOfAscension
# Descripton    : Auto ascend heroes
# ##############################################################################
templeOfAscension() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "templeOfAscension" >&2; fi
    if testColorOR -d "$DEFAULT_DELTA" 450 1050 fe1c0c; then # If red circle
        inputTapSleep 280 960                                # Temple Of Ascension
        inputTapSleep 900 1800                               # Auto Ascend
        inputTapSleep 550 1460                               # Confirm
        inputTapSleep 550 1810                               # Close
        inputTapSleep 70 1810                                # Exit
    else
        printInColor "INFO" "No heroes to ascend."
    fi

    inputTapSleep 70 1810 # Exit
    wait
    verifyHEX 20 1775 d49a61 "Attempted to ascend heroes." "Failed to ascend heroes."
}

# ##############################################################################
# Function Name : twistedRealmBoss
# Descripton    : Battles against the Twisted Realm Boss
# Args          : <START_FROM_TAB>: true / false
# ##############################################################################
twistedRealmBoss() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "twistedRealmBoss ${cPurple}$*${cNc}" >&2; fi
    if [ "$1" = true ]; then # Check if starting from tab or already inside activity
        inputTapSleep 380 360 10
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 380 360 10
    ## End of testing ##

    inputTapSleep 820 820 # Twisted Realm

    if testColorOR 540 1220 9aedc1; then # Check if TR is being calculated
        printInColor "INFO" "Unable to fight in the Twisted Realm because it's being calculated." >&2
    else
        printInColor "INFO" "Fighting Twisted Realm Boss ${cCyan}$totalAmountTwistedRealmBossTries${cNc} time(s)."
        until [ "$totalAmountTwistedRealmBossTries" -le 0 ]; do
            inputTapSleep 550 1850               # Challenge
            if testColorOR 600 1250 53c6bb; then # Check if notice did popup
                inputTapSleep 70 1810
                break
            fi
            inputTapSleep 550 1850 0 # Battle
            waitBattleStart
            doAuto
            doSpeed
            waitBattleFinish 40
            wait
            inputTapSleep 550 800 3                                                    # tap score screen
            inputTapSleep 550 800                                                      # tap score screen to close it
            totalAmountTwistedRealmBossTries=$((totalAmountTwistedRealmBossTries - 1)) # Dicrement
        done
    fi

    inputTapSleep 70 1810
    inputTapSleep 70 1810 1
    verifyHEX 20 1775 d49a61 "Checked Twisted Realm Boss out." "Failed to check the Twisted Realm out."
}

# ##############################################################################
# Section       : End
# ##############################################################################

# ##############################################################################
# Function Name : checkWhereToEnd
# Descripton    : Checks where to end the script
# ##############################################################################
checkWhereToEnd() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "checkWhereToEnd" >&2; fi
    case "$endAt" in
    "oak")
        switchTab "Ranhorn" true
        inputTapSleep 780 280 0
        ;;
    "soren")
        switchTab "Ranhorn" true
        inputTapSleep 380 360 3
        inputTapSleep 290 860 1
        inputTapSleep 970 890 0
        ;;
    "mail")
        inputTapSleep 960 630 0
        ;;
    "chat")
        switchTab "Chat" true
        ;;
    "tavern")
        switchTab "Ranhorn" true
        inputTapSleep 300 1400 0
        ;;
    "merchants")
        inputTapSleep 120 290 0
        ;;
    "campaign")
        inputTapSleep 550 1850 0
        ;;
    "championship")
        switchTab "Dark Forest" true
        inputTapSleep 740 1050
        if [ "$eventHoe" = false ]; then
            inputTapSleep 550 1370 0
        else
            inputTapSleep 550 1680 0
        fi
        ;;
    *)
        printInColor "WARN" "Unknown location to end script on. Ignoring..." >&2
        ;;
    esac
}

# ##############################################################################
# Function Name : collectQuestChests
# Descripton    : Collects quest chests (well, switch tab then call collectQuestChests_quick)
# Remark        : May break because "some resources have exceeded their maximum limit"
# ##############################################################################
collectQuestChests() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "collectQuestChests" >&2; fi
    # WARN: May break because "some resources have exceeded their maximum limit"
    # WARN: This actually happened to me today, and the script handled it well, as it thought it had one more chest to collect
    # WARN: and closed the warning message. Might not be a problem anymore.
    inputTapSleep 960 250 # Quests
    collectQuestChests_quick

    inputTapSleep 650 1650 # Weeklies
    collectQuestChests_quick

    #WARN: May break if the reward is a new champ...
    inputTapSleep 930 1650                                     # Campaign
    until testColorNAND -d "$DEFAULT_DELTA" 950 610 acf0bd; do # Old value: 82fdf5
        inputTapSleep 860 610
    done

    inputTapSleep 70 1650 1 # Return
    verifyHEX 20 1775 d49a61 "Collected daily and weekly quest chests." "Failed to collect daily and weekly quest chests."
}

# ##############################################################################
# Function Name : collectQuestChests_quick
# Descripton    : Collects quest chests
# ##############################################################################
collectQuestChests_quick() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "collectQuestChests_quick" >&2; fi
    # Collect Quests
    until testColorNAND -d "$DEFAULT_DELTA" 700 670 7dfff1; do # Old value: 82fdf5
        inputTapSleep 930 680
    done

    if testColorNAND -d "$DEFAULT_DELTA" 265 450 4b2711 && testColorNAND 295 410 71211e; then # OFF: 4b2711 COLLECTED: 71211e
        inputTapSleep 330 430                                                                 # Chest 20
        inputTapSleep 580 600 0                                                               # Collect
    fi
    if testColorNAND -d "$DEFAULT_DELTA" 430 450 552813 && testColorNAND 460 410 ad2c27; then # OFF: 552813 COLLECTED: ad2c27
        inputTapSleep 500 430                                                                 # Chest 40
        inputTapSleep 580 600 0                                                               # Collect
    fi
    if testColorNAND -d "$DEFAULT_DELTA" 595 450 4e2713 && testColorNAND 625 410 8f2d28; then # OFF: 4e2713 COLLECTED: 8f2d28
        inputTapSleep 660 430                                                                 # Chest 60
        inputTapSleep 580 600 0                                                               # Collect
    fi
    if testColorNAND -d "$DEFAULT_DELTA" 760 450 502611 && testColorNAND 785 410 c21c22; then # OFF: 502611 COLLECTED: c21c22
        inputTapSleep 830 430                                                                 # Chest 80
        inputTapSleep 580 600 0                                                               # Collect
    fi
    if testColorNAND -d "$DEFAULT_DELTA" 920 450 662611 && testColorNAND 950 410 6e1819; then # OFF: 662611 COLLECTED: 6e1819
        inputTapSleep 990 430                                                                 # Chest 100
        inputTapSleep 580 600                                                                 # Collect
    fi
}

# ##############################################################################
# Function Name : collectMail
# Descripton    : Collects mail
# Remark        : May break because "some resources have exceeded their maximum limit"
# ##############################################################################
collectMail() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "collectMail" >&2; fi
    # WARN: May break because "some resources have exceeded their maximum limit"
    if testColorOR -d "$DEFAULT_DELTA" 1020 580 e51f06; then # Red mark
        inputTapSleep 960 630                                # Mail
        inputTapSleep 790 1470                               # Collect all
        inputTapSleep 110 1850                               # Return
        inputTapSleep 110 1850                               # Return
    else
        printInColor "INFO" "No mail to collect."
    fi
    verifyHEX 20 1775 d49a61 "Collected Mail." "Failed to collect Mail."
}

# ##############################################################################
# Function Name : collectMerchants
# Descripton    : Collects Daily/Weekly/Monthly from the merchants page
# Remark        : Breaks if a pop-up message shows up
# ##############################################################################
collectMerchants() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "collectMerchants" >&2; fi
    inputTapSleep 120 300 3 # Merchants
    # WARN: Breaks if a pop-up message shows up
    inputTapSleep 510 1820 # Merchant Ship

    if testColorNAND 375 940 0b080a; then # Checks for Special Daily Bundles
        inputTapSleep 200 1200 1          # Free
    else
        inputTapSleep 200 750 1 # Free
    fi
    inputTapSleep 550 300 1 # Collect rewards

    if testColorOR -d "$DEFAULT_DELTA" 430 1530 e51f06; then # Check if red mark - Weekly Deals
        inputTapSleep 280 1620 1                             # Weekly Deals
        if testColorNAND 375 940 050a0f; then                # Checks for Special Weekly Bundles
            inputTapSleep 200 1200 1                         # Free
        else
            inputTapSleep 200 750 1 # Free
        fi
        inputTapSleep 550 300 1 # Collect rewards
    else
        printInColor "INFO" "No weekly reward to collect."
    fi

    if testColorOR -d "$DEFAULT_DELTA" 610 1530 ed2102; then # Check if red mark - Monthly Deals
        inputTapSleep 460 1620 1                             # Monthly Deals
        if testColorNAND 375 940 0b080a; then                # Checks for Special Monthly Bundles
            inputTapSleep 200 1200 1                         # Free
        else
            inputTapSleep 200 750 # Free
        fi
        inputTapSleep 550 300 1 # Collect rewards
    else
        printInColor "INFO" "No monthly reward to collect."
    fi

    inputTapSleep 70 1810 1
    verifyHEX 20 1775 d49a61 "Collected daily/weekly/monthly offer." "Failed to collect daily/weekly/monthly offer."
}

# ##############################################################################
# Section       : Test
# ##############################################################################

# ##############################################################################
# Function Name : doTest
# Description   : Print HEX then exit
# Args          : <X> <Y> [<COLOR_TO_COMPARE>] [<REPEAT>] [<SLEEP>]
# Output        : stdout color
# ##############################################################################
doTest() {
    _doTest_COUNT=0
    until [ "$_doTest_COUNT" -ge "${4:-3}" ]; do
        sleep "${5:-.5}"
        getColor -f "$1" "$2"
        if [ "$#" -ge 3 ] && [ "${3:-""}" != "" ]; then
            printInColor "DEBUG" "doTest [${cPurple}$1${cNc}, ${cPurple}$2${cNc}] > HEX: ${cCyan}$HEX${cNc} [Δ ${cCyan}$(HEXColorDelta "$HEX" "$3")${cNc}%]"
        else
            printInColor "DEBUG" "doTest [${cPurple}$1${cNc}, ${cPurple}$2${cNc}] > HEX: ${cCyan}$HEX${cNc}"
        fi
        _doTest_COUNT=$((_doTest_COUNT + 1)) # Increment
    done
    # exit
}

# ##############################################################################
# Function Name : tests
# Descripton    : Uncomment tests to run it. Will exit after tests done.
# Remark        : If you want to run multiple tests you need to comment exit in test()
# ##############################################################################
tests() {
    printInColor "INFO" "Starting tests... ($(date))"
    # doTest 450 1050 ef2118 # Random coords
    # doTest 550 740         # Check for Boss in Campaign
    # doTest 660 520         # Check for Solo Bounties HEX
    # doTest 650 570         # Check for Team Bounties HEX
    # doTest 700 670         # Check for chest collection HEX
    # doTest 715 1815        # Check if Soren is open
    # doTest 740 205         # Check if game is updating
    # doTest 270 1800        # Oak Inn Present Tab 1
    # doTest 410 1800        # Oak Inn Present Tab 2
    # doTest 550 1800        # Oak Inn Present Tab 3
    # doTest 690 1800        # Oak Inn Present Tab 4

    printInColor "INFO" "End of tests! ($(date))"
    exit
}

# Run test functions
# tests

if [ -n "$totest" ]; then
    test_x=$(echo "$totest" | cut -d ',' -f 1)
    test_y=$(echo "$totest" | cut -d ',' -f 2)
    test_color=$(echo "$totest" | cut -d ',' -f 3)
    test_repeat=$(echo "$totest" | cut -d ',' -f 4)
    test_time=$(echo "$totest" | cut -d ',' -f 5)

    doTest "$test_x" "$test_y" "$test_color" "$test_repeat" "$test_time"
    exit
fi

# ##############################################################################
# Section       : Script Start
# ##############################################################################

# ##############################################################################
# Function Name : init
# Descripton    : Init the script (close/start app, preload, wait for update)
# Remark        : Can be skipped if you are already in the game
# ##############################################################################
init() {
    closeApp
    sleep 0.5
    startApp
    sleep 10

    # Loop until the game has launched
    until testColorOR -f 450 1775 cc9261; do
        sleep 2
        # Close popup
        inputTapSleep 550 1850 .1
        #Check special popup that need to be closed with the cross
        testColorORTapSleep 1100 300 131517
    done

    # Preload graphics
    switchTab "Campaign" true
    sleep 3
    switchTab "Dark Forest"
    sleep 1
    switchTab "Ranhorn"
    sleep 1
    switchTab "Campaign" true
    sleep 1

    # Open menu for friends, etc
    inputTapSleep 970 380 0

    if testColorOR -f 740 205 ffc359; then # Check if game is being updated
        printInColor "INFO" "Game is being updated!" >&2
        if [ "$waitForUpdate" = true ]; then
            printInColor "INFO" "Waiting for game to finish update..."
            loopUntilNotRGB 5 740 205 ffc359
            printInColor "DONE" "Game finished updating."
        else
            printInColor "WARN" "Not waiting for update to finish." >&2
        fi
    fi
}

# ##############################################################################
# Function Name : run
# Descripton    : Run the script based on config
# ##############################################################################
run() {
    if [ "$hasEnded" = true ]; then return 0; fi # if the script has restarted we need a way to stop looping at the end.

    # CAMPAIGN TAB
    switchTab "Campaign"
    if checkToDo doLootAfkChest; then lootAfkChest; fi
    if checkToDo doChallengeBoss; then challengeBoss; fi
    if checkToDo doFastRewards; then fastRewards; fi
    if checkToDo doCollectFriendsAndMercenaries; then collectFriendsAndMercenaries; fi
    if checkToDo doLootAfkChest2; then lootAfkChest; fi

    # DARK FOREST TAB
    switchTab "Dark Forest"
    if checkToDo doSoloBounties; then
        soloBounties
        if checkToDo doTeamBounties; then teamBounties; fi
    elif checkToDo doTeamBounties; then teamBounties true; fi
    if checkToDo doArenaOfHeroes; then
        arenaOfHeroes
        if checkToDo doLegendsTournament; then legendsTournament; fi
    elif checkToDo doLegendsTournament; then legendsTournament true; fi
    if checkToDo doKingsTower; then kingsTower; fi

    # RANHORN TAB
    switchTab "Ranhorn"
    if checkToDo doGuildHunts; then
        guildHunts
        if checkToDo doTwistedRealmBoss; then twistedRealmBoss; fi
    elif checkToDo doTwistedRealmBoss; then twistedRealmBoss true; fi
    if checkToDo doBuyFromStore; then
        if [ "$testServer" = true ]; then
            buyFromStore_test
        else buyFromStore; fi
    fi
    if checkToDo doStrengthenCrystal; then strengthenCrystal; fi
    if checkToDo doTempleOfAscension; then templeOfAscension; fi
    if checkToDo doCompanionPointsSummon; then nobleTavern; fi
    if checkToDo doCollectOakPresents; then oakInnSpeedy; fi

    # END
    if checkToDo doCollectQuestChests; then collectQuestChests; fi
    if checkToDo doCollectMail; then collectMail; fi
    if checkToDo doCollectMerchantFreebies; then collectMerchants; fi
    # Ends at given location
    sleep 1
    checkWhereToEnd

    hasEnded=true
}

printInColor "INFO" "Starting script... ($(date))"
if [ "$DEBUG" -gt 0 ]; then printInColor "INFO" "Debug: ${cBlue}ON${cNc} [${cCyan}$DEBUG${cNc}]"; fi
if [ "$forceFightCampaign" = true ]; then printInColor "INFO" "Fight Campaign: ${cBlue}ON${cNc}"; else printInColor "INFO" "Fight Campaign: ${cBlue}OFF${cNc}"; fi
if [ "$forceWeekly" = true ]; then printInColor "INFO" "Weekly: ${cBlue}ON${cNc}"; else printInColor "INFO" "Weekly: ${cBlue}OFF${cNc}"; fi
if [ "$testServer" = true ]; then printInColor "INFO" "Test server: ${cBlue}ON${cNc}"; fi

# Events
if [ "$eventHoe" = true ]; then activeEvents="${activeEvents}| Heroes of Esperia |"; fi
if [ -n "$activeEvents" ]; then printInColor "INFO" "Active event(s): ${cBlue}${activeEvents}${cNc}"; fi

echo
init
run

echo
printInColor "INFO" "End of script! ($(date))"
exit
