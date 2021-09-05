The script acts depending on a set of variables. In order to change these, open `config.ini` with a text editor of choice, and update them. If you do not have/see a `config.ini` file, simply run the script with the `-c` flag (`./deploy.sh -c`), and it should get automatically generated for you to edit.

- [Player](#player)
- [General](#general)
- [Repetitions](#repetitions)
- [Store](#store)
- [Campaign](#campaign)
- [Dark Forest](#dark-forest)
- [Ranhorn](#ranhorn)
- [End](#end)

### Player

| Variable              |   Type    | Description                                                                                                                                               | Default |
| :-------------------- | :-------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------- | :-----: |
| `canOpenSoren`        | `Boolean` | If `true`, player has permission to open Soren.                                                                                                           | `false` |
| `arenaHeroesOpponent` | `Number`  | Choose which opponent to fight in the Arena of Heroes. Possible entries: `1`, `2`, `3`, `4` or `5`, where `1` is the top opponent and `5` the bottom one. |   `5`   |

### General

| Variable              |   Type    | Description                                                                                                                                  |    Default     |
| :-------------------- | :-------: | :------------------------------------------------------------------------------------------------------------------------------------------- | :------------: |
| `waitForUpdate`       | `Boolean` | If `true`, waits until the in-game update has finished.                                                                                      |     `true`     |
| `endAt`               | `String`  | Script will end at the chosen location. Possible entries: `oak`, `soren`, `mail`, `chat`, `tavern`, `merchants`, `campaign`, `championship`. | `championship` |
| `guildBattleType`     | `String`  | Choose type of Guild fight. Possible entries: `quick` or `challenge`.                                                                        |    `quick`     |
| `allowCrystalLevelUp` | `Boolean` | If `true`, allows the Resonating Crystal to be leveled up.                                                                                   |     `true`     |

### Repetitions

| Variable                           |   Type   | Description                                                                                                    | Default |
| :--------------------------------- | :------: | :------------------------------------------------------------------------------------------------------------- | :-----: |
| `maxCampaignFights`                | `Number` | The maximum amount of lost attempts when fighting in the Campaign.                                             |   `5`   |
| `maxKingsTowerFights`              | `Number` | The maximum amount of lost attempts when fighting in the King's Tower.                                         |   `5`   |
| `totalAmountArenaTries`            | `Number` | The total amount of fights in the Arena of Heroes. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |
| `totalAmountTournamentTries`       | `Number` | The total amount of fights in the Legends' Challenger Tournament.                                              |   `0`   |
| `totalAmountGuildBossTries`        | `Number` | The total amount of fights against a Guild Boss. The minimum is always 2, that's why its displayed as `2+X`.   |  `2+0`  |
| `totalAmountTwistedRealmBossTries` | `Number` | The total amount of fights in the Twisted Realm.                                                               |   `1`   |

### Store

| Variable                   |   Type    | Description                                                       | Default |
| :------------------------- | :-------: | :---------------------------------------------------------------- | :-----: |
| `buyStoreDust`             | `Boolean` | If `true`, buys Dust for Gold.                                    | `true`  |
| `buyStorePoeCoins`         | `Boolean` | If `true`, buys Poe Coins for Gold.                               | `true`  |
| `buyStorePrimordialEmblem` | `Boolean` | If `true` and possible, buys Primordial Emblems for Gold.         | `false` |
| `buyStoreAmplifyingEmblem` | `Boolean` | If `true` and possible, buys Amplifying Emblems for Gold.         | `false` |
| `buyStoreSoulstone`        | `Boolean` | If `true` and possible, buys Rare Soulstones for Diamonds.        | `false` |
| `buyStoreLimitedGoldOffer` | `Boolean` | If `true`, buys Limited offer for Gold.                           | `false` |
| `buyStoreLimitedDiamOffer` | `Boolean` | If `true`, buys Limited offer for Diamonds.                       | `false` |
| `buyWeeklyGuild`           | `Boolean` | If `true`, buys one Stone for Guild Coins once a Week.            | `false` |
| `buyWeeklyLabyrinth`       | `Boolean` | If `true`, buys Rare Soulstones for Labyrinth Tokens once a Week. | `false` |

### Campaign

| Variable                         |   Type    | Description                                                      | Default |
| :------------------------------- | :-------: | :--------------------------------------------------------------- | :-----: |
| `doLootAfkChest`                 | `Boolean` | If `true`, collects rewards from AFK chest.                      | `true`  |
| `doChallengeBoss`                | `Boolean` | If `true`, enters current campaign level.                        | `true`  |
| `doFastRewards`                  | `Boolean` | If `true`, collects free fast rewards.                           | `true`  |
| `doCollectFriendsAndMercenaries` | `Boolean` | If `true`, collects Companion Points and auto-lends mercenaries. | `true`  |

### Dark Forest

| Variable              |   Type    | Description                                              | Default |
| :-------------------- | :-------: | :------------------------------------------------------- | :-----: |
| `doSoloBounties`      | `Boolean` | If `true`, collects and dispatches Solo Bounties.        | `true`  |
| `doTeamBounties`      | `Boolean` | If `true`, collects and dispatches Team Bounties.        | `true`  |
| `doArenaOfHeroes`     | `Boolean` | If `true`, fights in the Arena of Heroes.                | `true`  |
| `doLegendsTournament` | `Boolean` | If `true`, fights in the Legends' Challenger Tournament. | `true`  |
| `doKingsTower`        | `Boolean` | If `true`, fights in the King's Towers.                  | `true`  |

### Ranhorn

| Variable                  |   Type    | Description                                        | Default |
| :------------------------ | :-------: | :------------------------------------------------- | :-----: |
| `doGuildHunts`            | `Boolean` | If `true`, fights Wrizz and if possible, Soren.    | `true`  |
| `doTwistedRealmBoss`      | `Boolean` | If `true`, fights current Twisted Realm boss.      | `true`  |
| `doBuyFromStore`          | `Boolean` | If `true`, buys items from store.                  | `true`  |
| `doStrengthenCrystal`     | `Boolean` | If `true`, strengthens the resonating Crystal.     | `true`  |
| `doTempleOfAscension`     | `Boolean` | If `true` and possible, auto ascends heroes.       | `false` |
| `doCompanionPointsSummon` | `Boolean` | If `true`, summons one hero with Companion Points. | `false` |
| `doCollectOakPresents`    | `Boolean` | If `true`, collects Oak Inn presents.              | `true`  |

### End

| Variable                    |   Type    | Description                                                                                 | Default |
| :-------------------------- | :-------: | :------------------------------------------------------------------------------------------ | :-----: |
| `doCollectQuestChests`      | `Boolean` | If `true`, collects daily quest chests.                                                     | `true`  |
| `doCollectMail`             | `Boolean` | If `true` and possible, collects mail rewards.                                              | `true`  |
| `doCollectMerchantFreebies` | `Boolean` | If `true` and possible, collects free daily/weekly/monthly rewards from the Merchants page. | `false` |

<hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Installation">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Usage">Next page</a>
</div>
