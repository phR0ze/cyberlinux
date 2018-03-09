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
* https://www.x.org/wiki/XKB/
* https://jlk.fjfi.cvut.cz/arch/manpages/man/localectl.1
* https://wiki.galliumos.org/Media_keys_and_default_keybindings
* https://github.com/GalliumOS/xkeyboard-config/blob/master/debian/patches/chromebook.patch
* http://www.fascinatingcaptain.com/blog/remap-keyboard-keys-for-ubuntu/

***xmodmap*** is a pretty good solution for one or two key remappings, but for a larger scale
solution the correct method is to use ***X Keyboard Extension (XKB)*** and create a new layout.
During the creation of a layout you can use `xev` to determine key codes and symbol names.
The ***xkeyboard-config*** package provides the description files for the XKB system, settable with
***setxkbmap***. Use a custom layout file name to avoid obliteration on ***xkeyboard-config***
updates e.g. ***/usr/share/X11/xkb/symbols/chromebook***.

.xkb file
https://unix.stackexchange.com/questions/144374/declare-a-new-modifier-key-with-xkb
```bash
xkb_keymap {
    xkb_keycodes {
        minimum = 8;
        maximum = 255;
        // ---
        // Scancode Key_Normal Key_Shift Key_Hyper
        // ---
        <K_09> = 9;         // BackSpace
        <K_31> = 49;        // Tab
        <K_17> = 23;        // Return
        <K_6C> = 108;       // Delete
        <K_87> = 135;       // Insert
        <K_33> = 51;        // Print Sys_Req Break
        // ---
        <K_42> = 66;        // Shift_L
        <K_32> = 50;        // Control_L
        <K_69> = 105;       // Control_R
        <K_25> = 37;        // Super_L
        <K_85> = 133;       // Hyper_L
        <K_40> = 64;        // Alt_L
        // ---
        <K_6F> = 111;       // Up
        <K_71> = 113;       // Left
        <K_72> = 114;       // Right
        <K_74> = 116;       // Down
        // ---
        <K_18> = 24;        // a A Home
        <K_36> = 54;        // b B XF86AudioRaiseVolume
        <K_35> = 53;        // c C XF86AudioLowerVolume
        <K_1A> = 26;        // d D End
        <K_0B> = 11;        // e E 6
        <K_27> = 39;        // f F Down
        <K_19> = 25;        // g G Up
        <K_28> = 40;        // h H Right
        <K_0D> = 13;        // i I 8
        <K_1B> = 27;        // j J Left
        <K_1C> = 28;        // k K Up
        <K_29> = 41;        // l L Prior
        <K_37> = 55;        // m M XF86MonBrightnessDown
        <K_39> = 57;        // n N XF86AudioNext
        <K_0C> = 12;        // o O 7
        <K_0E> = 14;        // p P 9
        <K_43> = 67;        // q Q 0
        <K_44> = 68;        // r R 1
        <K_26> = 38;        // s S Left
        <K_45> = 69;        // t T 2
        <K_46> = 70;        // u U 3
        <K_38> = 56;        // v V XF86MonBrightnessUp
        <K_0A> = 10;        // w W 5
        <K_2A> = 42;        // x X Down
        <K_47> = 71;        // y Y 4
        <K_34> = 52;        // z Z XF86AudioMute
        // ---
        <K_41> = 65;        // space space Escape
        // ---
        <K_3A> = 58;        // equal plus
        <K_1D> = 29;        // period colon Right
        <K_1E> = 30;        // apostrophe quotedbl grave
        <K_1F> = 31;        // at dollar
        <K_2B> = 43;        // comma semicolon Next
        <K_2C> = 44;        // minus underscore asciitilde
        <K_2D> = 45;        // bar ampersand
        <K_3B> = 59;        // Multi_key
        // ---
        <K_48> = 72;        // parenleft braceleft 5
        <K_49> = 73;        // parenright braceright
        <K_0F> = 15;        // bracketleft less 0
        <K_10> = 16;        // bracketright greater
        // ---
        <K_4A> = 74;        // asterisk slash
        <K_4B> = 75;        // percent backslash
        <K_11> = 17;        // exclam asciicircum
        // ---
        <K_4C> = 76;        // F1
        <K_12> = 18;        // F2
        <K_5F> = 95;        // F3
        <K_13> = 19;        // F4
        <K_60> = 96;        // F5
        <K_6B> = 107;       // F6
        <K_14> = 20;        // F7
        <K_7F> = 127;       // F8
        <K_15> = 21;        // F9
        <K_76> = 118;       // F10
        <K_16> = 22;        // F11
        <K_77> = 119;       // F12
        <K_20> = 32;        // F15
        <K_21> = 33;        // F16
        <K_22> = 34;        // F17
        <K_23> = 35;        // F18
        <K_2E> = 46;        // F19
        <K_2F> = 47;        // F20
        <K_30> = 48;        // F21
        <K_24> = 36;        // F22
        <K_3C> = 60;        // F23
        <K_3D> = 61;        // F24
        <K_3E> = 62;        // F25
    };
    
    xkb_symbols {
        key <K_09> { type = "ONE_LEVEL", [ BackSpace ] };
        key <K_31> { type = "ONE_LEVEL", [ Tab ] };
        key <K_17> { type = "ONE_LEVEL", [ Return ] };
        key <K_6C> { type = "ONE_LEVEL", [ Delete ] };
        key <K_87> { type = "ONE_LEVEL", [ Insert ] };
        key <K_33> { type = "HYPER_LEVEL", [ Print, Sys_Req, Break ] };
        key <K_42> { type = "ONE_LEVEL", [ Shift_L ] };
        key <K_32> { type = "ONE_LEVEL", [ Control_L ] };
        key <K_69> { type = "ONE_LEVEL", [ Control_R ] };
        key <K_25> { type = "ONE_LEVEL", [ Super_L ] };
        key <K_85> { type = "ONE_LEVEL", [ Hyper_L ] };
        key <K_40> { type = "ONE_LEVEL", [ Alt_L ] };
        key <K_6F> { type = "ONE_LEVEL", [ Up ] };
        key <K_71> { type = "ONE_LEVEL", [ Left ] };
        key <K_72> { type = "ONE_LEVEL", [ Right ] };
        key <K_74> { type = "ONE_LEVEL", [ Down ] };
        key <K_18> { type = "HYPER_LEVEL", [ a, A, Home ] };
        key <K_36> { type = "HYPER_LEVEL", [ b, B, XF86AudioRaiseVolume ] };
        key <K_35> { type = "HYPER_LEVEL", [ c, C, XF86AudioLowerVolume ] };
        key <K_1A> { type = "HYPER_LEVEL", [ d, D, End ] };
        key <K_0B> { type = "HYPER_LEVEL", [ e, E, 6 ] };
        key <K_27> { type = "HYPER_LEVEL", [ f, F, Down ] };
        key <K_19> { type = "HYPER_LEVEL", [ g, G, Up ] };
        key <K_28> { type = "HYPER_LEVEL", [ h, H, Right ] };
        key <K_0D> { type = "HYPER_LEVEL", [ i, I, 8 ] };
        key <K_1B> { type = "HYPER_LEVEL", [ j, J, Left ] };
        key <K_1C> { type = "HYPER_LEVEL", [ k, K, Up ] };
        key <K_29> { type = "HYPER_LEVEL", [ l, L, Prior ] };
        key <K_37> { type = "HYPER_LEVEL", [ m, M, XF86MonBrightnessDown ] };
        key <K_39> { type = "HYPER_LEVEL", [ n, N, XF86AudioNext ] };
        key <K_0C> { type = "HYPER_LEVEL", [ o, O, 7 ] };
        key <K_0E> { type = "HYPER_LEVEL", [ p, P, 9 ] };
        key <K_43> { type = "HYPER_LEVEL", [ q, Q, 0 ] };
        key <K_44> { type = "HYPER_LEVEL", [ r, R, 1 ] };
        key <K_26> { type = "HYPER_LEVEL", [ s, S, Left ] };
        key <K_45> { type = "HYPER_LEVEL", [ t, T, 2 ] };
        key <K_46> { type = "HYPER_LEVEL", [ u, U, 3 ] };
        key <K_38> { type = "HYPER_LEVEL", [ v, V, XF86MonBrightnessUp ] };
        key <K_0A> { type = "HYPER_LEVEL", [ w, W, 5 ] };
        key <K_2A> { type = "HYPER_LEVEL", [ x, X, Down ] };
        key <K_47> { type = "HYPER_LEVEL", [ y, Y, 4 ] };
        key <K_34> { type = "HYPER_LEVEL", [ z, Z, XF86AudioMute ] };
        key <K_41> { type = "HYPER_LEVEL", [ space, space, Escape ] };
        key <K_3A> { type = "TWO_LEVEL", [ equal, plus ] };
        key <K_1D> { type = "HYPER_LEVEL", [ period, colon, Right ] };
        key <K_1E> { type = "HYPER_LEVEL", [ apostrophe, quotedbl, grave ] };
        key <K_1F> { type = "TWO_LEVEL", [ at, dollar ] };
        key <K_2B> { type = "HYPER_LEVEL", [ comma, semicolon, Next ] };
        key <K_2C> { type = "HYPER_LEVEL", [ minus, underscore, asciitilde ] };
        key <K_2D> { type = "TWO_LEVEL", [ bar, ampersand ] };
        key <K_3B> { type = "ONE_LEVEL", [ Multi_key ] };
        key <K_48> { type = "HYPER_LEVEL", [ parenleft, braceleft, 5 ] };
        key <K_49> { type = "TWO_LEVEL", [ parenright, braceright ] };
        key <K_0F> { type = "HYPER_LEVEL", [ bracketleft, less, 0 ] };
        key <K_10> { type = "TWO_LEVEL", [ bracketright, greater ] };
        key <K_4A> { type = "TWO_LEVEL", [ asterisk, slash ] };
        key <K_4B> { type = "TWO_LEVEL", [ percent, backslash ] };
        key <K_11> { type = "TWO_LEVEL", [ exclam, asciicircum ] };
        key <K_4C> { type = "ONE_LEVEL", [ F1 ] };
        key <K_12> { type = "ONE_LEVEL", [ F2 ] };
        key <K_5F> { type = "ONE_LEVEL", [ F3 ] };
        key <K_13> { type = "ONE_LEVEL", [ F4 ] };
        key <K_60> { type = "ONE_LEVEL", [ F5 ] };
        key <K_6B> { type = "ONE_LEVEL", [ F6 ] };
        key <K_14> { type = "ONE_LEVEL", [ F7 ] };
        key <K_7F> { type = "ONE_LEVEL", [ F8 ] };
        key <K_15> { type = "ONE_LEVEL", [ F9 ] };
        key <K_76> { type = "ONE_LEVEL", [ F10 ] };
        key <K_16> { type = "ONE_LEVEL", [ F11 ] };
        key <K_77> { type = "ONE_LEVEL", [ F12 ] };
        key <K_20> { type = "ONE_LEVEL", [ F15 ] };
        key <K_21> { type = "ONE_LEVEL", [ F16 ] };
        key <K_22> { type = "ONE_LEVEL", [ F17 ] };
        key <K_23> { type = "ONE_LEVEL", [ F18 ] };
        key <K_2E> { type = "ONE_LEVEL", [ F19 ] };
        key <K_2F> { type = "ONE_LEVEL", [ F20 ] };
        key <K_30> { type = "ONE_LEVEL", [ F21 ] };
        key <K_24> { type = "ONE_LEVEL", [ F22 ] };
        key <K_3C> { type = "ONE_LEVEL", [ F23 ] };
        key <K_3D> { type = "ONE_LEVEL", [ F24 ] };
        key <K_3E> { type = "ONE_LEVEL", [ F25 ] };
        modifier_map Shift { Shift_L };
        modifier_map Control { Control_L, Control_R };
    };
    
    xkb_compatibility {
        interpret Alt_L { action = SetMods(modifiers=Mod1); };
        interpret Shift_L { action = SetMods(modifiers=Shift); };
        interpret Super_L { action = SetMods(modifiers=Super); };
        interpret Hyper_L { action = SetMods(modifiers=Hyper); };
    };
    
    xkb_types {
        
        type "ONE_LEVEL" {
            modifiers= none;
        };
        
        type "TWO_LEVEL" {
            modifiers= Shift;
            map[Shift]= Level2;
        };
        
        type "HYPER_LEVEL" {
            modifiers= Shift+Hyper;
            map[Shift]= Level2;
            map[Hyper]= Level3;
            map[Shift+Hyper]= Level3;
        };
    };
    
};
```


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
