Feel free to [join our Discord](https://discord.com/invite/Fq2cfqjp8D) and let us know there that you're having trouble!

If you encounter an issue that is *not* listed below or in [issues](https://github.com/zebscripts/AFK-Daily/issues), feel free to [open a new issue](https://github.com/zebscripts/afk-daily/issues/new)!

- [`#4`](https://github.com/zebscripts/afk-daily/issues/4) - Since the timings are quite hardcoded for now, there's always a chance that the script might skip something because it tried to take an action before the game even loaded it. An example of this is at the beginning when loading the game and switching between the first Tabs, or while fighting in the Legends Tournament. Worst case scenario the script either exits, or you'll have to go fight one extra time at the tournament.
- [`#32`](https://github.com/zebscripts/AFK-Daily/issues/32) - Script breaks whenever resources are full. Please make sure to always collect them/spend them.
- Script not auto-updating - You can easily update the script yourself by typing `git pull` in the terminal. If it still doesn't work, then I recommend deleting every file besides `config.ini` and running `git pull https://github.com/zebscripts/AFK-Daily`.

- `hexdump: not found` - This is most likely because your personal android device does not have [busybox](https://play.google.com/store/apps/details?id=stericson.busybox) installed. Either install it on your device or try an emulator like Bluestacks out.

- `protocol fault: stat response has wrong message id` - This most likely happens because you did not enable Android Debug Bridge. Check your devices' [requirements](https://github.com/zebscripts/AFK-Daily/wiki/Supported-Devices) on how to do this.

<!-- <hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/FAQ">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Troubleshooting">Next page</a>
</div> -->


