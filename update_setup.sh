#!/bin/bash
# ##############################################################################
# Script Name   : update_setup.sh
# Description   : Tools to update ini files
# Args          : [-h] [-a] [-c] [-l]
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# ##############################################################################
# Section       : AFKScript
# ##############################################################################

# ##############################################################################
# Function Name : cleanAKFScript
# Descripton    : Remove old file
# ##############################################################################
cleanAKFScript() {
    rm -f .*afkscript.tmp
}

# ##############################################################################
# Function Name : convertAKFScriptTMPtoINI
# Descripton    : Convert old file & format
# ##############################################################################
convertAKFScriptTMPtoINI() {
    for f in .*afkscript.tmp; do
        if [ ! -f "$f" ]; then continue; fi;
        echo "# afk-daily" > "$(basename "$f" .tmp)".ini
        case "$(uname -s)" in                   # Check OS
            Darwin|Linux)                       # Mac / Linux
                echo "lastCampaign=$(date -r "$(cat "$f")" +%Y%m%d)" >> "$(basename "$f" .tmp)".ini
                ;;
            CYGWIN*|MINGW32*|MSYS*|MINGW*)      # Windows
                echo "lastCampaign=$(date -d "@$(cat "$f")" +%Y%m%d)" >> "$(basename "$f" .tmp)".ini
                ;;
        esac
        echo "$f converted"
    done
}

# ##############################################################################
# Function Name : updateAFKScript
# Descripton    : Update file, add new params
# ##############################################################################
updateAFKScript() {
    # Date 3 days ago
    # Saturday 2 weeks ago
    case "$(uname -s)" in                       # Check OS
        Darwin|Linux)                           # Mac / Linux
            lastCampaign_default=$(date -v -3d +%Y%m%d)
            lastWeekly_default=$(date -v -sat -v -7d +%Y%m%d)
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)          # Windows
            lastCampaign_default=$(date -d 'now - 3day' +%Y%m%d)
            lastWeekly_default=$(date -dlast-saturday +%Y%m%d)
            ;;
    esac

    for f in .*afkscript.ini; do
        if [ ! -f "$f" ]; then continue; fi;
        source "$f"                             # Load the file
        echo -e "# afk-daily\n\
lastCampaign=${lastCampaign:-$lastCampaign_default}\n\
lastWeekly=${lastWeekly:-$lastWeekly_default}" > "$f"

        case "$(uname -s)" in
            CYGWIN*|MINGW32*|MSYS*|MINGW*)      # Windows
                attrib +h "$f"                  # Make file invisible
                ;;
        esac

        # Unset all values
        while read -r line ; do
            if [[ $line =~ ^(.*)= ]]; then
                unset "${BASH_REMATCH[1]}"
            fi
        done < "$f"
        echo "$f updated"
    done
}

# ##############################################################################
# Section       : Config
# ##############################################################################

# ##############################################################################
# Function Name : guildHunts
# Descripton    : Remove old file
# ##############################################################################
cleanConfig() {
    rm -f config*.sh
}

# ##############################################################################
# Function Name : convertConfigSHtoINI
# Descripton    : Convert old file
# ##############################################################################
convertConfigSHtoINI() {
    for f in config*.sh; do
        if [ ! -f "$f" ]; then continue; fi;
        cp "$f" "$(basename "$f" .sh)".ini      # Copy new files
        echo "$f converted"
    done
}

