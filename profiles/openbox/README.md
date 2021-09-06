cyberlinux openbox profile
[![license-badge](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
====================================================================================================

<img align="left" width="48" height="48" src="https://raw.githubusercontent.com/phR0ze/cyberlinux/master/art/logo_256x256.png">
The <b>cyberlinux openbox profile</b> provides a reference build with multiple highly opinionated
pre-configured deployments ready to install. All deployments in this profile use the ***OpenBox***
window manager and have been carefully crafted to be a light as possible without sacrificing
productivity and style.

### License restrictions
Some deployments in this profile may include applications licensed only for personal and are not free
to use for commercial purposes. In these cases the deployments have been clearly labeled as such to
avoid any confusion.

### Disclaimer
***cyberlinux*** and any of its components come with absolutely no guarantees or support of any kind.
It is to be used at your own risk. Any damages, issues, losses or problems caused by the use of
***cyberlinux*** or its components are strictly the responsiblity of the user and not the
developer/creator of ***cyberlinux***.

### Quick links
* [Desktop Deployment](#desktop-deployment)
* [Laptop Deployment](#laptop-deployment)
* [Theater Deployment](#theater-deployment)
* [Netbook Deployment](#netbook-deployment)
* [Lite Deployment](#lite-deployment)
* [Shell Deployment](#shell-deployment)
* [Base Deployment](#base-deployment)

### Desktop Deployment <a name="desktop-deployment"/></a>
The ***desktop*** deployment was created to serve as a full developer environment and daily runner.
It is an amalgam of most other deployment options. Although it is the heaviest of the deployments,
resource wise, it is still built with speed and efficiency in mind. It is built on top of the
***Lite*** deployment thus having all the new features below layered on top of the existing Lite
applications and configuration.

<a href="../doc/images/cyberlinux-deployment-02.jpg"><img width="820" height="480" src="../doc/images/cyberlinux-deployment-02.jpg"></a>

**Features:** 
* System
  * WPA Supplicant, guake, plank
* Utilities
  * Android Utils, Docker, VirtualBox, Cinnamon ScreenSaver, Conky
* Nework
  * Synergy
* Media
  * Gimp, SMplayer, Mvp, Handbrake, MakeMKV, Audacity, Brasero, DEVEDE, Avidemux, OpenShot,
  InkScape, Scribus, Asunder, Tiny Media Manager
* Office
  * LibreOffice, PDFMod
* Development
  * Visual Studio Code, Meld

### Lite Deployment <a name="lite-deployment"/></a>
Slimmed down minimal Xorg desktop environment with selected light weight apps built on top of the
***Shell*** deployment thus having all the new features below layered on top of the existing shell
applications and configuration.

<a href="../doc/images/lite-deployment.jpg"><img width="639" height="480" src="../doc/images/lite-deployment.jpg"></a>

**Features:**
* System
    * LXDM, OpenBox, Nitrogen, Thunar, Tint1
* Utilities
    * Galculater, GSimpleCal, File Roller, LXRandr, LXTerminal, PNMixer, PAVUControl, Xfce3 Screenshooter
* Nework
    * Chromium, FileZilla
* Media
    * Audacious, GPicView, SMPlayer, VLC, WinFF, XNViewMP
* Office
    * Evince, GVim, Leafpad

### Shell Deployment <a name="shell-deployment"/></a>
Intended as a full shell development environment

<a href="../doc/images/standard-shell.jpg"><img width="639" height="480" src="../doc/images/standard-shell.jpg"></a>

**Features:**
* Filesystem utilities
    * dosfstools, efibootmgr, gptfdisk, cdrkit, pkgfile, squashfs-tools
* Compression utilities
    * p6zip, tar, unrar, unzip, zip
* Networking utilities
    * curl, dnsutils, wget, rsync
* Development utilities
    * C, C++, Go, Ruby, Python
* System utilities
    * htop, iftop
