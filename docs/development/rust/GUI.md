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
  * [Dioxus CLI config](#dioxus-cli-config)
* [Tailwind CSS](#tailwind-css)
  * [Tailwind Overview](#tailwind-overview)
    * [Tailwind Reset](#tailwind-reset)
* [BULMA CSS](#bulma-css)
* [DaisyUI](#daisyui)

# Overview

## Requirements
* Low power consumption
* Media processing capabiliies
* As much pure Rust as possible
* Cross-platform support including Android, Linux and WASM

## General UI Design

**References**
* [UI Glossary](https://www.uxdesigninstitute.com/blog/ui-glossary/)
* [React Icons for lookup](https://react-icons.github.io/react-icons/search?q=arrow)

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
* [Awesome Dioxus](https://github.com/DioxusLabs/awesome-dioxus)
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
* [Hangman online](https://github.com/lennartkloock/hangman-online)
* [Dioxus use future with fermi](https://github.com/DioxusLabs/dioxus/pull/161/files)
* [Dioxus manual future restart](https://github.com/DioxusLabs/dioxus/issues/149)
* [ER Mule Copier](https://github.com/pubnoconst/er_mule_copier)
* [CSS Primer impl](https://github.com/purton-tech/cloak/tree/main/crates/primer-rsx)
* [TwitVault](https://github.com/terhechte/twitvault)
* [Pomodoro timer](https://github.com/kualta/pomo)
* [Emoji Browser from Dioxus Class](https://github.com/edger-dev/dioxus-class)
* [Dioxus hooks helpers](https://github.com/oovm/dioxus-hooks)
* [React hook recipes](https://usehooks.com/)
* [Dioxus starter](https://github.com/mrxiaozhuox/dioxus-starter)
* [Real World example](https://github.com/dxps/fullstack-rust-axum-dioxus-rwa)
* [Material Icons browser](https://mui.com/material-ui/material-icons/)

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

## Dioxus global state - fermi

### State rendering events
The `fermi` project provide a convenient way to access global state by object type. However in order 
to be efficient you need to be careful in how you construct and use this global state as Dioxus will 
be triggering the re-render of components based on their use of state that has also changed. This 
means that it is problematic to use a centralized state object for all state as any part of the 
system that uses the same state object will automatically trigger component updates even when they 
shouldn't be triggered. As a result the best practice for this is to use granular objects for state. 
Potentially a state object per type use-case. In this way we can avoid un-related component 
re-renders.

## Dioxus CLI config
The `dioxus` cli binary we installed earlier in the process provides the ability to build our project 
and stage it to be served by a production server like `axum` to do this though we need to create the 
`Dioxus.toml` configuration file and specify where the static assets should end up. By default this 
is the `dist` directory inside your frontend project.

# Tailwind CSS
A utility-first CSS framework packed with utility type classes that can be composed to build any 
design with infinite flexibility. Nothing is pre-styled; not even headings or links. You have to 
create everything from scratch, giving you the opportunity to create something unique. Typically a 
designer will create sets of semantic classes that group the appropriate utiltiy classes for 
component types e.g. `btn`, `btn-primary` etc... and use those everywhere and don't use the utility 
classes directly. `Tailwind UI` though is a higher level set of pre-styled components such as `hero`, 
`sections`, `CTA` etc... more like Bulma or Bootstrap but are based on the utility classes of 
Tailwind CSS. Notably though Tailwind UI is not free. However there are a host of others like 
`daisyUI` or `Flowbite` that are built on top of Tailwind CSS providing pre-styled components similar 
to Tailwind UI for free.

**References**
* [Tailwind docs](https://tailwindcss.com/docs/installation)
* [Tailwind showcase](https://tailwindcss.com/showcase)
* [Tailwind CSS Un-reset](https://dev.to/swyx/how-and-why-to-un-reset-tailwind-s-css-reset-46c5)
* [daislyUI](https://daisyui.com/components/alert/)
* [Flowbite components](https://flowbite.com/docs/components/alerts/)
* [Versoly UI](https://versoly.com/versoly-ui/components/alert)
* [Tailwind Stamps](https://tailwindcss.5balloons.info/components/alerts/)
* [Tailwind Elements](https://tailwind-elements.com/docs/standard/components/alerts/)
* [Tailblocks](https://tailblocks.cc/)
* [Tailwind templates](https://tailwindtemplates.co/)
* [Hyper UI](https://www.hyperui.dev/components/application-ui/alerts)
* [Tailwind Components](https://tailwindcomponents.com/)
* [Meraki UI](https://merakiui.com/components)
* [Tailwind Toolbox](https://www.tailwindtoolbox.com/)

## Tailwind Overview
Latest version 3.3.2

* [Tailwind CSS releases](https://github.com/tailwindlabs/tailwindcss/releases)

### Tailwind Reset
Tailwind CSS comes with a great CSS Reset, called Preflight. It starts with the awesome Normalize.css 
project then nukes all default margins, styling, and borders for ever HTML element. This is so that 
you have a consistent, predictable starting point with which to apply your visual utility classes 
separate from the semantic element names. Preflight is included as part of the `base` tailwind 
module.

## Tailwind in Dioxus

### Include Tailwind
Tailwind provides the ability to only include what you use. However to do this you'll need to have a 
tailwind minify operation run during build time to scan your codebase to determine what is being used 
to generate the final `tailwind.min.css`.

**tailwindcss as alternate to npx**
You can install `tailwindcss` and use it instead of executing `npx` commands but it gives you 
the exact same options and is of no benefit.

* [Setup tailwind for yew](https://dev.to/arctic_hen7/how-to-set-up-tailwind-css-with-yew-and-trunk-il9)
* [Optimizing for Production](https://tailwindcss.com/docs/optimizing-for-production)
* [Tailwindcss docs - Installation](https://tailwindcss.com/docs/installation)

1. Initialize TailwindCSS to create `tailwind.config.js`
   ```shell
   $ cd ~/Projects/<project>
   $ npx tailwindcss init
   ```
2. Update `tailwind.config.js`. Any missing sections will fall back to the default configuration
   * [Default Tailwind Config](https://github.com/tailwindlabs/tailwindcss/blob/master/stubs/config.full.js)
   * Use `npx tailwindcss init --full` to get a full default config
   ```javascript
   module.exports = {
     content: ["./src/**/*.{html,rs}"],
     theme: {
       extend: {},
     },
     plugins: [],
   } 
   ```
3. Create module call out `tailwind.input.css`
   ```css
   @tailwind base;
   @tailwind components;
   @tailwind utilities;
   ```
4. Run the minify operation manually to generate `tailwind.min.css` for your project to start from
  ```shell
  $ npx tailwindcss -c tailwind.config.js -i tailwind.input.css -o tailwind.min.css --minify
  ```
5. Automate the building of it in your project, create `build.rs`
   ```rust
   use std::process::Command;
   
   fn main() {
       Command::new("npx")
           .arg("tailwindcss")
           .arg("-c")
           .arg("./tailwind.config.js")
           .arg("-i")
           .arg("./tailwind.input.css")
           .arg("-o")
           .arg("./tailwind.min.css")
           .arg("--minify")
           .output()
           .expect("Error running tailwindcss");
   }
   ```
6. Include in your project
   ```rust
   pub fn get_tailwind_css() -> &'static str {
       include_str!("../tailwind.min.css")
   }

   fn App(cx: Scope) -> Element {
       cx.render(rsx! {
           style: { "{get_tailwind_css()}" },
           div {
               class: "w-full h-screen bg-gray-300 flex items-center justify-center",
               "Hello, world!"
           }
       })
   }
   ```

## Daisy UI
Tailwind.css provides the tools to build beautiful UIs with infinite customization. DaisyUI is a 
Tailwind plugin that provides a number of pre-created components along the lines of Bulma CSS that 
use Tailwind to allow you to get up and running faster and use fewer class names.

* lkj

**References**
* [DaisyUI Components](https://daisyui.com/components/)



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
