**For normal users:**

1. Create a folder on your machine to save this script in
2. Open up a terminal at said directory:
   - **Windows:** Open the directory, `Shift+Right Mouse Click` inside it, and click on `Git Bash here`.
   - **Mac/Linux:** Open a terminal, and `cd` into your directory.
3. Clone this repository by running `git clone https://github.com/zebscripts/AFK-Daily.git` in the terminal.
4. Run `cd AFK-Daily` in the terminal.
5. Connect your device to the computer (or start your emulator of choice).
6. Type `./deploy.sh` into your terminal.
7. Configure [`config.sh`](https://github.com/zebscripts/AFK-Daily/wiki/Config) if necessary.
8. Type `./deploy.sh` into your terminal once again to run the script with the `config.sh` variables.
9. Watch your device magically play for you. It's fun! I promise.

**For advanced users:**

1. Clone this repo and `cd` into it .
2. Connect your device to the computer (or start your emulator of choice).
3. Run `./deploy.sh` to generate [`config.sh`](https://github.com/zebscripts/AFK-Daily/wiki/Config) and change its values if necessary.
4. Run `./deploy.sh` again to run script.
5. Watch your device magically play for you. It's fun! I promise.

**If for whatever reason `git clone https://github.com/zebscripts/AFK-Daily.git` (step 3) returns an error**, simply download this repository as a `.zip` file through the *big green "Code" button* at the top of this page, and unzip it into your directory. Then open the "AFK-Daily-master" repository, open a terminal there (step 2) and follow the rest of the steps starting at step 5. Keep in mind automatic updates won't be working then. [Send me a message](#troubleshooting), I'd be happy to help!

While creating this repository and script, I wanted to make it as easy as possible for anyone to use it. That's why I've implemented various checks in order to run the script, so you don't have to! These include:

- Check if adb is installed, and if not install it.
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

```sh
./deploy.sh
```

*Note: By running the above command, the script will automatically try to figure out what platform you want to run the script on! If this doesn't work, please specify the platform.*

Running the script on Bluestacks:

```sh
./deploy.sh bs
```

Running the script on Nox:

```sh
./deploy.sh nox
```

<hr>

[Previous](https://github.com/zebscripts/AFK-Daily/wiki/Requirements) | [Next](https://github.com/zebscripts/AFK-Daily/wiki/Config)