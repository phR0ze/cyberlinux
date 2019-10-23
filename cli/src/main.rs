extern crate clap;
extern crate log;

// Cargo information
const APP_NAME: &'static str = env!("CARGO_PKG_NAME");
const APP_VERSION: &'static str = env!("CARGO_PKG_VERSION");
const APP_DESCRIPTION: &'static str = env!("CARGO_PKG_DESCRIPTION");

fn main() {
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
                .subcommand(
                    clap::SubCommand::with_name("multiboot").about("Build grub multiboot image"),
                )
                .subcommand(clap::SubCommand::with_name("iso").about("Build bootable ISO"))
                .subcommand(
                    clap::SubCommand::with_name("isofull")
                        .about("Build initramfs, multiboot and iso"),
                ),
        )
        .get_matches();

    // Execute build command
    if let Some(ref matches) = cmds.subcommand_matches("build") {
        if matches.is_present("all") {
            println!("Version: {}", format!("v{}", APP_VERSION).to_string());
        } else {
            println!("no sub command given");
        }
    }
}

// // Parse the command line arguments
// fn run(matches: ArgMatches) -> Result<(), String> {
//     let min_log_level = match matches.occurrences_of("verbose") {
//         0 => log::Level::Info,
//         1 => log::Level::Debug,
//         2 | _ => slog::Level::Trace,
//     };
//     let drain = slog::level_filter(min_log_level, slog_term::streamer().build()).fuse();
//     let logger = slog::Logger::root(drain, o!());
//     trace!(logger, "app_setup");
//     // setting up app...
//     debug!(logger, "load_configuration");
//     trace!(logger, "app_setup_complete");
//     // starting processing...
//     info!(logger, "processing_started");
//     // ...
// }
