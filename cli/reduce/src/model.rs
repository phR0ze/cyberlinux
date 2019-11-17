use errors::Result;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use sys::*;

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
    pub(crate) loaded_profiles: Vec<PathBuf>,
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

#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Profile {
    // Profile structure version.
    pub version: u8,

    // Defaults to use when values are not set and variables to use for templating.
    pub defaults: Defaults,

    // Defaults to use when values are not set and variables to use for templating.
    pub builder: Container,

    // Fundamental building blocks for Linux distro
    pub blocks: HashMap<String, Vec<Step>>,
}

#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Defaults {
    // Required default global variables
    pub vars: Vars,

    // Optional defaults for machines
    #[serde(default)]
    pub machine: Machine,

    // Optional defaults for containers
    #[serde(default)]
    pub container: Container,
}
// Global variables to use when templating.
#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Vars {
    // e.g. x86_64
    #[serde(default)]
    pub arch: String,

    // e.g. 0.2.241
    #[serde(default)]
    pub release: String,

    // e.g. cyberlinux
    #[serde(default)]
    pub distro: String,

    // e.g. en_US
    #[serde(default)]
    pub language: String,

    // e.g. UTF-8
    #[serde(default)]
    pub character_set: String,

    // e.g. US/Mountain
    #[serde(default)]
    pub timezone: String,

    // e.g. United_States
    #[serde(default)]
    pub country: String,

    // e.g. '#39AEF4'
    #[serde(default)]
    pub color_light: String,

    // e.g. '#216A94'
    #[serde(default)]
    pub color_dark: String,

    // e.g. 1280x1024,1024x768,auto
    #[serde(default)]
    pub gfxmode: String,

    #[serde(default)]
    pub grub_iso_theme: PathBuf, // e.g. /boot/grub/themes/cyberlinux

    // Default fontsize to use e.g. 10
    #[serde(default)]
    pub fontsize: u8,

    // Wallpaper to use e.g. /usr/share/wallpaper/dreamfusion003_1280x1024.jpg
    #[serde(default)]
    pub wallpaper: PathBuf,

    // DNS1 to use for fallback resolved e.g. 8.8.8.8
    #[serde(default)]
    pub dns1: String,

    // DNS2 to use for fallback resolved e.g. 8.8.4.4
    #[serde(default)]
    pub dns2: String,

    // Vagrant network name e.g. vboxnet0
    #[serde(default)]
    pub netname: String,

    // Vagrant network ip e.g. 192.168.56.1
    #[serde(default)]
    pub netip: String,

    // Vagrant subnet e.g. 255.255.255.0
    #[serde(default)]
    pub subnet: String,

    // NFS allowed cidr
    #[serde(default)]
    pub nfscidr: String,

    // Kernel params
    // ----------------------------------------------------------------------------
    // ipv6.disable=1              // don't really need or want ipv6
    // rd.systemd.show_status=auto // reduce systemd boot logging
    // rd.udev.log_priority=3      // reduce udev boot logging
    // e.g. kernel_params: rd.systemd.show_status=auto rd.udev.log_priority=3 ipv6.disable=1
    #[serde(default)]
    pub kernel_params: String,
}

#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Machine {
    pub multilib: bool,

    // Variable overrides to use for a specific machine.
    #[serde(default)]
    pub vars: Vars,

    // Vagrant configuration to use when deploying machine.
    #[serde(default)]
    pub vagrant: Vagrant,

    // Configuration to copy to the deployment from `.../cyberlinux/aur/cyberlinux-config/config`.
    #[serde(default)]
    pub config: Vec<String>,

    // Names of blocks acting as references to the top level `blocks` section.
    // e.g. kernel => blocks.kernel
    #[serde(default)]
    pub blocks: Vec<String>,
}

#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Container {
    pub multilib: bool,

    // Variable overrides to use for a specific machine.
    #[serde(default)]
    pub vars: Vars,

    // Docker command arguments to use when deploying container.
    #[serde(default)]
    pub docker: Docker,

    // Configuration to copy to the deployment from `.../cyberlinux/aur/cyberlinux-config/config`.
    #[serde(default)]
    pub config: Vec<String>,

    // Names of blocks acting as references to the top level `blocks` section.
    // e.g. kernel => blocks.kernel
    #[serde(default)]
    pub blocks: Vec<String>,
}

#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Docker {
    pub command: String,
    pub params: String,
}

#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Vagrant {
    pub vram: u16,
    pub cpus: u16,
    pub ram: u16,
    pub v3d: bool,
}

// Automation steps to execute to install and/or configuration applications.
// Steps are executed in order.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(untagged)]
pub enum Step {
    BlockRef(String),
    Groups(Groups),
    Install(Install),
    Chroot(Chroot),
    Exec(Exec),
    Edit(Edit),
    Menu(Menu),
    Block(HashMap<String, Vec<Step>>),
}

// Describes the groups that should be used
#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Groups {
    pub groups: Vec<String>,
}

// Describes an Arch Linux package to install.
#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Install {
    // Required package name
    pub install: String,

    // Optional repo for package: Repo::ArchLinux.
    #[serde(default)]
    pub repo: String,

    // Optional package description
    #[serde(default)]
    pub desc: String,

    // Optional list of packages this packages depends on
    #[serde(default)]
    pub depends_on: Vec<String>,

    // Optional size of the package
    #[serde(default)]
    pub size: String,
}

// Chroot command to execute in the context of the deployment.
#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Chroot {
    pub chroot: String,
}

// Command to execute without chrooting into the deployment. Paths by default refer to the root
// of the deployment e.g. /etc/environment is actually .../cyberlinux/temp/work/shell/etc/environment
#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Exec {
    pub exec: String,
}

// Edit configuration file to `insert`, `append`, or `prepend` values.
#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Edit {
    // Path to the file to edit
    pub edit: String,

    // Optional regex to execute to match or search replace
    #[serde(default)]
    pub regex: String,

    // Edit insert mode `after`, `before`, `append`.
    #[serde(default)]
    pub insert: String,

    // Values to use with mode.
    #[serde(default)]
    pub values: Vec<String>,
}

// Menu configuration for an application
#[derive(Debug, Default, Clone, PartialEq, Serialize, Deserialize)]
pub struct Menu {
    // Menu folder.
    pub menu: String,

    // Menu icon path for the folder or for the entry.
    pub icon: PathBuf,

    // Optional menu entry that the icon would apply.
    #[serde(default)]
    pub entry: String,

    // Optional menu entry executable string to use to execute the entry.
    #[serde(default)]
    pub exec: String,
}
