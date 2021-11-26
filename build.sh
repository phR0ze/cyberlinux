#!/bin/bash
#set -x
none="\e[m"
red="\e[1;31m"
cyan="\e[1;36m"
green="\e[1;32m"
yellow="\e[1;33m"

BUILDER="builder"                         # Name of the build image and container

# Determine the script name and absolute root path of the project
SCRIPT=$(basename $0)
PROJECT_DIR=$(readlink -f $(dirname $BASH_SOURCE[0]))

# Temp build locations
TEMP_DIR="${PROJECT_DIR}/temp"            # Temp directory for build artifacts
ISO_DIR="${TEMP_DIR}/iso"                 # Build location for staging iso/boot files
REPO_DIR="${TEMP_DIR}/repo"               # Local repo location to stage packages being built
CACHE_DIR="${TEMP_DIR}/cache"             # Local location to cache packages used in building deployments
LAYERS_DIR="${TEMP_DIR}/layers"           # Layered filesystems to include in the ISO
OUTPUT_DIR="${TEMP_DIR}/output"           # Final built artifacts
IMAGES_DIR="${ISO_DIR}/images"            # Final iso sqfs image locations

# Source material to pull from
WORK_DIR="${LAYERS_DIR}/work"             # Temp work directory for layer mounts
CONFIG_DIR="${PROJECT_DIR}/config"        # Location for config files and templates files
PROFILES_DIR="${PROJECT_DIR}/profiles"    # Location for profile descriptions, packages and configs
INSTALLER_DIR="${PROJECT_DIR}/installer"  # Location to pull installer hooks from
GRUB_DIR="${INSTALLER_DIR}/grub"          # Location to pull persisted Grub configuration files from
BOOT_CFG_PATH="${ISO_DIR}/boot/grub/boot.cfg"  # Boot menu entries to read in
PACMAN_CONF_CACHING="${CONFIG_DIR}/pacman.conf_1_for_caching" # Pacman config template to turn into the actual config

# Container directories and mount locations
CONT_BUILD_DIR="/home/build"              # Build location for layer components
CONT_TEMP_DIR="/home/build/temp"          # Build location for layer components
CONT_ROOT_DIR="${CONT_BUILD_DIR}/root"    # Root mount point to build layered filesystems
CONT_ISO_DIR="${CONT_BUILD_DIR}/iso"      # Build location for staging iso/boot files
CONT_ESP="${CONT_ISO_DIR}/boot/grub/esp.img" # Build location for staging iso/boot files
CONT_IMAGES_DIR="${CONT_ISO_DIR}/images"  # Final iso sqfs image locations
CONT_PKGS_DIR="${CONT_ISO_DIR}/pkgs"      # Optional install time packages downloaded and stored on the ISO
CONT_REPO_DIR="${CONT_BUILD_DIR}/repo"    # Local repo location to stage packages being built
CONT_CACHE_DIR="/var/cache/pacman/pkg"    # Location to mount cache at inside container
CONT_OUTPUT_DIR="${CONT_BUILD_DIR}/output" # Final built artifacts
CONT_LAYERS_DIR="${CONT_BUILD_DIR}/layers" # Layered filesystems to include in the ISO
CONT_WORK_DIR="${CONT_LAYERS_DIR}/work"    # Needs to be on the same file system as the upper dir i.e. layers
CONT_PROFILES_DIR="${CONT_BUILD_DIR}/profiles" # Location to mount profiles inside container

# Ensure the current user has passwordless sudo access
if ! sudo -l | grep -q "NOPASSWD: ALL"; then
  echo -e ":: ${red}Failed${none} - Passwordless sudo access is required see README.md..."
  exit
fi

# Create the necessary directories upfront
make_env_directories() {
  mkdir -p "${ISO_DIR}"
  mkdir -p "${REPO_DIR}"
  mkdir -p "${OUTPUT_DIR}"
  mkdir -p "${LAYERS_DIR}"
}

# Failsafe resource release code
[ -z ${RELEASED+x} ] && RELEASED=0
release() {
  if [ $RELEASED -ne 1 ]; then
    RELEASED=1
    docker_kill ${BUILDER}
    sudo rm -rf "${WORK_DIR}"
  fi
}
trap release EXIT
trap release SIGINT

# Configure build environment using Docker
# -------------------------------------------------------------------------------------------------
# We need to use a docker container in order to get the isolation needed. arch-chroot alone seems
# to allow leakage. Building off the `archlinux:base-devel` image provides a quick start.
# docker run --name builder --rm -it archlinux:base-devel bash
build_env()
{
  echo -e "${yellow}:: Configuring build environment...${none}"

  # Build the builder image
  if ! docker_image_exists ${BUILDER}; then
    docker_kill ${BUILDER}
    # Use the same user id as the one runing the docker build so we don't get mixed up
    docker build --build-arg USER_ID=$(id -u) --force-rm -t ${BUILDER} "${PROJECT_DIR}"
  fi

  # Attach to builder if set
  if [ ! -z ${RUN_BUILDER+x} ]; then
    docker_run ${BUILDER}
    docker exec --privileged -it ${BUILDER} bash
  fi
}

