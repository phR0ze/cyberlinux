# Kernel for the Samsung Chromebook 3 (a.k.a. CELES)
Arch Linux based Kernel for the Samsung Chromebook 3 (a.k.a CELES). Celes is running the
Atom-based SoC code named Braswell replacing the previous-generation Bay Trail family.

I'm borrowing from the execellent Arch, Manjaro and GalliumOS projects as well as some other
sources.

* http://ck.kolivas.org/patches/muqss
* https://github.com/manjaro/packages-core/tree/master/linux415
* https://github.com/GalliumOS/linux/tree/v4.14.14-galliumos/galliumos/diffs
* https://git.archlinux.org/svntogit/packages.git/tree/trunk?h=packages/linux
* https://github.com/felixonmars/aur3-mirror/tree/master/linux-chromebook
* https://github.com/GalliumOS/galliumos-distro/issues/270

### Table of Contents
* [Building the Kernel](#building-the-kernel)
  * [Use Kernel Compression](#use-kernel-compression)
  * [Braswell Sound Driver ](#braswell-sound-driver)
  * [Braswell Touchpad/Keyboard Driver](#braswell-touchpad-keyboard-driver)
* [Patches](#patches)
  * [GalliumOS](#galliumos)
    * [Config Changes](#config-changes)
    * [0001-add-touchpad-touchscreen-support](#0001-add-touchpad-touchscreen-support)
    * [0003-suppress-tpm-error-msg](#0003-suppress-tpm-error-msg)
    * [0004-check-atom-pmc-platform-clocks](#0004-check-atom-pmc-platform-clocks)
    * [0008-avoid-drm-i915-pps-state-mismatch](#0008-avoid-drm-i915-pps-state-mismatch)
* [Deprecated Patches](#deprecated-patches)
  * [GalliumOS](#galliumos)
    * [backout-drm-1915-link-rate-fallback](#backout-drm-1915-link-rate-fallback)
    * [sync-plbossart-sound-intel-audio](#sync-plbossart-sound-intel-audio)
    * [mask-and-clear-cherryview-irqs](#mask-and-clear-cherryview-irqs)
    * [prevent-mmcblk-rpmb-errors](#prevent-mmcblk-rpmb-errors)
    * [add-aufs-4.16.diff](#add-aufs-4-16-diff)
* [Other Research](#other-research)
  * [Schedulers](#schedulers)
    * [MuQSS Scheduler](#muqss-scheduler)
    * [BFQ Scheduler](#bfq-scheduler)
    * [Con Kolivas Patches](#con-kolivas-patches)
 
# Building the Kernel <a name="building-the-kernel"/></a>
Arch Linux does an excellent job putting together their kernel. We'll start from this base and only
tweak it where necessary for CELES.

1. Download the Arch Linux Kernel configs
   ```bash
   $ yay -G linux
   ```
2. Copy in and overwrite all supporting files as they are used as is
   ```bash
   $ linux/60-linux.hook .
   $ linux/90-linux.hook
   $ linux/config .
   $ linux/linux.install .
   $ linux/linux.preset .
   ```
3. Deal with the PKGBUILD differences, should be minimal only version and patches
4. Any config changes should be stored as patches in `patches/config`

## Use Kernel Compression <a name="use-kernel-compression"/></a>
Typically disk I/O is the slowest component on a pc. By loading a compressed kernel then
decompressing into memory we save time. GZIP is almost as good as XZ compression but much easier on
the CPU, which ***celes*** has little of

* Enable `CONFIG_KERNEL_GZIP=y`
* Disable `# CONFIG_KERNEL_XZ is not set`

## Braswell Sound Driver <a name="braswell-sound-driver"/></a>
The Linux 5.2 Kernel added support for the Braswell DSP sound hardware

???
* Enable ***CONFIG_SND_SOC_INTEL_CHT_BSW_RT5645_MACH=y***

## Braswell Touchpad/Keyboard Driver <a name="braswell-touchpad-keyboard-driver"/></a>
The Cherryview hardware driver must be enabled to support braswell

Arch linux already has this value configured
* Enable `CONFIG_PINCTRL_CHERRYVIEW=y`

# Patches <a name="patches"/></a>
I've included a handlful of patches from other projects as called out below:

## GalliumOS <a name="galliumos"/></a>
GalliumOS is a fast and lightweight Linux distro made for Chrombooks and Chromeboxes. GalliumOS
delivers a complete linux environment with fully hardware support, a carfully tuned kernel and a
full-featured and attractive desktop. In practice I found it to be a bit bloated and not tuned well
to my specific Samsung Chromebook 3 CELES. What really turned me off was that it wouldn't install out
of the box. But they do have some fixes and kernel tweaks that work well.

Features:
* BFQ for I/O scheduling
* BFS for process scheduling
* Removed unnecessary kernel features/modules
* Zram for swap which is much faster than disk
* Touchpad driver customized for chromebooks
* Fixes for device specific bugs

Patches enabling the features:
* https://github.com/GalliumOS/linux/tree/v4.16.18-galliumos/galliumos

### Config Changes <a name="config-changes"/></a>

Disable IPv6 - saves overhead of loading unused modules
* Set `CONFIG_NFT_CHAIN_NAT_IPV6=m `
* Set `CONFIG_NFT_MASQ_IPV6=m`
* Set `CONFIG_NFT_REDIR_IPV6=m`

Disable Atom PCI/ACPI
* Set `# CONFIG_SND_SST_ATOM_HIFI2_PLATFORM_PCI is not set`
* Set `CONFIG_SND_SST_ATOM_HIFI2_PLATFORM_ACPI=m`

### 0001-add-touchpad-touchscreen-support <a name="0001-add-touchpad-touchscreen-support"/></a>
Add necessary tweaks for the kernel to recognize the ***celes*** hardware and invoke the correct
drivers

### 0003-suppress-tpm-error-msg <a name="0003-suppress-tpm-error-msg"/></a>

### 0004-check-atom-pmc-platform-clocks <a name="0004-check-atom-pmc-platform-clocks"/></a>

### 0008-avoid-drm-i915-pps-state-mismatch <a name="0008-avoid-drm-i915-pps-state-mismatch"/></a>

# Deprecated Patches <a name="deprecated-patches"/></a>
Patches that I'm not using I'm calling out below with the reasons why.

## GalliumOS <a name="galliumos"/></a>
Patches from GalliumOS were not using here

### backout-drm-1915-link-rate-fallback <a name="backout-drm-1915-link-rate-fallback"/></a>
Disabled in upstream GalliumOS without any explanation

### sync-plbossart-sound-intel-audio <a name="sync-plbossart-sound-intel-audio"/></a>
Disabled in upstream GalliumOS 4.16.8 with the note **replaced**

### mask-and-clear-cherryview-irqs <a name="mask-and-clear-cherryview-irqs"/></a>
Disabled in upstream GalliumOS 4.16.18 without any explanation

### prevent-mmcblk-rpmb-errors <a name="prevent-mmcblk-rpmb-errors"/></a>
This patch was created to prevent errors when partitioning MMC storage. It has been fixed in the
4.15.4 mainline kernel and is no longer needed

### add-aufs-4.16.diff <a name="add-aufs-4-16-diff"/></a>
https://github.com/GalliumOS/linux/blob/v4.16.18-galliumos/galliumos/diffs/add-aufs-4.16.diff

OverlayFS has been in the mainline kernel for ever and works better than AUFS so there isn't any
reason to add this complex patch.

# Other research <a name="other-research"/></a>
* https://patchwork.ozlabs.org/patch/661413/
* https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=808044;msg=5

## Schedulers <a name="schedulers"/></a>

### MuQSS - The Multiple Queue Skiplist Scheduler by Con Kolivas <a name="muqss-scheduler"/></a>
***MuQSS*** pronounced ***mux*** is the evolved version of the BFS scheduler. http://ck.kolivas.org/patches/muqss/sched-MuQSS.txt
Con Kolivas maintains patches for the mainline kernel http://ck.kolivas.org/patches/muqss/4.0/ that
can be used to enable MuQSS for your kernel.

* Add ***CONFIG_SCHED_MUQSS=y***
* Add ***CONFIG_FORCE_IRQ_THREADING=y***
* Disable ***CONFIG_NUMA_BALANCING is not set***
* Disable ***CONFIG_NUMA_BALANCING_DEFAULT_ENABLED is not set***
* Disable ***CONFIG_FAIR_GROUP_SCHED is not set***
* Disable ***CONFIG_CFS_BANDWIDTH is not set***
* Disable ***CONFIG_CGROUP_CPUACCT is not set***
* Disable ***CONFIG_SCHED_AUTOGROUP is not set***
* Add ***CONFIG_SMT_NICE=y***
* Disable ***# CONFIG_RQ_NONE is not set***
* Disable ***# CONFIG_RQ_SMT is not set***
* Add ***CONFIG_RQ_MC=y***
* Disable ***# CONFIG_RQ_SMP is not set***
* Add ***CONFIG_SHARERQ=2***

### BFQ Storage I/O Scheduler <a name="bfq-scheduler"/></a>
http://algo.ing.unimo.it/people/paolo/disk_sched/  
The Budget Fair Queueing Storage I/O scheduler provides low latency, higher speed, high throughput
and better gaurantees than the standard Queueing scheduler and is used by default by Manjaro and
GalliumOS.  There are both configuration changes and a patch from Manjaro for this.

* Enable ***CONFIG_IOSCHED_BFQ_SQ=y***
* Enable ***CONFIG_BFQ_SQ_GROUP_IOSCHED=y***
* Disable ***# CONFIG_DEFAULT_CFQ is not set***
* Enable ***CONFIG_DEFAULT_BFQ_SQ=y***
* Change ***CONFIG_DEFAULT_IOSCHED="bfq-sq"***
* Enable ***CONFIG_MQ_IOSCHED_BFQ=y***
* Enable ***CONFIG_MQ_BFQ_GROUP_IOSCHED=y***
