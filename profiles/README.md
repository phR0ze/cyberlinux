# cyberlinux profiles
<img align="left" width="48" height="48" src="https://raw.githubusercontent.com/phR0ze/cyberlinux/master/art/logo_256x256.png">
<b><i>cyberlinux profiles</i></b> were designed to provide a clean declaritive yaml syntax for
building infinitely flexible <b><i>cyberlinux</i></b> deployments.

### Disclaimer
Licensing/copyright use restrictions depend on the packages included in the profile.  Profiles that
are restricted in their use to ***personal use only*** have been named with a preceeding
***personal*** tag. Additionally profiles aimed at specific hardware have been named with a trailing
**arch** called out e.g. ***personal-celes.yml*** which targets the ***Samsung Chromebook 3*** using
its codename and calls out that packages are being included that restrict the use of deployments
created from this profile to personal use only.

### Table of Contents
* [Roll your own cyberlinux](#build-cyberlinux)
    * [Dependencies](#dependencies)
    * [Linux Dev Environment](#linux-dev-environment)
    * [Full cyberlinux build](#full-cyberlinux-build)
        * [Arch Bootstrap deployment](#arch-bootstrap-deployment)
    * [Pack cyberlinux](#pack-cyberlinux)
    * [Customization](#customization)
        * [Profile Structure](#profile-structure)
        * [Variables](#variables)
        * [Build Layer](#build-layer)
        * [Layers](#layers)
        * [Changes](#changes)
* [Troubleshooting](#troubleshooting)
    * [BlackArch Signature issue](#blackarch-signature-issue)
* [Contributions](#contributions)
    * [Git-Hook Version Increment](#git-hook-version-increment)
* [Licenses](#licenses)

## Roll your own cyberlinux <a name="build-cyberlinux"/></a>
This section covers how to roll your own cyberlinux ISO

### Dependencies <a name="dependencies"/></a>
You'll need to install the following packages:
```bash
sudo pacman -S ruby docker
```

### Linux dev environment <a name="linux-dev-environment"/></a>
There are multiple ways you can get a development environment up and running.
* [Bare metal deployment](#bare-metal-deployment)
* [Virtual box deployment](#virtual-box-deployment)
* [Vagrant box deployment](#vagrant-box-deployment)
* [Arch Bootstrap deployment](#arch-bootstrap-deployment)

#### Arch Bootstrap deployment <a name="arch-bootstrap-deployment"/></a>
** This is TBD**

***sudo pacman -S grub mtools***

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
the use of ***profiles*** which are declarative yaml describing all of the packages and configuration
required when building ***cyberlinux***.

#### Profile Structure <a name="profile-structure"/></a>
Example:
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
***cyberlinux*** leverages Ruby's ERB templating in the profiles as well as any configuration files
that are called out in the ***profile*** with the ***resolve*** change function. The ***vars***
block provides templating variables to use. Variables are evaluated first by pulling in all
variables from the ***vars*** block then overriding as needed for the profile ***layer***
context that is being evaluated.

The existing set of base vars below are required, but more can be added as desired:
```YAML
vars:
  arch: x86_64
  release: 0.1.55
  distro: cyberlinux
  timezone: US/Mountain
  country: United_States

  # Vagrant networking
  netname: vboxnet0
  netip: 192.168.56.1
  subnet: 255.255.255.0

  # NFS allowed cidr
  nfscidr: 192.168.56.0/24
```

#### Build Layer <a name="build-layer"/></a>
The ***build*** layer is a special purpose layer for building ***cyberlinux*** components in an
isolated environment to avoid cluttering up the host build machine as well as staying independent
from it's specifics. It is also required.

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
level ***changes*** section of the ***profile***. Change names when used as a re-usable change
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
Change Blocks are listed in the ***changes*** top level seection of ***profile***
```YAML
changes:
```

### Repos <a name="repos"/></a>
Defines the repositories that are available for pulling packages from