# Build repo packages if needed
build_repo_packages() 
{
  [ -f "$REPO_DIR/builder.db" ] && return

  echo -e "${yellow}:: Caching package artifacts..."
  docker_run ${BUILDER}
  cp "${PROJECT_DIR}/VERSION" "${PROFILES_DIR}"

  # Build packages for all profile repos
  for x in ${PROFILES[@]}; do

    # makepkg will modify the PKGBUILD to inject the most recent version.
    # saving off the original and replacing it will avoid having that file changed all the time
    echo -e "${yellow}:: Building packages for profile ${none}${cyan}${x}${none}..."
    cat <<EOF | docker exec --privileged -i ${BUILDER} sudo -u build bash
  cp "${CONT_PROFILES_DIR}/${x}/PKGBUILD" "${CONT_BUILD_DIR}/PKGBUILD"
  cd "${CONT_PROFILES_DIR}/${x}"
  BUILDDIR=${CONT_BUILD_DIR} PKGDEST=${CONT_REPO_DIR} makepkg
  rc=$?
  cp "${CONT_BUILD_DIR}/PKGBUILD" "${CONT_PROFILES_DIR}/${x}/PKGBUILD"
  exit $rc
EOF
    check
  done

  # Build the builder repo if it doesn't exist
  echo -e "${yellow}:: Build the builder repo...${none}"
  cat <<EOF | docker exec --privileged -i ${BUILDER} sudo -u build bash
  cd "${CONT_REPO_DIR}"
  repo-add builder.db.tar.gz *.pkg.tar.*
EOF
  check
}

