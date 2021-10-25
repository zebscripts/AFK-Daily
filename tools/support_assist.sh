#!/bin/bash
# ##############################################################################
# Script Name   : support_assist.sh
# Description   : Tool to check things about your emulator, network, ...
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

Color_Off="\033[0m"  # Text Reset
IRed="\033[0;91m"    # Red
IGreen="\033[0;92m"  # Green
IYellow="\033[0;93m" # Yellow
IBlue="\033[0;94m"   # Blue
ICyan="\033[0;96m"   # Cyan
IWhite="\033[0;97m"  # White

# ##############################################################################
# Function Name : checkEmulator
# Description   : Check emulator performance.
# Args          : <PLATFORM>
# Return        : 0 (OK), 1 (ADB not found), 2 (Emulator not found)
# ##############################################################################
checkEmulator() {
    echo -e "${IWhite}Checking Emulator${Color_Off}"

    # Auto detect nox & emulator <3
    case "$(uname -s)" in # Check OS
    Darwin | Linux)       # Mac / Linux
        adb="$(ps | grep -i nox_adb.exe | tr -s ' ' | cut -d ' ' -f 9-100 | sed -e 's/^/\//' -e 's/://' -e 's#\\#/#g')"
        ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) # Windows
        adb="$(ps -W | grep -i nox_adb.exe | tr -s ' ' | cut -d ' ' -f 9-100 | sed -e 's/^/\//' -e 's/://' -e 's#\\#/#g')"
        ;;
    esac
    if [ -n "$adb" ]; then # nox_adb.exe is running :)
        echo -e "${Color_Off}Using:\t\t\t${IBlue}Nox ADB${Color_Off}"
        "$adb" connect localhost:62001 1>/dev/null
        if "$adb" get-state 1>/dev/null; then # Check if Nox is running
            echo -e "${Color_Off}Emulator:\t\t${IBlue}Nox${Color_Off}"
        else # Nox not found
            echo -e "${Color_Off}Emulator:\t\t${IRed}not found!${Color_Off}"
            return 2
        fi
    else
        # Else let's find ADB
        if command -v adb &>/dev/null; then # Check if ADB is already installed (with Path)
            adb="adb"
            echo -e "${Color_Off}Using:\t\t\t${IBlue}Path adb${Color_Off}"
        elif [ -d "./adb" ]; then
            adb="./adb/platform-tools/adb.exe"
            echo -e "${Color_Off}Using:\t\t\t${IBlue}./adb/platform-tools/adb.exe${Color_Off}"
        elif [ -d "../adb" ]; then
            adb="../adb/platform-tools/adb.exe"
            echo -e "${Color_Off}Using:\t\t\t${IBlue}../adb/platform-tools/adb.exe${Color_Off}"
        else # ADB folder not found
            echo -e "${IRed}ADB not found!${Color_Off}"
            return 1
        fi

        # Restart ADB
        "$adb" kill-server 1>/dev/null 2>&1
        "$adb" start-server 1>/dev/null 2>&1

        if "$adb" get-state 1>/dev/null 2>/dev/null; then # Check if BlueStacks is running
            echo -e "${Color_Off}Emulator:\t\t${IBlue}BlueStacks${Color_Off}"
        else                                                       # BlueStacks not found
            "$adb" connect localhost:21503 1>/dev/null 2>/dev/null # Try to connect to memu
            if "$adb" get-state 1>/dev/null 2>/dev/null; then      # Check if Memu is running
                echo -e "${Color_Off}Emulator:\t\t${IBlue}Memu${Color_Off}"
                echo -e "${Yellow}Memu is a liar! So config is not the true one, please send a capture of your settings.${Color_Off}"
                # Memu is doing magic with CPU, instead of CPU Cores it's separated CPUs, RAM is also IDK it's strange ...
                #$(($($adb shell "grep 'processor'  /proc/cpuinfo | tail -n1 | tr -s ' ' | cut -d ' ' -f 2") + 1)) # Return number of processor
            else # Memu not found
                echo -e "${Color_Off}Emulator:\t\t${IRed}not found!${Color_Off}"
                return 2
            fi
        fi
    fi

    # Check config
    echo -n -e "${Color_Off}CPU Cores:${Color_Off}\t\t"
    cpuCores=$("$adb" shell "grep 'cpu cores' /proc/cpuinfo | uniq | tr -s ' ' | cut -d ' ' -f3") # Return number of CPU cores
    if [ "$cpuCores" -lt 2 ]; then
        echo -e "${IRed}$cpuCores${Color_Off}"
    elif [ "$cpuCores" -lt 4 ]; then
        echo -e "${IYellow}$cpuCores${Color_Off}"
    else echo -e "${IGreen}$cpuCores${Color_Off}"; fi

    echo -n -e "${Color_Off}RAM Total:${Color_Off}\t\t"
    memTotal=$("$adb" shell "grep 'MemTotal' /proc/meminfo | tr -s ' ' | cut -d ' ' -f 2") # Return memory capacity in kB
    if [ $((memTotal / 1048576)) -le 1 ]; then
        echo -e "${IRed}$(numfmt --from=iec --to=iec "${memTotal}K")${Color_Off}"
    elif [ $((memTotal / 1048576)) -le 2 ]; then
        echo -e "${IYellow}$(numfmt --from=iec --to=iec "${memTotal}K")${Color_Off}"
    else echo -e "${IGreen}$(numfmt --from=iec --to=iec "${memTotal}K")${Color_Off}"; fi

    echo -n -e "${Color_Off}Resolution:${Color_Off}\t\t"
    resolution=$("$adb" shell wm size | cut -d ' ' -f3)
    if [ "$resolution" = "1080x1920" ]; then
        echo -e "${IGreen}$resolution${Color_Off}"
    elif [ "$resolution" = "1920x1080" ]; then
        echo -e "${IYellow}$resolution${Color_Off}"
    else echo -e "${IRed}$resolution${Color_Off}"; fi

    if [ -n "$("$adb" shell pm list packages com.lilithgame.hgame.gp)" ]; then
        echo -e "${Color_Off}AFK Arena:\t\t${IGreen}installed${Color_Off}"
    else
        echo -e "${Color_Off}AFK Arena:\t\t${IRed}installed${Color_Off}"
    fi

    if [ -n "$("$adb" shell pm list packages com.lilithgames.hgame.gp.id)" ]; then
        echo -e "${Color_Off}AFK Arena Test Server:\t${IGreen}installed${Color_Off}"
    else
        echo -e "${Color_Off}AFK Arena Test Server:\t${IRed}not installed${Color_Off}"
    fi

    return 0
}

