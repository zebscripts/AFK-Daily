#!/system/bin/sh

# --- Variables --- #
# Probably you don't need to modify this. Do it if you know what you're doing, I won't blame you (unless you blame me).
DEVICEWIDTH=1080
DEBUG=4
# DEBUG  = 0    Show no debug
# DEBUG >= 1    Show getColor calls > $RGB value
# DEBUG >= 2    Show test calls
# DEBUG >= 3    Show all core functions calls
# DEBUG >= 4    Show all functions calls
# DEBUG >= 9    Show tap calls
DEFAULT_SLEEP=2                                 # equivalent to wait
pvpEvent=false                                  # Set to `true` if "Heroes of Esperia" event is live
totalAmountOakRewards=3

# Do not modify
RGB=00000000
oakRes=0
forceFightCampaign=false
if [ $# -gt 0 ]; then
    SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.dump"
    # SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.png"
    # source "/$1/scripts/afk-arena/config.sh"
    . "/$1/scripts/afk-arena/config.sh"
    forceFightCampaign=$2
else
    SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.dump"
    # SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.png"
    # source "/storage/emulated/0/scripts/afk-arena/config.sh"
    . "/storage/emulated/0/scripts/afk-arena/config.sh"
fi

# --- Functions --- #
# Test function: take screenshot, get rgb, exit. Params: X, Y, amountTimes, waitTime
test() {
    _test_COUNT=0
    until [ "$_test_COUNT" -ge "$3" ]; do
        sleep "$4"
        getColor "$1" "$2"
        echo "RGB: $RGB"
        _test_COUNT=$((_test_COUNT + 1))        # Increment
    done
    exit
}

# Default wait time for actions
wait() {
    sleep 2
}

# Starts the app
startApp() {
    monkey -p com.lilithgame.hgame.gp 1 >/dev/null 2>/dev/null
    sleep 1
    disableOrientation
}

# Closes the app
closeApp() {
    am force-stop com.lilithgame.hgame.gp >/dev/null 2>/dev/null
}

# Switches between last app
switchApp() {
    input keyevent KEYCODE_APP_SWITCH
    input keyevent KEYCODE_APP_SWITCH
}

# Disables automatic orientation
disableOrientation() {
    content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
}

# Takes a screenshot and saves it
takeScreenshot() {
    screencap "$SCREENSHOTLOCATION"
}

# Gets pixel color. Params: X, Y
readRGB() {
    offset=$((DEVICEWIDTH*$2+$1+3))
    RGB=$(dd if="$SCREENSHOTLOCATION" bs=4 skip="$offset" count=1 2>/dev/null | hexdump -C)
    RGB=${RGB:9:9}
    RGB="${RGB// /}"
    # echo "[INFO] X: "$1" Y: "$2" RGB: $RGB"
}

# Sets RGB. Params: X, Y
getColor() {
    takeScreenshot
    readRGB "$1" "$2"
    if [ $DEBUG -ge 1 ]; then echo "[DEBUG] getColor $* > RGB: $RGB" >&2; fi
}

# Verifies if X and Y have specific RGB. Params: X, Y, RGB, MessageSuccess, MessageFailure
verifyRGB() {
    getColor "$1" "$2"
    if [ "$RGB" != "$3" ]; then
        echo "[ERROR] VerifyRGB: Failure! Expected $3, but got $RGB instead."
        echo
        echo "[ERROR] $5"
        exit
    else
        echo "[OK] $4"
    fi
}

# inputTapSleep <X> <Y> <SLEEP>
# SLEEP default value is DEFAULT_SLEEP
inputTapSleep() {
    if [ $DEBUG -ge 9 ]; then echo "[DEBUG] inputTapSleep $*" >&2; fi
    input tap "$1" "$2"                         # tap
    sleep "${3:-$DEFAULT_SLEEP}"                # sleep
}

# testColorOR <X> <Y> <COLOR> [<COLOR> ...]
# if true, return 1, else 0
testColorOR() {
    if [ $DEBUG -ge 2 ]; then echo "[DEBUG] testColorOR $*" >&2; fi
    getColor "$1" "$2"                          # looking for color
    i=3
    while [ $i -le $# ]; do                     # loop in colors
        if [ "$RGB" = "${!i}" ]; then           # color found?                  # alternative: eval "echo \"\$$i\""
            result=1                            # At the first color found OR is break, result 1
            break
        fi
        i=$((i+1))
    done
    echo "${result:-0}"                         # print result, if no result > result 0
}

# testColorNAND <X> <Y> <COLOR> [<COLOR> ...]
# if true, return 1, else 0
testColorNAND() {
    if [ $DEBUG -ge 2 ]; then echo "[DEBUG] testColorNAND $*" >&2; fi
    getColor "$1" "$2"                          # looking for color
    i=3
    while [ $i -le $# ]; do                     # loop in colors
        if [ "$RGB" = "${!i}" ]; then           # color found?                  # alternative: eval "echo \"\$$i\""
            result=0                            # At the first color found NAND is break, result 0
            break
        fi
        i=$((i+1))
    done
    echo "${result:-1}"                         # print result, if no result > result 1
}

# testColorORTapSleep <X> <Y> <COLOR> <SLEEP>
# SLEEP default value is DEFAULT_SLEEP
# if true, tap, else do nothing
testColorORTapSleep() {
    if [ $DEBUG -ge 2 ]; then echo "[DEBUG] testColorORTapSleep $*" >&2; fi
    if [ "$(testColorOR "$1" "$2" "$3")" = "1" ];then                           # if color found
        inputTapSleep  "$1" "$2" "${4:-$DEFAULT_SLEEP}"                         # tap & sleep
    fi
}

# Switches to another tab. Params: <Tab name> <force>
switchTab() {
    if [ $DEBUG -ge 3 ]; then echo "[DEBUG] switchTab $*" >&2; fi
    case "$1" in
        "Campaign")
            if [ "${2:-false}" = true ] || \
               [ "$doLootAfkChest" = true ] || \
               [ "$doChallengeBoss" = true ] || \
               [ "$doFastRewards" = true ] || \
               [ "$doCollectFriendsAndMercenaries" = true ] || \
               [ "$doLootAfkChest" = true ]
            then
                inputTapSleep 550 1850
                verifyRGB 450 1775 cc9261 "Switched to the Campaign Tab." "Failed to switch to the Campaign Tab."
            fi
            ;;
        "Dark Forest")
            if [ "${2:-false}" = true ] || \
               [ "$doSoloBounties" = true ] || \
               [ "$doTeamBounties" = true ] || \
               [ "$doArenaOfHeroes" = true ] || \
               [ "$doLegendsTournament" = true ] || \
               [ "$doKingsTower" = true ]
            then
                inputTapSleep 300 1850
                verifyRGB 240 1775 d49a61 "Switched to the Dark Forest Tab." "Failed to switch to the Dark Forest Tab."
            fi
            ;;
        "Ranhorn")
            if [ "${2:-false}" = true ] || \
               [ "$doGuildHunts" = true ] || \
               [ "$doTwistedRealmBoss" = true ] || \
               [ "$doGuildHunts" = true ] || \
               [ "$doBuyFromStore" = true ] || \
               [ "$doStrengthenCrystal" = true ] || \
               [ "$doCompanionPointsSummon" = true ] || \
               [ "$doCollectOakPresents" = true ]
            then
                inputTapSleep 110 1850
                verifyRGB 20 1775 d49a61 "Switched to the Ranhorn Tab." "Failed to switch to the Ranhorn Tab."
            fi
            ;;
        "Chat")
            inputTapSleep 970 1850
            verifyRGB 550 1690 ffffff "Switched to the Chat Tab." "Failed to switch to the Chat Tab."
            ;;
    esac
}

