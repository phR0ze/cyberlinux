use glob::glob;
use std::env;
use std::path::{Path, PathBuf};

use errors::Result;
use sys::*;

#[derive(Debug, Default)]
pub struct Reduce {
    // Pathing
    pub(crate) root_dir: PathBuf,
    pub(crate) aur_dir: PathBuf,
    pub(crate) config_dir: PathBuf,
    pub(crate) out_dir: PathBuf,
    pub(crate) work_dir: PathBuf,
    pub(crate) pacman_dir: PathBuf,
    pub(crate) pacman_cache: PathBuf,
    pub(crate) tmp_dir: PathBuf,
    pub(crate) iso_dir: PathBuf,
    pub(crate) deployments_dir: PathBuf,
    pub(crate) vagrant_dir: PathBuf,
    pub(crate) motd_path: PathBuf,
    pub(crate) pacman_src_conf: PathBuf,
    pub(crate) pacman_src_mirrors: Vec<PathBuf>,
    pub(crate) boot_iso: PathBuf,
    pub(crate) efi_iso: PathBuf,
    pub(crate) deployment_images: PathBuf,
    pub(crate) grub_iso: PathBuf,
    pub(crate) grub_work: PathBuf,
    pub(crate) kernel_dir: PathBuf,
    pub(crate) kernel_prefix: String,
    pub(crate) memtest_image: PathBuf,
    pub(crate) ucode_image: PathBuf,
    pub(crate) initramfs_dir: PathBuf,
    pub(crate) initramfs_prefix: String,
    pub(crate) initramfs_src: PathBuf,
    pub(crate) initramfs_work: PathBuf,
    pub(crate) packer_src: PathBuf,
    pub(crate) packer_work: PathBuf,
    pub(crate) image_dirs: Vec<PathBuf>,
}
impl Reduce {
    pub fn new() -> Result<Reduce> {
        let mut reduce: Self = Default::default();
        reduce.resolve_root_dir()?;
        reduce.configure_pathing()?;
        Ok(reduce)
    }

    // Determines the root directory for the application
    pub(crate) fn resolve_root_dir(&mut self) -> Result<()> {
        self.root_dir = sys::exec_dir()?;

        // work our way up the path until we find `initramfs` or fail
        loop {
            if self.root_dir.join("initramfs").exists() {
                break;
            }
            self.root_dir = self.root_dir.dirname()?;
        }
        Ok(())
    }

    // Configure pathing for the application
    pub(crate) fn configure_pathing(&mut self) -> Result<()> {
        self.out_dir = self.root_dir.join("temp");
        self.aur_dir = self.root_dir.join("aur");
        self.config_dir = self.aur_dir.join("cyberlinux-config/config");
        self.vagrant_dir = self.root_dir.join("vagrant");
        self.work_dir = self.out_dir.join("work");
        self.pacman_dir = self.out_dir.join("pacman");
        self.pacman_cache = self.pacman_dir.join("cache");
        self.tmp_dir = self.work_dir.join("tmp");
        self.iso_dir = self.work_dir.join("_iso_");
        self.deployments_dir = self.work_dir.join("deployments");
        self.motd_path = self.config_dir.join("shell/etc/motd");
        self.pacman_src_conf = self.config_dir.join("shell/etc/pacman.conf");
        self.pacman_src_mirrors = sys::getpaths(&self.config_dir.join("shell/etc/pacman.d/*.mirrorlist"))?;
        self.boot_iso = self.iso_dir.join("boot");
        self.efi_iso = self.iso_dir.join("efi/boot");
        self.deployment_images = self.iso_dir.join("images");
        self.grub_iso = self.boot_iso.join("grub");
        self.grub_work = self.work_dir.join("boot/grub_iso");
        self.kernel_dir = PathBuf::from(&self.boot_iso);
        self.kernel_prefix = "vmlinuz".to_string();
        self.memtest_image = self.boot_iso.join("memtest");
        self.ucode_image = self.boot_iso.join("intel-ucode");
        self.initramfs_dir = PathBuf::from(&self.boot_iso);
        self.initramfs_prefix = "initramfs".to_string();
        self.initramfs_src = self.root_dir.join("initramfs");
        self.initramfs_work = self.work_dir.join("initramfs");
        self.packer_src = self.root_dir.join("packer");
        self.packer_work = self.work_dir.join("packer");

        // Configure image dirs
        self.image_dirs.push(self.out_dir.join("images"));
        self.image_dirs.push(PathBuf::from(&self.deployment_images));
        //self.image_dirs.push(self.out_dir.join("images"));
        Ok(())
    }

    pub fn root(&self) -> &str {
        self.root_dir.to_str().unwrap()
    }
}

// Load the given profile
fn load_profile(target: &str) {
    println!("Target profile: {}", target)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::env;

    #[test]
    fn resolve_root_dir() {
        let mut reduce: Reduce = Default::default();
        assert_eq!("", reduce.root_dir.to_str().unwrap());
        assert_eq!(true, reduce.resolve_root_dir().is_ok());

        let root = env::current_dir().unwrap().parent().unwrap().to_path_buf();
        assert_eq!(root, reduce.root_dir);
    }
}
