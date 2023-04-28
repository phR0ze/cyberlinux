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
  * [General UI Design](#general-ui-design)
* [Install prerequisites](#install-prerequisites)
  * [Install Rust](#install-rust)
  * [Install Rust Android targets](#install-rust-android-targets)
* [Tauri](#tauri)
  * [Install Tauri Dependencies](#install-tauri-dependencies)
* [Dioxus](#dioxus)
  * [Setup Dioxus](#setup-dioxus)
  * [Create a new Dioxus WASM project](#create-a-new-dioxus-wasm-project)
  * [Make a Dioxus WASM and Desktop project](#make-a-dioxus-wasm-and-desktop-project)
  * [Build and run a Dioxus WASM app](#build-and-run-a-dioxus-wasm-app)
* [Tailwind CSS](#tailwind-css)
  * [Tailwind Overview](#tailwind-overview)
    * [Tailwind Reset](#tailwind-reset)
* [BULMA CSS](#bulma-css)

# Overview

## Requirements
* Low power consumption
* Media processing capabiliies
* As much pure Rust as possible
* Cross-platform support including Android, Linux and WASM

## General UI Design

**References**
* [UI Glossary](https://www.uxdesigninstitute.com/blog/ui-glossary/)

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
user interfaces in Rust. It is built on top of Tauri which provides the cross-platform aspects. Tauri 
could be used directly but then you loose Dioxus's convenient works out of the box paradigm. Dioxus 
layers on top making it just work and adding the React capablities.

**Dioxus references**
* [Dioxus Bulma](https://github.com/mrxiaozhuox/dioxus-bulma)
* [Fetch images example](https://github.com/DioxusLabs/dioxus/blob/master/examples/suspense.rs)
* [Desktop Window Builder](https://docs.rs/dioxus-desktop/latest/dioxus_desktop/struct.WindowBuilder.html#method.with_menu)
* [Example of WASM and Desktop](https://github.com/LyonSyonII/dioxus-tailwindcss)
* [Window Decorations](https://github.com/DioxusLabs/dioxus/blob/master/examples/overlay.rs)
* [Full featured mail client](https://github.com/jkelleyrtp/blazemail)
* [Uplink - P2P chat](https://github.com/Satellite-im/Uplink)
* [Blazemail](https://github.com/jkelleyrtp/blazemail)
* [Rummy Nights](https://github.com/arqalite/rummy-nights)
* [SpideyClick](http://demo.spideyclick.net/)
* [Karaty](https://github.com/mrxiaozhuox/karaty)

**Dioxus questions**
* dioxus-web vs dioxus-html
* global state management - Fermi

## Setup Dioxus

### Install Arch system libs
```
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

### Conditional platform crate imports
By using conditional crate imports we can include specific code per platform while keeping the UI and 
core code shared. The `dioxus-<platform>` crates are key to making this happen.

```toml
[target.'cfg(any(unix, windows))'.dependencies]
dioxus-desktop = { version = "0.3.0" }

[target.'cfg(target_family = "wasm")'.dependencies]
dioxus-web = { version = "0.3.1" }
```

### Conditional platform code
Conditional platform code is used for CSS imports. WASM will pick up the CSS from the index.html 
configuration and local files while the desktop version will need to import it via the `launch_cfg` 
configuration.

```rust
#![allow(non_snake_case)]

use dioxus::prelude::*;

fn main() {
   #[cfg(target_family = "wasm")]
   dioxus_web::launch(App);

   #[cfg(any(windows, unix))]
   dioxus_desktop::launch_cfg(Root, dioxus_desktop::Config::new());
}

fn App(cx: Scope) -> Element {
   cx.render(rsx! {
       div {
           "Hello, world!"
       }
   })
}
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

## Build and run a Dioxus WASM app
1. Build and run
   ```
   dioxus serve --hot-reload
   ```
2. Browse to `http://localhost:8080/`

# Tailwind CSS
A utility-first CSS framework packed with classes like `flex`, `pt-4`, `text-center` and `rotate-90` 
that can be composed to build any design, directly in your markup.

**References**
* [Tailwind docs](https://tailwindcss.com/docs/installation)
* [Tailwind showcase](https://tailwindcss.com/showcase)

## Tailwind Overview

### Tailwind Reset
Tailwind CSS comes with a great CSS Reset, called Preflight. It starts with the awesome Normalize.css 
project then nukes all default margins, styling, and borders for ever HTML element. This is so that 
you have a consistent, predictable starting point with which to apply your visual utility classes 
separate from the semantic element names.

```css
@tailwind base; /* Preflight will be injected here */
@tailwind components;
@tailwind utilities;
```

**References**
* [Tailwind CSS Un-reset](https://dev.to/swyx/how-and-why-to-un-reset-tailwind-s-css-reset-46c5)

## Tailwind in Dioxus
```html
<!-- style stuff -->
<!-- <script src="https://cdn.tailwindcss.com"></script> -->
<link data-trunk rel="css" href="tailwind.css" />
```

# BULMA CSS
Bulma is a free, open source framework that provides ready-to-use frontend components that you can 
easily combine to build responsive web interfaces.

* 100% responsive mobile first
* Just import what you need
* Modern, build with Flexbox

**References**
* [Bulma github](https://github.com/jgthms/bulma)
* [Bulma docs](https://bulma.io/documentation/)
* [Dioxus Bulma github](https://github.com/mrxiaozhuox/dioxus-bulma)

<!-- 
vim: ts=2:sw=2:sts=2
-->