# Loops until RGB is not equal. Params: Seconds, X, Y, RGB
loopUntilRGB() {
    if [ $DEBUG -ge 2 ]; then echo "[DEBUG] loopUntilRGB $*" >&2; fi
    sleep "$1"
    while [ "$(testColorNAND "$2" "$3" "$4")" = "1" ];do
        sleep 1
    done
}

# Loops until RGB is equal. Params: Seconds, X, Y, RGB
loopUntilNotRGB() {
    if [ $DEBUG -ge 2 ]; then echo "[DEBUG] loopUntilNotRGB $*" >&2; fi
    sleep "$1"
    while [ "$(testColorOR "$2" "$3" "$4")" = "1" ];do
        sleep 1
    done
}

# Waits until a battle has ended. Params: Seconds
waitBattleFinish() {
    if [ $DEBUG -ge 3 ]; then echo "[DEBUG] waitBattleFinish $*" >&2; fi
    sleep "$1"
    finished=false
    while [ $finished = false ]; do
        # First RGB local device, second bluestacks
        if [ "$(testColorOR 560 350 b8894d b7894c)" = "1" ];then                # Victory
            battleFailed=false
            finished=true
        elif [ "$RGB" = '171932' ]; then                                        # Failed
            battleFailed=true
            finished=true
        # First RGB local device, second bluestacks
        elif [ "$RGB" = "45331d" ] || [ "$RGB" = "44331c" ]; then               # Victory with reward
            battleFailed=false
            finished=true
        fi
        sleep 1
    done
}

# Buys an item from the Store. Params: X, Y
buyStoreItem() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] buyStoreItem $*" >&2; fi
    inputTapSleep "$1" "$2" 1
    inputTapSleep 550 1540 1
    inputTapSleep 550 1700 0
}

# Searches for a "good" present in oak Inn
oakSearchPresent() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] oakSearchPresent " >&2; fi
    input swipe 400 1600 400 310 50             # Swipe all the way down
    sleep 1

    if [ "$(testColorOR 540 990 833f0e)" = "1" ];then                           # 1 red 833f0e blue 903da0
        inputTapSleep 540 990 3                 # Tap present
        inputTapSleep 540 1650 1                # Ok
        inputTapSleep 540 1650 0                # Collect reward
        oakRes=1
    else
        if [ "$(testColorOR 540 800 a21a1a)" = "1" ];then                       # 2 red a21a1a blue 9a48ab
            inputTapSleep 540 800 3
            inputTapSleep 540 1650 1            # Ok
            inputTapSleep 540 1650 0            # Collect reward
            oakRes=1
        else
            if [ "$(testColorOR 540 610 aa2b27)" = "1" ];then                   # 3 red aa2b27 blue b260aa
                inputTapSleep 540 610 3
                inputTapSleep 540 1650 1        # Ok
                inputTapSleep 540 1650 0        # Collect reward
                oakRes=1
            else
                if [ "$(testColorOR 540 420 bc3f36)" = "1" ];then               # 4 red bc3f36 blue c58c7b
                    inputTapSleep 540 420 3
                    inputTapSleep 540 1650 1                                    # Ok$
                    inputTapSleep 540 1650 0                                    # Collect reward
                    oakRes=1
                else
                    if [ "$(testColorOR 540 220 bb3734)" = "1" ];then           # 5 red bb3734 blue 9442a5
                        inputTapSleep 540 220 3
                        inputTapSleep 540 1650 1                                # Ok
                        inputTapSleep 540 1650 0                                # Collect reward
                        oakRes=1
                    else                                                        # If no present found, search for other tabs
                        oakRes=0
                    fi
                fi
            fi
        fi
    fi
}