# Configure grub theme and build supporting BIOS and EFI boot images required to make
# the ISO bootable as a CD or USB stick on BIOS and UEFI systems with the same presentation.
build_multiboot()
{
  echo -e "${yellow}:: Building multiboot components...${none}"

  # Clean up the prior build
  rm -rf "${ISO_DIR}/boot"
  rm -rf "${ISO_DIR}/EFI"

  docker_run ${BUILDER}

  echo -e ":: Copying kernel, intel ucode patch and memtest to ${cyan}${ISO_DIR}/boot${none}"
  mkdir -p "${ISO_DIR}/boot/grub/themes"
  docker_cp "${BUILDER}:/boot/intel-ucode.img" "${ISO_DIR}/boot"
  docker_cp "${BUILDER}:/boot/vmlinuz-linux" "${ISO_DIR}/boot"
  docker_cp "${BUILDER}:/boot/memtest86+/memtest.bin" "${ISO_DIR}/boot/memtest"

  echo -e ":: Copying GRUB config and theme to ${ISO_DIR}/boot/grub"
  cp "${GRUB_DIR}/grub.cfg" "${ISO_DIR}/boot/grub"
  cp "${GRUB_DIR}/loopback.cfg" "${ISO_DIR}/boot/grub"
  cp -r "${GRUB_DIR}/themes" "${ISO_DIR}/boot/grub"
  docker_cp "${BUILDER}:/usr/share/grub/unicode.pf2" "${ISO_DIR}/boot/grub"

  # Create the target profile's boot entries
  # ------------------------------------------------------------------------------------------------
  for layer in $(echo "$DEPLOYMENTS_JSON" | jq -r '.[].name'); do
    read_deployment $layer

    # Don't include entries that don't have a kernel called out as they are intended
    # as a non-installable option for building on only
    if [ ${DE_KERNEL} != "null" ]; then
      echo -e ":: Creating ${cyan}${layer}${none} boot entry in ${cyan}${ISO_DIR}/boot/grub/boot.cfg${none}"
      echo -e "menuentry --class=deployment ${DE_ENTRY} {" >> "${BOOT_CFG_PATH}"
      echo -e "  cat /boot/grub/themes/cyberlinux/splash" >> "${BOOT_CFG_PATH}"
      #echo -e "  sleep 5" >> "${BOOT_CFG_PATH}"

      # Add in optionals which will be default on the installer side if missing
      echo -en "  linux	/boot/vmlinuz-${DE_KERNEL} version=${VERSION} kernel=${DE_KERNEL} layers=${DE_LAYERS}" >> "${BOOT_CFG_PATH}"
      [ ${DE_PARAMS} != "null" ] && echo -en " params=${DE_PARAMS}" >> "${BOOT_CFG_PATH}"
      [ ${DE_DISTRO} != "null" ] && echo -en " distro=${DE_DISTRO}" >> "${BOOT_CFG_PATH}"
      [ ${DE_TIMEZONE} != "null" ] && echo -en " timezone=${DE_TIMEZONE}" >> "${BOOT_CFG_PATH}"
      [ ${DE_GROUPS} != "null" ] && echo -en " groups=${DE_GROUPS}" >> "${BOOT_CFG_PATH}"
      [ ${DE_DNS1} != "null" ] && echo -en " dns1=${DE_DNS1}" >> "${BOOT_CFG_PATH}"
      [ ${DE_DNS2} != "null" ] && echo -en " dns2=${DE_DNS2}" >> "${BOOT_CFG_PATH}"
      [ ${DE_AUTOLOGIN} != "null" ] && echo -en " autologin=${DE_AUTOLOGIN}" >> "${BOOT_CFG_PATH}"
      echo -en "\n" >> "${BOOT_CFG_PATH}"

      echo -e "  initrd	/boot/intel-ucode.img /boot/installer" >> "${BOOT_CFG_PATH}"
      echo -e "}" >> "${BOOT_CFG_PATH}"
    fi
  done

  # Creating BIOS boot files
  # ------------------------------------------------------------------------------------------------
  echo -e "${yellow}:: Creating BIOS boot files...${none}"
  local shared_modules="iso9660 part_gpt ext2"

  # Stage the grub modules
  # GRUB doesn't have a stble binary ABI so modules from one version can't be used with another one
  # and will cause failures so we need to remove then all in advance
  docker_cp "${BUILDER}:/usr/lib/grub/i386-pc" "${ISO_DIR}/boot/grub"
  rm -f "${ISO_DIR}/boot/grub/i386-pc"/*.img

  # We need to create our core image i.e bios.img that contains just enough code to find the grub
  # configuration and grub modules in /boot/grub/i386-pc directory
  # -p /boot/grub                 Directory to find grub once booted, default is /boot/grub
  # -c /boot/grub/grub.cfg        Location of the config to use, default is /boot/grub/grub.cfg
  # -d /usr/lib/grub/i386-pc      Use resources from this location when building the boot image
  # -o $CONT_BUILD_DIR/bios.img   Output destination
  cat <<EOF | docker exec --privileged -i ${BUILDER} sudo -u build bash
  grub-mkimage --format i386-pc -d /usr/lib/grub/i386-pc -p /boot/grub \
    -o "$CONT_BUILD_DIR/bios.img" biosdisk ${shared_modules}

  echo -e ":: Concatenate cdboot.img to bios.img to create CD-ROM bootable image $CONT_BUILD_DIR/eltorito.img..."
  cat /usr/lib/grub/i386-pc/cdboot.img "$CONT_BUILD_DIR/bios.img" > "$CONT_ISO_DIR/boot/grub/i386-pc/eltorito.img"

  echo -e ":: Concatenate boot.img to bios.img to create embedded boot $CONT_BUILD_DIR/embedded.img..."
  cat /usr/lib/grub/i386-pc/boot.img "$CONT_BUILD_DIR/bios.img" > "$CONT_ISO_DIR/boot/grub/i386-pc/embedded.img"
EOF
  check

  # Creating UEFI boot files
  # xorriso expects a FAT32 filesystem image which contains a binary file named /EFI/BOOT/BOOTX64.EFI
  # GRUB2 doesn't create the FAT32 filesystem by default it only creates the binary BOOTX64.EFI. We
  # need to create the EFI System Partition i.e. ESP and mount it for GRUB2 to deposit the binary in.
  # Then the resulting ESP is saved as the esp.img and used by xorriso.
  # ------------------------------------------------------------------------------------------------
  echo -e "${yellow}:: Creating UEFI boot files...${none}"
  mkdir -p "${ISO_DIR}/EFI/BOOT"

  # Stage the grub modules
  # GRUB doesn't have a stble binary ABI so modules from one version can't be used with another one
  # and will cause failures so we need to remove then all in advance
  docker_cp "$BUILDER:/usr/lib/grub/x86_64-efi" "$ISO_DIR/boot/grub"
  rm -f "$ISO_DIR/grub/x86_64-efi"/*.img

  # We need to create our core image i.e. BOOTx64.EFI that contains just enough code to find the grub
  # configuration and grub modules in /boot/grub/x86_64-efi directory.
  # -p /boot/grub                               Directory to find grub once booted, default is /boot/grub
  # -c /boot/grub/grub.cfg                      Location of the config to use, default is /boot/grub/grub.cfg
  # -d "$BUILDER_DIR/usr/lib/grub/x86_64-efi"   Use resources from this location when building the boot image
  # -o "$CONT_ISO_DIR/EFI/BOOT/BOOTX64.EFI"     Using wellknown EFI location for fallback compatibility
  cat <<EOF | docker exec --privileged -i ${BUILDER} sudo -u build bash
  grub-mkimage --format x86_64-efi -d /usr/lib/grub/x86_64-efi -p /boot/grub \
    -o "$CONT_ISO_DIR/EFI/BOOT/BOOTX64.EFI" fat efi_gop efi_uga ${shared_modules}

  echo -e ":: Creating ESP with the BOOTX64.EFI binary"
  truncate -s 8M "${CONT_ESP}"
  mkfs.vfat "${CONT_ESP}" &>/dev/null
  mkdir -p "${CONT_TEMP_DIR}"
  while :; do
    echo -e ":: Attempting to mount ${CONT_ESP} as ${CONT_TEMP_DIR}"
    sleep 1 && sudo mount "${CONT_ESP}" "${CONT_TEMP_DIR}"
    [ $? -eq 0 ] && break
  done
  sudo mkdir -p "${CONT_TEMP_DIR}/EFI/BOOT"
  sudo cp "$CONT_ISO_DIR/EFI/BOOT/BOOTX64.EFI" "${CONT_TEMP_DIR}/EFI/BOOT"
  sudo umount "${CONT_TEMP_DIR}"
EOF
  check
}

# Build the initramfs based installer
build_installer()
{
  if [ ${OPTIONAL_PKGS} != "null" ]; then
    build_repo_packages
    docker_run ${BUILDER}
    echo -e "${yellow}:: Downloading optional install packages...${none}"
    cat <<EOF | docker exec --privileged -i ${BUILDER} bash
  mkdir -p ${CONT_PKGS_DIR}
  sed -i 's|#CacheDir.*|CacheDir = ${CONT_PKGS_DIR}|g' /etc/pacman.conf
  pacman -Sy --downloadonly --noconfirm ${OPTIONAL_PKGS}
EOF
    check
    docker_kill ${BUILDER}
  fi

  echo -e "${yellow}:: Stage files for building initramfs based installer...${none}"
  docker_run ${BUILDER}
  docker_cp "${INSTALLER_DIR}/installer" "$BUILDER:/usr/lib/initcpio/hooks"
  docker_cp "${INSTALLER_DIR}/installer.conf" "$BUILDER:/usr/lib/initcpio/install/installer"
  docker_cp "${INSTALLER_DIR}/mkinitcpio.conf" "$BUILDER:/etc"

  # Build a sorted array of kernels such that the first is the newest
  echo -en "${yellow}:: Build the initramfs based installer...${none}"
  local kernels=($(docker_exec ${BUILDER} "ls /lib/modules | sort -r | tr '\n' ' '"))
  docker_exec ${BUILDER} "mkinitcpio -k ${kernels[0]} -g /root/installer"
  check

  docker_cp "$BUILDER:/root/installer" "$ISO_DIR/boot"
}

# Build deployments
build_deployments() 
{
  build_repo_packages
  echo -e "${yellow}:: Building deployments${none} ${cyan}${1}${none}..."
  docker_run ${BUILDER}
  docker_exec ${BUILDER} "mkdir -p ${CONT_ROOT_DIR}"

  # Iterate over the deployments
  for target in ${1//,/ }; do
    read_deployment $target
    echo -e ":: Building deployment ${cyan}${target}${none} composed of ${cyan}${DE_LAYERS}${none}"

    # Build each of the deployment's layers
    for i in "${!LAYERS[@]}"; do
      local layer="${LAYERS[$i]}"
      echo -e ":: Building layer ${cyan}${layer}${none}..."

      # Ensure the layer destination path exists and is owned by root to avoid warnings
      local layer_dir="${LAYERS_DIR}/${layer}"
      local cont_layer_dir="${CONT_LAYERS_DIR}/${layer}"                  # e.g.  /home/build/layers/openbox/core
      local cont_layer_image_dir="${CONT_IMAGES_DIR}/$(dirname ${layer})" # e.g.  /home/build/iso/images/openbox
      docker_exec ${BUILDER} "mkdir -p ${cont_layer_dir} ${cont_layer_image_dir} ${CONT_WORK_DIR}"

      # Mount the layer destination path 
      if [ ${i} -eq 0 ]; then
        echo -en ":: Bind mount layer ${cyan}${cont_layer_dir}${none} to ${cyan}${CONT_ROOT_DIR}${none}..."
        docker_exec ${BUILDER} "mount --bind $cont_layer_dir $CONT_ROOT_DIR"
        check
      else
        # Slice off the lower layer directories and build the lowerdir string
        local cont_lower_dirs=""
        for x in "${LAYERS[@]:0:$i}"; do
          cont_lower_dirs="${CONT_LAYERS_DIR}/${x}:${cont_lower_dirs}"
        done
        cont_lower_dirs="${cont_lower_dirs%?}" # Trim trailing colon

        # `upperdir` is a writable layer at the top
        # `lowerdir` is a colon : separated list of read-only dirs the right most is the lowest
        # `workdir`  is an empty dir used to prepare files and has to be on the same file system as upperdir
        # the last param is the merged or resulting filesystem after layering to work with
        echo -en ":: Mounting layer ${cyan}${cont_layer_dir}${none} over ${cyan}${cont_lower_dirs}${none}..."
        docker_exec ${BUILDER} "mount -t overlay overlay -o lowerdir=${cont_lower_dirs},upperdir=${cont_layer_dir},workdir=${CONT_WORK_DIR} ${CONT_ROOT_DIR}"
        check
      fi

      # Install target packages
      if [ "$(ls "${layer_dir}")" != "" ]; then
        echo -e ":: Skipping install layer ${cyan}${cont_layer_dir}${none} already exists"
      else
        for pkg in ${PACKAGES[@]}; do
          echo -e ":: Installing layer package ${cyan}${pkg}${none} to ${cyan}${CONT_ROOT_DIR}${none}"
          # -c use the package cache on the host rather than target
          # -G avoid copying the host's pacman keyring to the target
          # -M avoid copying the host's mirrorlist to the target
          docker_exec ${BUILDER} "pacstrap -c -G -M ${CONT_ROOT_DIR} $pkg"
          check
        done
      fi

      # Release the root mount point now that we have fully built the required layers
      echo -en ":: Releasing overlay ${cyan}${CONT_ROOT_DIR}${none}..."
      docker_exec ${BUILDER} "umount -fR $CONT_ROOT_DIR"
      check
      docker_exec ${BUILDER} "rm -rf $CONT_WORK_DIR"
    done

    # Compress each built layer into a deliverable image
    for i in "${!LAYERS[@]}"; do
      local layer="${LAYERS[$i]}"
      local cont_layer_dir="${CONT_LAYERS_DIR}/${layer}"
      local cont_layer_image="${CONT_IMAGES_DIR}/${layer}.sqfs" # e.g.  iso/images/openbox/core.sqfs
      if [ -f "${IMAGES_DIR}/${layer}.sqfs" ]; then
        echo -e ":: Squashfs image ${cyan}${cont_layer_image}${none} already exists"
      else
        echo -en ":: Compressing layer ${cyan}${cont_layer_dir}${none} into ${cyan}${cont_layer_image}${none}..."
        # Stock settings pulled from ArchISO
        # -noappend           // overwrite destination image rather than adding to it
        # -b 1M               // use a larger block size for higher performance
        # -comp xz -Xbcj x86  // use xz compression with x86 filter for best compression
        docker_exec ${BUILDER} "mksquashfs ${cont_layer_dir} ${cont_layer_image} -noappend -b 1M -comp xz -Xbcj x86"
        check
      fi
    done
  done
}

# Build the ISO
# El-Torito is a standard for creating bootable optical media. The Boot Catalog is created during the
# production of the ISO. The Boot Catalog lists the available boot images called 'platforms'. BIOS
# reads from the Boot Catalog the number of blocks to load, loads them then executes them as code.
# EFI interprets the boot image as a FAT filesystem and looks up a standardized file paath for futher
# processing i.e /EFI/BOOT/BOOTX86.EFI In either case El-Torito is required. The boot image that gets
# run is the boot loader that then looks for its configuration and presents its UI from simple text
# menu like systemd-boot or graphical menus with GRUB2's GFXMenu.
#
# Reference:
# https://wiki.osdev.org/El-Torito
# https://lukeluo.blogspot.com/2013/06/grub-how-to-2-make-boot-able-iso-with.html
# https://www.0xf8.org/2020/03/recreating-isos-that-boot-from-both-dvd-and-mass-storage-such-as-usb-sticks-and-in-both-legacy-bios-and-uefi-environments/
build_iso()
{
  echo -e "${yellow}:: Building an ISOHYBRID bootable image...${none}"
  docker_run ${BUILDER}
  cat <<EOF | docker exec --privileged -i ${BUILDER} sudo -u build bash
  cd ~/
  xorriso \
    \
    `# Configure general settings` \
    -as mkisofs                                     `# Use -as mkisofs to support options like grub-mkrescue does` \
    -volid CYBERLINUX_INSTALLER                     `# Identifier installer uses to find the install drive` \
    --modification-date=$(date -u +%Y%m%d%H%M%S00)  `# Date created YYYYMMDDHHmmsscc e.g. 2021071223322500` \
    -r -iso-level 3 -full-iso9660-filenames         `# Use Rock Ridge and level 3 for standard ISO features` \
    \
    `# Configure BIOS bootable settings` \
    -b boot/grub/i386-pc/eltorito.img               `# a.k.a -eltorito-boot enables BIOS boot` \
    -no-emul-boot                                   `# Image is not emulating floppy mode` \
    -boot-load-size 4                               `# Specifies (4) 512byte blocks: 2048 total` \
    -boot-info-table                                `# Updates boot image with boot info table` \
    --embedded-boot iso/boot/grub/i386-pc/embedded.img  `# Copy 32768 bytes to the start of the ISO` \
    --protective-msdos-label                        `# Seals off the MBR boot space` \
    \
    `# Configure UEFI bootable settings` \
    `# the 'esp.img' is a disk image in FAT GPT i.e. ESP specification` \
    `# https://www.gnu.org/software/xorriso/man_1_xorrisofs.html` \
    `# --efi-boot IMAGE is an alias for -eltorito-alt-boot, -e IMAGE, -no-emul-boot, -eltorito-alt-boot` \
    --efi-boot boot/grub/esp.img                    `# Alias for -eltorito-alt-boot, -e with image` \
    -isohybrid-gpt-basdat                           `# Announces esp.img is FAT GPT i.e. ESP` \
    \
    `# Specify the output iso file path and location to turn into an ISO` \
    -o "${CONT_OUTPUT_DIR}/cyberlinux.iso" "$CONT_ISO_DIR"
EOF
  check
}

# Clean the various build artifacts as called out
clean()
{
  docker_kill ${BUILDER}

  local targets="$1"
  if [ "${1}" == "most" ]; then
    targets="$targets,iso,layers,output,repo" 
  fi

  for x in ${targets//,/ }; do
    local target="${TEMP_DIR}/${x}"

    # Clean everything not covered in other specific cases
    if [ "${x}" == "all" ]; then
      target="${TEMP_DIR}"
      echo -e "${yellow}:: Cleaning docker image ${cyan}archlinux:base-devel${none}"
      docker_rmi archlinux:base-devel
    fi

    # Clean the builder docker image
    if [ "${x}" == "all" ] || [ "${x}" == "${BUILDER}" ]; then
      echo -e "${yellow}:: Cleaning docker image ${cyan}${BUILDER}${none}"
      docker_rmi ${BUILDER}
    fi

    # Clean the squashfs staged images from temp/iso/images if layer called out
    if [ "${x}" == "all" ] || [ "${x%%/*}" == "layers" ]; then
      if [ "${x}" == "all" ] || [ "${x}" == "layers" ]; then
        echo -e "${yellow}:: Cleaning all layer images${none}"
        sudo rm -rf "${IMAGES_DIR}"
      else
        local layer_image="${IMAGES_DIR}/${x#*/}.sqfs" # e.g. .../images/openbox/core.sqfs
        echo -e "${yellow}:: Cleaning sqfs layer image${none} ${cyan}${layer_image}${none}"
        sudo rm -f "${layer_image}"
      fi
    fi

    echo -e "${yellow}:: Cleaning build artifacts${none} ${cyan}${target}${none}"
    sudo rm -rf "${target}"
  done
}

