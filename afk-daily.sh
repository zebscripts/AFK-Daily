#!/system/bin/sh
# ##############################################################################
# Script Name   : afk-daily.sh
# Description   : Script automating daily
# Args          : <SCREENSHOTLOCATION> <forceFightCampaign> <forceWeekly> <testServer> <DEBUG>
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
pvpEvent=false  # Set to `true` if "Heroes of Esperia" event is live
totalAmountOakRewards=3

# Do not modify
HEX=00000000
oakRes=0
forceFightCampaign=false
forceWeekly=false
testServer=false
activeTab="Start"
screenshotRequired=true

if [ $# -gt 0 ]; then
    SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.dump"
    # SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.png"
    . "/$1/scripts/afk-arena/config.ini"
    forceFightCampaign=$2
    forceWeekly=$3
    testServer=$4
    DEBUG=${5:-$DEBUG}
else
    SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.dump"
    # SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.png"
    . "/storage/emulated/0/scripts/afk-arena/config.ini"
fi

# ##############################################################################
# Section       : Core Functions
# Description   : It's like a library of usefull functions
# ##############################################################################

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
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] getColor $*" >&2; fi
    for arg in "$@"; do
        shift
        case "$arg" in
        -f) screenshotRequired=true ;;
        *) set -- "$@" "$arg" ;;
        esac
    done
    takeScreenshot
    readHEX "$1" "$2"
    if [ "$DEBUG" -ge 1 ]; then echo "[DEBUG] getColor $* > HEX: $HEX" >&2; fi
}

# ##############################################################################
# Function Name : HEXColorDelta
# Args          : <COLOR1> <COLOR2>
# Output        : stdout [0 means same colors, 100 means opposite colors]
# Source        : https://github.com/kevingrillet/ShellUtils/blob/main/utils/utils_colors.sh
# ##############################################################################
HEXColorDelta() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: HEXColorDelta <COLOR1> <COLOR2>" >&2
        echo " 0 means same colors, 100 means opposite colors" >&2
        return
    fi
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] HEXColorDelta $*" >&2; fi
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
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] inputSwipe $*" >&2; fi
    input swipe "$1" "$2" "$3" "$4" "$5"
    screenshotRequired=true
}

# ##############################################################################
# Function Name : inputTapSleep
# Descripton    : input tap <X> <Y>, then SLEEP with default value DEFAULT_SLEEP
# Args          : <X> <Y> [<SLEEP>]
# ##############################################################################
inputTapSleep() {
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] inputTapSleep $*" >&2; fi
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
    if [ "$DEBUG" -ge 2 ]; then echo "[DEBUG] loopUntilNotRGB $*" >&2; fi
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
    if [ "$DEBUG" -ge 2 ]; then echo "[DEBUG] loopUntilRGB $*" >&2; fi
    sleep "$1"
    shift
    until testColorOR -f "$@"; do
        sleep 1
    done
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
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] takeScreenshot [screenshotRequired=$screenshotRequired]" >&2; fi
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
    if [ "$DEBUG" -ge 2 ]; then echo "[DEBUG] testColorNAND $*" >&2; fi
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
            return 1               # At the first color found NAND is break, return 1
        else
            if [ "$DEBUG" -ge 2 ] || [ "$_testColorNAND_max_delta" -gt "0" ]; then
                _testColorNAND_delta=$(HEXColorDelta "$HEX" "$i")
                echo "[DEBUG] testColorNAND $HEX != $i [Δ $_testColorNAND_delta%]" >&2
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
    if [ "$DEBUG" -ge 2 ]; then echo "[DEBUG] testColorOR $*" >&2; fi
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
            return 0               # At the first color found OR is break, return 0
        else
            if [ "$DEBUG" -ge 2 ] || [ "$_testColorOR_max_delta" -gt "0" ]; then
                _testColorOR_delta=$(HEXColorDelta "$HEX" "$i")
                if [ "$DEBUG" -ge 2 ]; then
                    echo "[DEBUG] testColorOR $HEX != $i [Δ $_testColorOR_delta%]" >&2
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
    if [ "$DEBUG" -ge 2 ]; then echo "[DEBUG] testColorORTapSleep $*" >&2; fi
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
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] verifyHEX $*" >&2; fi
    getColor "$1" "$2"
    if [ "$HEX" != "$3" ]; then
        echo "[ERROR] verifyHEX: Failure! Expected $3, but got $HEX instead. [Δ $(HEXColorDelta "$HEX" "$3")%]" >&2
        echo >&2
        echo "[ERROR] $5" >&2
        #exit
        echo "[INFO] Restarting"
        init
        run
    else
        echo "[OK] $4"
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
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] doAuto" >&2; fi
    testColorORTapSleep 760 1440 332b2b 0 # On:743b29 Off:332b2b
}

# ##############################################################################
# Function Name : doSpeed
# Descripton    : Click on x4 if not already enabled
# ##############################################################################
doSpeed() {
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] doSpeed" >&2; fi
    testColorORTapSleep 990 1440 332b2b 0 # On:743b2a Off:332b2b
}

# ##############################################################################
# Function Name : doSkip
# Descripton    : Click on skip if avaible
# ##############################################################################
doSkip() {
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] doSkip" >&2; fi
    testColorORTapSleep 760 1440 502e1d 0 # Exists: 502e1d
}

