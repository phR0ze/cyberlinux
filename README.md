# cyberlinux
<img align="left" width="48" height="48" src="art/logo_256x256.png">
<b><i>cyberlinux</i></b> was designed to provide the unobtrusive beauty and power of Arch Linux as a fully
customized automated offline multi-deployment ISO. Using clean declarative yaml profiles,
cyberlinux is able to completely customize and automate the building of Arch Linux filesystems
which are bundled as a bootable ISO. Many common use cases are available as deployment options
right out of the box, but the option to build your own infinitely flexible deployment is yours
for the taking.

[![Build Status](https://travis-ci.org/phR0ze/cyberlinux.svg)](https://travis-ci.org/phR0ze/cyberlinux?branch=master)
[![Coverage Status](https://coveralls.io/repos/github/phR0ze/cyberlinux/badge.svg?branch=master&service=github)](https://coveralls.io/github/phR0ze/cyberlinux?branch=master&service=github)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***.

Additionally the pre-configured ***profiles*** and ***layers*** that exist in this repo are
purely for my own personal benefit and pull requests will be evaluated as such. I intend to make the
defaults generally useful but foremost it needs to be useful for my purposes. Pull requests aligning
with my desires will be accepted. Typically I would expect those looking to leverage this framework to
fork it and make their own configuration ***profiles***

### Table of Contents
* [Screen Shots](#screen-shots)
* [cyberlinux Profiles](#cyberlinux-profiles)
* [Deploy cyberlinux](#deploy-cyberlinux)
  * [Vagrant box deployment](#vagrant-box-deployment)
  * [Virtual box deployment](#virtual-box-deployment)
  * [Bare metal deployment](#bare-metal-deployment)
  * [Brown field deployment](#brown-field-deployment)
* [Configure cyberlinux](#configure-cyberlinux)
  * [Configure Backlight](#configure-backlight)
    * [HP ZBook 15 Display](#hp-zbook-15-display)
  * [Toggle Devices](#toggle-devices)
* [Roll your own cyberlinux](#build-cyberlinux)
* [cyberlinux-repo](#cyberlinux-repo)
* [Background](#background)
  * [Evolution](#evolution)
  * [My take on Arch](#my-take-on-arch)
  * [Distro requirements](#distro-requirements)
* [Contributions](#contributions)
  * [Git-Hook Version Increment](#git-hook-version-increment)
* [Licenses](#licenses)
* [cyberlinux help](#cyberlinux-help)

# Screen Shots <a name="screen-shots"/></a>
<a href="doc/images/cyberlinux-deployment-01.jpg"><img width="820" height="480" src="doc/images/cyberlinux-deployment-01.jpg"></a>
<a href="doc/images/cyberlinux-deployment-02.jpg"><img width="820" height="480" src="doc/images/cyberlinux-deployment-02.jpg"></a>

# cyberlinux Profiles <a name="cyberlinux-profiles"/></a>
[cyberlinux Profiles](profiles/README.md) provide a way to capture predefined system configurations
and turn them into ISO and Vagrant Box artifacts.  There are serveral predefined profiles to choose
from and the possibility of making endless more.

# Deploy cyberlinux <a name="deploy-cyberlinux"/></a>
***cyberlinux*** can be quickly deployed using the ***Bare metal***, a hypervisor like
***VirtualBox*** or via prebuilt ***Vagrant boxes***. Simply choose the pre-built artifact of your
choice either ***ISO*** or ***Vagrant Box*** and deploy at will. Additionally you could roll your
own artifacts usig [cyberlinux profiles](profiles/README.md).

## Vagrant box deployment <a name="vagrant-box-deployment"/></a>
Deploy [phR0ze/cyberlinux-standard-desktop](https://app.vagrantup.com/phR0ze/boxes/cyberlinux-standard-desktop) via a VM using a Vagrant Box

```bash
# Create a Vagrantfile describing the cyberlinux-desktop box to use
vagrant init phR0ze/cyberlinux-standard-desktop

# Download and deploy cyberlinux-standard-desktop box
vagrant up
```

## Virtual box deployment <a name="virtual-box-deployment"/></a>
Deploy ***cyberlinux*** via a VM using Virtual Box

1. Create a VM named ***cyberlinux-desktop*** with ***4GB RAM, 40GB HDD***  
2. Once created edit ***Settings***  
  a. Set ***System >Processor = 4***  
  b. Set ***Display >Video = 32***  
  c. Set ***Network >Bridged Adapter***  
  d. Set ***Storage >IDE Empty*** to ***cyberlinux-standard-0.2.208-4.18.1-x86_64.iso***  
  e. Click ***OK***  
2.	Once booted to the ISO choose the ***cyberlinux-desktop*** deployment option

## Bare metal deployment <a name="bare-metal-deployment"/></a>
Deploy ***cyberlinux*** via a USB directly onto a machine

1. Download the latest [***cyberlinux ISO***](https://github.com/phR0ze/cyberlinux/releases)
2. Burn the ISO to a USB via ***dd***  
    ```bash
    # Determine correct USB device
    sudo fdisk -l

    # Burn to USB
    sudo dd bs=4M if=~/cyberlinux-standard-0.2.208-4.18.1-x86_64.iso of=/dev/sdb status=progress oflag=sync
    ```
2. Burn the ISO to a USB via ***MultiWriter***  
    ```bash
    # Install MultiWriter
    sudo pacman -S gnome-multi-writer

    # Launch MultiWriter
    sudo gnome-multi-writer

    # Add the ISO and point it at your USB and click start  
    ```
3. Burn the ISO to a DVD via ***GrowISOFS***  
    ```bash
    # Navigate to temp location
    cd ~/Projects/cyberlinux/temp

    # Burn dvd
    growisofs -dvd-compat -Z /dev/sr0=images/cyberlinux-0.1.2-4.14.11-1-x86_64.iso
    ```
4. Boot from the USB and choose the ***cyberlinux-desktop*** deployment option

## Brown field deployment <a name="brown-field-deployment"/></a>
Using an existing arch linux system to deploy cyberlinux is more complicated as it requires a few
dependencies. I'll be documenting them here:

* cyberlinux-grub
* podman

# Configure cyberlinux <a name="configure-cyberlinux"/></a>

## Configure Backlight <a name="configure-backlight"/></a>
cyberlinux uses the ***https://aur.archlinux.org/packages/light/*** script to configure the
backlights.  ***Light*** is used directly in the ***~/.config/openbox/rc.xml*** config file.

```bash
# Increment backlight brightness by 10%
light -A 10

# Decrement backlight brightness by 10%
light -U 10
```

### HP ZBook 15 <a name="HP ZBook 15"/></a>
The ***HP ZBook 15*** laptop has hybrid graphics, using the intel chipset to conserve power and the
Nvidia discrete graphics for power. I've always run with this disabled and just used the discrete
graphics. However Linux doesn't create the backlight controls unless it is enabled thus generating
the desired ***/sys/class/backlight/intel_backlight*** files.

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

### HP ZBook 15 Display <a name="hp-zbook-15-display"/></a>
Using the ***toggle*** script I was able to get the external output to turn and off mirroring the
internal display at 1280x1024 resolution just fine when the laptop was started undocked.

Additionally if I enable the internal display before undocking I won't loose it after undocking
although I haven't tried the projector in this state.

I was unable to get the dock display to enable again after redocking until restarting in the docked
state although the internal display continued to work until restarted.

# Roll your own cyberlinux <a name="build-cyberlinux"/></a>
[See => profiles/README.md](https://github.com/phR0ze/cyberlinux/blob/master/profiles)

# cyberlinux-repo <a name="cyberlinux-repo"></a>

Key:
* **AUR** simply means the upstream aur package was built and added to this repo
* **Repackaged** indicates the upstream bits were customized and saved at `cyberlinux/aur/<package>`
* **Custom** indicates this package was wrote from scratch and saved at `cyberlinux/aur/<package>`

| Package                         | Version           | Purpose                
| ------------------------------- | ------------------| ------------------------------------------------------------------
| abiword-gtk2                    | 3.0.2.-3          | AUR: The non gtk2 one flickers, this one seems to be ok
| arch-install-scripts            | 22-2              | Repackaged: patched the arch-chroot to retry umount for reduce
| asterisk                        | 15.4.1-2          | Custom: asterisk telephony engine
| awf-git                         | v1.3.1.r4.gcee91. | ?
| bindip                          | 0.0.1-1           | ?
| ccextractor                     | 0.88-1            | AUR: dependency of makemkv
| chromium                        | 76.0.3809.100-4   | Custom: cyberlinux build of chromium with security enhancements
| chromium-widevine               | 1:4.10.1440.18-2  | AUR: Chromium dependency for viewing premium media content
| cinnamon-desktop                | 3.4.2-1           | Repackaged: support file for lockscreen
| cinnamon-screensaver            | 3.0.1-1           | Repackaged: keeping the old lockscreen behavior
| cinnamon-translations           | 3.4.2-1           | Repackaged: support file for lockscreen
| cri-tools                       | 1.11.1-2          | ?
| cyberlinux-config               | 0.0.3-1           | Custom: provides cyberlinux configuration files
| cyberlinux-desktop-config       | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-grub                 | 0.0.3-1           | Custom: provides cyberlinux splash screen and boot files
| cyberlinux-keyring              | 0.0.170-2         | Custom: provides cyberlinux keyring
| cyberlinux-laptop-config        | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-lite-config          | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-netbook-config       | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-plank                | 0.11.4-4          | Repackaged: modified the source with better defaults 
| cyberlinux-screenfetch          | 3.8.0-2           | Custom: cyberlinux screenfetch
| cyberlinux-server-config        | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-shell-config         | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-theater-config       | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-vim-plugins          | 0.0.2-1           | Custom: provides useful default vim plugins
| epson-inkjet-printer-escpr2     | 1.0.26-1          | AUR: Driver for the Epson WorkForce 7710 inkjet all-in-one printer
| galliumos-braswell-config       | 1.0.0-1           | AUR: Braswell configuration files for Samsung 3 Chromebook
| google-cloud-sdk                | 243.0.0-1         | ?
| helm                            | 2.14.0-1          | ?
| idesk                           | 0.7.5-8           | AUR: desktop icon support
| iksemel                         | 1.5-1             | AUR: FreeSWITCH dependency
| imagescan-plugin-networkscan    | 1.1.2-1           | AUR: Scanner driver for Epson WorkForce 7710 inject all-in-on printer
| input-wacom-dkms                | 0.39.0-1          | AUR: wacom input driver
| inxi                            | 3.0.36-2          | AUR: Low level cli tool for device configuration discovery
| jd-gui                          | 1.6.3             | Repackaged: patched with dark theme and java font fix
| kubeadm                         | 1.11.2-2          | ?
| kubecni                         | 0.7.2-2           | ?
| kubectl                         | 1.11.2-2          | ?
| kubelet                         | 1.11.2-2          | ?
| lib32-freetype2                 | 2.8-2             | ?
| lib32-nvidia-340xx-utils        | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| lib32-opencl-nvidia-340xx       | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| libblockdev                     | 2.22-2            | Repackaged: recompiled ABS with `--without-lvm` to remove the lvm2 dependency
| libxnvctrl-340xx                | 340.107-2         | Repackaged: provides libxnvctrl used by conky
| light                           | 1.1.2-1           | AUR: file size ui tool
| makemkv                         | 1.14.4-1          | Repackaged version making ccextractor a default dependency
| mkinitcpio-vt-colors            | 1.0.0-1           | Custom: provides kernel output coloring on boot
| numix-frost-themes              | 3.6.6-1           | ?
| nvidia-340xx                    | 340.107-92        | AUR: supports the Quadro FX 3800 and other older cards
| nvidia-340xx-dkms               | 340.107-92        | AUR: supports the Quadro FX 3800 and other older cards
| nvidia-340xx-settings           | 340.107-2         | AUR: supports the Quadro FX 3800 and other older cards
| nvidia-340xx-utils              | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| opencl-nvidia-340xx             | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| openvpn-update-systemd-resolved | 1.2.6-1           | ?
| paper-icon-theme                | 1.4.0-1           | ?
| php                             | 7.1.12-2          | ?
| php-apache                      | 7.1.12-2          | ?
| php-gd                          | 7.1.12-2          | ?
| php-sqlite                      | 7.1.12-2          | ?
| pjproject                       | 2.7-1             | ?
| pnmixer                         | 0.7.2-1           | ?
| postman-bin                     | 6.1.3-2           | ?
| powerline-gitstatus             | 1.3.1-1           | Custom: provides gitstatus in PS1 using powerline
| ruby-amatch                     | 0.4.0-1           | ?
| ruby-byebug                     | 11.0.0-1          | ?
| ruby-coderay                    | 1.1.2-3           | ?
| ruby-filesize                   | 0.2.0-3           | ?
| ruby-method\_source             | 0.9.2-3           | ?
| ruby-net-scp                    | 1.2.1-3           | ?
| ruby-net-sftp                   | 2.1.2-2           | ?
| ruby-net-sftp                   | 2.1.2-3           | ?
| ruby-net-ssh                    | 4.2.0-3           | ?
| ruby-nub                        | 0.1.2-1           | ?
| ruby-pry                        | 0.12.2-1          | ?
| ruby-pry-byebug                 | 3.7.0-1           | ?
| ruby-rest-client                | 2.0.2-3           | ?
| ruby-themoviedb                 | 1.0.1-1           | ?
| systemd-docker                  | 0.2.1-1           | ?
| teamviewer                      | 13.2.13582-1      | All-In-One Software for Remote Support and Online Meetings
| termcap                         | 1.3.1-6           | ?
| tiny-media-manager              | 2.9.16-1          | AUR: Kodi compatible media manager
| ttf-google-fonts-fun            | 1.0.0             | Repackaged: some of the script and sans serif fun fonts
| ttf-google-fonts-work           | 1.0.0             | Repackaged: includes the same fonts as typewolf did
| ttf-inconsolata-g               | 20090213-3        | AUR: excellent mono space coding font
| ttf-ms-fonts                    | 2.0-10            | AUR: old venerable Microsoft fonts
| ttf-nerd-fonts-symbols          | 2.0.0-2           | AUR: font symbols useful for powerine etc...
| vdhcoapp-bin                    | 1.3.0-2           | Repackaged: Video Download Helper's companion app, simply bumped the version
| virtualbox-ext-oracle           | 6.0.4-1           | AUR: extensions for virtualbox
| visual-studio-code-bin          | 1.34.0-2          | AUR: excellent development IDE
| vivaldi                         | 2.5.1525.48-1     | An advanced browser made with the power user in mind
| vpnctl                          | 0.0.62-1          | ?
| vundle                          | 0.10.2-2          | ?
| winff                           | 1.5.5+f721e4d-1   | AUR: GUI for ffmpeg
| wpa\_gui                        | 2.6-1             | Custom: A Qt frontend to wpa\_supplicant
| xcursor-numix-frost             | 0.9.9-4           | Custom: X-Cursor theme for use with numix products
| xnviewmp                        | 0.89-1            | AUR: An efficient multimedia viewer, browser and converter
| zoom                            | 2.8.252201.0616-1 | AUR: Video Conferencing and Web Conferencing Service

# Background <a name="background"></a>
***cyberlinux*** is an evolution of an idea come to fruition.  The origin was the need for an
automated installer that would be able to install a completely pre-configured and ready to use
system customized for a handful of common use cases (e.g. desktop, theater, server...) in an offline
environment. As time passed the need for simpler maintainability and access to larger more
up-to-date software repositories drove the search for the ideal Linux distribution.

### Evolution <a name="evolution"></a>

**Ubuntu Online Install**  
In the beginning I would deploy a super lightweight Ubuntu server system and then launch a custom
python script that would automate installing all packages and configuration settings I desired on
the new system.  This unfortunately required an internet connection and that my package sources,
many of which were outside Ubuntu's repositories, persist at the same location over an extended
period of time.  This method was slow, and fraught with network failures and missing online
packages as maintainers came and went.

**CentOS Offline Install**  
My next attempt was to use CentOS and Kickstart to develop an ISO with all the packages stored on
an ISO.  This solved my offline issues and gave a consistent versioning for packages, but still
took a long time to install and didn't allow for much in the way of pre-build or post install
configuration.  Additionally CentOS is notoriously behind the times and packages are difficult to
find or simply don't exist. Additionally building newer packages on the old CentOS tool chains
proved difficult and impossible in some cases where they required newer dependencies.

**Manjaro Offline Install**  
About this time I started looking for distribution that provided modern packages and tooling and
found Arch.  Being intimidated by Arch's install process though I moved on to Manjaro as the next
best thing and fell in love with ***manjaroiso*** and ***Thus*** as the means to develop my own
offline ISO with pre/post install configuration changes.  This seemed to solve most of my problems.
I now had offline install capabilities, latest versioned packages available and the ability to make
some small pre/post install changes.  However it didn't allow for custom applications for different
deployment options without heroic effort.  As time passed I found I was making more and more changes
to ***Thus***, the installer, and other installation aspects other than what was allowed for with
Manjaro's current tool set at the time. I soon realized that I had evolved my use of Manjaro so far
beyond its original purpose that consuming updates from upstream Manjaro and other tasks were
becoming complicated and tedious.  Additionally I was more and more envious of pure Arch Linux and
the goodness that was available by staying close to the source and began looking at Arch Linux
directly.

**Arch Offline Install**  
I really like Manjaro as per above and it took me far down the road I wanted to go. I began to
discover however that the parent distro, Arch Linux, had far greater market acceptance and thus more
community repositories and more pre-built AUR packages. I quickly found that the custom AUFS kernel
and different processes that Manjaro was using meant I couldn't leverage the greater Arch Linux
community packages easily. At this point I realized that I'd already moved far beyond the original
issue I had with Arch of no installer and so it was a natural progression to switch my distribution
from Manjaro to be based directly on Arch Linux. This made BlackArch and Antergos repos directly
available and put me in a bigger support community with newer updates and packages.

### My take on Arch <a name="my-take-on-arch"></a>
***Arch Linux kills!*** I've never used a distribution as simple, clean and easy to use as Arch. The
packages are plentiful, up-to-date and easily managed. The community is huge and active, providing
almost every package known to man in the Arch User Repository or you can easily build your own
packages with little effort. The kernel and tooling is modern, maintenance is easy and rolling
updates make for a system that can be used forever with little effort. Best of all though is that
the Arch Install process provides simple building blocks that lend themselves easily to custom
filesystem creations that in turn is readily turned into ISOs and other install media. Because of
the large community and plethera of distros based off Arch there are many ideas to leverage such
as the following:

**BlackArch** - https://blackarch.org  
BlackArch is a penetration testing distro based directly off Arch and is 100% compatible with Arch.
One of the main reasons I'm moving off Manjaro to pure Arch is to get access to BlackArch's
repository of penetration testing tools.

**Manjaro** - http://manjaro.org/get-manjaro  
Manjaro is an Arch split-off distro which used to have a really nice OpenBox deployment that suited
my needs quite well.  They have since dropped the OpenBox deployment but their distribution is still
one of the best distros out there and have a great community which adds to Arch's appeal with a
little adaptation. The main draw back with Manjaro is that that it can't leverage the Arch repos as
is due to their differences.

**ArchBang** - http://bbs.archbang.org  
ArchBang caught my eye because they are devoted to using lite components like OpenBox, LXTerminal,
VolumeIcon, LXAppearance, etc... They have a great community and a lot of good ideas and
configuration for keeping your system lite.

**Antergos** - http://antergos.com  
Antergos is based on Arch and 100% compatible but also has a few developments of its own, like its
slick custom isolinux boot and installer.  They also offer a number of prebuilt AUR packages in
their custom repos.

### Distro requirements <a name="distro-requirements"></a>
I boiled down my requirements for ***cyberlinux*** as follows:

* Single configuration file (i.e. profile) to drive ISO creation
* ISO must include all packages, config etc... (i.e. works offline)
* Boot splash screen shown with multi-deployment options
* Fast, simple automated installs with abosolute minimal initial user input
* Fully pre-configured user environments to avoid post-install changes
* Live boot option for maintenance, rescue and secure work
* Hardware boot and diagnostics options e.g. RAM validation
* As light as possible while still offering an elegant solution

## Contributions <a name="contributions"/></a>
Pull requests are always welcome.  However understand that they will be evaluated purely on whether
or not the change fits with my goals/ideals for the project.

### Git-Hook Version Increment <a name="git-hook-version-increment"/></a>
Enable the githooks to have automatic version increments

```bash
cd ~/Projects/cyberlinux
git config core.hooksPath .githooks
```

## Licenses <a name="licenses"/></a>
Because of the nature of ***cyberlinux*** any licensing will be of a mixed nature.  In some cases as
called out below such as ***reduce*** and the ***boot/initramfs/installer***, created by phR0ze, the
license is MIT. In other cases works i leveraged from else where using licenses such as GPLv2.

### ART works
All art works used in the distribution have been carefully selected to be either creative commons,
public domain, have permission from the original authors, or lay claim on fair use licensing. If for
some reason a licensing mistake has been made please let me know and I'll review the claim immediately.

### Reduce, build and Install Scripts
***reduce*** and all Ruby code related to it is licensed below via MIT additionally the
boot/initramfs/installer bash code base is likewise MIT licensed.

MIT License
Copyright (c) 2017-2018 phR0ze

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

# cyberlinux help <a name="cyberlinux-help"/></a>
cyberlinux is just a custom version of Arch Linux these guides will usually work word for word on
either system.

* [Apps to use](#apps-to-use)
* [BlackArch Signature issue](#blackarch-signature-issue)
* [Certificates](#certificates)
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
* [Display Manager](#display-manager)
  * [LXDM](#lxdm)
    * [xprofile](#xprofile)
* [Containers](#containers)
  * [Podman](#podman)
    * [Migrate from Docker](#migrate-from-docker)
  * [Build container](#build-container)
  * [Run container](#run-container)
  * [Upload container](#upload-container)
  * [Build cyberliux container](#build-cyberlinux-container)
* [Grub](#grub)
  * [Boot Kernel](#boot-kernel)
    * [BIOS Boot](#bios-boot)
    * [UEFI Boot](#uefi-boot)
  * [Boot Resolution](#boot-resolution)
* [Fonts](#fonts)
  * [Distro Fonts](#distro-fonts)
  * [Fontconfig](#fongconfig)
  * [Manually Install Fonts](#manually-install-fonts)
* [Kernel](#kernel)
  * [Switch Kernel](#switch-kernel)
* [Launchers](#launchers)
  * [Plank](#plank)
* [Media](#media)
  * [Convert Images](#convert-images)
    * [Convert HEIC to JPEG](#convert-heic-to-jpeg)
  * [Screen Recorder](#screen-recorder)
* [Mount](#mount)
  * [Mount Busy](#mount-busy)
    * [fuser](#fuser)
  * [Add Automount using FSTAB](#add-automount-using-fstab)
* [Network](#network)
  * [Bind to NIC](#bind-to-nic)
  * [Configure Multiple IPs](#configure-multiple-ips)
  * [SSH Port Forwarding](#ssh-port-forwarding)
  * [Nameservers](#nameservers)
    * [See Current DNS](#see-current-dns)
    * [Configure DNS](#configure-dns)
    * [Quad9 DNS](#quad9-dns)
    * [Cloudflare DNS](#cloudflare-dns)
    * [Google DNS](#google-dns)
    * [DNSSEC Validation Failures](#dnssec-validation-failures)
  * [Networking DHCP](#networking-dhcp)
  * [Networking Static](#networking-static)
  * [Networking Wifi](#networking-wifi)
  * [NFS Shares](#nfs-shares)
    * [NFS Client Config](#nfs-server-config)
    * [NFS Server Config](#nfs-server-config)
  * [File Sharing](#file-sharing)
* [Office](#office)
  * [LibreOffice](#libreoffice)
    * [Config Navigation](#config-navigation)
    * [Keyboard Shortcuts](#keyboard-shortcuts)
    * [Set Default Template](#set-default-template)
    * [Turn off Smart Quotes](#turn-off-smart-quotes)
    * [Turn off Replace Dashes](#turn-off-replace-dashes)
    * [Turn off Automatic Strikeout](#turn-off-automatic-strikeout)
    * [Repeatable Config](#repeatable-config)
  * [PDFs](#pdfs)
    * [Combine PDFs](#combine-pdfs)
    * [Convert Images to PDF](#convert-images-to-pdf)
* [Packages](#packages)
  * [Init Database](#init-database)
  * [Update Mirrorlist](#update-mirrorlist)
* [Patching](#patching)
  * [Create Patch](#create-patch)
  * [Apply Patch](#apply-patch)
* [Remoting](#remoting)
  * [Synergy](#synergy)
  * [Teamviewer](#teamviewer)
  * [Zoom](#zoom)
* [Rescue](#resuce)
  * [Switch to TTY](#switch-to-tty)
  * [Graphical Target](#graphical-target)
    * [Check Xorg logs](#check-xorg-logs)
    * [Reset Xorg settings](#check-xorg-settings)
    * [Opensource Driver](#opensource-driver)
  * [Unable to Login](#unable-to-login)
    * [Try logging in while tailing the logs](#try-logging-in-while-tailing-the-logs)
    * [Try running openbox directly](#try-running-openbox-directly)
    * [Try reinstalling the target video driver](#try-reinstallig-the-target-video-driver)
  * [Boot from Live USB](#boot-from-live-usb)
  * [Black Screen](#black-screen)
  * [Check Logs for Errors](#check-logs-for-errors)
* [Sesion](#session)
  * [XDG Autostart](#xdg-autostart)
    * [Exec Script](#exec-script)
* [Storage](#storage)
  * [Add Drive](#add-drive)
  * [Clone Drive](#clone-drive)
  * [Shred Drive](#shred-drive)
  * [Wipe Drive](#wipe-drive)
  * [RAID Drives](#raid-drives)
  * [Test Drive](#test-drive)
* [System](#system)
  * [Shell](#shell)
    * [Powerline](#powerline)
  * [System Update](#system-update)
  * [Systemd Boot Performance](#systemd-boot-performance)
    * [See How long boot takes](#see-how-long-boot-takes)
    * [Rank services by startup time](#rank-services-by-startup-time)
    * [Remove lvm2 service](#remove-lvm2-service)
  * [Systemd Debug Shell](#systemd-debug-shell)
* [Time/Date](#time-date)
  * [Set Time/Date](#set-time-date)
* [Users/Groups](#users-groups)
  * [Add user](#add-user)
  * [Rename user](#rename-user)
* [VeraCrypt](#veracrypt)
* [VPNs](#vpns)
  * [OpenConnect](#openconnect)
* [Wine](#wine)
  * [Config Wine](#config-wine)
  * [Config Prefix](#config-prefix)

# Arch Linux Help <a name="arch-linux-help"/></a>
The [arch wiki](https://wiki.archlinux.org/) is the best place to go for help. I've just collected a
few things here that were useful for me here for quick reference.

# Apps to use <a name="apps-to-use"/></a>
[List of apps to use from Arch Linux Wiki](https://wiki.archlinux.org/index.php/List_of_applications/Utilities)

# BlackArch Signature issue <a name="blackarch-signature-issue"/></a>
To fix the issue below delete ***/var/lib/pacman/sync/*.sig***

Example: 
```
error: blackarch: signature from "Levon 'noptrix' Kayan (BlackArch Developer) <noptrix@nullsecurity.net>" is invalid
error: failed to update blackarch (invalid or corrupted database (PGP signature))
error: database 'blackarch' is not valid (invalid or corrupted database (PGP signature))
```
# Certificates <a name="certificates"/></a>

## Add Root CA <a name="add-root-ca"/></a>
```bash
# Download certs
wget --no-check-certificate -P ~/Downloads https://example.com/CAs/CA1.zip

# Unzip cert and rename to crt
unzip CA1.zip && rename CA1.cer CA1.crt

# Install new CA cert, original file can then be deleted
sudo trust anchor CA1.crt
```

# Develop <a name="develop"/></a>

## Git <a name="git"/></a>
Common git config across repos

```bash
cd ~/Projects/cyberlinux
git config --global user.email <email address>
git config --global user.name phR0ze
git config --global push.default simple
git config core.hooksPath .githooks
```

## Rewrite Git History <a name="rewrite-git-history"/></a>
Hammer to rewrite committer and author for all history

```bash
git filter-branch -f --env-filter \
"GIT_AUTHOR_NAME='NEW_USER'; GIT_AUTHOR_EMAIL='NEW_USER@EXAMPLE.COM'; \
GIT_COMMITTER_NAME='NEW_USER'; GIT_COMMITTER_EMAIL='NEW_USER@EXAMPLE.COM';" HEAD

git push origin -f
```

## Github Personal Access Tokens <a name="github-personal-access-tokens"/></a>
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

# Devices <a name="devices"/></a>

## Android <a name="android"/></a>
Configure minimal android support on your cyberlinux box

```bash
# Install dependencies
$ sudo pacman -S android-tools android-udev libmtp

# Add user to adbusers group
$ sudo gpasswd -a <user> adbusers

# Logout and back in or
$ su - <user>
```

## Display <a name="display"/></a>

### Adapt Output Toggle <a name="adapt-output-toggle"/></a>
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

### Dual Output <a name="dual-output"/></a>
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

### VGA Output <a name="vga-output"/></a>
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

### Quadro FX 880M <a name="quadro-fx-880m"/></a>
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

# Reboot
$ sudo reboot
```

### Quadro FX 3800 <a name="quadro-fx-3800"/></a>
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

# Reboot
$ sudo reboot
```

### Nvidia Proprietary <a name="nvidia-proprietary"/></a>
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

### Overscan/Underscan <a name="overscan-underscan"/></a>
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

## Mouse <a name="mouse"/></a>

### Configure Mouse Speed <a name="configure-mouse-speed"/></a>
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

### Configure Mouse Scroll <a name="configure-mouse-scroll"/></a>
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

## Keyboard <a name="keyboard"/></a>

### Configure Keyboard Rate <a name="configure-keyboard-rate"/></a>
Set this in your `~/.xprofile`
```bash
# First number is after how many ms the key will start repeating
# Second number is how many repititions per second, so after 190ms will output 40 a sec
xset r rate 200 40
```

### Disable Numlock on Boot <a name="disable-numlock-on-boot"/></a>
LXDM has a nice configuration setting allowing you to enable or disable numlock on boot.

1. Edit `/etc/lxdm/lxdm.conf`
2. Set `numlock=0` to disable

## Printer <a name="printer"/></a>
Any printer will require the default CUPS installation

```bash
# First install the CUPS open source printer solution
$ sudo pacman -S cups-pdf system-config-printer

# Start the CUPS service
$ sudo systemctl enable org.cups.cupsd
$ sudo systemctl start org.cups.cupsd

# Ensure your user is part of the 'lp' group
$ groups
```

### Workforce WF-7710 <a name="printer-workforce-wf-7710"/></a>
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

### Pending - Out of Paper <a name="pending-out-of-paper"/></a>
The printer driver got stuck after one failed print and continually reported the printer was out of
paper. Opening the `Printer Preferences` i.e. `system-config-printer` app showed a yellow caution
overlay indicating the problem. I right clicked on it and set it to `enabled` and double clicked to
establish a connection and it started working after that.

## Scanner <a name="scanner"/></a>
https://wiki.archlinux.org/index.php/SANE

SANE is the defacto standard in the Linux community for scanning software.

```bash
# Install
$ sudo pacman -S sane

# Test if your scanner is reconized by SANE
$ scanimage -L
```
### Workforce WF-7710<a name="scanner-workforce-wf-7710"/></a>

Slow detection black list devices:
```bash
# Firt time i detected devices
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

Working throught the driver install process:
```bash
# Install imagescan
$ sudo pacman -S imagescan

# Download and install the AUR package 
$ yaourt -S imagescan-plugin-networkscan

# Now edit `/etc/utsushi/utsushi.conf`
# In the [devices] delete everything also delete the entire [devices.mfp1] if it exists
# Add the following looking up the actual IP address from your printer.
# wf7710.udi = esci:networkscan://<ip-address-here>:1865
# wf7710.vendor = EPSON
# wf7710.model = WF-7710
```

Scan a black and white document:
1. Launch the scanner with `utsushi`
2. Set `Scan Area` to `Letter/Portrait`
3. Set `Resolution` to `150`
4. Set `Image Type` to `Grayscale`
5. Click `Scan` and choose the pdf destination

## Sound <a name="sound"/></a>
https://wiki.archlinux.org/index.php/PulseAudio/Troubleshooting#Simultaneous_output_to_multiple_sound_cards_/_devices

1. Install: `sudo pacman -S paprefs`
2. Click the `Simultaneous Output` tab
2. Check `Add virtual output device for simultaneous output on all local sound cards`

# Display Manager <a name="display-manager"/></a>
https://wiki.archlinux.org/index.php/Display_manager

A display manager manager is typically a graphical user interface that is displayed at the end of the
boot process in place of the default shell. Cyberlinux is uses systemd and symlinks `lxdm` to the
`display-manager.service` using `sudo systemctl enable lxdm`. LXDM works in conjunction with the
systemd service `systemd-logind` managed with `loginctl`.

## LXDM <a name="lxdm"/></a>
[LXDM](https://wiki.archlinux.org/index.php/LXDM) is a lightweight display manager for the LXDE
desktop environment. I'm using it in cyberlinux because it lightweight, although I've been eying
LightDM.

### xprofile <a name="xprofile"/></a>
An [xprofile](https://wiki.archlinux.org/index.php/Xprofile) file `~/.xprofile` allows you to
execute commands at the begining of the X user session before the window manager is started.

I'm using this in cyberlinux to setup a few minor Xorg settings at login

The following display managers natively source it at the right time:
* GDM
* LightDM
* LXDM
* SDDM

# Containers <a name="containers"/></a>

## Podman <a name="podman"/></a>
Podman replaces the docker cli and docker daemon with a cli that emulates the docker cli but calls
the registry etc... directly via `runC` rather than using a go between daemon as docker does. This
has all kinds of advantages, one being not daemon running in the background consuming resources on
development machines.

### Migrate from Docker <a name="migrate-from-docker"/></a>
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
3. Install podman and configure uids/gids to use for containers:
   ```bash
   # Install podman
   $ sudo pacman -S podman buildah

   # Create and set the uid/gid mappings for containers
   $ sudo touch /etc/subuid
   $ sudo touch /etc/subgid
   $ sudo usermod --add-subuids 10000-65536 <user>
   $ sudo usermod --add-subgids 10000-65536 <user>

   $ reboot
   ```

## Build container <a name="build-container"/></a>
From the directory that contains your ***Dockerfile*** run:

```bash
$ podman build -t alpine-base:latest  .
```

## Run container <a name="run-container"/></a>
```bash
$ podman run --rm -it alpine-base:latest bash
```

## Upload container <a name="upload-cyberlinux-container"/></a>
1. Build and deploy a cyberlinux container see [Build cyberlinux container](#build-cyberlinux-container)
2. List out your docker images: `podman images`
3. Login to dockerhub.com: `podman login`
4. Tag and push the versioned and latest tags
  ```bash
  # Tag and push the versioned image
  $ podman tag net-0.2.197:latest phr0ze/cyberlinux-net:0.2.197
  $ podman push phR0ze/cyberlinux-net:0.2.197

  # Tag and push the latest image
  $ podmane tag net-0.2.197:latest phr0ze/cyberlinux-net:latest
  $ podman push phr0ze/cyberlinux-net:latest
  ```

## Build cyberlinux container <a name="build-cyberlinux-container"/></a>
Build, deploy and run a cyberlinux container

```bash
# Build net container
$ sudo ./reduce clean build -d net -p containers

# Deploy net container to local docker
$ sudo ./reduce deploy net -p containers

# Run net container with docker
$ podman run --rm -it net-0.2.197:latest bash
```

# Grub <a name="Grub"/></a>
I was using syslinux as my go to bootloader as it is so simple and liteweight, but found that grub
handled install splash screens and menus better and the transition from gfx to xorg better.

## Boot Kernel <a name="boot-kernel"/></a>
When BIOS is used the boot grub config ends up in `/boot/grub/grub.cfg` where as on an EFI system the
grub boot files are stored on the ESP mount point.

You can tell which your system is simply by looking at the partitions on your disk:
```bash
# As we see below the 'EFI System' is the EFI partition that contains the bootloader and
# bootloader configuration.
$ sudo fdisk -l
...
Device         Start      End  Sectors  Size Type
/dev/mmcblk0p1  2048    22527    20480   10M EFI System
/dev/mmcblk0p2 22528 30777310 30754783 14.7G Linux filesystem
```

### BIOS Boot <a name="bios-boot"/></a>
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

### UEFI Boot <a name="uefi-boot"/></a>
System like the Samsung Chromebook 3 boot in UEFI mode which reads the bootloader from the boot
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

## Boot Resolution <a name="boot-resolution"/></a>
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

# Fonts <a name="fonts"/></a>
https://wiki.archlinux.org/index.php/fonts

## Xorg Fonts <a name="xorg-fonts"/></a>

## Fontconfig <a name="fontconfig"/></a>
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

### Replace or Set Defaut Fonts <a name="replace-or-set-default-fonts"/></a>
```xml
...
 <match target="pattern">
   <test qual="any" name="family"><string>georgia</string></test>
   <edit name="family" mode="assign" binding="same"><string>Ubuntu</string></edit>
 </match>
...
```

### Font paths <a name="font-paths"/></a>
Fontconfig recogizes the following font paths and scans them recursively:
* `/usr/share/fonts`
* `~/local/share/fonts`

List out existing fonts known to Fontconfig
```bash
$ fc-list : file
```

### Font Presets <a name="font-presets"/></a>
Font presets are installed in the directory `/etc/fonts/conf.avail` and can be enabled by creating
symbolic links to them in the `/etc/fonts/conf.d` directory.

### Font Anti-aliasing <a name="font-anti-aliasing"/></a>

### Font Hinting <a name="font-hinting"/></a>

### Font Autohinter <a name="font-auto-hinter"/></a>

### Subpixel Rendering <a name="subpixel-rendering"/></a>
Subpixel rendering a.k.a. `ClearType` is covered by Microsoft patents and **disabled** by default on
Arch Linux. To enable it, you have to use the `freetype2-cleartype` AUR package.

## Manually Install Fonts <a name="manually-install-fonts"/></a>
1. Copy fonts to `/usr/share/fonts`
2. Set permissions to at least `0444` for files and `0555` for directories
3. Update font cache: `fc-cache`

## Distro Fonts <a name="distro-fonts"/></a>
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

## Conky Fonts <a name="conky-fonts"/></a>
Conky will need to be restarted to pick up new fonts

# Kernel <a name="kernel"/></a>
## Switch Kernel <a name="switch-kernel"/></a>
1. Install the target kernel
   ```bash
   $ sudo pacman -S linux-lts linux-lts-headers
   ```
2. Update the boot loader config to point to the correct kernel
   ```bash
   $ sudo vim /boot/grub/grub.cfg
   # Modify the `vmlinuz-linux` and `initramfs-linux` to use
   # `vmlinuz-linux-lts` and `initramfs-linux-lts`
   $ sudo reboot
   ```
3. Update the bootloader to point to the target kernel
   ```bash
   # Edit: vim /boot/grub/grub.cfg
   # linux /boot/vmlinuz-linux root=LABEL=cyberlinux rw rd.systemd.show_status=auto rd.udev.log_priority=3 ipv6.disable=1
   # initrd /boot/intel-ucode.img /boot/initramfs-linux.img
   $ cat /boot/grub/grub.cfg
   # linux /boot/vmlinuz-linux-lts root=LABEL=cyberlinux rw rd.systemd.show_status=auto rd.udev.log_priority=3 ipv6.disable=1
   # initrd /boot/intel-ucode.img /boot/initramfs-linux-lts.img
   $ sudo reboot
   ```

# Launchers <a name="launchers"/></a>
## Plank <a name="plank"/></a>
Plank can be configured via the `dconf-editor`

1. Launch `dconf-editor`
2. Navigate to `net/launchpad/plank/docks/dock1`
3. Flip switches as desired

# Media <a name="media"/></a>

## Convert Images <a name="convert-images"/></a>
### Convert HEIC to JPEG <a name="convert-heic-to-jpeg"/></a>
Image conversions are easily done with `imagemagick`
```bash
# Install imagemagick
$ sudo pacman -S imagemagick

# Convert all heic pix to jpeg
$ mogrify -format jpg *.heic

# Delete the original heic files
$ rm *.heic
```

## Screen Recorder <a name="screen-recorder"/></a>
The two best are ***SimpleScreenRecorder*** and ***RecordMyDesktop***

1. Install: `sudo pacman -S simplescreenrecorder`
2. Launch: `simplescreenrecorder`
3. Click ***Continue***
4. Click ***Record a fixed rectangle*** then ***Select window...***
5. Click the content area of the window to be recorder to only record the content
6. Uncheck ***Record cursor***
7. Uncheck ***Record audio***
8. Click ***Continue***
9. Click ***Browse*** to choose a file to record as
10. Choose ***Preset*** as ***faster***
11. Click ***Continue***
12. Click ***Start Recording***

# Mount <a name="mount"/></a>

## Mount Busy <a name="mount-busy"/></a>
How do you deal with a mount point that is busy e.g.

`umount: cyberlinux/temp/work/deployments/shell/dev: target is busy.`

### lsof <a name="lsof"/></a>
See the open files for the given mount path

`lsof <mount path that is busy>`

### fuser <a name="fuser"/></a>
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

## Add Automount using FSTAB <a name="add-automount-using-fstab"/></a>
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
# Remove boot device from the list
# Use: UUID=ba6619b0-c3a6-493e-92f0-14bf313d15a3 /mnt/storage1 ext4 defaults,noatime,nodiratime 0 0
$ sudo vim /etc/fstab

# Manually mount
$ sudo mount -a

# Set ownership if needed
$ sudo chown -R phR0ze: /mnt/storage1 /mnt/storage2
```

# Network <a name="network"/></a>
https://wiki.archlinux.org/index.php/Systemd-networkd#Basic_usage

## Bind to NIC <a name="bind-to-nic"/></a>
Many Linux apps will by default bind to all available network interfaces. This is a nightmare for
end users that want control of which nics are used. To get around this many techniques have been
developed to replace code at runtime using LD_PRELOAD shims to inform the dynamic linker to first
load all libs into the process that you want then add some more.

```bash
# Compile code
wget http://daniel-lange.com/software/bind.c -O bindip.c
gcc -nostartfiles -fpic -shared bindip.c -o bindip.so -ldl -D_GNU_SOURCE

# Install binary
strip bindip.so
sudo cp bindip.so /usr/lib/

# Check existing binding of teamviewer
netstat -nl | grep 5938
tcp        0      0 0.0.0.0:5938            0.0.0.0:*               LISTEN     

# Edit teamviewer unit and add teh new start up line below
sudo systemctl stop teamviewerd
sudo sed -i -e 's|^\(PIDFile=.*\)|\1\nEnvironment=BIND_ADDR=10.33.234.133 LD_PRELOAD=/usr/lib/bindip.so|' /usr/lib/systemd/system/teamviewerd.service
sudo systemctl daemon-reload
sudo systemctl start teamviewerd

# Check resulting binding
netstat -nl | grep 5938
tcp        0      0 10.33.234.133:5938      0.0.0.0:*               LISTEN     
```

## Configure Multiple IPs <a name="configure-multiple-ips"/></a>
In Linux its easy to add more than one ip address to a given NIC. But if your service binds to all
NICs then your not going to get an open port, use [Bind to NIC](#bind-to-nic) to limit the service
to a specific IP address then create another to forward ports to.

```bash
# Add an address to your NIC
sudo tee -a /etc/systemd/network/20-dhcp.network <<EOL

[Address]
Address=192.168.0.1/24
[Address]
Address=192.168.0.2/24
EOL

# Restart networking for it to take affect
sudo systemctl restart systemd-networkd

# Check new IPs exist
ip a
# inet 192.168.0.1/24 brd 192.168.0.255 scope global enp0s25
# inet 192.168.0.2/24 brd 192.168.0.255 scope global enp0s25
```

## SSH Port Forwarding <a name="ssh-port-forwarding"/></a>
Securely forwarding ports via ssh is simple just hard to remember.

```bash
# Forward local host:port to remote host:port using the ssh connection
# e.g. forwards local 192.168.0.1:5938 to remote 192.168.1.10:5938 via user@access-point.com
# 192.168.1.10 in this case is a host accesible from access-point.com

# ssh -L local_host:local_port:remote_host:remote_port user@access-point.com
ssh -L 192.168.0.1:5938:192.168.1.10:5938 -p 23 user@access-point.com

# Forward 5938 from access-point.com directly
ssh -L 192.168.0.1:5938:127.0.0.1:5938 -p 23 user@access-point.com

# Check resulting ports
netstat -nl | grep 5938
tcp        0      0 192.168.0.1:5938        0.0.0.0:*               LISTEN     
tcp        0      0 10.33.234.133:5938      0.0.0.0:*               LISTEN     
```

## Nameservers <a name="nameservers"/></a>
https://wiki.archlinux.org/index.php/Alternative_DNS_services

Systemd's resolved service configured it's Fallback DNS by default to use Cloudflare then Quad9 then
Google so that DNS will always work.

### See Current DNS <a name="see-current-dns"/></a>
```bash
$ resolvectl status
```

### Configure DNS <a name="configure-dns"/></a>
https://wiki.archlinux.org/index.php/Systemd-resolved#Setting_DNS_servers

DNS is managed first by the network manager which in cyberlinux's case means `systemd-networkd`
which if not specified will fallback on the network router's DNS configuration. It can be overridden
with resolved configuration if desired but is probably simpler to just go with the network manager
settings.

Configure Network Wide at Router:
1. Set network wide DNS picked up by DHCP clients at your router
2. Restart clients `sudo systemctl restart systemd-resolved`

Configure DNS directly locally (for target link):
```bash
# Edit the target network config ensuring that UseDNS=false is set
# Note that to not use the DHCP dns you must set UseDNS=false
$ cat /etc/systemd/network/30-wireless.network
[Match]
Name=wl*

[Network]
DHCP=ipv4
IPForward=kernel
DNS=8.8.8.8

[DHCP]
UseDNS=false
RouteMetric=20
UseDomains=true

# Restart services
$ sudo systemctl restart systemd-networkd systemd-resolved
```

Configure DNS directly locally (for all links):
```bash
# Edit resolved config
$ cat /etc/systemd/resolved.conf
[Resolve]
DNS=1.1.1.1 1.0.0.1
FallbackDNS=1.1.1.1 1.0.0.1 9.9.9.9 8.8.8.8

# Change the DNS= line to your target dns e.g. DNS=8.8.8.8 8.8.4.4

# Restart service
$ sudo systemctl restart systemd-resolved
```

### Cloudflare DNS <a name="cloudflare-dns"/></a>
[Cloudflare's DNS](https://blog.cloudflare.com/announcing-1111/) heralded as the Internet's fastest,
privacy-first consumer DNS service.

* ***1.1.1.1***
* ***1.0.0.1***

### Quad9 DNS <a name="quad9-dns"/></a>
[Quad9's DNS](https://quad9.net/) is a DNS service founed by IBM and a few others with the primary
unique feature of a malicious blocklist.

* ***9.9.9.9***
* ***9.9.9.10***

### Google DNS <a name="google-dns"/></a>
[Google DNS](https://developers.google.com/speed/public-dns/) claims to speed up browsing and offer
better security, however nothing is called out around privacy as they like to monitor heavily.

* ***8.8.8.8***
* ***8.8.4.4***

### DNSSEC Validation Failures <a name="dnssec-validation-failures"/></a>
After updating to the latest bits 5.2.11 kernel for reference I started getting DNS failures:

```bash
# Check the status of systemd resolved
$ sudo systemctl status systemd-resolved
...
Sep 02 20:04:08 main4 systemd-resolved[668]: DNSSEC validation failed for question io IN DS: signature-expired
...
```

Apparently DNSSEC is known to fail and the work around is to turn it off.
https://wiki.archlinux.org/index.php/Systemd-resolved#DNSSEC

```bash
# /etc/systemd/resolved.conf.d/dnssec.conf
# [Resolve]
# DNSSEC=false

# Then restart the service
$ sudo systemctl restart systemd-resolved
```

## Networking DHCP <a name="networking-dhcp"/></a>
```bash
# Create config file
sudo tee -a /etc/systemd/network/10-static.network <<EOL
[Match]
Name=en* eth*

[Network]
DHCP=ipv4
IPForward=kernel

[DHCP]
UseDomains=true
EOL

# Configure DNS
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

# Enable/start resolved
sudo systemctl enable systemd-networkd systemd-resolved
sudo systemctl start systemd-networkd systemd-resolved

# Restart networking
sudo systemctl restart systemd-networkd
```

## Networking Static <a name="networking-static"/></a>
```bash
# Create config file
sudo tee -a /etc/systemd/network/10-static.network <<EOL
[Match]
Name=en* eth*

[Network]
Address=192.168.1.6/24
Gateway=192.168.1.1
DNS=1.1.1.1
DNS=1.0.0.1
IPForward=kernel
EOL

# Restart networking
sudo systemctl restart systemd-networkd
```

## Networking Wifi <a name="networking-wifi"/></a>

1. Ensure kernel driver is accurate:
  ```bash
  inxi -N
  # Network:   Card-1: Intel Ethernet Connection I217-LM driver: e1000e 
  #            Card-2: Intel Centrino Advanced-N 6235 driver: iwlwifi 
  ```
2. Ensure ***systemd-networkd*** has been configured:
  ```bash
  sudo tee /etc/systemd/network/30-wireless.network <<EOL
  [Match]
  Name=wl*

  [Network]
  DHCP=ipv4
  IPForward=kernel

  [DHCP]
  RouteMetric=20
  UseDomains=true
  EOL
  sudo systemctl daemon-reload
  sudo systemctl restart systemd-networkd
  ```
3. Ensure ***wpa_supplicant*** is configured:
  ```bash
  sudo tee /etc/wpa_supplicant/wpa_supplicant-wlo1.conf <<EOL
  ctrl_interface=/run/wpa_supplicant
  ctrl_interface_group=wheel
  update_config=1
  p2p_disabled=1

  network={
    ssid="My Network"
    psk="secret-key"
    proto=RSN
    key_mgmt=WPA-PSK
    pairwise=CCMP
    auth_alg=OPEN
  }
  EOL
  sudo systemctl daemon-reload
  sudo systemctl enable wpa_supplicant@wlo1
  sudo systemctl start wpa_supplicant@wlo1
  sudo systemctl status wpa_supplicant@wlo1
  ```
4. Launch with ***WPA UI***:
  ```bash
  sudo wpa_gui
  # Click connect
  ```

## NFS Shares <a name="nfs-shares"/></a>
https://wiki.archlinux.org/index.php/NFS

### NFS Client Config <a name="nfs-client-config"/></a>
* ***nfs*** – calls out the type of technology being used
* ***auto*** – maps the share immediately rather than waiting until it is accessed
* ***noacl*** – turns off all ACL processing, if your not woried about security i.e. home network this is find to turn off
* ***noatime*** – disables NFS from updating the inodes access time, it can be safely ignored to speed up performance a bit
* ***nodiratime*** – same as noatime but for directories
* ***rsize and wsize*** - bytes read from server, default: 1024, larger values e.g. 8192 improve throughput
* ***timeo=14*** – time in tenths of a second to wait before resending a transmission after an RPC timeout, default: 600
* ***_netdev*** – tells systemd to wait until the network is up before tyring to mount the share

```bash
# Check exported list on client side
$ showmount -e 192.168.1.3

# Create local mount points
sudo mkdir -p /mnt/{Documents,Install,Movies.Pictures,TV}

# Set local mount point ownership to your user
#sudo chown -R <user-name>: /mnt/{Documents,Install,Movies.Pictures,TV}

# Manually mount/umount
sudo mount 192.168.1.2:/srv/nfs/Movies /mnt/Movies
sudo umount /mnt/Movies

# Setup automount for shares
sudo tee -a /etc/fstab <<EOL
192.168.1.2:/srv/nfs/Documents /mnt/Documents nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Install /mnt/Install nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Movies /mnt/Movies nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/Pictures /mnt/Pictures nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
192.168.1.2:/srv/nfs/TV /mnt/TV nfs auto,noacl,noatime,nodiratime,rsize=8192,wsize=8192,timeo=15,_netdev 0 0
EOL
sudo mount -a
```

### NFS Server Config <a name="nfs-server-config"/></a>
Kodi recommends the `(rw,all_squash,insecure)` for the export options. In my experience the nfs root
was also required `/srv/nfs             192.168.1.0/24(rw,fsid=0,no_subtree_check)` and although the
linux nfs client worked fine without it, Kodi wouldn't work until it was added.

Setup nfs shares:
```bash
$ sudo tee -a /etc/exports <<EOL
/srv/nfs             192.168.1.0/24(rw,fsid=0,no_subtree_check)
/srv/nfs/Documents   192.168.1.0/24(rw,all_squash,insecure,no_subtree_check)
/srv/nfs/Educational 192.168.1.0/24(rw,all_squash,insecure,no_subtree_check)
/srv/nfs/Family      192.168.1.0/24(rw,all_squash,insecure,no_subtree_check)
/srv/nfs/Install     192.168.1.0/24(rw,all_squash,insecure,no_subtree_check)
/srv/nfs/Movies      192.168.1.0/24(rw,all_squash,insecure,no_subtree_check)
/srv/nfs/Pictures    192.168.1.0/24(rw,all_squash,insecure,no_subtree_check)
/srv/nfs/TV          192.168.1.0/24(rw,all_squash,insecure,no_subtree_check)
EOL

# Manually Bind mount directories
$ sudo mount --bind /mnt/Movies /srv/nfs/Movies

# Auto Bind mount directories
$ sudo tee -a /etc/fstab <<EOL
/mnt/Documents /srv/nfs/Documents none bind 0 0
/mnt/Educational /srv/nfs/Educational none bind 0 0
/mnt/Family /srv/nfs/Family none bind 0 0
/mnt/Install /srv/nfs/Install none bind 0 0
/mnt/Movies /srv/nfs/Movies none bind 0 0
/mnt/Pictures /srv/nfs/Pictures none bind 0 0
/mnt/TV /srv/nfs/TV none bind 0 0
EOL
$ sudo mount -a
$ sudo systemctl restart nfs-server

# Check what is currently being served
$ sudo exportfs -v
```

# Office <a name="office"/></a>
## LibreOffice <a name="libreoffice"/></a>

### Config Navigation <a name="config-navigation"/></a>
1. Display navigation select ***View >Navigator***  
2. Dock press ***Ctrl+Shift+F10***  

### Keyboard Shortcuts <a name="keyboard-shortcuts"/></a>
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

### Set Default Template <a name="set-default-template"/></a>
1. Save your template as ***~/.config/libreoffice/4/user/template/standard.ott***  
2. Launch ***libreoffice*** and navigate to ***File >Templates >Manage Templates***  
3. Right click on ***standard*** and choose ***Set As Default***  
4. Cancel dialog and your done  

### Turn off Smart Quotes <a name="turn-off-smart-quotes"/></a>
1. Navigate to ***Tools >AutoCorrect >AutoCorrect Options...***  
2. Select the ***Localization Options*** tab  
3. Uncheck ***Replace*** for both types of quotes  

### Turn off Replace Dashes <a name="turn-off-replace-dashes"/></a>
1. Navigate to ***Tools >AutoCorrect >AutoCorrect Options...***  
2. Select the ***Options*** tab  
3. Uncheck ***Replace dashes***  

### Turn off Automatic Strikeout <a name="turn-off-automatic-strikeout"/></a>
1. Navigate to ***Tools >AutoCorrect >AutoCorrect Options...***  
2. Select the ***Options*** tab  
3. Uncheck ***Automatic bold,italic,strikeout,underline***   

### Repeatable Config <a name="repeatable-config"/></a>
LibreOffice stores its user configuration in the `~/.config/libreoffice/4/user/registrymodifications.xdu` file.
To detect the settings you desire and apply them to a future system you can remove the config and use
git to detect the diffs between the defaults and any changes you make.

```bash
# Remove the existing configuration to have it defaulted
```

## PDFs <a name="pdfs"/></a>

### Combine PDFs <a name="combine-pdfs"/></a>
```bash
# Install pdfjoin
$ sudo pacman -S pdfjoin

# Join pdfs
$ pdfjoin 1.pdf 2.pdf -o combined.pdf
```

### Convert Images to PDF <a name="convert-images-to-pdf"/></a>
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

# Packages <a name="packages"/></a>
* Create repo: `repo-add cyberlinux.db.tar.gz *.pkg.tar.xz`

## Init database <a name="init-database"/></a>
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

## Update mirrorlist <a name="update-mirrorlist"/></a>
Install latest mirrorlist and rank by fastest 20

```bash
# Install the latest mirror list
$ sudo pacman -S pacman-mirrorlist
$ sudo mv /etc/pacman.d/mirrorlist.pacnew /etc/pacman.d/mirrorlist`  

# Sort mirrorlist by speed  
# First uncomment all the US mirrors then delete everything else
$ sudo bash -c 'rankmirrors -n 20 /etc/pacman.d/mirrorlist > /etc/pacman.d/archlinux.mirrorlist'

# Clean up
$ sudo rm /etc/pacman.d/archlinux.mirrorlist
```

# Patching <a name="patching"/></a>

## Create Patch <a name="create-patch"/></a>
```bash
# Copy code to a
$ cp -a <code> a

# Copy a to b
$ cp -a a b

# Modify b as desired then generate patch
$ diff -ruN a b > <patch-name>.patch
```

## Apply Patch <a name="apply-patch"/></a>
```bash
$ patch -Np1 -i <patch-name>.patch
```

# Remoting <a name="remoting"/></a>

## Synergy <a name="synergy"/></a>
Synergy allows you to share a keyboard and mouse between machines (e.g. desktop and laptop).

Note: if synergy starts up before xrandr has positioned the windows and thus mousing over to the
other desktop doesn't work due to inaccurate display layout I've found this can be solved by using
the Nvidia drivers rather than the free ones.

1. Configure Main Workstation as Server i.e. has keyboard/mouse
  a. Install: `sudo pacman -S synergy`  
  b. Run ***synergy*** from the ***Network*** menu  
  c. Work through the wizard  
  d. Select ***Server (share this computer's mouse and keyboard)*** and click ***Finish***  
     Note: ignore the ***Failed to get local IP address...*** errror and click ***OK***  
  e. Select ***Configure interactively*** and then click ***Configure Server...***  
  f. Drage a new monitor from top left down to be to the right of ***cyberlinux-desktop***  
  g. Double click the new monitor and name it ***cyberlinux-laptop*** and click ***OK***  
  i. Navigate to ***File >Save configuration as...*** and save ***synergy.conf*** in your home dir  
  j. Now move it to etc: `sudo mv ~/synergy.conf /etc`
2. Configure systemd unit  
  Synergy needs to attach to your user's X session which means it needs to run as your user. Synergy
  provides `/usr/lib/systemd/user/synergys.service` which when run with `systemctl --user
  enable synergys` will create the link ***~/.config/systemd/user/default.target.wants/synergys.service***  
  a. Enable synergy: `systemctl --user enable synergys`  
  b. Start synergy: `systemctl --user start synergys`  
3. Configure Slave Nodes as Clients i.e. don't have keyboard/mouse
  a. Launch: `synergy`  
  b. Click ***Next*** to accept ***English*** as the default language  
  c. Select ***Client (use another computer's mouse and keyboard)*** then ***Finish***  
  d. Uncheck ***Auto config***  
  e. Enter server hostname e.g. ***cyberlinux-desktop***  
  f. Click ***Start***  
  g. Navigate to ***Edit >Settings*** and check ***Hide on startup*** then ***OK***  
  h. Click ***File >Save configuration as...*** and save as ***~/.config/synergy.conf***  
  i. Create autostart for client: `cp /usr/share/applications/synergy.desktop ~/.config/autostart`
4. Configure AutoLogin with Lock  
  Display refreshes don't seem to happen normally after this  
  a. Autologin: `echo "autologin=$USER" | sudo tee -a /etc/lxdm/lxdm.conf`  
  b. Lock immediately: `echo 'sleep 2 && cinnamon-screensaver-command --lock' | sudo tee -a /etc/lxdm/PostLogin`  

## Teamviewer <a name="teamviewer"/></a>
Typically I configure TV to only be accessible from my LAN and tunnel in.

1. Install Teamviewer
  ```bash
  sudo pacman -S teamviewer
  sudo systemctl enable teamviewerd
  sudo systemctl start teamviewerd
  ```
2. Autostart Teamviewer
  ```bash
  cp /usr/share/applications/teamviewer.desktop ~/.config/autostart
  ```
3. Configure Teamviewer  
  a. Start teamviewer: `teamviewer`  
  b. Click ***Accept License Agreement***  
  c. Navigate to ***Extras >Options***  
  d. Click ***General*** tab on left  
  e. Set ***Your Display Name***  
  f. Check the box ***Start Teamviwer with system***  
  g. Set drop down ***Incoming LAN connections*** to ***accept exclusively***  
  h. Click ***Security*** tab   
  i. Set ***Password*** and ***Confirm Password***  
  j. Leave ***Start Teamviewer with Windows*** checked and click ***OK*** then ***OK***  
  k. Click ***Advanced*** tab on left  
  l. Disable log files  
  m. Check ***Disable TeamViewer shutdown***  
  n. Click ***OK***  

## Zoom <a name="zoom"/></a>
Seems to be a pretty good quality app.  I simply installed it and selected my plantronics headset
and audio worked great.  My laptop webcam also worked without doing anything.

**Install Manually**
```bash
$ yaourt -G zoom; cd zoom
$ makepkg -s
$ sudo pacman -U zoom-2.4.121350.0816-1-x86_64.pkg.tar.xz
```

**Install from cyberlinux-repo**
```bash
$ sudo tee -a /etc/pacman.conf <<EOL
[cyberlinux]
SigLevel = Optional TrustAll
Server = https://phR0ze.github.io/cyberlinux-repo/$repo/$arch
EOL
$ sudo pacman -Sy zoom
```

# Rescue <a name="rescue"/></a>

## Switch to TTY <a name="switch-to-tty"/></a>
Bare Metal:
* `ctrl+alt+F2` should switch to console  
* `ctrl+alt+F1` should switch back to UI

VirtualBox:
* `right ctrl+F2` should switch to console  
* `right ctrl+F1` should switch back to UI

## Graphical Target <a name="graphical-target"/></a>
When you're system boots the last thing you'll see before the display manager is loaded is that the
`Graphical Target` is being started. If it hangs here its safe to say either LXDM is failing or Xorg
is failing to start.

### Check Xorg logs <a name="check-xorg-logs"/></a>
The Xorg logs are often telling when unable you get black screens or hanging at the Graphical Target.
Often this will be a video driver issue. You can check your video card with `inxi -G`.

```bash
$ cat /var/log/Xorg.0.log | grep EE
[     3.932] (EE) Failed to load module "vboxvideo" (module does not exist, 0)
[     3.935] (EE) Failed to load module "fbdev" (module does not exist, 0)
```

### Reset Xorg settings <a name="check-xorg-settings"/></a>
Often there will be old settings from a previous driver in the `xorg.conf`

```bash
# Remove the xorg config file
# 99.9% of the time the main config file is not required
$ sudo rm /etc/X11/xorg.conf

# Removing the one off configs is probably not needed, but circle back if still not working
$ sudo rm -rf /etc/X11/xorg.conf.d/*
```

### Opensource Driver <a name="opensource-driver"/></a>
Frequently the settings on Nvidia's proprietary drivers will get screwed up. If you just want to
validate that he problem is indeed the video driver you can temporarily switch to the opensource
driver to check.

```bash
# Remove the old nvidia driver
$ sudo pacman -Rns nvidia-340xx nvidia-340xx-utils

# Install the opensource driver
$ sudo pacman -Rns mesa xf86-video-nouveau
```

## Unable to Login <a name="unable-to-login"/></a>
If you are unable to login via LXDM but have got past the Graphicl target that means your video
driver is working properly. In this case it may be something in the chain of scripts and apps that
boot the desktop i.e. LXDM settings, `startx` or user scripts like `.bashrc`. I've seen powerline
initialization in `.bashrc` fail causing the login to fail.

### Try logging in while tailing the logs <a name="try-logging-in-while-tailing-the-logs"/></a>
1. Switch to TTY and get the ip of the system then loging and tail the logs
   ```bash
   $ journalctl -f
   ```
2. Switch back to LXDM and attempt to loging and watch the logs

### Try running openbox directly <a name="try-running-openbox-directly"/></a>
This will eliminate possiblities
1. Use one of the methods below to get shell access.
2. Disable LXDM `sudo systemctl disable lxdm`
3. Restart your system `sudo reboot`
4. Install xinit `sudo pacman -S xorg-xinit`
5. Launch `startx openbox-session`

### Try an aternate window manager <a name="try-an-alternate-window-manager"/></a>
If this works you know you might have an openbox issue or in my case I had a lxdm issue that that I
fixed by uninstalling `lxdm` and instead installing `lxdm-gtk3`.

```bash
$ sudo pacman -S xfwm4 xfce4-session xfce4-settings
$ startxfce4
```

### Try reinstalling the target video driver <a name="try-reinstallig-the-target-video-driver"/></a>
I noticed that when I tried reinstalling the correct video driver that the `dkms` module failed to
compile and install with the new kernel. So I rebuilt the drivers and installed the new one and it
worked. So apparently the dkms doesn't always work.

## Boot from Live USB <a name="boot-from-live-usb"/></a>
```bash
# Mount the HDD
$ lsblk
$ sudo mount /dev/sda3 /mnt

# Chroot into HDD
$ sudo arch-chroot /mnt

# Check current boot target
$ sudo systemctl get-default
graphical.target

# Change to mult-user (console)
$ sudo systemctl set-default multi-user

# Exit the chroot
$ exit

# Reboot to the HDD
$ sudo reboot
```

## Black Screen <a name="black-screen"/></a>
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

## Check Logs for Errors <a name="check-logs-for-errors"/></a>
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

# Session <a name="session"/></a>
cyberlinux uses `lxsession` to manage its session which is started by the `/usr/bin/startx` in the
`cyberlinux-lite-config` package which in turn is started by `lxdm`. LXSession will also kick off any
XDG Autostart desktop files at `~/.config/autostart`.

## XDG Autostart <a name="xdg-autostart"/></a>
LXSession supports the XDG Autostart specification which calls out `/etc/xdg/autostart` and
`~/.config/autostart` as locations where you can store desktop files that will get executed at
startup.

### Exec Script <a name="exec-script"/></a>
As of yet the timing/ordering of X components being started isn't guaranteed which means that some
may start too soon and end up having UI tearing. Conky is an example of an app that frequently does
this. To avoid it you can create a wrapper script called from the desktop exec entry that will sleep 
then execute conky.

Note the placement of the `exec` call to avoid having nested parent processes visible with `ps -ef`
```bash
#!/bin/bash
sleep 2 && exec conky -c /etc/xdg/conky/.conkyrc
```

# Storage <a name="storage"/></a>

## Add Drive <a name="add-drive"/></a>
```bash
# Get device names
$ sudo fdisk -l

# Partition a drive via gdisk (greater than 2TB)
$ sudo gdisk /dev/sdb
# n to start create a new partition wizard
# Accept default Partition number, hit enter
# Accept defaults for First sector and Last sector
# Accept default Hex code 8300 for Linux filesystem
# w to write out the changes

# To tell kernel about changes  
$ sudo partprobe /dev/sdb

# Format and Tune Drive  
$ sudo mkfs.ext4 /dev/sdb1

# For storage only set reserved blocks which defaults to 5% to 0 as it is unneeded.  These
# reserved blocks are only used as a security measure on boot disks to that system functions can
# continue to operate correctly even if a user has stuffed the drive.
$ sudo tune2fs -m 0 /dev/sdb1
```

Most likely you'll want to also automount it [Add Automount using FSTAB](#add-automount-using-fstab)

## Clone Drive <a name="clone-drive"/></a>
```bash
# Kick off clone in one terminal
# conv=sync,noerror means in the case of an error ensure length of original data is preserved and don't fail
sudo dd if=/dev/sdX of=/dev/sdY bs=1M conv=sync,noerror

# Watch clone in another with
watch -n10 'sudo kill -USR1 $(pgrep ^dd)'
```

## Shred Drive <a name="shred-drive"/></a>
```bash
sudo shred -v --random-source=/dev/urandom -n1 /dev/sdX
```

## Wipe Drive <a name="wipe-drive"/></a>
```bash
sudo dd if=/dev/zero of=/dev/sdX bs=512 count=2048
sudo bash -c 'dd if=/dev/zero of=/dev/sdX bs=512 count=2048 seek=$((`blockdev --getsz /dev/sdX` - 2048))'
sudo wipefs --all --force /dev/sdX
```

## RAID Drives <a name="raid-drives"/></a>
The standard URE rate of 1 in 10^14 failure in modern drives has made RAID 5 an almost 100% fail with
larger drives. RAID 6 although tolerable will also be too high a risk with larger drives.  The only
option for RAID is RAID 10 if you value your data.  Otherwise forget RAID and make regular backups.
Once configured partition and format like any other drive.

## Test Drive <a name="test-drive"/></a>
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

# System <a name="system"/></a>

## Shell <a name="shell"/></a>
### Powerline <a name="powerline"/></a>
https://powerline.readthedocs.io/en/latest/usage/shell-prompts.html#bash-prompt

If powerline git status is not working try upgrading

## System Update <a name="system-update"/></a>
1. Update keyring first
   ```bash
   $ sudo pacman -Sy archlinux-keyring
   ```
2. [Update mirrorlist](#update-mirrorlist)
3. Update full system
   ```bash
   $ sudo pacman -Syu
   ```

## Systemd Status <a name="systemd-status"/></a>

```bash
# By leaving off a specific unit to get status about we see the status of the entire system
$ systemctl status

# List out all running units and their state
$ systemctl
```

## Systemd Boot Performance <a name="systemd-boot-performance"/></a>
https://wiki.archlinux.org/index.php/Improving_performance/Boot_process

### See How long boot takes <a name="see-how-long-boot-takes"/></a>
```bash
$ systemd-analyze
Startup finished in 4.800s (kernel) + 2min 3.457s (userspace) = 2min 8.258s 
graphical.target reached after 2min 3.457s in userspace
```

### Rank services by startup time <a name="rank-services-by-startup-time"/></a>
```bash
$ systemd-analyze blame
2min 200ms systemd-networkd-wait-online.service
  2.012s dev-sda3.device
  1.577s systemd-udevd.service
  1.483s systemd-resolved.service
  1.406s man-db.service
  1.277s systemd-journal-flush.service
   981ms docker.service
   823ms systemd-timesyncd.service
   472ms logrotate.service
   455ms systemd-logind.service
   417ms systemd-networkd.service
   374ms systemd-journald.service
   338ms udisks2.service
   305ms polkit.service
   114ms systemd-rfkill.service
    96ms systemd-udev-trigger.service
    71ms teamviewerd.service
    69ms user@1000.service
    51ms org.cups.cupsd.service
    47ms systemd-binfmt.service
    28ms dev-mqueue.mount
    26ms dev-hugepages.mount
    26ms lvm2-monitor.service
    26ms sys-kernel-debug.mount
    25ms systemd-tmpfiles-setup.service
    24ms kmod-static-nodes.service
    24ms systemd-modules-load.service
    23ms systemd-remount-fs.service
    20ms systemd-tmpfiles-setup-dev.service
    19ms systemd-random-seed.service
    15ms systemd-sysctl.service
    15ms tmp.mount
    13ms systemd-tmpfiles-clean.service
    12ms user-runtime-dir@1000.service
    12ms systemd-update-utmp.service
    11ms proc-sys-fs-binfmt_misc.mount
    10ms systemd-user-sessions.service
     9ms systemd-backlight@backlight:acpi_video0.service
     7ms docker.socket
     7ms systemd-backlight@backlight:nv_backlight.service

$ systemd-analyze critical-chain
graphical.target @2min 3.457s
└─multi-user.target @2min 3.457s
  └─docker.service @2min 2.474s +981ms
    └─network-online.target @2min 2.472s
      └─network.target @3.749s
        └─systemd-resolved.service @2.265s +1.483s
          └─systemd-networkd.service @1.845s +417ms
            └─systemd-udevd.service @263ms +1.577s
              └─systemd-tmpfiles-setup-dev.service @240ms +20ms
                └─kmod-static-nodes.service @190ms +24ms
                  └─systemd-journald.socket @189ms
                    └─system.slice @183ms
                      └─-.slice @183ms
```

### Remove lvm2 service <a name="remove-lvm2-service"/></a>
If you're not using the lvm2 service, which has never seemed a useful feature, then disabling it
will clean up your boot slightly especially since it seems to be trying to start and failing for me.
Unfortunately due to actual useful tools depending on it i.e. `libblockdev` which in turn is
depended upon by `gvfs` which I use, it can't be simply removed. Unless I rebuilt `libblockdev` with
the `--without-lvm` flag which I did and made available in the `cyberlinux-repo`.

Remove lvm2 requires a rebuild of `libblockdev`
```bash
$ 
```

Disable
```bash
# List out all failed units
$ systemctl --failed
● lvm2-monitor.service                 loaded failed failed Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling

# Checking if lvm2 is enabled gives 'static' which means that its a dependency of something else
$ systemctl is-enabled lvm2-monitor
static

# Mask the lvm2-monitor service
$ sudo systemctl mask lvm2-monitor --now
```

## Systemd Debug Shell <a name="systemd-debug-shell"/></a>
```bash
$ sudo systemctl enable debug-shell

# Logout then switch to debug shell with Ctl+F9
$ systemctl status

# See which apps are hanging
```

# Time/Date <a name="time-date"/></a>
Time and dates are controlled on Arch Linux by  `timedatectl`

# Set Time/Date <a name="set-time-date"/></a>
```bash
# timedatectl set-time "yyyy-MM-dd hh:mm:ss"
sudo timedatectl set-time "2019-01-17 09:12:20"
```

# Users/Groups <a name="users-groups"/></a>

## Add user <a name="add-user"/></a>
https://wiki.archlinux.org/index.php/users_and_groups#Example_adding_a_system_user

Add a user without a home directory or ability to login for running daemons
```bash
# e.g. useradd -r -s /usr/bin/nologin <username>
useradd -r -s /usr/bin/nologin teamviewer
```

## Rename user <a name="rename-user"/></a>
1. Login using root
2. Rename user `usermod -l newname oldname`
3. Rename user home directory `mv /home/oldname /home/newname`
4. Change user home `usermod -d /home/newname -m newname`
5. Rename user group `groupmod -n newname oldname`

# VeraCrypt <a name="veracrypt"/></a>
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

# VPNs <a name="vpns"/></a>

## OpenConnect <a name="openconnect"/></a>
https://wiki.archlinux.org/index.php/OpenConnect  
OpenConnect is a client for Cisco's AnyConnect SSL VPN and Pulse Secure's Pulse Connect Secure.

**Note:** I kept wanting to pass in all the fields I could. It works better to use the minimal args
and OpenConnect will then prompt for information it needs.

```bash
# Install OpenConnect
$ sudo pacman -S openconnect vpnc

# Connect to AnyConnect VPN
$ sudo openconnect --user=<USER-NAME> --authgroup=<AUTH-GROUP> <VPN GATEWAY NAME/IP>
...
Please enter your username and password.
Password:
# When prompted for `Password:` paste in your ldap password
Password:
# When prompted again for `Password:` u may or may not have a second
Verification code:
Response:
# When prompted for `Response:` paste in authy code
Connect Banner:
Welcome to Example VPN!
```

### Trouble shooting DNS failures

#### systemd-resolved and vpn dns
`systemd-resolved` first checks for system overrides at `/etc/systemd/resolved.conf` then for network
configuration at `/etc/systemd/network/*.network`, then vpn dns configuration and finally falls back
on the fallback configuration in `/etc/systemd/resolved.conf`. I've found the most reliable way to
get vpn dns to work correctly is to not set anything except the fallback configuration so that dns is
configured by openconnect and when not on the vpn dns is configured by the fallback.

#### systemd-resolved nsswitch configuration
cyberlinux just worked out of the box but Ubuntu, although using `systemd-resolved` doesn't have
`nsswitch` setup correctly.

You can verify if it is working by checking the DNS configured with `systemd-resolved --status`. If
that returns the VPN's dns then your good if not check below as I had to on Ubuntu

The problem is that `/etc/nsswitch.conf` is not configured to use `systemd-resolved` even
though Ubuntu Pop has systemd-resolved running.  To fix this you need to add
`resolve` before `[NOTFOUND=return]` on the `hosts` line, no restarts are necessary

Example of fixed:
```bash
hosts: files mdns4_minimal resolve [NOTFOUND=return] dns myhostname
```

# Wine <a name="wine"/></a>
Wine uses the `WINEPREFIX` as separate C-drive/registries. Typically you'll want one per app unless
the apps are sharing configuration or depend on each other.

## Config Wine <a name="config-wine"/></a>
https://wiki.archlinux.org/index.php/wine

```bash
# Install Wine
$ sudo pacman -S winetricks wine_gecko wine-mono

# Ensure the multilib freetype is installed
$ sudo pacman -S multilib/lib32-freetype2
```

## Config Prefix <a name="config-prefix"/></a>
Wine prefixes are where all the registry, apps etc... live and are installed.

Delete a prefix:
```bash
$ rm -rf ~/.wine/steam
```

Create new 32bit Wine Prefix:
```bash
$ mkdir ~/.wine
$ WINEARCH=win32 WINEPREFIX=~/.wine/win32 wineboot -u

# Configure new Prefix if desired, defaults to Windows 7
$ WINEARCH=win32 WINEPREFIX=~/.wine/win32 wincfg
```

## Wine Sketchup <a name="wine-sketchup"/></a>
```bash
$ Install Sketchup via Winetricks
$ WINEARCH=win32 WINEPREFIX=~/.wine/sketchup winetricks sketchup

# Note you can see the download location in the output of the shell
# https://dl.google.com/sketchup/GoogleSketchUpWEN.exe

# Launch after installation find the exe and launch
$ WINEARCH=win32 WINEPREFIX=~/.wine/sketchup wine ~/.wine/sketchup/drive_c/Program\ Files/Google/Google\ SketchUp\ 8/SketchUp.exe

```

## Wine Steam <a name="wine-steam"/></a>
```bash
$ WINEARCH=win32 WINEPREFIX=~/.wine/steam winetricks steam
```

<!-- 
vim: ts=2:sw=2:sts=2
-->
