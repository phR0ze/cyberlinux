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
        * [Build](#build)
        * [Deployments](#deployments)
        * [Apps](#apps)
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
**This is still TBD**

### Full cyberlinux Build <a name="full-cyberlinux-build"/></a>
Once you happy with the current configuration build with the following

```bash
# Clone cyberlinux
git clone git@github.com:phR0ze/cyberlinux.git

# Change directory into the newly cloned repo
cd cyberlinux

# Install ruby dependencies
bundle install --system

# Trigger full build
sudo ./reduce clean build --iso-full
```

### Pack cyberlinux <a name="pack-cyberlinux"/></a>
***reduce*** provides the ability to pack any given deploymet into a vagrant box that can then be
uploaded for public use or deployed locally.

```bash
# Pack all deployments, boxes end up in .../cyberlinux/temp/images
./reduce pack
```

To pack a specific deployment for use - e.g. k8snode -  use the following:

1. Pack image: `./reduce pack --deployments=k8snode`
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
the use of ***profiles*** which are declarative yaml descriptions of everything required when
building a bootable ISO with installable deployments.

#### Profile Structure <a name="profile-structure"/></a>
Example:
```YAML
build:
  type: container
  multilib: true
  docker:
    params: '-e TERM=xterm -v /var/run/docker.sock:/var/run/docker.sock --privileged=true'
    command: 'bash -c "while :; do sleep 5; done"'
  apps:
    - { install: linux-celes,                     desc: Linux kernel and supporting modules, type: CYBERLINUX }
    - core
    - core-tools
    - grub
  configs:
  ...
deployments:
  base:
    type: machine
    multilib: true
    groups: [ls, wheel, network, storage, users]
    vars: { fontsize: 10 }
    vagrant: { vram: 32, cpus: 2, ram: 2048 }
    install:
      entry: "Deploy <%=distro%>-base                    // Minimal shell"
      kernel: linux-celes
    apps:
      - server-apps
  ...
apps:
  base-apps:
    - conky
    - { install: curl, desc: Network download REST command line tool }
  server-apps:
    - base-apps
    - phpBB
    - { edit: /etc/httpd/conf/httpd.conf, regex: '^(Listen).*', value: '\1 80' }
    - { chroot: systemctl enable httpd.service }
  conky:
    - { install: conky, desc: Lightweight system monitor for X }
    - { menu: Settings, entry: Conky RC, icon: /usr/share/icons/Paper/32x32/apps/gvim.png, exec: gvim ~/.conkyrc }
    - { edit: /etc/lxdm/PostLogout, insert: append, values: [ 'killall conky' ]}
  phpBB:
    - { install: apache, desc: Apache web server }
    - { install: php-apache, desc: PHP apache module }
    - { install: php-sqlite, desc: PHP sqlite module }
    - { install: php-gd, desc: PHP gd module }
    - { edit: /etc/httpd/conf/httpd.conf, regex: '^(DocumentRoot).*', value: '\1 /srv/http' }
    - { edit: /etc/httpd/conf/httpd.conf, regex: '^(.*DirectoryIndex index.html).*', value: '\1 index.php' }
    - { edit: /etc/httpd/conf/httpd.conf, regex: '^(LoadModule mpm_event.*)', value: '#\1' }
```

#### Variables <a name="variables"/></a>
***vars*** are used for specifying distribution specific values and templating variables.
***cyberlinux*** leverages Ruby's ERB templating in the profiles as well as any configuration files
that are called out in the ***profile*** with the ***resolve*** function. The ***vars***
block provides templating variables to use. Variables are evaluated first by pulling in all
variables from the ***vars*** block then overriding as needed for the profile ***deployment***
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

#### Build <a name="build"/></a>
The ***build*** layer is a special purpose layer for building ***cyberlinux*** components in an
isolated environment to avoid cluttering up the host build machine as well as staying independent
from it's specifics. It is also required.

#### Deployments <a name="deployments"/></a>
Deployments can be layered on top of each other to build a variation of the
underlying deployment.  Each deployment has a list of ***apps*** included in the deployment.
***Apps*** are a group of packages to install and configuration changes that constitute the app.

***Layers*** are granular re-buildable parts of the whole that can be layered to form more complex
parts. They promote reuse. A deployable stack of layers are considered to be a ***deployment***.
Machine layers are installable sqfs images targeting 'baremetal' and 'VMs'. Container layers are
deployable docker images. Files and packages are layered on top of dependency layers. Layers are
built in the order they are listed in the yaml and this is the same order used in the ISO install
menus.

Layers have a ***type*** which is one of two values either ***machine*** or ***container***

#### Apps <a name="apps"/></a>
***Apps*** is a list of type ***App*** which are individual components that describe both the packages
that will be installed for the given application and the associated configuration to apply.

***app*** blocks are one of the fundamental elements of reuse in the profile. They can be used to
capture packages to install and configuration to perform. They can also reference other app blocks.

**App Structure**
```YAML
# Structure for an app
layers:
  - layer: server
    changes:
      - { apply: config-autologin }
      - { exec: 'ln -sf //usr/share/zoneinfo/Zulu /etc/localtime' }
changes:
  config-autologin:
    - { edit: /etc/lxdm/lxdm.conf, regex: '^#\s*(autologin)=.*', value: '\1=<%= USER %>'
```

##### Changes <a name="changes"/></a>
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
