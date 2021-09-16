#!/bin/bash
# ##############################################################################
# Script Name   : support_assist.sh
# Description   : Tool to check things about your emulator, network, ...
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

Color_Off="\033[0m"  # Text Reset
Red="\033[0;31m"     # Red
Yellow="\033[0;33m"  # Yellow
White="\033[0;37m"   # White
BRed="\033[1;31m"    # Red
BGreen="\033[1;32m"  # Green
BYellow="\033[1;33m" # Yellow
BBlue="\033[1;34m"   # Blue
BWhite="\033[1;37m"  # White

# ##############################################################################
# Function Name : checkEmulator
# Description   : Check emulator performance.
# Args          : <PLATFORM>
# Return        : 0 (OK), 1 (ADB not found), 2 (Emulator not found)
# ##############################################################################
checkEmulator() {
    echo -e "${BWhite}Checking Emulator${Color_Off}"

    # Auto detect nox & emulator <3
    adb="$(ps -W | grep -i nox_adb.exe | tr -s ' ' | cut -d ' ' -f 9-100 | sed -e 's/^/\//' -e 's/://' -e 's#\\#/#g')"
    if [ -n "$adb" ]; then # nox_adb.exe is running :)
        echo -e "${White}Using:\t\t\t${BBlue}Nox ADB${Color_Off}"
        "$adb" connect localhost:62001 1>/dev/null
        if "$adb" get-state 1>/dev/null; then # Check if Nox is running
            echo -e "${White}Emulator:\t\t${BBlue}Nox${Color_Off}"
        else # Nox not found
            echo -e "${White}Emulator:\t\t${Red}not found!${Color_Off}"
            return 2
        fi
    else # Else let's find ADB folder
        if [ -d "./adb" ]; then
            adb="./adb/platform-tools/adb.exe"
        elif [ -d "../adb" ]; then
            adb="./adb/platform-tools/adb.exe"
        else # ADB folder not found
            echo -e "${Red}ADB not found!${Color_Off}"
            return 1
        fi
        echo -e "${White}Using:\t\t\t${BBlue}ADB${Color_Off}"

        # Restart ADB
        "$adb" kill-server 1>/dev/null 2>&1
        "$adb" start-server 1>/dev/null 2>&1

        if "$adb" get-state 1>/dev/null 2>/dev/null; then # Check if BlueStacks is running
            echo -e "${White}Emulator:\t\t${BBlue}BlueStacks${Color_Off}"
        else                                                       # BlueStacks not found
            "$adb" connect localhost:21503 1>/dev/null 2>/dev/null # Try to connect to memu
            if "$adb" get-state 1>/dev/null 2>/dev/null; then      # Check if Memu is running
                echo -e "${White}Emulator:\t\t${BBlue}Memu${Color_Off}"
                echo -e "${Yellow}Memu is a liar! So config is not the true one, please send a capture of your settings.${Color_Off}"
                # Memu is doing magic with CPU, instead of CPU Cores it's separated CPUs, RAM is also IDK it's strange ...
                #$(($($adb shell "grep 'processor'  /proc/cpuinfo | tail -n1 | tr -s ' ' | cut -d ' ' -f 2") + 1)) # Return number of processor
            else # Memu not found
                echo -e "${White}Emulator:\t\t${Red}not found!${Color_Off}"
                return 2
            fi
        fi
    fi

    # Check config
    echo -n -e "${White}CPU Cores:${Color_Off}\t\t"
    cpuCores=$("$adb" shell "grep 'cpu cores' /proc/cpuinfo | uniq | tr -s ' ' | cut -d ' ' -f3") # Return number of CPU cores
    if [ "$cpuCores" -lt 2 ]; then
        echo -e "${BRed}$cpuCores${Color_Off}"
    elif [ "$cpuCores" -lt 4 ]; then
        echo -e "${BYellow}$cpuCores${Color_Off}"
    else echo -e "${BGreen}$cpuCores${Color_Off}"; fi

    echo -n -e "${White}RAM Total:${Color_Off}\t\t"
    memTotal=$("$adb" shell "grep 'MemTotal' /proc/meminfo | tr -s ' ' | cut -d ' ' -f 2") # Return memory capacity in kB
    if [ $((memTotal / 1048576)) -le 1 ]; then
        echo -e "${BRed}$(numfmt --from=iec --to=iec "${memTotal}K")${Color_Off}"
    elif [ $((memTotal / 1048576)) -le 2 ]; then
        echo -e "${BYellow}$(numfmt --from=iec --to=iec "${memTotal}K")${Color_Off}"
    else echo -e "${BGreen}$(numfmt --from=iec --to=iec "${memTotal}K")${Color_Off}"; fi

    echo -n -e "${White}Resolution:${Color_Off}\t\t"
    resolution=$("$adb" shell wm size | cut -d ' ' -f3)
    if [ "$resolution" = "1080x1920" ]; then
        echo -e "${BGreen}$resolution${Color_Off}"
    elif [ "$resolution" = "1920x1080" ]; then
        echo -e "${BYellow}$resolution${Color_Off}"
    else echo -e "${BRed}$resolution${Color_Off}"; fi

    if [ -n "$("$adb" shell pm list packages com.lilithgame.hgame.gp)" ]; then
        echo -e "${White}AFK Arena:\t\t${BGreen}installed${Color_Off}"
    else
        echo -e "${White}AFK Arena:\t\t${BRed}installed${Color_Off}"
    fi

    if [ -n "$("$adb" shell pm list packages com.lilithgames.hgame.gp.id)" ]; then
        echo -e "${White}AFK Arena Test Server:\t${BGreen}installed${Color_Off}"
    else
        echo -e "${White}AFK Arena Test Server:\t${BRed}not installed${Color_Off}"
    fi

    return 0
}

