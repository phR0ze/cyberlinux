# Samsung Chromebook 3 (a.k.a CELES)
<img align="left" width="48" height="48" src="https://raw.githubusercontent.com/phR0ze/cyberlinux/master/art/logo_256x256.png">
The Samsung Chromebook 3 is an excellent general purpose netbook. Thanks to the opensource community
everything is availble to change it from a ChromeOS paper weight into a full Linux operating system.  Kudos to
<b><i>Mr. Chromebox</i></b> <a href="https://mrchromebox.tech">https://mrchromebox.tech</a> for the firmware to make this happen. 

### Table of Contents
* [Build Deployable ISO](#build-deployable-iso)
    * [Compatible Environment](#compatible-environment)
    * [Build Profile](#build-profile)
* [Deploy ISO from bootable USB drive](#deploy-iso-from-bootable-usb-drive)
    * [Prerequisites](#prerequisites)
    * [Install cyberlinux](#install-cyberlinux)
* [License](#license)
* [Configuration](#configuration)

## Build Deployable ISO <a name="build-deployable-iso"/></a>

### Compatible Environment <a name="compatible-environment"/></a>
You'll need to be running cyberlinux or a compatible environment

### Build Profile <a name="build-profile"/></a>
Once you have a compatible enviroment setup:

1. Clone ***cyberlinux***
    ```bash
    git clone https://github.com/phR0ze/cyberlinux.git
    ```
2. Build ***personal-celes*** profile
    ```bash
    sudo ./reduce clean build --iso-full --profile=personal-celes
    ```

## Deploy ISO from bootable USB drive <a name="deploy-iso-from-bootable-usb-drive"/></a>

### Prerequisites <a name="prerequisites"/></a>
Chromebooks are not setup for Linux out of the box however there has been some excellent work done
in this area to make Chromebooks behave like normal Linux netbooks.

1. Follow the direction found here https://wiki.galliumos.org/Installing/Preparing
2. Burn your ISO to a USB using
    ```bash
    sudo dd bs=4M if=/path/to/cyberlinux.iso of=/dev/sdx status=progress oflag=sync
    ```

### Install cyberlinux <a name="install-cyberlinux"/></a>
1. Boot from USB
2. Select deployment option
3. Step through short wizard
4. Wait for ~5-10min for install to complete
5. Remove USB and reboot

## License <a name="license"/></a>
As called out in the [README.md](https://github.com/phR0ze/cyberlinux/tree/master/profiles) this
profile prefixed with ***personal*** uses applications with various restrictions and can not be used
commercial purposes. It is only to be used for personal use only.

## Configuration <a name="configuration"/></a>
Documenting various configuration changes that I made to support the ***celes*** platform here.
These changes are automatically applied for you in the corresponding yaml file
https://github.com/phR0ze/cyberlinux/blob/master/profiles/personal-celes.yml and only included here as a reference.

### Kernel <a name="kernel"/></a>
In order to improve performance (I'm using the ***BFQ Storage I/O Scheduler*** as well as ***MuQSS Process Scheduler***) and to support
the ***Braswell*** keyboard/touchpad drivers I decided to roll my own kernel [linux-celes](https://github.com/phR0ze/cyberlinux/tree/master/aur/linux-celes) which borrows work from the ***Manjaro*** and ***GalliumOS*** projects as well as ***Con Kolivas***.

### Video <a name="video"/></a>
Video worked out of the box with the ***xf86-video-intel*** driver included with Arch Linux.

### WiFi <a name="wifi"/></a>
CELES has the Intel Corporation Wireless 7265 [8086:095a] ***REV=0x210*** termed as the ***7265D*** supported by the latest
***iwlwifi 29.610311.0*** as found from **dmesg | grep iwlwifi**. WiFi worked out of the box with the ***wpa_gui***, ***wpa_supplicant*** packages from Arch Linux.

### BlueTooth <a name="bluetooth"/></a>
?

### Keyboard/Touchpad <a name="keyboard-touchpad"/></a>
Keyboard and Touchpad support required kernel changes see [linux-celes](https://github.com/phR0ze/cyberlinux/tree/master/aur/linux-cele)

### Sound Output <a name="sound-output"/></a>
Audio required using the [GalliumOS Braswell Config](https://aur.archlinux.org/packages/galliumos-braswell-config/), but after that seems to work well for both the speakers as well as headphones with jack detection working correctly.

### Microphone Headset <a name="microphone-headset"/></a>
?

### USB Storage <a name="usb-storage"/></a>
?

### MicroSD Storage <a name="micro-sd-storage"/></a>
?

### HDMI Output <a name="hdmi-output"/></a>
irc nskelsey?

### Suspend <a name="suspend"/></a>
Suspend works out of the box with ***systemd*** as the default system manager

### Brightness <a name="brightness"/></a>
Brightness is controlled via the sysfs file ***/sys/class/backlight/intel_backlight/brightness***
with a max value of ***1200***. After not finding an easy solution to use xbackight, I simply wrote
my own script to modify the brightness directly and wired it up through openbox. See the
corresponding yaml file.

Manually change:

```bash
sudo tee /sys/class/backlight/intel_backlight/brightness <<< 800
```

### Battery Status <a name="battery-status"/></a>
To keep the OS as light as possible I decided to use [conky](https://github.com/phR0ze/cyberlinux/blob/master/layers/desktop-celes/etc/skel/.conkyrc) to provide ***Date***, ***Time***, ***Calendar***, and ***Battery status*** as well as a few other monitoring widgets.

### Hot Keys <a name="hot-keys"/></a>
I took advantage of OpenBox to map the Search button on the keyboard (which by default is the Super key) as a
modifier for Audio and Brightness controls.

I have as yet not figured out how to get the following working:
* ***Back***
* ***Forward***
* ***Refresh***
* ***Full Screen***
* ***HDMI***

***galliumos-xkeyboard-config***?
