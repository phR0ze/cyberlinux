distro comparison
====================================================================================================
<img align="left" width="48" height="48" src="../art/logo_256x256.png">
Reviewing the various Linux distros that have caught my eye and the components they are composed
from.
<br><br>

All of the Distros below are being reviewed in a VirtualBox VM with 4GB of RAM and (2)
`Intel E5-2637 Cores`. Obviously this will be highly subjective and serves more as a reference for
myself.

### Quick Links
* [.. up dir](README.md)
* [Arch Linux Distros](#arch-linux-distros)
  * [Arco Linux - Openbox](#arco-linux-openbox)
  * [Hefftor Linux](#hefftor-linux)
* [Desktop Components](#desktop-components)
  * [Window managers](#window-managers)
    * [XFWM vs Openbox](#xfwm-vs-openbox)
  * [Logout screens](#logout-screens)
    * [arcolinux-logout](#arcolinux-logout)
    * [oblogout](#oblogout)
  * [Lock screens](#lock-screens)
    * [Betterlockscreen](#betterlockscreen)
    * [i3lock-color](#i3lock-color)
    * [i3lock](#i3lock)
* [Desktop Environments](#desktop-evironments)
  * [Performance](#performance)
    * [XFCE vs LXDE](#xfce-vs-lxde)
    * [XFCE vs KDE Plasma](#xfce-vs-kde-plasma)
  * [Budgie Desktop](#budgie-desktop)
  * [Cinnamon Desktop](#cinnamon-desktop)
  * [Deepin Desktop](#deepin-desktop)
  * [KDE Plasma Desktop](#plasma-desktop)
  * [Lumina Desktop](#lumina-desktop)
  * [LXDE Desktop](#lxde-desktop)
  * [LXQt Desktop](#lxqt-desktop)
    * [LXQt splash](#lxqt-splash)
  * [MATE Desktop](#mate-desktop)
  * [XFCE Desktop](#xfce-desktop)

# Arch Linux Distros <a name="arch-linux-distros"/></a>

## Arco Linux - Openbox <a name="arco-linux-openbox"/></a>
**Review**
* The ArcoLinuxB version as is a live environment you can install from
* Booting from it gives a minimal Arch Linux type menu then it boots to live and launches Calamares
* Terminal - URXT with splash of scrot
* Arco specific software
  * arcolinux-logout
    * integrated with BetterLockScreen UI 
    * /usr/local/bin/arcolinux-logout
    * python3 /usr/share/arcologout/arcologout.py
  * ArcoLinux BetterLockScreen GUI
    * Brad Heffernan
    * /usr/local/bin/arcolinux-betterlockscreen
    * /usr/share/arcolinux-betterlockscreen/arcolinux-betterlockscreen.py
  * ArcoLInux Conky manager
    * conkyzen
  * Arco Tweak Tool
    * Desktop Installer
* App Finder - xfc4-appfinder
* xfce4-power-manager
* xfce-clipman
* exo-open --launch TerminalEmulator
  * will launch the preferred terminal
* Sound controls
  * volumeicon
  * pavucontrol
* Install software
  * pamac is a UI for pacman
* Change resolution
  * lxrandr
  * xfce4-display-settings
* xcape
* tint2
* xfc4-taskmanager
* xfce4-appearance
* lxappearance
* Variety
* Terminals
  * lxterminal
  * xfce4-terminal
  * termite
  * Urxvt
  * Alacritty
* Ristretto image viewer from XFC4
* USB image writer - mintstick
* Theme
  * GTK2/3: Arc-Dark
  * Icons: Sardi-Arc 
* Kavantum theme engine for KDE
* Archive Manager - file roller
* xfce4-terminal --drop-down
  * Strange behavior it disappears when you click out only
* NetworkManager
* sddm
* thunar
* screenshot
  * nicer looking than xfc4-screenshooter
  * identical features except xfc4-screenshooter can open in target app
* Openbox
  * Same issue resizing borders, super hard to catch on
* picom - standalone compositor fork of compton
* Has a delayed bootloader page
* Display manager login is set to tiny resolution by default

## Hefftor Linux <a name="hefftor-linux"/></a>
[Hefftor Linux](https://hefftorlinux.net/) popped up on my radar when I was searching for a better
lock screen. Apparently Brad Hefferman made his own GUI tool for the `Betterlockscreen` scripts which
got me curious about what hes was working on. His screen shots look really neat.

**Review**
* On first boot your presented with a similar looking menu to the original Arch Linux ISO.
* It boots into a full featured Live environment and runs the Calamares installer
  * The Calamares installer is clean and slick looking
* There is a nice compositing translucent affect that windows get when you move them
* The default theme and look and feel are subdued and pleasant
* Conky date and time in a neat font on desktop
* Terminal - URXVT with no scrollbar and higher than usual tranparencey
* xfce4-panel top right for tray icons
* App launcher - Plank at bottom
* XFW4 Window Manager 
* pavucontrol - launched from 
* risretto image viewer
* catfish file search
* grsync ui for rsync
* yad icon browser
* Fonts via XFC Appearance
  * Roboto Regular 10 for both Default and Monospace font
  * Enabled anti-aliasing
  * Hinting: Slight
  * Sub pixel order: RGB
  * Custom DPI: 96
  * Terminal font `Hack`

# Desktop Components <a name="desktop-components"/></a>

## Window managers <a name="window-managers"/></a>

### XFWM vs Openbox <a name="xfwm-vs-openbox"/></a>
* Both wrote in C
* Openbox is standalone
* XFWM is part of a DE
* XFWM has a compositor built in for true transparency

## Logout screens <a name="logout-screens"/></a>
Most linux desktop environments have their own integrated logout functionality which is much the same
providing a small window with a list of buttons with small text on them for the various logout
functions. Some may offer configurability as to the commands but many do not.

I much prefer large icons and large text in a splash overlay that completely covers the screen. To
date I've only found a few but `oblogout` seems to have been the first.

### arcolinux-logout<a name="arcolinux-logout"/></a>
[ArcoLinux-logout](https://aur.archlinux.org/packages/arcolinux-logout/) appears to be a clone of
`oblogout` and provides much the same options.

### oblogout <a name="oblogout"/></a>
[Oblogout](https://aur.archlinux.org/packages/oblogout/) has been my go to in this area providing:
* Simple set of widgets overlayed in all white with icons for common controls
  * Logout, Shutdown, Reboot, Hibernate etc...
  * Each action could be clicked to activate or use a hot key
* The actual commands executed were configurable

It has since been moved out of main line into the AUR as its not being actively maintained and is
using python2 dependencies `python2-pillow` and `python2-dbus`

## Lock screens <a name="lock-screens"/></a>
After reviewing a few lock screen applications I've realized that the features I'd really want
ideally in a lock screen app are:

* Configureable thumbnail image gallery
* Choose image frrom from thumbnail image gallery
* Choose affects to apply to wallpaper and/or lockscreen
* Apply image to both wallpaper and lockscreen saving affected images in cache
* Allow for customized greeter overlay
* Ability to randomly choose wallpaper/lockscreen combination

This is really a combination of the traditional lockscreen and wallpaper applications

### Betterlockscreen <a name="betterlockscreen"/></a>
[Betterlockscreen](https://github.com/betterlockscreen/betterlockscreen) wraps `i3lock-color` using a
caching mechanism to apply all affects to a chosen image then cache it and have `i3lock-color`
display it so there isn't any delay while applying affects dynamically.

Betterlockscreen uses `imagemagick`, `xdpyinfo`, `xrandr`, `xrdb` and `xset` in order to
automatically detrmine the correct size and resolution an image should be then to apply affects to
the images and cache them to be then set as an i3lock-color background and optionally keep the
wallpaper in sync.

After research I found [ArcoLinux's project work](https://github.com/arcolinux/arcolinux-betterlockscreen)
on this to provide a GUI to make this easier.

### i3lock-fancy <a name="i3lock-fancy"/></a>
[i3lock-fancy](https://github.com/meskarune/i3lock-fancy#static-image) is a wrapper script around the
venderable `i3lock-color` project. The script dynamically takes a screen shot and applies affects
than calls i3lock-color.

Adding a lock icon and text to the center of an image can be done statically with:
```bash
$ convert /path/to/background.png -font Audiowide -pointsize 50 -fill white -gravity center \
    -annotate +0+160 "Password required to unlock" lock.png -gravity center -composite newimage.png
$ i3lock -i newimage.png
```

### i3lock-color <a name="i3lock-color"/></a>
[i3lock-color](https://github.com/Raymo111/i3lock-color) is the most popular i3lock fork providing a
number of enhancments:

* Multiple configurable colors for the unlock ring
* Blurring the current screen and using that for a background
* Showing a clock in the indicator
* Positioning the various UI elements
* Changing the ring radius and thickness as well as text size

### i3lock <a name="i3lock"/></a>
[i3lock](https://github.com/i3/i3lock) is a simple screen locker that is independent of any desktop
environment and can be used standalone. Its a great idea but many have found it too spartan and has
spawned a number of forks with various feature enhancements.

Features:
* able to display image in background
* uses PAM and therefor has all PAM integrations
* shows simple circle that offers a little animation when password is entered

### Cinnamon-screensaver <a name="cinnamon-screensaver"/></a>
Cinnamon-screensaver was my favorite for some time providing a simple image with a bluring layer and
the current time and date and would offer password entry when activated. However due to its numerous
cinnamon desktop dependencies I've abandoned it.

## Window Manager <a name="window-manager"/></a>
***Window Managers*** used by Desktop Environments usually provide:
* Window placment on the screen
* Window decorations
* Workspace or virtual desktops

## Desktop Manager <a name="desktop-manager"/></a>
***Desktop Managers*** used by Desktop Enviroments usually provide:
* Desktop Wallpaper
* Desktop root window menu
* Desktop application and file manager icons

## Panel <a name="panel"/></a>
***Panels*** used by Desktop Environments usually provide:
* Switching between open windows
* Launch applications
* Switch workspaces
* Menu plugins to browse applications or directories

## Session Manager <a name="session-manager"/></a>
***Session Managers*** used by Desktop Environments usually provide:
* Controls for login
* Power managment
* Multiple login sessions

## Application Finder <a name="application-finder"/></a>
***Application Finders*** used by Desktop Environments usually provide:
* View of the applications installed in categories

## File Manager <a name="file-manager"/></a>
***File Managers*** usec by Desktop Environments usually provide:
* File management
* Unique utilities like bulk renamer

## Settings Manager <a name="settings-manager"/></a>
***Settings Managers*** used by Desktop Environments usually provide:
* Tools to control various settings
* Keyboard shortcuts
* Appearance
* Display settings

* Appearance
  * Themes
* Desktop features
* Desktop settings
  * Desktop notifications

* Screenshooter
* PDF Viewer
* Multi-monitor management

## Desktop features <a name="desktop-features"/></a>
One of the core paradigms in the Desktop Environment is the visible desktop surface and your
interactions with it. Sometimes these features are abscent from a particular desktop environment,
handled by a standalone appliation or simply a feature of a larger application.

* Desktop wallpaper
* Desktop application launcher icons
* Desktop file management folder icons

## Desktop settings <a name="desktop-settings"/></a>
Another typical desktop environment feature is 


# Desktop Environments <a name="desktop-environments"/></a>
To compare the different ***Desktop Environments*** I'll first attempt to break down their features
into common groups I can compare and contrast.

|             | Display Mngr | Window Mngr | Desktop Mngr | Panel | Session Mngr | App Finder | File Mngr | Settings |
| ----------- | ------------ | ----------- | ------------ | ----- | ------------ | ---------- | --------- | -------- |
| Budgie      |              |             |              |       |              |            |           |          |
| Cinnamon    |              |             |              |       |              |            |           |          |
| Deepin      |              |             |              |       |              |            |           |          |
| GNOME       |              |             |              |       |              |            |           |          |
| KDE Plasma  |              |             |              |       |              |            |           |          |
| LXDE        |              |             |              |       |              |            |           |          |
| LXQt        |              |             |              |       |              |            |           |          |
| MATE        |              |             |              |       |              |            |           |          |
| XFCE        |              |             |              |       |              |            |           |          |

## Performance <a name="performance"/></a>
Performance comes down to the amount of resources consumed by the desktop environment that is then
not available for actual user applications. 

### XFCE vs LXDE <a name="xfce-vs-lxde"/></a>

### XFCE vs KDE Plasma <a name="xfce-vs-kde-plasma"/></a>
According to [Jason Evangelho](https://www.forbes.com/sites/jasonevangelho/2019/10/23/bold-prediction-kde-will-steal-the-lightweight-linux-desktop-crown-in-2020/#5562672f26d2) the latest version of `KDE Plasma 5.17` are
approaching a similar usage as XFCE, which has long been heralded for its low resource usage, with
`KDE Plasma 5.17` using `~503MB` and `XFCE` using `525MB`. Another test using a more feature rich
build puts `XFCE => 949MB` and `KDE => 957MB`

# Budgie Desktop <a name="budgie-desktop"/></a>
The [Budgie Desktop]() is developed independently for Solus Linux. I'll be evaluating is via the
[Ubuntu Budgie](https://ubuntubudgie.org/) distro.

# Cinnamon Desktop <a name="cinnamon-desktop"/></a>
The [Cinnamon Desktop](https://en.wikipedia.org/wiki/Cinnamon_(desktop_environment) is a fork of
`GNOME 2`. I'm evaluating it via the [Linux Mint](https://linuxmint.com/) distro.

# Deepin Desktop <a name="deepin-desktop"/></a>

# KDE Plasma Desktop <a name="kde-plasma-desktop"/></a>
Evaluating via [Kubuntu](https://kubuntu.org/) distro.


# Lumina Desktop <a name="lumina-desktop"/></a>

# LXDE Desktop <a name="lxde-desktop"/></a>
LXQt is the continuation of LXDE

# LXQt Desktop <a name="lxqt-desktop"/></a>
[LXQt](https://github.com/lxqt/lxqt/wiki) is a lightweight Qt desktop environment that still aims to
have a modern look and feel. I'm evaluating it via the [Lubuntu](https://lubuntu.me/) distro.

Resources:
* [LXQt - Arch Wiki](https://wiki.archlinux.org/title/LXQt)

## LXQt splash <a name="lxqt-splash"/></a>
<img src="../docs/images/lxqt/splash.jpg">

## LXQt display manager <a name="lxqt-display-manager"/></a>
<img src="../docs/images/lxqt/display-manager.jpg">

## LXQt power management <a name="lxqt-power-management"/></a>
<img src="../docs/images/lxqt/power-management.jpg">

## LXQt lock screen <a name="lxqt-lock-screen"/></a>
The lock screen turned into a screen saver once it set for awhile
<img src="../docs/images/lxqt/lock-screen.jpg">
<img src="../docs/images/lxqt/lock-screen2.jpg">

## LXQt accessories <a name="lxqt-accessories"/></a>
**FeatherPad - simple notepad clone**
<img src="../docs/images/lxqt/accessories-featherpad.jpg">

**KCalc - simple calculator**
<img src="../docs/images/lxqt/accessories-kcalc.jpg">

**LXQt Archiver - derived from File Roller of Gnome**
<img src="../docs/images/lxqt/accessories-lxqt-file-archiver.jpg">

**QtPass - basic UI frontend to pass unix password manager**
<img src="../docs/images/lxqt/accessories-qtpass.jpg">

  * PCManFM-Qt File Manager
  * TeXInfo
  * Vim
  * compton
  * nobleNote
  * picom

**LXQt Image Viewer - simple imager viewer slightly more advanced than gpicview**
<img src="../docs/images/lxqt/graphics-image-viewer.jpg">

* Graphics
  * LXImage
  * LibreOffice Draw
  * ScreenGrab
  * Skanlite
* Internet
  * BlueDevil Send File
  * BlueDevil Wizard
  * Firefox
  * Quassel IRC
  * Transmission (Qt)
  * Trojita
* Office
  * LibreOffice
  * LibreOffice Calc
  * LibreOffice Draw
  * LibreOffice Impress
  * LibreOffice Match
  * LibreOffice Writer
  * Trojita
  * qpdfview
* Sound & Video
  * K3b
  * PulseAudio Volume Control
  * VLC
* System Tools
  * BlueDevil Send File
  * BlueDevil Wizard
  * Discover
  * Fcitx
  * Htop
  * KDE Partition Manager 
  * Muon Package Manager 
  * QTerminal
  * QTerminal drop down
  * Startup Disk Creator
  * qps
* Preferences
  * LXQt settings
  * Additional Drivers
  * Advanced Network Configuration
  * Alternatives Configurator
  * Apply Full Upgrade
  * Fcitx Configuration
  * Input Method
  * Printers
  * Screensaver
* About LXQt
* Leave
  * Hibernate
  * Leave
  * Logout
  * Reboot
  * Shutdown
  * Suspend
* Lock Screen

## PCManFM-Qt <a name="pcmanfm-qt"/></a>

* File Manager
* Desktop wallpaper
* Desktop folder browsing icons
* Desktop Application Launcher Icons
* Right click for desktop preferences and 

## Power Control <a name="power-control"/></a>

## Volume Control <a name="volume-control"/></a>

## Removable Media <a name="removable-media"/></a>

# MATE Desktop <a name="mate-desktop"/></a>
The [MATE Desktop](https://mate-desktop.com/) is a fork of `GNOME 2`. I'm evaluating it via the
[Ubuntu MATE](https://ubuntu-mate.org/) distro.

# XFCE Desktop <a name="xfce-desktop"/></a>
[XFCE](https://www.xfce.org/about) is a lightweight GTK desktop environment. I'm evaluating it via
the [XUbuntu](https://xubuntu.org/download) distro.

* GTK+ toolkit

<!-- 
vim: ts=2:sw=2:sts=2
-->