# ##############################################################################
# Function Name : updateConfig
# Descripton    : Update file, add new params
# ##############################################################################
updateConfig() {
    for f in config*.ini; do
        if [ ! -f "$f" ]; then continue; fi;
        source "$f"                             # Load the file
        echo -e "# --- CONFIG: Modify accordingly to your game! --- #\n\
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #\n\
# Player\n\
canOpenSoren=${canOpenSoren:-"false"}\n\
arenaHeroesOpponent=${arenaHeroesOpponent:-"5"}\n\
\n\
# General\n\
waitForUpdate=${waitForUpdate:-"true"}\n\
endAt=${endAt:-"championship"}\n\
\n\
# Repetitions\n\
maxCampaignFights=${maxCampaignFights:-"5"}\n\
maxKingsTowerFights=${maxKingsTowerFights:-"5"}\n\
totalAmountArenaTries=${totalAmountArenaTries:-"2+0"}\n\
totalAmountGuildBossTries=${totalAmountGuildBossTries:-"2+0"}\n\
\n\
# Store\n\
buyStoreDust=${buyStoreDust:-"true"}\n\
buyStorePoeCoins=${buyStorePoeCoins:-"true"}\n\
buyStoreEmblems=${buyStoreEmblems:-"false"}\n\
\n\
# --- Actions --- #\n\
# Campaign\n\
doLootAfkChest=${doLootAfkChest:-"true"}\n\
doChallengeBoss=${doChallengeBoss:-"true"}\n\
doFastRewards=${doFastRewards:-"true"}\n\
doCollectFriendsAndMercenaries=${doCollectFriendsAndMercenaries:-"true"}\n\
\n\
# Dark Forest\n\
doSoloBounties=${doSoloBounties:-"true"}\n\
doTeamBounties=${doTeamBounties:-"true"}\n\
doArenaOfHeroes=${doArenaOfHeroes:-"true"}\n\
doLegendsTournament=${doLegendsTournament:-"true"}\n\
doKingsTower=${doKingsTower:-"true"}\n\
\n\
# Ranhorn\n\
doGuildHunts=${doGuildHunts:-"true"}\n\
doTwistedRealmBoss=${doTwistedRealmBoss:-"true"}\n\
doBuyFromStore=${doBuyFromStore:-"true"}\n\
doStrengthenCrystal=${doStrengthenCrystal:-"true"}\n\
doTempleOfAscension=${doTempleOfAscension:-"false"}\n\
doCompanionPointsSummon=${doCompanionPointsSummon:-"false"}\n\
# Only works if 'Hide Inn Heroes' is enabled under 'Settings -> Memory'\n\
doCollectOakPresents=${doCollectOakPresents:-"false"}\n\
\n\
# End\n\
doCollectQuestChests=${doCollectQuestChests:-"true"}\n\
doCollectMail=${doCollectMail:-"true"}\n\
doCollectMerchantFreebies=${doCollectMerchantFreebies:-"false"}" > "$f"

        # Unset all values
        while read -r line ; do
            if [[ $line =~ ^(.*)= ]]; then
                unset "${BASH_REMATCH[1]}"
            fi
        done < "$f"
        echo "$f updated"
    done
}

# ##############################################################################
# Section       : Main
# ##############################################################################

# ##############################################################################
# Function Name : runAFKScript
# ##############################################################################
runAFKScript() {
    convertAKFScriptTMPtoINI
    cleanAKFScript
    touch ".afkscript.ini"                      # Create default file
    updateAFKScript
}

# ##############################################################################
# Function Name : runConfig
# ##############################################################################
runConfig(){
    convertConfigSHtoINI
    cleanConfig
    touch "config.ini"                          # Create default file
    updateConfig
}

# ##############################################################################
# Function Name : show_help
# ##############################################################################
show_help() {
    echo -e "Usage: update_setup.sh [-h] [-a] [-c] [-l]\n"
    echo -e "Description:"
    echo -e "  - Convert file to new format (.tmp/.sh > .ini)"
    echo -e "  - Clean the folder (remove old .tmp/.sh files)"
    echo -e "  - Init with a file if run for the first time\n"
    echo -e "  - Update for new values\n"
    echo -e "Options:"
    echo -e "  h\tShow help"
    echo -e "  a\tSetup afkscript files"
    echo -e "  c\tSetup config files"
    echo -e "  l\tList setup files"
}

if [ -z "$1" ]; then
    show_help
    exit 0
fi

while getopts "hacl" opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        a)
            runAFKScript
            ;;
        c)
            runConfig
            ;;
        l)
            ls -al .*afkscript.ini config*.ini
            ;;
        \?)
            echo "$OPTARG : Invalid option"
            exit 1
            ;;
    esac
done
