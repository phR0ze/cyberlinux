Rust GUI
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting my learning experience with Rust GUIs. Specifically I'm looking for cross-platform i.e. 
Android, WASM and Linux support using Arch Linux as my devlopment environment.
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
  * [Requirements](#requirements)
* [Install prerequisites](#install-prerequisites)
  * [Install Rust](#install-rust)
  * [Install Rust Android targets](#install-rust-android-targets)
* [Tauri](#tauri)
  * [Install Tauri Dependencies](#install-tauri-dependencies)
* [Dioxus](#dioxus)

# Overview

## Requirements
* Low power consumption
* Media processing capabiliies
* As much pure Rust as possible
* Cross-platform support including Android, Linux and WASM

# Install pre-requisites

## Install Rust
see [README.md/#install-rust](README.md/#install-rust)

## Install Rust Android targets
```bash
$ rustup target add aarch64-linux-android
$ rustup target add armv7-linux-androideabi
$ rustup target add i686-linux-android
$ rustup target add x86_64-linux-android
```

# Tauri
Tauri is a lot like Electron only faster and smaller. While Electron uses the Chromium engine with 
Node.js bundled together producing fat 150MB+ binaries, Tauri is a Rust engine that uses the 
operating system's WebView libraries, making it faster and smaller as its uding dynamic libraries 
rather than baked in ones. 

## Install Tauri Dependencies
* [Tauri docs](https://next--tauri.netlify.app/next/guides/getting-started/prerequisites/linux)

1. Install Arch system libs
   ```
   sudo pacman -Syu
   sudo pacman -S --needed \
       webkit2gtk-4.1 \
       base-devel \
       curl \
       wget \
       openssl \
       appmenu-gtk-module \
       gtk3 \
       libappindicator-gtk3 \
       librsvg \
       libvips
   ```
2. Install Android rust targets
   ```bash
   $ rustup target add aarch64-linux-android
   $ rustup target add armv7-linux-androideabi
   $ rustup target add i686-linux-android
   $ rustup target add x86_64-linux-android
   ```
3. Install Android Studio from the [official website](https://developer.android.com/studio)
   1. Install deps: `libpulse, nss, libxcomposite, libxcursor`
   2. Build package: `yay -Ga android-studio; cd android-studio; makepkg -s`
   3. Install package: `sudo pacman -U sudo pacman -U android-studio-2022.1.1.21-1-x86_64.pkg.tar.zst`
   4. Set JDK path: `export JAVA_HOME=/opt/android-studio/jbr`
4. Install Android SDK
   1. Launch IDE: `android-studio`
   2. Follow prompts to install Android SDK to `$HOME/Android/Sdk"`
   3. Load and project and then navigate to `Tools >SDK Manager`
   4. Select the `SDK Tools` tab then `NDK (Side by side)` and `Android SDK Command-line Tools`
   5. Figure out your correct NDK path with `ll $HOME/Android/Sdk/ndk`
   6. Set the Android SDK path: `export ANDROID_HOME="$HOME/Android/Sdk"`
   7. Set the Android NDK path: `export NDK_HOME="$ANDROID_HOME/ndk/25.2.9519653"`
   
5. Install Android NDK

# Dioxus
Dioxus is a React inspired portable, performant and ergonomic framework for building cross-platform 
user interfaces in Rust. It is built on top of Tauri. Tauri provides the underlying infrstructure and 
allows for a lot more choice but requires more effort to get started. Dioxus layers on top providing 
a simplified one-size fits all approach that will be easier to get started with.

**Dioxus references**
* [Bulma with Dioxus](https://github.com/mrxiaozhuox/dioxus-bulma/blob/main/examples/full.rs)
* [Fetch images example](https://github.com/DioxusLabs/dioxus/blob/master/examples/suspense.rs)
* [Desktop Window Builder](https://docs.rs/dioxus-desktop/latest/dioxus_desktop/struct.WindowBuilder.html#method.with_menu)
* [Example of WASM and Desktop](https://github.com/LyonSyonII/dioxus-tailwindcss)
* [Window Decorations](https://github.com/DioxusLabs/dioxus/blob/master/examples/overlay.rs)
* [Full featured mail client](https://github.com/jkelleyrtp/blazemail)
* [Uplink - P2P chat](https://github.com/Satellite-im/Uplink)
  * Run with: `cargo run`

**Dioxus questions**
* dioxus-web vs dioxus-html
* global state management - Fermi

## Setup Dioxus

### Install Dioxus CLI
```
$ cargo install dioxus-cli
```

### Install Cargo Add
```
$ cargo install cargo-add
```

### Install Dioxus VSCode Extension
Install the `dioxus` extension

## Create a new Dioxus WASM project
1. Create the project
   ```
   $ cargo new --bin wasm
   $ cd wasm
   ```
2. Add dependencies to project
   ```
   cargo add dioxus
   cargo add dioxus-web
   ```
3. Add the base main.rs content
   ```rust
   #![allow(non_snake_case)]
   // import the prelude to get access to the `rsx!` macro and the `Scope` and `Element` types
   use dioxus::prelude::*;
   
   fn main() {
       // launch the web app
       dioxus_web::launch(App);
   }
   
   // create a component that renders a div with the text "Hello, world!"
   fn App(cx: Scope) -> Element {
       cx.render(rsx! {
           div {
               "Hello, world!"
           }
       })
   }
   ```

## Make a Dioxus WASM and Desktop project
My original intent with learning Dioxus was to write an app that can span the Web, Desktop and 
Mobile. The core code can stay the same hopefully but some conditional crates and logic will need to 
be included per platform.

### Conditional platform code
Conditional platform code is used for CSS imports. WASM will pick up the CSS from the index.html 
configuration and local files while the desktop version will need to import it via the `launch_cfg` 
configuration.

```rust
#[cfg(target_family = "wasm")]
dioxus_web::launch(Root);

#[cfg(any(windows, unix))]
dioxus_desktop::launch_cfg(Root, dioxus_desktop::Config::new().with_custom_head(r#"<link rel="stylesheet" href="public/tailwind.css">"#.to_string()));
```

### Conditional platform crate imports
By using conditional crate imports we can include specific code per platform while keeping the UI and 
core code shared. The `dioxus-<platform>` crates are key to making this happen.

```toml
[target.'cfg(any(unix, windows))'.dependencies]
dioxus-desktop = { version = "0.3.0" }

[target.'cfg(target_family = "wasm")'.dependencies]
dioxus-web = { version = "0.3.1" }
```

### Set the window properties
You can set the window's name, size and other window properties using the 
`dioxus_desktop::WindowBuilder` builder object.

```rust
dioxus_desktop::launch_cfg(
  App,
  dioxus_desktop::Config::new()
    .with_window(
        dioxus_desktop::WindowBuilder::new()
          .with_title("diper")
          .with_decorations(false)
          .with_inner_size(dioxus_desktop::LogicalSize::new(300.0, 300.0)),
    )
);
```

## Build and run
1. Build and run
   ```
   dioxus serve --hot-reload
   ```
2. Browse to `http://localhost:8080/`

<!-- 
vim: ts=2:sw=2:sts=2
-->
