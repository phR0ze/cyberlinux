cyberlinux
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
====================================================================================================

<img align="left" width="48" height="48" src="art/logo_256x256.png">
<b><i>cyberlinux</i></b> was designed to provide the unobtrusive beauty and power of Arch Linux as a
fully customized automated offline multi-deployment ISO. Leveraging Arch Linux's excellent packaging
system and some scripting cyberlinux is able to provide a completely customizable and automated
build of Arch Linux filesystems bundled as distinct deployment options on a BIOS/UEFI bootable ISO.
This includes opinionated builds of common use cases out of the box, but the option to build your own
infinitely flexible deployment is yours for the taking. <br><br>

<b><i>Please fork this repo and create your own variations as you see fit.</i></b> The profiles included by
default, though fully functional, are reference implementations only with highly opinionated designs
for my personal use cases. If you find the reference deployments useful note that any PRs, though
welcome, will be evaluated in that context and will need to align with my goals.

### Warning
The pre-built `cyberlinux-*` packages available in the [cyberlinux-aur](https://github.com/phR0ze/cyberlinux-aur)
are highly opinionated and in some cases will modify system configuration with cyberlinux defaults
and as such they are ***only recommended to be installed with new systems*** or to
***upgrade existing cyberlinux based systems*** and are ***not to be used directly on pre-existing non-cyberlinux systems***.

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk. Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***.

<a href="docs/images/cyberlinux-deployment-01.jpg"><img width="820" height="480" src="docs/images/cyberlinux-deployment-01.jpg"></a>
<a href="docs/images/cyberlinux-deployment-02.jpg"><img width="820" height="480" src="docs/images/cyberlinux-deployment-02.jpg"></a>

### Quick links
* [Help](docs)
* [Getting started](#getting-started)
  * [Prerequisites](#prerequisites)
    * [Configure Arch Linux for build](#configure-arch-linux-for-build)
    * [Configure Ubuntu for build](#configure-ubuntu-for-build)
  * [Create multiboot USB](#create-multiboot-usb)
    * [Build the ISO](#build-the-iso)
    * [Burn the ISO to USB](#burn-the-iso-to-usb)
    * [Test the USB in VirtualBox](#test-the-usb-in-virtualbox)
* [Deploy cyberlinux](#deploy-cyberlinux)
  * [QEMU VM](#qemu-vm)
  * [ACEPC AK1](docs/deployments/acepc-ak1)
  * [Dell XPS 13 9310](docs/deployments/dell-xps-13-9310)
  * [HP ZBook 15](docs/deployments/hp-zbook-15)
  * [nVidia Quadro FX 3800](docs/deployments/nvidia-quadro-fx-3800)
  * [Samsung Chromebook3 (CELES)](docs/deployments/samsung-chromebook3)
  * [Package Deployment](#package-deployment)
* [Advanced concepts](#advanced-concepts)
  * [cyberlinux help](docs)
  * [Roll your own](profiles)
  * [cyberlinux-repo](https://github.com/phR0ze/cyberlinux-repo)
* [Background](#background)
  * [Evolution](#evolution)
  * [My take on Arch](#my-take-on-arch)
  * [Distro requirements](#distro-requirements)
* [Contributions](#contributions)
  * [Git-Hook Version Increment](#git-hook-version-increment)
* [Licenses](#licenses)
* [Backlog](#backlog)
* [Testlog](docs/CHANGELOG.md#Testlog)
* [Changelog](docs/CHANGELOG.md)

---

# Getting started

## Prerequisites
The multiboot ISO is built almost entirely in a docker container with data cached on the local host
for quicker rebuilds. This makes it possible to build on systmes with a minimal dependencies. All
that is required is ***passwordless sudo***, ***jq***, and ***docker***. Optionally use Virtualbox or
another hypervisor solution to test out the resulting ISO/USB.

### Configure Arch Linux for build
1. Passwordless sudo access is required for automation:
   ```bash
   $ sudo bash -c "echo '$USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-passwordless"
   ```
2. Install dependencies:
   ```bash
   $ sudo pacman -S jq docker virtualbox virtualbox-host-modules-arch
   $ sudo usermod -aG disk,docker,vboxusers $USER

   $ sudo systemctl enable docker
   $ sudo systemctl start docker
   ```
3. Add your user to the appropriate groups:
   ```bash
   $ sudo usermod -aG disk,docker,vboxusers $USER
   ```

### Configure Ubuntu for build
1. Passwordless sudo access is required for automation:
   ```bash
   $ sudo bash -c "echo 'YOUR_USER ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/10-passwordless"
   ```
2. Install dependencies:
   ```bash
   $ sudo apt update
   $ sudo apt install jq docker virtualbox
   ```
3. Add your user to the appropriate groups:
   ```bash
   $ sudo usermod -aG disk,docker,vboxusers $USER
   ```

## Create multiboot USB
First ensure you satisfy the [Prerequisites](#prerequisites)

### Build the ISO
1. Clone the repo:
   ```bash
   $ cd ~/Projects
   $ git clone git@github.com:phR0ze/cyberlinux
   ```
2. Execute the build:
   ```bash
   $ ./build.sh -p xfce -a
   ```

### Burn the ISO to USB
1. Determine the correct USB device
   ```bash
   $ lsblk
   ```
2. Optionally wipe your USB first
   ```bash
   $ sudo wipefs --all --force /dev/sdd
   ```
3. Copy to the dev leaving off the partition
   ```bash
   $ sudo dd bs=4M if=temp/output/cyberlinux-0.1.62-xfce.iso of=/dev/sdd status=progress conv=fsync oflag=direct
   ```

### Test the USB in VirtualBox
1. Determine which device is your USB
   ```bash
   $ lsblk
   ```
2. Create a raw vmdk boot stub from the USB
   ```
   $ sudo vboxmanage convertfromraw /dev/sdd usb.vmdk --format vmdk

   # Change ownership of new image to your user
   $ sudo chown $USER: usb.vmdk

   # Add your user to the disk group then
   # Logout and back in and launch virtualbox
   $ sudo usermod -a -G disk $USER
   ```
3. Create a new VM in VirtualBox then after
   1. Ensure your VM is not using `EFI`
   1. Click `Settings` then choose `Storage1`
   2. Under `Storage Devices` click the `Adds hard disk` button to the `Controller: IDE`
   3. Browse to and select the `usb.vmdk` you just created
   4. Start up the new VM

# Deploy cyberlinux
For the most part deploying ***cyberlinux*** is as simple as:
1. Booting from the USB or ISO you created in the [Create multiboot USB](#create-multiboot-usb) section
2. Selecting your desired deployment configuration
3. Walking through the simple installer wizard
4. Waiting for the install to complet
5. Removing the USB
6. Rebooting

## QEMU VM
Note: QEMU use disk named `vda`

1. Create new virtual disk
   ```bash
   $ qemu-img create -f qcow2 arch1.qcow2 20G
   ```
2. Install ISO to new virtual disk
   ```bash
   $ qemu-system-x86_64 \
       -enable-kvm \
       -m 4G \
       -nic user,model=virtio \
       -drive file=arch1.qcow2,media=disk,if=virtio \
       -cdrom cyberlinux-0.1.62-xfce.iso
   ```

## Package Deployment
The pre-built `cyberlinux-*` packages available in the [cyberlinux-repo](https://github.com/phR0ze/cyberlinux-repo)
are highly opinionated and in some cases will modify system configuration with cyberlinux defaults
and as such they are ***only recommended to be installed with new systems*** or to
***upgrade existing cyberlinux based systems*** and are
***not to be used directly on pre-existing non-cyberlinux systems***.

1. Install desired end state package e.g.
   ```bash
   $ sudo pacman -S cyberlinux-xfce-theater
   ```
2. Update user configuration: ***WARNING this is destructive. Please backup your configs first***
   ```bash
   $ mv -rf ~/.config ~/Downloads
   $ mv -rf ~/.local ~/Downloads
   $ shopt -s dotglob
   $ cp -r /etc/skel/* ~/
   $ sudo reboot
   ```

## Advancecd concepts
* [cyberlinux help](docs)
* [Roll your own](profiles)
* [cyberlinux-repo](https://github.com/phR0ze/cyberlinux-repo)

# Background
***cyberlinux*** is an evolution of an idea come to fruition.  The origin was the need for an
automated installer that would be able to install a completely pre-configured and ready to use
system customized for a handful of common use cases (e.g. desktop, theater, server...) in an offline
environment. As time passed the need for simpler maintainability and access to larger more
up-to-date software repositories drove the search for the ideal Linux distribution.

### Evolution

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
configuration.  The crux of CentOS's issues was that it is notoriously behind the times and packages 
are difficult to find or simply don't exist. Additionally building newer packages on the old CentOS 
tool chains proved difficult and impossible in some cases where they required newer dependencies.

**Manjaro Offline Install**  
About this time I started looking for a distribution that provided modern packages and tooling and
found Arch.  Being intimidated by Arch's install process though, I moved on to Manjaro as the next
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

### My take on Arch
***Arch Linux kills!*** I've never used a distribution as transparent, clean and documented to use as 
Arch.  The packages are plentiful, up-to-date and easily managed. The community is huge and active, 
providing almost every package known to man in the Arch User Repository or you can easily build your 
own packages with little effort. The kernel and tooling is modern, maintenance is easy and rolling 
updates make for a system that can be used forever with little effort. Best of all though is that the 
Arch Install process provides simple building blocks that lend themselves easily to custom filesystem 
creations that in turn is readily turned into ISOs and other install media. Because of the large 
community and plethera of distros based off Arch there are many ideas to leverage such as the 
following:

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

### Distro requirements
I boiled down my requirements for ***cyberlinux*** as follows:

* Single configuration file (i.e. profile) to drive ISO creation
* ISO must include all packages, config etc... (i.e. works offline)
* Boot splash screen shown with multi-deployment options
* Fast, simple automated installs with abosolute minimal initial user input
* Fully pre-configured user environments to avoid post-install changes
* Live boot option for maintenance, rescue and secure work
* Hardware boot and diagnostics options e.g. RAM validation
* As light as possible while still offering an elegant solution

# Contributions
Pull requests are always welcome.  However understand that they will be evaluated purely on whether
or not the change fits with my goals/ideals for the project.

## Git-Hook Version Increment
Enable the githooks to have automatic version increments

```bash
cd ~/Projects/cyberlinux
git config core.hooksPath .githooks
```

## Licenses
Because of the nature of ***cyberlinux*** any licensing will be of a mixed nature.  In some cases as
called out below such as ***build.sh*** and the ***installer/installer***, created by phR0ze, the
license is MIT. In other cases works I leveraged from else where using licenses such as GPLv2.

### ART work
All art work used in the distribution have been carefully selected to be either creative commons,
public domain, have permission from the original authors, or lay claim on fair use licensing. If for
some reason a licensing mistake has been made please let me know and I'll review the claim immediately.

### Configure, Build and Install Scripts
All scripting and code created for the cyberlinux project is licensed below via MIT.

[LICENSE-MIT](LIENSE-MIT)

---

# Backlog
* Write Rust version of [pdfmod](https://wiki.gnome.org/Attic/PdfMod)

* Configure rust analyzer to not show types
* Use `Gnome Disks` i.e. `sudo pacman -S gnome-disk-utility`
* `Super + plus` to resize window to custom size
* `Super + Enter` to position in the center

* Tool to merge skel configs
  * skip `~/.local/share/gem`
* Inject system wide configuration change via strategic edits rather than file replaces
  * This would aleviate loosing custom changes in files such as `/etc/pacman.conf` and 
  `/etc/lxdm/lxdm.conf`

# Sometime
* clu to sync wallpaper
  * `/etc/lxdm/lxdm.conf`
  * `/usr/bin/lockscreen`
  * `~/.conf/xfce4/xfconf/.../xfce4-desktop.xml`
* GTK folder sort settings didn't take
* ACEPC
  * Vulkan support
    * `sudo pacman -S vulkan-intel vulkan-tools`
    * `vulkaninfo` if you get info about your graphics card its working
* Add conflicts to PKGBUILD
* Replace powerline with powerline-go or powerline-rs
* clu - cyberlinux automation
  * replace conky scripts, cal.rb, date.rb and radio.rb
  * build in skel copy for updates
* Add cyberlinux-repo README about packages and warnings and how to configure
  * Automate updates to the readme when updating the packages

<!-- 
vim: ts=2:sw=2:sts=2
-->
