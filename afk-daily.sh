#!/system/bin/sh

# --- Variables --- #
# Probably you don't need to modify this. Do it if you know what you're doing, I won't blame you (unless you blame me).
DEVICEWIDTH=1080
pvpEvent=false # Set to `true` if "Heroes of Esperia" event is live
totalAmountOakRewards=3

# Do not modify
RGB=00000000
oakRes=0
if [ $# -gt 0 ]; then
    SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.dump"
    # SCREENSHOTLOCATION="/$1/scripts/afk-arena/screen.png"
    source /$1/scripts/afk-arena/config.sh
else
    SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.dump"
    # SCREENSHOTLOCATION="/storage/emulated/0/scripts/afk-arena/screen.png"
    source /storage/emulated/0/scripts/afk-arena/config.sh
fi

# --- Functions --- #
# Test function: take screenshot, get rgb, exit. Params: X, Y, amountTimes, waitTime
function test() {
    local COUNT=0
    until [ "$COUNT" -ge "$3" ]; do
        sleep $4
        getColor "$1" "$2"
        echo "RGB: $RGB"
        ((COUNT = COUNT + 1)) # Increment
    done
    exit
}

# Default wait time for actions
function wait() {
    sleep 2
}

# Starts the app
function startApp() {
    monkey -p com.lilithgame.hgame.gp 1 >/dev/null 2>/dev/null
    sleep 1
    disableOrientation
}

# Closes the app
function closeApp() {
    am force-stop com.lilithgame.hgame.gp >/dev/null 2>/dev/null
}

# Switches between last app
function switchApp() {
    input keyevent KEYCODE_APP_SWITCH
    input keyevent KEYCODE_APP_SWITCH
}

# Disables automatic orientation
function disableOrientation() {
    content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0
}

# Takes a screenshot and saves it
function takeScreenshot() {
    screencap "$SCREENSHOTLOCATION"
}

# Gets pixel color. Params: X, Y
function readRGB() {
    let offset="$DEVICEWIDTH"*"$2"+"$1"+3
    RGB=$(dd if="$SCREENSHOTLOCATION" bs=4 skip="$offset" count=1 2>/dev/null | hexdump -C)
    RGB=${RGB:9:9}
    RGB="${RGB// /}"
    # echo "[INFO] X: "$1" Y: "$2" RGB: $RGB"
}

# Sets RGB. Params: X, Y
function getColor() {
    takeScreenshot
    readRGB "$1" "$2"
}

# Verifies if X and Y have specific RGB. Params: X, Y, RGB, MessageSuccess, MessageFailure
function verifyRGB() {
    getColor "$1" "$2"
    if [ "$RGB" != "$3" ]; then
        echo "[ERROR] VerifyRGB: Failure! Expected "$3", but got "$RGB" instead."
        echo
        echo "[ERROR] $5"
        exit
    else
        echo "[OK] $4"
    fi
}

# Switches to another tab. Params: Tab name
function switchTab() {
    case "$1" in
    "Campaign")
        input tap 550 1850
        wait
        verifyRGB 450 1775 cc9261 "Switched to the Campaign Tab." "Failed to switch to the Campaign Tab."
        ;;
    "Dark Forest")
        input tap 300 1850
        wait
        verifyRGB 240 1775 d49a61 "Switched to the Dark Forest Tab." "Failed to switch to the Dark Forest Tab."
        ;;
    "Ranhorn")
        input tap 110 1850
        wait
        verifyRGB 20 1775 d49a61 "Switched to the Ranhorn Tab." "Failed to switch to the Ranhorn Tab."
        ;;
    "Chat")
        input tap 970 1850
        wait
        verifyRGB 550 1690 ffffff "Switched to the Chat Tab." "Failed to switch to the Chat Tab."
        ;;
    esac
}

# Loops until RGB is not equal. Params: Seconds, X, Y, RGB
function loopUntilRGB() {
    sleep "$1"
    getColor $2 $3
    while [ "$RGB" != "$4" ]; do
        sleep 1
        getColor $2 $3
    done
}

