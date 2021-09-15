rust
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Rust is a systems programming language that aims to offer both performance and safety. It provides
the low-level control of C, but also enforces memory and thread safety. Rust applications compile
directly into machine code, allowing for highly optimized code and better performance. Rust is being
adopted at an incredible rate. It's the most loved language by developers according to the [Stack
Overflow Developer Survey](https://insights.stackoverflow.com/survey/2019#technology-_-most-loved-dreaded-and-wanted-languages)
and its the fith fast growing language according to [Github's State of the Octoverse](https://octoverse.github.com/projects.html)
There's no virtual machine or interpreter sitting between your code and your computer.

Resources:
* https://blog.rust-lang.org/2015/04/10/Fearless-Concurrency.html
* https://medium.com/@jondot/my-key-learnings-after-30-000-loc-in-rust-a553e6403c19
* https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/rust-go.html
* https://benchmarksgame-team.pages.debian.net/benchmarksgame/fastest/rust-gpp.html

### Quick links
* [.. up dir](..)
* [Getting Started](#getting-started)
  * [Install Rust](#install-rust)
  * [Configure VSCode](#configure-vscode)
  * [Create new project](#create-new-project)
    * [1. Configure Cargo.toml](#configure-cargo-toml)
    * [2. Add .vscode/tasks.json](#add-vscode-tasks-json)
    * [3. Configure .gitignore](#configure-gitignore)
    * [4. Add library to bin](#add-library-to-bin)
    * [5. Add git commit and build date](#add-git-commit-and-build-date)
    * [6. Add Githook Auto Version Increment](#add-githook-auto-version-increment)
    * [7. Link to github repo](#link-to-github-repo)
    * [8. Project Structure](#project-structure)
  * [Configure Github Actions](#configure-github-actions)
  * [Configure Codecov](#configure-codecov)
    * [Tarpaulin](#tarpaulin)
* [Rust News](#rust-news)
  * [This week in rust](#this-week-in-rust)
  * [This month in rust osdev](#this-month-in-rust-osdev)
  * [This month in rust gamedev](#this-month-in-rust-gamedev)
* [Best Practices](#best-practices)
  * [Builder Pattern](#builder-pattern)
  * [Panics](#panics)
  * [Logging](#logging)
    * [Logging requirments](#logging-requirements)
    * [Logging crates](#logging-crates)
    * [Logging in libraries](#logging-in-libraries)
  * [Errors](#errors)
  * [Configuration](#configuration)
* [Idiomatic Rust](#idiomatic-rust)
  * [Collections](#collections)
    * [Pass slices over vectors](#pass-slices-over-vectors)
  * [Combinators](#combinators)
  * [Iterators](#iterators)
    * [IntoIterator](#into-iterator)
  * [Strings](#strings)
    * [Accept &str](#accept-str)
    * [Accept Into String](#accept-into-string)
    * [Return &str where possible](#return-str-where-possible)
    * [Use to\_owned over to\_string](#use-to-owned-over-to-string)
  * [Paths](#paths)
    * [Pass Path over String](#pass-path-over-string)
* [Language](#language)
  * [Version](#version)
  * [Dependency Hell](#dependency-hell)
  * [Documentation](#documentation)
  * [Mailing List](#mailing-list)
  * [Generics](#generics)
  * [Macros](#macros)
  * [Ownership](#ownership)
    * [Mutable](#mutable)
    * [Mutable Reference](#mutable-reference)
    * [Lifetimes](#lifetimes)
  * [Parsers](#parsers)
  * [Web Frameworks](#web-frameworks)
  * [Web Scraping](#web-scraping)
* [rustup](#rustup)
  * [Update Tools](#update-tools)
* [CI/CD](#ci-cd)
  * [Github Actions](#github-actions)
  * [Code Coverage Reporting](#code-coverage-reporting)
    * [Codecov](#codecov)
    * [Coveralls](#coveralls)
  * [Code Coverage Generation](#code-coverage-generation)
    * [Tarpaulin](#tarpaulin)
* [Cargo](#cargo)
  * [Examples](#examples)
  * [Binary Size](#binary-size)
  * [Workspaces](#workspaces)
  * [Packages](#packages)
  * [Clippy](#clippy)
  * [Crates](#crates)
  * [Modules](#modules)
  * [Expand Macros](#expand-macros)
  * [Static Binary](#static-binary)
  * [Tests](#tests)
    * [Unit Tests](#unit-tests)
    * [Documentation Tests](#documentation-tests)
    * [Integration Tests](#integration-tests)
* [Crates.io](#crates-io)
  * [Download crate](#download-crate)
* [Cross Platform](#cross-platform)
* [Language Interop](#language-interop)
  * [Go Interop](#go-interop)

# Getting Started <a name="getting-started"/></a>

## Install Rust <a name="install-rust"/></a>
see [Install Rust](../vscode#install-rust)

## Configure VScode<a name="configure-vscode"/></a>
see [Config Rust](../vscode#config-rust)

## Create new project <a name="create-new-project"/></a>
Always start with a binary project and then use `[workspace]` to split the structure up. This allows
for your cli to pull in dependencies that don't affect the library.

### 1. Configure Cargo.toml <a name="configure-cargo-toml"/></a>
Create the binary project
```bash
$ cargo new <name> --bin
```

Edit the Cargo.toml and add the basics. We'll add the `[workspace]` in a later step.

All `path` dependencies in in the workspace e.g. `path = "libclu"` will be included in the workspace.
* https://doc.rust-lang.org/cargo/reference/workspaces.html#the-workspace-section

**Cargo.yaml Example:**
```
[package]
name = "clu"
version = "0.0.1"
edition = "2018"
authors = ["phR0ze"]
license = "MIT OR Apache-2.0"
description = "Automation for the Arch Linux ecosystem"
readme = "README.md"
homepage = "https://github.com/phR0ze/clu"
repository = "https://github.com/phR0ze/clu"
exclude = [
  "docs",
  "examples",
  ".git",
  ".githooks",
  ".github",
  "tests",
  "benches",
  "target",
  ".vscode"
]

# Spliting the library from the binary with workspaces allows for a separation of
# dependencies so the binary dependencies aren't required for the library.
# path = <dependency> entries in dependencies are automatically included
[workspace]

# Higher the opt-level value the slower the compile time
[profile.release]
opt-level = 3   # Optimize for speed over size
lto = true      # Futher assist in optimization
debug = true    # Enable debug symbols for witcher

[profile.dev]
opt-level = 0   # Default no optimization

[dependencies]
libclu = { path = "libclu" }
```

### 2. Add .vscode/tasks.json <a name="add-vscode-tasks-json"/></a>
```bash
$ mkdir -p .vscode
tee .vscode/tasks.json <<EOL
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Build",
            "type": "shell",
            "command": [
                "cargo build --all-features",
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        },
        {
            "label": "Test",
            "type": "shell",
            "command": "cargo test --all-features",
            "group": {
                "kind": "test",
                "isDefault": true
            }
        }
    ]
}
EOL
```

### 3. Configure .gitignore <a name="configure-gitignore"/></a>
```
/target/
**/*.rs.bk
tests/temp/
bin/
```

### 4. Add library to bin <a name="add-library-to-bin"/></a>
To add a library to the workspace do the following:

1. Add library to binary project
   ```bash
   $ cd clu
   $ cargo new libclu --lib 
   ```
2. Update its `Cargo.toml` with the following:
   ```toml
   [package]
   name = "libclu"
   version = "0.0.1"
   edition = "2018"
   authors = ["phR0ze"]
   license = "MIT OR Apache-2.0"
   description = "Automation for the Arch Linux ecosystem"
   readme = "README.md"
   homepage = "https://github.com/phR0ze/clu/libclu"
   repository = "https://github.com/phR0ze/clu/libclu"
   exclude = [
     "docs",
     "examples",
     ".git",
     ".githooks",
     ".github",
     "tests",
     "benches",
     "target",
     ".vscode"
   ]
   
   [dependencies]
   
   # Examples and tests are built with these dependencies
   [dev-dependencies]
   
   # build.rs is built with these dependencies
   [build-dependencies]
   chrono = "0.4"
   ```
4. Add `libclu` as a dependency to the top level `Cargo.toml` file:
   ```toml
   [dependencies]
    libclu = { path = "libclu" }
   ```
5. Add the following function to file `libclu/src/lib.rs`:
   ```rust
   pub fn test() {
       println!(r#"From the lib"#);
   }
   ```
6. Add the following to the `src/main.rs`. Because `test()` is defined as `pub` and is
   in the top level of the library it is available from the library scope.
   ```
   use libclu;

   fn main() {
     libclu::test();
   }
   ```

### 5. Add git commit and build date <a name="add-git-commit-and-build-date"/></a>
I like to include the git commit and build date in my appliation version output to get something like
the following:
```
CLU - Automation for the Arch Linux ecosystem
------------------------------------------------------------
Version:           0.0.1
Build Date:        2020.02.03
Git Commit:        a4a6c172c860b8f4a9f03bc879d792529c58c1d1
```

In order to do this you need to leverage Cargo's ability to have a build script that runs before it
runs to pre-compile C/C++ appliations or do other pre-work. The presence of the `build.rs` in the
root of the project will cause cargo to compile it and run it before building the package.
* [pre-build scripts](https://doc.rust-lang.org/cargo/reference/build-scripts.html)

1. Add the following build file `build.rs` to your library project e.g. `libclu`
   ```rust
   use chrono::prelude::*;
   use std::process::Command;
   
   fn main() {
       // Set the APP_BUILD_DATE
       let local: DateTime<Local> = Local::now();
       println!("cargo:rustc-env=APP_BUILD_DATE={}.{:0>2}.{:0>2}", local.year(), local.month(), local.day());
   
       // Set the APP_GIT_COMMIT
       let output = Command::new("git").args(&["rev-parse", "HEAD"]).output().unwrap();
       let git_hash = String::from_utf8(output.stdout).unwrap();
       println!("cargo:rustc-env=APP_GIT_COMMIT={}", git_hash);
   }
   ```

2. Add the `chrono = "0.4"` to your `[build-dependencies]` section of your library `Cargo.toml`
   ```toml
   [build-dependencies]
   chrono = "0.4"
   ```

3. Add the following to `libclu/src/lib.rs` in your library crate:
   ```rust
   pub const APP_NAME: &str = "cre";
   pub const APP_VERSION: &str = env!("CARGO_PKG_VERSION");
   pub const APP_DESCRIPTION: &str = env!("CARGO_PKG_DESCRIPTION");
   pub const APP_GIT_COMMIT: &str = env!("APP_GIT_COMMIT");
   pub const APP_BUILD_DATE: &str = env!("APP_BUILD_DATE");
   ```

4. Replace the content of `src/main.rs` in your binary crate at the root with the following:
   ```rust
   use libclu;

   fn main() {
       println!("{} - {}", libclu::APP_NAME, libclu::APP_DESCRIPTION);
       println!("{:->w$}", "-", w = 60);
       println!("{:<w$} {}", "Version:", libclu::APP_VERSION, w = 18);
       println!("{:<w$} {}", "Build Date:", libclu::APP_BUILD_DATE, w = 18);
       println!("{:<w$} {}", "Git Commit:", libclu::APP_GIT_COMMIT, w = 18);

       libclu::test();
   }
   ```
5. Build the project by pressing `Ctrl+Shift+b`
6. Execute your new application:
   ```bash
   $ cargo run -q
   CLU - Automation for the Arch Linux ecosystem
   ------------------------------------------------------------
   Version:           0.0.2
   Build Date:        2020.11.07
   Git Commit:        d7e27829e00dc8d292bd6445d5e88c4f6a0c26f7
   From the lib
   ```
7. Update the githoook to include the lib autoversion
   ```
   increment_version 'libclu/Cargo.toml' '(.*version =.*")([0-9]+\.[0-9]+\.[0-9]+)(".*)'
   ```

### 6. Add Githook Auto Version Increment <a name="add-githook-auto-version-increment"/></a>

1. Add the githooks to your project
   ```bash
   # Copy .githooks
   $ cp -R ~/Projects/githooks/hooks .githooks
   ```
2. Update target files and match regex:
   a. Edit `.githooks/commit-msg`  
   b. Change the `get_version` line to  
      ```
      get_version 'Cargo.toml' '.*version =.*"([0-9]+\.[0-9]+\.[0-9]+)".*' ver
      ```
   c. Edit `.githooks/pre-commit`  
   d. Change the `increment_version` line to  
      ```
      increment_version 'Cargo.toml' '(.*version =.*")([0-9]+\.[0-9]+\.[0-9]+)(".*)'
      ```
   e. Add an additional `increment_version` line for each target  
3. Configure githooks to now take effect
   ```
   $ git config core.hooksPath .githooks
   ```

### 7. Link to github repo <a name="link-to-github-repo"/></a>
```bash
$ git remote add upstream git@github.com:phR0ze/clu
```

### 8. Project structure <a name="project-structure"/></a>
```
<project>
├── .git
├── .githooks
│   ├── commit-msg
│   ├── pre-commit
│   └── utils
├── .github
│   └── workflows
│       └── build.yaml
├── libcre
│   ├── build.rs
│   ├── Cargo.toml
│   ├── LICENSE-APACHE
│   ├── LICENSE-MIT
│   └── src
│       └── lib.rs
├── src
│   └── main.rs
├── .vscode
│   ├── launch.json
│   └── tasks.json
├── Cargo.lock
├── Cargo.toml
├── .gitignore
├── LICENSE-APACHE
├── LICENSE-MIT
└── README.md
```

## Configure Github Actions <a name="configure-github-actions"/></a>
see [Github Actions](github.md#actions)

## Configure Codecov <a name="configure-codecov"/></a>
Codecov is the online SaaS tool for viewing code coverage for others with a badge but to get the
actual coverate numbers you need to use `tarpaulin`. I'm using `tarpaulin` because `grcov` requires
Rust nightly and codecov because coveralls doesn't seem to have an easy github action.

1. Login [to the UI](https://app.codecov.io) using github creds
2. Click the `Add Repos` option on the left
3. Flip the switch to enable `witcher`
4. Copy the new token that pops up
4. Switch back to github and navigate to `Settings >Secrets`
5. Click `New Repository Secret` Add the `CODECOV_TOKEN` secret with the copied value

### Configure Tarpaulin <a name="configure-tarpaulin"/></a>
1. Install tarpaulin
   ```bash
   $ cargo install cargo-tarpaulin
   ```
2. Run tarpaulin
```bash
$ cargo tarpaulin -v
```

# Best Practices <a name="best-practices"/></a>

## Builder Pattern <a name="builder-pattern"/></a>
https://doc.rust-lang.org/1.0.0/style/ownership/builders.html

## Panics <a name="panics"/></a>
I don't agree with the notion that a panic is a valid answer. It is always better to exit with an
error code and a controlled stack trace than to bail with a panic. All errors should be bubbled up
the stack allowing handlers to fire correctly before the process shuts down.

References:
* [Panic Resilience](https://towardsdatascience.com/how-to-design-for-panic-resilience-in-rust-55d5fd2478b9)

We should be able to catch a `Ctrl+c` or `panic!` and execute handling before going down.

## Logging <a name="logging"/></a>

### Logging requirements <a name="logging-requirements"/></a>
I need a simple logging library that supports:

* timestamp, module name, function name, line number
* log levels
* structured logs
* optional colorization

### Logging crates <a name="logging-crates"/></a>
* [rust-lang/log](https://github.com/rust-lang/log) lightweight logging facade.
* [slog-rs/slog](https://github.com/slog-rs/slog) echosystem of reusable components for structured logging
  * [slog-json](https://github.com/slog-rs/json)
  * [sloggers](https://github.com/sile/sloggers)
* [tokio-rs/Tracing](https://github.com/tokio-rs/tracing) a framework for instrumenting Rust programs

### Logging in libraries <a name="logging-in-libraries"/></a>
Libraries should only rely on the `tracing` crate and use the provided macros and types to collect
whatever information might be useful to downstream consumers.

```toml
[dependencies]
tracing = "0.1"
```

Note: Libraries should `NOT` install a collector by using a method that calls `set_global_default()`, as
this will cause conflicts when executables try to set the default later.

* https://github.com/tokio-rs/tracing

```rust
use std::{error::Error, io};
use tracing::{debug, error, info, span, warn, Level};

// the `#[tracing::instrument]` attribute creates and enters a span
// every time the instrumented function is called. The span is named after the
// the function or method. Parameters passed to the function are recorded as fields.
#[tracing::instrument]
pub fn shave(yak: usize) -> Result<(), Box<dyn Error + 'static>> {
    // this creates an event at the DEBUG level with two fields:
    // - `excitement`, with the key "excitement" and the value "yay!"
    // - `message`, with the key "message" and the value "hello! I'm gonna shave a yak."
    //
    // unlike other fields, `message`'s shorthand initialization is just the string itself.
    debug!(excitement = "yay!", "hello! I'm gonna shave a yak.");
    if yak == 3 {
        warn!("could not locate yak!");
        // note that this is intended to demonstrate `tracing`'s features, not idiomatic
        // error handling! in a library or application, you should consider returning
        // a dedicated `YakError`. libraries like snafu or thiserror make this easy.
        return Err(io::Error::new(io::ErrorKind::Other, "shaving yak failed!").into());
    } else {
        debug!("yak shaved successfully");
    }
    Ok(())
}
```

## Errors <a name="errors"/></a>
see github.com/phR0ze/errors ?

## Configuration <a name="configuration"/></a>
YAML configuration file in `~/.config`

* [config](https://crates.io/crates/config)

# Idiomatic Rust <a name="idiomatic-rust"/></a>

## Collections <a name="collections"/></a>
A `Vec<T>` is an owning collection of `T`. Vectors always allocate their data on the heap.  `Vectors`
are to `Slices` what `String` is to `&str`. A `Slice` is a reference or view into an array or vector.
They are useful for allowing safe, efficient access to an array or portion of an array without
copying it. You can take a slice of a vector, String or &str because they are backed by arrays.
Slices are a borrowed collection of `T` have a type `&[T]`. Vectors can be implicitly dereferenced
from `&Vec<T>` to `&[T]`. 

### Return slices over vectors <a name="return-slices-over-vectors"/></a>
Return a `&[T]` or `impl Iterator<Item=` for ergonomic returns

### Pass slices over vectors <a name="pass-slices-over-vectors"/></a>
To accept a collection type ergonomically use a slice `&[T]` with a `AsRef<T>` which allows for
accepting static slice references for testing as well as `Vec<T>`.

**Slice of &str**:
```rust
fn foo<T: AsRef<str>>(data: &[T]) {
    println!("{}", data.iter().map(|x| x.as_ref()).collect::<Vec<&str>>().join(", "));
}

fn main() {
    foo(&["foo1", "foo2"]);
    foo(&vec!["foo1", "foo2"]);
    foo(&vec!["foo1".to_string(), "foo2".to_string()]);
}
```

**Slice of String**:
```rust
fn foo<I: IntoIterator<Item=T>, T: Into<String>>(data: I) {
    println!("{}", data.into_iter().map(|x| x.into()).collect().join(", "));
}

// Alternate syntax
fn foo<T>(data: T) {
where
    T: IntoIterator,
    T::Item: Into<String>
{
    println!("{}", data.into_iter().map(|x| x.into()).collect().join(", "));
}

fn main() {
    foo(&["foo1", "foo2"]);
    foo(&vec!["foo1", "foo2"]);
    foo(&vec!["foo1".to_string(), "foo2".to_string()]);
}
```

**Slice of custom struct**:
```rust
pub fn join<T: Into<Component>>(components: &[T]) -> String
where
    T: fmt::Display,
{
    let result: Vec<String> = components.iter().map(|x| x.to_string()).collect();
    result.join(", ")
}

fn main() {
    Component::join(&["config"]);
    Component::join(&["config".to_string()]);
    Component::join(&vec![Component::Config]);
}

```

### Return slices over vectors <a name="return-slices-over-vectors"/></a>

```rust
```


## Combinators <a name="combinators"/></a>
Combinators can be used instead of the more verbose `match` and `if let` syntax.

## opt.or(y) <a name="opt-or"/></a>
You can convert match syntax that simply defaults an option with `or()`
```rust
match opt {
  Some(x) => x,
  None => y
}
opt.or(y)
```

```
match opt { Some(x) => foo(x), None => y } === opt.map_or(y, foo)
if let Some(x) = opt { foo(x) } === opt.map_or((), foo)
if let Some(x) = opt { x } else { foo() } === opt.unwrap_or_else(foo)
```

## Iterators <a name="iterators"/></a>
**References:**
* [rust for loops](http://xion.io/post/code/rust-for-loop.html)

### IntoIterator <a name="into-iterator"/></a>
`v.iter()` is the same thing as `IntoIterator::into_iter(&v)`

Why do we need `IntoIterator` and how do we loop on custom types like `Vec` e.g.
```rust
let v = vec!["1", "2", "3"];
for x in v {
    println!("{}", x);
}
```

This is an example of looping implicitly and expending or using up the original vector. By adding a
`&` before the vec like `for x in &v` we actually change what object we're iterating over here. It is
no longer a `Vec<T>` but rather a `&Vec<T>`, an immutable reference to it. Thus `x` is no longer a
`T` but rather a `&T`.

`for x in v` is just ***syntatic sugar*** for:
```rust
let mut iter = IntoIterator::into_iter(v);
loop {
    match iter.next() {
        Some(x) => {
            // body
        },
        None => break,
    }
}
```

What this means is that for a ***for loop*** to work correctly your custom type must implement not
only `Iterator` but also `IntoIterator`.

Forms of IntoIterator
```rust
impl IntoIterator Vec<T> {
    fn into_iter(self) -> Iterator<Item=T> { ... }
}

impl IntoIterator for &Vec<T> {
    fn into_iter(self) -> Iterator<Item=&T> { ... }
}

impl IntoIterator for mut Vec<T> {
    fn into_iter(self) -> Iterator<Item=mut T> { ... }
}

impl IntoIterator for &mut Vec<T> {
    fn into_iter(self) -> Iterator<Item=&mut T> { ... }
}
```

## Strings <a name="strings"/></a>
* If the function never takes ownership accept `&str`
* If the function ever takes ownership accept `T: Into<String>`
* If the method refers to an owned String return `&str`

### Accept &str <a name="accept-str"/></a>
Use `&str` for functions that don't take ownership of the string as this allows for the most ergonic
appearance and still allows for accepting both a `static' &str` and `String`. Some would argue that
`AsRef<str>` is better but although it can accept more types and convert them the internal
`arg.as_ref()` usage and `T: AsRef<str>` make it less visually ergonomic and the gains of more
genericity are overkill and not needed.

```rust
// Allows for references to strings and static strings
fn foo(arg: &str) {
  println!("{}", arg);
}

// Allows for accepting anything that can be turned into a &str
// This is overkill and you loose some ergonomic appearance
fn foo<T: AsRef<str>>(arg: T)
{
  // Use of value
  let arg: &str = arg.as_ref();
  println!("{}", arg);
}
```

### Accept Into String <a name="accept-into-string"/></a>
In the rare case where the function may own the string internally always use `Into<String>` which
allows for the most ergonomic usage while still making it clear that the function takes onwership.
I favor `impl Into<String>` as is aligns more clearly with other languages.

```rust
// Using trait syntax
fn foo(arg: impl Into<String>) 
{
  let arg: String = arg.into();
  println!("{}", arg);
}

// Using generic syntax
fn foo<T: Into<String>>(arg: T)
{
  let arg: String = arg.into();
  println!("{}", arg);
}
```

### Return &str where possible <a name="return-str-where-possible"/></a>


### Use to\_owned over to\_string <a name="use-to-owned-over-to-string"/></a>
When want a `String` type and you have a reference always use the `to_owned()` function rather than
the `to_string()` function. The reason is that the `to_owned()` will have less overhead. The
`to_string()` invokes the `fmt::Display` trait to convert the value into a `String` while the
`to_owned()` will do minimal coercion to get the right value.

## Paths <a name="paths"/></a>

### Pass Path over String <a name="pass-path-over-string"/></a>
When working with paths always prefer the `AsRef<Path>` form to allow for the use of as many
conversion types as possible e.g. `Path`, `PathBuf`, `String`, `&str` and other forms that are
convertable. This allows for the more ergonomic usage.

```rust
fn foo<T>(arg: T)
where
  T: AsRef<Path>
{
  let arg: &Path = arg.as_ref();
  println!("{}", arg);
}
```

# Language <a name="language"/></a>
In [one benchmark](https://medium.com/sean3z/rest-api-node-vs-rust-c75aa8c96343) comparing REST API
performance (using [Rocket](https://rocket.rs/) and [Restify](http://restify.com/) for Node.js),
Ruest handled ***72,000*** requests per second compared to Node.js's ***8,000*** and used just over
***1MB*** of memory when idle compared to Node.js's ***19MB***. Other benchmarks like ([nickel](https://nickel-org.github.io/) for
Rust and [restana](http://github.com/jkyberneees/ana) for Node.js), Rust responded to requests nearly
***100x*** faster on average than Node.js.

Pros:
* Compiles to a single machine code binary
* Fastest modern language that exists comparable to C and C++, crushes Go
* Supports generic programming, operator overloading and polymorphism
* Memory and thread management safety without garbage collection or Virtual Machines
* Directly convertable into Web Assembly to run in Browsers
* Self-hosted compiler i.e. Rust's compiler is written in Rust
* Low level Kernel interaction for easy integration with services like inotify
* Rock solid stability/compatibility with no fear of upgrading Rust core libs nightly
* Ruest solved feature flags with the ability to mix and match your software at compile via Features
* Interop with C and C++
* Solved dependency hell with name mangling
* Excellent libraries:
  * [Clap](https://clap.rs/) - Fantastic CLI library
  * [Serde](https://serde.rs/) - Excellent serialization for JSON, YAML, TOML
  * [Reqwest](https://docs.rs/reqwest/0.9.15/reqwest/) - HTTP Client library
  * [Log](https://docs.rs/log/0.4.8/log/) - Logging
  * [Rayon](https://github.com/rayon-rs/rayon) - Data parallelism across your CPU cores
  * [Actix Web](https://github.com/actix/actix-web) - HTTP Server library better than hyper
  * [Itertools](https://github.com/rust-itertools/itertools) - Extra iterators over your lists
  * [hyper](https://hyper.rs/) - fast HTTP implementation
  * [proptest](https://lib.rs/crates/proptest) - property based testing library
  * [libloading](https://docs.rs/libloading/0.5.0/libloading/) - load C libs
  * [regex](https://docs.rs/regex/1.1.6/regex/) - faster than rust's internal regex

Cons
* Slow compile times
* Steep learning curve

References:
* https://www.rust-lang.org/learn

## Version <a name="version"/></a>
The rust version can be found by checking the compiler

```bash
$ rustc --version
```

## Documenation <a name="documentation"/></a>
You can open the Ruest Book at any point locally and its the same exact thing as remote.
```bash
$ rustup docs --book
```

You can view package documentation with:
```bash
$ cargo doc --open
```

## Dependency Hell <a name="dependency-hell"/></a>
The question answered here is if crate A depends on libc and crate B depends on libc will there be
two versions of libc included in my final binary? If they are compatible versions then one and only 
one is included.

```
     A -- libc 0.2.71
    /
APP
    \
     B -- libc 0.2.*
``` 

References:
* [How rust solved dependency hell](https://stephencoakley.com/2019/04/24/how-rust-solved-dependency-hell)

You can specify libc versions are compatible i.e. specified as interoperable in the cargo manifest of both
crates by the use of the asterisk `*` pattern. This says that my application will work with any
version `0.2.0 >= libc < 0.3.0` i.e. the whole `0.2 series`. In this situation Rust will select the
newer of the two libc dependencies and include that and only that one in the resulting binary and
have both `A` and `B` us that single libc dependency.
```toml
[dependencies]
libc = { version = "0.2.*", optional = true }
```

In the case where the two libc versions are not compatible Rust will include them both in the
resulting binary to make it still work and have them use the appropriate one as needed through name
managling.

## Mailing List <a name="mailing-list"/></a>
https://this-week-in-rust.org/

## Generics <a name="generics"/></a>
Functions can take generic type parameters instead of concreate types. 

## Macros <a name="macros"/></a>
`Macros` allow you to invent your own syntax and write code that writes more code. In other words
they are freakin awesome. This is called `metaprogramming`, which allows for syntatic surgar that
make your code shorter and easier to use.

Resources:
* https://medium.com/@phoomparin/a-beginners-guide-to-rust-macros-5c75594498f1
* https://blog.rust-lang.org/2018/12/21/Procedural-Macros-in-Rust-2018.html
* https://doc.rust-lang.org/book/ch19-06-macros.html
* https://doc.rust-lang.org/reference/macros-by-example.html
* https://danielkeep.github.io/tlborm/book/README.html

Macros can use `()`, `{}` or `[]` for calling and defining, it doesn't matter. Example: `vec!()`,
`vec![]` or `vec!{}`.

Called code:
```rust
let v: Vec<u32> = vec![1, 2, 3];
```

Example of `vec!`:
```rust
#[macro_export]
macro_rules! vec {
    ( $( $x:expr ),* ) => {
        {
            let mut temp_vec = Vec::new();
            $(
                temp_vec.push($x);
            )*
            temp_vec
        }
    };
}
```

The `#[macro_export]` annotation indicates that this is a macro and should be available outside this
crate in a similar fashion to the `pub` indicator on functions. `vec` is the name of the macro
without the `!` and the body of the macro is enclosed in a block.

`$x` is the name of the of the variable to use in the code transcription block. The `expr` after the
colon is called the designator and calls out the type to match for. So we're matching for an
expression and capturing it as `$x`.

The macro body is always similar to the structure of a `match` expression with a `matcher` followed
by a `=>` and then the `transcriber` block. The matcher is composed of a `variable name` e.g. `$x`
and a `desitnator` e.g `expr` with some surrounding annotations.  Here we have one arm with the
pattern `( $( $x:expr ),* )` followed by `=>` and the block of code associated with this pattern. If
the pattern matches, the contents of the associated block of code will be emitted exactly as is
similar to templating. Any unmatched patterns will result in an error.

Emitted code via the transcription block:
```rust
let v: Vec<u32> = {
  let mut temp_vec = Vec::new();
  temp_vec.push(1);
  temp_vec.push(2);
  temp_vec.push(3);
  temp_vec
};
```

### Macro TT Repetition <a name="macro-tt-repetition"/></a>
`$($tail::tt)*` is called a tt repetition and losslessly captures anything

## Ownership <a name="ownership"/></a>

https://doc.rust-lang.org/1.8.0/book/ownership.html  
Rust is unique in how it approaches memory clean up. It uses a compile time borrow checker to
enforce ownership via reference counting. The end of scope will automatically clean up anthing no
longer pointed to. 

When a ownership is transferred to another binding or to a function it is said to have been `moved`.

### Copy types <a name="copy-types"/></a>
All primative types implement the `Copy` trait which allows you to create copies of the data when
assignments are made and thus owneship is not moved as before.

### Borrowing <a name="borrowing"/></a>
Borrowing occurs by specifying that a function takes references as its input arguments then passing
in references. The binding is able to use the value then on end of scope the borrow completes. The
type `&T` is known as a reference. References are immutable and can not be changed at all.

Borrow the `Vec<i32>` in both cases with the `reference` prefix `&`
```rust
fn foo(v1: &Vec<i32>, v2: &Vec<i32>) -> i32 {
    // do stuff with v1 and v2

    // return the answer
    42
}

let v1 = vec![1, 2, 3];
let v2 = vec![1, 2, 3];

let answer = foo(&v1, &v2);

// we can use v1 and v2 here!
```

### Mutable <a name="mutable"/></a>
By default Rust variables are immutable, meaning that you can't change the value of the variable
after it is defined unless specifically calling out that it should be allowed.

Fails to compile:
```rust
let i: i32 = 1;
i = 2;
```

Compiles:
```rust
let mut i: i32 = 1;
i = 2;
```

### Mutable Reference <a name="mutable-reference"/></a>
A mutable reference is a borrow of any type `mut T`, allowing mutation of `T` through that
reference. To create a mutable reference you would borrow i.e. `&mut x` where `x` is the original
`mut T` type. A `borrow` is automatically dropped on block scopes which will allow then another
borrow to be made.

Compiles as `ref_i` was `moved` to `another_ref_i`:
```rust
fn main() {
  let mut i:i32 = 1;
  let ref_i = &mut i;
  let another_ref_i = ref_i;
}
```

### Field-level Mutability <a name="field-level-mutability"/></a>
You cannot have a struct with some fields mutable and others not. The mutability of a struct is in
its bindings.

### Interior vs Exterior Mutability <a name="interior-vs-exterior-mutability"/></a>


### Lifetimes <a name="lifetimes"/></a>
Lifetime of `'static` is a special lifetime. It signals that something has the lifetime of the
entire program.

## Templating <a name="templating"/></a>
* ***tera***
* ***mustache***
* ***liquid***
* ***handlebars***
* ***horrorshow***
* ***maud***
* ***askama***
* ***stpl***
* ***ructe***
* ***typed-html***


## Parsers <a name="parsers"/></a>
Functional programming using a technique known as ***parser combinators***. `nom` is the most widely
used Rust implementation which is what we'll use in this section.

Referenes:
* [Parser combinators](https://bodil.lol/parser-combinators/)
* [Nom parser combinator](https://blog.logrocket.com/parsing-in-rust-with-nom/)
* [Nom combinators list](https://github.com/Geal/nom/blob/master/doc/choosing_a_combinator.md)
* [Nom tag parser](https://github.com/benkay86/nom-tutorial)

***Parser combinators*** are higher-order fucntions that can accept serveral parsers as input and
return a new parser as its output. This approach allows you to build parsers for simple tasks, such
as parsgin certain strings or numbers and composing them using combinator functions into a whole
recursive descent parser. 

The benefits of using parser combinators is that they are:
* highly testable
* highly readable
* highly maintainable

### Tag parser <a name="tag-parser"/></a>
Nom tag parsers recognize a listeral string or `tag` of text. The tag parser `tag("hello")` is a
function object that recognizes the text "hello".

Nom parsers typically take an input `&str` and return an `IResult<&str, &str>` with remaining input
being the first return param and the the matched value as the second.


## Web Frameworks <a name="web-frameworks"/></a>
https://github.com/flosse/rust-web-framework-comparison

High level:
* ***Actix***
* ***Gotham***
* ***Rocket*** - simple, safe web applications (Rails of the Rust world).
* ***Tower Web***
* ***Warp***

Lower level:
* ***H2***
* ***Hyper*** - Hyper provides a safe abstraction over HTTP offering both a client and a server.
* ***tiny http***

* ***Iron*** - based on hyper
* ***Nickel*** - based on hyper

## Web Scraping <a name="web-scraping"/></a>
* ***actix-web***
* ***reqwest***
* ***scraper***
* ***select***
* ***jsonrpc***
* ***surf***
* ***ureq***
* ***yukikaze***
* ***isahc***
* ***hyper***

## CSS Selectors <a name="css-selectors"/></a>
Grabbing content by css selectors is one of the easiest ways to select html content. The Chrome
extension [Selector Gadget](http://selectorgadget.com/) makes it easy to navigate to a page and get a
selector for content you can use in your app.

# rustup <a name="rustup"/></a>

## Update Tools <a name="update-tools"/></a>
```bash
$ rustup update
```

## Install Nightly Toolchain <a name="install-nightly-toolchain"/></a>
Installs the nightly toolchain but doesn't activate it
```bash
$ rustup toolchain install nightly
```

To test out the nightly toolchain without fully activating it:
```bash
$ rustup run nightly rustc --version
```

Switch over to nightly:
```bash
$ rustup default nightly
```

Use cargo with nighly as one off:
```bash
$ cargo +nightly expand 
```

# CI/CD <a name="ci-cd"/></a>

## Github Actions <a name="github-actions"/></a>

## Code Coverage Reporting <a name="code-coverage-reporting"/></a>
Oneline code coverage reporting tools

### Codecov <a name="codecov"/></a>
* More popular now than coveralls
* More stable than coveralls
* Better github integration
* Easy to see per commit coverage
* Free for public repositories

### Coveralls <a name="coveralls"/></a>
Codecov doesn't seem to have a simple github action

* Github integration
* Free for public repositories

## Code Coverage Generation <a name="code-coverage-generation"/></a>
A quick overview of some of the code coverages tools available for Rust

### grcov <a name="grcov"/></a>
The newest entry into the Rust scene is Mozilla's `grcov` used to gather coverage for Firefox. 
Seems to have more buzz than tarpaulin but requires Rust nightly to work so no go

Supports:
* coveralls format
* codecov format

### Tarpaulin <a name="tarpaulin"/></a>
`tarpaulin` works well enough on, but only on `x86_64` machines

Supports:
* local runs
* uploads to https://coveralls.io
* uploads to https://codecov.io

#### Install Tarpaulin <a name="install-tarpaulin"/></a>
```bash
$ cargo install cargo-tarpaulin
```

#### Run Tarpaulin from command line <a name="run-tarpaulin-from-command-line"/></a>
```bash
$ cargo taarpaulin -v
```

# Cargo <a name="cargo"/></a>
***Cargo*** is the official Rust dependency manager. Cargo is similar to tools like NPM or Maven, and
has some interesting features that make it a really high quality dependency manager. Cargo is
responsible for downloading Rust libraries, called ***Crates***, that your project depends on, and
orchestrates calling the Rust compiler to get your final result.

References:
* https://doc.rust-lang.org/cargo/index.html
* https://doc.rust-lang.org/1.38.0/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html

Module System:
* ***Workspaces:*** A workspace is a set of packages that share the same `Cargo.lock`
* ***Packages:*** A Cargo feature that lets you build, test, and share crates. Also a synonym for crate
* ***Crates:*** A tree of modules that produces a library or executable
* ***Modules and use:*** Let you control the organization, scope, and privacy of paths
* ***Paths:*** A way of naming an item, such as a struct, function, or module

The `Cargo.toml` file for each package, a.k.a crate, is called its `manifest`, a.k.a `cargo manifest`:
```toml
[package]
name = "hello_world" # the name of the package
version = "0.1.0"    # the current version, obeying semver
authors = ["Alice <a@example.com>", "Bob <b@example.com>"]

[dependencies]
log = "0.4.*"
```

If multiple versions of a crate are used in your application that don't match a version called out in
your dependency file then Cargo simply includes them both and uses `name mangling` to allow them both
to be callable.

## Examples <a name="examples"/></a>s
Examples in Rust are really cool. They provide a way to package up code as binaries that you can run
as tests or debug to drive your main project. They provide examples of how to you use your project.
In `vscode` you can run them directly or in the debugger. With cargo you can run them directly.

**References**:
* [Rust examples](http://xion.io/post/code/rust-examples.html)

### dependencies <a name="dependencies"/></a>s
* `[dev-dependencies]` in Cargo.toml can be used to setup dependencies for `tests`, `examples` and
`benchmarks` that are separate from the main package.

* ***implied dependencies***: the library or binary and all of their dependencies will automatically
be available for examples to leverage with simple `use` statements. Nothing is required by the
example code other than the `use` call outs.

### run and build examples <a name="run-and-build-exmaples"/></a>s
Examples can be run with cargo by name

Run example:
```bash
$ cargo run --examples foobar

# Pass in addtional arguments
$ cargo run --examples foobar -- arg1
```

Build example:
```bash
$ cargo build --examples foobar
```

## Workspace <a name="workspaces"/></a>s
A workspace is used when your existing crate is large enough you want to split it up into multiple
library crates. Workspaces help manage multiple related library crates that are developed in tandem.
In this way the library crates will share the same version and other properties.

### Create a new workspace <a name="create-a-new-workspace"/></a>
The goal here is to encapsulate all my re-usable Rust code into a single workspace that I can then
version together.

References:
* https://github.com/BurntSushi/ripgrep/blob/master/Cargo.toml
* https://doc.rust-lang.org/stable/cargo/reference/manifest.html#the-workspace-section

Example project layout:
```
rs:
- arc:
  - tar
  - zip
- buf:
  - runes
- enc:
  - bin
  - json
  - unit
  - yaml
- parse:
  - shlex
- sys:
  - os
  - fileinfo
  - path
  - user
```

1. Create a new directory:
   ```bash
   $ cd ~/Projects
   $ cargo new rs --lib
   $ cd rs
   ```
2. Add crate to the workspace:
   ```bash
   $ cargo new laconic --lib 
   ```
3. Add the `workspace` section to the `Cargo.toml` file:
   ```toml
   # Packages to include in the workspace
   [workspace]
   members = [
     "laconic",
   ]
   ```

## Packages <a name="packages"/></a>
Packages are a cargo feature that lets you build, test and share crates as related groups. It is
composed of onr or more crates that provide a set of functionality. A package contains a `Cargo.toml`
file that describes how to build those crates. Packages can only contain at most one library crate.
It may contain one or more binary crates. It is really meant to be a set of related binaries.

## Clippy <a name="clippy"/></a>
Clippy runs some linting against your project to detect code smells

```bash
$ cargo clippy
```

## Crates <a name="crates"/></a>
Crates are a tree of modules that produces an executable i.e. binary or a library. The `crate root` is
a source file that the Rust compiler starts from and makes up the root module of your crate.

## Modules <a name="modules"/></a>
Modules let you control the organization, scope and privacy of paths.

## Expand Macros <a name="expand-macros"/></a>
The `expand` subcommand requires the nightly compiler though but will automatically find and use it
if its installed but not activated.

```bash
# Install the `cargo-expand` subcommand.
$ cargo install cargo-expand

# Expand ll macros
$ cargo expand

# Expand specific module
$ cd ~/Projects/fungus

# `macros` here is actually referring to `fungus::macros` or `src/macros.rs`.
$ cargo expand macros

# Include test expansion
$ cargo expand macros --tests --lib
```

## Static Binary <a name="static-binary"/></a>
To build a 64-bit statically linked binary for Linux, you need to cross compile for hte
`x86_64-unknown-linux-musl` target. To cross compile you'll need standard crates i.e. libstd cross
compiled to that target, which can be installed with `rustup`.

Resources:
* Ripgrep[](https://github.com/BurntSushi/ripgrep/tree/31adff6f3c4bfefc9e77df40871f2989443e6827#installation)
* [Travis template](https://github.com/japaric/trust)
* [Rust Packaging](https://rust-cli.github.io/book/tutorial/packaging.html)
* [Rust Docs](https://doc.rust-lang.org/edition-guide/rust-2018/platform-and-target-support/musl-support-for-fully-static-binaries.html)
* [Travis Example](https://github.com/rustwasm/wasm-pack/blob/51e6351c28fbd40745719e6d4a7bf26dadd30c85/.travis.yml#L74-L91)

```bash
# Install the musl target
$ rustup target add x86_64-unknown-linux-musl

# Install arch linux musl compiler
$ sudo pacman -S musl

# Use the musl target with cargo => target/x86_64-unknown-linux-musl/release/<app>
$ cargo build --target x86_64-unknown-linux-musl
```

## Tests <a name="tests"/></a>

### Unit Tests <a name="unit-tests"/></a>
Unit tests are pretty simple just follow the following guide lines.

Pro Tips:
* Include the unit tests in the same file as the source
* Keep unit tests specific to the source in the same file
* Nest unit tests in their own `tests` module being `#[cfg(test)]` only included for test

### Documentation Tests <a name="documentation-tests"/></a>
Documentation tests are extremely slow. It has the same problem as integration tests. Each one is
built as a separate binary and linked.

### Integration Tests <a name="integration-tests"/></a>
Integration tests are more complicated to get right as there are performance compilation issues to
worry about. First of all integration tests are stored in the top level `tests` folder and deal with
the entire project from the outside to gets your project as a whole i.e. black box while unit tests
are white box.

#### Build time overhead
Cargo will build each file in the `tests` directory as a separate binary and link them to the target
library. This repeated building and linking can add significant compilation time.

#### Single integration test binary
To make Cargo create a single binary containing all tests do the following steps. Note that since
this turns all files in `tests/` into modules in a single integration crate you can reference the
code call out in your entry point with `crate::` references. Freaking cool.

1. Manually call out your integration test entry point. `tests.rs` can be named anything, but this
   notation tells Cargo to treat the path containing this file as an entire crate.
   ```toml
   # Required to turn off autotests so that your single integration test binary works this doesn't
   # affect unit tests or doc tests which will still be auto discovered and run with `cargo test`
   [package]
   autotests = false

   # Make integration tests a single binary
   [[test]]
   name = "integration"
   path = "tests/tests.rs"
   ```

2. In your `tests.rs` integration test entry point call out all the modules in your integration
   tests:
   ```rust
   mod common;
   mod sso_user;
   mod user;
   ```

3. Use code in one module from others as long as they are in the `tests.rs`:
   ```rust
   # From user.rs you could use common code from common.rs with
   use crate::common::*;
   ```

# Crates.io <a name="crates-io"/></a>
Note before you publish ensure you are ready as published crates are there forever with no way to
delete them.

1. Login to `github.com`
2. Browse to [Crates.io](https://crates.io)
3. Click `Log in with GitHub`
4. Open the `Account Settings` page
5. Enter an email address and verify it

## Download crate <a name="download-crate"/></a>
Using the crate.io REST API we can download a crate by name and version. Since crates are simply
source tarballs its simply a matter of a quick extract and we can look at the source for code that
was once published maybe inadvertently as crates.io never deletes anything.

Punch the following into a browser substituting the `<crate-name>` and `<crate-version>` below:
```
https://crates.io/api/v1/crates/<crate-name>/<crate-version>/download

# Example
https://crates.io/api/v1/crates/match-downcast/0.1.2/download
```

# Cross Platform <a name="cross-platform"/></a>
At Visly they wrote an article explaining why they chose ***Rust*** as their Cross-Platform language of
choice over ***C, C++, Go, Kotlin or JavaScript***. Rust has fantastic support for cross compilation
and doesn't include the monsterous VMs that Go and other languages require.

Refernces:
* https://medium.com/visly/cross-platform-rust-406fddd0185b

***C/C++*** are lack modern constructs and idioms making them slow and tedious to develop in.
JavaScript, Go and Kotlin require large runtimes which don't make them ideal for libraries that are
supposed to be embedded everywhere. This really only leaves Rust.

# Language Interop <a name="language-interop"/></a>
Since Rust is still relativily new and has a smaller community sometimes its helpful to borrow code
from another ecosystem. Rust makes working with c type libs a breeze.

## Go Interop <a name="go-interop"/></a>
Compile your Go code as a C Shared library https://github.com/vladimirvivien/go-cshared-examples then
simply call it from Rust.
