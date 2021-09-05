## Emulator

### Nox

Nox is using a specific `adb` version, called `nox_adb.exe`. There is a high change that it's already running at the start of Nox without you having to do anything, but if it's not the case please check the configuration here:

- Our wiki: <https://github.com/zebscripts/AFK-Daily/wiki/Requirements>
- More info: <https://www.bignox.com/blog/how-to-connect-android-studio-with-nox-app-player-for-android-development-and-debug/>

Run the script using the following command:

```console
deploy.sh -d Nox
```

*If you need help with `nox_adb.exe` please contact us on our [Discord](https://discord.gg/Fq2cfqjp8D) server with the result of this command `ps -W | grep -i nox_adb.exe`.*

### MEmu

MEmu has `adb` enabled by default, so there are no requirements other than opening Memu before running the script. Run the script on MEmu with the following command:

```console
deploy.sh -d memu
```

## OS

### Mac

1. First of all, make sure your AFK Arena account meets the requirements to even run the script: <https://github.com/zebscripts/AFK-Daily/wiki/Requirements>
2. Start by creating a folder called for example Scripts where you want this script to be placed in.
3. Open the folder and click on Action on the top right to open a new terminal inside this folder.
4. Next, run the following command inside the terminal:

    ```console
    git clone <https://github.com/zebscripts/AFK-Daily.git>
    ```

5. Close your terminal when the previous command is done and navigate to the newly created folder AFK-daily. Open a new terminal the same way you did on step 2.
6. Run the following command:

    ```console
    bash deploy.sh
    ```

7. If you get an `Error: Couldn't find OS.` error, please download the necessary files from the link in the terminal for the MacOS. After downloading it, unzip the content of the downloaded file into the newly created adb folder inside `AFK-daily`. In the end, you should have a file structure like `AFK-daily/adb/platform-tools` that has various files and folders inside, like for example the file adb (`AFK-daily/adb/platform-tools/adb`).
8. Open the newly created `config.ini` file by double-clicking it and edit its variables to your liking. Here's a link explaining what each one does: <https://github.com/zebscripts/AFK-Daily/wiki/Config>
9. Save the file and exit.
10. Install Bluestacks (as of writing this guide, BS5 is not yet available for Mac, so you'll have to install BS4), and make sure to apply the settings present in this section under Bluestacks 5 (most settings should exist in BS4 as well): <https://github.com/zebscripts/AFK-Daily/wiki/Requirements>. You can access BS settings like this: <https://support.bluestacks.com/hc/article_attachments/360080656112/a.png>
11. Install AFK Arena in Bluestacks and make sure you have your account set up.
12. Now it's finally time to try and run the script by executing `bash deploy.sh` again.

If everything worked as expected, you should see the game restart and then play on it's own and attempt to do daily stuff for you! From this point on, all you have to do to run the script again is open a terminal inside the AFK-daily folder and then run `bash deploy.sh`.

<hr>

<div align="center">
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Usage">Previous page</a>
<!-- |
<a href="https://github.com/zebscripts/AFK-Daily/wiki/Tips">Next page</a> -->
</div>
