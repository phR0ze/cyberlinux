# cyberlinux
***cyberlinux*** was designed to provide the unobtrusive beauty and power of Arch Linux as a fully
customized multi-flavor automated offline deployment. Using a clean declarative yaml specification,
processed by ***reduce***, cyberlinux is able to completely customize and automate the building of
Arch Linux filesystems which are bundled either as a bootable ISO. By default install flavors are
provided for many common use cases but the option to build your own infinitely flexible flavor is
yours for the taking.

[![Build Status](https://travis-ci.org/phR0ze/cyberlinux.svg)](https://travis-ci.org/phR0ze/cyberlinux)

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***

### Table of Contents
* [Background](#background)
   * [Evolution process](#evolution-process)
   * [My take on Arch](#my-take-on-arch)
   * [Distro requirements](#distro-requirements)
* [Build cyberlinux](#build-cyberlinux)
    * [Package versions](#package-versions)
    * [Linux Dev Envioronment](#linux-dev-environment)
    * [Full cyberlinux build](#full-cyberlinux-build)
* [Deploy cyberlinux](#deploy-cyberlinux)
    * [Deploy flavor](#deploy-flavor)
* [Troubleshooting](#troubleshooting)
    * [BlackArch Signature issue](#blackarch-signature-issue)
* [Contributions](#contributions)
    * [Git-Hook Version Increment](#git-hook-version-increment)

## Background <a name="background"></a>
***cyberlinux*** is an evolution of an idea come to fruition.  The origin was the need for an
automated installer that would be able to install a completely pre-configured and ready to use
system customized for a handful of common use cases (e.g. desktop, theater, server...) in an offline
environment. As time passed the need for simpler maintainability and access to larger more
up-to-date software repositories drove the search for the ideal Linux distribution.

### Evolution process <a name="evolution-process"></a>

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
install flavors without heroic effort.  As time passed I found I was making more and more changes
to ***Thus***, the installer, and other installation aspects other than what was allowed for with
Manjaro's current tool set at the time. I soon realized that I had evolved my use of Manjaro so far
beyond its original purpose that consuming updates from upstream Manjaro and other tasks were
becoming complicated and tedious.  Additionally I was more and more envious of pure Arch Linux and
the goodness that was available by stying close to the source and began looking at Arch Linux
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
Manjaro is an Arch split-off distro which used to have a really nice OpenBox flavor that suited my
needs quite well.  They have since dropped the OpenBox flavor but their distribution is still one 
of the best distros out there and have a great community which adds to Arch's appeal with a little
adaptation. The main draw back with Manjaro is that that it can't leverage the Arch repos as is due
to their differences.

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

* Single configuration file to drive ISO creation
* ISO must include all packages, config etc... without online requirements
* Boot splash screen shown with multi-flavor install options
* Fast, simple automated installs with abosolute minimal initial user input
* Fully pre-configured user environments to avoid post-install changes
* Live boot option for maintenance, rescue and secure work
* Hardware boot and diagnostics options e.g. RAM validation
* As light as possible while still offering an elegant solution

## Build cyberlinux <a name="build-cyberlinux"/></a>
This section covers how to build your own cyberlinux ISO

### Package versions <a name="package-versions"/></a>
**Working combinations:**  
* ***Kernel=4.11.3-1, Vagrant=1.9.5, Packer=1.0.0, VirtualBox=5.1.22***

**Notes**:  
* Virtual box and packer interation has been iffy as versions have revved.

### Linux dev environment <a name="linux-dev-environment"/></a>
There are three different ways you can get a development environment up and running.

**Bare metal install**  
Install ***cyberlinux*** via a USB directly onto a machine

1. Download the latest ***cyberlinux ISO*** 
2. Burn the ISO to a USB
3. Boot from the USB and install the ***cyberlinux-heavy*** flavor

**Vagrant VM**  
If your not currently running ***cyberlinux*** and don't have a spare machine you can always deploy
a vagrant cyberlinux box.

```bash
$ git clone https://github.com/phR0ze/cyberlinux.git
$ cd cyberlinux
$ vagrant ?????
```

**VirtualBox install**  
Alternately you can install to a VM using a cyberlinux ISO.

1. Create a VM named ***cyberlinux-build*** with ***4GB RAM, 40GB HDD***  
2. Once created edit ***Settings***  
    a. Set ***System >Processor = 4***  
    b. Set ***Display >Video = 32***  
    c. Set ***Network >Bridged Adapter***  
    d. Set ***Storage >IDE Empty*** to ***cyberlinux-1.0.1-x86_64.iso***  
    e. Click ***OK***  
2.	Once booted to ISO choose ***cyberlinux-heavy***  

### Full cyberlinux Build <a name="full-cyberlinux-build"/></a>
1. [Update cyberlinux](#update-cyberlinux)
2. [Clone cyberlinux repo](#clone-cyberlinux-repo)
3. [Full build of cyberlinux](#full-build-of-cyberlinux)

## Deploy cyberlinux <a name="deploy-cyberlinux"/></a>
TBD

### Deploy flavor<a name="deploy-flavor"/></a>
TBD

## Troubleshooting<a name="troubleshooting"/></a>

### BlackArch Signature issue <a name="blackarch-signature-issue"/></a>
To fix the issue below delete ***/var/lib/pacman/sync/*.sig***

Example: 
```bash
error: blackarch: signature from "Levon 'noptrix' Kayan (BlackArch Developer) <noptrix@nullsecurity.net>" is invalid
error: failed to update blackarch (invalid or corrupted database (PGP signature))
error: database 'blackarch' is not valid (invalid or corrupted database (PGP signature))
```

## Contributions <a name="contributions"/></a>
Pull requests are always welcome.  However understand that they will be evaluated purely on whether
or not the change fits with my goals/ideals for the project.

### Git-Hook Version Increment <a name="git-hook-version-increment"/></a>
Enable the githooks to have automatic version increments

```bash
$ cd ~/Projects/cyberlinux
$ git config core.hooksPath .githooks
```