# Loops until RGB is equal. Params: Seconds, X, Y, RGB
function loopUntilNotRGB() {
    sleep "$1"
    getColor $2 $3
    while [ "$RGB" == "$4" ]; do
        sleep 1
        getColor $2 $3
    done
}

# Waits until a battle has ended. Params: Seconds
function waitBattleFinish() {
    sleep "$1"
    local finished=false
    while [ $finished == false ]; do
        getColor 560 350
        if [ "$RGB" == "b8894d" ]; then
            # Victory
            battleFailed=false
            finished=true
        elif [ "$RGB" == "171932" ]; then
            # Failed
            battleFailed=true
            finished=true
        elif [ "$RGB" == "45331d" ] || [ "$RGB" == "44331c" ]; then # First RGB local device, second bluestacks
            # Victory with reward
            battleFailed=false
            finished=true
        fi
        sleep 1
    done
}

# Buys an item from the Store. Params: X, Y
function buyStoreItem() {
    input tap $1 $2
    sleep 1
    input tap 550 1540
    sleep 1
    input tap 550 1700
}

# Searches for a "good" present in oak Inn
function oakSearchPresent() {
    # Swipe all the way down
    input swipe 400 1600 400 310 50
    sleep 1

    getColor 540 990 # 1 red 833f0e blue 903da0
    if [ "$RGB" == "833f0e" ]; then
        input tap 540 990 # Tap present
        sleep 3
        input tap 540 1650 # Ok
        sleep 1
        input tap 540 1650 # Collect reward
        oakRes=1
    else
        getColor 540 800 # 2 red a21a1a blue 9a48ab
        if [ "$RGB" == "a21a1a" ]; then
            input tap 540 800
            sleep 3
            input tap 540 1650 # Ok
            sleep 1
            input tap 540 1650 # Collect reward
            oakRes=1
        else
            getColor 540 610 # 3 red aa2b27 blue b260aa
            if [ "$RGB" == "aa2b27" ]; then
                input tap 540 610
                sleep 3
                input tap 540 1650 # Ok
                sleep 1
                input tap 540 1650 # Collect reward
                oakRes=1
            else
                getColor 540 420 # 4 red bc3f36 blue c58c7b
                if [ "$RGB" == "bc3f36" ]; then
                    input tap 540 420
                    sleep 3
                    input tap 540 1650 # Ok
                    sleep 1
                    input tap 540 1650 # Collect reward
                    oakRes=1
                else
                    getColor 540 220 # 5 red bb3734 blue 9442a5
                    if [ "$RGB" == "bb3734" ]; then
                        input tap 540 220
                        sleep 3
                        input tap 540 1650 # Ok
                        sleep 1
                        input tap 540 1650 # Collect reward
                        oakRes=1
                    else
                        # If no present found, search for other tabs
                        oakRes=0
                    fi
                fi
            fi
        fi
    fi
}

# Search available present tabs in Oak Inn
function oakPresentTab() {
    oakPresentTabs=0
    getColor 270 1800 # 1 gift c79663
    if [ "$RGB" == "c79663" ]; then
        ((oakPresentTabs = oakPresentTabs + 1000)) # Increment
    fi
    getColor 410 1800 # 2 gift bb824f
    if [ "$RGB" == "bb824f" ]; then
        ((oakPresentTabs = oakPresentTabs + 200)) # Increment
    fi
    getColor 550 1800 # 3 gift af6e3b
    if [ "$RGB" == "af6e3b" ]; then
        ((oakPresentTabs = oakPresentTabs + 30)) # Increment
    fi
    getColor 690 1800 # 4 gift b57b45
    if [ "$RGB" == "b57b45" ]; then
        ((oakPresentTabs = oakPresentTabs + 4)) # Increment
    fi
}

