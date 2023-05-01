cyberlinux help
====================================================================================================

<img align="left" width="48" height="48" src="../art/logo_256x256.png">
Documenting general Arch Linux help here as well as <b><i>cyberlinux</i></b> specific instructions. 
Since <b><i>cyberlinux</i></b> is just a preconfigured version of Arch Linux general Arch Linux help 
on the [Arch Linux Wiki](https://wiki.archlinux.org/) should work just fine as well.
<br>

### Quick links
* [.. up dir](https://github.com/phR0ze/cyberlinux)
* [CHANGELOG](CHANGELOG.md)
* [Deployments](deployments)
* [Development](development)

* [Apps to use](#apps-to-use)
* [Bash](#bash)
  * [heredoc](#heredoc)
    * [Save heredoc into a variable](#save-heredoc-into-a-variable)
* [Certificates](#certificates)
  * [Add Root CA](#add-root-ca)
* [Configuration](#configuration)
  * [dconf](#dconf)
    * [Dump dconf settings to file](#dump-dconf-settings-to-file)
    * [Load dconf settings from file](#load-dconf-settings-from-file)
* [Develop](#develop)
  * [Git](#git)
  * [Rewrite Git History](#rewrite-git-history)
  * [Github Personal Access Tokens](#github-personal-access-tokens)
* [Devices](#devices)
  * [Android](#android)
  * [Display](#display)
    * [Adapt Output Toggle](#adapt-output-toggle)
    * [Dual Output](#dual-output)
    * [VGA Output](#vga-output)
    * [GTX 650 Ti](#gtx-650-ti)
    * [Quadro K600](#quadro-k600)
    * [Quadro FX 880M](#quadro-fx-880m)
    * [Quadro FX 3800](#quadro-fx-3800)
    * [Nvidia Proprietary](#nvidia-proprietary)
    * [Overscan/Underscan](#overscan-underscan)
  * [Mouse](#mouse)
    * [Configure Mouse Speed](#configure-mouse-speed)
  * [Keyboard](#keyboard)
    * [Configure Keyboard Rate](#configure-keyboard-rate)
    * [Disable Numlock on Boot](#disable-numlock-on-boot)
  * [Printer](#printer)
    * [Workforce WF-7710](#printer-workforce-wf-7710)
    * [Pending - Out of Paper](#pending-out-of-paper)
  * [Scanner](#scanner)
    * [Workforce WF-7710](#scanner-workforce-wf-7710)
  * [Sound](#sound)
    * [Simultaneous output to multiple devices](#simultaneous-output-to-multiple-devices)
    * [Google Meet Headset](#google-meet-headset)
* [Display Manager](#display-manager)
  * [LXDM](#lxdm)
    * [Set lxdm background](#set-lxdm-background)
  * [SSDM](#ssdm)
* [Containers](#containers)
  * [Podman](#podman)
    * [Migrate from Docker](#migrate-from-docker)
  * [Docker ipv6 issue](#docker-ipv6-issue)
  * [Build container](#build-container)
    * [Build from filesystem](#build-from-filesystem)
  * [Run container](#run-container)
    * [Shell into a running container](#shell-into-a-running-container)
    * [Check if container exists](#check-if-container-exists)
  * [Upload container](#upload-container)
  * [Build cyberliux container](#build-cyberlinux-container)
* [Games](#games)
  * [HedgeWars](#hedgewars)
    * [Install HedgeWars](#install-hedgewars)
    * [libGL nvidia-340xx fix](#libgl-nvidia-340xx-fix)
  * [Steam](#steam)
* [Bootloader](#bootloader)
  * [Grub](#grub)
  * [Boot Kernel](#boot-kernel)
  * [Boot Resolution](#boot-resolution)
  * [Add Kernel params](#add-kernel-params)
* [Fonts](#fonts)
  * [Install Fonts](#install-fonts)
  * [Find Font Name](#find-font-name)
  * [Distro Fonts](#distro-fonts)
  * [Fontconfig](#fongconfig)
* [Kernel](#kernel)
  * [Switch Kernel](#switch-kernel)
* [Launchers](#launchers)
  * [Plank](#plank)
* [Mount](#mount)
  * [Mount Busy](#mount-busy)
    * [fuser](#fuser)
  * [Add Automount using FSTAB](#add-automount-using-fstab)
* [Multimedia](multimedia)
* [Networking](networking)
* [Office](#office)
  * [LibreOffice](#libreoffice)
    * [Config Navigation](#config-navigation)
    * [Keyboard Shortcuts](#keyboard-shortcuts)
    * [Set Default Template](#set-default-template)
    * [Turn off Smart Quotes](#turn-off-smart-quotes)
    * [Turn off Replace Dashes](#turn-off-replace-dashes)
    * [Turn off Automatic Strikeout](#turn-off-automatic-strikeout)
    * [Fix Spellcheck Issue](#fix-spellcheck-issue)
    * [Repeatable Config](#repeatable-config)
  * [OCR](#ocr)
    * [Tesseract](#tesseract)
  * [PDFs](#pdfs)
    * [PDF Manipulation](#pdf-manipulation)
    * [Combine PDFs](#combine-pdfs)
    * [Rotate PDFs](#rotate-pdfs)
    * [Convert Images to PDF](#convert-images-to-pdf)
* [pacman packages](#pacman-packages)
  * [Init Database](#init-database)
  * [Update Mirrorlist](#update-mirrorlist)
  * [Create Repo Database](#create-repo-database)
  * [Share Package Cache](#share-package-cache)
  * [Download packages only](#download-packages-only)
  * [BlackArch repo](#blackarch-repo)
    * [Configure BlackArch repo](#configure-blackarch-repo)
    * [BlackArch Signature issue](#blackarch-signature-issue)
  * [Flatpak](system/flatpak)
* [Panels](#panels)
  * [Tint2](#tint2)
  * [XFCE4 Panel](#xfce4-panel)
* [Patching](#patching)
  * [Create Patch](#create-patch)
  * [Apply Patch](#apply-patch)
* [Power Management](#power-management)
  * [XFCE4 Power Manager](#xfce4-power-manager)
    * [Battery Status](#battery-status)
    * [Display Brightness](#display-brightness)
  * [Suspend](#suspend)
* [Rescue](#rescue)
  * [Switch to TTY](#switch-to-tty)
  * [Graphical Target](#graphical-target)
    * [Switch to console](#switch-to-console)
    * [Check Xorg logs](#check-xorg-logs)
    * [Reset Xorg settings](#check-xorg-settings)
    * [Opensource Driver](#opensource-driver)
  * [Unable to Login](#unable-to-login)
    * [Try logging in while tailing the logs](#try-logging-in-while-tailing-the-logs)
    * [Try running openbox directly](#try-running-openbox-directly)
    * [Try reinstalling the target video driver](#try-reinstallig-the-target-video-driver)
  * [chroot into target disk](#chroot-into-target-disk)
    * [Unable to chroot into disk](#unable-to-chroot-into-disk)
    * [Rebuild initramfs-linux](#rebuild-initramfs-linux)
  * [Black Screen](#black-screen)
  * [Check Logs for Errors](#check-logs-for-errors)
  * [Update Old System](#update-old-system)
  * [ldconfig is empty, not checked](#ldconfig-is-empty-not-checked)
* [Session Manager](#session-manager)
  * [lxsession](#lxsession)
  * [xfce4-session](#xfce4-session)
* [Storage](#storage)
  * [Add Drive](#add-drive)
  * [Clone Drive](#clone-drive)
  * [Backup Drive](#backup-drive)
  * [Securely Wipe Drive](#securely-wipe-drive)
  * [RAID Drives](#raid-drives)
  * [Test Drive](#test-drive)
  * [Test USB Drive](#test-usb-drive)
* [System](system)
* [Time/Date](#time-date)
  * [Set Time/Date](#set-time-date)
* [Troubleshooting](#troubleshooting)
  * [GVFS Slow Start](#gvfs-slow-start)
    * [libblockdev fix](#libblock-dev)
    * [xdg-desktop-portal](#xdg-desktop-portal)
* [Users/Groups](#users-groups)
  * [Add user](#add-user)
  * [Rename user](#rename-user)
* [VeraCrypt](#veracrypt)
* [Virtualization](virtualization)
* [Window Manager](#window-manager)
  * [Openbox](#openbox)
  * [XFWM](#xfwm)
    * [XFCE Menu](#xfce-menu)
  * [wmctrl](#wmctrl)
* [Wine](system/wine)
* [X Windows](#x-windows)
  * [Icons](#icons)
    * [Refresh Icons Cache](#refresh-icon-cache)
  * [Persist X Configs](#persist-x-configs)
    * [xprofile](#xprofile)
    * [XDG Autostart](#xdg-autostart)

# Apps to use
[List of apps to use from Arch Linux Wiki](https://wiki.archlinux.org/index.php/List_of_applications/Utilities)

# Bash
Although bash isn't the most elegant or fastest scripting language out there it has the largest reach 
and most pervasive install base and most importantly is almost never changes. For this reason it is 
an excellent technology for small scripts that you want to just work over an extended period of time.

## heredoc

### Save heredoc into a variable
Changing `EOF` to `'EOF'` ignores variable expansion

```bash
local DOC=$(cat << 'EOF'
[cyberlinux]
SigLevel = Optional TrustAll
Server = https://cyberlinux.bitbucket.io/packages/$repo/$arch
EOF
)
```

# Certificates

## Add Root CA
```bash
# Download certs
wget --no-check-certificate -P ~/Downloads https://example.com/CAs/CA1.zip

# Unzip cert and rename to crt
unzip CA1.zip && rename CA1.cer CA1.crt

# Install new CA cert, original file can then be deleted
sudo trust anchor CA1.crt
```

# Configuration
## dconf

### Dump dconf settings to file
To get setting persisted from dconf configure first reset your configs then configure as desired and 
dump out your settings to a local file.

Dump all settings:
1. Reset all configs to factory defaults:
   ```bash
   $ dconf reset -f /
   ```
2. Configure target applications as desired then dump out the settings:
   ```bash
   $ dconf dump / > settings
   ```

Dump specific app settings:
```bash
$ dconf dump /org/gtk/settings/file-chooser/ > /etc/dconf/db/local.d/02-gtk
$ dconf dump /apps/guake/ > /etc/dconf/db/local.d/03-guake
```

### Load dconf settings from file
Use a file dumped from the previous section [Dump dconf settings to file](#dump-dconf-settings-to-file)
to restore your settings.

Manually restore all settings:
```bash
$ dconf load < settings
```

Manually restore specific app settings:
```bash
$ dconf load /org/gtk/settings/file-chooser/ < 02-gtk
```

[Set values from defaults](https://help.gnome.org/admin/system-admin-guide/stable/dconf-custom-defaults.html.en)
1. Place settings fil in `/etc/dconf/db/local.d/02-gtk` ensuring keys have full path without root 
   prefix and slash suffix like is required in manual form e.g. `/org/gtk/` vs `[org/gtk]`
   ```
   [org/gtk/settings/file-chooser]
   show-hidden=true
   sort-directories-first=true
   ```
2. Ensure the file `/etc/dconf/profiles/user` exists with the contents
   ```
   user-db:user
   system-db:local
   ```
3. Update
   ```bash
   $ sudo dconf update
   ```

# Develop

## Git
Common git config across repos

```bash
cd ~/Projects/cyberlinux
git config --global user.email <email address>
git config --global user.name phR0ze
git config --global push.default simple
git config core.hooksPath .githooks
```

## Rewrite Git History
Hammer to rewrite committer and author for all history

```bash
git filter-branch -f --env-filter \
"GIT_AUTHOR_NAME='NEW_USER'; GIT_AUTHOR_EMAIL='NEW_USER@EXAMPLE.COM'; \
GIT_COMMITTER_NAME='NEW_USER'; GIT_COMMITTER_EMAIL='NEW_USER@EXAMPLE.COM';" HEAD

git push origin -f
```

## Github Personal Access Tokens
Personal access tokens provide a secure way to access your account with the ability to lock down the
token to only particular access.

1. Navigate to `Settings/Developer settings/Personal access tokens` and click `Generate new token`
2. Set priviledges for the token
3. Use it for git clones e.g. `git clone https://example-token@github.com/phR0ze/cyberlinux`
4. If you find this taxing you can create a `~/.gitconfig` setting to simplify token use
```bash
tee -a ~/.gitconfig <<EOL
[url "https://example-token@github.com/phR0ze/"]
    insteadOf = phR0ze/
EOL
```
5. Then you can just use e.g. `git clone phR0ze/cyberlinux`

# Devices

## Android
Configure minimal android support on your cyberlinux box

```bash
# Install dependencies
$ sudo pacman -S android-tools android-udev libmtp

# Add user to adbusers group
$ sudo gpasswd -a <user> adbusers

# Logout and back in or
$ su - <user>
```

## Display

### Adapt Output Toggle
cyberlinux uses the ***/opt/cyberlinux/bin/toggle*** script to toggle external displays on and off.

You can adapt it for you system by looking up the output port you want and setting that.
```bash
# Running xrandr shows that our primary output is 'LVDS-1' and target output port is 'DP-2'
$ xrandr
LVDS-1 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 345mm x 194mm
   1920x1080     59.93*+
DP-2 connected (normal left inverted right x axis y axis)
   1920x1080     60.00 +  60.00    59.94    59.93    24.00    23.98  

# Edit the /opt/cyberlinux/bin/toggle script to control your laptop as desired
# Set primary to 'LVDS-1'
# Set output to 'DP-2'
# Set resolution to desired '1920x1080'
# Test
$ toggle display
```

### Dual Output
Many workstations will have more than one monitor. In order to have Linux configure them both
accurately you have to set some ***xrandr*** rules post login:

```bash
# Executing xrandr you'll see multiple devices:
# DVI-I-0 disconnected primary (normal left inverted right x axis y axis)
# DVI-I-1 disconnected (normal left inverted right x axis y axis)
# DP-0 disconnected (normal left inverted right x axis y axis)
# DP-1 disconnected (normal left inverted right x axis y axis)
# DP-2 connected 1920x1200+2560+0 (normal left inverted right x axis y axis) 520mm x 320mm
# DP-3 connected 2560x1600+0+0 (normal left inverted right x axis y axis) 641mm x 400mm
xrandr

# Specify order of displays (auto is a default param if nothing is given to override it)
xrandr --output DP-3 --auto --primary --output DP-2 --auto --left-of DP-3

# LXDM has a hook you can use to configure this after login /etc/lxdm/PostLogin
# LoginReady and PreLogin both seem to be too early in the process to work correctly
# Lxrandr updates the auto start desktop file with its config ~/.config/autostart/lxrandr-autostart.desktop
# Exec=sh -c 'xrandr --output DP-3 --mode 2560x1600 --rate 59.97 --output DP-2 --mode 1920x1200 --rate 59.95 --left-of DP-3'
sudo tee -a /etc/lxdm/PostLogin <<EOL
xrandr --output DP-3 --mode 2560x1600 --rate 59.97 --primary --output DP-2 --mode 1920x1200 --rate 59.95 --left-of DP-3
EOL
```

### VGA Output
Many laptops have a VGA output port that can be hooked up to a projector or other external video
device. To tell Linux you want to use that external port:

```bash
# Executing xrandr you'll see multiple devices:
# eDP-1 (internal display)
# DP-2 (docking station display)
# VGA-1 (external port for projectors)
xrandr

# Turn on VGA-1 output mirroring internal
# Note lxrandr provides a good way to change resolution as well
xrandr --output VGA-1 --mode 1280x1024 --same-as eDP-1 --output eDP-1 --mode 1280x1024
xrandr --output VGA-1 --off --output eDP-1 --auto

# Mapping this to Win + P or other hot key combo
# Launch lxrandr
# Select resolution of 1280x1024 for both monitors
```

### GTX 650 Ti
[Nvidia - Arch linux wiki](https://wiki.archlinux.org/title/NVIDIA)

1. Determine you graphics card
   ```
   $ lspci -k | grep -A 2 -E "(VGA|3D)"
   05:00.0 VGA compatible controller: NVIDIA Corporation GK106 [GeForce GTX 650 Ti] (rev a1)
     Subsystem: ZOTAC International (MCO) Ltd. Device 2294
     Kernel driver in use: nouveau
   ```
2. Determine the drver you'll need using [Nvidia's Download page](https://www.nvidia.com/Download/index.aspx)  
   a. Product Type: `GeForce`  
   b. Product Series: `GeForce 600 Series`  
   c. Product: `GeForce GTX 650 Ti`  
   d. Operating System: `Linux 64-bit`  
   e. Click the `Search` button  
   f. Note the resulting `Version` i.e. `470.161.03`
3. Update kernel params in the boot loader [add kernel params](#add-kernel-params) to add `ibt=off`
4. Step 1 gave us `GK106` and Step 2 gave use version `470` both of which line up to the `Kelper` 
   series which uses the Arch Linux `nvidia-470xx-dkms` package.
5. Install packages
   ```
   $ sudo pacman -S 
   ```

### Quadro K600
Use the `nvidia-340xx` driver in the cyberlinux repo
```bash
$ inxi -G
Graphics:  Device-1: NVIDIA GK107GL [Quadro K600]

$ sudo pacman -S nvidia-340xx

# Note for 5.11 and greater kernels set the xorg config to use nvidia
$ sudo cp /usr/share/nvidia-340xx/20-nvidia.conf /etc/X11/xorg.conf.d/10-nvidia.conf
```

### Quadro FX 880M
The driver for this card i.e. `nvidia-340xx` is no longer carried in the Arch Linux repos, but has a
maintained version in the cyberlinux repo.

```bash
# Determine graphics card
$ inxi -G
Graphics:  Card-1: NVIDIA [Quadro FX 880M]
...

# Remove the opensource driver if it is installed
$ sudo pacman -Rns xf86-video-nouveau

# Installing the DKMS driver will allow kernel updates without requiring rebuilds
$ sudo pacman -S nvidia-340xx-dkms libxnvctrl

# Note for 5.11 and greater kernels set the xorg config to use nvidia
$ sudo cp /usr/share/nvidia-340xx/20-nvidia.conf /etc/X11/xorg.conf.d/10-nvidia.conf

# Reboot
$ sudo reboot
```

### Quadro FX 3800
The driver for this card i.e. `nvidia-340xx` is no longer carried in the Arch Linux repos, but has a
maintained version in the cyberlinux repo.

**Determine graphics card:**
```bash
$ inxi -G
Graphics:  Card-1: NVIDIA GT200GL [Quadro FX 3800]
...
```

**Build nvidia-340xx drivers if necessary:**
```bash
$ yay -Ga nvidia-340xx-utils
$ cd nvidia-340xx-utils
$ makepkg -s
$ sudo pacman -U nvidia-340xx-utils-340.108-1-x86_64.pkg.tar.zst

$ yay -Ga lib32-nvidia-340xx-utils
$ cd lib32-nvidia-340xx-utils
$ makepkg -s

$ yay -Ga nvidia-340xx-settings
$ cd nvidia-340xx-settings
$ makepkg -s

$ yay -Ga nvidia-340xx
$ cd nvidia-340xx
$ makepkg -s
```

**Install the DKMS version which allows for kernel updates without driver rebuilds:**
```bash
# Remove the opensource driver if it is installed
$ sudo pacman -Rns xf86-video-nouveau

# Install the nvidia dkms driver
$ sudo pacman -S nvidia-340xx-dkms libxnvctrl

# Note for 5.11 and greater kernels set the xorg config to use nvidia
$ sudo cp /usr/share/nvidia-340xx/20-nvidia.conf /etc/X11/xorg.conf.d/10-nvidia.conf

# Reboot
$ sudo reboot
```

### Nvidia Proprietary
1. Determine Graphics Card
  ```bash
  inxi -G
  #Graphics:  Card-1: NVIDIA GK106GLM [Quadro K2100M] driver: nouveau v: kernel 
  #       Display: server: X.Org 1.20.0 driver: modesetting unloaded: vesa resolution: 1920x1080~60Hz 
  #       OpenGL: renderer: NVE6 v: 4.3 Mesa 18.1.5 
  ```
2. Determine driver version  
  a. Navigate to https://nouveau.freedesktop.org/wiki/CodeNames/  
  b. Search for ***Quadro K2100M*** finding ***NVE6*** as the code 
  c. Navigate to https://wiki.archlinux.org/index.php/NVIDIA#Installation  
  d. Find the driver package related to ***NVE6***  
  e. Install driver: ***sudo pacman -S nvidia***  
  f. Reboot  

### Overscan/Underscan
I'm using the term `Underscan` to mean reducing the display image and `Overscan` to increase the
display image as relates to the defaults.  `Offset` in this context means what location related to
the origin top left i.e. +0+0 to draw the display.

**Adjust with nvidia-settings**:
1. Launch `nvidia-settings` which is part of the `nvidia-utils` package.
2. Click `X Server Display Configuration` on the left
3. Then use the `Underscan` slider to increase the underscan
4. Click `Apply` and done

**Adjust directly via Xorg**:
1. Follow steps from the nvidia-settings section above
2. Instead of `Apply` click `Save to X Configuration File` then `Show preview...`
3. From here you can see what needs to be added to your `/etc/X11/xorg.conf.d/10-display.conf` file to get what you want.
4. Example changing viewport with syntax `widthxheight+offset_width+offset_height`
   ```bash
   # http://blog.wxm.be/2012/08/26/nvidia-linux-overscan.html
   Section "Screen"
       Identifier "Screen0"
       # Keep underscan/overscan and offset at defaults
       Option     "metamodes" "1920x1080 +0+0"
       # Underscan 14 pixels and offset to center it
       Option     "metamodes" "1920x1080 +0+0 {viewportout=1892x1064+14+7}"
       # Underscan 14 pixels and leave top left corner
       Option     "metamodes" "1920x1080 +0+0 {viewportout=1892x1064+0+0}"
       SubSection "Display"
           Depth 24
           Modes "1920x1080"
       EndSubSection
   EndSection
   ```

## Mouse

### Configure Mouse Speed
[Arch Linux Wiki](https://wiki.archlinux.org/index.php/Mouse_acceleration#Using_xinput)
The xorg input config file at `/etc/X11/xorg.conf.d/40-input.conf` sets up the mouse speed and
accuracy.

Xorg config method
```bash
Section "InputClass"
  Identifier "Mouse"
  Driver "libinput"
  MatchIsPointer "on"
  MatchDevicePath "/dev/input/event*"
  Option "AccelSpeed" "0.6"
  EndSection'
```

Manually test mouse acceleration via libinput before using above in Xorg config:
```bash
# Find mouse device id
$ xinput list
Virtual core pointer                    	id=2	[master pointer  (3)]
   ↳ Virtual core XTEST pointer           id=4	[slave  pointer  (2)]
   ↳ PixArt HP USB Optical Mouse          id=10	[slave  pointer  (2)]
...

# List out mouse properties
$ xinput list-props 10
...
libinput Accel Speed (361):	0.300000
...

# Set new value to test acceleration diff, increase value to accelerate faster
xinput --set-prop 10 'libinput Accel Speed' 0.6
```

### Configure Mouse Scroll
Although libinput doesn't have a nice property to change the scrolling speed. You can at the systemd
udev level modify the scroll speed.

```bash
# View the udev mouse control file
$ sudo vim /etc/udev/hwdb.d/70-mouse.hwdb

# All supported brands are listed in this file so we need to identify your mouse
$ xinput list
...
   ↳ PixArt HP USB Optical Mouse          id=10	[slave  pointer  (2)]
...
# Searching the file "HP USB 1000dpi Laser Mouse" is probably the closest thing to it
# Note the 'MOUSE_WHEEL_CLICK_ANGLE=15'

# Create a new mouse control override
$ sudo vim /etc/udev/hwdb.d/71-mouse.hwdb

# Add contents
# HP USB 1000dpi Laser Mouse
mouse:usb:v0458p0133:name:Mouse Laser Mouse:
 MOUSE_DPI=1000@125
 MOUSE_WHEEL_CLICK_ANGLE=30

# Reload the udev rules
$ sudo udevadm hwdb --update
$ sudo udevadm trigger /dev/input/event1
```

## Keyboard

### Configure Keyboard Rate
This works well for a bare bones system, but I was never able to figure out a reliable way to have it 
always be set as I think the desktop environment would override it.
```bash
# Set this in your `~/.xprofile`
# First number is after how many ms the key will start repeating
# Second number is how many repititions per second, so after 190ms will output 60 a sec
xset r rate 200 60
```

However both `LXDE` and Xfce have their own keyboard control app that allows you to set similar 
values.

### Disable Numlock on Boot
LXDM has a nice configuration setting allowing you to enable or disable numlock on boot.

1. Edit `/etc/lxdm/lxdm.conf`
2. Set `numlock=0` to disable

## Printer
Any printer will require the default CUPS installation

```bash
# First install the CUPS open source printer solution
$ sudo pacman -S cups-pdf system-config-printer

# Start the CUPS service
$ sudo systemctl enable cups
$ sudo systemctl start cups

# Ensure your user is part of the 'lp' group
$ groups
```

### Workforce WF-7710
The package that works for the WF-7710 is actually a wrapped version that comes from Epson directly

1. Download and install the correct Epson driver  
  a. Navigate to [Arch Wiki - Epson](https://aur.archlinux.org/packages/epson-inkjet-printer-escpr2/)  
  b. We can see that the `WF7710` requires the AUR package `epson-inkjet-printer-escpr2`  
  c. Open a shell and run:  
  ```bash
  $ yaourt -G epson-inkjet-printer-escpr2
  $ cd epson-inkjet-printer-escpr2
  $ makepkg -s
  $ sudo pacman -U epson-inkjet-printer-escpr2-1.0.26-1-x86_64.pkg.tar.xz
  ```
2. Launch `system-config-printer`  
  a. Click `+Add > Network Printer`  
  b. Select `Epson WF-7710`  
     Note: it automatically showed up in the list  
  c. Click `Forward`  
  d. Click `Apply`  

### Pending - Out of Paper
The printer driver got stuck after one failed print and continually reported the printer was out of
paper. Opening the `Printer Preferences` i.e. `system-config-printer` app showed a yellow caution
overlay indicating the problem. I right clicked on it and set it to `enabled` and double clicked to
establish a connection and it started working after that.

## Scanner
https://wiki.archlinux.org/index.php/SANE

SANE is the defacto standard in the Linux community for scanning software.
```bash
# Install
$ sudo pacman -S sane

# Test if your scanner is reconized by SANE
$ scanimage -L
```

### Workforce WF-7710<a name="scanner-workforce-wf-7710"/></a>

**Slow detection black list devices:**
```bash
# First time I detected devices
$ scanimage -L
device `v4l:/dev/video0' is a Noname HP Webcam 3110: HP Webcam 3110 virtual device

# Edit /etc/sand.d/v4l.conf
# /dev/video0

# Once that was commented out I got nothing
No scanners were identified. If you were expecting something different,
check that the scanner is plugged in, turned on and detected by the
sane-find-scanner tool (if appropriate). Please read the documentation
which came with this software (README, FAQ, manpages).
```

Search EPSON I found the [Support Driver Download Page](http://download.ebz.epson.net/dsc/search/01/search/searchModule#)
and saw the `WF-7710 Series` had a `Scanner Driver` package available which when clicked brought me to the
[Image Scan v3](http://support.epson.net/linux/en/imagescanv3.php) so then I went back to the Arch Linux wiki
and found the [Image Scan v3](https://wiki.archlinux.org/index.php/SANE/Scanner-specific_problems#Image_Scan_v3) 
backend driver support section.

**Working through the driver install process:**
1. Install imagescan
   ```bash
   $ sudo pacman -S imagescan imagescan-plugin-networkscan
   ```
2. Configure your target scanner editing `/etc/utsushi/utsushi.conf`
   ```bash
   [devices]
   wf7710.udi    = esci:networkscan://192.168.1.94:1865
   wf7710.vendor = EPSON
   wf7710.model  = WF-7710
   ```

**Scan a black and white document:**
1. Launch the scanner with `utsushi`
2. Set `Scan Area` to `Letter/Portrait`
3. Set `Resolution` to `150`
4. Set `Image Type` to `Grayscale`
5. Click `Scan` and choose the pdf destination

## Sound

### Simultaneous output to multiple devices
[Simultaneous output to multiple devices](https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Simultaneous_output_to_multiple_sound_cards_/_devices)

1. Install: `sudo pacman -S paprefs`
2. Launch the app: `paprefs`
3. Click the `Simultaneous Output` tab
4. Check `Add virtual output device for simultaneous output on all local sound cards`

### Google Meet Headset
I prefer plantronics devices for their superior noise cancelation, but any headset will work here.
The goal is to simply get your mic and headset output working through a browser for google meet. I
tend to use Firefox for speed and privacy but other will be similar.

1. Configure [Simultaneous output to multiple devices](#simultaneous-output-to-multiple-devices)
2. Set Google Meet's device settings correctly  
   a. Launch `firefox`  
   b. Navigate to Google Meet and start a meeting then open up the meet `Settings`  
   c. Choose your `Microphone` to be your headset  
   d. Choose your `Speakers` to be the `System Default Speaker Device`  
3. Set Pulse Audio to use the correct input and output for your browser  
   a. Launch `pavucontrol`  
   b. Switch to the `Playback` tab and switch `Firefox: AudioCallbackDriver on` to use the `Simultaneous` option  
   c. Switch to the `Recording` tab and switch `Firefox: AudioCallbackDriver from` to use your headset  
4. Test the call in google meet

# Display Manager
A [display manager](https://wiki.archlinux.org/index.php/Display_manager) is a graphical user
interface that is displayed at the end of the boot process in place of the default shell.
***cyberlinux*** uses systemd as its init system and invokes LXDM as the `display-manager.service`.
LXDM works in conjunction with the systemd service `systemd-logind` managed with `loginctl`.

Systemd will create the `display-manager.service` link to LXDM for you with:
```bash
$ sudo systemctl enable lxdm
```

## LXDM
[LXDM](https://wiki.archlinux.org/index.php/LXDM) is a lightweight display manager for the LXDE
desktop environment.

Config files:
* `/etc/lxdm/lxdm.conf`

### Set lxdm background
1. Run `sudo lxdm-config`
2. And change the background to whatever you want
3. Then simply close. It saves the changes automatically

## SDDM
[SSDM](https://wiki.archlinux.org/title/SDDM), a.k.a `Simple Display Manager` is the recommended 
display manager for KDE Plasma and LXQt desktop environments. SSDM defaults to using `systemd-logind` 
for session management.

Config files:
* `/etc/ssdm.conf.d/`

# Containers

## Podman
Podman replaces the docker cli and docker daemon with a cli that emulates the docker cli but calls
the registry etc... directly via `runC` rather than using a go between daemon as docker does. This
has all kinds of advantages, one being no daemon running in the background consuming resources on
development machines.

### Migrate from Docker
1. Remove all docker volumes, images and containers:
   ```bash
   $ docker system prune
   ```
2. Shutdown docker daemon and uninstall:
   ```bash
   $ sudo systemctl stop docker
   $ sudo pacman -Rns docker
   $ gpasswd -d <user> docker
   ```
3. Install podman and configure:
   ```bash
   # Install podman
   $ sudo pacman -S podman buildah

   # Since podman is drop in compatible with docker lets just use a link
   $ sudo ln -sf /usr/bin/podman /usr/bin/docker

   # Set docker.io as the default registry
   $ sudo echo 'unqualified-search-registries = ["docker.io"]' > /etc/containers/registries.conf

   # Create the default policy file
   $ sudo echo '{ "default": [{"type": "insecureAcceptAnything"}] }' > /etc/containers/policy.json
   ```

## Docker ipv6 issue
`Docker v20.10.6` is [borked](https://github.com/moby/moby/issues/42288) and no longer works on
systems that have kernal parameter `ipv6.disable=1` set.

[Fixed in 20.10.7](https://docs.docker.com/engine/release-notes/#20107)

**Old Mitigation:**
1. Downgrade to `20.10.5`:
   ```bash
   $ sudo pacman -U /var/cache/pacman/pkg/docker-1\:20.10.5-1-x86_64.pkg.tar.zst
   ```

2. Update your `/etc/pacman.conf` to hold the package at that version:
   ```
   IgnorePkg = docker
   ```

## Build container
From the directory that contains your ***Dockerfile*** run:

```bash
$ docker build -t alpine-base:latest  .
```

### Build from filesystem
You can create a container image from a fileystem

Navigate to the directory of your filesystem then run:
```bash
$ sudo tar -c . | docker import - builder
```

## Run container
```bash
$ docker run --rm -it alpine-base:latest bash
```

### Shell into a running container
```bash
$ docker exec -it builder bash
```

### Check if container exists
You can check if a container exists in a programatic way using Docker Go templating and JSON output 
with the `jq` binary for extracing key information.

```bash
$ docker container ls --format='{{json .}}' | jq
```

## Upload container
1. Build and deploy a cyberlinux container see [Build cyberlinux container](#build-cyberlinux-container)
2. List out your docker images: `docker images`
3. Login to dockerhub.com: `docker login`
4. Tag and push the versioned and latest tags
  ```bash
  # Tag and push the versioned image
  $ docker tag net-0.2.197:latest phr0ze/cyberlinux-net:0.2.197
  $ docker push phR0ze/cyberlinux-net:0.2.197

  # Tag and push the latest image
  $ docker tag net-0.2.197:latest phr0ze/cyberlinux-net:latest
  $ docker push phr0ze/cyberlinux-net:latest
  ```

## Remove images
Removing images with podman is easier than docker as it has the `--all` flag.
Images are stored at `~/.local/share/containers`.

```bash
$ docker rmi --all
```

## Build cyberlinux container
Build, deploy and run a cyberlinux container

```bash
# Build net container
$ sudo ./reduce clean build -d net -p containers

# Deploy net container to local docker
$ sudo ./reduce deploy net -p containers

# Run net container with docker
$ docker run --rm -it net-0.2.197:latest bash
```

# Games
## HedgeWars
HedgeWars is a Worms clone and a lot of fun.

### Install HedgeWars
Install:
```bash
$ sudo pacman -S hedgewars
```

### libGL nvidia-340xx fix
Unfortunately when using the older `nvidia-340xx` proprietary driver it has issues with `libGL`
[library linkage](https://forum.manjaro.org/t/hedgewars-nvidia-problem-with-proprietary-driver-cant-launch-game-libglnvd-conflict/45955).

To fix the issue we need to update the libs to use the nvidia versions:
```bash
# List out the faulty libs
sudo ldconfig -p | grep libGL.so.1
	libGL.so.1 (libc6,x86-64) => /usr/lib/nvidia/libGL.so.1
	libGL.so.1 (libc6,x86-64) => /usr/lib/libGL.so.1
	libGL.so.1 (libc6) => /usr/lib32/nvidia/libGL.so.1
	libGL.so.1 (libc6) => /usr/lib32/libGL.so.1

# Fix the linkage
sudo rm /usr/lib/libGL.so.1
sudo rm /usr/lib32/libGL.so.1
sudo ln -s /usr/lib/nvidia/libGL.so.1 /usr/lib/libGL.so.1
sudo ln -s /usr/lib32/nvidia/libGL.so.1 /usr/lib32/libGL.so.1
```

## Steam

**Resources:**
* [Arch Linux Steam Wiki page](https://wiki.archlinux.org/title/Steam)

1. Install steam on VirtualBox
   ```bash
   $ sudo pacman -S steam vulkan-intel lib32-vulkan-intel
   ```


# Bootloader

## Grub
I was using syslinux as my goto bootloader as it is so simple and liteweight, but found that grub
handled install splash screens and menus better and the transition from gfx to xorg better so I 
switched over to `Grub`.

### Boot Kernel
On BIOS systems the boot grub config ends up in `/boot/grub/grub.cfg` where as on an EFI system the
grub boot files are stored on the ESP mount point.

You can tell which firmware system you have by simply looking at the partitions on your disk:

**EFI System** - is the EFI partition that contains the bootloader
```bash
$ sudo fdisk -l
Device         Start      End  Sectors  Size Type
/dev/mmcblk0p1  2048    22527    20480   10M EFI System
```

**BIOS boot** - is the BIOS partition that contains the bootloader
```bash
$ sudo fdisk -l
Device       Start       End   Sectors   Size Type
/dev/sda1     2048      6143      4096     2M BIOS boot
```

#### Create the BIOS boot partition
```bash
# Install grub package
$ sudo pacman -S cyberlinux-grub

# Determine your target drive
$ sudo fdisk -l
Device       Start       End   Sectors   Size Type
/dev/sda1     2048      6143      4096     2M BIOS boot

# Ensure your drive has the cyberlinux label
$ sudo blkid
/dev/sda1: PARTLABEL="BIOS boot" PARTUUID="xxx-xxx..."
/dev/sda3: LABEL="root" UUID="xxx-xxx..." TYPE="ext4" PARTLABEL="Linux filesystem" PARTUUID="xxx-xxx..."
$ sudo tune2fs -L cyberlinux /dev/sda3
$ sudo blkid
/dev/sda3: LABEL="cyberlinux" UUID="xxx-xxx..." TYPE="ext4" PARTLABEL="Linux filesystem" PARTUUID="xxx-xxx..."

# Install grub boot loader to disk
$ sudo grub-install --target=i386-pc /dev/sda

# Create the grub file with the following
$ sudo vim /boot/grub/grub.cfg
default=0
timeout=0

set gfxmode="1920x1080,auto"
loadfont unicode.pf2
terminal_input console
terminal_output gfxterm

menuentry "cyberlinux" {
    set gfxpayload=keep
    search --no-floppy --set=root --label cyberlinux
    linux /boot/vmlinuz-linux root=LABEL=cyberlinux rw rd.systemd.show_status=auto rd.udev.log_priority=3 ipv6.disable=1
    initrd /boot/intel-ucode.img /boot/initramfs-linux.img
}

$ sudo reboot
```

### Create the EFI System partition
Systems like the Samsung Chromebook 3 boot in UEFI mode which reads the bootloader from the boot
partition EFI System.

```bash
# Mount the ESP for editing
$ sudo mount /dev/mmcblk0p1 /mnt/tmp

# Edit the grub file to use the new kernel
$ cat /mnt/tmp/grub/grub.cfg
default=0
timeout=0

set gfxmode="1366x768,auto"
loadfont unicode.pf2
terminal_input console
terminal_output gfxterm

menuentry "cyberlinux" {
    set gfxpayload=keep
    search --no-floppy --set=root --label cyberlinux
    linux /boot/vmlinuz-linux root=LABEL=cyberlinux rw rd.systemd.show_status=auto rd.udev.log_priority=3 ipv6.disable=1
    initrd /boot/intel-ucode.img /boot/initramfs-linux.img
}

# Save the desired changes and unmount and reboot
$ sudo umount /mnt/tmp
$ sudo reboot
```

### Boot Resolution
Grub has the ability to configure the boot resolution that is used during boot and inherited by LXDM.
To configure this modify the `/boot/grub/grub.cfg` file.

Change the `set gfxmode="1920x1080,auto"` to something that makes sense for your machine. For example
I needed to set this to `set gfxmode="1024x600,auto"` for my Asus Aspire One 532h.

Additionally create the `X11` resolution `/etc/X11/xorg.conf.d/10-display.conf`:
```bash
Section "Screen"
  Identifier "Screen0"
  SubSection "Display"
    Depth 24
    Modes "1024x600"
  EndSubSection
EndSection
```

### Add Kernel params
Adding a kernel to the boot process can be done with Grub as follows:

**BIOS**
1. Edit `/boot/grub/grub.cfg`
2. Modify the `linux /boot/vmlinuz-linux` line e.g. adding `ibt=off` below
```
menuentry "CYBERLINUX" {
    ...
    linux /boot/vmlinuz-linux root=LABEL=CYBERLINUX rw rd.systemd.show_status=auto rd.udev.log_priority=3 ipv6.disable=1 ibt=off
    ...
}
```

# Fonts
https://wiki.archlinux.org/index.php/fonts

## Install Fonts

### Install manually
1. Copy fonts to `/usr/share/fonts`
2. Set permissions to at least `0444` for files and `0555` for directories

### Install from a package
`sudo pacman -S ttf-<package>`

### Update font cache
Update font cache: `fc-cache`


## Find Font Name
Many applications in Linux require you to set the font by name via entering a text string rather than 
picking from a widget list. This is problematic if you don't know the exact name of the font. To 
figure this out you can.

1. List out and grep for your target font
   ```bash
   $ fc-list | grep -i inconsolata
   ```
2. Copy out the portion after the first colon example
   ```
   /usr/share/fonts/TTF/InconsolataGo Nerd Font Complete Mono.ttf: InconsolataGo Nerd Font Mono:style=Regular
   InconsolataGo Nerd Font Mono
   ```

## Fontconfig
https://wiki.archlinux.org/index.php/font_configuration

Fontconfig is a library designed for provide a list of available fonts to applications, and also for
configuration for how fonts get rendered. The default font rendering library `freetype2` installed on
most linux machines renders fonts based on this configurattion.

Font configuration is done per user via the `~/.config/fontconfig/fonts.conf` and globally with
`/etc/fonts/local.conf` and `/etc/fonts/conf.d/*`.  All configuration is gathered into
`/etc/fonts/fonts.conf` during fontconfig updates via `fc-cache` and should not be edited.

The process for making Fontconfig configurations changes is:
1. Edit config files and/or install fonts
2. Build Fontconfig's configuration, run: `fc-cache`
3. Close and reopen applications that you want to see updated

### Replace or Set Defaut Fonts
```xml
...
 <match target="pattern">
   <test qual="any" name="family"><string>georgia</string></test>
   <edit name="family" mode="assign" binding="same"><string>Ubuntu</string></edit>
 </match>
...
```

### Font paths
Fontconfig recogizes the following font paths and scans them recursively:
* `/usr/share/fonts`
* `~/local/share/fonts`

List out existing fonts known to Fontconfig
```bash
$ fc-list : file
```

### Font Presets
Font presets are installed in the directory `/etc/fonts/conf.avail` and can be enabled by creating
symbolic links to them in the `/etc/fonts/conf.d` directory.

### Subpixel Rendering
Subpixel rendering a.k.a. `ClearType` is covered by Microsoft patents and **disabled** by default on
Arch Linux. To enable it, you have to use the `freetype2-cleartype` AUR package.

## Distro Fonts
Fonts are tricky due to licensing, despite being free for commercial use many are only free for
individual users and can not be included in a distribution.  That said here are some awesome techno
fonts that you may want to individually use.

* https://www.1001fonts.com/sui-generis-free-font.html
* https://www.1001fonts.com/rexlia-free-font.html
* https://www.1001fonts.com/recharge-font.html
* https://www.1001fonts.com/nulshock-font.html
* https://www.1001fonts.com/galderglynn-titling-font.html
* https://www.1001fonts.com/conthrax-font.html
* https://www.1001fonts.com/good-times-font.html
* https://www.1001fonts.com/sofachrome-font.html
* https://www.1001fonts.com/hemi-head-426-font.html
* https://www.1001fonts.com/ethnocentric-font.html
* https://www.1001fonts.com/neuropolitical-font.html
* https://www.1001fonts.com/induction-font.html
* https://www.1001fonts.com/neuropol-x-free-font.html
* https://www.1001fonts.com/zekton-free-font.html
* https://www.1001fonts.com/no-clocks-font.html
* https://www.1001fonts.com/dendritic-voltage-font.html
* https://www.1001fonts.com/neuropol-font.html
* https://www.1001fonts.com/perfect-dark-brk-font.html
* https://www.1001fonts.com/crackdown-brk-font.html
* https://www.1001fonts.com/airstrip-four-font.html
* https://www.1001fonts.com/aldrich-font.html
* https://www.1001fonts.com/anita-semi-square-font.html
* https://www.1001fonts.com/audiowide-font.html

## Conky Fonts
Conky will need to be restarted to pick up new fonts

# Kernel
## Switch Kernel
1. Install the target kernel
   ```bash
   $ sudo pacman -S linux-lts linux-lts-headers
   ```
2. Update the boot loader config to point to the target kernel
   ```bash
   $ sudo vim /boot/grub/grub.cfg
   # Modify the `vmlinuz-linux` and `initramfs-linux` entries to the target kernel
   # `vmlinuz-linux-lts` and `initramfs-linux-lts`
   $ sudo reboot
   ```

# Launchers
## Plank
Plank can be configured via the `dconf-editor`

1. Launch `dconf-editor`
2. Navigate to `net/launchpad/plank/docks/dock1`
3. Flip switches as desired

# Mount

## Mount Busy
How do you deal with a mount point that is busy e.g.

`umount: cyberlinux/temp/work/deployments/shell/dev: target is busy.`

### lsof
See the open files for the given mount path

`lsof <mount path that is busy>`

### fuser
`fuser` provided by the `psmisc` package is a command line utility for identifying processes using
resources.

1. Check that you have a valid local user session within X:
   ```bash
   # Look for Remote=no and Active=yes
   $ loginctl show-session $XDG_SESSION_ID
   ...
   Remote=no
   ...
   Active=yes
   ...
   ```
2. 

## Add Automount using FSTAB
https://www.freedesktop.org/software/systemd/man/systemd.mount.html

According to systemd documentation `/etc/fstab` entries will be automatically converted to systemd unit
files and is the preferred approach rather than manually creating individual mount unit files.

```bash
# Make mount point directory
$ sudo mkdir /mnt/storage

# Identify your drive
$ lsblk

# Find UUID of drive
$ sudo bash -c 'blkid >> /etc/fstab'

# Edit /etc/fstab
# fstab usage: UUID=ba6619b0-c3a6-493e-92f0-14bf313d15a3 /mnt/storage1 ext4 defaults,noatime,nodiratime 0 0
$ sudo vim /etc/fstab

# Manually mount
$ sudo mount -a

# Set ownership if needed
$ sudo chown -R USER: /mnt/storage1 /mnt/storage2
```

# Office
## LibreOffice

### Config Navigation
1. Display navigation select ***View >Navigator***  
2. Dock press ***Ctrl+Shift+F10***  

### Keyboard Shortcuts
`~/.config/libreoffice/4/user/registrymodifications.xcu`

1. Navigate to ***Tools >Customize... >Keyboard***  
2. Set ***Ctrl+Shift+c***  
  a. Press ***Ctrl+Shift+c*** to automatically navigate to that shortcut in the top window  
  b. Navigate to ***Category >Styles >Character >Code***  
  c. Click ***Modify*** in the top right to set shortcut function  
3. Set ***Ctrl+Shift+d***  
  a. Press ***Ctrl+Shift+d*** to automatically navigate to that shortcut in the top window  
  b. Navigate to ***Category >Styles >Character >Default Style***  
  c. Click ***Modify*** in the top right to set shortcut function  
4. Set ***Ctrl+Shift+l***  
  a. Press ***Ctrl+Shift+l*** to automatically navigate to that shortcut in the top window  
  b. Navigate to ***Category >Styles >Numbering >List 1***  
  c. Click ***Modify*** in the top right to set shortcut function  
5. Set ***Ctrl+Shift+n***  
  a. Press ***Ctrl+Shift+n*** to automatically navigate to that shortcut in the top window  
  b. Navigate to ***Category >Styles >Numbering >Numbering 1***  
  c. Click ***Modify*** in the top right to set shortcut function  
6. Set ***Ctrl++*** (there is a bug that prevents this from working)  
  a. Press ***Ctrl++*** to automatically navigate to that shortcut in the top window  
  b. Navigate to ***Category >View >Functions >Zoom In***  
  c. Click ***Modify*** in the top right to set shortcut function  
7. Set ***Ctrl+-*** (there is a bug that prevents this from working)  
  a. Press ***Ctrl+-*** to automatically navigate to that shortcut in the top window  
  b. Navigate to ***Category >View >Functions >Zoom Out***  
  c. Click ***Modify*** in the top right to set shortcut function  

### Set Default Template
1. Save your template as ***~/.config/libreoffice/4/user/template/standard.ott***  
2. Launch ***libreoffice*** and navigate to ***File >Templates >Manage Templates***  
3. Right click on ***standard*** and choose ***Set As Default***  
4. Cancel dialog and your done  

### Turn off Smart Quotes
1. Navigate to ***Tools >AutoCorrect >AutoCorrect Options...***  
2. Select the ***Localization Options*** tab  
3. Uncheck ***Replace*** for both types of quotes  

### Turn off Replace Dashes
1. Navigate to ***Tools >AutoCorrect >AutoCorrect Options...***  
2. Select the ***Options*** tab  
3. Uncheck ***Replace dashes***  

### Turn off Automatic Strikeout
1. Navigate to ***Tools >AutoCorrect >AutoCorrect Options...***  
2. Select the ***Options*** tab  
3. Uncheck ***Automatic bold,italic,strikeout,underline***   

### Fix Spellcheck Issue
LibreWriter has a notorious issue with getting the spell checker to work correctly when you it `F7`.
The problem is that first of all LibreWriter allows the default language to be set in multiple places
and second that you have to have your curser on a line that has text before pressing `F7` or it won't
be able to determine the correct language to use.

Default language override order:
1. In the global settings `Tools >Options... >Language Settings >Languages >Western >English (USA)`
2. In the paragraph styles `k`

Ensure the paragraph style is set correctly in any custom templates:
1. Open `~/.config/libreoffice/4/user/template/standard.ott`
2. Open the template styles by clicking the hamburger on the right and choosing `Styles`
3. Right click on the `Default Style` and choose `Modify...`
4. Select the `Font` tab
5. Set the `Language` to `English (USA)`
6. Note at the bottom the language called out `English (USA)`
7. Click `Save as Template...`
8. Choose `My Templates` and name `standard`

### Repeatable Config
LibreOffice stores its user configuration in the `~/.config/libreoffice/4/user/registrymodifications.xdu` file.
To detect the settings you desire and apply them to a future system you can remove the config and use
git to detect the diffs between the defaults and any changes you make.

```bash
# Remove the existing configuration to have it defaulted
```

## OCR

### Tesseract
```bash
$ tesseract input.png out
```

## PDFs

### PDF Manipulation
For general PDF manipulation `pdfmod` works well

```bash
$ sudo pacman -S pdfmod
```

### Combine PDFs
```bash
# Install pdfjoin
$ sudo pacman -S pdfjoin

# Join pdfs
$ pdfjoin 1.pdf 2.pdf -o combined.pdf
```

### Rotate PDFs
```bash
$ qpdf in.pdf out.pdf --rotate=[+|-]angle[:page-range]
```

### Convert Images to PDF
```bash
# Install imagemagick
$ sudo pacman -S imagemagick

# Comment out the stupid security policy default in Arch Linux
$ sudo vim /etc/ImageMagick-7/policy.xml
# <policy domain="coder" rights="none" pattern="{PS,PS2,PS3,EPS,PDF,XPS}" />

# Convert images to pdf
# -quality is the jpeg compression to use for images
$ convert -resize 50% -quality 98 -units pixelsperinch -density 150 image1.jpg image2.jpg output.pdf
```

# pacman packages
* Create repo: `repo-add cyberlinux.db.tar.gz *.pkg.tar.*`

## Init database
***cyberlinux*** is configured out of the box with initial keys and databases; however should the
need arise to clean it and start fresh this is what you do.

```bash
# Initialize pacman keys
$ sudo pacman-key --init

# Populate with repo keys
$ sudo pacman-key --populate archlinux blackarch

# Update database
$ sudo pacman -Sy

# Cache pkg data
$ sudo pkgfile --update
```

## Update mirrorlist
Install latest mirrorlist and rank by fastest 20

```bash
# Install the latest mirror list
$ sudo pacman -S pacman-mirrorlist
$ sudo mv /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/mirrorlist

# Sort mirrorlist by speed  
# First uncomment all the US mirrors then delete everything else
$ sudo bash -c 'rankmirrors -n 20 /etc/pacman.d/mirrorlist > /etc/pacman.d/archlinux.mirrorlist'

# Clean up
$ sudo rm /etc/pacman.d/mirrorlist
```

## Create Repo Database
Creating a repo database from a directory of packages is a simple process:
```bash
# Navigate into the target directory
$ cd ~/Projects/cyberlinux.bitbucket.io/packages/cyberlinux/x86_64

# Remove prior database files
$ rm -rf cyberlinux.*

# Create the database
$ repo-add cyberlinux.db.tar.gz *.pkg.tar.*

# Replace symbolic links with hard links
$ ln -f cyberlinux.db.tar.gz cyberlinux.db
$ ln -f cyberlinux.files.tar.gz cyberlinux.files
```

## Share Package Cache
When running more than one arch linux based machine sharing the package cache can be usefull to
reduce the number of packages being downloaded.

Note: I removed the step to bind mount to `/var/cache/pacman/pkg` as this causes some weird issue with
the `tmp-fs` service. Instead I simply mount it at `/mnt/Cache` and setup pacman to use it.

1. Setup an NFS share see [Share Package Cache](#share-package-cache) on your server
2. Ensure your NFS client is installed and can see the server shares:
   ```bash
   $ showmount -e 192.168.1.3
   Export list for 192.168.1.3:
   /srv/nfs/Cache 192.168.1.3
   ```
3. Create a local mount point:
   ```bash
   $ sudo mkdir -p /mnt/Cache
   $ sudo chown -R USER: /mnt/Cache
   ```
4. Setup automounting on boot:
   ```
   $ sudo bash -c 'echo "192.168.1.3:/srv/nfs/Cache /mnt/Cache nfs auto,noacl,noatime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0" >> /etc/fstab'
   $ sudo mount -a
   ```
5. Clear out the existing pacman cache:
   ```bash
   $ sudo pacman -Scc
   ```
6. Edit the pacman config `/etc/pacman.conf` and change the cache directory
   ```
   CacheDir     = /mnt/Cache
   ```
7. Occasionally you'll want to clean the cache:
   ```bash
   # Remove all but the last package installed
   $ sudo paccache -rk 1
   ```

## Download packages only
Sometimes its useful to download packages ahead of time to use in an offline usecase. For example
Docker has a limitation that it can't mount a volume during build and we'd really like to cache
package downloading so we're not constantly downloading the same packages over and over again. Its
slow and annoying. To avoid this we can use the off the shelf image `archlinux:base-devel` with a
mounted volume to download them and store them for us using the same lates image version that we'll
be using to build with thus avoiding host dependencies.

Arch Linux uses the `/var/cache/pacman/pkg` location as its package cache and provides a nifty
download only option `--downloadonly` a.k.a. `-w` that will allow us to download the target packages 
to the cache without installing them.

```bash
$ docker run --name builder --rm -it -v "${pwd}/temp":/var/cache/pacman/pkg archlinux:base-devel bash
$ pacman -Syw --noconfirm grub
```

## BlackArch repo

### Configure BlackArch repo
In order to configure the black arch repo you'll need to download their `blackarch-keyring` package
and their mirrorlist. The blackarch [strap.sh script](https://blackarch.org/strap.sh) gives some
insight as to how to do that.

1. Download the `blackarch-keyring` package
   ```bash
   $ curl -O https://blackarch.org/keyring/blackarch-keyring.pkg.tar.xz
   ```
2. Install the `blackarch-keyring` package
   ```bash
   sudo pacman --config /dev/null --noconfirm -U blackarch-keyring.pkg.tar.xz
   ```
3. Populate the pacman keyring
   ```bash
   $ sudo pacman-key --populate
   ```
4. The blackarch mirrorlist can be downloaded with
   ```bash
   $ curl -O https://blackarch.org/blackarch-mirrorlist
   ```

### BlackArch Signature issue
To fix the issue below delete ***/var/lib/pacman/sync/*.sig***

Example: 
```
error: blackarch: signature from "Levon 'noptrix' Kayan (BlackArch Developer) <noptrix@nullsecurity.net>" is invalid
error: failed to update blackarch (invalid or corrupted database (PGP signature))
error: database 'blackarch' is not valid (invalid or corrupted database (PGP signature))
```

# Panels

## Tint2

## XFCE4 Panel

### Install XFCE4 Panel
```bash
$ sudo pacman -S xfce4-panel xfce4-pulseaudio-plugin xfce4-battery-plugin xfce4-datetime-plugin
```

# Patching

## Create Patch
```bash
# Copy code to a
$ cp -a <code> a

# Copy a to b
$ cp -a a b

# Modify b as desired then generate patch
$ diff -ruN a b > <patch-name>.patch
```

## Apply Patch
```bash
$ patch -Np1 -i <patch-name>.patch
```

# Power Management
Originally I was using conky and a few scripts to handle battery status and screen dimness, but I 
kept loosing track of the script names and keyboard shortcuts. I'm switching over to use XFCE's Power 
Management application.

## XFCE4 Power Manager
Note the icon is called `/usr/share/icons/hicolor/48x48/apps/org.xfce.powermanager.png` and has no 
`32x32` size option.

1. Install xfce4-power-manager
   ```bash
   $ sudo pacman -S xfce4-power-manager
   ```
2. Launch power manager
   ```bash
   $ xfce4-power-manager-settings
   ```
3. Configure power manager
   a. Under the `General` tab  
   a. Set `Handle display brightness keys` on  
   b. Set `Status notification` on  
   c. Set `System tray icon` on  

### Battery Status
To keep the OS as light as possible I decided to use 
[conky](https://github.com/phR0ze/cyberlinux/blob/master/profiles/openbox/desktop/etc/skel/conky/netbook) to 
provide ***Date***, ***Time***, ***Calendar***, and ***Battery status*** as well as a few other 
monitoring widgets.

### Display Brightness
1. Launch power manager
   ```bash
   $ xfce4-power-manager-settings
   ```
2. Under the `General` tab  
   a. Set `Handle display brightness keys` on  
   b. Set `Status notification` on  
   c. Set `System tray icon` on  

## Suspend
Suspend works out of the box with ***systemd*** as the default system manager

# Rescue

## Switch to TTY
Bare Metal:
* `ctrl+alt+F2` should switch to console  
* `ctrl+alt+F1` should switch back to UI

VirtualBox:
* `right ctrl+F2` should switch to console  
* `right ctrl+F1` should switch back to UI

## Graphical Target
When you're system boots the last thing you'll see before the display manager is loaded is that the
`Graphical Target` is being started. If it hangs here its safe to say either LXDM is failing or Xorg
is failing to start.

### Switch to console
1. First thing to do is to switch over to the console using the key sequene `ctrl+alt+F2`

2. Persist the use of the console and reboot
   ```bash
   $ sudo systemctl set-default multi-user
   $ sudo reboot
   ```

3. When done debugging you can launch graphical target directly with:
   ```bash
   $ sudo systemctl isolate graphical.target
   ```

### Check Xorg logs
The Xorg logs are often telling when unable you get black screens or hanging at the Graphical Target.
Often this will be a video driver issue. You can check your video card with `inxi -G`.

```bash
# Seach boot logs for your graphics card e.g. 'radeon'
$ journalctl -b

$ cat /var/log/Xorg.0.log | grep EE
[     3.932] (EE) Failed to load module "vboxvideo" (module does not exist, 0)
[     3.935] (EE) Failed to load module "fbdev" (module does not exist, 0)
```

### Reset Xorg settings
Often there will be old settings from a previous driver in the `xorg.conf`

```bash
# Remove the xorg config file
# 99.9% of the time the main config file is not required
$ sudo rm /etc/X11/xorg.conf

# Removing the one off configs is probably not needed, but circle back if still not working
$ sudo rm -rf /etc/X11/xorg.conf.d/*
```

### Opensource Driver
Frequently the settings on Nvidia's proprietary drivers will get screwed up. If you just want to
validate that the problem is indeed the video driver you can temporarily switch to the opensource
driver to check.

```bash
# Remove the old nvidia driver
$ sudo pacman -Rns nvidia-340xx nvidia-340xx-utils

# Install the opensource driver
$ sudo pacman -Rns mesa xf86-video-nouveau
```

## Unable to Login
If you are unable to login via LXDM but have got past the Graphicl target that means your video
driver is working properly. In this case it may be something in the chain of scripts and apps that
boot the desktop i.e. LXDM settings, `startx` or user scripts like `.bashrc`. I've seen powerline
initialization in `.bashrc` fail causing the login to fail.

### Try logging in while tailing the logs
1. Switch to TTY and get the ip of the system then loging and tail the logs
   ```bash
   $ journalctl -f
   ```
2. Switch back to LXDM and attempt to loging and watch the logs

### Try running openbox directly
This will eliminate possiblities
1. Use one of the methods below to get shell access.
2. Disable LXDM `sudo systemctl disable lxdm`
3. Restart your system `sudo reboot`
4. Install xinit `sudo pacman -S xorg-xinit`
5. Launch `startx openbox-session`

### Try an aternate window manager
If this works you know you might have an openbox issue or in my case I had a lxdm issue that that I
fixed by uninstalling `lxdm` and instead installing `lxdm-gtk3`.

```bash
$ sudo pacman -S xfwm4 xfce4-session xfce4-settings
$ startxfce4
```

### Try reinstalling the target video driver
I noticed that when I tried reinstalling the correct video driver that the `dkms` module failed to
compile and install with the new kernel. So I rebuilt the drivers and installed the new one and it
worked. So apparently the dkms doesn't always work.

## chroot into target disk
Some times your system won't boot. You can boot from a live usb and chroot into the target disk to 
troubleshoot the issue further

1. Plugin your live USB and boot from it
2. Determine your target disk with `lsblk`
3. Mount your target disk e.g. `sudo mount /dev/sda3 /mnt`
4. Chroot into the disk: `sudo arch-chroot /mnt`

### Unable to chroot into disk
If you are unable to `arch-chroot` into your target disk it's most likely because of a corrupted arch 
linux install e.g. lost power during boot files update or something. In this case you'll need to 
rebuild it from a Live USB.

1. Boot from Live USB
2. Update your mirrorlist
   ```bash
   $ sudo pacman -Sy
   $ sudo pacman -S archlinux-keyring
   $ sudo pacman -S pacman-mirrorlist
   ```
3. Optionally format your target root partition
   ```bash
   $ sudo mkfs.ext4 -F -m 0 -L CYBERLINUX /dev/sda3
   ```
4. Mount your target disk root disk
   ```bash
   $ lsblk
   $ sudo mount /dev/sda3 /mnt
   ```
5. Remove the pacman lock if necessary
   ```bash
   $ sudo rm /mnt/var/lib/pacman/db.lock
   ```
6. Install the base system
   ```bash
   $ sudo pacstrap -c -G /mnt base
   ```
7. Mount the boot disk and install the kernel
   ```bash
   $ sudo mount /dev/sda1 /mnt/boot
   $ sudo pacstrap -c -G /mnt linux linux-firmware 
   ```
8. Install bootloader and configure user password
   ```bash
   $ sudo mkdir -p /mnt/sys/firmware/efi/efivars
   $ sudo mount -o bind /sys/firmware/efi/efivars /mnt/sys/firmware/efi/efivars
   $ sudo arch-chroot /mnt
   $ bootctrl install
   $ passwd
   ```

### Rebuild initramfs-linux
During a failed kernel install I ended up with a 0 byte `/boot/initramfs-linux.img` and at some point
apparently the same thing had happened to `/boot/initramfs-linux-fallback.img` so my system wouldn't
boot at all.

1. Boot from Live USB and chroot into your system
   ```bash
   # Mount the HDD
   $ lsblk
   $ sudo mount /dev/sda3 /mnt

   # Chroot into HDD
   $ sudo arch-chroot /mnt
   ```

2. Ensure the kernel is properly installed:
   ```bash
   $ sudo pacman -S linux-headers
   $ sudo pacman -S linux
   ```

3. Rebuild the initramfs-linux image
   ```bash
   # First determine the correct kernel version
   $ ls /lib/modules
   5.11.10-arch1-1

   # Next rebuild the initramfs-linux image
   $ sudo mkinitcpio -k 5.11.10-arch1-1 -g /boot/initramfs-linux.img
   $ sudo mkinitcpio -k 5.11.10-arch1-1 -g /boot/initramfs-linux-fallback.img
   ```

## Black Screen
If you get a black screen after upgrading downgrade to lts kernel

```bash
sudo pacman -S linux-lts linux-lts-docs linux-lts-headers
sudo reboot
```

Adding `nomodeset` to grub will bypass KMS but that sucks:
```bash
# Update GRUB configuration
# sudo vim /etc/default/grub
# Ensure GRUB_CMDLINE_LINUX="nomodeset"
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Check Logs for Errors
```bash

### Rebuild initramfs-linux
During a failed kernel install I ended up with a 0 byte `/boot/initramfs-linux.img` and at some point
apparently the same thing had happened to `/boot/initramfs-linux-fallback.img` so my system wouldn't
boot at all.

1. Boot from Live USB and chroot into your system
   ```bash
   # Mount the HDD
   $ lsblk
   $ sudo mount /dev/sda3 /mnt

   # Chroot into HDD
   $ sudo arch-chroot /mnt
   ```

2. Ensure the kernel is properly installed:
   ```bash
   $ sudo pacman -S linux-headers
   $ sudo pacman -S linux
   ```

3. Rebuild the initramfs-linux image
   ```bash
   # First determine the correct kernel version
   $ ls /lib/modules
   5.11.10-arch1-1

   # Next rebuild the initramfs-linux image
   $ sudo mkinitcpio -k 5.11.10-arch1-1 -g /boot/initramfs-linux.img
   $ sudo mkinitcpio -k 5.11.10-arch1-1 -g /boot/initramfs-linux-fallback.img
   ```

## Black Screen
If you get a black screen after upgrading downgrade to lts kernel

```bash
sudo pacman -S linux-lts linux-lts-docs linux-lts-headers
sudo reboot
```

Adding `nomodeset` to grub will bypass KMS but that sucks:
```bash
# Update GRUB configuration
# sudo vim /etc/default/grub
# Ensure GRUB_CMDLINE_LINUX="nomodeset"
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Check Logs for Errors
```bash
# Check LXDM unit logs
$ sudo systemctl status lxdm

# LXDM logs
$ sudo vim /var/log/lxdm.log

# Xorg logs - often telling when unable to login or black screens
# Search for EE e.g.
# [     3.932] (EE) Failed to load module "vboxvideo" (module does not exist, 0)
# [     3.935] (EE) Failed to load module "fbdev" (module does not exist, 0)
$ vim /var/log/Xorg.0.log

# Check system logs
$ journalctl --system

# Journal boot logs
$ journalctl -b
```

## Update Old System
When updating a really old system you'll need to do a few things:
1. Get the keyring updated
   ```bash
   $ sudo scp -r /etc/pacman.d user@target-system.com:~/
   $ ssh suer@target-system.com
   $ sudo rm /etc/pacman.d
   $ sudo mv ~/pacman.d /etc
   ```
2. Grab the static pacman with zst support
   ```bash
   $ wget https://pkgbuild.com/~eschwartz/repo/x86_64-extracted/pacman-static
   ```
3. Update your system keyring first
   ```bash
   $ sudo ./pacman-static -S archlinux-keyring
   $ sudo ./pacman-static -Syu
   ```

## ldconfig is empty, not checked
After a failed pacman update I noticed ldconfig was throwing all kinds of errors similar to:
```bash
ldconfig: File /usr/lib/libnautilus-extension.so is empty, not checked.
```

Additionally I noticed that many packages were showing out of sync with upstream:
```bash
$ sudo pacman -Qkk | grep warning
```

The fix for both these issues seems to be reinstalling the implicated package and overwriting any
local files.
```bash
$ sudo pacman -S firefox --overwrite '*'
```

# Session Manager

## lxsession
[LXsession](https://wiki.archlinux.org/title/LXDE#Autostart) provides `XDG Autostart` support that 
executes the following before then running `Openbox`
* `~/.config/autostart`
* `/etc/xdg/autostart`

## xfce4-session
`xfce4-session` is a session manager for Xfce. Its task is to save the state of your desktop (opened 
applications and their location) and restore them during your next startup.

Provides:
* Autostat via `~/.config/autostart`

# Storage

## Add Drive
1. Get device names
   ```bash
   $ lsblk
   ```

2. Destroy any RAID information if reusing the drive
   ```bash
   # Destroy RAID info from the begining of the drive
   $ sudo dd if=/dev/zero of=/dev/sdX bs=512 count=2048

   # Destroy RAID info from the end of the drive
   $ sudo bash -c 'dd if=/dev/zero of=/dev/sdX bs=512 count=2048 seek=$((`blockdev --getsz /dev/sdX` - 2048))'
   ```

2. Partition the drive via `gdisk`
   ```bash
   $ sudo gdisk /dev/sdb
   # n to start create a new partition wizard
   # Accept default Partition number, hit enter
   # Accept defaults for First sector and Last sector
   # Accept default Hex code 8300 for Linux filesystem
   # w to write out the changes
   ```

3. To tell kernel about changes
   ```bash
   $ sudo partprobe /dev/sdb
   ```

4. Format drive for `ext4`
   ```bash
   $ sudo mkfs.ext4 /dev/sdb1
   ```

5. Tune the drive to use its full capacity
   ```bash
   # For storage only set reserved blocks which defaults to 5% to 0 as it is unneeded.  These
   # reserved blocks are only used as a security measure on boot disks to that system functions can
   # continue to operate correctly even if a user has stuffed the drive.
   $ sudo tune2fs -m 0 /dev/sdb1
   ```

6. [Automount using FSTAB](#add-automount-using-fstab)

## Clone Drive
```bash
# Kick off clone in one terminal
# conv=sync,noerror means in the case of an error ensure length of original data is preserved and don't fail
sudo dd if=/dev/sdX of=/dev/sdY bs=1M conv=sync,noerror

# Watch clone in another with
watch -n10 'sudo kill -USR1 $(pgrep ^dd)'
```

## Backup Drive
One of the simplest and least expensive ways to backup your data is to buy a single hot swappable 
bay and a couple of large drives. Then just load one in and copy your data as desired then pull it 
out and store it in an anti-static/shock proof caddy.

1. Load your drive into the hot swappable bay
2. Determine the device path with `lsblk`
3. [Format the storage drive if needed](#add-drive)
4. Mount your device using `noatime` to speed up transfers a bit
   ```bash
   $ sudo mount -o defaults,noatime /dev/sdd1 /mnt/backup
   ```
5. Ensure the drive and all its data is owned by your user
   ```bash
   $ sudo chown USER: -R /mnt/backup
   ```
6. Launch `FileZilla` or your transfer app of choice and copy your data over

## Securely Wipe Drive
To securely shred all data on a drive you can use the shred tool:
* `-v` - verbose output
* `-z` - add a final pass of zeros to hide shredding
* `-n` - number of shred passes default to 3

```bash
sudo shred -vzn 3 --random-source=/dev/urandom /dev/sdX
```

## RAID Drives
The standard URE rate of 1 in 10^14 failure in modern drives has made RAID 5 an almost 100% fail with
larger drives. RAID 6 although tolerable will also be too high a risk with larger drives.  The only
option for RAID is RAID 10 if you value your data.  Otherwise forget RAID and make regular backups.
Once configured partition and format like any other drive.

## Test Drive
Using the SMART monitor tools and the built in diagnostics in drives we can determine their health.
SMART offers two different tests, according to specification type. Each of these tests can be
performed in two modes:

* ***Background Mode*** - the priority of the test is low, which means the normal instructions can
continue to be processed. If the drive is doing real work the test gets paused and compelted when
it's no longer busy.
* ***Forground Mode*** - all commands will be answered during the test with a `CHECK_CONDITION`
status i.e. you only want to use this option if the hard disk is unmounted.

The `Short Test` provides rapid identification of a defective hard drive. It only takes a max of
`2min` and checks the disk by looking at `Electrical Properties`, `Mechanical Properties` and
`Read/Verify`. The read verify spot check is usually a specific area as called out by the
manufacturer.

The `Long Test` is similar to the short test but also dos a `Read/Verify` on the entire disk, not
just the spot check done in the short test.

```bash
# Install smart monitor tools
$ sudo pacman -S smartmontools

# Check that drive is smart capable - check the last couple lines of output
$ sudo smartctl -i /dev/sda
...
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

# Check the approximate time required to run the tests - look near bottom
$ sudo smartctl -c /dev/sda
...
Extended self-test routine
recommended polling time: 	 ( 333) minutes.
...

# Run short drive test in foreground
$ sudo smartctl -t short -C /dev/sda

# Run long test
# Note: captive forground doesn't seem to work
$ sudo smartctl -t long /dev/sda

# Show overall health check from tests once all tests have been run
$ sudo smartctl -H /dev/sda
...
=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

# Show specific test results, the latest test is #1 and so on
$ sudo smartctl -l selftest /dev/sda
...
=== START OF READ SMART DATA SECTION ===
SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short captive       Interrupted (host reset)      50%     30363         -
# 2  Extended offline    Completed without error       00%     30356         -
# 3  Extended offline    Aborted by host               90%         2         -
```

## Test USB Drive
1. Locate your drive with `lsblk`
   ```bash
   $ lsblk
   NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
   ...
   sdb      8:64   1   7.2G  0 disk 
   └─sdb1   8:65   1   3.8G  0 part 
   ```
2. Run `badblocks` against it
   ```bash
   $ sudo badblocks -w -s /dev/sdb
   ```
3. Test with f3
   ```bash
   # Install the f3 tools
   $ yay -Ga f3; cd f3; makepkg -s; sudo pacman -U f3-8.0-2-x86_64.pkg.tar.zst

   # Partition and format FAT32
   $ sudo wipefs --all --force /dev/sdd
   $ sudo sgdisk -n 0:0 -t 0:0700 -c 0:"flash" /dev/sdd
   $ sudo mkfs.vfat /dev/sdd1

   # Execute the tests on the automount location
   $ sudo f3write /run/media/USER/AB4C-86A3
   $ sudo f3read /run/media/USER/AB4C-86A3
   ```

# Time/Date
Time and dates are controlled on Arch Linux by  `timedatectl`

# Set Time/Date
```bash
# timedatectl set-time "yyyy-MM-dd hh:mm:ss"
sudo timedatectl set-time "2019-01-17 09:12:20"
```

# Troubleshooting

## GVFS Slow Start
Pretty much any GTK app that uses a file dialog especially Thunar and Handbrake were taking 20sec to
startup, but after the initial start ran fine. 

### libblockdev fix
By tailing the journal `journalctl -f` while I started `thunar` I was able to tell that it launched gvfs
which in turn launched `udisks2` which fails. Running `sudo systemctl status udisks2` shows that it
is failing with a symbol lookup error.
```
/usr/lib/udisks2/udisksd: symbol lookup error: /usr/lib/udisks2/udisksd: undefined symbol: bd_utils_check_linux_version
```

**Solution:**  
Removing `gvfs` and all its dependencies fixes the issue but I'd rather have that support.
Turns out that my version of `libblockdev` that I hacked to remove the `lvm` dependency was out of
date and causing this issue. Once updated to the latest `udisks2` starts up fine.

### xdg-desktop-portal
The [libblockdev fix](#libblockdev-fix) solved the `Thurnar` and `Kodi` issue I was seeing but I also
noticed that `evince` takes forever to start and saw tailing the logs with `journalctl -f` that I'm
also getting a failure to start the `xdg-desktopportal.service`.
```
xdg-desktop-portal.service: start operation timed out. Terminating
```

**Solution**:  
I removed flatpak which I'd been experimenting with:
``` bash
$ sudo pacman -Rns flatpak flatpak-builder
...
( 5/16) removing xdg-desktop-portal                                                  [------------------------------------------------] 100%
Removed /etc/systemd/user/sockets.target.wants/pipewire.socket.
( 6/16) removing pipewire                                                            [------------------------------------------------] 100%
...
```

# Users/Groups

## Add user
https://wiki.archlinux.org/index.php/users_and_groups#Example_adding_a_system_user

Add a user without a home directory or ability to login for running daemons
```bash
# e.g. useradd -r -s /usr/bin/nologin <username>
useradd -r -s /usr/bin/nologin teamviewer
```

## Rename user
1. Login using root
2. Rename user `usermod -l newname oldname`
3. Rename user home directory `mv /home/oldname /home/newname`
4. Change user home `usermod -d /home/newname -m newname`
5. Rename user group `groupmod -n newname oldname`

# VeraCrypt
VeraCrypt is the go forward fork of TrueCrypt providing virtual drives with encryption you can
safely store your data in. Many of the issues with the original TrueCrypt code audits have been
fixed.

Create a new ***100GB Volume***  
1. Install, run:   
  `sudo pacman -S veracrypt`
2. Create Encrypted Volume  
  a. Launch: `veracrypt`  
  b. Select ***Slot 1*** and hit ***Create Volume***   
  c. Select ***Create an encrypted file container*** and click ***Next***
  d. Select ***Standard VeraCrypt volume*** and click ***Next***  
  e. Click ***Select File...*** and choose e.g. ***~/.local/data*** and click ***Next***  
  f. Choose ***AES*** and ***SHA-512*** and click ***Next***  
  g. Set ***100 GB*** and click ***Next***  
  h. Set Password and click ***Next***  
  i. Choose ***I will not store files larger than 4GB on the volume*** and click ***Next***  
  j. Select ***Linux Ext4*** as the file system and click ***Next***
  k. Select ***I will mount the volume only on Linux*** and click ***Next***  
  l. Move mouse randomly then click ***Format***
3. Mount encrypted volume  
  a. Launch: `veracrypt`  
  b. Select ***Slot 1*** and click ***Select File...*** then select your data file  
  d. Click ***Mount*** then punch in your password and walla  
  c. Veracrypt will automatically create ***/mnt/veracrypt1*** as your mount point  
  d. Set ownership: `sudo chown -R phR0ze: /mnt/veracrypt1`  
4. Create home dir link `ln -sf /mnt/veracrypt1/Documents ~/Documents`  
5. Create a Thunar Shortcut  
  a. Browse to ***/mnt/veracrypt1*** and drag and drop it to ***Places***  
6. Configure autostart for veracrypt  
  `cp /usr/share/applications/veracrypt.desktop ~/.config/autostart`

# Window Manager
A window manager controls the placment and appearance of windows within a windowing system like X
Windows.

## Openbox
Openbox is a lightweight, powerful and highly configurable stacking window manager with extensive
standards support.

## XFWM

### XFCE Menu
Xfce's `xfdesktop` app will install a menu file
XFCE will read from the `~/.config/menus/xfce-applications.menu`

1. Create the menu directory
   ```bash
   $ mkdir -p ~/.config/menus
   $ mkdir -p ~/.local/share/applications
   ```
2. Copy the global menu there for editing
   ```bash
   $ cp /etc/xdg/menus/xfce-applications.menu ~/.config/menus
   ```

## wmctrl
CLI automation for working with X11 window managers

### Resize current window
You can resize the current window with `wmctrl` cli tool

Example:
```bash
wmctrl -r :ACTIVE: -b remove,maximized_horz,maximized_vert -e 0,0,0,1920,1080
```

* `-r :ACTIVE:` designates the current window
* `-b remove,maximized_horz,maximized_vert` remove restrictions that may impact a resize/move
* `-e 0,0,0,1920,1080` gravity usually zero, x, y, width, height

# X Windows
X Windows, X Window system, X11 or simply X is the most common windowing system in Linux.

## Icons
Icons are stored at `/usr/share/icons` with `hicolor` being the defaults.

### Refresh Icon Cache
Each icon theme e.g. `/usr/share/icons/hicolor` has a `/usr/share/icons/hicolor/icon-theme.cache` 
that appliations will use to view the available icons from that theme. If you add icons to the theme 
manually they will not show up in your icon viewers until the cache is updated.

Update the timestamp on the icon them directory then trigger the cache updater
```bash
$ touch /usr/share/icons/hicolor
$ sudo gtk-update-icon-cache /usr/share/icons/hicolor
```

## Persist X Configs
Linux has a plethera of ways to persist configuration depending on which system components your
using. I'm documenting here the components in use in ***cyberlinux*** and the recommended use based
on ordering and pros/cons of the technologies in play.

### Execution order
The order of execution from start to running desktop is as follows

1. The kernel starts `systemd` as the init process running as `PID 1`
2. [systemd](https://wiki.archlinux.org/title/systemd) is the ***init process*** and starts the rest
   of the system as shown by `systemd-analyze critical-chain`
   * file systems are mounted
   * networking is established
   * dbus is started
   * LXDM is started which starts Xorg first
3. [Xorg](https://wiki.archlinux.org/title/xorg) is the ***X Window System*** used to draw graphical
   widgets on the display and is started by LXDM as it is a dependency for LXDM to actually run. During
   startup X11 will take into account its configuration files found at:
   * `/etc/X11/xorg.conf.d`
4. [LXDM](https://wiki.archlinux.org/index.php/LXDM) is the ***Display Manager*** and will be
   displayed once it launches X Windows to then draw the login widgets on the display. After login
   via `systemd-logind` lxdm will source and/or executes the following in order:
   * `/etc/lxdm/Xsession` - not meant to be edited directly
   * `/etc/profile`
   * `~/.profile`
   * `/etc/xprofile`
   * `~/.xprofile`
   * `/etc/X11/Xresources`
   * `~/.Xresources`
   * `/etc/X11/Xkbmap`
   * `~/.Xkbmap`
   * `/etc/X11/Xmodmap`
   * `~/.Xmodmap`
   * `/etc/X11/xinit/xinitrc.d`
   * `~/.xsession`
   * `/usr/bin/lxsession`
5. [LXsession](https://wiki.archlinux.org/title/LXDE#Autostart) is the ***Session Manager*** and
   provides `XDG Autostart` support that executes the following before then running `Openbox`
   * `~/.config/autostart`
   * `/etc/xdg/autostart`
6. [Openbox](https://wiki.archlinux.org/title/Openbox) is the ***Window Manager*** and executes the
   [XDG Autostart](https://wiki.archlinux.org/title/XDG_Autostart) with dependency `python-pyxdg`
   then executes its own startup scripts as follows:

### X Configs
The best way to persist X11 configuration is by dropping in the appropriate changes into the
`/etc/X11/xorg.conf.d` directory. Each file there will be read in and applied in the order they are
found.

**Example:**
```
$ sudo cp /usr/share/nvidia-340xx/20-nvidia.conf /etc/X11/xorg.conf.d/10-nvidia.conf
```

### profile.d
The shell scripts in `/etc/profile.d` get sourced by `/etc/profile` when its sourced. This follows
the new granular drop in file pattern and is one of the best ways to add system boot configuration.
One thing to note is that the files are sourced in the context of the logged in user so `$HOME` will
be the user's home directory etc...

`/etc/profile` gets sourced by:
* login shells i.e ssh sessions and TTY sessions
* LXDM sessions i.e. Openbox and all X apps will inherit these environment values

**Exmple**:
```
export XDG_CONFIG_HOME="${HOME}/.config"
```

**WARNING:**  
The downside to this approach is that it gets read by login shells as well so you
don't want to include things here meant only for X11 sessions as it will be extra overhead.

**Recomendation:**  
Use this for environment configuration that you'd like present in your system regardless of the entry
point i.e. login shells or LXDM.

### xprofile
An [xprofile](https://wiki.archlinux.org/index.php/Xprofile) file `~/.xprofile` and `/etc/xprofile`
allow you to execute commands at the begining of the X user session before the window manager is
started as it is run by LXDM after X11 but before Openbox.

**WARNING:**  
Doesn't get read by login shells only via LXDM.

**Recomendation:**  
Use for configuration specific to X11 you want during your session and use `~/.profile` or
`/etc/profile.d` for configuration you want for all logins or LXDM entry points.

### Openbox Autostart
Openbox provides an autostart mechanism by:
1. Sourcing `/etc/xdg/openbox/environment`
2. Sourcing `~/.config/openbox/environment`
3. Executing `/etc/xdg/openbox/autostart`
4. Executing `~/.config/openbox/autostart`

**WARNING:**  
Openbox's autostart mechanism above doesn't work very well as it leaves an additional
shell process listed in the system processes in addition to the target application.

**Recommendation:**  
Use `~/.profile` and `/etc/profile.d` for environment configuration that you want in all cases i.e.
ssh sessions as well as Openbox and use `~/.xprofile` or `/etc/xprofile` for configuration you want
for your X11 Openbox session. `lxsession` provides an excellent mechanism implementing the `XDG Autostart`
specification and thus there is no need to use Openbox's autostart or environment configs at all.

### XDG Autostart
LXSession supports the `XDG Autostart` specification which calls out `/etc/xdg/autostart` and
`~/.config/autostart` as locations where you can store desktop files that will get executed at
startup.  Since timing/ordering of X components being started isn't guaranteed there may be UI
tearing in some cases. To avoid this you can sleep for a second or two before executing the target
app.

Note the use of the `exec` call to replace the bash process with conky to avoid having nested
parent processes visible with `ps -ef`
```
[Desktop Entry]
Type=Application
Exec=bash -c "sleep 2 && exec conky -c ~/.config/conky/active"
```
**LXDM Integration:**  
Integrating `LXDM` together with `lxsession` and `openbox` requires changing the LXDM session target
to `/usr/bin/lxsession -s default -e default` which will then load the configuration found at 
`/etc/xdg/lxsession/default`


---

<!-- 
vim: ts=2:sw=2:sts=2
-->
