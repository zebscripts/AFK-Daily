#!/bin/bash
# ##############################################################################
# Script Name   : print.sh
# Description   : Small lib containing basic print functions
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################
# Colors
cNc="\033[0m"        # Text Reset
cRed="\033[0;91m"    # Red
cGreen="\033[0;92m"  # Green
cYellow="\033[0;93m" # Yellow
cBlue="\033[0;94m"   # Blue
cPurple="\033[0;95m" # Purple
cCyan="\033[0;96m"   # Cyan
cWhite="\033[0;97m"  # White

withoutNewLine=false

checkNewLine() {
    if [ $withoutNewLine = true ]; then echo; fi
    withoutNewLine=false
}

colorTest() {
    for clfg in 30 31 32 33 34 35 36 37 90 91 92 93 94 95 96 97 39; do
        str=""
        for attr in 0 1 2 4 5 7; do
            str="$str\033[${attr};${clfg}m[attr=${attr};clfg=${clfg}]\033[0m"
        done
        echo -e "$str"
    done
}

printInColorTest() {
    printTask "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printSuccess "Lorem ipsum dolor sit amet"
    printTask "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printWarn "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printTask "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printError "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printInfo "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printTip "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
    printSuccess "Lorem ipsum ${cCyan}dolor${cNc} sit amet"
}

# Task
printTask() {
    checkNewLine
    withoutNewLine=true
    echo -n -e "${cBlue}[TASK]${cWhite}  $1${cNc} "
}

# Info
printInfo() {
    checkNewLine
    echo -e "${cBlue}[INFO]${cWhite}  $1${cNc}"
}

# Tip
printTip() {
    checkNewLine
    echo -e "${cPurple}[TIP]${cWhite}   $1${cNc}"
}

# Success
printSuccess() {
    withoutNewLine=false
    echo -e "${cGreen}$1${cNc}"
}

# Error
printError() {
    checkNewLine
    echo -e "${cRed}[ERROR]${cWhite} $1${cNc}"
}

# Warn
printWarn() {
    checkNewLine
    echo -e "${cYellow}[WARN]${cWhite}  $1${cNc}"
}