check_fail()
{
  if [ $? -ne 0 ]; then
    echo -e "${red}failed!${none}"
    exit 1
  fi
}

check()
{
  if [ $? -ne 0 ]; then
    echo -e "${red}failed!${none}"
    exit 1
  else
    echo -e "${green}success!${none}"
  fi
}

# Profile utility functions
# -------------------------------------------------------------------------------------------------

# Retrieve the deployment's properties
read_deployment()
{
  local layer=$(echo "$DEPLOYMENTS_JSON" | jq '.[] | select(.name=="'$1'")')
  DE_ENTRY=$(echo "$layer" | jq '.entry')
  DE_KERNEL=$(echo "$layer" | jq -r '.kernel')
  DE_PARAMS=$(echo "$layer" | jq -r '.params')
  DE_DISTRO=$(echo "$layer" | jq -r '.distro')
  DE_TIMEZONE=$(echo "$layer" | jq -r '.timezone')
  DE_GROUPS=$(echo "$layer" | jq -r '.groups')
  DE_DNS1=$(echo "$layer" | jq -r '.dns1')
  DE_DNS2=$(echo "$layer" | jq -r '.dns2')
  DE_AUTOLOGIN=$(echo "$layer" | jq -r '.autologin')
  DE_LAYERS=$(echo "$layer" | jq -r '.layers')
  
  # Create an array out of the packages
  PACKAGES=($(echo "$layer" | jq -r '.packages | join(" ")'))

  # Create an array out of the layers as well
  LAYERS=($(echo "$layer" | jq -r '.layers | split(",") | join(" ")'))
}

