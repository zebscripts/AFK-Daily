As of now, the script is capable of completing the following:

* Loot AFK chest
* Fight the current campaign level (automatically fights every three days for Mythic Trick)
* Collect Fast Rewards
* Send and receive Companion Points
* Auto-lend Mercenaries
* Send Heroes on Solo and Team Bounty Quests
* Fight in the Arena of Heroes
* Fight in the Legends Tournament
* Fight in the available King's Towers
* Fight Wrizz and Soren if available. Can also open Soren for you.
* Fight in the Twisted Realm (necessary to have at least fought once against each TR boss for the game to save your formation)
* Buy various items from the Store
* Strengthen the Resonating Crystal
* Summon one Hero with Companion Points
* Collect Oak Inn presents (necessary to enable "Hide Inn Heroes" in the game settings)
* Collect daily and weekly quest chests
* Collect Mail
* Collect Daily/Weekly/Monthly rewards from Merchants

## Push campaign/towers only

It is also possible to use the script to push campaign levels or Kings Towers only. In order to do this, simply disable any other feature in the `config.ini` and set `maxCampaignFights` and/or `maxKingsTowerFights` accordingly.

## There are more features planned though, check them out here

* [x] Add some sort of config, ideally a `./deploy.sh config`
* [x] Check if there are Bounty Quests to collect before sending out heroes on quests
* [x] Fight in more than just the main tower
* [ ] Choose if you want to fight Wrizz/Soren or use Quick Battle
* [x] Fight the twisted realm as well
* [ ] Collect Soulstones
* [x] Collect weekly quests
* [x] Collect Merchant Daily/Weekly/Monthly rewards (~~Will probably never happen if the games interface stays the same~~ Ended up happening!)
* [x] Make script output pretty
* [ ] Test for screen size with `adb shell wm size`
* [x] Android emulator compatibility (Aiming for Bluestacks and Nox)
* [x] Actually try to beat the campaign level every 3 days to maximize farm
* [ ] [Disable notifications while script is running](https://android.stackexchange.com/questions/194058/how-to-disable-peek-heads-up-notifications-globally-in-android-oreo): `adb shell settings put global heads_up_notifications_enabled 0`
* [ ] Compatibility for users who aren't as advanced in the game:
  * [ ] Mercenaries
  * [ ] Bounties without auto-fill
  * [ ] Arenas without skipping
  * [ ] Kings Tower without factional towers
  * [ ] Guild Hunts without quick battle
* [x] Collect daily rewards from Oak Inn
* [x] [Summon one hero with companion points to get the 20 Activity points from the daily bounty](https://github.com/zebscripts/AFK-Daily/discussions/34)

<!-- <hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Home">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Supported-Devices">Next page</a>
</div> -->