# ##############################################################################
# Function Name : waitBattleFinish
# Descripton    : Switches to another tab if required by config.
# Args          : <TAB_NAME> [<FORCE>]
#                   <TAB_NAME>: Campaign / Dark Forest / Ranhorn / Chat
#                   <FORCE>: true / false, default false
# ##############################################################################
switchTab() {
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] switchTab $* [activeTab=$activeTab]" >&2; fi
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
            [ "$doGuildHunts" = true ] ||
            [ "$doBuyFromStore" = true ] ||
            [ "$doStrengthenCrystal" = true ] ||
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
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] waitBattleFinish $*" >&2; fi
    sleep "$1"
    finished=false
    while [ $finished = false ]; do
        # First HEX local device, second bluestacks
        if testColorOR -f 560 350 b8894d b7894c; then # Victory
            battleFailed=false
            finished=true
        elif [ "$HEX" = '171932' ]; then # Failed
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
    if [ "$DEBUG" -ge 3 ]; then echo "[DEBUG] waitBattleStart" >&2; fi
    _waitBattleStart_count=0 # Max loops = 10 (10x.5s=5s max)
    # Check if pause button is present && less than 10 tries
    until testColorOR -f 110 1465 482f1f && [ $_waitBattleStart_count -lt 10 ]; do
        # Maybe pause button doesn't exist, so instead check for a skip button
        if testColorOR 760 1440 502e1d; then return; fi

        _waitBattleStart_count=$((_waitBattleStart_count + 1)) # Increment
        sleep .5
        # In case none were found, try again starting with the pause button
    done
}

# ##############################################################################
# Section       : Campaign
# ##############################################################################

# ##############################################################################
# Function Name : challengeBoss
# Descripton    : Challenges a boss in the campaign
# ##############################################################################
challengeBoss() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] challengeBoss" >&2; fi
    inputTapSleep 550 1650
    if testColorOR 550 740 f2d79f; then # Check if boss
        inputTapSleep 550 1450
    fi

    if [ "$forceFightCampaign" = "true" ]; then # Fight battle or not
        # Fight in the campaign because of Mythic Trick
        echo "[INFO] Fighting in the campaign $maxCampaignFights time(s) because of Mythic Trick."
        _challengeBoss_COUNT=0

        # Check for battle screen
        while testColorOR -f 20 1200 eaca95 && [ "$_challengeBoss_COUNT" -lt "$maxCampaignFights" ]; do
            inputTapSleep 550 1850 0 # Battle
            waitBattleStart
            doAuto
            doSpeed
            waitBattleFinish 10 # Wait until battle is over

            # Check battle result
            if [ "$battleFailed" = false ]; then     # Win
                if testColorOR 550 1670 e2dddc; then # Check for next stage
                    inputTapSleep 550 1670 6         # Next Stage
                    sleep 6

                    # TODO: Limited offers will fuck this part of the script up. I'm yet to find a way to close any possible offers.
                    # Tap top of the screen to close any possible Limited Offers
                    # inputTapSleep 550 75

                    if testColorOR 550 740 f2d79f; then # Check if boss
                        inputTapSleep 550 1450 5
                    fi
                else
                    inputTapSleep 550 1150 3 # Continue to next battle
                fi
            else # Loose
                # Try again
                inputTapSleep 550 1720 5

                _challengeBoss_COUNT=$((_challengeBoss_COUNT + 1)) # Increment
            fi
        done

        # Return to campaign
        inputTapSleep 60 1850 # Return

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
    verifyHEX 450 1775 cc9261 "Challenged boss in campaign." "Failed to fight boss in Campaign."
}

# ##############################################################################
# Function Name : collectFriendsAndMercenaries
# Descripton    : Collects and sends companion points, as well as auto lending mercenaries
# ##############################################################################
collectFriendsAndMercenaries() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] collectFriendsAndMercenaries" >&2; fi
    inputTapSleep 970 810 1                                  # Friends
    inputTapSleep 930 1600                                   # Send & Recieve
    if testColorOR -d "$DEFAULT_DELTA" 825 1750 df1909; then # Check if its necessary to send mercenaries
        inputTapSleep 720 1760                               # Short-Term
        inputTapSleep 990 190                                # Manage
        inputTapSleep 630 1590                               # Apply
        inputTapSleep 750 1410 1                             # Auto Lend
        inputTapSleep 70 1810 0                              # Return
    else
        echo "[WARN] No mercenaries to lend..."
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] fastRewards" >&2; fi
    if testColorOR -d "$DEFAULT_DELTA" 980 1620 ef1e05; then # check red dot to see if free fast reward is avaible
        inputTapSleep 950 1660 1
        inputTapSleep 710 1260
        inputTapSleep 560 1800 1
        inputTapSleep 400 1250
    else
        echo "[WARN] No free fast reward..."
    fi
    verifyHEX 450 1775 cc9261 "Fast rewards collected." "Failed to collect fast rewards."
}

