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
* [Cyberlinux Profiles](#cyberlinux-profiles)
  * [Standard Profile](#standard-profile)
  * [Personal Use Profile](#personal-profile)
  * [Personal Use Celes Profile](#personal-celes-profile)
  * [k8snode Profile](#k8snode-profile)
  * [Containers Profile](#containers-profile)
* [Roll your own cyberlinux](#build-cyberlinux)
  * [Dev Environment](#dev-environment)
  * [Full cyberlinux build](#full-cyberlinux-build)
  * [Pack cyberlinux](#pack-cyberlinux)
  * [Profiles](#profiles)
    * [Profile Structure](#profile-structure)
    * [Variables](#variables)
    * [Build](#build)
    * [Deployments](#deployments)
    * [Apps](#apps)
    * [Configs](#configs)
* [Troubleshooting](#troubleshooting)
  * [BlackArch Signature issue](#blackarch-signature-issue)
* [Contributions](#contributions)
  * [Git-Hook Version Increment](#git-hook-version-increment)
* [Licenses](#licenses)

## cyberlinux Profiles <a name="cyberlinux-profiles"/></a>
***cyberlinux Profiles*** provide a way to capture predefined system configurations
and turn them into ISO and Vagrant Box artifacts.  There are serveral predefined profiles to choose
from and the possibility of making endless more.

### Standard Profile <a name="standard-profile"/></a>
The [Standard profile](standard.md) was developed carefully to exclude any applications
that were not free to use for commercial purposes.

### Personal Use Profile <a name="personal-profile"/></a>
The [Personal profile](personal.md) was developed to allow the distribution of applications
for personal use that are not allowed due to licensing restrictions for commercial use.

### Personal Use Celes Profile <a name="personal-celes-profile"/></a>
The [Personal Celes profile](personal-celes.md) was developed specifically for the Samsung
Chromebook 3 (a.k.a celes) with personal use in mind meaning that it includes apps that are not
allowed due to licensing restrictions for commercial use.

### k8snode Profile <a name="k8snode-profile"/></a>
The [k8snode profile](k8snode.md) was developed as a slimmed down shell environment
with Kubernetes dependencies baked in. It includes ***kubectl***, ***kubelet***, ***kubeadm***,
***docker*** and ***helm*** to easily and quickly setup a K8s cluster.

### Containers Profile <a name="containers-profile"/></a>
The [containers profile](containers.md) was developed to provide docker containers for use in the
cloud world, such as deployed as an app in Kubernetes.

## Roll your own cyberlinux <a name="build-cyberlinux"/></a>
This section covers how to roll your own cyberlinux ISO

### Dev Environment <a name="dev-environment"/></a>
In order to get started you'll need to setup your development environment:

1. Install the following packages:
    ```bash
    sudo pacman -S ruby docker
    ```
2. Clone ***cyberlinux*** repo
    ```bash
    git clone git@github.com:phR0ze/cyberlinux.git
    ```

### Full cyberlinux Build <a name="full-cyberlinux-build"/></a>
Build the full ***cyberlinux*** ISO with the following commands

```bash
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

### Profiles <a name="profiles"/></a>
The heart of ***cyberlinux*** is it's ability to provide infinite variations of repeatable
deployments that can be built together into a bootable/installable ISO.  This is driven through
the use of ***profiles*** which are declarative yaml descriptions of everything required when
building a bootable ISO with installable deployments.

**Profiles** all inherit from the ***base*** profile. However top level blocks can be overridden in
the derived profile. For example the ***build*** block can be configured in the base profile to
handle most cases while being overridden in the ***celes*** case to provide an alternate kernel for
the build environment.

#### Profile Structure <a name="profile-structure"/></a>
Example:
```YAML
vars:
  arch: x86_64
  release: 0.1.345
  distro: cyberlinux
  language: en_US
  ...
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
    - { edit: /etc/lxdm/PostLogout, insert: append, values: [ 'killall conky' ]}
  ...
deployments:
  base:
    type: machine
    multilib: true
    groups: [ls, wheel, network, storage, users]
    vars: { fontsize: 10 }
    vagrant: { vram: 32, cpus: 2, ram: 2048 }
    deploy:
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
The first block in the profile is ***vars***. vars are used for specifying distribution specific
values and templating variables. ***cyberlinux*** leverages Ruby's ERB templating throughout
profiles as well as any configuration files that are called out in the ***profile*** with the
***resolve*** function. The ***vars*** block provides the values for the templating variables to
use. Variables are evaluated first by pulling in all variables from the ***vars*** block then
overriding as needed for the profile ***deployment*** context that is being evaluated.

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
The second block in the profile is ***build***. It is a special purpose layer for building
***cyberlinux*** components in an isolated environment to avoid cluttering up the host build machine
as well as staying independent from it's specifics. It is also required.

#### Deployments <a name="deployments"/></a>
The ***deployments*** block comes next and provides top level potentially installable file systems.
Deployments can be layered on top of each other to compose new deployment variations.  Each
deployment is composed of the ***apps*** included in the deployment and any ***configs*** for the
deployment not included with the ***apps***. 

Deployments have a ***type*** which is one of two values either ***machine*** or ***container***
Machine deployments are installable sqfs images targeting 'baremetal' and 'VMs'.  Container
deployments are deployable as docker images. Deployments are built in the order they are listed in
the profile and the same order they are listed in the ISO install menus.

#### Apps <a name="apps"/></a>
The ***apps*** block provides one of the fundamental units of reuse for profiles. An ***app*** is a
descriptive block calling out all desired packages that should be installed and any associated
configuration that should be applied after the installation is complete.

***app*** blocks can be used to describe packages to install and configuration to perform or they
can also reference other app blocks acting as a grouper.

**App Structure**
```YAML
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
```

#### Configs <a name="configs"/></a>
***Configs*** are a way to invoke blocks of configuration using special purpose functions. They come
in two flavors: the actual config calling out configuration or a config reference which simply
groups configs into a block of configs that can be applied by referencing the config block's name.

Configs must be either defined directly in the ***configs*** section of a ***deployment*** or in the
top level ***configs*** section of the ***profile***. Config names when used as a re-usable config
block in the ***configs*** section follow the convention of using an action followed by a short
description separated by a hypen (e.g. ***config-autologin*** or ***remove-docs***).

**Paths** referenced in a config are evaluated in the context of the deployment so ***/*** the root
would resolve to a deployment's working directory e.g. ***~/Projects/cyberlinux/temp/work/deployments/base***
and ***/etc/lxdm/lxdm.conf*** would resolve to
***~/Projects/cyberlinux/temp/work/deployments/base/etc/lxdm/lxdm.conf*** when executing in the context
of the ***base*** deployment.

In order to actually reference the host files system preced the path with an extra ***/*** such as
***//etc/lxdm/lxdm.conf***.

**Config Structure**
```YAML
# Structure for a config reference
deployments:
  - deployment: server
    apps:
      - config-autologin
      - { exec: 'ln -sf //usr/share/zoneinfo/Zulu /etc/localtime' }
configs:
  config-autologin:
    - { edit: /etc/lxdm/lxdm.conf, regex: '^#\s*(autologin)=.*', value: '\1=<%= USER %>'
```

##### Config <a name="config"/></a>
A ***config*** is a high level description of configuration that needs to take place. Configs
support one of the following mechanisms. Configs are executed in the context of their encompassing
***deployment***, which means that any templating that needs to occur will be evaluated with the
deployment's ***vars*** overriding any inherited vars (i.e. this makes it possible to use the same
config for multiple different deployments with a different value being substituted in via templating and
vars).

| Function | Params | Description |
| -------- | ------ | ----------- |
| chroot | bash script | Variation of ***exec*** but executes in a chroot of the encompassing ***deployment*** |
| edit | append, value | Append the given value to the implicated file |
| edit | append, values | Append the given values to the implicated file |
| edit | regex, value | Use regular expressions to match and replace with the given value |
| edit | regex, append, values | Use regular expressions to location an insertion point for the values  |
| exec | bash script | Executes the given bash script in the context of the encompassing ***layer*** |
| menu | category, name, icon, exec | Create a menu entry in the right click menu |
| install | pkg name | install the given packag for the encompassing ***deployment*** |
| resolve | filepath | Resolves ERB templating for the given file in the context of the encompassing ***layer*** |

**Examples**
```YAML
- { chroot: systemctl enable sshd.service }
- { edit: /etc/foo/bar, append: true, value: 'Lorem ipsum de foo bar'}
- { edit: /etc/foo/bar, append: true, values: ['Lorem ipsum', 'de foo bar'] }
- { edit: /etc/lxdm/lxdm.conf, regex: '^#\s*(autologin)=.*', value: '\1=<%= USER %>'
- { edit: /etc/foo/bar, append: after, regex: 'Foo', value: 'Lorem ipsum de foo bar'}
- { edit: /etc/foo/bar, append: after, regex: 'Foo', values: ['Lorem ipsum', 'de foo bar'] }
- { exec: 'ln -sf //usr/share/zoneinfo/Zulu /etc/localtime' }
- { install: linux-celes, desc: Linux kernel and supporting modules, type: CYBERLINUX }
- { menu: Accessories, entry: KeePass, icon: /usr/share/icons/hicolor/32x32/apps/keepass.png, exec: keepass }
- { resolve: /etc/os-release }
```
