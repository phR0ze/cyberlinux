BlueMan configuration
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
[BlueMan](https://wiki.archlinux.org/title/Blueman) is a full featured Bluetooth manager written in 
Python using GTK.
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
  * [Install](#install)

# Overview <a name="overview"/></a>

## Install <a name="install"/></a>
1. Install the packages
   ```bash
   $ sudo pacman -S blueman pulseaudio-blueman
   ```
2. Start the bluetooth service
   ```bash
   $ sudo systemctl enable bluetooth
   $ sudo systemctl start bluetooth
   ```
3. Start the BlueMan applet for the tray
   ```bash
   $ blueman-applet
   ```

<!-- 
vim: ts=2:sw=2:sts=2
-->
