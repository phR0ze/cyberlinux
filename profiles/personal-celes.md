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
List out all properties for the sd card device. Seems as though it is recognized as ***/dev/mmcblk1***. It's not recognized as a removable device maybe?

```bash
lspci -k
```
```bash
udevadm info -a -n /dev/mmcblk1
```

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
* https://wiki.archlinux.org/index.php/xmodmap
* https://wiki.archlinux.org/index.php/X_KeyBoard_extension
* https://wiki.archlinux.org/index.php/Keyboard_configuration_in_console
* https://wiki.archlinux.org/index.php/Keyboard_configuration_in_Xorg
* https://github.com/dnschneid/crouton/wiki/Keyboard
* https://jlk.fjfi.cvut.cz/arch/manpages/man/localectl.1
* https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=xkeyboard-config-chromebook
* https://medium.com/@damko/a-simple-humble-but-comprehensive-guide-to-xkb-for-linux-6f1ad5e13450
* https://wiki.galliumos.org/Media_keys_and_default_keybindings
* https://github.com/GalliumOS/xkeyboard-config/blob/master/debian/patches/chromebook.patch
* https://www.linux.com/news/creating-custom-keyboard-layouts-x11-using-xkb

***xmodmap*** is a pretty good solution for one or two key remappings, but for a larger scale
solution the correct method is to use ***X Keyboard Extension (XKB)*** and create a new layout.
During the creation of a layout you can use `xev` to determine key codes and symbol names.
***xkeyboard-config*** provides the description files for the XKB system, settable with
***setxkbmap***. Use a custom layout file name to avoid obliteration on ***xkeyboard-config***
updates e.g. ***/usr/share/X11/xkb/symbols/chromebook***.

Creating a custom layout:
* ***/usr/share/X11/xkb/symbols/us***
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
setxkbmap -layout us
# Persist layout for virtual console which saves in /etc/vconsole.conf
sudo localectl --no-convert set-keymap us
# Persist layout for X11 which saves in /etc/X11/xorg.conf.d/00-keyboard.conf
sudo localectl --no-convert set-x11-keymap us pc105
```

| Key       | Combination           | xmodmap                                   |
| --------- | --------------------- | ----------------------------------------- |
| F11       | ? |                           |
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