# Search available present tabs in Oak Inn
oakPresentTab() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] oakPresentTab" >&2; fi
    oakPresentTabs=0
    if [ "$(testColorOR 270 1800 c79663)" = "1" ];then                          # 1 gift c79663
        oakPresentTabs=$((oakPresentTabs + 1000))                               # Increment
    fi
    if [ "$(testColorOR 410 1800 bb824f)" = "1" ];then                          # 2 gift bb824f
        oakPresentTabs=$((oakPresentTabs + 200))                                # Increment
    fi
    if [ "$(testColorOR 550 1800 af6e3b)" = "1" ];then                          # 3 gift af6e3b
        oakPresentTabs=$((oakPresentTabs + 30))                                 # Increment
    fi
    if [ "$(testColorOR 690 1800 b57b45)" = "1" ];then                          # 4 gift b57b45
        oakPresentTabs=$((oakPresentTabs + 4))                                  # Increment
    fi
}

# Tries to collect a present from one Oak Inn friend
oakTryCollectPresent() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] oakTryCollectPresent" >&2; fi
    oakSearchPresent                            # Search for a "good" present
    if [ $oakRes = 0 ]; then
        oakPresentTab                           # If no present found, search for other tabs
        case $oakPresentTabs in
            0)
                oakRes=0
                ;;
            4)
                inputTapSleep 690 1800 3
                oakSearchPresent
                ;;
            30)
                inputTapSleep 550 1800 3
                oakSearchPresent
                ;;
            34)
                inputTapSleep 550 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 690 1800 3
                    oakSearchPresent
                fi
                ;;
            200)
                inputTapSleep 410 1800 3
                oakSearchPresent
                ;;
            204)
                inputTapSleep 410 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 690 1800 3
                    oakSearchPresent
                fi
                ;;
            230)
                inputTapSleep 410 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 550 1800 3
                    oakSearchPresent
                fi
                ;;
            234)
                inputTapSleep 410 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 550 1800 3
                    oakSearchPresent
                    if [ $oakRes = 0 ]; then
                        inputTapSleep 690 1800 3
                        oakSearchPresent
                    fi
                fi
                ;;
            1000)
                inputTapSleep 270 1800 3
                oakSearchPresent
                ;;
            1004)
                inputTapSleep 270 1800 3        # TODO: MISSING Y
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 690 1800 3
                    oakSearchPresent
                fi
                ;;
            1030)
                inputTapSleep 270 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 550 1800 3
                    oakSearchPresent
                fi
                ;;
            1034)
                inputTapSleep 270 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 550 1800 3
                    oakSearchPresent
                    if [ $oakRes = 0 ]; then
                        inputTapSleep 690 1800 3
                        oakSearchPresent
                    fi
                fi
                ;;
            1200)
                inputTapSleep 270 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 410 1800 3
                    oakSearchPresent
                fi
                ;;
            1204)
                inputTapSleep 270 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 410 1800 3
                    oakSearchPresent
                    if [ $oakRes = 0 ]; then
                        inputTapSleep 690 1800 3
                        oakSearchPresent
                    fi
                fi
                ;;
            1230)
                inputTapSleep 270 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 410 1800 3
                    oakSearchPresent
                    if [ $oakRes = 0 ]; then
                        inputTapSleep 550 1800 3
                        oakSearchPresent
                    fi
                fi
                ;;
            1234)
                inputTapSleep 270 1800 3
                oakSearchPresent
                if [ $oakRes = 0 ]; then
                    inputTapSleep 410 1800 3
                    oakSearchPresent
                    if [ $oakRes = 0 ]; then
                        inputTapSleep 550 1800 3
                        oakSearchPresent
                        if [ $oakRes = 0 ]; then
                            inputTapSleep 690 1800 3
                            oakSearchPresent
                        fi
                    fi
                fi
                ;;
        esac
    fi
}

# Checks where to end the script
checkWhereToEnd() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] checkWhereToEnd" >&2; fi
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
            echo "[WARN] Unknown location to end script on. Ignoring..."
            ;;
    esac
}

# Repeat a battle for as long as totalAmountArenaTries
quickBattleGuildBosses() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] quickBattleGuildBosses" >&2; fi
    _quickBattleGuildBosses_COUNT=0
    until [ "$_quickBattleGuildBosses_COUNT" -ge "$totalAmountGuildBossTries" ]; do
        inputTapSleep 710 1840
        inputTapSleep 720 1300 1
        inputTapSleep 550 800 0
        inputTapSleep 550 800 1
        _quickBattleGuildBosses_COUNT=$((_quickBattleGuildBosses_COUNT + 1))    # Increment
    done
}

# Loots afk chest
lootAfkChest() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] lootAfkChest" >&2; fi
    inputTapSleep 550 1500 1
    inputTapSleep 750 1350 3
    inputTapSleep 550 1850 1                    # Tap campaign in case of level up
    wait
    verifyRGB 450 1775 cc9261 "AFK Chest looted." "Failed to loot AFK Chest."
}

