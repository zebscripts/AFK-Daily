As of now, the script is capable of completing the following:

* Campaign
  * [x] Loot AFK chest
  * [x] Fight the current campaign level (automatically fights every three days for Mythic Trick)
  * [x] Collect Fast Rewards
  * [x] Send and receive Companion Points
  * [x] Auto-lend Mercenaries
* Dark Forest
  * [x] Send Heroes on Solo and Team Bounty Quests
  * [x] Fight in the Arena of Heroes
  * [x] Fight in the Legends Tournament
  * [x] Fight in all available King's Towers
* Ranhorn
  * [x] Fight Wrizz and Soren if available. Can also open Soren for you.
  * [x] Fight in the Twisted Realm (necessary to have at least fought once against each TR boss for the game to save your formation)
  * [x] Buy various items from the Store
    * [x] Dust
    * [x] Peo Coins
    * [x] Soulstone
    * [x] Primordial Emblem
    * [x] Amplifying Emblem
    * [x] Limited Gold / Diam offer
    * [x] Weekly Guild
    * [x] Weekly Labyrinth
  * [x] Strengthen the Resonating Crystal
  * [x] Summon one Hero with Companion Points
  * [x] Collect Oak Inn presents
* Finish
  * [x] Collect daily, weekly, campaign quest chests
  * [x] Collect Mail
  * [x] Collect Daily/Weekly/Monthly rewards from Merchants
* Miscellaneous
  * [x] Possibility to specify a config file: `-c config`
  * [x] Choose if you want to fight Wrizz/Soren or use Quick Battle
  * [x] Make script output pretty
  * [x] Android emulator compatibility (Bluestacks, Nox, Memu)
  * [x] [Disable notifications while script is running](https://android.stackexchange.com/questions/194058/how-to-disable-peek-heads-up-notifications-globally-in-android-oreo): `adb shell settings put global heads_up_notifications_enabled 0` using `-n`
  * [ ] Test for screen size with `adb shell wm size`

## Push campaign/towers only

It is also possible to use the script to push campaign levels or Kings Towers only. In order to do this, simply disable any other feature in the `config.ini`, set `maxCampaignFights` and/or `maxKingsTowerFights` accordingly and use this option: `-f`.

## There are more features planned though, check them out here

* [ ] Compatibility for users who aren't as advanced in the game:
  * [x] Mercenaries
  * [ ] Bounties without auto-fill
  * [x] Arenas without skipping
  * [x] Kings Tower without factional towers
  * [x] Guild Hunts without quick battle

<!-- <hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Home">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Supported-Devices">Next page</a>
</div> -->
