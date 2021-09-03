The script acts depending on a set of variables. In order to change these, open `config.ini` with a text editor of choice, and update them. If you do not have/see a `config.ini` file, simply run the script once (`./deploy.sh -c`), it should get automatically generated for you to edit.

### Player

| Variable              |   Type    | Description                                                                                                                                | Default |
| :-------------------- | :-------: | :----------------------------------------------------------------------------------------------------------------------------------------- | :-----: |
| `canOpenSoren`        | `Boolean` | If `true`, the player has permission to open Soren.                                                                                        | `false` |
| `arenaHeroesOpponent` | `Number`  | Choose which opponent to fight in the Arena of Heroes. Possible entries: `1`, `2`, `3`, `4`, `5`. `1` being at the top, `5` at the bottom. |   `5`   |

### General

| Variable        |   Type    | Description                                                                                                                                  |    Default     |
| :-------------- | :-------: | :------------------------------------------------------------------------------------------------------------------------------------------- | :------------: |
| `waitForUpdate` | `Boolean` | If `true`, waits until the in-game update has finished.                                                                                      |     `true`     |
| `endAt`         | `String`  | Script will end at the chosen location. Possible entries: `oak`, `soren`, `mail`, `chat`, `tavern`, `merchants`, `campaign`, `championship`. | `championship` |

### Repetitions

| Variable                    |   Type   | Description                                                                                                              | Default |
| :-------------------------- | :------: | :----------------------------------------------------------------------------------------------------------------------- | :-----: |
| `maxCampaignFights`         | `Number` | The total amount of attempts to fight in the campaign. Only losses count as attempts.                                    |   `5`   |
| `maxKingsTowerFights`       | `Number` | The total amount of attempts to fight in each King's Towers. Only losses count as attempts.                              |   `5`   |
| `totalAmountArenaTries`     | `Number` | The total amount of tries the player may fight in the Arena. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |
| `totalAmountGuildBossTries` | `Number` | The total amount of tries the player may fight a Guild Boss. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |

### Store

| Variable           |   Type    | Description                                        | Default |
| :----------------- | :-------: | :------------------------------------------------- | :-----: |
| `buyStoreDust`     | `Boolean` | If `true`, buys Dust from the store for Gold.      | `true`  |
| `buyStorePoeCoins` | `Boolean` | If `true`, buys Poe Coins from the store for Gold. | `true`  |
| `buyStoreEmblems`  | `Boolean` | If `true`, buys Emblems from the store for Gold.   | `false` |

### Campaign

| Variable                         |   Type    | Description                                                      | Default |
| :------------------------------- | :-------: | :--------------------------------------------------------------- | :-----: |
| `doLootAfkChest`                 | `Boolean` | If `true`, collects rewards from AFK chest.                      | `true`  |
| `doChallengeBoss`                | `Boolean` | If `true`, fights current campaign level.                        | `true`  |
| `doFastRewards`                  | `Boolean` | If `true`, collects fast rewards once.                           | `true`  |
| `doCollectFriendsAndMercenaries` | `Boolean` | If `true`, collects Companion Points and auto-lends mercenaries. | `true`  |

### Dark Forest

| Variable              |   Type    | Description                                              | Default |
| :-------------------- | :-------: | :------------------------------------------------------- | :-----: |
| `doSoloBounties`      | `Boolean` | If `true`, collects and dispatch Solo Bounties.          | `true`  |
| `doTeamBounties`      | `Boolean` | If `true`, collects and dispatch Team Bounties.          | `true`  |
| `doArenaOfHeroes`     | `Boolean` | If `true`, fights in the Arena of Heroes.                | `true`  |
| `doLegendsTournament` | `Boolean` | If `true`, fights in the Legends' Challenger Tournament. | `true`  |
| `doKingsTower`        | `Boolean` | If `true`, fights in the King's Tower.                   | `true`  |

### Ranhorn

| Variable                  |   Type    | Description                                                                                                          | Default |
| :------------------------ | :-------: | :------------------------------------------------------------------------------------------------------------------- | :-----: |
| `doGuildHunts`            | `Boolean` | If `true`, fights Wrizz and possibly Soren.                                                                          | `true`  |
| `doTwistedRealmBoss`      | `Boolean` | If `true`, fights current Twisted Realm Boss.                                                                        | `true`  |
| `doBuyFromStore`          | `Boolean` | If `true`, buys items from store.                                                                                    | `true`  |
| `doStrengthenCrystal`     | `Boolean` | If `true`, strengthens the resonating Crystal (without leveling up).                                                 | `true`  |
| `doCompanionPointsSummon` | `Boolean` | If `true`, summons one hero with Companion Points.                                                                   | `false` |
<!-- | `doCollectOakPresents`    | `Boolean` | **Only works if "Hide Inn Heroes" is enabled under "Settings -> Memory".** If `true`, collects Oak Inn red presents. | `false` | -->
| `doCollectOakPresents`    | `Boolean` | If `true`, collects Oak Inn red presents.                                                                            | `false` |

### End

| Variable                    |   Type    | Description                                                                    | Default |
| :-------------------------- | :-------: | :----------------------------------------------------------------------------- | :-----: |
| `doCollectQuestChests`      | `Boolean` | If `true`, collects daily quest chests.                                        | `true`  |
| `doCollectMail`             | `Boolean` | If `true`, collects mail rewards.                                              | `true`  |
| `doCollectMerchantFreebies` | `Boolean` | If `true`, collects free daily/weekly/monthly rewards from the Merchants page. | `false` |

<hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Installation">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Usage">Next page</a>
</div>
