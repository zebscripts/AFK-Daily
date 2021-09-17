:: Kills everything related to AFK-Daily

:: > Bluestacks
::   > Bluestacks 4
taskkill /F /IM Bluestacks.exe
::   > Bluestacks 4 & 5
taskkill /F /IM HD-Player.exe
taskkill /F /IM BstkSVC.exe

:: > Memu
taskkill /F /IM MEmu.exe
taskkill /F /IM MEmuHeadless.exe
taskkill /F /IM MEmuSVC.exe
taskkill /F /IM MemuService.exe

:: > Nox
taskkill /F /IM Nox.exe
taskkill /F /IM nox_adb.exe
taskkill /F /IM NoxVMHandle.exe

:: > ADB
taskkill /F /IM adb.exe

:: > Shell
taskkill /F /IM bash.exe

:: End
pause
