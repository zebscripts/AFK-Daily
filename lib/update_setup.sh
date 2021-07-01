#!/bin/bash
# ##############################################################################
# Script Name   : update_setup.sh
# Description   : Tools to update ini files
# Args          : [-h] [-a] [-c] [-l]
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# Source
source ./lib/print.sh

# TODO: Update for new files locations:
#  Move: update_setup.sh     >   lib/update_setup.sh
#
#  convertAKFScriptTMPtoINI:
#    for:       .*afkscript*.tmp              >  ./account-info/acc-*.ini
#    echo:      "$(basename "$f" .tmp)".ini   >  ./account-info/acc-"$(basename "$f" .tmp)".ini
#  updateAFKScript:
#    for:       .*afkscript*.ini              >  ./account-info/acc-*.ini
#  convertConfigSHtoINI:
#    for:       config*.sh                    >  ./config/config*.ini
#    cp:        "$(basename "$f" .tmp)".ini   >  ./config/"$(basename "$f" .tmp)".ini
#  updateConfig:
#    for:       config*.ini                   >  ./config/config*.ini
#  Maybe require ../ instead of ./
#
#  Check if works when called directly and deploy.sh

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
    for f in .*afkscript*.tmp; do
        if [ ! -f "$f" ]; then continue; fi
        echo "# afk-daily" >./account-info/acc.ini
        case "$(uname -s)" in # Check OS
        Darwin | Linux)       # Mac / Linux
            # FIXME: This is actually throwing an error to me right now and I didn't change anything here? Confusion.
            # The file was moved so it's normal, you can't add anything to a file not created line 49.
            echo "lastCampaign=$(date -r "$(cat "$f")" +%Y%m%d)" >>./account-info/acc.ini
            ;;
        CYGWIN* | MINGW32* | MSYS* | MINGW*) # Windows
            # FIXME: This is actually throwing an error to me right now and I didn't change anything here? Confusion.
            echo "lastCampaign=$(date -d "@$(cat "$f")" +%Y%m%d)" >>./account-info/acc.ini
            ;;
        esac
        # printSuccess "$f converted"
    done
}

# ##############################################################################
# Function Name : updateAFKScript
# Descripton    : Update file, add new params
# ##############################################################################
updateAFKScript() {
    # Date 3 days ago
    # Saturday 2 weeks ago
    case "$(uname -s)" in # Check OS
    Darwin | Linux)       # Mac / Linux
        lastCampaign_default=$(date -v -3d +%Y%m%d)
        lastWeekly_default=$(date -v -sat +%Y%m%d)
        ;;
    CYGWIN* | MINGW32* | MSYS* | MINGW*) # Windows
        lastCampaign_default=$(date -d 'now - 3day' +%Y%m%d)
        lastWeekly_default=$(date -dlast-saturday +%Y%m%d)
        ;;
    esac

    for f in ./account-info/acc*.ini; do
        if [ ! -f "$f" ]; then continue; fi
        source "$f" # Load the file
        echo -e "# afk-daily\n\
lastCampaign=${lastCampaign:-$lastCampaign_default}\n\
lastWeekly=${lastWeekly:-$lastWeekly_default}" >"$f.tmp"

        # Unset all values
        while read -r line; do
            if [[ $line =~ ^(.*)= ]]; then
                unset "${BASH_REMATCH[1]}"
            fi
        done <"$f"

        # Check for differences
        if cmp --silent -- "$f" "$f.tmp"; then
            rm -f "$f.tmp"
        else
            mv "$f.tmp" "$f"
            # echo "$f updated"
        fi
    done
}

# ##############################################################################
# Section       : Config
# ##############################################################################

# ##############################################################################
# Function Name : cleanConfig
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
        if [ ! -f "$f" ]; then continue; fi
        cp "$f" ./config/config.ini # Copy new files
        # printSuccess "$f converted"
    done
}

# ##############################################################################
# Function Name : updateConfig
# Descripton    : Update file, add new params
# ##############################################################################
updateConfig() {
    for f in ./config/config*.ini; do
        if [ ! -f "$f" ]; then continue; fi
        source "$f" # Load the file
        echo -e "# --- CONFIG: Modify accordingly to your game! --- #\n\
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily#configvariables --- #\n\
# Player\n\
canOpenSoren=${canOpenSoren:-"false"}\n\
arenaHeroesOpponent=${arenaHeroesOpponent:-"5"}\n\
\n\
# General\n\
waitForUpdate=${waitForUpdate:-"true"}\n\
endAt=${endAt:-"championship"}\n\
guildBattleType=${guildBattleType:-"quick"}\n\
allowCrystalLevelUp=${allowCrystalLevelUp:-"true"}\n\
\n\
# Repetitions\n\
maxCampaignFights=${maxCampaignFights:-"5"}\n\
maxKingsTowerFights=${maxKingsTowerFights:-"5"}\n\
totalAmountArenaTries=${totalAmountArenaTries:-"2+0"}\n\
totalAmountTournamentTries=${totalAmountTournamentTries:-"0"}\n\
totalAmountGuildBossTries=${totalAmountGuildBossTries:-"2+0"}\n\
totalAmountTwistedRealmBossTries=${totalAmountTwistedRealmBossTries:-"1"}\n\
\n\
# Store\n\
buyStoreDust=${buyStoreDust:-"true"}\n\
buyStorePoeCoins=${buyStorePoeCoins:-"true"}\n\
buyStorePrimordialEmblem=${buyStorePrimordialEmblem:-"false"}\n\
buyStoreAmplifyingEmblem=${buyStoreAmplifyingEmblem:-"false"}\n\
buyStoreSoulstone=${buyStoreSoulstone:-"false"}\n\
buyWeeklyGuild=${buyWeeklyGuild:-"false"}\n\
buyWeeklyLabyrinth=${buyWeeklyLabyrinth:-"false"}\n\
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
doCollectOakPresents=${doCollectOakPresents:-"true"}\n\
\n\
# End\n\
doCollectQuestChests=${doCollectQuestChests:-"true"}\n\
doCollectMail=${doCollectMail:-"true"}\n\
doCollectMerchantFreebies=${doCollectMerchantFreebies:-"false"}" >"$f.tmp"

        # Unset all values
        while read -r line; do
            if [[ $line =~ ^(.*)= ]]; then
                unset "${BASH_REMATCH[1]}"
            fi
        done <"$f"

        # Check for differences
        if cmp --silent -- "$f" "$f.tmp"; then
            rm -f "$f.tmp"
        else
            mv "$f.tmp" "$f"
            # echo "$f updated"
        fi
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
    touch "account-info/acc.ini" # Create default file
    updateAFKScript
}

# ##############################################################################
# Function Name : runConfig
# ##############################################################################
runConfig() {
    convertConfigSHtoINI
    cleanConfig
    touch "config/config.ini" # Create default file
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
    echo -e "  - Init with a file if run for the first time"
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

while getopts ":hacl" opt; do
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
