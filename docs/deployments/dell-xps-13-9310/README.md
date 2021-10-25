Dell XPS 13 9310 deployment
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux XFCE Desktop</i></b> onto the `Dell XPS 13 9310`
<br><br>

### Quick links
* [.. up dir](..)
* [Device specs](#device-specs)
  * [SSD Upgrade](#ssd-upgrade)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [Settings](#settings)
    * [Flash BIOS to latest](#flash-bios-to-latest)
    * [SSH Keys](#ssh-keys)
    * [Backgrounds](#backgrounds)
  * [Graphics](#graphics)
  * [WiFi](#wifi)

# Device specs <a name="device-specs"/></a>

* CPU: `Intel 11th Gen EVO Core i7-1185G7@3.00GHz`
* BIOS came with: `2.2.0`
* Microcode Version: `86`
* Native resolution: `1900x1200`
* Video Controller: `Iris Xe`
* Video BIOS: `GOP 1055`
* Audio controller: `Realtek ALC3281-CG`

## SSD Upgrade <a name="ssd-upgrade"/></a>
The SSD options that dell provides are small, slow and way to expensive. I bought the
`Samsung V-NAND SSD 970 EVO Plus NVMe M.2 2TB` SSD from Amazon and it fits and works perfectly.

1. Turn the laptop over
2. Remove the 8 Torx T5 screws
3. Gently pry off the case starting in the front using a guitar pick
4. Remove the PH0 screw holding the SSD
5. Remove the old SSD
6. Bend the smaller bracket contraints flat to allow for the larger SSD
7. Install the new SSD and re-assemble

# Install cyberlinux <a name="install-cyberlinux"/></a>
You need to disable UEFI secure boot in order to install cyberlinux as only the Ubuntu factory
firmware that comes with the machine will be cryptographically signed for the machine.

1. Boot Into the `Setup firmware`:  
   a. Press `F2` while booting  
   b. In the left hand navigation select `Boot Configuration`  
   c. On the right side scroll down to `Secure Boot`  
   d. Flip the toggle on `Enable Secure Boot` to `OFF`  
   e. Select `Yes` on the Secure Boot disable confirmation  
   f. In the left hand navigation select `Storage`  
   g. Select `AHCI/NVMe` rather than `RAID On`  
   h. Select `APPLY CHANGES` at the bottom  
   i. Select `OK` on the Apply Settings Confirmation page  
   j. Select `EXIT` bottom right of the screen to reboot  

2. Now boot from the USB:  
   a. Plug in the [Multiboot USB](../../../cyberlinux#create-multiboot-usb)  
   b. Press `F2` while booting  
   c. Select your `UEFI` USB device  

3. Install `cyberlinux`:  
   a. Select the desired deployment option e.g. `Install xfce desktop`  
   b. Walk through the wizard enabling WiFi onlong the way  
   c. Complete out the process and login to your new system  
   d. Unplug the USB, reboot and log back in  

# Configure cyberlinux <a name="configure-cyberlinux"/></a>
* [Arch Linux Dell XPS 13 (9310)](https://wiki.archlinux.org/title/Dell_XPS_13_(9310))

First results:
* Pre login
  * Machine automatically started when the lid was opened
  * LXDM login is shown and looks great and logs in correctly
* Post login
  * Set display dimness almost to the bottom and it still looks great
  * Battery seems to be detected when charging and when plugged in
  * Conky started working after BIOS firmware update
  * Audio works after firmware install and restart
  * Audio keyboard buttons work
* Problems
  * Locks up and keyboard input doesn't work

## Settings <a name="settings"/></a>

### Flash BIOS to latest <a name="flash-bios-to-latest"/></a>
`fwupd` is a simple daemon that allows large vendors like Dell and Logitech to distribute firemware 
to Linux devices using what they call `Linux Vendor Firmware Service (LVFS)`

References:
* [Linux Vendor Firmware Service Device Update List](https://fwupd.org/lvfs/devices/)
* [Arch Linux Wiki](https://wiki.archlinux.org/title/Flashing_BIOS_from_Linux#fwupd)

1. Install fwupd
   ```bash
   $ sudo pacman -S fwupd
   ```
2. Check for updates
   ```bash
   $ sudo fwupdmgr refresh
   $ sudo fwupdmgr get-updates
   ```
3. Apply updates
   ```bash
   $ sudo fwupdmgr update
   ```

Upgrade to `3.0.4`

### SSH Keys <a name="ssh-keys"/></a>
Copy over ssh keys
```bash
$ scp -r USER@IP-ADDRESSS:~/.ssh .
```

### Backgrounds <a name="backgrounds"/></a>
Copy over any wallpaper to `/usr/share/backgrounds`

## Audio <a name="audio"/></a>
Requires the `alsa-firmware` and `sof-firmware` packages to work. After reboot you should be good.

* Volume Control buttons seem to work great

## Graphics <a name="graphics"/></a>
[Hardware Video Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

1. Install hardware acceleration drivers:
   ```bash
   $ sudo pacman -S intel-media-driver libvdpau-va-gl libva-utils vdpauinfo
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
Work perfectly with NetworkManager and the applet.

All you have to do is just left click on the `nm-applet` icon in the tray and select your WiFi SSID. 
Entry your password and you should be greeted with a connection pop up.

<!-- 
vim: ts=2:sw=2:sts=2
-->