# Tries to collect a present from one Oak Inn friend
function oakTryCollectPresent() {
    # Search for a "good" present
    oakSearchPresent
    if [ $oakRes == 0 ]; then
        # If no present found, search for other tabs
        oakPresentTab
        case $oakPresentTabs in
        0)
            oakRes=0
            ;;
        4)
            input tap 690 1800
            sleep 3
            oakSearchPresent
            ;;
        30)
            input tap 550 1800
            sleep 3
            oakSearchPresent
            ;;
        34)
            input tap 550 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 690 1800
                sleep 3
                oakSearchPresent
            fi
            ;;
        200)
            input tap 410 1800
            sleep 3
            oakSearchPresent
            ;;
        204)
            input tap 410 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 690 1800
                sleep 3
                oakSearchPresent
            fi
            ;;
        230)
            input tap 410 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 550 1800
                sleep 3
                oakSearchPresent
            fi
            ;;
        234)
            input tap 410 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 550 1800
                sleep 3
                oakSearchPresent
                if [ $oakRes == 0 ]; then
                    input tap 690 1800
                    sleep 3
                    oakSearchPresent
                fi
            fi
            ;;
        1000)
            input tap 270 1800
            sleep 3
            oakSearchPresent
            ;;
        1004)
            input tap 270
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 690
                sleep 3
                oakSearchPresent
            fi
            ;;
        1030)
            input tap 270 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 550 1800
                sleep 3
                oakSearchPresent
            fi
            ;;
        1034)
            input tap 270 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 550 1800
                sleep 3
                oakSearchPresent
                if [ $oakRes == 0 ]; then
                    input tap 690 1800
                    sleep 3
                    oakSearchPresent
                fi
            fi
            ;;
        1200)
            input tap 270 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 410 1800
                sleep 3
                oakSearchPresent
            fi
            ;;
        1204)
            input tap 270 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 410 1800
                sleep 3
                oakSearchPresent
                if [ $oakRes == 0 ]; then
                    input tap 690 1800
                    sleep 3
                    oakSearchPresent
                fi
            fi
            ;;
        1230)
            input tap 270 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 410 1800
                sleep 3
                oakSearchPresent
                if [ $oakRes == 0 ]; then
                    input tap 550 1800
                    sleep 3
                    oakSearchPresent
                fi
            fi
            ;;
        1234)
            input tap 270 1800
            sleep 3
            oakSearchPresent
            if [ $oakRes == 0 ]; then
                input tap 410 1800
                sleep 3
                oakSearchPresent
                if [ $oakRes == 0 ]; then
                    input tap 550 1800
                    sleep 3
                    oakSearchPresent
                    if [ $oakRes == 0 ]; then
                        input tap 690 1800
                        sleep 3
                        oakSearchPresent
                    fi
                fi
            fi
            ;;
        esac
    fi
}

# Checks where to end the script
function checkWhereToEnd() {
    case "$endAt" in
    "oak")
        switchTab "Ranhorn"
        input tap 780 280
        ;;
    "soren")
        switchTab "Ranhorn"
        input tap 380 360
        sleep 3
        input tap 290 860
        sleep 1
        input tap 970 890
        ;;
    "mail")
        input tap 960 630
        ;;
    "chat")
        switchTab "Chat"
        ;;
    "tavern")
        switchTab "Ranhorn"
        input tap 300 1400
        ;;
    "merchants")
        input tap 120 290
        ;;
    "campaign")
        input tap 550 1850
        ;;
    "championship")
        switchTab "Dark Forest"
        input tap 740 1050
        sleep 2
        if [ "$pvpEvent" == false ]; then
            input tap 550 1370
        else
            input tap 550 1680
        fi
        ;;
    *)
        echo "[WARN] Unknown location to end script on. Ignoring..."
        ;;
    esac
}

# Repeat a battle for as long as totalAmountArenaTries
function quickBattleGuildBosses() {
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountGuildBossTries" ]; do
        input tap 710 1840
        wait
        input tap 720 1300
        sleep 1
        input tap 550 800
        input tap 550 800
        sleep 1
        ((COUNT = COUNT + 1)) # Increment
    done
}

