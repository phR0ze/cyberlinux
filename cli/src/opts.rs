use log;
use std::cell::RefCell;
use std::io;
use std::path::PathBuf;
use std::rc::Rc;
use sys;

// Reduce options
// -------------------------------------------------------------------------------------------------
#[derive(Clone)]
pub enum Opt {
    Home(PathBuf),
    Debug(bool),
    Quiet(bool),
    Stdout(Rc<RefCell<dyn io::Write>>),
    LogLevel(log::Level),
}
pub trait OptsExt {
    fn home(&self) -> PathBuf;
    fn debug(&self) -> bool;
    fn quiet(&self) -> bool;
    fn stdout(&self) -> Rc<RefCell<dyn io::Write>>;
    fn log_level(&self) -> log::Level;
}
impl OptsExt for Vec<Opt> {
    fn home(&self) -> PathBuf {
        for opt in self {
            if let Opt::Home(home) = opt.clone() {
                return home;
            }
        }
        sys::home_dir().unwrap()
    }
    fn debug(&self) -> bool {
        for opt in self {
            if let Opt::Debug(debug) = opt.clone() {
                return debug;
            }
        }
        false
    }
    fn quiet(&self) -> bool {
        for opt in self {
            if let Opt::Quiet(quiet) = opt.clone() {
                return quiet;
            }
        }
        false
    }
    fn stdout(&self) -> Rc<RefCell<dyn io::Write>> {
        for opt in self {
            if let Opt::Stdout(stdout) = opt.clone() {
                return stdout;
            }
        }
        Rc::new(RefCell::new(io::stdout()))
    }
    fn log_level(&self) -> log::Level {
        for opt in self {
            if let Opt::LogLevel(level) = opt.clone() {
                return level;
            }
        }
        log::Level::Info
    }
}
