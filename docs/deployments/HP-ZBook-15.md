HP ZBook 15 deployment
====================================================================================================

<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux</i></b> onto the HP ZBook 15
<br><br><br>

### Quick Links
* [.. up dir](https://github.com/phR0ze/cyberlinux)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [Graphics](#graphics)
    * [Hardware Acceleration](#hardware-acceleration)
    * [Backlight](#backlight)
    * [Display port](#display-port)
  * [Toggle Devices](#toggle-devices)
  * [WiFi](#wifi)

## Install cyberlinux <a name="install-cyberlinux"/></a>
1. Now boot from the USB:  
   a. Plug in the [Multiboot USB](../../README.md#create-multiboot-usb)  

3. Install `cyberlinux`:  
   a. Select the desired deployment type e.g. `Desktop`  
   b. Walk through the wizard enabling WiFi on the way  
   c. Complete out the process and login to your new system  
   d. Unplug the USB, reboot and log back in  

## Configure cyberlinux <a name="configure-cyberlinux"/></a>
1. Copy over ssh keys to `~/.ssh`
2. Copy over any wallpaper to `/usr/share/backgrounds`

## Graphics <a name="graphics"/></a>
The ***HP ZBook 15*** laptop has hybrid graphics, using the intel chipset to conserve power and the
Nvidia discrete graphics for power. I've always run with this disabled and just used the discrete
graphics. However Linux doesn't create the backlight controls unless it is enabled thus generating
the desired ***/sys/class/backlight/intel_backlight*** files.

### Hardware Acceleration <a name="hardware-acceleration"/></a>
[Hardware Acceleration](https://wiki.archlinux.org/title/Hardware_video_acceleration)

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

### Backlight <a name="backlight"/></a>
cyberlinux uses the ***https://aur.archlinux.org/packages/light/*** script to configure the
backlights.  ***Light*** is used directly in the ***~/.config/openbox/rc.xml*** config file.

```bash
# Increment backlight brightness by 10%
light -A 10

# Decrement backlight brightness by 10%
light -U 10
```

### Display port <a name="display-port"/></a>
Using the ***toggle*** script I was able to get the external output to turn and off mirroring the
internal display at 1280x1024 resolution just fine when the laptop was started undocked.

Additionally if I enable the internal display before undocking I won't loose it after undocking
although I haven't tried the projector in this state.

I was unable to get the dock display to enable again after redocking until restarting in the docked
state although the internal display continued to work until restarted.

## Toggle Devices <a name="toggle-devices"/></a>
cyberlinux uses the ***/opt/cyberlinux/bin/toggle*** script to toggle wifi/bluetooth radios and
external displays on and off as follows:

```bash
# Toggle wifi
sudo toggle wifi

# Toggle bluetooth
sudo toggle bluetooth

# Toggle display 
sudo toggle display
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
