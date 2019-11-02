use std::env;
use std::error::Error;
use std::path::PathBuf;

#[derive(Debug)]
pub struct Reduce {
    // Pathing
    pub rootpath: PathBuf,
    pub outpath: PathBuf,
    pub workpath: PathBuf,
    pub pacman_path: PathBuf,
    pub pacman_cache: PathBuf,
    pub tmp_dir: PathBuf,
    pub isopath: PathBuf,
    // @tmp_dir = File.join(@workpath, 'tmp')
    // @isopath = File.join(@workpath, '_iso_')
    // @deployments_src = File.join(@rootpath, 'source')
    // @deployments_work = File.join(@workpath, 'deployments')
    // @vagrantpath = File.join(@rootpath, 'vagrant')

    // @motd_path = File.join(@deployments_src, 'shell/etc/motd')
    // @pacman_src_conf = File.join(@deployments_src, 'shell/etc/pacman.conf')
    // @pacman_src_mirrors = Dir[File.join(@deployments_src, "shell/etc/pacman.d/*.mirrorlist")]

    // @boot_dst = File.join(@isopath, 'boot')
    // @efi_dst = File.join(@isopath, 'efi/boot')
    // @deployment_images_dst = File.join(@isopath, 'images')
    // @grub_iso_dst = File.join(@boot_dst, 'grub')
    // @grub_iso_work = File.join(@workpath, 'boot/grub_iso')

    // @kernel_path = @boot_dst
    // @kernel_prefix = 'vmlinuz'
    // @memtest_image = File.join(@boot_dst, 'memtest')
    // @ucode_image = File.join(@boot_dst, 'intel-ucode')

    // @initramfs_path = @boot_dst
    // @initramfs_prefix = 'initramfs'
    // @initramfs_src = File.join(@rootpath, 'boot/initramfs')
    // @initramfs_work = File.join(@workpath, 'boot/initramfs')

    // @packer_src = File.join(@rootpath, 'packer')
    // @packer_work = File.join(@workpath, 'packer')

    // @imagepaths = [
    //   File.join(@outpath, 'images'),
    //   @deployment_images_dst,
    //   "/home/#{User.name}/Downloads/images"
    // ]
}
impl Reduce {
    pub fn new() -> Result<Reduce, Box<dyn Error>> {
        // Get the executable's directory
        let path = env::current_exe()?;
        let root = path.parent().unwrap();

        // Construct reduce and set properties
        Ok(Reduce {
            rootpath: PathBuf::from(root),
            outpath: root.join("temp"),
            workpath: root.join("work"),
            pacman_path: root.join("temp").join("pacman"),
            pacman_cache: root.join("temp").join("pacman").join("cache"),
            tmp_dir: root.join("work").join("tmp"),
            isopath: root.join("work").join("_iso_"),
        })
    }

    pub fn root(&self) -> &str {
        self.rootpath.to_str().unwrap()
    }
}

// Load the given profile
fn load_profile(target: &str) {
    // let path =
    // let profile_path = File.join(@rootpath, "profiles/#{name}.yml")
    println!("Target profile: {}", target)
}