# ##############################################################################
# Function Name : checkNetwork
# Description   : Check network speed with different size files.
# Args          : <PLATFORM>
# ##############################################################################
checkNetwork() {
    echo -e "${BWhite}Checking Network${Color_Off}"

    echo -n -e "${White}Trying to download maximum out of 10G in 10s...${Color_Off}\t\t"
    output10G=$(curl -s --max-time 10 -4 -o /dev/null https://bouygues.testdebit.info/10G.iso -w "%{speed_download}")
    echo -e "${White}Average speed: $(checkNetwork_colorOutputSpeed "$output10G")${Color_Off}"

    echo -n -e "${White}Trying to download 1G...${Color_Off}\t\t\t\t"
    output1G=$(curl -s -4 -o /dev/null https://bouygues.testdebit.info/1G.iso -w "%{speed_download}")
    echo -e "${White}Average speed: $(checkNetwork_colorOutputSpeed "$output1G")${Color_Off}"

    echo -n -e "${White}Trying to download 100M...${Color_Off}\t\t\t\t"
    output100M=$(curl -s -4 -o /dev/null https://bouygues.testdebit.info/100M.iso -w "%{speed_download}")
    echo -e "${White}Average speed: $(checkNetwork_colorOutputSpeed "$output100M")${Color_Off}"

    echo -e "${White}Global average speed: $(checkNetwork_colorOutputSpeed $(((output10G + output1G + output100M) / 3)))${Color_Off} "
}

checkNetwork_colorOutputSpeed() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: checkNetwork_colorOutputSpeed <OUTPUT_SPEED>" >&2
        return 1
    fi
    if [ $(($1 / 1048576)) -le 1 ]; then
        echo -e "${BRed}$(numfmt --to=iec "$1")/s${Color_Off}"
    elif [ $(($1 / 1048576)) -le 2 ]; then
        echo -e "${BYellow}$(numfmt --to=iec "$1")/s${Color_Off}"
    else echo -e "${BGreen}$(numfmt --to=iec "$1")/s${Color_Off}"; fi
}

checkEmulator
echo
checkNetwork
