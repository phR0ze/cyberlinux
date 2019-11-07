use slog::{info, o, Drain};
use std::cell::RefCell;
use std::io::{self, Write};
use std::path::PathBuf;
use std::rc::Rc;

use errors::Result;
use sys::*;

// Configure logging for the app
pub(crate) fn configure_logging() -> Result<slog::Logger> {
    let decorator = slog_term::TermDecorator::new().build();
    let drain = slog_term::FullFormat::new(decorator).build().fuse();
    let drain = slog_async::Async::new(drain).build().fuse();
    // let log = slog::Logger::root(drain, o!("version" => "0.5"));
    let log = slog::Logger::root(drain, o!());
    Ok(log)
}

pub struct Reduce {
    // Standard io fields
    // pub(crate) log: slog::Logger,
    pub(crate) out: Rc<RefCell<dyn Write>>,
    pub(crate) err: Rc<RefCell<dyn Write>>,

    // Pathing fields
    pub(crate) home_dir: PathBuf,
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
            out: Rc::new(RefCell::new(io::stdout())),
            err: Rc::new(RefCell::new(io::stderr())),
            home_dir: Default::default(),
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
    pub fn new() -> Result<Reduce> {
        let log = configure_logging()?;
        info!(log, "Starting up app...");

        let mut reduce: Self = Default::default();
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
        self.home_dir = sys::home_dir()?;
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
    pub(crate) fn load_profile(&self, target: &str) {
        println!("Target profile: {}", target)
    }

    // // Print to stdout field
    // pub(crate) fn println<T: AsRef<str>>(msg: &T) {
    //     let mut out = self.out.borrow_mut();
    //     write!(out, "{}", self.msg).unwrap();
    // }
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