# ##############################################################################
# Function Name : lootAfkChest
# Descripton    : Loots afk chest
# ##############################################################################
lootAfkChest() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] lootAfkChest" >&2; fi
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] arenaOfHeroes" >&2; fi
    inputTapSleep 740 1050 3
    if [ "$pvpEvent" = false ]; then
        inputTapSleep 550 450 3
    else
        inputTapSleep 550 900 3
    fi
    if testColorOR -d "$DEFAULT_DELTA" 1050 1770 fb1e0d; then # Red mark? old value: e52505 (d=5)
        inputTapSleep 1000 1800                               # Record
        inputTapSleep 980 410                                 # Close
    fi
    inputTapSleep 540 1800 # Challenge

    if testColorNAND 200 1800 382314 382214; then # Check for new season
        _arenaOfHeroes_COUNT=0
        until [ "$_arenaOfHeroes_COUNT" -ge "$totalAmountArenaTries" ]; do # Repeat a battle for as long as totalAmountArenaTries
            # Refresh
            # inputTapSleep 815 540

            # Fight specific opponent
            #                                Free         x1
            #  Opponent 1: 820 700      ->        a7f1b7
            #  Opponent 2: 820 870      ->  2eaab4      aff3c0
            #  Opponent 3: 820 1050     ->        a7f1b7
            #  Opponent 4: 820 1220     ->  2daab4      aff3c0
            #  Opponent 5: 820 1400     ->        aaf2bb
            case $arenaHeroesOpponent in
            1)
                if testColorOR 820 700 a7f1b7; then # Check if opponent exists
                    inputTapSleep 820 700 0         # Fight opponent
                else
                    # Refresh opponents and try to fight opponent $arenaHeroesOpponent
                    arenaOfHeroes_tapClosestOpponent 1
                fi
                ;;
            2)
                if testColorOR 820 870 2daab4 aff3c0; then # Check if opponent exists
                    inputTapSleep 820 870 0                # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 2 # Try to fight the closest opponent to 2
                fi
                ;;
            3)
                if testColorOR 820 1050 a7f1b7; then # Check if opponent exists
                    inputTapSleep 820 1050 0         # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 3 # Try to fight the closest opponent to 3
                fi
                ;;
            4)
                if testColorOR 820 1220 2daab4 aff3c0; then # Check if opponent exists
                    inputTapSleep 820 1220 0                # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 4 # Try to fight the closest opponent to 4
                fi
                ;;
            5)
                if testColorOR 820 1400 aaf2bb; then # Check if opponent exists
                    inputTapSleep 820 1400 0         # Fight opponent
                else
                    arenaOfHeroes_tapClosestOpponent 5 # Try to fight the closest opponent to 5
                fi
                ;;
            esac

            # Check if return value of tapClosesopponent is 0. If it is 0, then it means a battle has been found.
            res=$?
            if [ $res = 0 ]; then
                wait
                inputTapSleep 550 1850 0 # Battle
                waitBattleStart
                doSkip
                waitBattleFinish 2
                if [ "$battleFailed" = false ]; then
                    inputTapSleep 550 1550 # Collect
                fi
                inputTapSleep 550 1550 3 # Finish battle
            fi
            _arenaOfHeroes_COUNT=$((_arenaOfHeroes_COUNT + 1)) # Increment
        done

        inputTapSleep 1000 380
        sleep 4
    else
        echo "[WARN] Unable to fight in the Arena of Heroes because a new season is soon launching." >&2
    fi

    if [ "$doLegendsTournament" = false ]; then # Return to Tab if $doLegendsTournament = false
        inputTapSleep 70 1810
        inputTapSleep 70 1810
        verifyHEX 240 1775 d49a61 "Checked the Arena of Heroes out." "Failed to check the Arena of Heroes out."
    else
        inputTapSleep 70 1810
        verifyHEX 760 70 1f2d3a "Checked the Arena of Heroes out." "Failed to check the Arena of Heroes out."
    fi
}

# ##############################################################################
# Function Name : arenaOfHeroes_tapClosestOpponent
# Descripton    : Attempts to tap the closest Arena of Heroes opponent
# Args          : <OPPONENT>: 1/2/3/4/5
# Output        : If failed, return 1
# ##############################################################################
arenaOfHeroes_tapClosestOpponent() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] arenaOfHeroes_tapClosestOpponent $*" >&2; fi
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
            if testColorOR 820 700 a7f1b7; then inputTapSleep 820 700 0; else return 1; fi
            ;;
        2)
            # Check if opponent 2 exists and fight if true
            if testColorOR 820 870 2daab4 aff3c0; then inputTapSleep 820 870 0; else return 1; fi
            ;;
        3)
            # Check if opponent 3 exists and fight if true
            if testColorOR 820 1050 a7f1b7; then inputTapSleep 820 1050 0; else return 1; fi
            ;;
        4)
            # Check if opponent 4 exists and fight if true
            if testColorOR 820 1220 2daab4 aff3c0; then inputTapSleep 820 1220 0; else return 1; fi
            ;;
        5)
            # Check if opponent 5 exists and fight if true
            if testColorOR 820 1400 aaf2bb; then inputTapSleep 820 1400 0; else return 1; fi
            ;;
        esac
        ;;
    2)
        if testColorOR 820 700 a7f1b7; then # Check if opponent 1 exists
            inputTapSleep 820 700 0         # Fight opponent
        else
            arenaOfHeroes_tapClosestOpponent 1 # Try to fight the closest opponent to 2
        fi
        ;;
    3)
        if testColorOR 820 870 2daab4 aff3c0; then # Check if opponent 2 exists
            inputTapSleep 820 870 0                # Fight opponent
        else
            arenaOfHeroes_tapClosestOpponent 2 # Try to fight the closest opponent to 3
        fi
        ;;
    4)
        if testColorOR 820 1050 a7f1b7; then # Check if opponent 3 exists
            inputTapSleep 820 1050 0         # Fight opponent
        else
            arenaOfHeroes_tapClosestOpponent 3 # Try to fight the closest opponent to 4
        fi
        ;;
    5)
        if testColorOR 820 1220 2daab4 aff3c0; then # Check if opponent 4 exists
            inputTapSleep 820 1220 0                # Fight opponent
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] kingsTower" >&2; fi
    inputTapSleep 500 870 # King's Tower

    # Towers
    kingsTower_battle 550 900  # Main Tower
    kingsTower_battle 250 500  # Tower of Light
    kingsTower_battle 800 500  # The Brutal Citadel
    kingsTower_battle 250 1400 # The World Tree
    kingsTower_battle 800 1400 # The Forsaken Necropolis

    # Exit
    inputTapSleep 70 1810
    verifyHEX 240 1775 d49a61 "Battled at the Kings Tower." "Failed to battle at the Kings Tower."
}