# Based on the given profile process all deployments and determine which
# profiles are referenced and set a distinct array of them.
# e.g. openbox standard
unique_profiles()
{
  # Get list of profiles to build packages for
  PROFILES=()

  # Load dependencies i.e. profiles that have packages that this profile depends on and must be built
  local dependencies=$(echo "$PROFILE_JSON" | jq -r '. | if has("dependencies") then (.dependencies | join(" ")) else null end')
  if [ "${dependencies}" != "null" ]; then

    # Include the current profile as a dependency
    for profile in ${dependencies} $PROFILE; do

      # Search the PROFILES array for the given profile
      local found=0
      for x in ${PROFILES[@]}; do
        [[ "${profile}" == "${x}" ]] && found=1
      done

      # Add the profile if not found
      [ $found -ne 1 ] && PROFILES+=("${profile}")
    done
  fi

  # Extract just the layers, split them on comma, add them together as a single array
  # ensuring each entry is unique then join them as a single space delimeted string
  #$(echo "$DEPLOYMENTS_JSON" | jq -r '[.[].layers | split(",")] | add | unique | join(" ")'); do
}

# Retrieve all deployments in reverse sequential order
read_deployments()
{
  echo -e "${yellow}:: Reading in all deployments${none}..."
  DEPLOYMENTS=$(echo "$DEPLOYMENTS_JSON" | jq -r '[reverse[].name] | join(",")')
}

