use colored::*;
use errors::Result;
use log;
use logs::{self, out};
use std::cell::RefCell;
use std::fmt;
use std::io::{self, Write};
use std::path::PathBuf;
use std::rc::Rc;
use sys::*;

use crate::opts::*;

pub const APP_NAME: &'static str = env!("CARGO_PKG_NAME");
pub const APP_VERSION: &'static str = env!("CARGO_PKG_VERSION");
pub const APP_DESCRIPTION: &'static str = env!("CARGO_PKG_DESCRIPTION");

// Reduce implementation
// -------------------------------------------------------------------------------------------------
pub struct Reduce {
    pub(crate) debug: bool,
    pub(crate) quiet: bool,
    pub(crate) home_dir: PathBuf,
    pub(crate) out: Rc<RefCell<dyn io::Write>>,

    // Pathing fields
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
impl Default for Reduce {
    fn default() -> Self {
        Self {
            debug: Default::default(),
            quiet: Default::default(),
            home_dir: Default::default(),
            out: Rc::new(RefCell::new(io::stdout())),
            root_dir: Default::default(),
            out_dir: Default::default(),
            aur_dir: Default::default(),
            config_dir: Default::default(),
            vagrant_dir: Default::default(),
            work_dir: Default::default(),
            pacman_dir: Default::default(),
            pacman_cache: Default::default(),
            tmp_dir: Default::default(),
            iso_dir: Default::default(),
            deployments_dir: Default::default(),
            motd_path: Default::default(),
            pacman_src_conf: Default::default(),
            pacman_src_mirrors: Default::default(),
            boot_iso: Default::default(),
            efi_iso: Default::default(),
            deployment_images: Default::default(),
            grub_iso: Default::default(),
            grub_work: Default::default(),
            kernel_dir: Default::default(),
            kernel_prefix: Default::default(),
            memtest_image: Default::default(),
            ucode_image: Default::default(),
            initramfs_dir: Default::default(),
            initramfs_prefix: Default::default(),
            initramfs_src: Default::default(),
            initramfs_work: Default::default(),
            packer_src: Default::default(),
            packer_work: Default::default(),
            image_dirs: Default::default(),
        }
    }
}
impl Reduce {
    // Create a new reduce instance with defaults.
    pub fn new() -> Result<Reduce> {
        Reduce::new_with(vec![])
    }

    // Create a new reduce instance with the given options.
    pub fn new_with(opts: Vec<Opt>) -> Result<Reduce> {
        let mut reduce = Self {
            debug: opts.debug(),
            quiet: opts.quiet(),
            home_dir: opts.home(),
            out: opts.stdout(),
            ..Default::default()
        };
        writeln!(reduce, "{}", format!("<<{{ {} v{} }}>>", APP_NAME, APP_VERSION).green().bold());

        // Configure logging based off the Opt::LogLevel option
        logs::init_with(vec![logs::Opt::Level(opts.log_level())])?;

        // Startup reduce instance
        log::info!("Starting up app...");
        reduce.resolve_root_dir()?;
        reduce.configure_pathing()?;
        Ok(reduce)
    }

    // Determines the root directory for the app
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

    // Configure pathing
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
        self.image_dirs.push(self.home_dir.join("Downloads/images"));
        Ok(())
    }

    // Load the given profile
    pub(crate) fn load_profile(&mut self, target: &str) {
        writeln!(self, "Target profile: {}", target)
    }

    // Implement support for write*! macro varients to use Reduce as a Writer.
    // We actually don't need to implement the entire fmt::Write trait only this func
    // as macros don't seem to honor the full trait contractd only existance of the func.
    pub fn write_fmt(&mut self, fmt: fmt::Arguments<'_>) {
        if !self.quiet {
            self.out.borrow_mut().write_fmt(fmt).unwrap();
        }
    }
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
