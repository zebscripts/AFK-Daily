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

# Task
printTask() {
    echo -e "${cBlue}Task:${cNc} $1"
}

# Info
printInfo() {
    echo -e "${cCyan}Info:${cNc} $1"
}

# Tip
printTip() {
    echo -e "${cGreen}Tip:${cNc} $1"
}

# Success
printSuccess() {
    echo -e "${cGreen}Success:${cNc} $1"
}

# Error
printError() {
    echo -e "${cRed}Error:${cNc} $1"
}

# Warn
printWarn() {
    echo -e "${cYellow}Warning:${cNc} $1"
}
