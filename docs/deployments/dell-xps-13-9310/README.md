Dell XPS 13 9310 deployment
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux XFCE Desktop</i></b> onto the `Dell 
XPS 13 9310` and additional configuration and maintenance I've done on this system.
<br><br>

### Quick links
* [.. up dir](..)
* [Device](#device)
  * [Specs](#Specs)
  * [Open chassis covere](#open-chassis-cover)
  * [SSD Upgrade](#ssd-upgrade)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [Settings](#settings)
    * [Flash BIOS to latest](#flash-bios-to-latest)
    * [SSH Keys](#ssh-keys)
    * [Backgrounds](#backgrounds)
  * [Graphics](#graphics)
  * [WiFi](#wifi)
* [Troubleshooting](#troubleshooting)
  * [Boot from live USB](#boot-from-live-usb)
  * [Stuck on Dell boot logo](#stuck-on-dell-boot-logo)

# Device
**Resources:**
* [Tear down of XPS 9310](https://www.youtube.com/watch?v=Dzf4R3vr22M)
  * Shows battery removal
  * CPU heatsink and fan removal
  * Covers screen replacment as well
  * Covers motherboard replacement as well
  * States that modern laptops like 9310 don't have CMOS battery but instead run directly off the 
  main battery
* [Service Manual PDF](https://dl.dell.com/topicspdf/xps-13-9310-laptop_service-manual_en-us.pdf)

## Specs
* CPU: `Intel 11th Gen EVO Core i7-1185G7@3.00GHz`
* BIOS came with: `2.2.0`
* Microcode Version: `86`
* Native resolution: `1900x1200`
* Video Controller: `Iris Xe`
* Video BIOS: `GOP 1055`
* Audio controller: `Realtek ALC3281-CG`

## Open chassis cover
1. Turn the laptop over
2. Remove the 8 Torx T5 screws
3. Use a guitar pick to gently pry off the case starting from the front two edges and along front
   then lift up the front.

## SSD Upgrade
The SSD options that dell provides are small, slow and way to expensive. I bought the
`Samsung V-NAND SSD 970 EVO Plus NVMe M.2 2TB` SSD from Amazon and it fits and works perfectly.

1. [Remove the chassis cover](#open-chassis-cover)
2. Remove the PH0 screw holding the SSD
3. Remove the old SSD
4. Bend the smaller bracket contraints flat to allow for the larger SSD
5. Install the new SSD and re-assemble

# Install cyberlinux
You need to disable UEFI secure boot in order to install cyberlinux as only the Ubuntu factory
firmware that comes with the machine will be cryptographically signed for the machine.

1. Boot Into the `Setup firmware`:  
   a. Press `F2` while booting (no need to press `Fn` key)  
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

# Configure cyberlinux
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

## Settings

### Flash BIOS to latest
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

### SSH Keys
Copy over ssh keys
```bash
$ scp -r USER@IP-ADDRESSS:~/.ssh .
```

### Backgrounds
Copy over any wallpaper to `/usr/share/backgrounds`

## Audio
Requires the `alsa-firmware` and `sof-firmware` packages to work. After reboot you should be good.

* Volume Control buttons seem to work great

## Graphics
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

## WiFi
Work perfectly with NetworkManager and the applet.

All you have to do is just left click on the `nm-applet` icon in the tray and select your WiFi SSID. 
Entry your password and you should be greeted with a connection pop up.

# Troubleshooting

## Boot from live USB
1. Plug your live USB stick into a USB-C adapter and then into your laptop
2. Press the power button to boot then start pressing `F12` (no need to press `Fn` key)
3. Once the `One-Time Boot Settings` loads select your USB drive and press `Enter`

## Stuck on Dell boot logo
According to the [Dell XPS 13 9310 tear down](https://www.youtube.com/watch?v=Dzf4R3vr22M) video the 
9310 doesn't have a CMOS battery but rather simply uses the main battery. This means that to clear 
the CMOS out all you have to do is disconnect the main battery and wait for some time for the CMOS to 
discharge.

NOTE: this solution will supposedly fix a lot of BIOS issues. However my system was actually 
suffering from a 2 amber 4 white light issue which is bad RAM which is soldered to the motherboard. 
So calling support for this one.

1. [Remove the chassis cover](#open-chassis-cover)
2. Disconnect the main battery
3. Flip the unit over on a non-metalic surface 
4. Hold the power down for at least 30sec
5. Re-connect the main battery

## Installer debugging
Debugging strange installer issues I'm seeing.

1. Installed with Dell Ubuntu USB twice - `Success`
  * Pulled USB at end and rebooted and it booted fine 
  * The chances of a flakey SSD working both times are low so concluding SSD is good
  * Further inspection revealed the Dell Ubuntu installer created a new EFI boot entry `ubuntu` and 
  made it the first install priority
  * Probing this install option a bit
    * Rebooted and used `F12` to select `SSD` - `failed`
    * Rebooted and used `F12` to select new `ubuntu` - `success`
  * NOTE: the dell tuned OS re-enabled secure boot in BIOS
2. Installing via Cyberlinux installer - `failed to boot`
  * Using `F12` booted into one time boot then BIOS
  * Removed all EFI entries except SSD and USB
  * Installing `base shell` for speed
  * Booted into a USB live system and found:
    * that the boot files were not correct
    * some /usr/lib files were zero bytes - what?
3. Testing the installer in a UEFI enabled VM works fine
  * Note the VM doesn't have a NVMe device
  * Live system is failing with a docker bug
    ```
    [FAILED] Failed to start Docker Application Container Engine
    overlayfs: filesystem on '/var/lib/docker/check-overlayfs-support../upper' not supported as upperdir
    ```
4. Testing USB flash drive health
  * Tested for bad blocks and corruption all passed
5. Minimal standard base install works - `success`
  * MUST be something in the more complicated installs


<!-- 
vim: ts=2:sw=2:sts=2
-->