# ##############################################################################
# Function Name : checkNetwork
# Description   : Check network speed with different size files.
# Args          : <PLATFORM>
# ##############################################################################
checkNetwork() {
    echo -e "${IWhite}Checking Network with a maximum of 5 seconds per request:${Color_Off}"

    output10G=$(curl -s --max-time 5 -4 -o /dev/null https://bouygues.testdebit.info/10G.iso -w "%{speed_download}")
    echo -e "${Color_Off}10GB average speed:   $(checkNetwork_colorOutputSpeed "${output10G:-0}")${Color_Off}"

    output1G=$(curl -s --max-time 5 -4 -o /dev/null https://bouygues.testdebit.info/1G.iso -w "%{speed_download}")
    echo -e "${Color_Off}1GB average speed:    $(checkNetwork_colorOutputSpeed "${output1G:-0}")${Color_Off}"

    output100M=$(curl -s --max-time 5 -4 -o /dev/null https://bouygues.testdebit.info/100M.iso -w "%{speed_download}")
    echo -e "${Color_Off}100MB average speed:  $(checkNetwork_colorOutputSpeed "${output100M:-0}")${Color_Off}"

    echo
    echo -e "${Color_Off}Global average speed: $(checkNetwork_colorOutputSpeed $(((output10G + output1G + output100M) / 3)))${Color_Off} "
}

# ##############################################################################
# Function Name : checkNetwork_colorOutputSpeed
# Description   : Color & format output speed
# Args          : <OUTPUT_SPEED>
# Return        : Echo Speed colorized & formated
# ##############################################################################
checkNetwork_colorOutputSpeed() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: checkNetwork_colorOutputSpeed <OUTPUT_SPEED>" >&2
        return 1
    fi
    if [ $(($1 / 1048576)) -le 1 ]; then
        echo -e "${IRed}$(numfmt --to=iec "$1")/s${Color_Off}"
    elif [ $(($1 / 1048576)) -le 2 ]; then
        echo -e "${IYellow}$(numfmt --to=iec "$1")/s${Color_Off}"
    else echo -e "${IGreen}$(numfmt --to=iec "$1")/s${Color_Off}"; fi
}

# ##############################################################################
# Function Name : killAll
# Description   : Kill everything linked to the script (Emulator & ADB)
# ##############################################################################
killAll() {
    # Bluestacks 4 & 5
    killAll_facto "Bluestacks"
    killAll_facto "BstkSVC"

    # Memu
    killAll_facto "MEmu"

    # Nox
    killAll_facto "Nox"

    # ADB
    killAll_facto "adb"
}

# ##############################################################################
# Function Name : killAll_facto
# Description   : I hate to write the same line 10 times :)
# ##############################################################################
killAll_facto() {
    case "$(uname -s)" in # Check OS
    Darwin | Linux)       # Mac / Linux
        ps | awk "/$1/,NF=1" | xargs kill -f
        ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) # Windows
        KILL_PID=$(ps -W | grep -i "$1" | tr -s ' ' | cut -d ' ' -f2)
        if [ -n "$KILL_PID" ]; then
            echo "Killing $1 processes..."
            # Do not put quotes around $KILL_PID as kill won't kill every process returned
            /bin/kill -f $KILL_PID
        fi
        ;;
    esac
}

