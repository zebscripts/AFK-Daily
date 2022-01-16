The script acts depending on a set of variables. In order to change these, open `config.ini` with a text editor of choice, and update them. If you do not have/see a `config.ini` file, simply run the script with the `-c` flag (`./deploy.sh -c`), and it should get automatically generated for you to edit.

- [Player](#player)
- [General](#general)
- [Repetitions](#repetitions)
- [Store](#store)
- [Towers](#towers)
- [Campaign](#campaign)
- [Dark Forest](#dark-forest)
- [Ranhorn](#ranhorn)
- [End](#end)
- [Useful config files](#useful-config-files)

## Player

| Variable              |   Type    | Description                                                                                                                                               | Default |
| :-------------------- | :-------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------- | :-----: |
| `canOpenSoren`        | `Boolean` | If `true`, player has permission to open Soren.                                                                                                           | `false` |
| `arenaHeroesOpponent` | `Number`  | Choose which opponent to fight in the Arena of Heroes. Possible entries: `1`, `2`, `3`, `4` or `5`, where `1` is the top opponent and `5` the bottom one. |   `5`   |

## General

| Variable              |   Type    | Description                                                                                                                                              |    Default     |
| :-------------------- | :-------: | :------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------: |
| `waitForUpdate`       | `Boolean` | If `true`, waits until the in-game update has finished.                                                                                                  |     `true`     |
| `endAt`               | `String`  | Script will end at the chosen location. Possible entries: `oak`, `soren`, `mail`, `chat`, `tavern`, `merchants`, `campaign`, `championship`, `closeApp`. | `championship` |
| `guildBattleType`     | `String`  | Choose type of Guild fight. Possible entries: `quick` or `challenge`.                                                                                    |    `quick`     |
| `allowCrystalLevelUp` | `Boolean` | If `true`, allows the Resonating Crystal to be leveled up.                                                                                               |     `true`     |

## Repetitions

| Variable                           |   Type   | Description                                                                                                    | Default |
| :--------------------------------- | :------: | :------------------------------------------------------------------------------------------------------------- | :-----: |
| `maxCampaignFights`                | `Number` | The maximum amount of lost attempts when fighting in the Campaign.                                             |   `5`   |
| `maxKingsTowerFights`              | `Number` | The maximum amount of lost attempts when fighting in the King's Tower.                                         |   `5`   |
| `totalAmountArenaTries`            | `Number` | The total amount of fights in the Arena of Heroes. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |
| `totalAmountTournamentTries`       | `Number` | The total amount of fights in the Legends' Challenger Tournament.                                              |   `0`   |
| `totalAmountGuildBossTries`        | `Number` | The total amount of fights against a Guild Boss. The minimum is always 2, that's why its displayed as `2+X`.   |  `2+0`  |
| `totalAmountTwistedRealmBossTries` | `Number` | The total amount of fights in the Twisted Realm.                                                               |   `1`   |

## Store

| Variable                        |   Type    | Description                                                        | Default |                                                             Image                                                             |
| :------------------------------ | :-------: | :----------------------------------------------------------------- | :-----: | :---------------------------------------------------------------------------------------------------------------------------: |
| `buyStoreDust`                  | `Boolean` | If `true`, buys Dust for Gold.                                     | `true`  |    ![Hero's Essence](https://user-images.githubusercontent.com/7203617/132167221-91cfdb08-a624-4ad0-8c6d-d565683298c1.png)    |
| `buyStorePoeCoins`              | `Boolean` | If `true`, buys Poe Coins for Gold.                                | `true`  |      ![Poe Coins](https://user-images.githubusercontent.com/7203617/132167219-2e50cc20-56d3-485c-ae8a-1668e1fb6f9c.png)       |
| `buyStorePrimordialEmblem`      | `Boolean` | If `true` and possible, buys Primordial Emblems for Gold.          | `false` |  ![Primordial Emblem](https://user-images.githubusercontent.com/7203617/132167223-8847e3a0-f793-4fd1-a5c6-9c00267e54d1.png)   |
| `buyStoreAmplifyingEmblem`      | `Boolean` | If `true` and possible, buys Amplifying Emblems for Gold.          | `false` |  ![Amplifying Emblem](https://user-images.githubusercontent.com/7203617/132167227-82508558-3021-493c-8cfc-bcf2b6071ce8.png)   |
| `buyStoreSoulstone`             | `Boolean` | If `true` and possible, buys Elite Soulstones for Diamonds.        | `false` | ![Elite Hero Soulstone](https://user-images.githubusercontent.com/7203617/132287360-45c1eb6d-9ddf-45a8-9060-64aa867737b2.png) |
| `buyStoreLimitedElementalShard` | `Boolean` | If `true`, buys Limited Elemental Shard.                           | `false` |    ![Limited Shard](https://user-images.githubusercontent.com/7203617/132167224-49b5dfb6-fce5-4a95-a702-9423ec23939e.png)     |
| `buyStoreLimitedElementalCore`  | `Boolean` | If `true`, buys Limited Elemental Core.                            | `false` |     ![Limited Core](https://user-images.githubusercontent.com/7203617/132167220-86102296-3e75-49f9-a7e1-cff87ff0f4f3.png)     |
| `buyStoreLimitedTimeEmblem`     | `Boolean` | If `true`, buys Limited Time Emblem.                               | `false` |                                                                                                                               |
| `buyWeeklyGuild`                | `Boolean` | If `true`, buys one Stone from Guild Coins once a Week.            | `false` |                                                                                                                               |
| `buyWeeklyLabyrinth`            | `Boolean` | If `true`, buys Rare Soulstones from Labyrinth Tokens once a Week. | `false` |   ![Rare Soulstones](https://user-images.githubusercontent.com/7203617/132167981-baac849d-613a-4716-881e-ee21a9b2d4a1.png)    |

## Towers

| Variable                  |   Type    | Description                                           | Default |
| :------------------------ | :-------: | :---------------------------------------------------- | :-----: |
| `doMainTower`             | `Boolean` | If `true`, tries to battle in Main Tower              | `true`  |
| `doTowerOfLight`          | `Boolean` | If `true`, tries to battle in Tower of Light          | `true`  |
| `doTheBrutalCitadel`      | `Boolean` | If `true`, tries to battle in The Brutal Citadel      | `true`  |
| `doTheWorldTree`          | `Boolean` | If `true`, tries to battle in The World Tree          | `true`  |
| `doCelestialSanctum`      | `Boolean` | If `true`, tries to battle in Celestial Sanctum       | `true`  |
| `doTheForsakenNecropolis` | `Boolean` | If `true`, tries to battle in The Forsaken Necropolis | `true`  |
| `doInfernalFortress`      | `Boolean` | If `true`, tries to battle in InfernalFortress        | `true`  |

## Campaign

| Variable                         |   Type    | Description                                                      | Default |
| :------------------------------- | :-------: | :--------------------------------------------------------------- | :-----: |
| `doLootAfkChest`                 | `Boolean` | If `true`, collects rewards from AFK chest.                      | `true`  |
| `doChallengeBoss`                | `Boolean` | If `true`, enters current campaign level.                        | `true`  |
| `doFastRewards`                  | `Boolean` | If `true`, collects free fast rewards.                           | `true`  |
| `doCollectFriendsAndMercenaries` | `Boolean` | If `true`, collects Companion Points and auto-lends mercenaries. | `true`  |

## Dark Forest

| Variable              |   Type    | Description                                              | Default |
| :-------------------- | :-------: | :------------------------------------------------------- | :-----: |
| `doSoloBounties`      | `Boolean` | If `true`, collects and dispatches Solo Bounties.        | `true`  |
| `doTeamBounties`      | `Boolean` | If `true`, collects and dispatches Team Bounties.        | `true`  |
| `doArenaOfHeroes`     | `Boolean` | If `true`, fights in the Arena of Heroes.                | `true`  |
| `doLegendsTournament` | `Boolean` | If `true`, fights in the Legends' Challenger Tournament. | `true`  |
| `doKingsTower`        | `Boolean` | If `true`, fights in the King's Towers.                  | `true`  |

## Ranhorn

| Variable                  |   Type    | Description                                        | Default |
| :------------------------ | :-------: | :------------------------------------------------- | :-----: |
| `doGuildHunts`            | `Boolean` | If `true`, fights Wrizz and if possible, Soren.    | `true`  |
| `doTwistedRealmBoss`      | `Boolean` | If `true`, fights current Twisted Realm boss.      | `true`  |
| `doBuyFromStore`          | `Boolean` | If `true`, buys items from store.                  | `true`  |
| `doStrengthenCrystal`     | `Boolean` | If `true`, strengthens the resonating Crystal.     | `true`  |
| `doTempleOfAscension`     | `Boolean` | If `true` and possible, auto ascends heroes.       | `false` |
| `doCompanionPointsSummon` | `Boolean` | If `true`, summons one hero with Companion Points. | `false` |
| `doCollectOakPresents`    | `Boolean` | If `true`, collects Oak Inn presents.              | `true`  |

## End

| Variable                    |   Type    | Description                                                                                 | Default |
| :-------------------------- | :-------: | :------------------------------------------------------------------------------------------ | :-----: |
| `doCollectQuestChests`      | `Boolean` | If `true`, collects daily quest chests.                                                     | `true`  |
| `doCollectMail`             | `Boolean` | If `true` and possible, collects mail rewards.                                              | `true`  |
| `doCollectMerchantFreebies` | `Boolean` | If `true` and possible, collects free daily/weekly/monthly rewards from the Merchants page. | `false` |

## Useful config files

<details>
  <summary>config-Arena.ini</summary>

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily/wiki/Config --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt=championship
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=0
maxKingsTowerFights=0
totalAmountArenaTries=25
totalAmountTournamentTries=0
totalAmountGuildBossTries=0
totalAmountTwistedRealmBossTries=0

# Store
buyStoreDust=false
buyStorePoeCoins=false
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedElementalShard=false
buyStoreLimitedElementalCore=false
buyStoreLimitedTimeEmblem=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

# Towers
doMainTower=false
doTowerOfLight=false
doTheBrutalCitadel=false
doTheWorldTree=false
doCelestialSanctum=false
doTheForsakenNecropolis=false
doInfernalFortress=false

# --- Actions --- #
# Campaign
doLootAfkChest=false
doChallengeBoss=false
doFastRewards=false
doCollectFriendsAndMercenaries=false

# Dark Forest
doSoloBounties=false
doTeamBounties=false
doArenaOfHeroes=true
doLegendsTournament=false
doKingsTower=false

# Ranhorn
doGuildHunts=false
doTwistedRealmBoss=false
doBuyFromStore=false
doStrengthenCrystal=false
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=false

# End
doCollectQuestChests=false
doCollectMail=false
doCollectMerchantFreebies=false

```

</details>

<details>
  <summary>config-Push_Campaign.ini</summary>

Need to be run with `-f` flag!

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily/wiki/Config --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt=campaign
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=500
maxKingsTowerFights=0
totalAmountArenaTries=0
totalAmountTournamentTries=0
totalAmountGuildBossTries=0
totalAmountTwistedRealmBossTries=0

# Store
buyStoreDust=false
buyStorePoeCoins=false
buyStorePrimordialEmblem=false
buyStoreAmplifyingEmblem=false
buyStoreSoulstone=false
buyStoreLimitedElementalShard=false
buyStoreLimitedElementalCore=false
buyStoreLimitedTimeEmblem=false
buyWeeklyGuild=false
buyWeeklyLabyrinth=false

# Towers
doMainTower=false
doTowerOfLight=false
doTheBrutalCitadel=false
doTheWorldTree=false
doCelestialSanctum=false
doTheForsakenNecropolis=false
doInfernalFortress=false

# --- Actions --- #
# Campaign
doLootAfkChest=false
doChallengeBoss=true
doFastRewards=false
doCollectFriendsAndMercenaries=false

# Dark Forest
doSoloBounties=false
doTeamBounties=false
doArenaOfHeroes=false
doLegendsTournament=false
doKingsTower=false

# Ranhorn
doGuildHunts=false
doTwistedRealmBoss=false
doBuyFromStore=false
doStrengthenCrystal=false
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=false

# End
doCollectQuestChests=false
doCollectMail=false
doCollectMerchantFreebies=false

```

</details>

<details>
  <summary>config-Push_Towers.ini</summary>

```ini
# --- CONFIG: Modify accordingly to your game! --- #
# --- Use this link for help: https://github.com/zebscripts/AFK-Daily/wiki/Config --- #
# Player
canOpenSoren=false
arenaHeroesOpponent=5

# General
waitForUpdate=true
endAt=campaign
guildBattleType=quick
allowCrystalLevelUp=false

# Repetitions
maxCampaignFights=0
maxKingsTowerFights=500
totalAmountArenaTries=0
totalAmountTournamentTries=0
totalAmountGuildBossTries=0
totalAmountTwistedRealmBossTries=0

# Store
buyStoreDust=false
buyStorePoeCoins=false
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
doLootAfkChest=false
doChallengeBoss=false
doFastRewards=false
doCollectFriendsAndMercenaries=false

# Dark Forest
doSoloBounties=false
doTeamBounties=false
doArenaOfHeroes=false
doLegendsTournament=false
doKingsTower=true

# Ranhorn
doGuildHunts=false
doTwistedRealmBoss=false
doBuyFromStore=false
doStrengthenCrystal=false
doTempleOfAscension=false
doCompanionPointsSummon=false
doCollectOakPresents=false

# End
doCollectQuestChests=false
doCollectMail=false
doCollectMerchantFreebies=false

```

</details>

<hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Installation">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Usage">Next page</a>
</div>
