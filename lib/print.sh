#!/bin/bash
# ##############################################################################
# Script Name   : print.sh
# Description   : Small lib containing basic print functions
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################
# Colors
cNc='\033[0m'
cRed='\033[0;31m'
cBlue='\033[0;34m'
cGreen='\033[0;32m'
cYellow='\033[0;33m'
cCyan='\033[0;36m'

withoutNewLine=false

# Task
printTask() {
    if [ $withoutNewLine = true ]; then echo; fi
    echo -n -e "${cBlue}[TASK]${cNc}  $1 "
    withoutNewLine=true
}

# Info
printInfo() {
    if [ $withoutNewLine = true ]; then echo; fi
    echo -e "${cCyan}[INFO]${cNc}  $1"
    withoutNewLine=false
}

# Tip
printTip() {
    if [ $withoutNewLine = true ]; then echo; fi
    echo -e "${cGreen}[TIP]${cNc}   $1"
    withoutNewLine=false
}

# Success
printSuccess() {
    echo -e "${cGreen}$1${cNc}"
    withoutNewLine=false
}

# Error
printError() {
    if [ $withoutNewLine = true ]; then echo; fi
    echo -e "${cRed}[ERROR]${cNc} $1"
    withoutNewLine=false
}

# Warn
printWarn() {
    if [ $withoutNewLine = true ]; then echo; fi
    echo -e "${cYellow}[WARN]${cNc}  $1"
    withoutNewLine=false
}