# Read the given profile from disk
# $1 is expected to be the name of the profile 
read_profile()
{
  PROFILE_DIR="${PROFILES_DIR}/${1}"
  PROFILE_PATH="${PROFILE_DIR}/profile.json"
  echo -en "${yellow}:: Using profile${none} ${cyan}${PROFILE_PATH}${none}..."
  PROFILE_JSON=$(jq -r '.' "$PROFILE_PATH")
  check
  DEPLOYMENTS_JSON=$(echo "$PROFILE_JSON" | jq -r '.deployments')
  check_fail

  # Load optional packages that will be downloaded and included on the ISO for a runtime install
  OPTIONAL_PKGS=$(echo "$PROFILE_JSON" | jq -r '. | if has("optionalPkgs") then (.optionalPkgs | join(" ")) else null end')

  unique_profiles
}

# Docker utility functions
# -------------------------------------------------------------------------------------------------

# Execute the given bash script against the wellknown builder container
# $1 container to execute on
# $2 bash to execute
docker_exec() {
  docker exec --privileged ${1} bash -c "${2}"
}

# Check if the given image exists
# $1 docker repository
docker_image_exists() {
  docker image inspect -f {{.Metadata.LastTagTime}} $1 &>/dev/null
}

# Check if the given docker container is running
# $1 container to check
docker_container_running() {
  [ "$(docker container inspect -f {{.State.Running}} $1 2>/dev/null)" == "true" ]
}

