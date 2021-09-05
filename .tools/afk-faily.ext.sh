#!/system/bin/sh
# ##############################################################################
# Script Name   : afk-daily.ext.sh
# Description   : Extension of the afk-daily.sh script, used for backup & tools
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# ##############################################################################
# Section       : Ranhorn
# ##############################################################################

# ##############################################################################
# Function Name : oakInn
# Descripton    : Collect Oak Inn
# ##############################################################################
oakInn() {
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "oakInn" >&2; fi
    inputTapSleep 780 270 5 # Oak Inn

    _oakInn_COUNT=0
    until [ "$_oakInn_COUNT" -ge "$totalAmountOakRewards" ]; do
        inputTapSleep 1050 950   # Friends
        inputTapSleep 1025 400 5 # Top Friend
        sleep 5

        oakInn_tryCollectPresent
        if [ "$oakRes" = 0 ]; then # If return value is still 0, no presents were found at first friend
            # Switch friend and search again
            inputTapSleep 1050 950   # Friends
            inputTapSleep 1025 530 5 # Second friend

            oakInn_tryCollectPresent
            if [ "$oakRes" = 0 ]; then # If return value is again 0, no presents were found at second friend
                # Switch friend and search again
                inputTapSleep 1050 950   # Friends
                inputTapSleep 1025 650 5 # Third friend

                oakInn_tryCollectPresent
                if [ "$oakRes" = 0 ]; then # If return value is still freaking 0, I give up
                    printInColor "WARN" "Couldn't collect Oak Inn presents, sowy." >&2
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
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "oakInn_presentTab" >&2; fi
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
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "oakInn_searchPresent " >&2; fi
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
    if [ "$DEBUG" -ge 4 ]; then printInColor "DEBUG" "oakInn_tryCollectPresent" >&2; fi
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
# Section       : Test
# ##############################################################################

# ##############################################################################
# Function Name : colorTest
# Description   : Print all colors
# Output        : stdout colors test
# ##############################################################################
colorTest() {
    for clfg in 30 31 32 33 34 35 36 37 90 91 92 93 94 95 96 97 39; do
        str=""
        for attr in 0 1 2 4 5 7; do
            str="$str\033[${attr};${clfg}m[attr=${attr};clfg=${clfg}]\033[0m"
        done
        echo "$str${cNc}"
    done
}

# ##############################################################################
# Function Name : printInColorTest
# Description   : Print all types of messages
# Output        : stdout colors test
# ##############################################################################
printInColorTest() {
    printInColor "DEBUG" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [${cGreen}25 W${cNc} / ${cRed}10 L${cNc}]"
    printInColor "DONE" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [${cGreen}25${cNc} W / ${cRed}10${cNc} L]"
    printInColor "ERROR" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [25 ${cGreen}W${cNc} / 10 ${cRed}L${cNc}]"
    printInColor "INFO" "Lorem ipsum ${cCyan}dolor${cNc} sit amet [${cGreen}25 W${cNc}]"
    printInColor "TEST" "Lorem ipsum ${cCyan}dolor${cNc} sit amet $(getCountersInColor 25)"
    printInColor "WARN" "Lorem ipsum ${cCyan}dolor${cNc} sit amet $(getCountersInColor 25 10)"
    printInColor "" "Lorem ipsum ${cCyan}dolor${cNc} sit amet $(getCountersInColor 0 0)"
}
