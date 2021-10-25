Samsung Chromebook 3 (CELES) deployment
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting the steps I went through to deploy <b><i>cyberlinux</i></b> onto the Samsung Chromebook3
(CELES) including configuration changes to enable WiFi 
<br><br>

### Quick links
* [.. up dir](..)
* [Prerequisites](#prerequsites)
* [Install cyberlinux](#install-cyberlinux)
* [Configure cyberlinux](#configure-cyberlinux)
  * [BlueTooth](#bluetooth)
  * [Headset](#headset)
  * [HDMI Output](#hdmi-output)
  * [Kernel](#kernel)
  * [Key Mappings](#key-mappings)
  * [Keyboard Shortcuts](#keyboard-shortcuts)
  * [MicroSD Storage](#micro-sd-storge)
  * [Power Management](#power-management)
    * [Battery Status](#battery-status)
    * [Display Brightness](#display-brightness)
    * [Suspend](#suspend)
  * [Sound](#sound)
  * [Touchpad](#touchpad)
  * [USB Storage](#usb-storage)
  * [Video](#video)
  * [WiFi](#wifi)

## Prerequisites <a name="chromebook-3-prerequisites"/></a>
Chromebooks are not setup for Linux out of the box however there has been some excellent work done
in the community to make Chromebooks behave like normal Linux netbooks.

see [Prepare you system for install](https://wiki.galliumos.org/Installing/Preparing)

## Install cyberlinux <a name="install-cyberlinux"/></a>
With earlier kernel versions and drivers there were some quirks to work out but the latest `5.13.13`
and associated Arch Linux packages seem to work pretty smooth.

1. Boot Into the `Setup firmware`:  
   a. Plug in the [Multiboot USB](../../../cyberlinux#create-multiboot-usb)  
   b. Power on the system and press `Esc` repeatedly until the Setup firmware loads  
   b. Select `Boot Manager`  
   c. Select `EFI USB Device`  

2. Install `cyberlinux`:  
   a. Select the desired deployment type e.g. `Install xfce netbook`  
   b. Walk through the wizard enabling WiFi onlong the way  
   c. Complete out the process and login to your new system  
   d. Unplug the USB, reboot and log back in  

## Configure cyberlinux <a name="configure-cyberlinux"/></a>
1. Copy over ssh keys to `~/.ssh`
2. Copy over any wallpaper to `/usr/share/backgrounds`

### BlueTooth <a name="bluetooth"/></a>
BlueTooth seems to work fine out of the box

1. Install Bluetooth management tool and pulse audio plugin
   ```bash
   $ sudo pacman -S blueman pulseaudio-bluetooth
   ```
2. Enable Bluetooth
   ```bash
   $ sudo systemctl enable bluetooth
   $ sudo systemctl start bluetooth
   ```
3. Start BlueMan applet. Which will automatically happen on boot.
   ```bash
   $ blueman-applet
   ```

### Headset <a name="headset"/></a>
TBD

### HDMI Output <a name="hdmi-output"/></a>
TBD

### Kernel <a name="kernel"/></a>
Originally I was rolling my own kernel using the ***BFQ Storage I/O Scheduler*** and ***MuQSS Proces 
Scheduler*** since I needed to make changes to include the keyboard driver anyway. However with the 
latest Arch Linux `5.13.13` kernel the `keyboard` works fine out of the box so I'm just using the 
default now which is easier to maintain.

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

### MicroSD Storage <a name="micro-sd-storage"/></a>
The MicroSD card is recognized as ***/dev/mmcblk1*** and not as removable device. This would be a
problem if I intended to be inserting/removing it a lot, however I intend to simply use it as
personal data storage for things such as Documents and media separate from the main disk. This will
allow the main disk to be wiped and reinstalled as often as needed while keeping all non-system
i.e. personal data separate and protected during system re-installs/formats.

Prepare SD card for use and persistently mount:

1. List out devices
   ```bash
   $ lsblk
   ```
2. Format using `-m 0` to use all space as this is a storage disk
   ```bash
   $ sudo mkfs.ext4 -m 0 /dev/mmcblk1
   ```

3. Mount using `noatime` to improve performance
   ```bash
   sudo mkdir /mnt/storage
   sudo tee -a /etc/fstab <<< "/dev/mmcblk1 /mnt/storage ext4 defaults,noatime 0 0"
   sudo mount -a
   sudo chown -R $USER: /mnt/storage
   ```

## Power Management <a name="power-management"/></a>

### Battery Status <a name="battery-status"/></a>
To keep the OS as light as possible I decided to use 
[conky](https://github.com/phR0ze/cyberlinux/blob/master/profiles/openbox/desktop/etc/skel/conky/netbook) to 
provide ***Date***, ***Time***, ***Calendar***, and ***Battery status*** as well as a few other 
monitoring widgets.

### Display Brightness <a name="display-brightness"/></a>
1. Launch power manager from the menu `Settings >Power Manager`
2. Under the `General` tab  
   a. Set `Handle display brightness keys` on  
   b. Set `Status notification` on  
   c. Set `System tray icon` on  

### Suspend <a name="suspend"/></a>
Suspend works out of the box with ***systemd*** as the default system manager

### Sound <a name="sound"/></a>
Requires the `alsa-firmware` and `sof-firmware` packages to work. After reboot you should be good.

### Touchpad <a name="touchpad"/></a>
Touchpad appears to work fine with the latest Arch Linux `5.13.13` kernel. However it used to have 
issues and would crash when used with `Chromium` or `Libre Office`. I'm hoping those issues are fixed 
with the latest kernel as well.

Restart the touchpad driver if it drops out:
```bash
sudo modprobe -r atmel_mxt_ts
sudo modprobe atmel_mxt_ts
```

### USB Storage <a name="usb-storage"/></a>
USB thumbdrives seem to work great, providing simple mount and eject options in Thunar and the
process can be repeated as many times as desired.

### Video <a name="video"/></a>
Video worked out of the box with the ***xf86-video-intel*** driver included with Arch Linux.

### WiFi <a name="wifi"/></a>
WiFi worked out of the box with the latest packages

1. Launch WPA GUI from the menu `Network >WPA Gui`
2. Select `Scan >Scan` then doblue click the chosen `SSID`
3. Enter the pre-shared secret `PSK` and click `Add`
4. You should have an ip now you can verify with `ip a` in a shell

<!-- 
vim: ts=2:sw=2:sts=2
-->
