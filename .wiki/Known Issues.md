- [`#4`](https://github.com/zebscripts/afk-daily/issues/4) - Since the timings are quite hard coded for now, there's always a chance that the script might skip something because it tried to take an action before the game even loaded it. An example for this is at the beginning when loading the game and switching between the first Tabs, or while fighting in the Legends Tournament. Worst case scenario the script either exits, or you'll have to go fight one extra time at the tournament.
- [`#32`](https://github.com/zebscripts/AFK-Daily/issues/32) - Script breaks whenever resources are full. Please make sure to always collect them/spend them.
- [`#33`](https://github.com/zebscripts/AFK-Daily/issues/33) - Script waits forever in the Arena of Heroes
- The script does not auto-update to the latest version

    You can easily update the script yourself by typing `git pull` in the terminal. If it still doesn't work, then I recommend deleting every file besides `config.sh` and running `git pull https://github.com/zebscripts/AFK-Daily`.

- `hexdump: not found`

    This is most likely because your device does not have [busybox](https://play.google.com/store/apps/details?id=stericson.busybox) installed. Either install it on your device or try an emulator like Bluestacks out.

- `protocol fault: stat response has wrong message id`

   This most likely happens because you did not enable Android Debug Bridge under the Bluestacks settings. Check the [requirements for Bluestacks](#requirements--installation) out.

<hr>

If you encounter an issue that is *not* listed above or in [issues](https://github.com/zebscripts/AFK-Daily/issues), feel free to [open a new issue](https://github.com/zebscripts/afk-daily/issues/new)! I will try my best to add existing ones.

<hr>

[Previous](https://github.com/zebscripts/AFK-Daily/wiki/Feature-Requests) | [Next](https://github.com/zebscripts/AFK-Daily/wiki/Troubleshooting)
