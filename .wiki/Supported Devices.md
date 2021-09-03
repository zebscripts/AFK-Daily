Theoretically, anything that supports `adb` and is capable of running the latest AFK Arena game version with a resolution of `1080x1920` should be supported. We do, however, **recommend using Bluestacks** as it's our emulator of choice to test the script on. It's impossible for us to test the script on every other platform, which means at least Bluestacks will most likely always work.

- Bluestacks 5
- Memu
- Nox
- Personal device

<hr>

## [Bluestacks 5](https://www.bluestacks.com/)

   1. **Display:**
      - Change the resolution to `1080x1920`
      - *Optional:* Change from Landscape (Tablet mode) to Portrait (Phone mode)
      - *Recommended:* Use `240 DPI` (shouldn't affect the script, but you never know)
   2. **Device Settings:**
      - *Recommended:* Samsung Galaxy S8 Plus
   3. **Advanced:**
      - Enable Android Debug Bridge (ADB)

<hr>

## [Memu](https://www.memuplay.com/)

*It's in beta*

   1. **Display:**
      - Change the resolution to `1080x1920`
      - *Optional:* Change from Landscape (Tablet mode) to Portrait (Phone mode)

<hr>

## [Nox](https://www.bignox.com/)

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

## Personal Device

1. **USB Debugging:** Visit [this link](https://www.xda-developers.com/install-adb-windows-macos-linux/) on how to enable USB Debugging. It's in the beginning, under the `Phone Setup` part. *The settings on Nox are inside a folder called Tools.*
2. **Resolution:** Make sure your Device is set to `1080x1920`.
3. **AFK Arena:** Install the game. Duh.
4. **Root:** Unfortunately root is necessary. If you don't have root access, please use an emulator (Bluestacks).
5. **[BusyBox](https://play.google.com/store/apps/details?id=stericson.busybox):** This will install one specific command that the script uses for pixel analysis.
