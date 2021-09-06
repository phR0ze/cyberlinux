cyberlinux installer documentation
====================================================================================================

<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documenting resource documentation around the <b><i>cyberlinux installer</i></b>

### Quick Links
* [.. up dir](https://github.com/phR0ze/cyberlinux)
* [Overview](#overview)
  * [initramfs installer](#initramfs-installer)
    * [create initramfs](#create-initramfs)
* [mkinitcpio](#mkinitcpio)
  * [mkinitcpio-vt-colors](#mkinitcpio-vt-colors)
  * [docker mkinitcpio issues](#docker-mkinitcpio-issues)
    * [autodetect](#autodetect)
    * [arch-chroot](#arch-chroot)
* [Boot Loaders](#boot-loaders)
  * [BIOS Firmware](#bios-firmware)
  * [UEFI Firmware](#uefi-firmware)
  * [Clover](#clover)
    * [Install Clover (USB)](#install-clover-usb)
    * [Install Clover (SSD)](#install-clover-ssd)
  * [rEFInd](#rEFInd)
    * [rEFInd vs GRUB2](#rEFInd-vs-grub2)
  * [GRUB2](#grub2)
    * [GRUB structure](#grub-structure)
    * [grub-mkimage](#grub-mkimage)
    * [GFXMenu module](#gfxmenu-module)
    * [Trouble-shooting](#trouble-shooting)

# Overview <a name="overview"/></a>
**Goals:** *boot speed*, *simplicity*, and *automation*

Installing Linux on a target system typically consists of booting into a full live system and then
launch a full GUI with wizard to walk you through the installtion process. The downsides of this are
it takes a long time to boot into the live system and it isn't well suited for automating an install
process from boot. The other method which I'll use for `cyberlinux` is a minimal graphical
environment that launches from a pre-boot environment. Fedora's Anaconda or Ubuntu's minimal ncurses
based installers are examples of this. The concept is to build an early user space image typically
known as an `initramfs` that will contain enough tooling to setup and install your system.

We'll use GRUB to handle booting and presenting the same boot menu regardless of the under lying BIOS
or UEFI hardware systems. The GRUB menu will then launch our installer.

## initramfs installer <a name="initramfs-installer"/></a>
The initial ramdisk is in essence a very small environment (a.k.a early userspace) which contains
customizable tooling and instructions to load kernel modules as needed to set up necessary things
before handing over control to `init`. We can leverage this early userspace to build a custom install
environment containing all the tooling required to setup our system before than rebooting into it.

The installer is composed of three files:
1. `installer` is an initcpio hook and the heart of the installer
2. `installer.conf` initcpio hook configuration for what to include in the installer hook
3. `mkinitcpio.conf` configuration file to construct the initramfs early userspace environment

### Create initramfs <a name="create-initramfs"/></a>
An initramfs is made by creating a `cpio` archive, which is an old simple archive format comparable
to tar. This archive is then compressed using `gzip`.

# mkinitcpio <a name="mkinitcpio"/></a>

## mkinitcpio-vt-colors <a name="mkinitcpio-vt-colors"/></a>
The color of the kernel messages that are output during boot time can be controlled with a mkinitcpio
hook for color configuration.

1. Install `mkinitcpio-vt-colors`
2. Update `/etc/mkinitcpio.conf` to include the `vt-colors` hook
3. Rebuild the initramfs early boot image

## docker mkinitcpio issues <a name="docker-mkinitcpio-issues"/></a>
The intent is to be able to build a full multiboot ISO with only the minimal dependencies so its easy
to reproduce the ISO on any arch linux based system or virtual machine. After some initial research
it became obvious the easiest route was going to be using containers.

`arch-chroot` and `mount` etc.. require teh `--privileged=true` option to work correctly with docker.

### autodetect <a name="autodetect"/></a>
`mkinitcpio` when running in a docker container will `autodetect` that the docker overlay system
being used and try to add it as a module. To solve this you need to:

Edit the `/etc/mkinitcpio.conf` and remove the `autodetect` option

### arch-chroot <a name="arch-chroot"/></a>
Originally I tried to use `arch-chroot` only for isolation but ran into odd issues when the kernel
didn't match the host kernel. Obviously the jail was leaking.

Example:
```
[root@main4 /]# ls -la /lib/modules
total 36
drwxr-xr-x  3 root root  4096 Jul 30 03:29 .
drwxr-xr-x 47 root root 24576 Jul 30 03:29 ..
drwxr-xr-x  3 root root  4096 Jul 30 03:29 5.13.6-arch1-1
[root@main4 /]# mkinitcpio -g /root/installer
==> ERROR: '/lib/modules/5.12.15-arch1-1' is not a valid kernel module directory
[root@main4 /]# exit
exit
```

# Boot Loaders <a name="boot-loaders"/></a>
UEFI devices now have alternative options for boot loaders that provide options for image display,
custom fonts, and menus either on par or more advanced than the venerable GRUB2's GFXMenu in
functionality. It might be time to find a new boot loader.

**References**:
* [Arch Linux Early User space](http://archlinux.me/brain0/2010/02/13/early-userspace-in-arch-linux/)

## BIOS Firmware <a name="bios-firmware"/></a>
BIOS was developed in the 1970s and was prevelant till the late 2000s when it began to be gradually
replaced by EFI. BIOS provides a basic text-based interface.

### BIOS boot process <a name="bios-boot-process"/></a>
BIOS looks at the first segment of the drive to find the bootloader. Traditionally this was a `MBR`
partitioning sceme; however `GPT` partitioning part of the `EFI` spec can be used instead if done
correctly. In order to accomplish this you need to create a `GPT protective MBR`. The only caveat is
the boot loader needs to be GPT aware which pretty much all Linux compatible bootloaders are. Instead
of injecting the boot loader into the MBR space in the first partition you need to create a new `BIOS
Boot Partition` code `EF02`.

By leveraging the `GPT BIOS Boot Partition EF02` on a BIOS system and instead a normal `ESP EF02`
boot partition on UEFI systems we create a configuration that is bootable by modern EFI bootloaders
like Clover in either case. This means we can create a single Clover custom UI that will boot and be
used on either BIOS or UEFI.

## UEFI Firmware <a name="uefi-firmware"/></a>
From about 2010 on all computers have been using UEFI as their firmware to interface with the mother
board rather than thd old BIOS firmware. 

Note: `UEFI` is essentially `EFI 2.0`

Most EFI boot loaders and boot managers reside in their own subdirectories inside the `EFI` directory
on the `EFI System Partition (ESP)` e.g. `/dev/sda1` mounted at `/boot` thus
`/boot/efi/<bootloader>`.

### EFI boot process <a name="efi-boot-process"/></a>
UEFI firmware identifies the `ESP` (i.e. partition with code `ef00` formatted as `FAT32`) and loads
the binary target at `/efi/boot/bootx86.efi` which can be either a boot manager or bootloader. Either
way the binary target then loads the target kernel or target bootloader which loads the target
kernel.

## Clover <a name="clover"/></a>
Clover EFI is a boot loader developed to boot OSX, Windows and Linux in legacy or UEFI mode.

**References**:
* [Arch Linux - Clover](https://wiki.archlinux.org/title/Clover)

**Features**:
* Emulate UEFI on legacy BIOS systems which allows you to boot into EFI mode from legacy mode so you
can share the same `efi` files and UI
* Support native resolution GUI with icons, fonts and other UI elements with mouse support
* Easy to use and customize

### Install Clover (USB) <a name="install-clover-usb"/></a>
1. Install the clover pacakge
   ```bash
   $ sudo pacman -S clover
   ```
2. Copy the install files to the boot location
   ```bash
   $ cp -r /usr/lib/clover/EFI/BOOT iso/EFI
   $ cp -r /usr/lib/clover/EFI/CLOVER iso/EFI
   ```
3. Building the ISO
   ```bash
   xorriso \
    \
    `# Configure general settings` \
    -as mkisofs                                     `# Use -as mkisofs to support options like grub-mkrescue does` \
    -volid CYBERLINUX_INSTALLER                     `# Identifier installer uses to find the install drive` \
    --modification-date=$(date -u +%Y%m%d%H%M%S00)  `# Date created YYYYMMDDHHmmsscc e.g. 2021071223322500` \
    -r -iso-level 3 -full-iso9660-filenames         `# Use Rock Ridge and level 3 for standard ISO features` \
    \
    `# Configure BIOS bootable settings` \
    -b boot/grub/i386-pc/eltorito.img               `# El Torito boot image enables BIOS boot` \
    -no-emul-boot                                   `# Image is not emulating floppy mode` \
    -boot-load-size 4                               `# Specifies (4) 512byte blocks: 2048 total` \
    -boot-info-table                                `# Updates boot image with boot info table` \
    \
    `# Configure UEFI bootable settings` \
    -eltorito-alt-boot                              `# Separates BIOS settings from UEFI settings` \
    -e boot/grub/efi.img                            `# EFI boot image on the iso post creation` \
    -no-emul-boot                                   `# Image is not emulating floppy mode` \
    -isohybrid-gpt-basdat                           `# Announces efi.img is FAT GPT i.e. ESP` \
    \
    `# Specify the output iso file path and location to turn into an ISO` \
    -o "${CONT_OUTPUT_DIR}/cyberlinux.iso" "$CONT_ISO_DIR"
   ```

### Install Clover (SSD) <a name="install-clover-ssd"/></a>

## rEFInd <a name="rEFInd"/></a>
`rEFInd themes` are quite intriguing providing custom icons, images, fonts and menus that surpass
what GRUB2 offers.

References:
* [The rEFInd Boot Manager](https://www.rodsbooks.com/refind/)
* [Theming rEFInd](https://www.rodsbooks.com/refind/themes.html)
* [rEFInd vs GRUB](https://askubuntu.com/questions/760875/any-downside-to-using-refind-instead-of-grub)

### rEFInd vs GRUB2 <a name="refind-vs-grub2"/></a>
* rEFInd features
  * scans for kernels on every boot making it more adaptive and less reliant on config files.
  * configuration files are simpler and is easier to tweak
  * has `more eye candy`
  * can boot from CD or USB stick
  * has an arch linux package
* rEFInd downsides
  * has a single developer
  * doesn't support as many platforms as GRUB
  * getting `Shim` to work with rEFInd is harder

## GRUB2 <a name="grub2"/></a>
[GRUB2](https://www.gnu.org/software/grub) offers the ability to easily create a bootable USB drive
for both BIOS and UEFI systems as well as a customizable menu for arbitrary payloads. This
combination is ideal for a customizable initramfs based installer. Using GRUB2 we can boot on any
system with a custom splash screen and menus and then launch our initramfs installer which will
contain the tooling necessary to install the system. After which the initramfs installer will reboot
the system into the newly installed OS.

**References**:
* [GRUB lower level](http://www.dolda2000.com/~fredrik/doc/grub2)
* [GRUB Documentation](https://www.gnu.org/software/grub/manual/grub/html_node/index.html)
* [GRUB Developers Manual](https://www.gnu.org/software/grub/manual/grub-dev/html_node/index.html)
* [GFXMenu Components](https://www.gnu.org/software/grub/manual/grub-dev/html_node/GUI-Components.html#GUI-Components)

### GRUB structure <a name="grub-structure"/></a>
GRUB is composed of a `kernel` which contains the fundamental features from memory allocation to
basic commands the module loader and a simplistic rescue shell. The `modules` can be loaded by the
kernel to add functionality such as additional commands or support for various filesystems. The `core`
image which is constructed via `grub-mkimage` consists of the `kernel` the `specified modules` the
`prefix string` put together in a platform specific format.

Once GRUB is running the first thing it will do is try to load modules from the `prefix string`
location post fixed with the architecture e.g. `/boot/grub/x86_64-efi`. The modules included in the
core image are just enough to be able to load additional modules from the real filesystem usually
bios and filesystem modules.

### grub-mkimage <a name="grub-mkimage"/></a>
***grub-mkimage*** is the key to building GRUB bootable systems. All of GRUB's higher level utilities
like `grub-[install,mkstandalone,mkresuce]` all use `grub-mkimage` to do their work.

Resources:
* [GRUB on ISO](https://sites.google.com/site/grubefikiss/grub-on-iso-image)
* [GRUB image descriptions](https://www.gnu.org/software/grub/manual/grub/html_node/Images.html)
* [grub-mkstandalone](https://willhaley.com/blog/custom-debian-live-environment-grub-only/#create-bootable-isocd)
* [GRUB2 bootable ISO with xorriso](http://lukeluo.blogspot.com/2013/06/grub-how-to-2-make-boot-able-iso-with.html)

Essential Options:
* `-c, --config=FILE` is only required if your not using the default `/boot/grub/grub.cfg`
* `-O, --format=FORMAT` calls out the platform format e.g. `i386-pc` or `x86_64-efi`
* `-o DESTINATION` output destination for the core image being built e.g. `/efi/boot/bootx64.efi`
* `-d MODULES_PATH` location to modules during construction defaults to `/usr/lib/grub/<platform>`
* `-p /boot/grub` directory to find grub once booted i.e. prefix directory
* `space delimeted modules` list of modules to embedded in the core image
  * `i386-pc` minimal are `biosdisk part_msdos fat`

#### BIOS grub-mkimage <a name="bios-grub-mkimage"/></a>
```bash
local shared_modules="iso9660 part_gpt ext2"

# Stage the grub modules
# GRUB doesn't have a stable binary ABI so modules from one version can't be used with another one
# and will cause failures so we need to remove then all in advance
cp -r /usr/lib/grub/i386-pc iso/boot/grub
rm -f iso/boot/grub/i386-pc/*.img

# We need to create our core image i.e bios.img that contains just enough code to find the grub
# configuration and grub modules in /boot/grub/i386-pc directory
# -p /boot/grub                 Directory to find grub once booted, default is /boot/grub
# -c /boot/grub/grub.cfg        Location of the config to use, default is /boot/grub/grub.cfg
# -d /usr/lib/grub/i386-pc      Use resources from this location when building the boot image
# -o temp/bios.img              Output destination
grub-mkimage --format i386-pc -d /usr/lib/grub/i386-pc -p /boot/grub \
  -o temp/bios.img biosdisk ${shared_modules}

echo -e ":: Concatenate cdboot.img to bios.img to create CD-ROM bootable eltorito.img..."
cat /usr/lib/grub/i386-pc/cdboot.img temp/bios.img" > iso/boot/grub/i386-pc/eltorito.img
```

#### UEFI grub-mkimage <a name="uefi-grub-mkimage"/></a>
The key to making a bootable UEFI USB is to embedded the grub `BOOTX64.EFI` boot image inside an
official `ESP`, i.e. FAT32 formatted file, at `/EFI/BOOT/BOOTX64.EFI` then pass the resulting
`efi.img` to xorriso using the `-isohybrid-gpt-basdat` flag.

Resources:
* [UEFI only bootable USB](https://askubuntu.com/questions/1110651/how-to-produce-an-iso-image-that-boots-only-on-uefi)

**xorriso UEFI bootable settings**
```bash
-eltorito-alt-boot               `# Separates BIOS settings from UEFI settings` \
-e boot/grub/efi.img             `# EFI boot image on the iso filesystem` \
-no-emul-boot                    `# Image is not emulating floppy mode` \
-isohybrid-gpt-basdat            `# Announces efi.img is FAT GPT i.e. ESP` \
```

**ESP creation including grub-mkimage bootable image**
```bash
mkdir -p iso/EFI/BOOT

# Stage the grub modules
# GRUB doesn't have a stble binary ABI so modules from one version can't be used with another one
# and will cause failures so we need to remove then all in advance
cp -r /usr/lib/grub/x86_64-efi iso/boot/grub
rm -f iso/grub/x86_64-efi/*.img

# We need to create our core image i.e. BOOTx64.EFI that contains just enough code to find the grub
# configuration and grub modules in /boot/grub/x86_64-efi directory.
# -p /boot/grub                   Directory to find grub once booted, default is /boot/grub
# -c /boot/grub/grub.cfg          Location of the config to use, default is /boot/grub/grub.cfg
# -d /usr/lib/grub/x86_64-efi     Use resources from this location when building the boot image
# -o iso/EFI/BOOT/BOOTX64.EFI     Using wellknown EFI location for fallback compatibility
grub-mkimage --format x86_64-efi -d /usr/lib/grub/x86_64-efi -p /boot/grub \
  -o iso/EFI/BOOT/BOOTX64.EFI fat efi_gop efi_uga ${shared_modules}

echo -e ":: Creating ESP with the BOOTX64.EFI binary"
truncate -s 8M iso/boot/grub/efi.img
mkfs.vfat iso/boot/grub/efi.img
mkdir -p temp/esp
sudo mount iso/boot/grub/efi.img temp/esp
sudo mkdir -p temp/esp/EFI/BOOT
sudo cp iso/EFI/BOOT/BOOTX64.EFI temp/esp/EFI/BOOT
sudo umount temp/esp
```

### GFXMenu module <a name="gfxmenu-module"/></a>
The [gfxmenu](https://www.gnu.org/software/grub/manual/grub-dev/html_node/Introduction_005f2.html#Introduction_005f2)
module provides a graphical menu interface for GRUB 2. It functions as an alternative to the menu
interface provided by the `normal` module. The graphical menu uses the GRUB video API supporting
VESA BIOS extensions (VBE) 2.0+ and supports a number of GUI components.

`gfxmenu` supports a container-based layout system. Components can be added to containers, and
containers (which are a type of component) can then be added to other containers, to form a tree of
components. The root component of the tree is a `canvas` component, which allows manual layout of its
child components.

**Non-container components**:
* `label`
* `image`
* `progress_bar`
* `circular_progress`
* `list`

**Container components**:
* `canvas`
* `hbox`
* `vbox`

The GUI component instances are created by the theme loader in `gfxmenu/theme_loader.c` when a them
is loaded.

### Trouble-shooting <a name="trouble-shooting"/></a>

#### Keyboard not working <a name="keyboard-not-working"/></a>
Booting into the ACEPC AK1 I found that GRUB had no keyboard support. After some research I found
that newer systems use `XHCI` mode for USB which is a combination of USB 1.0, USB 2.0 and USB 3.0 and
is newer. On newer Intel motherboards XHCI is the only option meaning that there is no way to fall
back on EHCI.

**Research:**
* XHCI GRUB module?
  * I see a `uhci.mod ehci.mod usb_keyboard.mod` in `/usr/lib/grub/i386-pc`
  * `uhci.mod` supports USB 1 devices
  * `ehci.mod` supports USB 2 devices
  * `xhci.mod` supports all USB devices including USB 3
* Use Auto rather than Smart Auto or Legacy USB in BIOS
  * Doesn't seem to help

Turns out that GRUB2 doesn't have any plans to support xHCI. After digging into this futher it
appears that the community in the UEFI age is pulling away from GRUB2 as the boot manager of choice.
There are other options out there for newer systems like [rEFInd](#rEFInd)

#### incompatible license <a name="incompatible-license"/></a>
If you get an ugly GRUB license error as follows upon boot you'll need to re-examine the GRUB modules
you've included on your EFI boot.
```
GRUB loading...
Welcome to GRUB!

incompatible license
Aborted. Press any key to exit.
```
During boot `GRUB` will check for licenses embedded in the EFI boot modules. You can test ahead of
time to see of any are flagged. Acceptable licenses are `GPLv2+`, `GPLv3` and `GPLv3+`.

Following the instructions in [Test USB in VirtualBox](#test-usb-in-virtualbox) I was able to
determine that the problem existed in VirtualBox as well so its not unique to the target machine I
was attempting to test my USB on. This means that either:

* A non-compliant licensed module being included could cause this
  * Looking through all modules wih `for x in *.mod; do strings $x | grep LICENS; done` revealed
  everything is kosher.
* GRUB doesn't have a stable binary ABI so mixing modules versions could cause this
  * Ensuring that all modules were removed before recreating didn't help
* Copying the ISO to the USB incorrectly may cause this
  * Validated the same process with the Arch Linux ISO and it works 
* The construction of the GRUB boot images isn't accurate
  * I dropped it down to the minimal modules, possible this helped but unlikely
* The construction of the ISO isn't accurate
  * I believe the issue was the xorriso properties I had used. After switching back to the original
  xorriso settings from cyberlinux 1.0 I fixed it.

<!-- 
vim: ts=2:sw=2:sts=2
-->