# Challenges a boss in the campaign
challengeBoss() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] challengeBoss" >&2; fi
    inputTapSleep 550 1650 1
    testColorORTapSleep 550 740 f2d79f          # Check if boss
    wait

    if [ "$forceFightCampaign" = "true" ]; then # Fight battle or not
        # Fight in the campaign because of Mythic Trick
        echo "[INFO] Figthing in campaign because of Mythic Trick $maxCampaignFights time(s)."
        _challengeBoss_COUNT=0

        # Check for battle screen
        while [ "$(testColorOR 20 1200 eaca95)" = "1" ] && [ "$_challengeBoss_COUNT" -lt "$maxCampaignFights" ]; do
            inputTapSleep 550 1850 0            # Battle
            waitBattleFinish 10                 # Wait until battle is over

            # Check battle result
            if [ "$battleFailed" = false ]; then                                # Win
                if [ "$(testColorOR 550 1670 e2dddc)" = "1" ];then              # Check for next stage
                    inputTapSleep 550 1670 6    # Next Stage
                    sleep 6

                    # TODO: Limited offers will fuck this part of the script up. I'm yet to find a way to close any possible offers.
                    # Tap top of the screen to close any possible Limited Offers
                    # inputTapSleep 550 75

                    testColorORTapSleep 550 740 f2d79f 5                        # Check if boss
                else
                    inputTapSleep 550 1150 3    # Continue to next battle
                fi
            else                                # Loose
                # Try again
                inputTapSleep 550 1720 5

                _challengeBoss_COUNT=$((_challengeBoss_COUNT + 1))              # Increment
            fi
        done

        # Return to campaign
        inputTapSleep 60 1850                   # Return

        testColorORTapSleep 715 1260 feffff 2                                   # Check for confirm to exit button
    else
        # Quick exit battle
        inputTapSleep 550 1850 1                # Battle
        inputTapSleep 80 1460                   # Pause
        inputTapSleep 230 960 1                 # Exit

        testColorORTapSleep 450 1775 cc9261 0                                   # Check for multi-battle
    fi

    wait
    verifyRGB 450 1775 cc9261 "Challenged boss in campaign." "Failed to fight boss in Campaign."
}

# Collects fast rewards
fastRewards() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] fastRewards" >&2; fi
    inputTapSleep 950 1660 1
    inputTapSleep 710 1260
    inputTapSleep 560 1800 1
    inputTapSleep 400 1250
    verifyRGB 450 1775 cc9261 "Fast rewards collected." "Failed to collect fast rewards."
}

# Collects and sends companion points, as well as auto lending mercenaries
collectFriendsAndMercenaries() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] collectFriendsAndMercenaries" >&2; fi
    inputTapSleep 970 810 1
    inputTapSleep 930 1600
    inputTapSleep 720 1760
    inputTapSleep 990 190
    inputTapSleep 630 1590
    inputTapSleep 750 1410 1
    inputTapSleep 70 1810 0
    inputTapSleep 70 1810 0

    # TODO: Check if its necessary to send mercenaries

    wait
    verifyRGB 450 1775 cc9261 "Sent and recieved companion points, as well as auto lending mercenaries." "Failed to collect/send companion points or failed to auto lend mercenaries."
}

# Starts Solo bounties
soloBounties() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] soloBounties" >&2; fi
    inputTapSleep 600 1320 1
    inputTapSleep 780 1550 1                    # Collect all
    inputTapSleep 350 1550                      # Dispatch all
    inputTapSleep 550 1500 0                    # Confirm

    if [ "$doTeamBounties" = false ]; then      # Return to Tab if $doTeamBounties = false
        wait
        inputTapSleep 70 1810
        verifyRGB 240 1775 d49a61 "Collected/dispatched solo bounties." "Failed to collect/dispatch solo bounties."
    else
        wait
        verifyRGB 650 1740 a7541a "Collected/dispatched solo bounties." "Failed to collect/dispatch solo bounties."
    fi
}

# Starts Team Bounties. Params: startFromTab
teamBounties() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] waitBattleFinish $*" >&2; fi
    if [ "$1" = true ]; then                    # Check if starting from tab or already inside activity
        inputTapSleep 600 1320 1
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 600 1320 1
    ## End of testing ##
    inputTapSleep 910 1770
    inputTapSleep 780 1550 1                    # Collect all
    inputTapSleep 350 1550                      # Dispatch all
    inputTapSleep 550 1500                      # Confirm
    inputTapSleep 70 1810
    verifyRGB 240 1775 d49a61 "Collected/dispatched team bounties." "Failed to collect/dispatch team bounties."
}

# Attempts to tap the closest Arena of Heroes opponent. Params: opponent
tapClosestOpponent() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] waitBattleFinish $*" >&2; fi
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
            if [ "$(testColorOR 820 700 a7f1b7)" = "1" ];then inputTapSleep 820 700 0; else return 1; fi
            ;;
        2)
            # Check if opponent 2 exists and fight if true
            if [ "$(testColorOR 820 870 2daab4 aff3c0)" = "1" ]; then inputTapSleep 820 870 0; else return 1; fi
            ;;
        3)
            # Check if opponent 3 exists and fight if true
            if [ "$(testColorOR 820 1050 a7f1b7)" = "1" ]; then inputTapSleep 820 1050 0; else return 1; fi
            ;;
        4)
            # Check if opponent 4 exists and fight if true
            if [ "$(testColorOR 820 1220 2daab4 aff3c0)" = "1" ]; then inputTapSleep 820 1220 0; else return 1; fi
            ;;
        5)
            # Check if opponent 5 exists and fight if true
            if [ "$(testColorOR 820 1400 aaf2bb)" = "1" ]; then inputTapSleep 820 1400 0; else return 1; fi
            ;;
        esac
        ;;
    2)
        # Check if opponent 1 exists
        if [ "$(testColorOR 820 700 a7f1b7)" = "1" ]; then
            # Fight opponent
            inputTapSleep 820 700 0
        else
            # Try to fight the closest opponent to 2
            tapClosestOpponent 1
        fi
        ;;
    3)
        # Check if opponent 2 exists
        if [ "$(testColorOR 820 870 2daab4 aff3c0)" = "1" ]; then
            # Fight opponent
            inputTapSleep 820 870 0
        else
            # Try to fight the closest opponent to 3
            tapClosestOpponent 2
        fi
        ;;
    4)
        # Check if opponent 3 exists
        if [ "$(testColorOR 820 1050 a7f1b7)" = "1" ]; then
            # Fight opponent
            inputTapSleep 820 1050 0
        else
            # Try to fight the closest opponent to 4
            tapClosestOpponent 3
        fi
        ;;
    5)
        # Check if opponent 4 exists
        if [ "$(testColorOR 820 1220 2daab4 aff3c0)" = "1" ]; then
            # Fight opponent
            inputTapSleep 820 1220 0
        else
            # Try to fight the closest opponent to 5
            tapClosestOpponent 4
        fi
        ;;
    esac
}

