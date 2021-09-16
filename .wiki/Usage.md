While creating this repository and script, we wanted to make it as easy as possible for anyone to use it. That's why we've implemented various checks in order to run the script, so you don't have to! These include:

- Install `adb` locally if necessary
- Check for File line-endings
- Check what type of device is connected per ADB, and connect accordingly
- Auto-update the script if a new version is found

You can also execute the script with the following optional parameters:

```text
$ ./deploy.sh -h

    _     ___   _  __        ___           _   _
   /_\   | __| | |/ /  ___  |   \   __ _  (_) | |  _  _  
  / _ \  | _|  | ' <  |___| | |) | / _` | | | | | | || | 
 /_/ \_\ |_|   |_|\_\       |___/  \__,_| |_| |_|  \_, | 
                                                   |__/  

USAGE: deploy.sh [OPTIONS]

DESCRIPTION
   Automate daily activities within the AFK Arena game.  
   More info: https://github.com/zebscripts/AFK-Daily    

OPTIONS
   -h, --help
      Show help

   -a, --account [ACCOUNT]
      Specify account: "acc-[ACCOUNT].ini"
      Remark: Please don't use spaces!

   -d, --device [DEVICE]
      Specify target device.
      Values for [DEVICE]: bs (default), nox, memu

   -e, --event [EVENT]
      Specify active event.
      Values for [EVENT]: hoe

   -f, --fight
      Force campaign battle (ignore 3-day optimisation).

   -i, --ini [CONFIG]
      Specify config: "config-[CONFIG].ini"
      Remark: Please don't use spaces!

   -n
      Disable heads-up notifications while script is running.

   -r
      Ignore resolution warning. Use this at your own risk.

   -t, --test
      Launch on test server (experimental).

   -w, --weekly
      Force weekly.

DEV OPTIONS

   -b
      Dev mode: do not restart adb.

   -c, --check
      Check if script is ready to be run.

   -o, --output [OUTPUT_FILE]
      Write log in [OUTPUT_FILE]
      Remark: Folder needs to be created

   -s <X>,<Y>[,<COLOR_TO_COMPARE>[,<REPEAT>[,<SLEEP>]]]
      Test color of a pixel.

   -v, --verbose [DEBUG]
      Show DEBUG informations
         DEBUG  = 0    Show no debug
         DEBUG >= 1    Show getColor calls > value
         DEBUG >= 2    Show test calls
         DEBUG >= 3    Show all core functions calls
         DEBUG >= 4    Show all functions calls
         DEBUG >= 9    Show all calls

   -z
      Disable auto update.

EXAMPLES
   Run script
      ./deploy.sh

   Run script with specific emulator (for example Nox)
      ./deploy.sh -d nox

   Run script on test server
      ./deploy.sh -t

   Run script forcing fight & weekly
      ./deploy.sh -fw

   Run script for color testing
      ./deploy.sh -s 800,600

   Run script with output file and with disabled notifications
      ./deploy.sh -n -o ".history/$(date +%Y%m%d).log"

   Run script on test server with output file and with disabled notifications
      ./deploy.sh -n -t -a "test" -i "test" -o ".history/$(date +%Y%m%d).test.log"
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

<hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Config">Previous page</a>
|
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Specific">Next page</a>
</div>
