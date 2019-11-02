// laconic macros
//--------------------------------------------------------------------------------------------------

// Convert the given value to a String
#[macro_export]
macro_rules! s {
    ($name:expr) => {
        String::from($name)
    };
}

#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