# Does the daily arena of heroes battles
arenaOfHeroes() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] arenaOfHeroes" >&2; fi
    inputTapSleep 740 1050 3
    if [ "$pvpEvent" = false ]; then
        inputTapSleep 550 450 3
    else
        inputTapSleep 550 900 3
    fi
    inputTapSleep 1000 1800
    inputTapSleep 980 410
    inputTapSleep 540 1800

    if [ "$(testColorNAND 200 1800 382314 382214)" = "1" ];then                 # Check for new season
        _arenaOfHeroes_COUNT=0
        until [ "$_arenaOfHeroes_COUNT" -ge "$totalAmountArenaTries" ]; do                     # Repeat a battle for as long as totalAmountArenaTries
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
                    # Check if opponent exists
                     if [ "$(testColorOR 820 700 a7f1b7)" = "1" ]; then
                        # Fight opponent
                        inputTapSleep 820 700 0
                    else
                        # Refresh opponents and try to fight opponent $arenaHeroesOpponent
                        tapClosestOpponent 1
                    fi
                    ;;
                2)
                    # Check if opponent exists
                    if [ "$(testColorOR 820 870 2daab4 aff3c0)" = "1" ]; then
                        # Fight opponent
                        inputTapSleep 820 870 0
                    else
                        # Try to fight the closest opponent to 2
                        tapClosestOpponent 2
                    fi
                    ;;
                3)
                    # Check if opponent exists
                    if [ "$(testColorOR 820 1050 a7f1b7)" = "1" ]; then
                        # Fight opponent
                        inputTapSleep 820 1050 0
                    else
                        # Try to fight the closest opponent to 3
                        tapClosestOpponent 3
                    fi
                    ;;
                4)
                    # Check if opponent exists
                    if [ "$(testColorOR 820 1220 2daab4 aff3c0)" = "1" ]; then
                        # Fight opponent
                        inputTapSleep 820 1220 0
                    else
                        # Try to fight the closest opponent to 4
                        tapClosestOpponent 4
                    fi
                    ;;
                5)
                    # Check if opponent exists
                    if [ "$(testColorOR 820 1400 aaf2bb)" = "1" ]; then
                        # Fight opponent
                        inputTapSleep 820 1400 0
                    else
                        # Try to fight the closest opponent to 5
                        tapClosestOpponent 5
                    fi
                    ;;
            esac

            # Check if return value of tapClosesopponent is 0. If it is 0, then it means a battle has been found.
            if [ $? = 0 ]; then
                wait
                inputTapSleep 550 1850 0        # Battle
                waitBattleFinish 2
                if [ "$battleFailed" = false ]; then
                    inputTapSleep 550 1550      # Collect
                fi
                inputTapSleep 550 1550 3        # Finish battle
            fi
            _arenaOfHeroes_COUNT=$((_arenaOfHeroes_COUNT + 1))                  # Increment
        done

        inputTapSleep 1000 380
        sleep 4
    else
        echo "[WARN] Unable to fight in the Arena of Heroes because a new season is soon launching."
    fi

    if [ "$doLegendsTournament" = false ]; then # Return to Tab if $doLegendsTournament = false
        inputTapSleep 70 1810
        inputTapSleep 70 1810
        verifyRGB 240 1775 d49a61 "Checked the Arena of Heroes out." "Failed to check the Arena of Heroes out."
    else
        inputTapSleep 70 1810
        verifyRGB 760 70 1f2d3a "Checked the Arena of Heroes out." "Failed to check the Arena of Heroes out."
    fi
}

# Does the daily Legends tournament battles. Params: startFromTab
legendsTournament() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] legendsTournament $*" >&2; fi
    if [ "$1" = true ]; then                    # Check if starting from tab or already inside activity
        inputTapSleep 740 1050
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 740 1050 1
    ## End of testing ##
    if [ "$pvpEvent" = false ]; then
        inputTapSleep 550 900
    else
        inputTapSleep 550 1450
    fi
    inputTapSleep 550 280 3
    inputTapSleep 550 1550 3
    inputTapSleep 1000 1800
    inputTapSleep 990 380

    _legendsTournament_COUNT=0
    until [ "$_legendsTournament_COUNT" -ge "$totalAmountArenaTries-2" ]; do    # Repeat a battle for as long as totalAmountArenaTries
        inputTapSleep 550 1840 4
        inputTapSleep 800 1140 4
        inputTapSleep 550 1850 4
        inputTapSleep 770 1470 4
        inputTapSleep 550 800 4
        _legendsTournament_COUNT=$((_legendsTournament_COUNT + 1))              # Increment
    done

    inputTapSleep 70 1810
    inputTapSleep 70 1810
    verifyRGB 240 1775 d49a61 "Battled at the Legends Tournament." "Failed to battle at the Legends Tournament."
}