# ##############################################################################
# Function Name : kingsTower_battle
# Descripton    : Battles in King's Towers
# Args          : <X> <Y>
# ##############################################################################
kingsTower_battle() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] kingsTower_battle $*" >&2; fi
    _kingsTower_battle_COUNT=0
    inputTapSleep "$1" "$2" 2 # Tap chosen tower

    # Check if inside tower
    if testColorOR 550 150 1a1212; then
        inputTapSleep 540 1350 # Challenge

        # Battle while less than maxKingsTowerFights & we haven't reached daily limit of 10 floors
        while [ "$_kingsTower_battle_COUNT" -lt "$maxKingsTowerFights" ] && testColorNAND -f 550 150 1a1212; do
            inputTapSleep 550 1850 0 # Battle
            waitBattleFinish 2

            # Check if win or lose battle
            if [ "$battleFailed" = false ]; then
                inputTapSleep 550 1850 4 # Collect
                inputTapSleep 550 170    # Tap on the top to close possible limited offer

                # TODO: Limited offers might screw this up. Tapping 550 170 might close an offer.
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
        if testColorOR 550 150 1a1212; then # In case still in tower, exit once more
            inputTapSleep 70 1810 0
        fi
        sleep 2
    fi
}

# ##############################################################################
# Function Name : legendsTournament
# Descripton    : Does the daily Legends tournament battles
# Args          : <START_FROM_TAB>: true / false
# ##############################################################################
legendsTournament() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] legendsTournament $*" >&2; fi
    if [ "$1" = true ]; then # Check if starting from tab or already inside activity
        inputTapSleep 740 1050
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 740 1050 1
    ## End of testing ##
    if [ "$pvpEvent" = false ]; then
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

    _legendsTournament_COUNT=0
    until [ "$_legendsTournament_COUNT" -ge "$totalAmountTournamentTries" ]; do # Repeat a battle for as long as totalAmountTournamentTries
        inputTapSleep 550 1840 4                                                # Challenge
        inputTapSleep 800 1140 4                                                # Third opponent
        inputTapSleep 550 1850 4                                                # Begin Battle
        # inputTapSleep 770 1470 4
        waitBattleStart
        doSkip
        sleep 4
        inputTapSleep 550 800 4                                    # Tap anywhere to close
        _legendsTournament_COUNT=$((_legendsTournament_COUNT + 1)) # Increment
    done

    inputTapSleep 70 1810
    inputTapSleep 70 1810
    verifyHEX 240 1775 d49a61 "Battled at the Legends Tournament." "Failed to battle at the Legends Tournament."
}

# ##############################################################################
# Function Name : soloBounties
# Descripton    : Starts Solo bounties
# ##############################################################################
soloBounties() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] soloBounties" >&2; fi
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] teamBounties $*" >&2; fi
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] buyFromStore" >&2; fi
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
    # TODO: check yellow
    if [ "$buyStoreAmplifyingEmblem" = true ] && testColorOR -d "$DEFAULT_DELTA" 180 1430 d8995d; then
        buyFromStore_buyItem 180 1430
    fi
    # TODO: Buy Elite Hero Soulstone
    if [ "$buyStoreSoulstone" = true ]; then                    # Soulstone (widh 90 diamonds)
        if testColorOR -d "$DEFAULT_DELTA" 900 850 c6a3e6; then # row 1, item 4
            buyFromStore_buyItem 900 850
        fi
        if testColorOR -d "$DEFAULT_DELTA" 660 850 a775ae; then # row 1, item 3
            buyFromStore_buyItem 660 850
        fi
        if testColorOR -d "$DEFAULT_DELTA" 420 850 000000; then # row 1, item 2
            buyFromStore_buyItem 420 850
        fi
    fi
    if [ "$forceWeekly" = true ]; then
        # Weekly - Purchase an item from the Guild Store once (check red dot first row for most useful item)
        if [ "$buyWeeklyGuild" = true ]; then
            inputTapSleep 530 1810                                  # Guild Store
            if testColorOR -d "$DEFAULT_DELTA" 250 740 ea1c09; then # row 1, item 1
                buyFromStore_buyItem 180 810
            elif testColorOR -d "$DEFAULT_DELTA" 500 740 ed240f; then # row 1, item 2
                buyFromStore_buyItem 420 810
            elif testColorOR -d "$DEFAULT_DELTA" 740 740 f51f06; then # row 1, item 3
                buyFromStore_buyItem 660 810
            elif testColorOR -d "$DEFAULT_DELTA" 980 740 f12f1e; then # row 1, item 4
                buyFromStore_buyItem 900 810
            else
                buyFromStore_buyItem 180 810
            fi
        fi
        # TODO: Weekly - Purchase an item or hero from the Labyrinth store once
        if [ "$buyWeeklyLabyrinth" = true ]; then
            inputTapSleep 1020 1810          # Labyrinth Store
            inputSwipe 1050 1600 1050 750 50 # Swipe all the way down
            wait
            if testColorOR -d "$DEFAULT_DELTA" 900 1500 000000; then # row 6, item 4 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 900 1500
            elif testColorOR -d "$DEFAULT_DELTA" 660 1500 000000; then # row 6, item 3 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 660 1500
            elif testColorOR -d "$DEFAULT_DELTA" 420 1500 000000; then # row 6, item 2 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 420 1500
            elif testColorOR -d "$DEFAULT_DELTA" 180 1500 8fdbf4; then # row 6, item 1 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
                buyFromStore_buyItem 180 1500
            elif testColorOR -d "$DEFAULT_DELTA" 900 1200 88d8ff; then # row 5, item 4 > 120 Rare Hero Soulstone / 4800 Labyrinth Tokens
                buyFromStore_buyItem 900 1200
            elif testColorOR -d "$DEFAULT_DELTA" 660 1200 67d2fc; then # row 5, item 3 > 120 Rare Hero Soulstone / 4800 Labyrinth Tokens
                buyFromStore_buyItem 660 1200
            else
                echo "[INFO] Can't buy item from Labyrinth store"
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] buyFromStore_buyItem $*" >&2; fi
    inputTapSleep "$1" "$2" 1 # Item
    inputTapSleep 550 1540 1  # Purchase
    inputTapSleep 550 1700    # Close popup
}

