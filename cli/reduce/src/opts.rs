// use fungus::prelude::*;
// use std::cell::RefCell;
// use std::rc::Rc;

// // Reduce options
// // -------------------------------------------------------------------------------------------------
// #[derive(Clone)]
// pub enum Opt {
//     Home(PathBuf),
//     Debug(bool),
//     Quiet(bool),
//     Stdout(Rc<RefCell<dyn io::Write>>),
//     LogLevel(log::Level),
// }
// pub trait OptsExt {
//     fn home(&self) -> PathBuf;
//     fn debug(&self) -> bool;
//     fn quiet(&self) -> bool;
//     fn stdout(&self) -> Rc<RefCell<dyn io::Write>>;
//     fn log_level(&self) -> log::Level;
// }
// impl OptsExt for Vec<Opt> {
//     fn home(&self) -> PathBuf {
//         for opt in self {
//             if let Opt::Home(home) = opt.clone() {
//                 return home;
//             }
//         }
//         user::home().unwrap()
//     }
//     fn debug(&self) -> bool {
//         for opt in self {
//             if let Opt::Debug(debug) = opt.clone() {
//                 return debug;
//             }
//         }
//         false
//     }
//     fn quiet(&self) -> bool {
//         for opt in self {
//             if let Opt::Quiet(quiet) = opt.clone() {
//                 return quiet;
//             }
//         }
//         false
//     }
//     fn stdout(&self) -> Rc<RefCell<dyn io::Write>> {
//         for opt in self {
//             if let Opt::Stdout(stdout) = opt.clone() {
//                 return stdout;
//             }
//         }
//         Rc::new(RefCell::new(io::stdout()))
//     }

//     // Get the log level given during init. Override to error if quiet=true
//     fn log_level(&self) -> log::Level {
//         if self.quiet() {
//             return log::Level::Error;
//         }
//         for opt in self {
//             if let Opt::LogLevel(level) = opt.clone() {
//                 return level;
//             }
//         }
//         log::Level::Info
//     }
// }

// #[cfg(test)]
// mod tests {
//     use super::*;

//     #[test]
//     fn test_home() {
//         let home = user::home().unwrap();
//         let opts: Vec<Opt> = vec![];
//         assert_eq!(home, opts.home());

//         let opts = vec![Opt::Home(PathBuf::from("/foo"))];
//         assert_eq!(PathBuf::from("/foo"), opts.home());
//     }

//     #[test]
//     fn test_debug() {
//         let opts: Vec<Opt> = vec![];
//         assert_eq!(false, opts.debug());

//         let opts = vec![Opt::Debug(true)];
//         assert_eq!(true, opts.debug());
//     }

//     #[test]
//     fn test_quiet() {
//         let opts: Vec<Opt> = vec![];
//         assert_eq!(false, opts.quiet());

//         let opts = vec![Opt::Quiet(true)];
//         assert_eq!(true, opts.quiet());
//     }

//     #[test]
//     fn test_log_level() {
//         let opts: Vec<Opt> = vec![];
//         assert_eq!(log::Level::Info, opts.log_level());

//         let opts = vec![Opt::LogLevel(log::Level::Debug)];
//         assert_eq!(log::Level::Debug, opts.log_level());
//     }
// }
