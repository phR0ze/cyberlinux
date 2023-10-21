FROM archlinux:base-devel

# Build argument to use the executing user id as the build user in the container
# so that there isn't any confusion on ownership
ARG USER_ID

# Copy in basic configuration
COPY profiles/standard/core/etc/skel/.bash_profile_sideload /root/.bash_profile
COPY profiles/standard/core/etc/skel/.bashrc_sideload /root/.bashrc
COPY profiles/standard/base/etc/skel/.config/vim/.vimrc /root/
COPY profiles/standard/base/etc/skel/.config/starship.toml /root/.config/

# Configure pacmastarship n
COPY config/mkinitcpio.conf /etc/
COPY config/pacman.conf_2_for_builder /etc/pacman.conf
COPY profiles/standard/base/etc/pacman.d/archlinux.mirrorlist /etc/pacman.d/

# Packages to add for building cyberlinux
# --------------------------------------------------------------------------------------------------
# Already exist in archlinux:base-devel
# `coreutils`             provides basic linux tooling
# `pacman`                provides the ability to add additional packages via a chroot to our build env
# `sed`                   is used by the installer to update configuration files as needed
#
# Need to install in new image
# `grub`                  is needed by the installer for creating the EFI and BIOS boot partitions
# `dosfstools`            provides `mkfs.fat` needed by the installer for creating the EFI boot partition
# `mkinitcpio`            provides the tooling to build the initramfs early userspace installer
# `mkinitcpio-vt-colors`  required for the initramfs installer to use cyberlinux blue output
# `rsync`                 used by the installer to copy install data to the install target
# `gptfdisk`              used by the installer tstarship o prepare target media for install
# `linux`                 need to load the kernel to satisfy GRUB
# `intel-ucode`           standard practice to load the intel-ucode
# `memtest86+`            boot memory tester tool
# `libisoburn`            needed for xorriso support
# `linux-firmware`        needed to reduce issing firmware during mkinitcpio builds
# `arch-install-scripts`  needed for `pacstrap`
# `squashfs-tools`        provides `mksquashfs` for creating squashfs images
# `jq`                    provides `jq` json manipulation
# `efibootmgr`            provides `efibootmgr` for EFI boot manager entry manipulation
# `parted`                provides `partprobe` for partition manipulation
# `multipath-tools`       provides `kpartx` for paritition manipultion
# `starship`              bash prompt awesomeness
RUN echo echo ">> Install builder packages" && \
  mkdir -p /root/repo /root/profiles && \
  pacman -Sy --noconfirm cyberlinux/ncurses vim grub dosfstools mkinitcpio mkinitcpio-vt-colors \
    efibootmgr rsync gptfdisk linux intel-ucode memtest86+ libisoburn linux-firmware \
    arch-install-scripts squashfs-tools jq parted multipath-tools starship && \
  \
  # New user is created with: \
  # -r            to not create a mail directory \
  # -m            to create a home directory from /etc/skel \
  # -u            to use a specific user id \ \ \ \
  # -g            calls out the user's primary group created with a specific group id \
  # --no-log-init to avoid an unresolved Go archive/tar bug with docker \
  echo ">> Add the build user" && \
  cp /root/.bash_profile /root/.bashrc /root/.vimrc /etc/skel && \
  groupadd -g $USER_ID build && \
  useradd --no-log-init -r -m -u $USER_ID -g build build && \
  echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Update the pacman config after we installed the target packages so that future runs
# will use the custom repo were going to build at /home/build/repo
COPY config/pacman.conf_3_for_layers /etc/pacman.conf