# ##############################################################################
# Function Name : guildHunts
# Descripton    : Battles against Guild boss Wrizz
# ##############################################################################
guildHunts() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] guildHunts" >&2; fi
    inputTapSleep 380 360 10

    if testColorOR 380 500 793929; then # Check for fortune chest
        inputTapSleep 560 1300
        inputTapSleep 540 1830
    fi
    wait

    inputTapSleep 290 860 3
    guildHunts_quickBattle
    inputTapSleep 970 890 1              # Soren
    if testColorOR 715 1815 8ae5c4; then # If Soren is open
        guildHunts_quickBattle
    elif [ "$canOpenSoren" = true ]; then    # If Soren is closed
        if testColorOR 580 1753 fae0ac; then # If soren is "openable"
            inputTapSleep 550 1850
            inputTapSleep 700 1250 1
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
# ##############################################################################
guildHunts_quickBattle() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] guildHunts_quickBattle" >&2; fi
    _guildHunts_quickBattle_COUNT=0
    # Check if possible to fight wrizz to secure totalAmountGuildBossTries -> Grey: a1a1a1 / Blue: 9de8be
    until [ "$_guildHunts_quickBattle_COUNT" -ge "$totalAmountGuildBossTries" ] || testColorOR 710 1840 a1a1a1; do
        if [ "$doGuildHuntsBattle" = true ]; then
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
            # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] nobleTavern" >&2; fi
    inputTapSleep 280 1370 3 # The Noble Tavern
    inputTapSleep 600 1820 1 # The noble tavern again

    #until testColorOR 890 850 f4e38e; do       # Looking for heart
    until testColorOR -d "$DEFAULT_DELTA" 875 835 fc9473; do # Looking for heart
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
# Function Name : oakInn
# Descripton    : Collect Oak Inn
# ##############################################################################
oakInn() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] oakInn" >&2; fi
    inputTapSleep 780 270 5 # Oak Inn

    _oakInn_COUNT=0
    until [ "$_oakInn_COUNT" -ge "$totalAmountOakRewards" ]; do
        inputTapSleep 1050 950   # Friends
        inputTapSleep 1025 400 5 # Top Friend
        sleep 5

        oakInn_tryCollectPresent
        if [ $oakRes = 0 ]; then # If return value is still 0, no presents were found at first friend
            # Switch friend and search again
            inputTapSleep 1050 950   # Friends
            inputTapSleep 1025 530 5 # Second friend

            oakInn_tryCollectPresent
            if [ $oakRes = 0 ]; then # If return value is again 0, no presents were found at second friend
                # Switch friend and search again
                inputTapSleep 1050 950   # Friends
                inputTapSleep 1025 650 5 # Third friend

                oakInn_tryCollectPresent
                if [ $oakRes = 0 ]; then # If return value is still freaking 0, I give up
                    echo "[WARN] Couldn't collect Oak Inn presents, sowy." >&2
                    break
                fi
            fi
        fi

        sleep 2
        _oakInn_COUNT=$((_oakInn_COUNT + 1)) # Increment
    done

    inputTapSleep 70 1810 3
    inputTapSleep 70 1810 0

    wait
    verifyHEX 20 1775 d49a61 "Attempted to collect Oak Inn presents." "Failed to collect Oak Inn presents."
}

# ##############################################################################
# Function Name : oakInn_presentTab
# Descripton    : Search available present tabs in Oak Inn
# ##############################################################################
oakInn_presentTab() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] oakInn_presentTab" >&2; fi
    oakInn_presentTabs=0
    if testColorOR 270 1800 c79663; then                  # 1 gift c79663
        oakInn_presentTabs=$((oakInn_presentTabs + 1000)) # Increment
    fi
    if testColorOR 410 1800 bb824f; then                 # 2 gift bb824f
        oakInn_presentTabs=$((oakInn_presentTabs + 200)) # Increment
    fi
    if testColorOR 550 1800 af6e3b; then                # 3 gift af6e3b
        oakInn_presentTabs=$((oakInn_presentTabs + 30)) # Increment
    fi
    if testColorOR 690 1800 b57b45; then               # 4 gift b57b45
        oakInn_presentTabs=$((oakInn_presentTabs + 4)) # Increment
    fi
}

# ##############################################################################
# Function Name : oakInn_searchPresent
# Descripton    : Searches for a "good" present in oak Inn
# ##############################################################################
oakInn_searchPresent() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] oakInn_searchPresent " >&2; fi
    inputSwipe 400 1600 400 310 50 # Swipe all the way down
    sleep 1

    if testColorOR 540 990 833f0e; then # 1 red 833f0e blue 903da0
        inputTapSleep 540 990 3         # Tap present
        inputTapSleep 540 1650 1        # Ok
        inputTapSleep 540 1650 0        # Collect reward
        oakRes=1
    else
        if testColorOR 540 800 a21a1a; then # 2 red a21a1a blue 9a48ab
            inputTapSleep 540 800 3
            inputTapSleep 540 1650 1 # Ok
            inputTapSleep 540 1650 0 # Collect reward
            oakRes=1
        else
            if testColorOR 540 610 aa2b27; then # 3 red aa2b27 blue b260aa
                inputTapSleep 540 610 3
                inputTapSleep 540 1650 1 # Ok
                inputTapSleep 540 1650 0 # Collect reward
                oakRes=1
            else
                if testColorOR 540 420 bc3f36; then # 4 red bc3f36 blue c58c7b
                    inputTapSleep 540 420 3
                    inputTapSleep 540 1650 1 # Ok
                    inputTapSleep 540 1650 0 # Collect reward
                    oakRes=1
                else
                    if testColorOR 540 220 bb3734; then # 5 red bb3734 blue 9442a5
                        inputTapSleep 540 220 3
                        inputTapSleep 540 1650 1 # Ok
                        inputTapSleep 540 1650 0 # Collect reward
                        oakRes=1
                    else # If no present found, search for other tabs
                        oakRes=0
                    fi
                fi
            fi
        fi
    fi
}

