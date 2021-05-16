<div align="center">
  <!-- <img src="Stuff/AppIcon-readme.png" width="200" height="200"> -->
  <h1>afk-daily.sh</h1>
  <p>
    <b>Automate daily activities within the AFK Arena game</b>
  </p>

  <!-- Badges -->
  <!-- Script status -->
  <p>
  <a href="#features" alt="Script Status"><img src="https://img.shields.io/badge/Script-Passing-green.svg"></img></a>
  <!-- <a href="#issues" alt="Script Status"><img src="https://img.shields.io/badge/Script-Partial-orange.svg"></img></a> -->
  <!-- <a href="#issues" alt="Script Status"><img src="https://img.shields.io/badge/Script-Failing-red.svg"></img></a> -->
  <!-- Latest patch -->
  <a alt="Latest patch tested on"><img src="https://img.shields.io/badge/Patch-1.63.03-blue.svg"></img></a>
  </p>
</div>

<!-- Uncomment the following quote whenever the script is Failing -->
> **Big changes with the last update! Please delete your `config.ini` file and run the script to generate a new one.** You're now more in control of the script, by choosing which parts of it to run. This also helps in case one feature is broken, just turning it off temporarily works around the issue. Or even if the script fails, just run it again without running the stuff before the error.

This script is meant to automate the process of daily activities within the [AFK Arena](https://play.google.com/store/apps/details?id=com.lilithgame.hgame.gp&hl=en_US) game. It uses [ADB](https://developer.android.com/studio/command-line/adb) to analyse pixel colors in screenshots and tap on the screen accordingly. If you like my work, please consider starring this repository as it lets me know people use this script, which motivates me to keep working on it! :)

<p align="center"><img src="https://i.imgur.com/gcr9vZf.png" alt="Example script output"></p>

## Disclaimer<!-- omit in toc -->

This is a very fragile script (it relies on pixel accuracy), which means the probability of encountering a new error every time a new patch rolls out by Lilith is pretty high. Keep an eye on the `Patch` badge to check the latest game version this script was tested on.

**I am not responsible for any type of ban or unintentional purchase! Use this script at your own risk.** I will do my best to try and make it as robust and straightforward as possible.

Since lately I've been adding quite a lot of new features and bug fixes, this README is slowly but surely starting to get a big mess. I'll be working on an organized wiki one day, but for now this will do.

**For those who want to get a quick overview of this project instead of reading it all**: Install an emulator (bluestacks) and the rest of the dependencies, [change some bluestacks settings](#requirements--installation), run the script, update the freshly generated `config.ini` file, run script again and watch how the game gets played.

## Table of Contents<!-- omit in toc -->

- [Features](#features)
- [Supported Platforms](#supported-platforms)
- [Requirements & Installation](#requirements--installation)
- [Usage](#usage)
- [Examples](#examples)
- [Config/Variables](#configvariables)
  - [Player](#player)
  - [General](#general)
  - [Repetitions](#repetitions)
  - [Store](#store)
  - [Campaign](#campaign)
  - [Dark Forest](#dark-forest)
  - [Ranhorn](#ranhorn)
  - [End](#end)
- [Issues](#issues)
- [Planned features](#planned-features)
- [Tips](#tips)
- [FAQ](#faq)
- [Feature Requests](#feature-requests)
- [Troubleshooting](#troubleshooting)

## Features

As of now, the script is capable of completing the following inside the game:

- Loot AFK chest
- Fight the current campaign level (automatically fights every three days for Mythic Trick)
- Collect Fast Rewards
- Send and receive Companion Points
- Auto-lend Mercenaries
- Send Heroes on Solo and Team Bounty Quests
- Fight in the Arena of Heroes
- Fight in the Legends Tournament
- Fight in the available King's Towers
- Fight Wrizz and Soren if available. Can also open Soren for you.
- Fight in the Twisted Realm (necessary to have at least fought once against each TR boss for the game to save your formation)
- Buy various items from the Store
- Strengthen the Resonating Crystal
- Summon one Hero with Companion Points
- Collect Oak Inn presents (necessary to enable "Hide Inn Heroes" in the game settings)
- Collect daily and weekly quest chests
- Collect Mail
- Collect Daily/Weekly/Monthly rewards from Merchants

There are more features planned though, check them out [here](#planned-features)!

## Supported Platforms

There are **three different platforms** where you're able to run this script, namely your **personal Android device**, as well as two Android emulators: [**Bluestacks**](https://www.bluestacks.com/) and [**Nox**](https://www.bignox.com/). iOS will never be a thing, there's no need to ask for it (just install Bluestacks instead).

Which one you want to use is up to you. Keep in mind that AFK Arena saves chat messages locally on your device, so if you use an emulator and switch between your devices often, your chat might look a bit messy. Personally, I recommend either your personal device or Bluestacks, as Nox has worse compatibility with this script.

## Requirements & Installation

There are quite a few requirements in order to run this script. In a perfect world this all works flawlessly, but we're not in a perfect world, so be prepared for some hic-ups here and there...

**AFK-Arena:** You actually need to be quite advanced in the game to be able to run this script. For now, the script assumes you're already **at least at stage 15-1**. Plans to take newer players into consideration exist, they're not yet implemented though. Here are the necessary in-game features, along with their respective unlock levels:

- **Mercenaries:** Stage 6-40
- **Quick-battle Guild:** VIP 6 or higher
- **Skip battle in arena:** VIP 6 or higher
- **Unlock Bounty Autofill and Dispatch:** VIP 6 or higher
- **Auto-fill Heroes in quests:** VIP 6 or higher (or stage 12-40)
- **Twisted Realm:** Stage 14-40
- **Factional Towers:** Stage 15-1

<hr>

**For advanced users:**

1. Have ADB installed. Make sure it's in your `$PATH`!
2. Be able to run `.sh` files

**For normal users:**

In order to run the script, you'll need to be able to run/execute `.sh` files. This shouldn't be a problem in MacOS or Linux, *but Windows definitely needs extra software for that*. If you're on windows, there are many options available (a quick google search on "how to run sh scripts on windows" will help you), though I recommend installing [Git Bash](https://gitforwindows.org/), as its the easiest method in my opinion. I'm also going to assume you installed Git Bash for the rest of the installation.

<hr>

**Next, follow the requirements depending on what platform you want to run the script on!**

<hr>

*Bluestacks:*

1. **Settings:** Under Bluestacks settings, make sure to make the following changes:
   1. **Display:**
      - Change the resolution to `1080x1920`
      - *Optional:* Change from Landscape (Tablet mode) to Portrait (Phone mode)
      - *Optional:* Use `240 DPI` (still have to test how this affects the script)
   2. **Preferences:**
      - Enable Android Debug Bridge (ADB)
   3. **Advanced:**
      - *Optional:* Change the predefined profile to `Samsung Galaxy S10`
2. **AFK Arena:** Install the game. Duh.

<hr>

*Nox:*

1. **Settings:** Under Nox settings, make sure to make the following changes:
   1. **General:**
       - Enable Root
   2. **Performance:**
       - Change the resolution to `1080x1920`
       - *Optional:* Mobile Phone (instead of Tablet)
   3. **Phone model & Internet:**
       - Change the phone model to `Google Pixel 2`
2. **AFK Arena:** Install the game. Duh.
3. **USB Debugging:** Visit [this link](https://www.xda-developers.com/install-adb-windows-macos-linux/) on how to enable USB Debugging. It's in the beginning, under the `Phone Setup` part. *The settings on Nox are inside a folder called Tools.*

<hr>

*Personal Device:*

1. **USB Debugging:** Visit [this link](https://www.xda-developers.com/install-adb-windows-macos-linux/) on how to enable USB Debugging. It's in the beginning, under the `Phone Setup` part. *The settings on Nox are inside a folder called Tools.*
2. **Resolution:** Make sure your Device is set to `1080x1920`.
3. **AFK Arena:** Install the game. Duh.
4. **Root:** Unfortunately root is necessary. If you don't have root access, please use an emulator (Bluestacks).
5. **[BusyBox](https://play.google.com/store/apps/details?id=stericson.busybox):** This will install one specific command that the script uses for pixel analysis.

<hr>

## Usage

**For advanced users:**

1. Clone this repo and `cd` into it .
2. Connect your device to the computer (or start your emulator of choice).
3. Run `./deploy.sh` to generate [`config.ini`](#configvariables) and change its values if necessary.
4. Run `./deploy.sh` again to run script.
5. Watch your device magically play for you. It's fun! I promise.

**For normal users:**

1. Create a folder on your machine to save this script in
2. Open up a terminal at said directory:
   - **Windows:** Open the directory, `Shift+Right Mouse Click` inside it, and click on `Git Bash here`.
   - **Mac/Linux:** Open a terminal, and `cd` into your directory.
3. Clone this repository by running `git clone https://github.com/zebscripts/AFK-Daily.git` in the terminal.
4. Run `cd AFK-Daily` in the terminal.
5. Connect your device to the computer (or start your emulator of choice).
6. Type `./deploy.sh` into your terminal.
7. Configure [`config.ini`](#configvariables) if necessary.
8. Type `./deploy.sh` into your terminal once again to run the script with the `config.ini` variables.
9. Watch your device magically play for you. It's fun! I promise.

**If for whatever reason `git clone https://github.com/zebscripts/AFK-Daily.git` (step 3) returns an error**, simply download this repository as a `.zip` file through the *big green "Code" button* at the top of this page, and unzip it into your directory. Then open the "AFK-Daily-master" repository, open a terminal there (step 2) and follow the rest of the steps starting at step 5. Keep in mind automatic updates won't be working then. [Send me a message](#troubleshooting), I'd be happy to help!

While creating this repository and script, I wanted to make it as easy as possible for anyone to use it. That's why I've implemented various checks in order to run the script, so you don't have to! These include:

- Check if adb is installed, and if not install it.
- Check for File line endings
- Check what type of device is connected per ADB, and connect accordingly*
- Deploy the script on your device to be able to run it

*\* Unfortunately it won't detect nox without you specifying it as an optional parameter. At least not yet.*

You can also execute the script with the following optional parameters:

```text
$ ./deploy.sh -h
USAGE: deploy.sh [OPTIONS]

DESCRIPTION
   Automate daily activities within the AFK Arena game.
   More info: https://github.com/zebscripts/AFK-Daily

OPTIONS
   -h, --help
      Show help

   -a, --account [ACCOUNT]
      Use .afkscript.ini with a tag (multiple accounts)
      Remark: Please don't use spaces!
      Example: -a account1

   -c, --check
      Check if script is ready to be run

   -d, --device [DEVICE]
      Specify desired device
      Values for <DEVICE>: bs, dev

   -f, --fight
      Force campaign battle (ignore 3 day optimisation)

   -t, --test
      Launch on test server (experimental)

   -w, --weekly
      Force weekly

EXAMPLES
   Run script for Bluestacks
      deploy.sh -d bs

   Run script on test server
      deploy.sh -t

   Run script forcing fight & weekly
      deploy.sh -fw

```

## Examples

The most basic way to run the script:

```sh
./deploy.sh
```

*Note: By running the above command, the script will automatically try to figure out what platform you want to run the script on! If this doesn't work, please specify the platform.*

Running the script on Bluestacks:

```sh
./deploy.sh -d bs
```

Running the script on Nox:

```sh
./deploy.sh -d nox
```

## Config/Variables

The script acts depending on a set of variables. In order to change these, open `config.ini` with a text editor of choice, and update them. If you do not have/see a `config.ini` file, simply run the script once (`./deploy.sh`), it should get automatically generated for you to edit. **Do not delete any variable inside `config.ini`.**

### Player

| Variable              |   Type    | Description                                                                                                                                | Default |
| :-------------------- | :-------: | :----------------------------------------------------------------------------------------------------------------------------------------- | :-----: |
| `canOpenSoren`        | `Boolean` | Set to `true` if the player has permissions to open Soren.                                                                                 | `false` |
| `arenaHeroesOpponent` | `Number`  | Choose which opponent to fight in the Arena of Heroes. Possible entries: `1`, `2`, `3`, `4`, `5`. `1` being at the top, `5` at the bottom. |   `5`   |

### General

| Variable        |   Type    | Description                                                                                                                                  |    Default     |
| :-------------- | :-------: | :------------------------------------------------------------------------------------------------------------------------------------------- | :------------: |
| `waitForUpdate` | `Boolean` | If `true`, waits until the update has finished downloading. If `false`, ignores update and runs script.                                      |     `true`     |
| `endAt`         | `String`  | Script will end at the chosen location. Possible entries: `oak`, `soren`, `mail`, `chat`, `tavern`, `merchants`, `campaign`, `championship`. | `championship` |

### Repetitions

| Variable                     |   Type   | Description                                                                                                              | Default |
| :--------------------------- | :------: | :----------------------------------------------------------------------------------------------------------------------- | :-----: |
| `maxCampaignFights`          | `Number` | The total amount of attempts to fight in the campaign. Only losses count as attempts.                                    |  `5`    |
| `maxKingsTowerFights`        | `Number` | The total amount of attempts to fight in each King's Towers. Only losses count as attempts.                              |  `5`    |
| `totalAmountArenaTries`      | `Number` | The total amount of tries the player may fight in the Arena. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |
| `totalAmountTournamentTries` | `Number` | The total amount of tries the player may fight in the Tournament.                                                        |   `0`   |
| `totalAmountGuildBossTries`  | `Number` | The total amount of tries the player may fight a Guild Boss. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |

### Store

| Variable                    |   Type    | Description                                                       | Default |
| :-------------------------- | :-------: | :---------------------------------------------------------------- | :-----: |
| `buyStoreDust`              | `Boolean` | If `true`, buys Dust from the store for Gold.                     | `true`  |
| `buyStorePoeCoins`          | `Boolean` | If `true`, buys Poe Coins from the store for Gold.                | `true`  |
| `buyStoreSoulstone`         | `Boolean` | If `true`, buys Elite Hero Soulstones from the store for 90 Gems. | `false` |
| `buyStorePrimordialEmblem`  | `Boolean` | If `true`, buys Primordial Emblem from the store for Gold.        | `false` |
| `buyStoreAmplifyingEmblem`  | `Boolean` | If `true`, buys Amplifying Emblem from the store for Gold.        | `false` |
| `buyWeeklyGuild`            | `Boolean` | If `true`, buys first item of Guild store.                        | `false` |
| `buyWeeklyLabyrinth`        | `Boolean` | If `true`, buys Soulstones from the Labyrinth store.              | `false` |

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
| `doGuildHuntsBattle`      | `Boolean` | If `true`, do guild hunt with manual challenge, no quick battle                                                      | `false` |
| `doTwistedRealmBoss`      | `Boolean` | If `true`, fights current Twisted Realm Boss.                                                                        | `true`  |
| `doBuyFromStore`          | `Boolean` | If `true`, buys items from store.                                                                                    | `true`  |
| `doStrengthenCrystal`     | `Boolean` | If `true`, strengthens the resonating Crystal (without leveling up).                                                 | `true`  |
| `allowCrystalLevelUp`     | `Boolean` | If `true`, and `doStrengthenCrystal=true` strengthens the resonating Crystal and level up if possible.               | `false` |
| `doTempleOfAscension`     | `Boolean` | If `true`, auto ascend heroes.                                                                                       | `false` |
| `doCompanionPointsSummon` | `Boolean` | If `true`, summons one hero with Companion Points.                                                                   | `false` |
| `doCollectOakPresents`    | `Boolean` | **Only works if "Hide Inn Heroes" is enabled under "Settings -> Memory".** If `true`, collects Oak Inn red presents. | `false` |

### End

| Variable                    |   Type    | Description                                                                    | Default |
| :-------------------------- | :-------: | :----------------------------------------------------------------------------- | :-----: |
| `doCollectQuestChests`      | `Boolean` | If `true`, collects daily quest chests.                                        | `true`  |
| `doCollectMail`             | `Boolean` | If `true`, collects mail rewards.                                              | `true`  |
| `doCollectMerchantFreebies` | `Boolean` | If `true`, collects free daily/weekly/monthly rewards from the Merchants page. | `false` |

## Issues

The script is developed in a way to exit whenever something doesn't go as planned. In case it does *not* exit though, it's either still OK and you'll have to correct it yourself after it's finished, or (in very rare occasions) it just straight up breaks stuff. I have never had someone "call me" while the script was running for example, so I have no idea what would happen there...

**Either way, if something doesn't go as planned, be sure to hit `Control+C` in the terminal to stop the script from executing!**

These are known issues that you might stumble across:

- [`#4`](https://github.com/zebscripts/afk-daily/issues/4) - Since the timings are quite hard coded for now, there's always a chance that the script might skip something because it tried to take an action before the game even loaded it. An example for this is at the beginning when loading the game and switching between the first Tabs, or while fighting in the Legends Tournament. Worst case scenario the script either exits, or you'll have to go fight one extra time at the tournament.
- [`#32`](https://github.com/zebscripts/AFK-Daily/issues/32) - Script breaks whenever resources are full. Please make sure to always collect them/spend them.
- [`#33`](https://github.com/zebscripts/AFK-Daily/issues/33) - Script waits forever in the Arena of Heroes

If you encounter an issue that is *not* listed above or in [issues](https://github.com/zebscripts/AFK-Daily/issues), feel free to [open a new issue](https://github.com/zebscripts/afk-daily/issues/new)! I will try my best to add existing ones.

## Planned features

- [x] Add some sort of config, ideally a `./deploy.sh config`
- [x] Check if there are Bounty Quests to collect before sending out heroes on quests
- [x] Fight in more than just the main tower
- [ ] Choose if you want to fight Wrizz/Soren or use Quick Battle
- [x] Fight the twisted realm as well
- [ ] Collect Soulstones
- [x] Collect weekly quests
- [x] Collect Merchant Daily/Weekly/Monthly rewards (~~Will probably never happen if the games interface stays the same~~ Ended up happening!)
- [x] Make script output pretty
- [x] Test for screen size with `adb shell wm size`
- [x] Android emulator compatibility (Aiming for Bluestacks and Nox)
- [x] Actually try to beat the campaign level every 3 days to maximize farm
- [ ] [Disable notifications while script is running](https://android.stackexchange.com/questions/194058/how-to-disable-peek-heads-up-notifications-globally-in-android-oreo): `adb shell settings put global heads_up_notifications_enabled 0`
- [ ] Compatibility for users who aren't as advanced in the game:
  - [ ] Mercenaries
  - [ ] Bounties without auto-fill
  - [ ] Arenas without skipping
  - [ ] Kings Tower without factional towers
  - [ ] Guild Hunts without quick battle
- [x] Collect daily rewards from Oak Inn
- [x] [Summon one hero with companion points](https://github.com/zebscripts/AFK-Daily/discussions/34)

## Tips

Here are some tips to keep in mind:

- Don't try to run the script with more than one device connected
- Whenever something happens that you don't want to happen, just hit `Control+C` on the terminal and the script will instantly stop! *Note: If you happen to `Ctrl+C` while the script is `sleeping`, the terminal never exits. Please close and reopen it.*
- If for some reason the script returns errors like `: not found[0]: syntax error`, it's probably because `afk-daily.sh` is not saved wth `LF` line endings. Supposedly the script already does the conversion for you, but it appears you'll have to [do it yourself](https://support.nesi.org.nz/hc/en-gb/articles/218032857-Converting-from-Windows-style-to-UNIX-style-line-endings). Apologies.

## FAQ

**Can I get banned by using this script?**

I've tried getting in contact with Lilith through various means, and until this day I did **not** get an answer from them. Their [Terms of Service](https://www.lilithgames.com/termofservice.html) states the following:

> You agree not to do any of the following while using our Services, Lilith Content, or User Content: [...] Use cheats, exploits, hacks, bots, mods or third party software designed to gain an advantage, perceived or actual, over other Members, or modify or interfere with the Service; [...]

In my opinion, this does **not** include this script, as players don't gain any type of advantage over other players. Maybe time in their life, but that's about it... I can also let you know there's a really low chance for Lilith to find out you're using this script, unless they actively try to search for it. And I doubt they're willing to spend resources into that.

Though Lilith has confirmed, that using Bluestacks macros is allowed in the game. [Here's an image](https://imgur.com/Ho0O4ev) for that. This makes me believe my script is also allowed.

Do with this information what you want. I'm *not responsible at all* if anything happens to your account. **Use at your own risk.**

**Will this ever be available on iOS?**

Nope. Install Bluestacks and run this script.

## Feature Requests

Have a feature in mind? An idea? Something that isn't implemented yet? Maybe even a completely different script for the game? Let me know by writing it in the [discussion board](https://github.com/zebscripts/AFK-Daily/discussions/categories/ideas)!

## Troubleshooting

If you're having trouble running this script, feel free to send me a message on [Discord](http://discordapp.com/users/241655863616471041)(Zebiano#2989). I'll try my best to help you.

**The script does not auto-update to the latest version**

You can easily update the script yourself by typing `git pull` in the terminal. If it still doesn't work, then I recommend deleting every file besides `config.ini` and running `git pull https://github.com/zebscripts/AFK-Daily`.

**`hexdump: not found`**

This is most likely because your device does not have [busybox](https://play.google.com/store/apps/details?id=stericson.busybox) installed. Either install it on your device or try an emulator like Bluestacks out.

**`protocol fault: stat response has wrong message id`**

This most likely happens because you did not enable Android Debug Bridge under the Bluestacks settings. Check the [requirements for Bluestacks](#requirements--installation) out.
