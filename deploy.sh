#!/bin/bash

# TODO: Add colors

# --- Variables --- #
# CONFIG: Modify if needed. But if something doesn't work, it's not my fault.

# Probably you don't need to modify this. Do it if you know what you're doing, I won't blame you (unless you blame me).
personalDirectory="storage/emulated/0"
bluestacksDirectory="storage/emulated/0"
noxDirectory="data"

# Do not modify!
cNc='\033[0m'
cBlue='\033[0;34m'

# --- Functions --- #
# Restarts ADB server
function restartAdb() {
    printf "Restarting ADB... "
    adb kill-server
    adb start-server 1>/dev/null 2>&1
    printf "Done.\n"
}

# Check if afk-daily.sh has correct Line endings (LF)
# Params: file
function checkLineEndings() {
    printf "Checking Line endings of file $1... "
    if [[ $(head -1 afk-daily.sh | cat -A) =~ \^M ]]; then
        printf "Found CLRF! Converting to LF... "
        dos2unix $1 2>/dev/null

        if [[ $(head -1 afk-daily.sh | cat -A) =~ \^M ]]; then
            printf "\nFailed to convert $1 to LF. Please do it yourself.\n"
            printf "Exiting...\n"
            exit
        else
            printf "Success!\n"
        fi
    else
        printf "Passed!\n"
    fi
}

# Check if adb recognizes a device.
# Params: Platform
function checkForDevice() {
    # If parameters are sent
    if [ "$#" -gt "0" ]; then
        # Nox
        if [ "$1" == "Nox" ]; then
            printf "Searching for Nox through ADB... "
            adb connect localhost:62001 1>/dev/null
            if ! adb get-state 1>/dev/null; then
                printf "Exiting..."
                exit
            else
                printf "Found!\n"
            fi
        # Bluestacks
        elif [ "$1" == "Bluestacks" ]; then
            printf "Searching for Bluestacks through ADB... "
            if ! adb get-state 1>/dev/null; then
                printf "Exiting..."
                exit
            else
                printf "Found!\n"
            fi
        fi
    # If parameters aren't sent
    else
        printf "Searching for device through ADB... "

        # Checks if adb finds device
        if ! adb get-state 1>/dev/null 2>&1; then
            printf "\nNo device found! Please make sure it's connected.\nIf you're trying to use Nox, please run this script with './deploy nox'!\nExiting."
            exit
        else
            # Bluestacks
            if [[ $(adb devices) =~ emulator ]]; then
                printf "Found!\n"
                deploy "Bluestacks" "$bluestacksDirectory"
            # Personal
            else
                printf "Found!\n"
                deploy "Personal" "$personalDirectory"
            fi
        fi
    fi
}

# Makes a Dir (if it doesn't exist), pushes script into Dir, Executes script in Dir.
# Params: platform, directory
function deploy() {
    printf "Platform: ${cBlue}$1${cNc}\n"
    printf "Script Directory: ${cBlue}$2/scripts/afk-arena${cNc}\n"

    adb shell mkdir -p "$2"/scripts/afk-arena                # Create directories if they don't already exist
    adb push afk-daily.sh "$2"/scripts/afk-arena 1>/dev/null # Push the script to phone
    adb shell sh "$2"/scripts/afk-arena/afk-daily.sh "$2"    # Run script. Comment line if you don't want to run the script after pushing
}

# --- Script Start --- #
clear

checkLineEndings "afk-daily.sh"

# Check where to deploy
if [ "$1" ]; then
    # BlueStacks
    if [ "$1" == "bluestacks" ] || [ "$1" == "bs" ] || [ "$1" == "-bluestacks" ] || [ "$1" == "-bs" ]; then
        restartAdb
        checkForDevice "Bluestacks"
        deploy "Bluestacks" "$bluestacksDirectory"

    # Nox
    elif [ "$1" == "nox" ] || [ "$1" == "n" ] || [ "$1" == "-nox" ] || [ "$1" == "-n" ]; then
        restartAdb
        checkForDevice "Nox"
        deploy "Nox" "$noxDirectory"

    # Interactive Options
    elif [ "$1" == "dev" ]; then
        deploy "Personal" "$personalDirectory"
    fi
# Try to recognize device automatically
else
    restartAdb
    checkForDevice
fi
