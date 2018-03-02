# Kernel for the Samsung Chromebook 3 (a.k.a. CELES)
Arch Linux based Kernel for the Samsung Chromebook 2 (CELES)

I'm borrowing from the execellent Arch, Manjaro and GalliumOS projects as well as some other
sources.

* http://ck.kolivas.org/patches/muqss
* https://github.com/manjaro/packages-core/tree/master/linux415
* https://github.com/GalliumOS/linux/tree/v4.14.14-galliumos/galliumos/diffs
* https://git.archlinux.org/svntogit/packages.git/tree/trunk?h=packages/linux

## Kernel Config
Starting with the Arch Linux kernel config I'm making specific changes for celes

### Kernel compression
Typically disk I/O is the slowest component on a pc. By loading a decompressed kernel then
decompressing into memory we save time. GZIP is almost as good as XZ compression but much easier on
the CPU, which ***celes*** has little of

* Enable ***CONFIG_KERNEL_GZIP=y***
* Disable ***# CONFIG_KERNEL_XZ is not set***

### MuQSS - The Multiple Queue Skiplist Scheduler by Con Kolivas
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

### BFQ Storage I/O Scheduler
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

### Braswell touchpad/keyboard driver
The Cherryview hardware driver must be enabled to support braswell

* Enable ***CONFIG_PINCTRL_CHERRYVIEW=y***

## Patches
I've included a handlful of patches from other projects as called out below:

### Manjaro - BFQ-v8r12-20180130
See the BFQ Storage I/O Scheduler section in the kernel config

### GalliumOS - 0001-add-touchpad-touchscreen-support
Add necessary tweaks for the kernel to recognize the ***celes*** hardware and invoke the correct
drivers

### GalliumOS - 0003-suppress-tpm-error-msg

### GalliumOS - 0004-check-atom-pmc-platform-clocks

### GalliumOS - 0005-sync-plbossart-sound-intel-audio

### GalliumOS - 0006-mask-and-clear-cherryview-irqs

### GalliumOS - 0007-backout-drm-1915-link-rate-fallback

### GalliumOS - 0008-avoid-drm-i915-pps-state-mismatch

## Deprecated Patches

### GalliumOS - 0002-prevent-mmcblk-rpmb-errors
This patch was created to prevent errors when partitioning MMC storage. It has been fixed in the
4.15.4 kernel and is no longer needed

## Other research
* https://patchwork.ozlabs.org/patch/661413/
* https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=808044;msg=5

### Arch vs. Ubuntu
I was attempting to compare teh Arch Linux kernel and the Ubuntu kernels but found they differ so
much it isn't really practicle.

http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.15.5/
Download Ubuntu headers and extract ***config***
```bash
wget http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.15.5/linux-headers-4.15.5-041505-generic_4.15.5-041505.201802261304_amd64.deb
ar xv linux-headers-4.15.5-041505-generic_4.15.5-041505.201802261304_amd64.deb
tar xf data.tar.xz
vim usr/src/linux-headers-4.15.5-041505-generic/.config
```


