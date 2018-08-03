# cyberlinux Personal Use Profile
<img align="left" width="48" height="48" src="https://raw.githubusercontent.com/phR0ze/cyberlinux/master/art/logo_256x256.png">
This profile uses applications with various restrictions and can not be used
for commercial purposes. It is only to be used for personal use only.

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***.

### Table of Contents
* [Desktop Deployment](#desktop-deployment)
* [Theater Deployment](#theater-deployment)
* [Server Deployment](#server-deployment)
* [Lite Deployment](#lite-deployment)
* [Shell Deployment](#shell-deployment)

### Desktop Deployment <a name="desktop-deployment"/></a>
The ***desktop*** deployment was created to serve as a full developer environment and daily runner.
It is an amalgam of most other deployment options. Although it is the heaviest of the deployments,
resource wise, it is still built with speed and efficiency in mind.

**Features:** 
* Development (vscode, go, ruby, python)
* File Sharing (NFS, Torrent, SFTP, FTP)
* Productivity and Office (libreoffice, pdfs)
* Virtual Machines and Containers (virtualbox, docker)
* Media Processing/Consumption (vlc, smplayer, mvp, handbrake, makemkv)

### Theater Deployment <a name="theater-deployment"/></a>
Xorg desktop environment focusing on media playback

### Server Deployment <a name="server-deployment"/></a>
The ***server*** deployment was created to serve as a light weight web and file server that would
be run on lower end headless hardware. It is built on top of teh ***lite*** deployment.

**Features:** 
* Web Server
    * Apache, PHP
* Telephony Engine
    * Asterisk
* File Sharing
    * NFS, Torrent, SFTP, FTP
* Media Processing
    * Handbrake, makemkv-cli

<a href="../doc/images/server-deployment.jpg"><img width="639" height="480" src="../doc/images/server-deployment.jpg"></a>

### Lite Deployment <a name="lite-deployment"/></a>
Slimmed down minimal Xorg desktop environment with selected light weight apps built on top of the
***Shell*** deployment.

**Features:**
* System
    * LXDM, OpenBox, Nitrogen, Thunar, Tint1
* Utilities
    * Galculater, GSimpleCal, File Roller, LXRandr, LXTerminal, PNMixer, PAVUControl, Xfce3 Screenshooter
* Nework
    * Chromium, Filezilla
* Media
    * Audacious, GPicView, SMPlayer, VLC, WinFF, XNViewMP
* Office
    * Evince, GVim, Leafpad

<a href="../doc/images/lite-deployment.jpg"><img width="639" height="480" src="../doc/images/lite-deployment.jpg"></a>

### Shell Deployment <a name="shell-deployment"/></a>
Intended as a full shell development environment the ***Shell*** deployment provides:

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

<a href="../doc/images/shell-deployment.png"><img width="639" height="480" src="../doc/images/shell-deployment.png"></a>
