cyberlinux FLATPAK documentation
====================================================================================================
<img align="left" width="48" height="48" src="../art/logo_256x256.png">
<b><i>cyberlinux</i></b> was designed to provide the unobtrusive beauty and power of Arch Linux as a
fully customized automated offline multi-deployment ISO. Using clean declarative yaml profiles,
cyberlinux is able to completely customize and automate the building of Arch Linux filesystems
which are bundled as a bootable ISO. Many common use cases are available as deployment options
right out of the box, but the option to build your own infinitely flexible deployment is yours
for the taking.

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***.

### Quick links
* [.. up dir](..)
* [Flatpak Overview](#flatpak-overview)
* [Config flatpak](#config-flatpak)
  * [Install flatpak](#install-flatpak)
  * [Update flatpak database](#update-flatpak-database)
  * [Search for flatpak package](#search-for-flatpak-package)
  * [List flatpak packages](#list-flatpak-packages)
  * [Install/Update flatpak package](#install-update-flatpak-package)
  * [Run flatpak package](#run-flatpak-package)
* [Build flatpak packages](#build-flatpak-packages)

# Flatpak Overview <a name="flatpak-overview"/></a>
[Flatpak](https://flatpak.org/) provides the ability to have Linux apps that run anywhere by
including the applications dependencies with the application.

**Resources**
* [Flatpak docs](https://docs.flatpak.org/en/latest/)
* [Arch Linux docs](https://wiki.archlinux.org/index.php/Flatpak)
* [Comparision of Flatpak](https://github.com/AppImage/AppImageKit/wiki/Similar-projects#comparison)

## Config flatpak <a name="config-flatpak"/></a>
Binaries are installed to `/var/lib/flatpak/exports/bin` which gets added to the path by
`/etc/profile.d/flatpak-bindir.sh`

### Install flatpak <a name="install-flatpak"/></a>
```bash
$ sudo pacman -S flatpak flatpak-builder elfutils patch xdg-desktop-portal-gtk fakeroot fakechroot
```

### Update flatpak database <a name="update-flatpak-database"/></a>
By default flatpak comes preconfigured to use its upstream `flathub` repo but we need to update the
local database to reflect what is there.

```bash
$ flapak update
```

### Search for flatpak package <a name="search-for-flatpak-package"/></a>
```bash
$ flatpak search libreoffice
```

### List flatpak packages <a name="list-flatpak-packages"/></a>

**List installed**
```bash
$ flatpak list
```

**List Remote**
```bash
$ flatpak remote-ls
```

### Install/Update flatpak package <a name="install-update-flatpak-package"/></a>

**Install package**
```bash
$ flatpak install <name>
```

**Update package**
```bash
$ flatpak update <name>
```

### Run flatpak package <a name="run-flatpak-package"/></a>
```bash
$ flatpak run <name>
```

### Uninstall flatpak package <a name="uninstall-flatpak-package"/></a>

**Standard uninstall**
```bash
$ flatpak uninstall <name>
```

**Remove orphans**
```bash
$ flatpak uninstall --unused
```

### Viewing sandbox permissions <a name="viewing-sandbox-permissions"/></a>
Flatpak applications come with predefined sandbox rules which defines the resources and file system
paths the application is allowed to access.

**View permissions**
```bash
$ flatpak info --show-permissions <package>
```

## Build flatpak packages <a name="build-flatpak-packages"/></a>
* warcraft 2
* hedgewars

<!-- 
vim: ts=2:sw=2:sts=2
-->
