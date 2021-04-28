#!/system/bin/sh

# --- Variables --- #
# Probably you don't need to modify this. Do it if you know what you're doing, I won't blame you (unless you blame me).
DEVICEWIDTH=1080
DEBUG=0                                         # 0 no debug, 1 show getColor value, 2 show tap position
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
    COUNT=0
    until [ "$COUNT" -ge "$3" ]; do
        sleep "$4"
        getColor "$1" "$2"
        echo "RGB: $RGB"
        COUNT=$((COUNT + 1))                    # Increment
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
    if [ $DEBUG -ge 1 ]; then echo "[DEBUG] getColor $1 $2 > RGB: $RGB" >&2; fi
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
    if [ $DEBUG -ge 2 ]; then echo "[DEBUG] inputTapSleep $1 $2 $3" >&2; fi
    input tap "$1" "$2"                         # tap
    sleep "${3:-$DEFAULT_SLEEP}"                # sleep
}

# testColorOR <X> <Y> <COLOR> [<COLOR> ...]
# if true, return 1, else 0
testColorOR() {
    getColor "$1" "$2"                          # looking for color
    i=3
    while [ $i -le $# ]; do                     # loop in colors
        if [ "$RGB" = "${i}" ]; then            # color found?
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
    getColor "$1" "$2"                          # looking for color
    i=3
    while [ $i -le $# ]; do                     # loop in colors
        if [ "$RGB" = "${i}" ]; then            # color found?
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
    if [ "$(testColorOR "$1" "$2" "$3")" = "1" ];then                           # if color found
        inputTapSleep  "$1" "$2" "${4:-$DEFAULT_SLEEP}"                         # tap & sleep
    fi
}

# Switches to another tab. Params: <Tab name> <force>
switchTab() {
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
               [ "$doStrenghenCrystal" = true ] || \
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
    sleep "$1"
    while [ "$(testColorNAND "$2" "$3" "$4")" = "1" ];do
        sleep 1
    done
}

# Loops until RGB is equal. Params: Seconds, X, Y, RGB
loopUntilNotRGB() {
    sleep "$1"
    while [ "$(testColorOR "$2" "$3" "$4")" = "1" ];do
        sleep 1
    done
}

# Waits until a battle has ended. Params: Seconds
waitBattleFinish() {
    sleep "$1"
    finished=false
    while [ $finished = false ]; do
        # First RGB local device, second bluestacks
        if [ "$(testColorOR 560 350 "b8894d" "b7894c")" = "1" ];then            # Victory
            battleFailed=false
            finished=true
        elif [ "$RGB" = "171932" ]; then                                        # Failed
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
    inputTapSleep "$1" "$2" 1
    inputTapSleep 550 1540 1
    inputTapSleep 550 1700 0
}

# Searches for a "good" present in oak Inn
oakSearchPresent() {
    input swipe 400 1600 400 310 50             # Swipe all the way down
    sleep 1

    if [ "$(testColorOR 540 990 "833f0e")" = "1" ];then                         # 1 red 833f0e blue 903da0
        inputTapSleep 540 990 3                 # Tap present
        inputTapSleep 540 1650 1                # Ok
        inputTapSleep 540 1650 0                # Collect reward
        oakRes=1
    else
        if [ "$(testColorOR 540 800 "a21a1a")" = "1" ];then                     # 2 red a21a1a blue 9a48ab
            inputTapSleep 540 800 3
            inputTapSleep 540 1650 1            # Ok
            inputTapSleep 540 1650 0            # Collect reward
            oakRes=1
        else
            if [ "$(testColorOR 540 610 "aa2b27")" = "1" ];then                 # 3 red aa2b27 blue b260aa
                inputTapSleep 540 610 3
                inputTapSleep 540 1650 1        # Ok
                inputTapSleep 540 1650 0        # Collect reward
                oakRes=1
            else
                if [ "$(testColorOR 540 420 "bc3f36")" = "1" ];then             # 4 red bc3f36 blue c58c7b
                    inputTapSleep 540 420 3
                    inputTapSleep 540 1650 1                                    # Ok$
                    inputTapSleep 540 1650 0                                    # Collect reward
                    oakRes=1
                else
                    if [ "$(testColorOR 540 220 "bb3734")" = "1" ];then         # 5 red bb3734 blue 9442a5
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
    oakPresentTabs=0
    if [ "$(testColorOR 270 1800 "c79663")" = "1" ];then                        # 1 gift c79663
        oakPresentTabs=$((oakPresentTabs + 1000))                               # Increment
    fi
    if [ "$(testColorOR 410 1800 "bb824f")" = "1" ];then                        # 2 gift bb824f
        oakPresentTabs=$((oakPresentTabs + 200))                                # Increment
    fi
    if [ "$(testColorOR 550 1800 "af6e3b")" = "1" ];then                        # 3 gift af6e3b
        oakPresentTabs=$((oakPresentTabs + 30))                                 # Increment
    fi
    if [ "$(testColorOR 690 1800 "b57b45")" = "1" ];then                        # 4 gift b57b45
        oakPresentTabs=$((oakPresentTabs + 4))                                  # Increment
    fi
}

# Tries to collect a present from one Oak Inn friend
oakTryCollectPresent() {
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
    case "$endAt" in
        "oak")
            switchTab "Ranhorn"
            inputTapSleep 780 280 0
            ;;
        "soren")
            switchTab "Ranhorn"
            inputTapSleep 380 360 3
            inputTapSleep 290 860 1
            inputTapSleep 970 890 0
            ;;
        "mail")
            inputTapSleep 960 630 0
            ;;
        "chat")
            switchTab "Chat"
            ;;
        "tavern")
            switchTab "Ranhorn"
            inputTapSleep 300 1400 0
            ;;
        "merchants")
            inputTapSleep 120 290 0
            ;;
        "campaign")
            inputTapSleep 550 1850 0
            ;;
        "championship")
            switchTab "Dark Forest"
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
    COUNT=0
    until [ "$COUNT" -ge "$totalAmountGuildBossTries" ]; do
        inputTapSleep 710 1840
        inputTapSleep 720 1300 1
        inputTapSleep 550 800 0
        inputTapSleep 550 800 1
        COUNT=$((COUNT + 1))                    # Increment
    done
}

