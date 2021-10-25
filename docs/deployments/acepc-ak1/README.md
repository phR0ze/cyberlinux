ACEPC AK1 deployment
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux</i></b> onto the ACEPC AK1 including
configuration changes to enable WiFi 
<br><br>

### Quick links
* [.. up dir](..)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [Graphics](#graphics)
  * [WiFi](#wifi)
  * [Teamviewer](#teamviewer)
  * [Kodi](#kodi)

# Install cyberlinux <a name="install-cyberlinux"/></a>
Note because of the `xHCI` USB driver being used by the newer firmware on the ACEPC AK1 you must
choose an `UEFI` boot option in order to get keyboard support during the install as shown below.

1. Boot Into the `Setup firmware`:  
   a. Press `F7` repeatedly until the boot menu pops up  
   b. Select `Enter Setup`  
   c. Navigate to `Security >Secure Boot`  
   d. Ensure it is `Disabled`  

2. Now boot the AK1 from the USB:  
   a. Plug in the [Multiboot USB](../../../cyberlinux#create-multiboot-usb)  
   b. Press `F7` repeatedly until the boot menu pops up  
   c. Select your `UEFI` device entry e.g. `UEFI: USB Flash Disk 1.00`  

3. Install `cyberlinux`:  
   a. Select the desired deployment type e.g. `Install xfce desktop`  
   b. Complete out the process and login to your new system  
   c. Unplug the USB, reboot and log back in  

# Configure cyberlinux <a name="configure-cyberlinux"/></a>
1. Copy over ssh keys to `~/.ssh`
2. Copy over any wallpaper to `/usr/share/backgrounds`

## Graphics <a name="graphics"/></a>
[Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

1. Install hardware acceleration drivers:
   ```bash
   $ sudo pacman -S xf86-video-intel libva-intel-driver libvdpau-va-gl liva-utils vdpauinfo
   ```
2. Valid output from `vainfo` should show your acceleration is working
   ```bash
   $ vainfo
   ```
3. Valid output from `vdpauinfo` should show your acceleration is working
   ```bash
   $ vdpauinfo
   ```

## WiFi <a name="wifi"/></a>

### WiFi for Xfce <a name="wifi-for-xfce"/></a>
In Xfce we use NetworkManager rather than systemd-networkd which is heavier but it gives a nice user 
experience for Wifi connectivity

1. 

### WiFi for Openbox <a name="wifi-for-openbox"/></a>
1. WPA GUI will be launched automatically
2. Select `Scan >Scan` then doblue click the chosen `SSID`
3. Enter the pre-shared secret `PSK` and click `Add`
4. You should have an ip now you can verify with `ip a` in a shell
5. Set a static ip if desired, edit `sudo /etc/systemd/network/30-wireless.network`
   ```
   [Match]
   Name=wl*

   [Network]
   Address=192.168.1.7/24
   Gateway=192.168.1.1
   DNS=1.1.1.1
   DNS=1.0.0.1
   IPForward=kernel
   ```
6. Restart networking
   ```bash
   $ sudo systemctl restart systemd-networkd
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

<!-- 
vim: ts=2:sw=2:sts=2
-->
