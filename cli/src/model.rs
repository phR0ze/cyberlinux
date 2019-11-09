use errors::Result;
use std::path::{Path, PathBuf};
use sys::*;

#[derive(Debug, Default, Clone)]
pub struct Vars {
    pub(crate) arch: String,            // e.g. x86_64
    pub(crate) release: String,         // e.g. 0.2.241
    pub(crate) distro: String,          // e.g. cyberlinux
    pub(crate) language: String,        // e.g. en_US
    pub(crate) character_set: String,   // e.g. UTF-8
    pub(crate) timezone: String,        // e.g. US/Mountain
    pub(crate) country: String,         // e.g. United_States
    pub(crate) color_light: String,     // e.g. '#39AEF4'
    pub(crate) color_dark: String,      // e.g. '#216A94'
    pub(crate) gfxmode: String,         // e.g. 1280x1024,1024x768,auto
    pub(crate) grub_iso_theme: PathBuf, // e.g. /boot/grub/themes/cyberlinux
    pub(crate) dns1: String,            // DNS1 to use for fallback resolved e.g. 8.8.8.8
    pub(crate) dns2: String,            // DNS2 to use for fallback resolved e.g. 8.8.4.4
    pub(crate) netname: String,         // Vagrant network name e.g. vboxnet0
    pub(crate) netip: String,           // Vagrant network ip e.g. 192.168.56.1
    pub(crate) subnet: String,          // Vagrant subnet e.g. 255.255.255.0
    pub(crate) nfscidr: String,         // NFS allowed cidr

    // Kernel params
    // ----------------------------------------------------------------------------
    // ipv6.disable=1              // don't really need or want ipv6
    // rd.systemd.show_status=auto // reduce systemd boot logging
    // rd.udev.log_priority=3      // reduce udev boot logging
    // e.g. kernel_params: rd.systemd.show_status=auto rd.udev.log_priority=3 ipv6.disable=1
    pub(crate) kernel_params: String,
}

#[derive(Debug, Default, Clone)]
pub struct Paths {
    pub(crate) aur_dir: PathBuf,
    pub(crate) boot_iso: PathBuf,
    pub(crate) config_dir: PathBuf,
    pub(crate) deployment_images: PathBuf,
    pub(crate) deployments_dir: PathBuf,
    pub(crate) efi_iso: PathBuf,
    pub(crate) grub_iso: PathBuf,
    pub(crate) grub_work: PathBuf,
    pub(crate) image_dirs: Vec<PathBuf>,
    pub(crate) initramfs_dir: PathBuf,
    pub(crate) initramfs_prefix: String,
    pub(crate) initramfs_src: PathBuf,
    pub(crate) initramfs_work: PathBuf,
    pub(crate) iso_dir: PathBuf,
    pub(crate) kernel_dir: PathBuf,
    pub(crate) kernel_prefix: String,
    pub(crate) loaded_profiles: Vec<String>,
    pub(crate) memtest_image: PathBuf,
    pub(crate) motd_path: PathBuf,
    pub(crate) out_dir: PathBuf,
    pub(crate) packer_src: PathBuf,
    pub(crate) packer_work: PathBuf,
    pub(crate) pacman_dir: PathBuf,
    pub(crate) pacman_cache: PathBuf,
    pub(crate) pacman_src_conf: PathBuf,
    pub(crate) pacman_src_mirrors: Vec<PathBuf>,
    pub(crate) profiles_dir: PathBuf,
    pub(crate) root_dir: PathBuf,
    pub(crate) tmp_dir: PathBuf,
    pub(crate) ucode_image: PathBuf,
    pub(crate) vagrant_dir: PathBuf,
    pub(crate) work_dir: PathBuf,
}
impl Paths {
    pub fn init<T: AsRef<Path>>(home: &T) -> Result<Self> {
        let mut paths: Self = Default::default();

        // Resolve root directory working our way up the path until we find `initramfs`
        paths.root_dir = sys::exec_dir()?;
        loop {
            if paths.root_dir.join("initramfs").exists() {
                break;
            }
            paths.root_dir = paths.root_dir.dirname()?;
        }

        // Configure all other paths based off root or home
        paths.out_dir = paths.root_dir.join("temp");
        paths.aur_dir = paths.root_dir.join("aur");
        paths.config_dir = paths.aur_dir.join("cyberlinux-config/config");
        paths.vagrant_dir = paths.root_dir.join("vagrant");
        paths.work_dir = paths.out_dir.join("work");
        paths.pacman_dir = paths.out_dir.join("pacman");
        paths.pacman_cache = paths.pacman_dir.join("cache");
        paths.tmp_dir = paths.work_dir.join("tmp");
        paths.iso_dir = paths.work_dir.join("_iso_");
        paths.deployments_dir = paths.work_dir.join("deployments");
        paths.motd_path = paths.config_dir.join("shell/etc/motd");
        paths.pacman_src_conf = paths.config_dir.join("shell/etc/pacman.conf");
        paths.pacman_src_mirrors = sys::getpaths(&paths.config_dir.join("shell/etc/pacman.d/*.mirrorlist"))?;
        paths.boot_iso = paths.iso_dir.join("boot");
        paths.efi_iso = paths.iso_dir.join("efi/boot");
        paths.deployment_images = paths.iso_dir.join("images");
        paths.grub_iso = paths.boot_iso.join("grub");
        paths.grub_work = paths.work_dir.join("boot/grub_iso");
        paths.kernel_dir = PathBuf::from(&paths.boot_iso);
        paths.kernel_prefix = "vmlinuz".to_string();
        paths.memtest_image = paths.boot_iso.join("memtest");
        paths.ucode_image = paths.boot_iso.join("intel-ucode");
        paths.initramfs_dir = PathBuf::from(&paths.boot_iso);
        paths.initramfs_prefix = "initramfs".to_string();
        paths.initramfs_src = paths.root_dir.join("initramfs");
        paths.initramfs_work = paths.work_dir.join("initramfs");
        paths.packer_src = paths.root_dir.join("packer");
        paths.packer_work = paths.work_dir.join("packer");
        paths.profiles_dir = paths.root_dir.join("profiles");

        // Configure image dirs
        paths.image_dirs.push(paths.out_dir.join("images"));
        paths.image_dirs.push(PathBuf::from(&paths.deployment_images));
        paths.image_dirs.push(home.as_ref().join("Downloads/images"));
        Ok(paths)
    }
}