# Battles in King's Towers. Params: X, Y
battleKingsTower() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] battleKingsTower $*" >&2; fi
    _battleKingsTower_COUNT=0
    inputTapSleep "$1" "$2" 2                   # Tap chosen tower

    # Check if inside tower
    if [ "$(testColorOR 550 150 1a1212)" = "1" ]; then
        inputTapSleep 540 1350                  # Challenge

        # Battle while less than maxKingsTowerFights & we haven't reached daily limit of 10 floors
        while [ "$_battleKingsTower_COUNT" -lt "$maxKingsTowerFights" ] && [ "$(testColorOR 550 150 1a1212)" = "1" ]; do
            inputTapSleep 550 1850 0            # Battle
            waitBattleFinish 2

            # Check if win or lose battle
            if [ "$battleFailed" = false ]; then
                inputTapSleep 550 1850 4        # Collect

                # TODO: Limited offers might screw this up though I'm not sure they actually spawn in here, maybe only at the main tabs
                # Tap top of the screen to close any possible Limited Offers
                # if [ "$(testColorOR 550 150 1a1212)" = "1" ]; then # not on screen with Challenge button
                #     inputTapSleep 550 75        # Tap top of the screen to close Limited Offer
                #     if [ "$(testColorOR 550 150 1a1212)" = "1" ]; then # think i remember it needs two taps to close offer
                #         inputTapSleep 550 75    # Tap top of the screen to close Limited Offer
                # fi

                inputTapSleep 540 1350          # Challenge
            elif [ "$battleFailed" = true ]; then
                inputTapSleep 550 1720          # Try again
                _battleKingsTower_COUNT=$((_battleKingsTower_COUNT + 1))        # Increment
            fi

            # Check if reached daily limit / kicked us out of battle screen
        done

        # Return from chosen tower / battle
        inputTapSleep 70 1810 3
        if [ "$(testColorOR 550 150 1a1212)" = "1" ]; then                      # In case still in tower, exit once more
            inputTapSleep 70 1810 0;
        fi
        sleep 2
    fi
}

# Battles once in the kings tower
kingsTower() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] kingsTower" >&2; fi
    inputTapSleep 500 870                       # King's Tower

    # Towers
    battleKingsTower 550 900  # Main Tower
    battleKingsTower 250 500  # Tower of Light
    battleKingsTower 800 500  # The Brutal Citadel
    battleKingsTower 250 1400 # The World Tree
    battleKingsTower 800 1400 # The Forsaken Necropolis

    # Exit
    inputTapSleep 70 1810
    verifyRGB 240 1775 d49a61 "Battled at the Kings Tower." "Failed to battle at the Kings Tower."
}

# Battles against Guild boss Wrizz
guildHunts() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] guildHunts" >&2; fi
    inputTapSleep 380 360 10

    if [ "$(testColorOR 380 500 793929)" = "1" ];then                           # Check for fortune chest
        inputTapSleep 560 1300
        inputTapSleep 540 1830
    fi
    wait

    inputTapSleep 290 860 3

    # TODO: Make sure 2x and Auto are enabled
    # TODO: Have a variable decide if fight wrizz or not
    # Start checking for a finished Battle after 40 seconds
    # loopUntilRGB 85 420 380 ca9c5d
    # wait
    # inputTapSleep 550 800 0
    # inputTapSleep 550 800 0
    #wait

    # Wrizz
    # TODO: Check if possible to fight wrizz
    # Repeat a battle for as long as totalAmountArenaTries
    _guildHunts_COUNT=0
    until [ "$_guildHunts_COUNT" -ge "$totalAmountGuildBossTries" ]; do
        # Check if its possible to fight wrizz
        # if [ "$(testColorOR 710 1840 9de7bd)" = "1" ]; then
        #     echo "Enough of wrizz! Going out."
        #     break
        # fi

        inputTapSleep 710 1840 0
        # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
        wait
        inputTapSleep 720 1300 1
        inputTapSleep 550 800 0
        inputTapSleep 550 800 1
        _guildHunts_COUNT=$((_guildHunts_COUNT + 1))                            # Increment
    done

    inputTapSleep 970 890 1                     # Soren

    if [ "$(testColorOR 715 1815 8ae5c4)" = "1" ];then                          # If Soren is open
        quickBattleGuildBosses
    elif [ "$canOpenSoren" = true ]; then                                       # If Soren is closed
        if [ "$(testColorOR 580 1753 fae0ac)" = "1" ];then                      # If soren is "openable"
            inputTapSleep 550 1850
            inputTapSleep 700 1250 1
            quickBattleGuildBosses
        fi
    fi

    if [ "$doGuildHunts" = false ]; then        # Return to Tab if $doGuildHunts = false
        inputTapSleep 70 1810
        inputTapSleep 70 1810 1
        verifyRGB 20 1775 d49a61 "Battled Wrizz and possibly Soren." "Failed to battle Wrizz and possibly Soren."
    else
        inputTapSleep 70 1810 1
        verifyRGB 70 1000 a9a95f "Battled Wrizz and possibly Soren." "Failed to battle Wrizz and possibly Soren."
    fi
}

