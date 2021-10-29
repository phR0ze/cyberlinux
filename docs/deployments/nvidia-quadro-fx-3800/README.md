nVidia Quadro FX 3800
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux</i></b> onto older machines
running the nVidia Quadro FX 3800.
<br><br>

### Quick links
* [.. up dir](..)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [General](#general)
  * [Graphics](#graphics)
  * [Teamviewer](#teamviewer)
  * [Kodi](#kodi)
  * [Warcraft 2](#warcraft-2)

# Install cyberlinux <a name="install-cyberlinux"/></a>
This particular machine is an HP Z420

1. Now boot from the USB:  
   a. Plug in the [Multiboot USB](../../../cyberlinux#create-multiboot-usb)  
   b. Press `F9` repeatedly until the boot menu pops up  
   c. Select your USB device entry  

3. Install `cyberlinux`:  
   a. Select the desired deployment type e.g. `Install xfce theater`  
   b. Complete out the process and unplug the USB  
   c. Reboot your system usually `Ctrl+Alt+Delete` and login  

# Configure cyberlinux <a name="configure-cyberlinux"/></a>

## General <a name="general"/></a>
1. Copy over ssh keys to `~/.ssh`
2. Copy over any wallpaper to `/usr/share/backgrounds`

## Graphics <a name="graphics"/></a>
[Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

1. Install hardware acceleration drivers:
   ```bash
   $ sudo pacman -S libvdpau-va-gl libva-utils vdpauinfo
   ```
2. Valid output from `vainfo` should show your acceleration is working
   ```bash
   $ vainfo
   ```
3. Valid output from `vdpauinfo` should show your acceleration is working
   ```bash
   $ vdpauinfo
   ```

## Teamviewer <a name="teamviewer"/></a>
1. Launch Teamviewer from the tray icon
2. Navigate to `Extras >Options`
3. Set `Choose a theme` to `Dark` and hit `Apply`
4. Navigate to `Advanced` and set `Personal password` and hit `OK`

## Kodi <a name="kodi"/></a>
1. Hover over selecting `Remove this main menu item` for those not used `Muic Videos, TV, Radio, Games, Favourites`  
2. Add NFS shares as desired  
3. Navigate to `Movies > Enter files selection > Files >Add videos...`  
4. Select `Browse >Add network location...`  
5. Select `Protocol` as `Network File System (NFS)`  
6. Set `Server address` to your target e.g. `192.168.1.3`  
7. Set `Remote path` to your server path e.g. `srv/nfs/Movies`  
8. Select your new NFS location in the list and select `OK`  
9. Select `OK` then set `This directory contains` to `Movies`  
10. Set `Choose information provider` and set `Local information only`  
11. Set `Movies are in separate folders that match the movie title` and select `OK`  
12. Repeat for any other NFS share paths your server has  

## Warcraft 2 <a name="warcraft-2"/></a>
1. Follow the [instructions here](../../system/wine/README.md#install-warcraft-2)
2. Create the bash script `~/bin/warcraft2`
   ```bash
   #!/bin/bash

   WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 wine ~/.wine/prefixes/warcraft2/drive_c/GOG\ Games/Warcraft\ II\ BNE/Warcraft\ II\ BNE_dx.exe
   ```
3. Make the script executable `chmod +x ~/bin/warcraft2`
4. Launch warcaft by pressing Super+R and entering `warcraft2`

<!-- 
vim: ts=2:sw=2:sts=2
-->