# Loots afk chest
function lootAfkChest() {
    input tap 550 1500
    sleep 1
    input tap 750 1350
    sleep 3

    # Tap campaign in case of level up
    input tap 550 1850
    sleep 1

    wait
    verifyRGB 450 1775 cc9261 "AFK Chest looted." "Failed to loot AFK Chest."
}

# Challenges a boss in the campaign
function challengeBoss() {
    input tap 550 1650
    sleep 1

    # Check if boss
    getColor 550 740
    if [ "$RGB" = "f2d79f" ]; then
        input tap 550 1450
    fi

    sleep 2
    input tap 550 1850
    sleep 1
    input tap 80 1460
    wait
    input tap 230 960
    sleep 1

    # Check for multi-battle
    getColor 450 1775
    if [ "$RGB" != "cc9261" ]; then
        input tap 70 1810
    fi

    wait
    verifyRGB 450 1775 cc9261 "Challenged boss in campaign." "Failed to fight boss in Campaign."
}

# Collects fast rewards
function fastRewards() {
    input tap 950 1660
    sleep 1
    input tap 710 1260
    sleep 2
    input tap 560 1800
    sleep 1
    input tap 400 1250

    wait
    verifyRGB 450 1775 cc9261 "Fast rewards collected." "Failed to collect fast rewards."
}

# Collects and sends companion points, as well as auto lending mercenaries
function collectFriendsAndMercenaries() {
    input tap 970 810
    sleep 1
    input tap 930 1600
    wait
    input tap 720 1760
    wait
    input tap 990 190
    wait
    input tap 630 1590
    wait
    input tap 750 1410
    sleep 1
    input tap 70 1810
    input tap 70 1810

    # TODO: Check if its necessary to send mercenaries

    wait
    verifyRGB 450 1775 cc9261 "Sent and recieved companion points, as well as auto lending mercenaries." "Failed to collect/send companion points or failed to auto lend mercenaries."
}

# Starts Solo bounties
function soloBounties() {
    input tap 600 1320
    sleep 1

    # Check if there are bounties to collect
    # getColor 660 520
    # until [ "$RGB" != "7af7ee" ]; do
    #     input tap 915 470
    #     sleep 1
    #     getColor 660 520
    # done

    # TODO: Before doing all this, check if there are bounties to send heroes on
    # input tap 915 470
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # input tap 915 680
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # input tap 915 890
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # input tap 915 1100
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # input tap 915 1310
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # input swipe 550 1100 550 800 500
    # wait
    # input tap 915 960
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # input tap 915 1170
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # input tap 915 1380
    # wait
    # input tap 350 1160
    # input tap 750 1160

    input tap 780 1550 # Collect all
    input tap 350 1550 # Dispatch all
    wait
    input tap 550 1500 # Confirm

    wait
    verifyRGB 650 1740 a7541a "Collected/dispatched solo bounties." "Failed to collect/dispatch solo bounties."
}

# Starts Team Bounties
function teamBounties() {
    ## For testing only! Keep as comment ##
    # input tap 600 1320
    # sleep 1
    ## End of testing ##
    input tap 910 1770
    wait

    # Check if there are bounties to collect
    # getColor 650 570
    # until [ "$RGB" != "84fff8" ]; do
    #     input tap 930 550
    #     sleep 1
    #     getColor 650 570
    # done

    # input tap 930 550
    # wait
    # input tap 350 1160
    # input tap 750 1160
    # wait
    # input tap 930 770
    # wait
    # input tap 350 1160
    # input tap 750 1160

    input tap 780 1550 # Collect all
    input tap 350 1550 # Dispatch all
    wait
    input tap 550 1500 # Confirm

    wait
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Collected/dispatched team bounties." "Failed to collect/dispatch team bounties."
}

