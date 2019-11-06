use std::error;
use std::fmt;

pub type Result<T> = std::result::Result<T, Error>;

/// A list of potential Reduce errors.
#[derive(Clone, Copy, Debug, Eq, Hash, Ord, PartialEq, PartialOrd)]
pub enum ErrorKind {
    /// An entity was not found.
    NotFound,

    /// Any error not part of this list.
    Other,
}
impl ErrorKind {
    pub(crate) fn as_str(&self) -> &'static str {
        match *self {
            ErrorKind::NotFound => "entity not found",
            ErrorKind::Other => "other os error",
        }
    }
}

#[derive(Debug, Clone)]
pub struct Error {
    //     repr: Repr,
}
impl Error {
    // /// Creates a new error
    // pub fn new<E>(kind: ErrorKind, error: E) -> Error
    // where
    //     E: Into<Box<dyn error::Error + Send + Sync>>,
    // {
    //     Self::_new(kind, error.into())
    // }

    // fn _new(kind: ErrorKind, error: Box<dyn error::Error + Send + Sync>) -> Error {
    //     Error { repr: Repr::Custom(Box::new(Custom { kind, error })) }
    // }
}

impl fmt::Display for Error {
    fn fmt(&self, fmt: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "example error")
    }
}

impl error::Error for Error {
    fn source(&self) -> Option<&(dyn error::Error + 'static)> {
        None
    }
}

// enum Repr {
//     Simple(ErrorKind),
//     Custom(Box<Custom>),
// }

// #[derive(Debug)]
// struct Custom {
//     kind: ErrorKind,
//     error: Box<dyn error::Error + Send + Sync>,
// }

// impl fmt::Debug for Repr {
//     fn fmt(&self, fmt: &mut fmt::Formatter<'_>) -> fmt::Result {
//         match *self {
//             Repr::Os(code) => fmt
//                 .debug_struct("Os")
//                 .field("code", &code)
//                 .field("kind", &sys::decode_error_kind(code))
//                 .field("message", &sys::os::error_string(code))
//                 .finish(),
//             Repr::Custom(ref c) => fmt::Debug::fmt(&c, fmt),
//             Repr::Simple(kind) => fmt.debug_tuple("Kind").field(&kind).finish(),
//         }
//     }
// }
