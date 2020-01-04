//! `reduce` is the cyberlinux CLI
//!
//! ## About
//!
//! `reduce` is the cyberlinux CLI
use clap;
use fungus::prelude::*;
use reduce::*;

fn main() -> Result<()> {
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
            let debug = false;
            let quiet = false;
            let _reduce = Reduce::new()?.debug(debug).quiet(quiet).loglevel(log::Level::Trace).init()?;
        } else {
            println!("no sub command given");
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {
    use fungus::prelude::*;
    use reduce::*;

    #[test]
    fn test_main() {
        let reduce = Reduce::new().unwrap().loglevel(log::Level::Trace).init().unwrap();
    }
}
