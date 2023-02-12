HP Notebook 15-bs060wm
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux</i></b> onto this notebook
<br><br>

### Quick links
* [.. up dir](..)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [WiFi](#wifi)
  * [Keyboard](#keyboard)
  * [Graphics](#graphics)

## Install cyberlinux
1. Now boot from the USB:
   1. Plug in the [Multiboot USB](../../../cyberlinux#create-multiboot-usb)

3. Install `cyberlinux`:
   1. Select the desired deployment type e.g. `Install xfce desktop`
   2. Complete the process unplug the USB, reboot and login

## Configure cyberlinux
1. Copy over ssh keys to `~/.ssh`
2. Copy over any wallpaper to `/usr/share/backgrounds`

### WiFi
I was able to use the Xfce network manager system tray icon to configure Wifi without any problems

### Keyboard
All the keyboard hot keys seem to work
* Brightness up and down
* Volumen up and down
* Airplane mode

### Graphics
The ***HP Notebook 16-bs060wm*** uses the Intel HD Graphics 620 and seems to have problems with 
hardware acceleration out of the box. This means that `xfwm4` will fail to launch and without a 
window manager running you strange behavior e.g. keyboard input is only capture in a window if the 
mouse is hovering over that window.

The easiest way to work around this temporarily is to disable xfwm4's compositing until you get the 
accelerated graphics working.
* Check current value `xfconf-query -c xfwm4 -p /general/use_compositing`
* Disable `xfconf-query -c xfwm4 -p /general/use_compositing -s false`

#### Hadware Acceleration
[Hardware Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

1. Install hardware acceleration drivers:
   ```bash
   $ sudo pacman -S intel-media-driver libva-intel-driver libvdpau-va-gl libva-utils vdpauinfo
   ```
2. Valid output from `vainfo` should show your acceleration is working
   ```bash
   $ vainfo
   ```
3. Valid output from `vdpauinfo` should show your acceleration is working
   ```bash
   $ vdpauinfo
   ```

<!-- 
vim: ts=2:sw=2:sts=2
-->
