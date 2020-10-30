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
  <a alt="Latest patch tested on"><img src="https://img.shields.io/badge/Patch-1.49-blue.svg"></img></a>
  </p>
</div>

<!-- Uncomment the following quote whenever the script is Failing -->
<!-- > Dispatching and collecting bounties is still bugged. I'll take a look at it next reset. -->

This script is meant to automate the process of daily activities within the [AFK Arena](https://play.google.com/store/apps/details?id=com.lilithgame.hgame.gp&hl=en_US) game. It uses [ADB](https://developer.android.com/studio/command-line/adb) to analyse pixel colors in screenshots and tap on the screen accordingly.
<!-- > I'd be happy to hear some feedback! If you tried this out for yourself, let me know please. -->

## Disclaimer <!-- omit in toc -->  
This is a very fragile script (it relies on pixel accuracy), which means the probability of encountering a new error every time a new patch rolls out by Lilith is pretty high. So use it at your own risk after a new patch comes out. I'll try my best to keep it updated every now and then.

The main reason to why I haven't been adding features to the script is because I was unhappy with the way I was dealing with it. It slowly started being a very big mess, so I started spending resources into changing that. This includes making it easier for non-programmers to use this script. So right now, I ask for your patience while I develop another tool meant to run this script in a "nicer" fashion. If you don't want to wait, you can either check one of the available and updated forks (for example [this very interesting one](https://github.com/Fortigate/AFK-Daily/blob/master/deploy.sh)), or try and make your own fork to temporarily fix/change anything as you wish. Thank you for your understanding!

## Table of Contents <!-- omit in toc -->
- [Features](#features)
- [Supported Platforms](#supported-platforms)
- [Requirements & Installation](#requirements--installation)
- [Usage](#usage)
- [Examples](#examples)
- [Config/Variables](#configvariables)
- [Issues](#issues)
- [Planned features](#planned-features)
- [Tips](#tips)
- [FAQ](#faq)
- [Feature Requests](#feature-requests)

## Features
As of now, the script is capable of completing the following inside the game:
- Loot AFK chest
- Fight the current campaign level
- Collect Fast Rewards
- Send Companion Points to friends
- Auto Lend Mercenaries
- Send Heroes on Solo and Team Bounty Quests
- Fight in the Arena of Heroes
- Fight in the Legends Tournament
- Fight in the Kings Tower
- Fight Wrizz
- Fight Soren if available. Can also open Soren for you.
- Fight in the Twisted Realm
- Buy daily Dust from the Store
- Collect daily Quest Chests
- Collect Mail

There are more features planned though, check them out [here](#planned-features)!

## Supported Platforms
There are **three different platforms** where you're able to run this script, namely your **personal Android device**, as well as two Android emulators: [**Bluestacks**](https://www.bluestacks.com/) and [**Nox**](https://www.bignox.com/). iOS will never be a thing, there's no need to ask for it.

Which one you want to use is up to you. Keep in mind that AFK Arena saves chat messages locally on your device, so if you use an emulator and switch between your devices often, your chat might look a bit messy. Personally, I recommend either your personal device or Bluestacks, as Nox has worse performance compared to Bluestacks and worse compatibility with this script.

## Requirements & Installation
There are quite a few requirements in order to run this script. In a perfect world this all works flawlessly, but we're not in a perfect world, so be prepared for some hic-ups here and there...

**For advanced users:**
1. Have ADB installed. Make sure it's in your `$PATH`!
2. Be able to run `.sh` files

**For normal users:**
> I'm planning to make the installation a lot easier by letting the script install ADB for you. I'll make sure to update this README whenever that happens!

1. **ADB**: The script relies on ADB to communicate with your device. So installing ADB is really a no-brainer. Here's a [link](https://www.xda-developers.com/install-adb-windows-macos-linux/) on how to do it. Please make sure to add it to your `$PATH` as well, here's [another link](https://lifehacker.com/the-easiest-way-to-install-androids-adb-and-fastboot-to-1586992378).
2. **`.sh`:** In order to run the script, you'll need to be able to run/execute `.sh` files. This shouldn't be a problem in MacOS or Linux, *but Windows definitely needs extra software for that*. If you're on windows, there are many options available (a quick google search on "how to run sh scripts on windows" will help you), though I recommend installing [Git Bash](https://gitforwindows.org/), as its the easiest method in my opinion. I'm also going to assume you installed Git Bash for the rest of the installation.

<hr>

**AFK-Arena:** You actually need to be quite advanced in the game to be able to run this script. For now, the script assumes you're already **at least at stage 15-1**. Plans to take newer players into consideration exist, they're not yet implemented though. Here are the necessary in-game features, along with their respective unlock levels:
- **Mercenaries:** Stage 6-40
- **Quick-battle Guild:** VIP 6 or higher
- **Skip battle in arena:** VIP 6 or higher
- **Auto-fill Heroes in quests:** VIP 6 or higher (or stage 12-40)
- **Twisted Realm:** Stage 14-40
- **Factional Towers:** Stage 15-1

<hr>

**Next, follow the requirements depending on what platform you want to run the script on!**

<hr>

*Personal Device:*
1. **USB Debugging:** If you've followed the first [link](https://www.xda-developers.com/install-adb-windows-macos-linux/) on how to install ADB, you should have also enabled USB Debugging on your phone. In case you didn't, go do that now. It's under the `Phone Setup` part.
2. **Resolution:** Make sure your Device is set to `1920x1080`. I'm not sure if any other resolutions work, but hey, give it a try and let me know!
3. **AFK Arena:** Install the game. Duh.
4. **Root:** Should be *optional*, but is always nice to have.
5. **[BusyBox](https://play.google.com/store/apps/details?id=stericson.busybox):** Should also be *optional*, but if something doesn't work, install it and try again.

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
3. **USB Debugging:** If you've followed the first [link](https://www.xda-developers.com/install-adb-windows-macos-linux/) on how to install ADB, you should have also enabled USB Debugging inside Nox. In case you didn't, go do that now. It's under the `Phone Setup` part. *The settings on Nox are inside a folder called Tools.*

<hr>

## Usage
**For advanced users:**
1. Clone this repo and `cd` into it .
2. Open `afk-daily.sh` with any editor of choice and edit variables accordingly. More on this [here](#configvariables).
3. Connect your device to the computer (or start your emulator of choice).
4. Run `./deploy.sh`.
5. Watch your device magically play for you. It's fun! I promise.

**For normal users:** 
1. Clone/Download this repository to your desired directory.
2. Open `afk-daily.sh` with any editor of choice and edit variables accordingly. More on this [here](#configvariables).
3. Open up a terminal at said directory:
   - **Windows:** Open the directory, hold `Shift+Right Mouse Click` inside it, and click on `Git Bash here`.
   - **Mac/Linux:** Open a terminal, and `cd` into your directory.
4. Connect your device to the computer (or start your emulator of choice).
5. Type `./deploy.sh` into your terminal.
6. Watch your device magically play for you. It's fun! I promise.

While creating this repository and script, I wanted to make it as easy as possible for anyone to use it. That's why I've implemented various checks in order to run the script, so you don't have to! These include:
- Check for File line endings
- Check what type of device is connected per ADB, and connect accordingly*
- Deploy the script on your device to be able to run it

*\* Unfortunately it won't detect nox without you specifying it as an optional parameter. At least not yet.*

You can also execute the script with the following optional parameters:
```sh
./deploy.sh [platform]

  bluestacks|bs|-bluestacks|-bs
    Deploy to Bluestacks.

  nox|n|-nox|-n
    Deploy to Nox.
```

## Examples
The most basic way to run the script:
```
./deploy.sh
```
*Note: By running the above command, the script will automatically try to figure out what platform you want to run the script on! If this doesn't work, please specify the platform.*

Running the script on Bluestacks:
```
./deploy.sh bs
```

Running the script on Nox:
```
./deploy.sh nox
```

## Config/Variables
In order to take actions in the game, the script is dependent on some variables that are set at the beginning of the it. In order to change these, open `config.sh` with a text editor of choice, and update them.

**`afk-daily.sh`:**
| Variable                    | Description                                                                                                              | Default |
| :-------------------------- | :----------------------------------------------------------------------------------------------------------------------- | :-----: |
| `canOpenSoren`              | Set to `true` if the player has permissions to open Soren.                                                               | `false` |
| `totalAmountArenaTries`     | The total amount of tries the player may fight in the Arena. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |
| `totalAmountGuildBossTries` | The total amount of tries the player may fight a Guild Boss. The minimum is always 2, that's why its displayed as `2+X`. |  `2+0`  |
| `totalAmountDailyQuests`    | The total amount of daily Quest Chests the player is able to collect. This will probably never change.                   |   `8`   |
| `endAtSoren`                | If set to `true`, the script will execute, and when finished end at Soren.                                               | `false` |

## Issues
The script is developed in a way to exit whenever something doesn't go as planned. In case something doesn't go as planned and the script does not exit, it's either still OK and you'll have to correct it yourself after it's finished, or (in very rare occasions) it just straight up breaks stuff. I have never had someone "call me" while the script was running for example, so I have no idea what would happen there...

**Either way, if something doesn't go as planned, be sure to hit `Control+C` in the terminal to stop the script from executing!**

These are known issues that you might stumble across:
- [#4](https://github.com/zebscripts/afk-daily/issues/4) Since the timings are quite hard coded for now, there's always a chance that the script might skip something because it tried to take an action before the game even loaded it. An example for this is at the beginning when loading the game and switching between the first Tabs, or while fighting in the Legends Tournament. Worst case scenario the script either exits, or you'll have to go fight one extra time at the tournament.
- [#10](https://github.com/zebscripts/AFK-Daily/issues/10) If bounties are already dispatched, the script exits, instead of continuing with the next task.

If you encounter an issue that is *not* listed above, feel free to [open a new issue](https://github.com/zebscripts/afk-daily/issues/new)! I will try my best to add existing ones.

## Planned features
- [ ] Add some sort of config, ideally a `./deploy.sh config`
- [x] ~~Check if there are Bounty Quests to collect before sending out heroes on quests~~
- [ ] Fight in more than just the main tower
- [ ] Choose if you want to fight Wrizz/Soren or use Quick Battle
- [x] ~~Fight the twisted realm as well~~
- [ ] Collect Soulstones
- [ ] Collect weekly quests
- [ ] Collect Merchant Daily/Weekly/Monthly rewards (Will probably never happen if the games interface stays the same)
- [ ] Make script output pretty
- [ ] Test for screen size with `adb shell wm size`
- [x] ~~Android emulator compatibility (Aiming for Bluestacks and Nox)~~
- [ ] Actually try to beat the campaign level every 3 days to maximize farm
- [ ] [Disable notifications while script is running](https://android.stackexchange.com/questions/194058/how-to-disable-peek-heads-up-notifications-globally-in-android-oreo): `adb shell settings put global heads_up_notifications_enabled 0`
- [ ] Compatibility for users who aren't as advanced in the game:
  - [ ] Mercenaries
  - [ ] Bounties without auto-fill
  - [ ] Arenas without skipping
  - [ ] Kings Tower without factional towers
  - [ ] Guild Hunts without quick battle
- [ ] Collect daily rewards from Oak Inn

## Tips
Here are some tips to keep in mind:
- Don't try to run the script with more than one device connected
- Whenever something happens that you don't want to happen, just hit `Control+C` on the terminal and the script will instantly stop! *Note: If you happen to `Ctrl+C` while the script is `sleeping`, the terminal never exits. Please close and reopen it.*
- If for some reason the script returns errors like `: not found[0]: syntax error`, it's probably because `afk-daily.sh` is not saved wth `LF` line endings. Supposedly the script already does the conversion for you, but it appears you'll have to [do it yourself](https://support.nesi.org.nz/hc/en-gb/articles/218032857-Converting-from-Windows-style-to-UNIX-style-line-endings). Apologies.

## FAQ
**Do I need a rooted device?**

Probably not. I've tried my best to take most of the things into consideration to not use root, but maybe I've let something slip through. Also, this only affects Personal Devices, as the emulators usually give you root permissions.

**Can I get banned by using this script?**

I've tried getting in contact with Lilith through various means, and until this day I did **not** get an answer from them. Their [Terms of Service](https://www.lilithgames.com/termofservice.html) states the following:

> You agree not to do any of the following while using our Services, Lilith Content, or User Content: [...] Use cheats, exploits, hacks, bots, mods or third party software designed to gain an advantage, perceived or actual, over other Members, or modify or interfere with the Service; [...]

In my opinion, this does **not** include this script, as players don't gain any type of advantage over other players. Maybe time in their life, but that's about it... I can also let you know there's a really low chance for Lilith to find out you're using this script, unless they actively try to search for it. And I doubt they're willing to spend resources into that.

Though Lilith has confirmed, that using Bluestacks macros is allowed in the game. [Here's an image](https://imgur.com/Ho0O4ev) for that. This makes me believe my script is also allowed.

Do with this information what you want. I'm *not responsible at all* if anything happens to your account. **Use at your own risk.**

**Will this ever be available on iOS?**

Nope.

## Feature Requests
Have a feature in mind? An idea? Something that isn't implemented yet? Maybe even a completely different script for the game? Let me know by hitting me up on [discord](http://discordapp.com/users/241655863616471041), or by opening a new [issue](https://github.com/zebscripts/afk-daily/issues/new)!