# Copy the given source file to the given destination file
# example to container: docker_cp "/etc/pacman.conf" "builder:/etc/pacman.conf"
# example from container: docker_cp "builder:/etc/pacman.conf" "/tmp"
# $1 source file
# $2 destination file
docker_cp() {
  echo -en ":: Copying ${cyan}${1}${none} to ${cyan}$2${none}..."
  docker cp "$1" "$2"
  check
}

# Docker remove image
# $1 repository name
docker_rmi() {
  if docker_image_exists ${1}; then
    echo -en ":: Removing the given image ${cyan}${1}${none}..."
    docker image rm $1
    check
  fi
}

# Pull the builder container if it doesn't exist then run it in a sleep loop so we can work with
# it in parallel. We'll need to wait until it is ready and manage its lifecycle
# $1 container repository:tag combo to run
# $2 additional params to include e.g. "-v "${REPO_DIR}":/var/cache/builder"
docker_run() {
  docker_container_running ${BUILDER} && return
  echo -en ":: Running docker container in loop: ${cyan}${1}${none}..."
  
  # Docker will need additional privileges to allow mount to work inside a container
  local params="-e TERM=xterm -v /var/run/docker.sock:/var/run/docker.sock --privileged"

  # Run a sleep loop for as long as we need to
  # -d means run in detached mode so we don't block
  # -v is used to mount a directory into the container to cache all the packages.
  #    also using it to mount the custom repo into the container
  docker run -d --name ${BUILDER} --rm ${params} ${2} \
    -v "${ISO_DIR}":"${CONT_ISO_DIR}" \
    -v "${REPO_DIR}":"${CONT_REPO_DIR}" \
    -v "${CACHE_DIR}":"${CONT_CACHE_DIR}" \
    -v "${LAYERS_DIR}":"${CONT_LAYERS_DIR}" \
    -v "${OUTPUT_DIR}":"${CONT_OUTPUT_DIR}" \
    -v "${PROFILES_DIR}":"${CONT_PROFILES_DIR}" \
    $1 bash -c "while :; do sleep 5; done" &>/dev/null
  check

  # Now wait until it responds to commands
  while ! docker_container_running ${BUILDER}; do sleep 2; done
}

# Kill the running container using its wellknown name
# $1 container name to kill
docker_kill() {
  if docker_container_running ${1}; then
    echo -en ":: Killing docker ${cyan}${1}${none} container..."
    docker kill ${1} &>/dev/null
    check
  fi
}