# ##############################################################################
# Function Name : oakInn_tryCollectPresent
# Descripton    : Tries to collect a present from one Oak Inn friend
# ##############################################################################
oakInn_tryCollectPresent() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] oakInn_tryCollectPresent" >&2; fi
    oakInn_searchPresent # Search for a "good" present
    if [ $oakRes = 0 ]; then
        oakInn_presentTab # If no present found, search for other tabs
        case $oakInn_presentTabs in
        0)
            oakRes=0
            ;;
        4)
            inputTapSleep 690 1800 3
            oakInn_searchPresent
            ;;
        30)
            inputTapSleep 550 1800 3
            oakInn_searchPresent
            ;;
        34)
            inputTapSleep 550 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 690 1800 3
                oakInn_searchPresent
            fi
            ;;
        200)
            inputTapSleep 410 1800 3
            oakInn_searchPresent
            ;;
        204)
            inputTapSleep 410 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 690 1800 3
                oakInn_searchPresent
            fi
            ;;
        230)
            inputTapSleep 410 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 550 1800 3
                oakInn_searchPresent
            fi
            ;;
        234)
            inputTapSleep 410 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 550 1800 3
                oakInn_searchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 690 1800 3
                    oakInn_searchPresent
                fi
            fi
            ;;
        1000)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            ;;
        1004)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 690 1800 3
                oakInn_searchPresent
            fi
            ;;
        1030)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 550 1800 3
                oakInn_searchPresent
            fi
            ;;
        1034)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 550 1800 3
                oakInn_searchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 690 1800 3
                    oakInn_searchPresent
                fi
            fi
            ;;
        1200)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 410 1800 3
                oakInn_searchPresent
            fi
            ;;
        1204)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 410 1800 3
                oakInn_searchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 690 1800 3
                    oakInn_searchPresent
                fi
            fi
            ;;
        1230)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 410 1800 3
                oakInn_searchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 550 1800 3
                    oakInn_searchPresent
                fi
            fi
            ;;
        1234)
            inputTapSleep 270 1800 3
            oakInn_searchPresent
            if [ $oakRes = 0 ]; then
                inputTapSleep 410 1800 3
                oakInn_searchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 550 1800 3
                    oakInn_searchPresent
                    if [ $oakRes = 0 ]; then
                        inputTapSleep 690 1800 3
                        oakInn_searchPresent
                    fi
                fi
            fi
            ;;
        esac
    fi
}

# ##############################################################################
# Function Name : strengthenCrystal
# Descripton    : Strenghen Crystal
# ##############################################################################
strengthenCrystal() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] strengthenCrystal" >&2; fi
    if testColorOR -d "$DEFAULT_DELTA" 870 1115 f31f06; then # If red circle
        inputTapSleep 760 1030 3                             # Resonating Crystal

        # Detect if free slot, and take it.
        testColorORTapSleep 620 1250 8ae9cf # Detected: 8ae9cf / Not: e4c38e

        inputTapSleep 550 1850               # Strenghen Crystal
        if testColorOR 700 1250 9aedc4; then # If Level up
            echo "[INFO] Level up..."
            inputTapSleep 700 1250 3 # Confirm level up window
            inputTapSleep 200 1850 1 # Close level up window
            inputTapSleep 200 1850   # Close gift window
        else
            inputTapSleep 200 1850 # Close level up window
        fi
        inputTapSleep 200 1850 .5 # Better safe than sorry
        inputTapSleep 70 1810     # Exit
    else
        echo "[WARN] Unable to strengthen the resonating Crystal."
    fi
    verifyHEX 20 1775 d49a61 "Strenghened resonating Crystal." "Failed to Strenghen Resonating Crystal."
}

# ##############################################################################
# Function Name : templeOfAscension
# Descripton    : Auto ascend heroes
# ##############################################################################
templeOfAscension() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] templeOfAscension" >&2; fi
    if testColorOR -d "$DEFAULT_DELTA" 450 1050 ef2118; then # If red circle
        inputTapSleep 280 960                                # Temple Of Ascension
        inputTapSleep 900 800                                # Auto Ascend
        inputTapSleep 550 1460                               # Confirm
        inputTapSleep 550 1810                               # Close
        inputTapSleep 70 1810                                # Exit
    else
        echo "[WARN] No heroes to ascend."
    fi

    wait
    verifyHEX 20 1775 d49a61 "Attempted to ascend heroes." "Failed to ascend heroes."
}

