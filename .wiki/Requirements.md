## Supported Platforms

There are **three different platforms** where you're able to run this script, namely your **personal Android device**, as well as two Android emulators: [**Bluestacks**](https://www.bluestacks.com/) and [**Nox**](https://www.bignox.com/). iOS will never be a thing, there's no need to ask for it (just install Bluestacks instead).

Which one you want to use is up to you. Keep in mind that AFK Arena saves chat messages locally on your device, so if you use an emulator and switch between your devices often, your chat might look a bit messy. Personally, I recommend either your personal device or Bluestacks, as Nox has worse compatibility with this script.

## Installation

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

[Previous](https://github.com/zebscripts/AFK-Daily/wiki/Features) | [Next](https://github.com/zebscripts/AFK-Daily/wiki/Usage)
