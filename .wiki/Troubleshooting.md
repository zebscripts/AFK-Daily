The script is developed in a way to exit whenever something doesn't go as planned. In case it does *not* exit though, it's either still OK and you'll have to correct it yourself after it's finished, or (in very rare occasions) it just straight up breaks stuff. I have never had someone "call me" while the script was running for example, so I have no idea what would happen there...

Either way, if something doesn't go as planned, be sure to hit `Control+C` in the terminal to stop the script from executing!

<hr>

If you are creating a [Github Issue](https://github.com/zebscripts/AFK-Daily/issues) report or you want to troubleshoot some problem with AFK-Daily, logs are the way to go and they are mandatory if you are creating a [Github Issue](https://github.com/zebscripts/AFK-Daily/issues) report.

*This will be implemented soon*

To get decent logs, you need to edit `afk-daily.sh`, so before launch, do the following:

- Line 6: `DEBUG=4`
- Line 13: `SHOW_DELTA=1`

Then:

- Reproduce the issue
- Take a screenshot of the problem
- Copy/paste the log
- Open the [issue](https://github.com/zebscripts/AFK-Daily/issues)

After reporting the issue, please set `DEBUG` and `SHOW_DELTA` to default `0`.

<hr>

[Previous](https://github.com/zebscripts/AFK-Daily/wiki/Specific) | [Next](https://github.com/zebscripts/AFK-Daily/wiki/Contribute)
