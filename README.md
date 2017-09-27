# cyberlinux
***cyberlinux*** was designed to provide the unobtrusive beauty and power of Arch Linux as a fully
customized automated offline multi-deployment ISO. Using a clean declarative yaml specification,
processed by ***reduce***, cyberlinux is able to completely customize and automate the building of
Arch Linux filesystems which are bundled as a bootable ISO. Many common use cases are available as 
deployment options right out of the box, but the option to build your own infinitely flexible
deployment is yours for the taking.

[![Build Status](https://travis-ci.org/phR0ze/cyberlinux.svg)](https://travis-ci.org/phR0ze/cyberlinux)

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***.

Additionally the pre-configured ***spec.yml*** and ***layers*** files that exist in this repo are
purely for my own personal benefit and pull requests will be evaluated as such. I intend to make the
defaults generally useful but foremost it needs to be useful for my purposes. Pull requests aligning
with my desires will be accepted. Typically I would expect those looking to leverage this framework to
fork it and make their own configuration ***spec.yml***

### Table of Contents
* [Background](#background)
   * [Evolution](#evolution)
   * [My take on Arch](#my-take-on-arch)
   * [Distro requirements](#distro-requirements)
* [Deploy cyberlinux](#deploy-cyberlinux)
    * [Bare metal deployment](#bare-metal-deployment)
    * [Virtual box deployment](#virtual-box-deployment)
    * [Vagrant box deployment](#vagrant-box-deployment)
    * [Deployment Options](#deployment-options)
    * [Deployment Next Steps](#deployment-next-steps)
* [Roll your own cyberlinux](#build-cyberlinux)
    * [Dependency versions](#dependency-versions)
    * [Linux Dev Envioronment](#linux-dev-environment)
    * [Full cyberlinux build](#full-cyberlinux-build)
    * [Pack cyberlinux](#pack-cyberlinux)
    * [Customization](#customization)
        * [Spec Structure](#spec-structure)
        * [Variables](#variables)
        * [Build Layer](#build-layer)
        * [Layers](#layers)
        * [Changes](#changes)
* [Troubleshooting](#troubleshooting)
    * [BlackArch Signature issue](#blackarch-signature-issue)
* [Contributions](#contributions)
    * [Git-Hook Version Increment](#git-hook-version-increment)
* [Licenses](#licenses)

## Background <a name="background"></a>
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

* Single configuration file to drive ISO creation
* ISO must include all packages, config etc... (i.e. works offline)
* Boot splash screen shown with multi-deployment options
* Fast, simple automated installs with abosolute minimal initial user input
* Fully pre-configured user environments to avoid post-install changes
* Live boot option for maintenance, rescue and secure work
* Hardware boot and diagnostics options e.g. RAM validation
* As light as possible while still offering an elegant solution

## Deploy cyberlinux <a name="deploy-cyberlinux"/></a>
There are a number of ways to get up and running quickly with ***cyberlinux***

### Bare metal deployment <a name="bare-metal-deployment"/></a>
Deploy ***cyberlinux*** via a USB directly onto a machine

1. Download the latest [***cyberlinux ISO***](https://github.com/phR0ze/cyberlinux/releases)
2. Burn the ISO to a USB  (Linux)  
    a. Determine correct USB device: ```sudo fdisk -l```  
    b. Burn to USB: ```sudo dd bs=4M if=~/cyberlinux-0.0.159-4.12.13-1-x86_64.iso of=/dev/sdb status=progress```  
3. Boot from the USB and choose the ***cyberlinux-desktop*** deployment option

### Virtual box deployment <a name="virtual-box-deployment"/></a>
Deploy ***cyberlinux*** via a VM using Virtual Box

1. Create a VM named ***cyberlinux-desktop*** with ***4GB RAM, 40GB HDD***  
2. Once created edit ***Settings***  
    a. Set ***System >Processor = 4***  
    b. Set ***Display >Video = 32***  
    c. Set ***Network >Bridged Adapter***  
    d. Set ***Storage >IDE Empty*** to ***cyberlinux-0.0.159-4.12.13-1-x86_64.iso***  
    e. Click ***OK***  
2.	Once booted to the ISO choose the ***cyberlinux-desktop*** deployment option

### Vagrant box deployment <a name="vagrant-box-deployment"/></a>
Deploy ***cyberlinux*** via a VM using a Vagrant Box

```bash
# Create a Vagrantfile describing the cyberlinux-desktop box to use
vagrant init phR0ze/cyberlinux-desktop --box-version 0.0.159
# Download and deploy cyberlinux-desktop box
vagrant up
```

### Deployment Options <a name="deployment-options"/></a>

#### Desktop Deployment <a name="desktop-deployment"/></a>
The ***desktop*** deployment was created to serve as a full developer environment and daily runner.
It is an amalgam of most other deployment options. Although it is the heaviest of the deployments,
resource wise, it is still built with speed and efficiency in mind.

**Requirements:** 
* Development (vscode, go, ruby, python)
* File Sharing (NFS, Torrent, SFTP, FTP)
* Productivity and Office (libreoffice, pdfs)
* Virtual Machines and Containers (virtualbox, docker)
* Media Processing/Consumption (vlc, smplayer, mvp, handbrake, makemkv)

#### Server Deployment <a name="server-deployment"/></a>
The ***server*** deployment was created to serve as a light weight web and file server that would
be run on lower end headless hardware. As such many of the desktop widgets and such have been left
out to facilitate efficient remote desktop sessions.

**Requirements:** 
* Web Server (PHP)
* Telephony Engine (FreeSWITCH, Blink)
* File Sharing (NFS, Torrent, SFTP, FTP)
* Media Processing (Handbrake, makemkv-cli)

```bash
# Deploys a k8snode with ip address of 192.168.56.10
sudo ./reduce deploy --layer=k8snode --nodes=10
```

### Deployment Next Steps<a name="deployment-next-steps"/></a>

## Roll your own cyberlinux <a name="build-cyberlinux"/></a>
This section covers how to roll your own cyberlinux ISO

### Dependency versions <a name="dependency-versions"/></a>
**Working combinations:**  
* ***Kernel=4.11.3-1, Vagrant=1.9.5, Packer=1.0.0, VirtualBox=5.1.22***

**Notes**:  
* Virtual box and packer interation has been iffy as versions have revved.

### Linux dev environment <a name="linux-dev-environment"/></a>
There are three different ways you can get a development environment up and running.
* [Bare metal deployment](#bare-metal-deployment)
* [Virtual box deployment](#virtual-box-deployment)
* [Vagrant box deployment](#vagrant-box-deployment)

### Full cyberlinux Build <a name="full-cyberlinux-build"/></a>
Once you happy with the current configuration build with the following

```bash
# Clone cyberlinux
git clone git@github.com:phR0ze/cyberlinux.git
# Trigger full build
sudo ./reduce clean build --iso-full
```

### Pack cyberlinux <a name="pack-cyberlinux"/></a>
***reduce*** provides the ability to pack any given layer into a vagrant box that can then be
uploaded for public use or deployed locally.

```bash
# Pack all layers, boxes end up in .../cyberlinux/temp/images
./reduce pack
```

To pack a specific deployment for use - e.g. k8snode -  use the following:

1. Pack image: ```./reduce pack --layers=k8snode```
2. Login to https://app.vagrantup.com/session
3. Click ***New Vagrant Box***
4. Set ***Name*** to ***cyberlinux-k8snode*** and ***Short description*** then click ***Create box***
5. Click ***New Version*** to current ***0.0.159*** and click ***Create version*** 
6. Click ***Add a provider*** set ***Provider*** to ***virtualbox*** and click ***Continue to upload***
7. Select the box ***~/Projects/cyberlinux/temp/images/cyberlinux-desktop-0.0.159.box*** 
8. Once uploaded click the ***Finish*** button
9. Compete the process by releasing the box to make it publicly available

### Customization <a name="customization"/></a>
The heart of ***cyberlinux*** is it's ability to provide infinite variations of repeatable
deployments that can be built together into a bootable/installable ISO.  This is driven through
the ***spec.yml*** which is the file documenting all of the packages and configuration to use
when building ***cyberlinux***.

#### Spec Structure <a name="spec-structure"/></a>
```YAML
vars:
  distro: cyberlinux
build:
  name: build
  type: container
  ...
layers:
  - name: base
    packages:
      - { install: machine-core }
    changes:
      - { apply: autologin-config }
      - { exec: 'ln -sf //usr/share/zoneinfo/Zulu /etc/localtime' }
repos:
  - name: archlinux
changes:
  autologin-config:
    - { edit: /etc/lxdm/lxdm.conf, regex: '^#\s*(autologin)=.*', value: '\1=<%= USER %>'
packages:
  machine-core:
    - { install: container-core }
```


#### Variables <a name="variables"/></a>
***vars*** are used for specifying distribution specific values and templating variables.
***cyberlinux*** leverages Ruby's ERB templating in the spec.yml as well as any configuration files
that are called out in the ***spec.yml*** with the ***resolve*** change function. The ***vars***
blocks provide templating variables to use. Variables are evaluated first by pulling in all
variables in the ***vars*** root section the overriding as needed for the specific ***layer***
context that is being evaluated.

```YAML
vars:
  release: 0.0.24
  distro: cyberlinux
  http_proxy: http://web-proxy.example.com:8080
```

#### Build Layer <a name="build-layer"/></a>
The ***build*** layer is a special purpose layer for building ***cyberlinux*** components in an
isolated environment to avoid cluttering up the localhost as well as staying independent from it's
specifics.

#### Layers <a name="layers"/></a>
***Layers*** are granular re-buildable parts of the whole that can be layered to form more complex
parts. They promote reuse. A deployable stack of layers are considered to be a ***deployment***.
Machine layers are installable sqfs images targeting 'baremetal' and 'VMs'. Container layers are
deployable docker images. Files and packages are layered on top of dependency layers. Layers are
built in the order they are listed in the yaml and this is the same order used in the ISO install
menus.

Layers have a ***type*** which is one of two values either ***machine*** or ***container***

##### Default Layers <a name="default-layers"/></a>
**Base Layer**  
The ***base*** layer is a minimal shell environment that is typically inherited by all other machine
layers. Container based layers will not want to inherit from this as ***base*** contains the kernel
and other full system type components not required by containers.

**Shell Layer**  
The ***shell*** layer is a full shell environment inheriting from base, meaning that it has all
tooling needed for development and building applications from the terminal. There are no X11/GUI
componentsa and a bare minimum set of services running.

**Lite Layer**  
The ***lite*** layer builds on top of the shell layer adding in a minimal X11 environment.

**Music Layer**  
The ***music*** layer builds on top of the lite layer adding in Music focused applications.

**Heavy Layer**  
The ***heavy*** layer builds on top of the lite layer fleshing out the applications offerings and
adds a few more running services. This is really the base for all desktop type deployments. Heavy is
the layer required to fully rebuild ***cyberlinux*** from source.

**Desktop Layer**  
The ***desktop*** layer builds on the build layer adding in all normal applications for a full
desktop environmen (e.g. libreoffice and gimp).

**K8sNode Layer**  
The ***k8snode*** layer builds on the shell layer adding in the applications required to easily
use this deployment as a node in a Kubernetes cluster. This includes ***kubectl***, ***helm*** and
K8s networking components.

**Theater Layer**  
theater - full theater environment with couch video playback as the focus

**Server Layer**  
server - server focused environment for file sharing and web apps

**Live Layer**  
live - full maintenance, recovery, or no trace privacy environment

#### Changes <a name="changes"/></a>
***Changes*** are a way to invoke blocks of configuration. They come in two flavors: the actual
change calling out configuration and a change reference which simply groups changes into a block of
changes that can be applied by referencing the change block's name.

Changes must be either defined directly in the ***changes*** section of a ***layer*** or in the top
level ***changes*** section of the ***spec.yml***. Change names when used as a re-usable change
block in the ***changes*** section follow the convention of using an action followed by a short
description separated by a hypen (e.g. ***config-autologin*** or ***remove-docs***).

**Paths** referenced in a change are evaluated in the context of the layer so ***/*** the root
would resolve to a layer's working directory e.g. ***~/Projects/cyberlinux/temp/work/layers/base***
and ***/etc/lxdm/lxdm.conf*** would resolve to
***~/Projects/cyberlinux/temp/work/layers/base/etc/lxdm/lxdm.conf*** when executing in the context
of the ***base*** layer.

In order to actually reference the host files system preced the path with an extra ***/*** such as
***//etc/lxdm/lxdm.conf***.

**Change Structure**
```YAML
# Structure for a change reference
layers:
  - layer: server
    changes:
      - { apply: config-autologin }
      - { exec: 'ln -sf //usr/share/zoneinfo/Zulu /etc/localtime' }
changes:
  config-autologin:
    - { edit: /etc/lxdm/lxdm.conf, regex: '^#\s*(autologin)=.*', value: '\1=<%= USER %>'
```

##### Change <a name="change"/></a>
Changes are a high level description of configuration that needs to take place. Changes support one
of the following mechanisms. Changes are executed in the context of their encompassing ***layer***,
which means that any templating that needs to occur will be evaluated with the layer's ***vars***
overriding any inherited vars (i.e. this makes it possible to use the same change for multiple
different layers with a different value being substituted in via templating and vars).

There are four fundamental changes types: ***apply, edit, exec*** and ***resolve***

| Change Type | Params | Description |
| ----------- | ------ | ----------- |
| apply | change name | Applies the referrenced change in the context of the encompassing ***layer*** |
| chroot | bash script | Variation of ***exec*** but executes in a chroot of the encompassing ***layer*** |
| edit | append, value | Append the given value to the implicated file |
| edit | append, values | Append the given values to the implicated file |
| edit | regex, value | Use regular expressions to match and replace with the given value |
| edit | regex, append, values | Use regular expressions to location an insertion point for the values  |
| exec | bash script | Executes the given bash script in the context of the encompassing ***layer*** |
| resolve | filepath | Resolves ERB templating for the given file in the context of the encompassing ***layer*** |

**Examples**
```YAML
- { apply: config-autologin }
- { chroot: systemctl enable sshd.service }
- { edit: /etc/foo/bar, append: true, value: 'Lorem ipsum de foo bar'}
- { edit: /etc/foo/bar, append: true, values: ['Lorem ipsum', 'de foo bar'] }
- { edit: /etc/lxdm/lxdm.conf, regex: '^#\s*(autologin)=.*', value: '\1=<%= USER %>'
- { edit: /etc/foo/bar, append: after, regex: 'Foo', value: 'Lorem ipsum de foo bar'}
- { edit: /etc/foo/bar, append: after, regex: 'Foo', values: ['Lorem ipsum', 'de foo bar'] }
- { exec: 'ln -sf //usr/share/zoneinfo/Zulu /etc/localtime' }
- { resolve: /etc/os-release }
```

#### Change Block <a name="change-block"/></a>
Change Blocks are listed in the ***changes*** top level seection of ***spec.yml***
```YAML
changes:
```

### Repos <a name="repos"/></a>
Defines the repositories that are available for pulling packages from

## Troubleshooting<a name="troubleshooting"/></a>

### BlackArch Signature issue <a name="blackarch-signature-issue"/></a>
To fix the issue below delete ***/var/lib/pacman/sync/*.sig***

Example: 
```
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
cd ~/Projects/cyberlinux
git config core.hooksPath .githooks
```

<!-- 
vim: ts=2:sw=2:sts=2
-->

## Licenses <a name="licenses"/></a>
Because of the nature of ***cyberlinux*** any licensing will be of a mixed nature.  In some cases as
called out below such as ***reduce*** and the ***boot/initramfs/installer***, created by phR0ze, the
license is MIT. In other cases such as ***gfxboot*** the license is GPL2 as it leverages OpenSUSE's
work.

### ART works
All art works used in the distribution have been carefully selected to be either creative commons,
public domain, or lay claim on fair use licensing. If for some reason a licensing mistake has been
made please let me know and I'll review the claim immediately.

### Reduce, build and Install Scripts
***reduce*** and all Ruby code related to it is licensed below via MIT additionally the
boot/initramfs/installer bash code base is likewise MIT licensed.

MIT License
Copyright (c) 2017 phR0ze

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