# ##############################################################################
# Function Name : run
# Description   : Run all checks
# ##############################################################################
run() {
    checkEmulator
    echo
    checkNetwork
}

# ##############################################################################
# Function Name : show_help
# ##############################################################################
show_help() {
    echo -e "${Color_Off}"
    echo -e "  ___                                    _         _               _        _   "
    echo -e " / __|  _  _   _ __   _ __   ___   _ _  | |_      /_\    ___  ___ (_)  ___ | |_ "
    echo -e " \__ \ | || | | '_ \ | '_ \ / _ \ | '_| |  _|    / _ \  (_-< (_-< | | (_-< |  _|"
    echo -e " |___/  \_,_| | .__/ | .__/ \___/ |_|    \__|   /_/ \_\ /__/ /__/ |_| /__/  \__|"
    echo -e "              |_|    |_|                                                        "
    echo
    echo -e "USAGE: ${IYellow}support_assist.sh ${ICyan}[OPTIONS]${Color_Off}"
    echo
    echo -e "DESCRIPTION"
    echo -e "   Automate check to support assistance."
    echo -e "   More info: https://github.com/zebscripts/AFK-Daily"
    echo
    echo -e "REMARKS"
    echo -e "   Need to be run from AFK-Daily or tools folder."
    echo -e "   Require the emulator and ADB to be running."
    echo
    echo -e "OPTIONS"
    echo -e "   ${ICyan}-h${Color_Off}"
    echo -e "      Show help."
    echo -e "   ${ICyan}-e${Color_Off}"
    echo -e "      Check Emulator."
    echo -e "   ${ICyan}-k${Color_Off}"
    echo -e "      Kill everything linked to the script (Emulator & ADB)."
    echo -e "   ${ICyan}-n${Color_Off}"
    echo -e "      Check Network."
    echo -e "      Remark: May take a few seconds."
}

if [ -z "$1" ]; then
    run
    exit 0
fi

while getopts ":hekn" opt; do
    case $opt in
    h)
        show_help
        exit 0
        ;;
    e)
        checkEmulator
        ;;
    k)
        killAll
        ;;
    n)
        checkNetwork
        ;;
    \?)
        echo "$OPTARG : Invalid option"
        exit 1
        ;;
    esac
done