# Loots afk chest
lootAfkChest() {
    inputTapSleep 550 1500 1
    inputTapSleep 750 1350 3
    inputTapSleep 550 1850 1                    # Tap campaign in case of level up
    wait
    verifyRGB 450 1775 cc9261 "AFK Chest looted." "Failed to loot AFK Chest."
}

# Challenges a boss in the campaign
challengeBoss() {
    inputTapSleep 550 1650 1
    testColorORTapSleep 550 740 "f2d79f"        # Check if boss
    wait

    if [ "$forceFightCampaign" = "true" ]; then # Fight battle or not
        # Fight in the campaign because of Mythic Trick
        echo "[INFO] Figthing in campaign because of Mythic Trick $maxCampaignFights time(s)."
        COUNT=0

        getColor 20 1200                        # Check for battle screen
        while [ "$RGB" = "eaca95" ] && [ "$COUNT" -lt "$maxCampaignFights" ]; do
            inputTapSleep 550 1850 0            # Battle
            waitBattleFinish 10                 # Wait until battle is over

            # Check battle result
            if [ "$battleFailed" = false ]; then                                # Win
                if [ "$(testColorOR 550 1670 "e2dddc")" = "1" ];then            # Check for next stage
                    inputTapSleep 550 1670 6    # Next Stage
                    sleep 6

                    # TODO: Limited offers will fuck this part of the script up. I'm yet to find a way to close any possible offers.
                    # Tap top of the screen to close any possible Limited Offers
                    # input tap 550 75
                    # sleep 2

                    testColorORTapSleep 550 740 "f2d79f" 5                      # Check if boss
                else
                    inputTapSleep 550 1150 3    # Continue to next battle
                fi
            else                                # Loose
                # Try again
                inputTapSleep 550 1720 5

                COUNT=$((COUNT + 1))            # Increment
            fi

            getColor 20 1200                    # Check for battle screen
        done

        # Return to campaign
        inputTapSleep 60 1850                   # Return

        testColorORTapSleep 715 1260 "feffff" 2                                 # Check for confirm to exit button
    else
        # Quick exit battle
        inputTapSleep 550 1850 1                # Battle
        inputTapSleep 80 1460                   # Pause
        inputTapSleep 230 960 1                 # Exit

        testColorORTapSleep 450 1775 "cc9261" 0                                 # Check for multi-battle
    fi

    wait
    verifyRGB 450 1775 cc9261 "Challenged boss in campaign." "Failed to fight boss in Campaign."
}

# Collects fast rewards
fastRewards() {
    inputTapSleep 950 1660 1
    inputTapSleep 710 1260
    inputTapSleep 560 1800 1
    inputTapSleep 400 1250
    verifyRGB 450 1775 cc9261 "Fast rewards collected." "Failed to collect fast rewards."
}

