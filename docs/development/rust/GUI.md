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

## Create a new Dioxus project
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

## Build and run
1. Build and run
   ```
   dioxus serve --hot-reload
   ```
2. Browse to `http://localhost:8080/`

<!-- 
vim: ts=2:sw=2:sts=2
-->