# ##############################################################################
# Function Name : twistedRealmBoss
# Descripton    : Battles against the Twisted Realm Boss
# Args          : <START_FROM_TAB>: true / false
# ##############################################################################
twistedRealmBoss() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] twistedRealmBoss $*" >&2; fi
    # TODO: Choose a formation (Would be dope!)
    if [ "$1" = true ]; then # Check if starting from tab or already inside activity
        inputTapSleep 380 360 10
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 380 360 10
    ## End of testing ##

    inputTapSleep 820 820

    if testColorOR 540 1220 9aedc1; then # Check if TR is being calculated
        echo "[WARN] Unable to fight in the Twisted Realm because it's being calculated." >&2
    else
        inputTapSleep 550 1850   # Twisted Realm
        inputTapSleep 550 1850 0 # Challenge
        waitBattleStart
        doAuto
        doSpeed

        # TODO: Maybe use the waitUntilbattleFinish() instead of loop here?
        loopUntilRGB 30 420 380 ca9c5d # Start checking for a finished Battle after 40 seconds
        wait
        inputTapSleep 550 800 3
        inputTapSleep 550 800
        # TODO: Repeat battle if variable says so
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
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] checkWhereToEnd" >&2; fi
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
        if [ "$pvpEvent" = false ]; then
            inputTapSleep 550 1370 0
        else
            inputTapSleep 550 1680 0
        fi
        ;;
    *)
        echo "[WARN] Unknown location to end script on. Ignoring..." >&2
        ;;
    esac
}

# ##############################################################################
# Function Name : collectQuestChests
# Descripton    : Collects quest chests (well, switch tab then call collectQuestChests_quick)
# ##############################################################################
collectQuestChests() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] collectQuestChests" >&2; fi
    # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
    inputTapSleep 960 250 # Quests
    collectQuestChests_quick

    inputTapSleep 650 1650 # Weeklies
    collectQuestChests_quick

    inputTapSleep 70 1650 1 # Return
    verifyHEX 20 1775 d49a61 "Collected daily and weekly quest chests." "Failed to collect daily and weekly quest chests."
}

# ##############################################################################
# Function Name : collectQuestChests_quick
# Descripton    : Collects quest chests
# ##############################################################################
collectQuestChests_quick() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] collectQuestChests_quick" >&2; fi
    # Collect Quests
    while testColorOR -d "$DEFAULT_DELTA" 700 670 7dfff1; do # Old value: 82fdf5
        inputTapSleep 930 680
    done

    if testColorNAND 350 380 54332b; then
        inputTapSleep 330 430   # Chest 20
        inputTapSleep 580 600 0 # Collect
    fi
    if testColorNAND 510 380 543323; then
        inputTapSleep 500 430   # Chest 40
        inputTapSleep 580 600 0 # Collect
    fi
    if testColorNAND 670 380 54331b; then
        inputTapSleep 660 430   # Chest 60
        inputTapSleep 580 600 0 # Collect
    fi
    if testColorNAND 830 380 533323; then
        inputTapSleep 830 430   # Chest 80
        inputTapSleep 580 600 0 # Collect
    fi
    if testColorNAND 1000 380 543323; then
        inputTapSleep 990 430 # Chest 100
        inputTapSleep 580 600 # Collect
    fi
}

# ##############################################################################
# Function Name : collectMail
# Descripton    : Collects mail
# ##############################################################################
collectMail() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] collectMail" >&2; fi
    # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
    if testColorOR -d "$DEFAULT_DELTA" 1020 580 e51f06; then # Red mark
        inputTapSleep 960 630                                # Mail
        inputTapSleep 790 1470                               # Collect all
        inputTapSleep 110 1850                               # Return
        inputTapSleep 110 1850                               # Return
    else
        echo "[WARN] No mail to collect."
    fi
    verifyHEX 20 1775 d49a61 "Collected Mail." "Failed to collect Mail."
}

# ##############################################################################
# Function Name : collectMerchants
# Descripton    : Collects Daily/Weekly/Monthly from the merchants page
# ##############################################################################
collectMerchants() {
    if [ "$DEBUG" -ge 4 ]; then echo "[DEBUG] collectMerchants" >&2; fi
    inputTapSleep 120 300 3 # Merchants
    inputTapSleep 510 1820  # Merchant Ship

    if testColorNAND 375 940 0b080a; then # Checks for Special Daily Bundles
        inputTapSleep 200 1200 1          # Free
    else
        inputTapSleep 200 750 1 # Free
    fi
    inputTapSleep 550 300 1 # Collect rewards

    if testColorOR -d "$DEFAULT_DELTA" 325 1530 fc260d; then # Check if red mark - Weekly Deals
        inputTapSleep 280 1620 1                             # Weekly Deals
        if testColorNAND 375 940 050a0f; then                # Checks for Special Weekly Bundles
            inputTapSleep 200 1200 1                         # Free
        else
            inputTapSleep 200 750 1 # Free
        fi
        inputTapSleep 550 300 1 # Collect rewards
    else
        echo "[WARN] No weekly reward to collect."
    fi

    if testColorOR -d "$DEFAULT_DELTA" 505 1530 000000; then # TODO: Check if red mark - Monthly Deals
        inputTapSleep 460 1620 1                             # Monthly Deals
        if testColorNAND 375 940 0b080a; then                # Checks for Special Monthly Bundles
            inputTapSleep 200 1200 1                         # Free
        else
            inputTapSleep 200 750 # Free
        fi
        inputTapSleep 550 300 1 # Collect rewards
    else
        echo "[WARN] No monthly reward to collect."
    fi

    inputTapSleep 70 1810 1
    verifyHEX 20 1775 d49a61 "Collected daily/weekly/monthly offer." "Failed to collect daily/weekly/monthly offer."
}

# ##############################################################################
# Section       : Test
# ##############################################################################

# ##############################################################################
# Function Name : Test
# Description   : Print HEX then exit
# Args          : <X> <Y> [<REPEAT>] [<SLEEP>]
# Output        : stdout color
# ##############################################################################
test() {
    _test_COUNT=0
    until [ "$_test_COUNT" -ge "${3:-3}" ]; do
        sleep "${4:-.5}"
        getColor -f "$1" "$2"
        echo "[TEST] [$1, $2] > HEX: $HEX"
        _test_COUNT=$((_test_COUNT + 1)) # Increment
    done
    # exit
}

