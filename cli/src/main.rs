extern crate clap;
use clap::{App, Arg, SubCommand};

const VERSION: Option<&'static str> = option_env!("CARGO_PKG_VERSION");

fn main() {
    let cmds = App::new("My Super Program")
        .version("1.0")
        .author("Kevin K. <kbknapp@gmail.com>")
        .about("Does awesome things")
        .subcommand(
            SubCommand::with_name("build")
                .about("build TARGETS PROFILE")
                .subcommand(SubCommand::with_name("all")),
        )
        .get_matches();

    // Execute build command
    if let Some(ref matches) = cmds.subcommand_matches("build") {
        if matches.is_present("all") {
            println!("subcommand all given");
        } else {
            println!("no sub command given");
        }
    } else {
        cmds.usage();
        println!("MyProgram v{}", VERSION.unwrap_or("unknown"));
    }
}
