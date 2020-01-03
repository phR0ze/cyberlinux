use fungus::prelude::*;
use serde_yaml;
use std::cell::RefCell;
use std::fmt;
use std::rc::Rc;

use crate::model;

pub const APP_NAME: &'static str = env!("CARGO_PKG_NAME");
pub const APP_VERSION: &'static str = env!("CARGO_PKG_VERSION");
pub const APP_DESCRIPTION: &'static str = env!("CARGO_PKG_DESCRIPTION");

pub const BASE_PROFILE: &'static str = "base";

// Reduce implementation
// -------------------------------------------------------------------------------------------------
pub struct Reduce {
    pub(crate) debug: bool,
    pub(crate) quiet: bool,
    pub(crate) homedir: PathBuf,
    pub(crate) rootdir: PathBuf,
    pub(crate) loglevel: log::Level,
    pub(crate) out: Rc<RefCell<dyn io::Write>>,
    pub(crate) paths: model::Paths,
    pub(crate) vars: model::Vars,
}
impl Default for Reduce {
    fn default() -> Self {
        Self {
            debug: Default::default(),
            quiet: Default::default(),
            homedir: Default::default(),
            rootdir: Default::default(),
            loglevel: log::Level::Info,
            out: Rc::new(RefCell::new(io::stdout())),
            paths: Default::default(),
            vars: Default::default(),
        }
    }
}
impl Reduce {
    // Create a new reduce instance with defaults.
    pub fn new() -> Result<Self> {
        let homedir = user::home()?;
        Ok(Self { homedir: homedir, ..Default::default() })
    }

    /// Set the debug mode with the given `yes` value.
    pub fn debug(&mut self, yes: bool) -> &mut Self {
        self.debug = yes;
        self
    }

    /// Set the quiet mode with the given `yes` value.
    pub fn quiet(&mut self, yes: bool) -> &mut Self {
        self.quiet = yes;
        Logger::enable_silence();
        self
    }

    /// Set the homedir to use
    pub fn homedir<T: AsRef<Path>>(&mut self, path: T) -> Result<&mut Self> {
        self.homedir = path.as_ref().abs()?;
        Ok(self)
    }

    /// Set the rootdir to use. Defaults to a parent in the tree where `initramfs` exists
    pub fn rootdir<T: AsRef<Path>>(&mut self, path: T) -> Result<&mut Self> {
        self.rootdir = path.as_ref().abs()?;
        Ok(self)
    }

    /// Set the log level to use to `level`
    pub fn loglevel(&mut self, level: log::Level) -> &mut Self {
        self.loglevel = level;
        self
    }

    /// Initialize reduce with the configured options
    pub fn init(&mut self) -> Result<&mut Self> {
        // Configure logging and print out startup
        Logger::init()?;
        Logger::set_level(self.loglevel);
        info!("{}", format!("<<{{ {} v{} }}>>", APP_NAME, APP_VERSION).green().bold());

        // Configure pathing and load profile
        self.configure_pathing()?;
        self.load_profile(self.paths.profiles_dir.mash(format!("{}.yml", BASE_PROFILE)))?;

        Ok(self)
    }

    /// Configure pathing
    pub(crate) fn configure_pathing(&mut self) -> Result<()> {
        info!("Configuring pathing...");

        // Resolve root directory working our way up the path until we find `initramfs` if not set
        if self.rootdir == PathBuf::new() {
            self.rootdir = exec::dir()?;
            loop {
                if self.rootdir.join("initramfs").exists() {
                    break;
                }
                self.rootdir = self.rootdir.dir()?;
            }
        }
        self.paths = model::Paths::init(&self.homedir, &self.rootdir)?;
        Ok(())
    }

    /// Create any directories that needs to occur returning true if directories were created.
    pub(crate) fn create_directory_structure(&mut self) -> Result<bool> {
        let mut changed = false;
        //user::pause_sudo();

        info!("Creating root directory structure");
        let paths = vec![
            &self.paths.work_dir,
            &self.paths.tmp_dir,
            &self.paths.iso_dir,
            &self.paths.deployment_images,
            &self.paths.boot_iso,
            &self.paths.efi_iso,
            &self.paths.grub_iso,
            &self.paths.grub_work,
            &self.paths.deployments_dir,
            &self.paths.initramfs_work,
            &self.paths.image_dirs.first().unwrap(),
            &self.paths.packer_work,
            &self.paths.vagrant_dir,
        ];
        for x in &paths {
            if !x.exists() {
                info!("Creating dir: {}", x.to_string()?.cyan());
                sys::mkdir(&x)?;
                changed = true;
            }
        }

        Ok(changed)
    }

    // Load the given profile
    pub(crate) fn load_profile<T: AsRef<Path>>(&mut self, path: T) -> Result<()> {
        let target = path.as_ref().to_path_buf();
        if self.paths.loaded_profiles.contains(&target) {
            return Ok(());
        }
        info!("Loading target profile: {}", target.to_string()?.cyan());
        let file = fs::File::open(&target)?;
        let profile: model::Profile = serde_yaml::from_reader(file)?;
        debug!("{:#?}", profile);

        self.paths.loaded_profiles.push(target);
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
    use fungus::prelude::*;

    // Reusable teset setup
    struct Setup {
        temp: PathBuf,
        root: PathBuf,
    }
    impl Setup {
        fn init() -> Self {
            let setup = Self {
                temp: PathBuf::from("tests/temp").abs().unwrap(),
                root: env::current_dir().unwrap().parent().unwrap().parent().unwrap().to_path_buf(),
            };
            sys::mkdir(&setup.temp).unwrap();
            setup
        }
    }

    #[test]
    fn test_init() {
        let setup = Setup::init();
        let mut reduce = Reduce::new().unwrap();
        reduce.quiet(true);

        assert!(reduce.init().is_ok());
        assert_eq!(reduce.paths.root_dir, setup.root);
        let profile = reduce.paths.profiles_dir.mash(format!("{}.yml", BASE_PROFILE));
        assert!(reduce.paths.loaded_profiles.contains(&profile));
    }

    #[test]
    fn test_configure_pathing() {
        let setup = Setup::init();
        let mut reduce: Reduce = Default::default();

        assert_eq!(reduce.paths.root_dir, PathBuf::new());
        assert!(reduce.configure_pathing().is_ok());
        assert_eq!(reduce.paths.root_dir, setup.root);
    }

    #[test]
    fn test_load_profile() {
        let mut reduce: Reduce = Default::default();
        reduce.configure_pathing().unwrap();
        let profile = reduce.paths.profiles_dir.mash(format!("{}.yml", BASE_PROFILE));
        assert!(reduce.load_profile(profile).is_ok());
    }
}
