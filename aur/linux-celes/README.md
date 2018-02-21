# Kernel for the Samsung Chromebook 3 a.k.a. celes
This is an attempt to build a kernel based on Arch Linux with support for celes

I'm borrowing from the execellent Arch, Manjaro and GalliumOS projects as well as some other
sources.

* https://github.com/manjaro/packages-core/tree/master/linux415
* https://github.com/GalliumOS/linux/tree/v4.14.14-galliumos/galliumos/diffs
* https://git.archlinux.org/svntogit/packages.git/tree/trunk?h=packages/linux

## Patches

### Manjaro - BFQ-v8r12-20180130
http://algo.ing.unimo.it/people/paolo/disk_sched/  
The Budget Fair Queueing Storage I/O scheduler provides low latency, higher speed, high throughput
and better gaurantees than the standard Queueing scheduler and is used by default by Manjaro and
GalliumOS

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

## GPIO Controller
https://patchwork.ozlabs.org/patch/661413/
