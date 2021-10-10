#!/system/bin/sh
# ##############################################################################
# Script Name   : deploy.ext.sh
# Description   : Extension of the deploy script, used for backup & tools
# GitHub        : https://github.com/zebscripts/AFK-Daily
# License       : MIT
# ##############################################################################

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
        $buyStoreLimitedGoldOffer || -z \
        $buyStoreLimitedDiamOffer || -z \
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