# Does the daily arena of heroes battles
function arenaOfHeroes() {
    input tap 740 1050
    sleep 2
    if [ "$pvpEvent" == false ]; then
        input tap 550 450
    else
        input tap 550 900
    fi
    sleep 2
    input tap 1000 1800
    wait
    input tap 980 410
    sleep 2
    input tap 540 1800
    sleep 2

    # Check for new season
    getColor 200 1800
    if [ "$RGB" != "382314" ] && [ "$RGB" != "382214" ]; then
        # Repeat a battle for as long as totalAmountArenaTries
        local COUNT=0
        until [ "$COUNT" -ge "$totalAmountArenaTries" ]; do
            # Refresh
            # input tap 815 540
            # wait
            # Fight specific opponent
            case $arenaHeroesOpponent in
            1)
                input tap 820 700
                ;;
            2)
                input tap 820 870
                ;;
            3)
                input tap 820 1050
                ;;
            4)
                input tap 820 1220
                ;;
            5)
                input tap 820 1400
                ;;
            esac
            sleep 2
            input tap 550 1850
            waitBattleFinish 2
            if [ "$battleFailed" == false ]; then
                input tap 550 1550 # Collect
                sleep 2
            fi
            input tap 550 1550 # Finish battle
            sleep 3
            ((COUNT = COUNT + 1)) # Increment
        done

        input tap 1000 380
        wait
    else
        echo "[WARN] Unable to fight in the Arena of Heroes because a new season is soon launching."
    fi

    input tap 70 1810
    wait
    verifyRGB 760 70 1f2d3a "Checked the Arena of Heroes out." "Failed to check the Arena of Heroes out."
}

# Does the daily Legends tournament battles
function legendsTournament() {
    ## For testing only! Keep as comment ##
    # input tap 740 1050
    # sleep 1
    ## End of testing ##
    if [ "$pvpEvent" == false ]; then
        input tap 550 900
    else
        input tap 550 1450
    fi
    sleep 2
    input tap 550 280
    sleep 3
    input tap 550 1550
    sleep 3
    input tap 1000 1800
    input tap 990 380
    wait

    # Repeat a battle for as long as totalAmountArenaTries
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountArenaTries-2" ]; do
        input tap 550 1840
        sleep 4
        input tap 800 1140
        sleep 4
        input tap 550 1850
        sleep 4
        input tap 770 1470
        sleep 4
        input tap 550 800
        sleep 4
        ((COUNT = COUNT + 1)) # Increment
    done

    input tap 70 1810
    sleep 2
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Battled at the Legends Tournament." "Failed to battle at the Legends Tournament."
}

# Battles once in the kings tower
function kingsTower() {
    input tap 500 870
    sleep 2
    input tap 550 900
    sleep 2
    input tap 540 1350
    sleep 2
    input tap 550 1850
    sleep 2
    input tap 80 1460
    sleep 1
    input tap 230 960
    wait
    input tap 70 1810
    wait
    input tap 70 1810

    wait
    verifyRGB 240 1775 d49a61 "Battled at the Kings Tower." "Failed to battle at the Kings Tower."
}

# Battles against Guild boss Wrizz
function guildHunts() {
    input tap 380 360
    sleep 10

    # Check for fortune chest
    getColor 380 500
    if [ "$RGB" == "793929" ]; then
        input tap 560 1300
        sleep 2
        input tap 540 1830
    fi
    wait

    input tap 290 860
    sleep 3

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
    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountGuildBossTries" ]; do
        # Check if its possible to fight wrizz
        # getColor 710 1840
        # if [ "$RGB" != "9de7bd" ]; then
        #     echo "Enough of wrizz! Going out."
        #     break
        # fi

        input tap 710 1840
        # TODO: I think right here should be done a check for "some resources have exceeded their maximum limit". I have ascreenshot somewhere of this.
        wait
        input tap 720 1300
        sleep 1
        input tap 550 800
        input tap 550 800
        sleep 1
        ((COUNT = COUNT + 1)) # Increment
    done

    # Soren
    input tap 970 890
    sleep 1

    getColor 715 1815
    # If Soren is open
    if [ "$RGB" == "8ae5c4" ]; then
        quickBattleGuildBosses

    # If Soren is closed
    elif [ "$canOpenSoren" == true ]; then
        getColor 580 1753

        # If soren is "openable"
        if [ "$RGB" == "fae0ac" ]; then
            input tap 550 1850
            wait
            input tap 700 1250
            sleep 1
            quickBattleGuildBosses
        fi
    fi
    input tap 70 1810

    sleep 1
    verifyRGB 70 1000 a9a95f "Battled Wrizz and possibly Soren." "Failed to battle Wrizz and possibly Soren."
}

