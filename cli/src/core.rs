use colored::*;
use errors::Result;
use log;
use logs;
use std::cell::RefCell;
use std::fmt;
use std::fs;
use std::io;
use std::path::PathBuf;
use std::rc::Rc;
use sys::*;
use yaml_rust::YamlLoader;

use crate::model;
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
    pub(crate) paths: model::Paths,
}
impl Default for Reduce {
    fn default() -> Self {
        Self {
            debug: Default::default(),
            quiet: Default::default(),
            home_dir: Default::default(),
            out: Rc::new(RefCell::new(io::stdout())),
            paths: Default::default(),
        }
    }
}
impl Reduce {
    // Create a new reduce instance with defaults.
    pub fn new() -> Result<Self> {
        Self::new_with(vec![])
    }

    // Create a new reduce instance with the given options.
    pub fn new_with(opts: Vec<Opt>) -> Result<Self> {
        let mut reduce = Self {
            debug: opts.debug(),
            quiet: opts.quiet(),
            home_dir: opts.home(),
            out: opts.stdout(),
            ..Default::default()
        };

        // Print startup and configure logging based off the Opt::LogLevel option
        logs::init_with(vec![logs::Opt::Level(opts.log_level())])?;
        //writeln!(reduce, "{}", format!("<<{{ {} v{} }}>>", APP_NAME, APP_VERSION).green().bold());
        log::info!("{}", format!("<<{{ {} v{} }}>>", APP_NAME, APP_VERSION).green().bold());

        // Configure pathing and load profile
        reduce.configure_pathing()?;
        reduce.load_profile("base")?;
        Ok(reduce)
    }

    // Configure pathing
    pub(crate) fn configure_pathing(&mut self) -> Result<()> {
        log::info!("Configuring pathing...");
        self.paths = model::Paths::init(&self.home_dir)?;
        Ok(())
    }

    // Load the given profile
    pub(crate) fn load_profile(&mut self, target: &str) -> Result<()> {
        if self.paths.loaded_profiles.contains(&target.to_string()) {
            return Ok(());
        }
        log::info!("Loading target profile: {}", target.cyan());
        let profile_path = self.paths.profiles_dir.join(format!("{}.yml", target));
        let data = fs::read_to_string(profile_path)?;
        let profile = YamlLoader::load_from_str(&data)?;

        self.paths.loaded_profiles.push(target.to_string());
        Ok(())
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
    fn test_reduce_opts() {
        let reduce = Reduce::new_with(vec![
            Opt::Debug(true),
            Opt::Quiet(false),
            Opt::Home(PathBuf::from("/foo")),
            Opt::LogLevel(log::Level::Debug),
        ])
        .unwrap();
        assert_eq!(PathBuf::from("/foo"), reduce.home_dir);
        assert_eq!(true, reduce.debug);
        assert_eq!(false, reduce.quiet);
        assert_eq!(log::Level::Debug, log::max_level().to_level().unwrap());

        let home = sys::home_dir().unwrap();
        let reduce = Reduce::new_with(vec![]).unwrap();
        assert_eq!(home, reduce.home_dir);
        assert_eq!(false, reduce.debug);
        assert_eq!(false, reduce.quiet);
        assert_eq!(log::Level::Info, log::max_level().to_level().unwrap());
    }

    #[test]
    fn test_configure_pathing() {
        let mut reduce: Reduce = Default::default();
        assert_eq!("", reduce.paths.root_dir.to_str().unwrap());
        assert_eq!(true, reduce.configure_pathing().is_ok());

        let root = env::current_dir().unwrap().parent().unwrap().to_path_buf();
        assert_eq!(root, reduce.paths.root_dir);
    }

    #[test]
    fn test_load_profile() {
        let mut reduce: Reduce = Default::default();
        reduce.configure_pathing().unwrap();
        reduce.load_profile("base").unwrap();
    }
}
