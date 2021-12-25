If you're having trouble and would like some personal help, [join our Discord server](https://discord.gg/Fq2cfqjp8D)! We'd be happy to help.

<hr>

The script is developed in a way to exit whenever something doesn't go as planned. In case it does *not* exit though, it's either still OK and you'll have to correct it yourself after it's finished, or (in very rare occasions) it just straight up breaks stuff. I have never had someone "call me" while the script was running for example, so I have no idea what would happen there...

Either way, if something doesn't go as planned, be sure to hit `Control+C` in the terminal to stop the script from executing!

<hr>

The script is not finding BlueStacks? Then most likely you need to specify the port with the `-p` flag. You can easily find the port of BlueStacks under its `Settings` -> `Advanced` tab. You should see something like "Connect to Android at `127.0.0.1:<PORT>`". That last part after the `:` is the port number. Try running the script again with the `-p` flag:
```sh
./deploy.sh -p <PORT> # For example with port 52080: ./deploy.sh -p 52080
```

<hr>

If you are creating a [Github Issue](https://github.com/zebscripts/AFK-Daily/issues) report or you want to troubleshoot some problem with AFK-Daily, logs are the way to go and they are mandatory if you are creating a [Github Issue](https://github.com/zebscripts/AFK-Daily/issues) report.

- Add the option `-v 9` to your command: `./deploy.sh -v 9`
- Reproduce the issue
- Take a screenshot of the problem
- Copy/paste the log
- Open the [issue](https://github.com/zebscripts/AFK-Daily/issues)

<!-- <hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Known-Issues">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Feature-Requests">Next page</a>
</div> -->
