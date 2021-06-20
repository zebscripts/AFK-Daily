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

# Variables
withoutNewLine=false

checkNewLine() {
    if [ $withoutNewLine = true ]; then echo; fi
    withoutNewLine=false
}

printInNewLine() {
    if [ -n "$1" ]; then
        checkNewLine
        echo "$1"
    fi
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
    if [ $withoutNewLine = false ]; then
        echo -n "        "
    else
        withoutNewLine=false
    fi
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