# Battles against the Twisted Realm Boss. Params: startFromTab
twistedRealmBoss() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] waitBattleFinish $*" >&2; fi
    # TODO: Choose if 2x or not
    # TODO: Choose a formation (Would be dope!)
    if [ "$1" = true ]; then                    # Check if starting from tab or already inside activity
        inputTapSleep 380 360 10
    fi
    ## For testing only! Keep as comment ##
    # inputTapSleep 380 360 10
    ## End of testing ##

    inputTapSleep 820 820

    if [ "$(testColorOR 540 1220 9aedc1)" = "1" ];then                          # Check if TR is being calculated
        echo "[WARN] Unable to fight in the Twisted Realm because it's being calculated."
    else
        inputTapSleep 550 1850
        inputTapSleep 550 1850 0

        loopUntilRGB 30 420 380 ca9c5d          # Start checking for a finished Battle after 40 seconds

        sleep 1
        inputTapSleep 550 800 3
        inputTapSleep 550 800
        # TODO: Repeat battle if variable says so
    fi

    inputTapSleep 70 1810
    inputTapSleep 70 1810 1
    verifyRGB 20 1775 d49a61 "Checked Twisted Realm Boss out." "Failed to check the Twisted Realm out."
}

# Buy items from store
buyFromStore() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] buyFromStore" >&2; fi
    inputTapSleep 330 1650 3

    if [ "$buyStoreDust" = true ]; then         # Dust
        buyStoreItem 180 840
        wait
    fi
    if [ "$buyStorePoeCoins" = true ]; then     # Poe Coins
        buyStoreItem 670 1430
        wait
    fi
    if [ "$buyStoreEmblems" = true ]; then      # Emblems
        buyStoreItem 180 1430
        wait
    fi
    inputTapSleep 70 1810
    verifyRGB 20 1775 d49a61 "Visited the Store." "Failed to visit the Store."
}

quickCollectQuestChests() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] quickCollectQuestChests" >&2; fi
    # Collect Quests
    while [ "$(testColorOR 700 670 82fdf5)" = "1" ]; do
        inputTapSleep 930 680
    done

    # Collect Chests
    inputTapSleep 330 430                       # Chest 20
    inputTapSleep 580 600 0                     # Collect
    inputTapSleep 500 430                       # Chest 40
    inputTapSleep 580 600 0                     # Collect
    inputTapSleep 660 430                       # Chest 60
    inputTapSleep 580 600 0                     # Collect
    inputTapSleep 830 430                       # Chest 80
    inputTapSleep 580 600 0                     # Collect
    inputTapSleep 990 430                       # Chest 100
    inputTapSleep 580 600                       # Collect
}

# Collects
collectQuestChests() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] collectQuestChests" >&2; fi
    # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
    inputTapSleep 960 250                       # Quests
    quickCollectQuestChests

    # Weekly quests
    inputTapSleep 650 1650                      # Weeklies
    quickCollectQuestChests

    # Return
    inputTapSleep 70 1650 1
    verifyRGB 20 1775 d49a61 "Collected daily and weekly quest chests." "Failed to collect daily and weekly quest chests."
}

# Collects mail
collectMail() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] collectMail" >&2; fi
    # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
    inputTapSleep 960 630
    inputTapSleep 790 1470
    inputTapSleep 110 1850
    inputTapSleep 110 1850
    verifyRGB 20 1775 d49a61 "Collected Mail." "Failed to collect Mail."
}

# Collects Daily/Weekly/Monthly from the merchants page
collectMerchants() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] collectMerchants" >&2; fi
    inputTapSleep 120 300 3                     # Merchants
    inputTapSleep 510 1820                      # Merchant Ship

    if [ "$(testColorNAND 375 940 0b080a)" = "1" ];then                         # Checks for Special Daily Bundles
        inputTapSleep 200 1200 1
    else
        inputTapSleep 200 750 1
    fi
    inputTapSleep 550 300 1                     # Collect rewards
    inputTapSleep 280 1620 1                    # Weekly Deals

    if [ "$(testColorNAND 375 940 050a0f)" = "1" ];then                         # Checks for Special Weekly Bundles
        inputTapSleep 200 1200 1
    else
        inputTapSleep 200 750 1
    fi
    inputTapSleep 550 300 1                     # Collect rewards
    inputTapSleep 460 1620 1                    # Monthly Deals

    if [ "$(testColorNAND 375 940 0b080a)" = "1" ];then                         # Checks for Special Monthly Bundles
        inputTapSleep 200 1200 1
    else
        inputTapSleep 200 750
    fi
    inputTapSleep 550 300 1                     # Collect rewards
    inputTapSleep 70 1810 1
    verifyRGB 20 1775 d49a61 "Collected daily/weekly/monthly offer." "Failed to collect daily/weekly/monthly offer."
}

# If red square, strenghen Crystal
strengthenCrystal() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] strengthenCrystal" >&2; fi
    inputTapSleep 760 1030 3                    # Crystal

    # TODO: Detect if free slot, and take it.

    inputTapSleep 550 1850                      # Strenghen Crystal
    inputTapSleep 200 1850                      # Close level up window
    inputTapSleep 70 1810
    verifyRGB 20 1775 d49a61 "Strenghened resonating Crystal." "Failed to Strenghen Resonating Crystal."
}

# Let's do a "free" summon
nobleTavern() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] nobleTavern" >&2; fi
    inputTapSleep 280 1370 3                    # The Noble Tavern
    inputTapSleep 600 1820 1                    # The noble tavern again

    until [ "$(testColorOR 875 835 f38d67)" = "1" ];do                          # Looking for heart
        inputTapSleep 870 1630 1                # Next pannel
    done

    inputTapSleep 320 1450 3                    # Summon
    inputTapSleep 540 900 3                     # Click on the card
    inputTapSleep 70 1810                       # close
    inputTapSleep 550 1820 1                    # Collect rewards

    inputTapSleep 70 1810
    verifyRGB 20 1775 d49a61 "Summoned one hero with Companion Points." "Failed to summon one hero with Companion Points."
}