# Collects and sends companion points, as well as auto lending mercenaries
collectFriendsAndMercenaries() {
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
    if [ "$1" = true ]; then                    # Check if starting from tab or already inside activity
        inputTapSleep 600 1320 1
    fi
    ## For testing only! Keep as comment ##
    # input tap 600 1320
    # sleep 1
    ## End of testing ##
    inputTapSleep 910 1770
    inputTapSleep 780 1550 1                    # Collect all
    inputTapSleep 350 1550                      # Dispatch all
    inputTapSleep 550 1500                      # Confirm
    inputTapSleep 70 1810
    verifyRGB 240 1775 d49a61 "Collected/dispatched team bounties." "Failed to collect/dispatch team bounties."
}

# Does the daily arena of heroes battles
arenaOfHeroes() {
    inputTapSleep 740 1050
    if [ "$pvpEvent" = false ]; then
        inputTapSleep 550 450
    else
        inputTapSleep 550 900
    fi
    inputTapSleep 1000 1800
    inputTapSleep 980 410
    inputTapSleep 540 1800

    if [ "$(testColorNAND 200 1800 "382314" "382214")" = "1" ];then             # Check for new season
        COUNT=0
        until [ "$COUNT" -ge "$totalAmountArenaTries" ]; do                     # Repeat a battle for as long as totalAmountArenaTries
            # Refresh
            # input tap 815 540
            # wait
            # Fight specific opponent
            case $arenaHeroesOpponent in
                1)
                    inputTapSleep 820 700 0
                    ;;
                2)
                    inputTapSleep 820 870 0
                    ;;
                3)
                    inputTapSleep 820 1050 0
                    ;;
                4)
                    inputTapSleep 820 1220 0
                    ;;
                5)
                    inputTapSleep 820 1400 0
                    ;;
            esac
            wait
            inputTapSleep 550 1850 0
            waitBattleFinish 2
            if [ "$battleFailed" = false ]; then
                inputTapSleep 550 1550          # Collect
            fi
            inputTapSleep 550 1550 3            # Finish battle
            COUNT=$((COUNT + 1))                # Increment
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
    if [ "$1" = true ]; then                    # Check if starting from tab or already inside activity
        inputTapSleep 740 1050
    fi
    ## For testing only! Keep as comment ##
    # input tap 740 1050
    # sleep 1
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

    COUNT=0
    until [ "$COUNT" -ge "$totalAmountArenaTries-2" ]; do                       # Repeat a battle for as long as totalAmountArenaTries
        inputTapSleep 550 1840 4
        inputTapSleep 800 1140 4
        inputTapSleep 550 1850 4
        inputTapSleep 770 1470 4
        inputTapSleep 550 800 4
        COUNT=$((COUNT + 1))                    # Increment
    done

    inputTapSleep 70 1810
    inputTapSleep 70 1810
    verifyRGB 240 1775 d49a61 "Battled at the Legends Tournament." "Failed to battle at the Legends Tournament."
}

# Battles once in the kings tower
kingsTower() {
    inputTapSleep 500 870
    inputTapSleep 550 900
    inputTapSleep 540 1350
    inputTapSleep 550 1850
    inputTapSleep 80 1460 1
    inputTapSleep 230 960
    inputTapSleep 70 1810
    inputTapSleep 70 1810
    verifyRGB 240 1775 d49a61 "Battled at the Kings Tower." "Failed to battle at the Kings Tower."
}

