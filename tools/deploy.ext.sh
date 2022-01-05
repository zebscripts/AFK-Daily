#!/bin/bash
# ##############################################################################
# Script Name   : deploy.ext.sh
# Description   : Extension of the deploy script, used for backup & tools
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

# ##############################################################################
# Function Name : checkConfig
# Description   : Creates a $configFile file if not found
# ##############################################################################
checkConfig() {
    printTask "Searching for ${cCyan}$configFile${cNc}..."
    if [ -f "$configFile" ]; then
        printSuccess "Found!"
    else
        printWarn "Not found!"
        printTask "Creating new ${cCyan}$configFile${cNc}..."
        printf '# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily/wiki/Config --- #

# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt="championship"
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=5
maxKingsTowerFights=5
totalAmountArenaTries=2+0
totalAmountTournamentTries=0
totalAmountGuildBossTries=2+0
totalAmountTwistedRealmBossTries=1

# Store
buyStoreDust=true
buyStorePoeCoins=true
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedElementalShard=false
buyStoreLimitedElementalCore=false
buyStoreLimitedTimeEmblem=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

# Towers
doMainTower=true
doTowerOfLight=true
doTheBrutalCitadel=true
doTheWorldTree=true
doCelestialSanctum=true
doTheForsakenNecropolis=true
doInfernalFortress=true

# --- Actions --- #
# Campaign
doLootAfkChest=true
doChallengeBoss=true
doFastRewards=true
doCollectFriendsAndMercenaries=true

# Dark Forest
doSoloBounties=true
doTeamBounties=true
doArenaOfHeroes=true
doLegendsTournament=true
doKingsTower=true

# Ranhorn
doGuildHunts=true
doTwistedRealmBoss=true
doBuyFromStore=true
doStrengthenCrystal=true
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=true

# End
doCollectQuestChests=true
doCollectMail=true
doCollectMerchantFreebies=false
' >$configFile
        printSuccess "Created!\n"
        printInfo "Please edit ${cCyan}$configFile${cNc} if necessary and run this script again."
        exit
    fi
}

# ##############################################################################
# Function Name : validateConfig
# Description   : Checks for every necessary variable that needs to be defined in $configFile
# ##############################################################################
validateConfig() {
    source $configFile
    printTask "Validating ${cCyan}$configFile${cNc}..."
    if [[ -z $canOpenSoren || -z \
        $arenaHeroesOpponent || -z \
        $waitForUpdate || -z \
        $endAt || -z \
        $maxCampaignFights || -z \
        $maxKingsTowerFights || -z \
        $totalAmountArenaTries || -z \
        $totalAmountTournamentTries || -z \
        $totalAmountGuildBossTries || -z \
        $totalAmountTwistedRealmBossTries || -z \
        $buyStoreDust || -z \
        $buyStorePoeCoins || -z \
        $buyStorePrimordialEmblem || -z \
        $buyStoreAmplifyingEmblem || -z \
        $buyStoreSoulstone || -z \
        $buyStoreLimitedElementalShard || -z \
        $buyStoreLimitedElementalCore || -z \
        $buyStoreLimitedTimeEmblem || -z \
        $buyWeeklyGuild || -z \
        $buyWeeklyLabyrinth || -z \
        $doMainTower || -z \
        $doTowerOfLight || -z \
        $doTheBrutalCitadel || -z \
        $doTheWorldTree || -z \
        $doCelestialSanctum || -z \
        $doTheForsakenNecropolis || -z \
        $doInfernalFortress || -z \
        $doLootAfkChest || -z \
        $doChallengeBoss || -z \
        $doFastRewards || -z \
        $doCollectFriendsAndMercenaries || -z \
        $doSoloBounties || -z \
        $doTeamBounties || -z \
        $doArenaOfHeroes || -z \
        $doLegendsTournament || -z \
        $doKingsTower || -z \
        $doGuildHunts || -z \
        $guildBattleType || -z \
        $doTwistedRealmBoss || -z \
        $doBuyFromStore || -z \
        $doStrengthenCrystal || -z \
        $allowCrystalLevelUp || -z \
        $doTempleOfAscension || -z \
        $doCompanionPointsSummon || -z \
        $doCollectOakPresents || -z \
        $doCollectQuestChests || -z \
        $doCollectMail || -z \
        $doCollectMerchantFreebies ]]; then
        printError "${cCyan}$configFile${cNc} has missing/wrong entries."
        echo
        printInfo "Please either delete ${cCyan}$configFile${cNc} and run the script again to generate a new one,"
        printInfo "or run ./lib/update_setup.sh -c"
        printInfo "or check the following link for help:"
        printInfo "https://github.com/zebscripts/AFK-Daily/wiki/Config"
        exit
    fi
    printSuccess "Passed!"
}
