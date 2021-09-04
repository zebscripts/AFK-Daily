#!/bin/bash
# ##############################################################################
# Script Name   : update_git.sh
# Description   : Tools to work with git
# Output        : return 0/1
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# Consts
headRow=8
remoteURL="https://raw.githubusercontent.com/zebscripts/AFK-Daily/master/README.md"

# ##############################################################################
# Function Name : checkUpdate
# Descripton    : Check for update
# Output        : return 0/1
# ##############################################################################
checkUpdate() {
    localPatch=$(<README.md head -n$headRow | tail -n1 | sed -n 's/.*Version-\([^"]*\)-.*/\1/p')
    remotePatch=$(curl --silent $remoteURL | head -n$headRow | tail -n1 | sed -n 's/.*Version-\([^"]*\)-.*/\1/p')
    if [ "$localPatch" = "$remotePatch" ]; then
        return 0
    else
        return 1
    fi
}

checkUpdate
# echo -e "[WIP] |$localPatch|$remotePatch|$?|"