# Battles against Guild boss Wrizz
guildHunts() {
    inputTapSleep 380 360 10

    if [ "$(testColorOR 380 500 "793929")" = "1" ];then                         # Check for fortune chest
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
    # input tap 550 800
    # input tap 550 800
    #wait

    # Wrizz
    # TODO: Check if possible to fight wrizz
    # Repeat a battle for as long as totalAmountArenaTries
    COUNT=0
    until [ "$COUNT" -ge "$totalAmountGuildBossTries" ]; do
        # Check if its possible to fight wrizz
        # getColor 710 1840
        # if [ "$RGB" != "9de7bd" ]; then
        #     echo "Enough of wrizz! Going out."
        #     break
        # fi

        inputTapSleep 710 1840 0
        # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
        wait
        inputTapSleep 720 1300 1
        inputTapSleep 550 800 0
        inputTapSleep 550 800 1
        COUNT=$((COUNT + 1))                    # Increment
    done

    inputTapSleep 970 890 1                     # Soren

    if [ "$(testColorOR 715 1815 "8ae5c4")" = "1" ];then                        # If Soren is open
        quickBattleGuildBosses
    elif [ "$canOpenSoren" = true ]; then                                       # If Soren is closed
        if [ "$(testColorOR 580 1753 "fae0ac")" = "1" ];then                    # If soren is "openable"
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
    # TODO: Choose if 2x or not
    # TODO: Choose a formation (Would be dope!)
    if [ "$1" = true ]; then                    # Check if starting from tab or already inside activity
        inputTapSleep 380 360 10
    fi
    ## For testing only! Keep as comment ##
    # input tap 380 360
    # sleep 10
    ## End of testing ##

    inputTapSleep 820 820

    if [ "$(testColorOR 540 1220 "9aedc1")" = "1" ];then                        # Check if TR is being calculated
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

# Collects
collectQuestChests() {
    # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
    inputTapSleep 960 250

    while [ "$(testColorOR 700 670 "82fdf5")" = "1" ];do                        # Collect Quests
        inputTapSleep 930 680
    done

    inputTapSleep 330 430
    inputTapSleep 580 600 0
    inputTapSleep 500 430
    inputTapSleep 580 600 0
    inputTapSleep 660 430
    inputTapSleep 580 600 0
    inputTapSleep 830 430
    inputTapSleep 580 600 0
    inputTapSleep 990 430
    inputTapSleep 580 600
    inputTapSleep 70 1650 1
    verifyRGB 20 1775 d49a61 "Collected daily quest chests." "Failed to collect daily quest chests."
}

# Collects mail
collectMail() {
    # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
    inputTapSleep 960 630
    inputTapSleep 790 1470
    inputTapSleep 110 1850
    inputTapSleep 110 1850
    verifyRGB 20 1775 d49a61 "Collected Mail." "Failed to collect Mail."
}

# Collects Daily/Weekly/Monthly from the merchants page
collectMerchants() {
    inputTapSleep 120 300 3                     # Merchants
    inputTapSleep 510 1820                      # Merchant Ship

    if [ "$(testColorNAND 375 940 "0b080a")" = "1" ];then                       # Checks for Special Daily Bundles
        inputTapSleep 200 1200 1
    else
        inputTapSleep 200 750 1
    fi
    inputTapSleep 550 300 1                     # Collect rewards
    inputTapSleep 280 1620 1                    # Weekly Deals

    if [ "$(testColorNAND 375 940 "050a0f")" = "1" ];then                       # Checks for Special Weekly Bundles
        inputTapSleep 200 1200 1
    else
        inputTapSleep 200 750 1
    fi
    inputTapSleep 550 300 1                     # Collect rewards
    inputTapSleep 460 1620 1                    # Monthly Deals

    if [ "$(testColorNAND 375 940 "0b080a")" = "1" ];then                       # Checks for Special Monthly Bundles
        inputTapSleep 200 1200 1
    else
        inputTapSleep 200 750
    fi
    inputTapSleep 550 300 1                     # Collect rewards
    inputTapSleep 70 1810 1
    verifyRGB 20 1775 d49a61 "Collected daily/weekly/monthly offer." "Failed to collect daily/weekly/monthly offer."
}

# If red square, strenghen Crystal
strenghenCrystal() {
    inputTapSleep 760 1030 3                    # Crystal

    # TODO: Detect if free slot, and take it.

    inputTapSleep 550 1850                      # Strenghen Crystal
    inputTapSleep 200 1850                      # Close level up window
    inputTapSleep 70 1810
    verifyRGB 20 1775 d49a61 "Strenghened resonating Crystal." "Failed to Strenghen Resonating Crystal."
}

# Let's do a "free" summon
nobleTavern() {
    inputTapSleep 280 1370 3                    # The Noble Tavern
    inputTapSleep 600 1820 1                    # The noble tavern again

    until [ "$(testColorOR 875 835 "f38d67")" = "1" ];do                        # Looking for heart
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
    inputTapSleep 780 270 5                     # Oak Inn

    COUNT=0
    until [ "$COUNT" -ge "$totalAmountOakRewards" ]; do
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
        COUNT=$((COUNT + 1))                    # Increment
    done

    inputTapSleep 70 1810 3
    inputTapSleep 70 1810 0

    wait
    verifyRGB 20 1775 d49a61 "Attempted to collect Oak Inn presents." "Failed to collect Oak Inn presents."
}

# Test (X, Y, amountTimes, waitTime)
# test 560 350 3 0.5
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

loopUntilNotRGB 450 1775 "cc9261"               # Loops until the game has launched

inputTapSleep 970 380 0                         # Open menu for friends, etc

switchTab "Campaign"
sleep 3
switchTab "Dark Forest"
sleep 1
switchTab "Ranhorn"
sleep 1
switchTab "Campaign" true

if [ "$(testColorOR 740 205 "ffc15b")" = "1" ];then                             # Check if game is being updated
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
if [ "$doStrenghenCrystal" = true ]; then strenghenCrystal; fi
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