# Main entry point
# -------------------------------------------------------------------------------------------------
header()
{
  VERSION=$(cat VERSION)
  echo -e "${cyan}CYBERLINUX v${VERSION}${none} builder for a multiboot installer ISO"
  echo -e "${cyan}------------------------------------------------------------------${none}"
}
usage()
{
  header
  echo -e "Usage: ${cyan}./$(basename $0)${none} [options]\n"
  echo -e "Options:"
  echo -e "  -a               Build all components for the given profile"
  echo -e "  -b               Run the builder attaching to standard input and output"
  echo -e "  -d DEPLOYMENTS   Build deployments, comma delimited (all,shell,lite)"
  echo -e "  -i               Build the initramfs installer"
  echo -e "  -m               Build the grub multiboot environment"
  echo -e "  -I               Build the acutal ISO image"
  echo -e "  -p PROFILE       Set the profile to use (default: openbox)"
  echo -e "  -r               Build repo packages for deployment/s and/or profile"
  echo -e "  -c TARGETS       Clean artifacts, comma delimited (all,most,cache,iso,layers/openbox/core)"
  echo -e "                   'most' will clean everything except the cache and docker images"
  echo -e "  -h               Display usage help\n"
  echo -e "Examples:"
  echo -e "  ${green}Build full Xfce ISO:${none} ./${SCRIPT} -p xfce -a"
  echo -e "  ${green}Rebuild Xfce packages:${none} ./${SCRIPT} -p xfce -c repo -r"
  echo -e "  ${green}Build just bootable installer:${none} ./${SCRIPT} -imI"
  echo -e "  ${green}Rebuild full Xfce ISO:${none} ./${SCRIPT} -p xfce -c most -a"
  echo -e "  ${green}Rebuild deployment:${none} ./${SCRIPT} -c layers/xfce/theater,repo; ./${SCRIPT} -p xfce -d theater -rimI"
  echo -e "  ${green}Build installable Xfce theater deployment:${none} ./${SCRIPT} -p xfce -d theater -rimI"
  echo -e "  ${green}Clean openbox core,base layers:${none} ./${SCRIPT} -c layers/openbox/core,layers/openbox/base"
  echo -e "  ${green}Don't automatically destroy the build container:${none} RELEASED=1 ./${SCRIPT} -d base"
  echo -e "  ${green}Run the build container attaching to input/output:${none} ./${SCRIPT} -b"
  echo
  RELEASED=1
  exit 1
}
while getopts ":abd:imIp:c:rth" opt; do
  case $opt in
    c) CLEAN=$OPTARG;;
    a) BUILD_ALL=1;;
    b) RUN_BUILDER=1;;
    i) BUILD_INSTALLER=1;;
    d) DEPLOYMENTS=$OPTARG;;
    m) BUILD_MULTIBOOT=1;;
    I) BUILD_ISO=1;;
    p) PROFILE=$OPTARG;;
    r) BUILD_REPO=1;;
    t) TEST=1;;
    h) usage;;
    \?) echo -e "Invalid option: ${red}-${OPTARG}${none}\n"; usage;;
    :) echo -e "Option ${red}-${OPTARG}${none} requires an argument\n"; usage;;
  esac
done
[ $(($OPTIND -1)) -eq 0 ] && usage
header

# Invoke the testing function if given
[ ! -z ${TEST+x} ] && testing

# Default profile if not set
[ -z ${PROFILE+x} ] && PROFILE=standard
read_profile "$PROFILE"

# Optionally clean artifacts
[ ! -z ${CLEAN+x} ] && clean $CLEAN
make_env_directories

# 1. Always build the build environment if any build option is chosen
if [ ! -z ${BUILD_ALL+x} ] || [ ! -z ${BUILD_MULTIBOOT+x} ] || \
  [ ! -z ${BUILD_INSTALLER+x} ] || [ ! -z ${DEPLOYMENTS+x} ] || \
  [ ! -z ${BUILD_REPO+x} ] || [ ! -z ${RUN_BUILDER+x} ]; then
  build_env
fi

# 2. Build the grub multiboot images
if [ ! -z ${BUILD_ALL+x} ] || [ ! -z ${BUILD_MULTIBOOT+x} ]; then
  build_multiboot
fi

# Build the installer
if [ ! -z ${BUILD_ALL+x} ] || [ ! -z ${BUILD_INSTALLER+x} ]; then
  build_installer
fi

# Build repo packages
if [ ! -z ${BUILD_ALL+x} ] || [ ! -z ${BUILD_REPO+x} ]; then
  build_repo_packages
fi

# Build the deployments
if [ ! -z ${BUILD_ALL+x} ] || [ ! -z ${DEPLOYMENTS+x} ]; then
  if [ ! -z ${BUILD_ALL+x} ] || [ "${DEPLOYMENTS}" == "all" ]; then
    read_deployments
  fi
  build_deployments $DEPLOYMENTS
fi

# Build the actual ISO
if [ ! -z ${BUILD_ALL+x} ] || [ ! -z ${BUILD_ISO+x} ]; then
  build_iso
fi

# vim: ft=sh:ts=2:sw=2:sts=2