# Battles against the Twisted Realm Boss
function twistedRealmBoss() {
    # TODO: Choose if 2x or not
    # TODO: Choose a formation (Would be dope!)
    ## For testing only! Keep as comment ##
    # input tap 380 360
    # sleep 3
    ## End of testing ##

    input tap 820 820
    sleep 2

    # Check if TR is being calculated
    getColor 540 1220
    if [ "$RGB" == "9aedc1" ]; then
        echo "[WARN] Unable to fight in the Twisted Realm because it's being calculated."
    else
        input tap 550 1850
        sleep 2
        input tap 550 1850

        # Start checking for a finished Battle after 40 seconds
        loopUntilRGB 30 420 380 ca9c5d

        sleep 1
        input tap 550 800
        sleep 3
        input tap 550 800
        wait

    # TODO: Repeat battle if variable says so
    fi

    input tap 70 1810
    wait
    input tap 70 1810

    sleep 1
    verifyRGB 20 1775 d49a61 "Checked Twisted Realm Boss out." "Failed to check the Twisted Realm out."
}

# Buy items from store
function buyFromStore() {
    input tap 330 1650
    sleep 1

    # Dust
    if [ "$buyStoreDust" == true ]; then
        buyStoreItem 180 840
        wait
    fi
    # Poe Coins
    if [ "$buyStorePoeCoins" == true ]; then
        buyStoreItem 670 1430
        wait
    fi
    # Emblems
    if [ "$buyStoreEmblems" == true ]; then
        buyStoreItem 180 1430
        wait
    fi
    input tap 70 1810

    wait
    verifyRGB 20 1775 d49a61 "Visited the Store." "Failed to visit the Store."
}

# Collects
function collectQuestChests() {
    input tap 960 250
    wait

    # Collect Quests
    getColor 700 670
    while [ "$RGB" == "82fdf5" ]; do
        input tap 930 680
        wait
        getColor 700 670
    done

    input tap 330 430
    wait
    input tap 580 600
    input tap 500 430
    wait
    input tap 580 600
    input tap 660 430
    wait
    input tap 580 600
    input tap 830 430
    wait
    input tap 580 600
    input tap 990 430
    wait
    input tap 580 600
    wait
    input tap 70 1650

    sleep 1
    verifyRGB 20 1775 d49a61 "Collected daily quest chests." "Failed to collect daily quest chests."
}

# Collects mail
collectMail() {
    input tap 960 630
    wait
    input tap 790 1470
    wait
    input tap 110 1850
    wait
    input tap 110 1850

    wait
    verifyRGB 20 1775 d49a61 "Collected Mail." "Failed to collect Mail."
}

