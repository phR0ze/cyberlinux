# Samsung Chromebook 3 (a.k.a CELES)
<img align="left" width="48" height="48" src="https://raw.githubusercontent.com/phR0ze/cyberlinux/master/art/logo_256x256.png">
The Samsung Chromebook 3 is an excellent general purpose netbook. Thanks to the opensource community
everything is availble to change it from a ChromeOS paper weight into a fully functioning Linux system.  Kudos to
<b><i>Mr. Chromebox</i></b> <a href="https://mrchromebox.tech">https://mrchromebox.tech</a> for the UEFI firmware to make this happen. 

### Table of Contents
* [Build Deployable ISO](#build-deployable-iso)
    * [Compatible Environment](#compatible-environment)
    * [Build Profile](#build-profile)
* [Deploy ISO from bootable USB drive](#deploy-iso-from-bootable-usb-drive)
    * [Prerequisites](#prerequisites)
    * [Install cyberlinux](#install-cyberlinux)
* [License](#license)
* [Configuration](#configuration)
    * [Kernel](#kernel)
    * [Video](#video)
    * [WiFi](#wifi)
    * [BlueTooth](#bluetooth)
    * [Keyboard/Touchpad](#keyboard-touchpad)
    * [Sound Output](#sound-output)
    * [Microphone Headset](#microphone-headset)
    * [USB Storage](#usb-storage)
    * [MicroSD Storage](#micro-sd-storage)
    * [Android Phone MTP](#android-phone-mtp)
    * [HDMI Output](#hdmi-output)
    * [Suspend](#suspend)
    * [Brightness](#brightness)
    * [Battery Status](#battery-status)
    * [Key Mappings](#key-mappings)
    * [Keyboard Shortcuts](#keyboard-shortcuts)

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
    sudo ./reduce clean build all -p personal-celes
    ```

## Deploy ISO from bootable USB drive <a name="deploy-iso-from-bootable-usb-drive"/></a>

### Prerequisites <a name="prerequisites"/></a>
Chromebooks are not setup for Linux out of the box however there has been some excellent work done
in the community to make Chromebooks behave like normal Linux netbooks.

1. Prepare you system for install using [these](https://wiki.galliumos.org/Installing/Preparing)
   instructions
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
for commercial purposes. It is only to be used for personal use.

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
https://wiki.archlinux.org/index.php/bluetooth

```bash
# Install Bluetooth management tool and pulse audio plugin
sudo pacman -S blueman pulseaudio-bluetooth
# Enable/Start the Bluetooth daemon
sudo systemctl enable bluetooth
sudo systemctl start bluetooth
# Start Blueman
```

### Keyboard/Touchpad <a name="keyboard-touchpad"/></a>
Keyboard and Touchpad support required kernel changes see [linux-celes](https://github.com/phR0ze/cyberlinux/tree/master/aur/linux-cele)

The Keyboard has been flawless, but the touchpad driver has been iffy seem Crash Note below. The
touchpad driver is a port of the ChromeOS mouse driver.

**Touchpad freezes:**
* https://github.com/GalliumOS/galliumos-distro/issues/415
* https://github.com/GalliumOS/linux/blob/v4.9.4-galliumos/galliumos/diffs/fix-celes-touchpad.diff
* https://github.com/GalliumOS/linux/blob/v4.16.13-galliumos/galliumos/diffs/sequence

Touchpad seems to occasionally freez when using Chrome or Libre Office and I assume others though
I've only noticed it with those two. When I close either application the touchpad driver seems to
recover.

```bash
# Temporary fix
sudo modprobe -r atmel_mxt_ts
sudo modprobe atmel_mxt_ts
```

### Sound Output <a name="sound-output"/></a>
Audio required using the [GalliumOS Braswell Config](https://aur.archlinux.org/packages/galliumos-braswell-config/), but after that seems to work well for both the speakers as well as headphones with jack detection working correctly.

### Microphone Headset <a name="microphone-headset"/></a>
?

### USB Storage <a name="usb-storage"/></a>
USB thumbdrives seem to work great, providing simple mount and eject options in Thunar and the
process can be repeated as many times as desired.

### MicroSD Storage <a name="micro-sd-storage"/></a>
The MicroSD card is recognized as ***/dev/mmcblk1*** and not as removable device. This would be a
problem if I intended to be inserting/removing it a lot, however I intend to simply use it as
personal data storage for things such as Documents and media separate from the main disk. This will
allow the main disk to be wiped and reinstalled as often as needed while keeping all non-system
i.e. personal data separate and protected during system re-installs/formats.

Prepare SD card for use and persistently mount:
```bash
# See device drivers and details
lspci -k
udevadm info -a -n /dev/mmcblk1
# Format use '-m 0' to prevent reserved block as this is a storage disk
sudo mkfs.ext4 -m 0 /dev/mmcblk1
# Mount, use 'noatime' to improve performance
sudo mkdir /mnt/storage
sudo tee -a /etc/fstab <<< "/dev/mmcblk1 /mnt/storage ext4 defaults,noatime 0 0"
sudo mount -a
sudo chown -R $USER: /mnt/storage
```

### Android Phone MTP <a name="android-phone-mtp"/></a>
1. Ensure the proper drivers are installed:
    ```bash
    sudo pacman -S libmtp gvfs-mtp
    sudo reboot
    ```
2. To connect your android phone via USB
3. Put the phone into USB file transfer mode

### HDMI Output <a name="hdmi-output"/></a>
irc nskelsey?

### Suspend <a name="suspend"/></a>
Suspend works out of the box with ***systemd*** as the default system manager

### Brightness <a name="brightness"/></a>
Brightness is controlled via the sysfs file ***/sys/class/backlight/intel_backlight/brightness***
with a max value of ***1200***. After not finding an easy solution to use xbackight, I simply wrote
my own script to modify the brightness directly and wired it up through openbox. See the
corresponding yaml file.

Get udev properties:
```bash
udevadm info -a -p /sys/class/backlight/intel_backlight
```

Manually change:

```bash
sudo tee /sys/class/backlight/intel_backlight/brightness <<< 800
```

### Battery Status <a name="battery-status"/></a>
To keep the OS as light as possible I decided to use [conky](https://github.com/phR0ze/cyberlinux/blob/master/layers/desktop-celes/etc/skel/.conkyrc) to provide ***Date***, ***Time***, ***Calendar***, and ***Battery status*** as well as a few other monitoring widgets.

### Key Mappings <a name="key-mappings"/></a>
Blah, this section is WIP, XKB kicked my butt for now.

* https://wiki.archlinux.org/index.php/xmodmap
* https://wiki.archlinux.org/index.php/X_KeyBoard_extension
* https://wiki.archlinux.org/index.php/Keyboard_configuration_in_console
* https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
* https://github.com/dnschneid/crouton/wiki/Keyboard
* https://www.x.org/wiki/XKB/
* https://jlk.fjfi.cvut.cz/arch/manpages/man/localectl.1
* https://wiki.galliumos.org/Media_keys_and_default_keybindings
* https://github.com/GalliumOS/xkeyboard-config/blob/master/debian/patches/chromebook.patch
* http://www.fascinatingcaptain.com/blog/remap-keyboard-keys-for-ubuntu/

***X Keyboard Extension (XKB)*** is how Linux configures keyboard layouts and key sequences.
During the creation of a layout you can use `xev` to determine key codes and symbol names.
The ***xkeyboard-config*** package provides the description files for the XKB system, settable with
***setxkbmap***. Use a custom layout file name to avoid obliteration on ***xkeyboard-config***
updates e.g. ***/usr/share/X11/xkb/symbols/chromebook***.

1. Make XKB changes
    1. Edit: ***sudo vim /usr/share/X11/symbols/pc***
    2. In the ***pc105*** section add ***key <FK01> { [XF86Back] }***
3. Clear XKB cache
    1. Run: `sudo rm -rf /var/lib/xkb/*.xkm`
4. Reboot

Creating a custom layout:
1. ***/usr/share/X11/xkb/symbols/us***
    * The layout file ***us*** may hosts many different layouts known as layout variants
    * Each layout variant can be written from scratch or it can inherit from a parent layout and modify something.
    * Create a custom layout ***/usr/share/X11/xkb/symbols/chromebook***
    * Have the custom layout inherit from ***us*** as its parent
* ***/usr/share/X11/xkb/rules/evdev***
    * Update the ***rules/evdev*** file to include your new layout

Celes Keyboard Hardware defaults:

| Param         | Value   | Explanation                                                    |
| ------------- | --------| -------------------------------------------------------------- |
| XkbModel      | pc105   | selects the keyboard model, usually ***pc104*** or ***pc105*** |
| XkbLayout     | us      | selects the keyboard layout, usually ***us***                  |
| XkbVariant    |         | selects the specific layout variant                            |
| XkbOptions    |         | any extra options                                              |

Set keyboard configuration:
```bash
# Current session only use setxkbmap
# setxkbmap [-model xkb_model] [-layout xkb_layout] [-variant xkb-variant] [-option xkb_options]
# See current configuration
setxkbmap -print -verbose 10
# Set current layout
setxkbmap -layout us -option ctrl:nocaps
# Persist layout for virtual console which saves in /etc/vconsole.conf
sudo localectl --no-convert set-keymap us
# Persist layout for X11 which saves in /etc/X11/xorg.conf.d/00-keyboard.conf
sudo localectl --no-convert set-x11-keymap us pc105
```

| Key               | Symbol                | xmodmap                                   |
| ----------------- | --------------------- | ----------------------------------------- |
| Search+F1         | F11                   | ?  |
| Search+F2         | F12                   | ?  |
| Search+F3         | XF86Reload            | ?  |
| Search+F4         | Print                 | ?  |
| Search+F5         | XF86                  | ?  |
| Search+F6         | XF86MonBrightnessDown | [ F6 ] |
| Search+F7         | XF86MonBrightnessUp   | ?  |
| Search+F8         | XF86AudioMute         | ?  |
| Search+F9         | XF86AudioLowerVolume  | ?  |
| Search+F10        | XF86AudioRaiseVolume  | ?  |
| BackSpace  | [ BackSpace, BackSpace, Delete ] | ?  |
| F11               | kk                    | ?  |
| F12       | ? |       |
| Home      | Overlay+Left |        |
| End       | ? | |
| Page Up   | ? |
| Page Down | ? |
| Insert    | ? |
| Delete    | Search+BackSpace      | `xmodmap -e "keycode 22 = Super_L"`      |

Manually invoke: `xmodmap ~/.Xmodmap`

### Keyboard Shortcuts <a name="keyboard-shortcuts"/></a>
Keyboard shortcuts are handled by OpenBox key bindings as described below

* ***Search key*** maps to ***Super_L***
* Top row ***function keys*** map to ***F1 - F10***

| Combination           | Function |
| --------------------- | -------- |
| Alt+F4                | Close the current window |
| Alt+Tab               | Switch to next window |
| Alt+Shift+Tab         | Switch to previous window |
| Search+c              | Reconfigure openbox |
| Search+e              | Launch Editor (GVim) |
| Search+f              | Launch FileManager (Thunar) |
| Search+l              | Lock (Cinnamon Lock) |
| Search+m              | Show the desktop |
| Search+o              | Launch Office (libre-office) |
| Search+r              | Launch Runner (dmenu) |
| Search+t              | Launch Terminal (lxterminal) |
| Search+w              | Launch Web Browser (chromium) |
| Search+x              | Launch Login Controls (oblogout) |
| Search+F1             | ? |
| Search+F2             | ? |
| Search+F3             | ? |
| Search+F4             | ? |
| Search+F5             | ? |
| Search+F6             | Decrease Brightness |
| Search+F7             | Increase Brightness |
| Search+F8             | Mute Volume |
| Search+F9             | Decrease Volume |
| Search+F10            | Increase Volume |
| Search+Up             | Maximize Window |
| Search+Down           | Minimize Window |
| Search+Escape         | Unmaximize Window |
| Search+Enter          | Centers Window |
| Search+minus          | Resize to smaller Window |
| Search+equal          | Resize to larger Window |
| Search+Left           | Dock Window left |
| Search+Right          | Dock Window Right |
| Alt+Search+F5         | Take Screenshot |
| Alt+Shift+Search+F5   | Launch Screenshot |
| Alt+Search+F6         | Increase Volume |
| Alt+Search+F7         | Increase Volume |
