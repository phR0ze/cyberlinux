//! `reduce` is the cyberlinux CLI
//!
//! ## About
//!
//! `reduce` is the cyberlinux CLI
use clap;
mod core;
mod opts;
pub use crate::core::*;
pub use crate::opts::*;

fn main() {
    // Parse cli args
    let cmds = clap::App::new(APP_NAME)
        .version(&format!("v{}", APP_VERSION)[..])
        .about(APP_DESCRIPTION)
        .setting(clap::AppSettings::SubcommandRequiredElseHelp)
        .subcommand(
            // Build command
            clap::SubCommand::with_name("build")
                .about("build TARGETS PROFILE")
                .setting(clap::AppSettings::SubcommandRequiredElseHelp)
                .subcommand(clap::SubCommand::with_name("all").about("Build everything"))
                .subcommand(clap::SubCommand::with_name("builder").about("Build builder"))
                .subcommand(clap::SubCommand::with_name("initramfs").about("Build initramfs image"))
                .subcommand(clap::SubCommand::with_name("multiboot").about("Build grub multiboot image"))
                .subcommand(clap::SubCommand::with_name("iso").about("Build bootable ISO"))
                .subcommand(clap::SubCommand::with_name("isofull").about("Build initramfs, multiboot and iso")),
        )
        .get_matches();

    // Execute build command
    if let Some(ref matches) = cmds.subcommand_matches("build") {
        if matches.is_present("all") {
            let reduce = Reduce::new().unwrap();
            println!("{:?}", reduce.root_dir);
            println!("{:?}", reduce.pacman_src_mirrors);
            println!("{:?}", reduce.image_dirs);
        } else {
            println!("no sub command given");
        }
    }
}

#[cfg(test)]
mod tests {
    // use super::*;

    #[test]
    fn test_main() {
        assert_eq!(4, 4);
    }
}