# Collects Daily/Weekly/Monthly from the merchants page
function collectMerchants() {
    input tap 120 300 # Merchants
    sleep 3
    input tap 510 1820 # Merchant Ship
    sleep 2
	
	getColor 370 650
	# Checks for Special Daily Bundles
	if [ "$RGB" != "ba0a07" ]; then
	    input tap 200 1200
	    wait
	else
	    input tap 200 750 # Free bundle
	fi
    sleep 1
    input tap 550 300 # Collect rewards
    sleep 1
    input tap 280 1620 # Weekly Deals
    sleep 1
	
	getColor 370 650
	# Checks for Special Weekly Bundles
	if [ "$RGB" != "ba0a07" ]; then
	    input tap 200 1200
	    wait
	else
	    input tap 200 750 # Free bundle
	fi
    sleep 1
    input tap 550 300 # Collect rewards
    sleep 1
    input tap 460 1620 # Monthly Deals
    sleep 1
	
	getColor 370 650
	# Checks for Special Monthly Bundles
	if [ "$RGB" != "ba0a07" ]; then
	    input tap 200 1200
	    wait
	else
	    input tap 200 750 # Free bundle
	fi
    sleep 1
    input tap 550 300 # Collect rewards
    sleep 1
    input tap 70 1810

    sleep 1
    verifyRGB 20 1775 d49a61 "Collected daily/weekly/monthly offer." "Failed to collect daily/weekly/monthly offer."
}

# Collect Oak Inn
function oakInn() {
    input tap 780 270 # Oak Inn
    sleep 5

    local COUNT=0
    until [ "$COUNT" -ge "$totalAmountOakRewards" ]; do
        input tap 1050 950 # Friends
        wait
        input tap 1025 400 # Top Friend
        sleep 5

        oakTryCollectPresent
        # If return value is still 0, no presents were found at first friend
        if [ $oakRes == 0 ]; then
            # Switch friend and search again
            input tap 1050 950 # Friends
            wait
            input tap 1025 530 # Second friend
            sleep 5

            oakTryCollectPresent
            # If return value is again 0, no presents were found at second friend
            if [ $oakRes == 0 ]; then
                # Switch friend and search again
                input tap 1050 950 # Friends
                wait
                input tap 1025 650 # Third friend
                sleep 5

                oakTryCollectPresent
                # If return value is still freaking 0, I give up
                if [ $oakRes == 0 ]; then
                    echo "[WARN] Couldn't collect Oak Inn presents, sowy."
                    break
                fi
            fi
        fi

        sleep 2
        ((COUNT = COUNT + 1)) # Increment
    done

    input tap 70 1810
    sleep 3
    input tap 70 1810

    wait
    verifyRGB 20 1775 d49a61 "Attempted to collect Oak Inn presents." "Failed to collect Oak Inn presents."
}

# Test function (X, Y, amountTimes, waitTime)
# test 380 500 3 0.5
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
echo "[INFO] Starting script..."
echo
closeApp
sleep 0.5
startApp
sleep 10

# Loops until the game has launched
getColor 450 1775
while [ "$RGB" != "cc9261" ]; do
    sleep 1
    getColor 450 1775
done
sleep 1

input tap 970 380 # Open menu for friends, etc

switchTab "Campaign"
sleep 3
switchTab "Dark Forest"
sleep 1
switchTab "Ranhorn"
sleep 1
switchTab "Campaign"

# Check if game is being updated
getColor 740 205
if [ "$RGB" == "ffc15b" ]; then
    echo "[WARN] Game is being updated!"
    if [ "$waitForUpdate" == true ]; then
        echo "[INFO]: Waiting for game to finish update..."
        loopUntilNotRGB 5 740 205 ffc15b
        echo "[OK]: Game finished updating."
    else
        echo "[WARN]: Not waiting for update to finish."
    fi
fi

# CAMPAIGN TAB
switchTab "Campaign"
lootAfkChest
challengeBoss
fastRewards
collectFriendsAndMercenaries
lootAfkChest

# DARK FOREST TAB
switchTab "Dark Forest"
soloBounties
teamBounties
arenaOfHeroes
legendsTournament
kingsTower

# RANHORN TAB
switchTab "Ranhorn"
guildHunts
twistedRealmBoss
buyFromStore
collectQuestChests
collectMail
if [ "$collectMerchantFreebies" == true ]; then collectMerchants; fi
if [ "$collectOakPresents" == true ]; then oakInn; fi

# Ends at given location
sleep 1
checkWhereToEnd

echo
echo "[INFO] End of script!"
exit
