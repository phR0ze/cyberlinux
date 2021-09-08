Dell XPS 13 9310 deployment
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux</i></b> onto the Dell XPS 13 9310 
<br><br>

### Quick Links
* [.. up dir](README.md)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [Graphics](#graphics)
  * [WiFi](#wifi)

## Install cyberlinux <a name="install-cyberlinux"/></a>
You need to disable UEFI secure boot in order to install cyberlinux as only the Ubuntu factory
firmware that comes with the machine will be cryptographically signed for the machine.

1. Boot Into the `Setup firmware`:  
   a. Press `F2` while booting  
   b. In the left hand navigation select `Boot Configuration`  
   c. On the right side scroll down to `Secure Boot`  
   d. Flip the toggle on `Enable Secure Boot` to `OFF`  
   e. Select `Yes` on the Secure Boot disable confirmation  
   f. Select `APPLY CHANGES` at the bottom  
   g. Select `OK` on the Apply Settings Confirmation page  
   h. Select `EXIT` bottom right of the screen to reboot  

2. Now boot from the USB:  
   a. Plug in the [Multiboot USB](../../README.md#create-multiboot-usb)  
   b. Press `F2` while booting  
   c. Select your `UEFI` USB device  

3. Install `cyberlinux`:  
   a. Select the desired deployment type e.g. `Desktop`  
   b. Walk through the wizard enabling WiFi on the way  
   c. Complete out the process and login to your new system  
   d. Unplug the USB, reboot and log back in  

## Configure cyberlinux <a name="configure-cyberlinux"/></a>
1. Copy over ssh keys to `~/.ssh`
2. Copy over any wallpaper to `/usr/share/backgrounds`

### Graphics <a name="graphics"/></a>
[Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

1. Install hardwar acceleration drivers:
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

### WiFi <a name="wifi"/></a>
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

<!-- 
vim: ts=2:sw=2:sts=2
-->