# ##############################################################################
# Function Name : tests
# Descripton    : Uncomment tests to run it. Will exit after tests done.
# Remark        : If you want to run multiple tests you need to comment exit in test()
# ##############################################################################
tests() {
    # test 550 740                              # Check for Boss in Campaign
    # test 660 520                              # Check for Solo Bounties HEX
    # test 650 570                              # Check for Team Bounties HEX
    # test 700 670                              # Check for chest collection HEX
    # test 715 1815                             # Check if Soren is open
    # test 740 205                              # Check if game is updating
    # test 270 1800                             # Oak Inn Present Tab 1
    # test 410 1800                             # Oak Inn Present Tab 2
    # test 550 1800                             # Oak Inn Present Tab 3
    # test 690 1800                             # Oak Inn Present Tab 4

    # TODO: Replace 000000
    # Buy Elite Hero Soulstone
    # test 410 850 # Row 1, slot 2
    # test 650 850 # Row 1, slot 3
    # test 910 850 # Row 1, slot 4

    ## Next month
    # Check if red mark - Monthly Deals
    # test 505 1530
    # Weekly - Purchase an item or hero from the Labyrinth store once
    # test 900 1500 # row 6, item 4 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
    # test 660 1500 # row 6, item 3 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
    # test 420 1500 # row 6, item 2 >  60 Rare Hero Soulstone / 2400 Labyrinth Tokens
    exit
}

# Run test functions
# tests

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
    loopUntilRGB 1 450 1775 cc9261
    wait

    # Open menu for friends, etc
    inputTapSleep 970 380 0

    # Preload graphics
    switchTab "Campaign" true
    sleep 3
    switchTab "Dark Forest" true
    sleep 1
    switchTab "Ranhorn" true
    sleep 1
    switchTab "Campaign" true

    if testColorOR -f 740 205 ffc359; then # Check if game is being updated
        echo "[WARN] Game is being updated!" >&2
        if [ "$waitForUpdate" = true ]; then
            echo "[INFO] Waiting for game to finish update..."
            loopUntilNotRGB 5 740 205 ffc359
            echo "[OK]: Game finished updating."
        else
            echo "[WARN]: Not waiting for update to finish." >&2
        fi
    fi
}

# ##############################################################################
# Function Name : run
# Descripton    : Run the script based on config
# ##############################################################################
run() {
    # CAMPAIGN TAB
    switchTab "Campaign"
    if [ "$doLootAfkChest" = true ]; then lootAfkChest; fi # Will be false after 2nd uses
    if [ "$doChallengeBoss" = true ]; then
        doChallengeBoss=false
        challengeBoss
    fi
    if [ "$doFastRewards" = true ]; then
        doFastRewards=false
        fastRewards
    fi
    if [ "$doCollectFriendsAndMercenaries" = true ]; then
        doCollectFriendsAndMercenaries=false
        collectFriendsAndMercenaries
    fi
    if [ "$doLootAfkChest" = true ]; then
        doLootAfkChest=false
        lootAfkChest
    fi

    # DARK FOREST TAB
    switchTab "Dark Forest"
    if [ "$doSoloBounties" = true ]; then
        doSoloBounties=false
        soloBounties
        if [ "$doTeamBounties" = true ]; then
            doTeamBounties=false
            teamBounties
        fi
    elif [ "$doTeamBounties" = true ]; then
        doTeamBounties=false
        teamBounties true
    fi
    if [ "$doArenaOfHeroes" = true ]; then
        doArenaOfHeroes=false
        arenaOfHeroes
        if [ "$doLegendsTournament" = true ]; then
            doLegendsTournament=false
            legendsTournament
        fi
    elif [ "$doLegendsTournament" = true ]; then
        doLegendsTournament=false
        legendsTournament true
    fi
    if [ "$doKingsTower" = true ]; then
        doKingsTower=false
        kingsTower
    fi

    # RANHORN TAB
    switchTab "Ranhorn"
    if [ "$doGuildHunts" = true ]; then
        doGuildHunts=false
        guildHunts
        if [ "$doTwistedRealmBoss" = true ]; then
            doTwistedRealmBoss=false
            twistedRealmBoss
        fi
    elif [ "$doTwistedRealmBoss" = true ]; then
        doTwistedRealmBoss=false
        twistedRealmBoss true
    fi
    if [ "$doBuyFromStore" = true ]; then
        doBuyFromStore=false
        buyFromStore
    fi
    if [ "$doStrengthenCrystal" = true ]; then
        doStrengthenCrystal=false
        strengthenCrystal
    fi
    if [ "$doTempleOfAscension" = true ]; then
        doTempleOfAscension=false
        templeOfAscension
    fi
    if [ "$doCompanionPointsSummon" = true ]; then
        doCompanionPointsSummon=false
        nobleTavern
    fi
    if [ "$doCollectOakPresents" = true ]; then
        doCollectOakPresents=false
        oakInn
    fi

    # END
    if [ "$doCollectQuestChests" = true ]; then
        doCollectQuestChests=false
        collectQuestChests
    fi
    if [ "$doCollectMail" = true ]; then
        doCollectMail=false
        collectMail
    fi
    if [ "$doCollectMerchantFreebies" = true ]; then
        doCollectMerchantFreebies=false
        collectMerchants
    fi

    # Ends at given location
    sleep 1
    checkWhereToEnd
}

echo "[INFO] Starting script... ($(date))"
if [ "$forceFightCampaign" = true ]; then
    echo "[INFO] Fight Campaign is ON"
fi
if [ "$forceWeekly" = true ]; then
    echo "[INFO] Weekly is ON"
fi
if [ "$DEBUG" -gt 0 ]; then
    echo "[INFO] Debug is ON [$DEBUG]"
fi
echo

init
run

echo
echo "[INFO] End of script! ($(date))"
exit