# Collect Oak Inn
oakInn() {
    if [ $DEBUG -ge 4 ]; then echo "[DEBUG] oakInn" >&2; fi
    inputTapSleep 780 270 5                     # Oak Inn

    _oakInn_COUNT=0
    until [ "$_oakInn_COUNT" -ge "$totalAmountOakRewards" ]; do
        inputTapSleep 1050 950                  # Friends
        inputTapSleep 1025 400 5                # Top Friend
        sleep 5

        oakTryCollectPresent
        if [ $oakRes = 0 ]; then                # If return value is still 0, no presents were found at first friend
            # Switch friend and search again
            inputTapSleep 1050 950              # Friends
            inputTapSleep 1025 530 5            # Second friend

            oakTryCollectPresent
            if [ $oakRes = 0 ]; then            # If return value is again 0, no presents were found at second friend
                # Switch friend and search again
                inputTapSleep 1050 950          # Friends
                inputTapSleep 1025 650 5        # Third friend

                oakTryCollectPresent
                if [ $oakRes = 0 ]; then        # If return value is still freaking 0, I give up
                    echo "[WARN] Couldn't collect Oak Inn presents, sowy."
                    break
                fi
            fi
        fi

        sleep 2
        _oakInn_COUNT=$((_oakInn_COUNT + 1))    # Increment
    done

    inputTapSleep 70 1810 3
    inputTapSleep 70 1810 0

    wait
    verifyRGB 20 1775 d49a61 "Attempted to collect Oak Inn presents." "Failed to collect Oak Inn presents."
}

# Test function (X, Y, amountTimes, waitTime)
# test 630 1520 3 0.5
# test 550 740 3 0.5 # Check for Boss in Campaign
# test 660 520 3 0.5 # Check for Solo Bounties RGB
# test 650 570 3 0.5 # Check for Team Bounties RGB
# test 700 670 3 0.5 # Check for chest collection RGB
# test 715 1815 3 0.5 # Check if Soren is open
# test 740 205 3 0.5 # Check if game is updating
# test 270 1800 3 0.5 # Oak Inn Present Tab 1
# test 410 1800 3 0.5 # Oak Inn Present Tab 2
# test 550 1800 3 0.5 # Oak Inn Present Tab 3
# test 690 1800 3 0.5 # Oak Inn Present Tab 4

# --- Script Start --- #
echo "[INFO] Starting script... ($(date)) "
echo
closeApp
sleep 0.5
startApp
sleep 10

loopUntilNotRGB 1 450 1775 cc9261               # Loops until the game has launched

inputTapSleep 970 380 0                         # Open menu for friends, etc

switchTab "Campaign"
sleep 3
switchTab "Dark Forest"
sleep 1
switchTab "Ranhorn"
sleep 1
switchTab "Campaign" true

if [ "$(testColorOR 740 205 ffc15b)" = "1" ];then                               # Check if game is being updated
    echo "[WARN] Game is being updated!"
    if [ "$waitForUpdate" = true ]; then
        echo "[INFO]: Waiting for game to finish update..."
        loopUntilNotRGB 5 740 205 ffc15b
        echo "[OK]: Game finished updating."
    else
        echo "[WARN]: Not waiting for update to finish."
    fi
fi

# CAMPAIGN TAB
switchTab "Campaign"
if [ "$doLootAfkChest" = true ]; then lootAfkChest; fi
if [ "$doChallengeBoss" = true ]; then challengeBoss; fi
if [ "$doFastRewards" = true ]; then fastRewards; fi
if [ "$doCollectFriendsAndMercenaries" = true ]; then collectFriendsAndMercenaries; fi
if [ "$doLootAfkChest" = true ]; then lootAfkChest; fi

# DARK FOREST TAB
switchTab "Dark Forest"
if [ "$doSoloBounties" = true ]; then soloBounties; fi
if [ "$doTeamBounties" = true ]; then
    if [ "$doSoloBounties" = true ]; then teamBounties; else teamBounties true; fi
fi
if [ "$doArenaOfHeroes" = true ]; then arenaOfHeroes; fi
if [ "$doLegendsTournament" = true ]; then
    if [ "$doArenaOfHeroes" = true ]; then legendsTournament; else legendsTournament true; fi
fi
if [ "$doKingsTower" = true ]; then kingsTower; fi

# RANHORN TAB
switchTab "Ranhorn"
if [ "$doGuildHunts" = true ]; then guildHunts; fi
if [ "$doTwistedRealmBoss" = true ]; then
    if [ "$doGuildHunts" = true ]; then twistedRealmBoss; else twistedRealmBoss true; fi
fi
if [ "$doBuyFromStore" = true ]; then buyFromStore; fi
if [ "$doStrengthenCrystal" = true ]; then strengthenCrystal; fi
if [ "$doCompanionPointsSummon" = true ]; then nobleTavern; fi
if [ "$doCollectOakPresents" = true ]; then oakInn; fi

# END
if [ "$doCollectQuestChests" = true ]; then collectQuestChests; fi
if [ "$doCollectMail" = true ]; then collectMail; fi
if [ "$doCollectMerchantFreebies" = true ]; then collectMerchants; fi

# Ends at given location
sleep 1
checkWhereToEnd

echo
echo "[INFO] End of script! ($(date)) "
exit
