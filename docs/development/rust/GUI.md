Rust GUI
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting my learning experience with Rust GUIs. Specifically I'm looking for cross-platform i.e. 
Android, WASM and Linux support using Arch Linux as my devlopment environment. As I delved further 
into this space I've realized that the kind of custom graphics manipulation that I'm interested is 
more readily available in the Gaming community. However immediate mode UI frameworks more prevalent
in gaming are not as battery conscious.
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
  * [References](#references)
    * [Example information](#example-information)
    * [Tutorials and learning](#tutorials-and-learning)
* [Rust prerequisites](#rust-prerequisites)
  * [Install Rust](#install-rust)
  * [Install Rust Android targets](#install-rust-android-targets)
* [Macroquad](#macroquad)
  * [Install OpenJDK](#install-openjdk)
  * [Install Android SDK](#install-android-sdk)
  * [Install Android NDK](#install-android-ndk)
  * [Adding Macroquad to your project](#adding-macroquad-to-your-project)
  * [Install Cargo plugin for building apks](#install-cargo-plugin-for-building-apks)
  * [Macroquad UI](#macroquad-ui)
    * [Margins](#margins)
  * [Debugging in Macroquad](#debugging-in-macroquad)
* [EGUI](#egui)
  * [EGUI app](#egui-app)
* [Gaming Ecosystem](#gaming-ecosystem)
  * [Deprecated or not maintained](#deprecated-or-not-maintained)
    * [Ame](#deprecated-or-not-maintained)
* [Gaming Concepts](#gaming-concepts)
  * [Entity Component Systems (ECS)](#entity-component-systems-ecs)

# Overview
Originally I'd gone down the path of writing a Kotlin Android app with Android Studio. However I 
quickly realized that the complexity involved in cross platform support would be a nightmare. 
Additionally I found that I disklike the Kotlin/Java ecosystem intensly. Switching gears I determined 
that I could write my application in Rust and have it cross platform while using a language I enjoy. 
To this end I'm documenting my journey through this process.

**Guiding requirements**
* Media processing: images
* As much pure Rust as possible
* Cross-platform support including Android, Linux and WASM

## References

### Example information
* Rust GUIs
  * [Are we gui yet](https://www.areweguiyet.com/)
  * [Good Web Game](https://github.com/ggez/good-web-game)
  * [Github glutin](https://github.com/rust-windowing/glutin)
* Rust Gaming
  * [Android gamedev - Reddit](https://www.reddit.com/r/rust_gamedev/comments/wbg7xg/framework_or_libraries_for_developing_androidios/)
  * [GameDevRS](https://gamedev.rs/news)
  * [Portal](https://github.com/optozorax/portal)
    * Uses both MacroQuad and EGUI
  * FDG Force directed graph (Macroquad based)
    * [Github](https://github.com/grantshandy/fdg)
    * [Demo](https://grantshandy.github.io/fdg)
  * Hydrofoil - 3D super high quality Steam game
    * [Hydrofoil Generation](https://store.steampowered.com/app/1448820/Hydrofoil_Generation/)
* Rusty Slider
  * [Github](https://github.com/ollej/rusty-slider)
  * [Demo](https://ollej.github.io/rusty-slider/demo/example-slideshows.html)
* Sugar Cubes
  * [Demo](https://henryksloan.github.io/sugarcubes/)
  * [Github](https://github.com/henryksloan/sugarcubes)
  * MacroQuad and EGUI
  * Buildable and runnable
* Images processing
  * [Image RS Blog](https://blog.image-rs.org/)
  * [Emulsion](https://github.com/ArturKovacs/emulsion)
  * [Github image](https://github.com/image-rs/image)
  * [Github imageproc](https://github.com/image-rs/imageproc)
  * [Simple Android Gallery app](https://github.com/SimpleMobileTools/Simple-Gallery)
* Rusty Aquarium
  * [Github](https://github.com/ollej/rusty-aquarium)
  * [Demo](https://ollej.github.io/rusty-aquarium/demo/)
* Rust on Android
  * [Github android-ndk-rs](https://github.com/rust-windowing/android-ndk-rs)
  * [Integrating Rust modules in Android](https://blog.logrocket.com/integrating-rust-module-android-app/)

### Tutorials and learning
* [Boy Maas - youtube](https://www.youtube.com/channel/UC_GA3MH6UmklIgQX3_fCpLQ)
* [Bevvy Basics](https://www.youtube.com/c/PhaestusFox)
  * [Episode 1](https://youtu.be/pB3ERI5JtrA)
  * [Episode 2](https://youtu.be/G37yUGL3e1U)
  * [Episode 3](https://youtu.be/1q5iQsLVGJA)
  * [Episode 4](https://youtu.be/PjLozjlOgJ4)
* [Integrating Rust modules in Android](https://blog.logrocket.com/integrating-rust-module-android-app/)

# Rust pre-requisites

## Instal Rust
see [README.md/#install-rust](README.md/#install-rust)

## Install Rust Android targets
```bash
$ rustup target add aarch64-linux-android
$ rustup target add armv7-linux-androideabi
$ rustup target add i686-linux-android
$ rustup target add x86_64-linux-android
```

# Macroquad
GGEZ reuses the existing rust gamedev ecosystem i.e. winit, wgpu, rodio while Macroquad has 
re-written most of this in miniquad and doesn't use the standard components.

* Pros:
  * Cross-platform including Android, Linux and WASM
  * Fully skinnable intermediate UI
  * Simpler to use than GGEZ which is its top competitor
  * Context is stored in a static variable rather than being passed around
  * Contains its own [fully skinnable and configurable UI](https://docs.rs/macroquad/latest/macroquad/ui/index.html#)
  * Arch Linux specific instructions
    * `pacman -S pkg-config libx11 libxi mesa-libgl alsa-lib`
  * Efficient 2D rendering with automatic geometry batching
  * Supported by [Embark Studios](https://www.embark-studios.com) who are building their own game 
engine from the ground up in Rust
  * Was able to contribute changes to get support for the latest [NDK r25](https://github.com/not-fl3/cargo-quad-apk/commit/ccab7748e9536cab7ba66718ca6958a1550cdfc2)
* Cons:
  * Depends on `OpenJDK8` and `Android SDK 29` and will take some work to get to modern dependencies

**References**
* [Java interop with Miniquad](https://macroquad.rs/articles/java/)
* [Publishing a Rust game on Android](https://macroquad.rs/tutorials/android/)
* [Github Zemeroth](https://github.com/ozkriff/zemeroth)
* [Awesome quads](https://github.com/ozkriff/awesome-quads)
* [Fish Flocking Simulation](https://github.com/eckyputrady/fish-flocking-simulation)
  * `cargo run`
  * Somewhat realistic fish in schools moving around the screen
  * Some logic to have the smaller fish avoid the larger
  * Remenicient of old school screen savers
* [Recwars](https://github.com/martin-t/rec-wars)
  * `cargo run`
  * Take battle game with decent explosions
  * Take driving and collisions
  * High scores and games stats painted on sreen
* [Breakout tutorial](https://github.com/TanTanDev/breakout_tutorial)
  * `cargo run`
  * Text overlay on paused game for startup
  * Score and lives text
  * Collission detection and ball bounce physics
* [Minesweeper](https://github.com/eboatwright/minesweeper)
  * `cargo run`
  * Moving text start menu
  * Multi-dimension graphics and explosion effects 
  * Action sound effects
  * Nicer custom font for menu and Game Over
* [Tetris](https://github.com/eboatwright/rs-tris)
  * Needed some resource path change to get to run `cargo run`
  * Splash screen with key press to start
  * Moving background during game
  * Game score panel
  * Multiple key controls
  * Music and affects sounds
* [Moving 3D space](https://github.com/DomtronVox/Nova-Stella)
  * `cargo run`
  * Primitive start menu with highlightable buttons
  * 3D grid with orbiting colored balls around center ball
* [Rust platformer](https://github.com/tofraley/rust-platformer)
  * `cargo run`
  * Simple single level
  * Simple moveable and jumpable blocky character
  * Moving platform
* [Pakemon](https://github.com/notnullgames/pakemon-demos)
  * `cd macroquad; cargo run`
  * Parallax example with moving background, middle ground and forground
  * Sprite cat animation
  * Slide into place title splash screen
* [Procedural Spider](https://github.com/darthdeus/procedural-spider)
  * `cargo run`
  * procedurally generated and movable spider
  * realistic looking spider movements
* [Demon attack](https://github.com/TanTanDev/rusty_demon_attack)
  * Sound package is not working with Alsa on linux needed commented out to build `cargo run`
  * Game scales with window changes
  * Score and informational text
  * Lives widgets
  * Movable, shootable ship and enemies
  * Bullet to enemey collision detection
* [Fish fight the prequel](https://github.com/fishfolks/FishFightThePrequel)
  * `cargo run`
  * Custom widgets with tabs and input fields
* [Bumble Bee](https://github.com/alanfalloon/bumble-umble-gee)
  * `cargo run --features=console`
  * Nice zoom in and zoom out game view
  * Bee animation flying is great
  * Make sprite example
  * Background is colored and generated procedurally
* [Car game](https://github.com/GabutHome/car-game)
  * `cargo run`
  * Layout setup like a mobile app
  * Splash scren with custom font and credits
  * Movable car on moving road with oncomming cars and obstacles
  * Game Over splash screen with restart options
* [EGUI Gizmo](https://github.com/urholaukkarinen/egui-gizmo)
  * `cd demo; cargo run`
  * Scales with window size
  * EGUI embedded default looking controls
  * Control graphics overlay
  * 3D multi-dimensional live rotation
  * 3D live transformation and scaling
* [Fish fight jumpy](https://github.com/fishfolks/jumpy)
  * `cargo run`
  * Custom graphics game start menu with hover affect
  * Inter menu navigation with custom styles and rounded borders
    * Local file loading maps with custom hover buttons and widgets
  * Scrolling credits screen
* [Spell](https://github.com/elsid/spell)
  * `cargo run --features=client`
  * HUD
  * Pausable main menu drop down
  * Cursor controled movement
  * Highlighted menu
  * Multiple key bindings
* [Opentd](https://github.com/kraxarn/opentd)
  * Simple menu
  * FPS widget
* [frc auto generator](https://github.com/We-Gold/frc-auto-generator)
  * Draw lines
* [Quad Android Playground](https://github.com/not-fl3/quad-android-playground)
  * Android features for testing
* [HyperMaze](https://github.com/elo-siema/HyperMaze)
  * First person maze 3d walls
* [Arena gungeon](https://github.com/Redfox/arena-gungeon)
  * Simple map movements top down background
* [Rusty Sandbox](https://github.com/JSKitty/rusty-sandbox)
  * Sand simulation
* [Room for growth](https://github.com/volbot/room-for-growth)
  * Some basic ui widgets - text box and button
* [Tamerz Gotcha](https://github.com/1sra3l/tamerzgotcha)
  * Some drag widgets
* [Ray casting sandbox](https://github.com/nathanielfernandes/ray-casting-sandbox)
  * Neat Wolf 3D type playground

## Install OpenJDK - Not compatible yet
Android Studio 4.2 released in 2021 and onwards uses `OpenJDK 11`

1. Install OpenJDK11
   ```bash
   $ sudo pacman -S jdk11-openjdk
   ```
2. Configure `~/.bashrc` for the correct `JAVA_HOME` path
   ```
   $ echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> ~/.bashrc
   $ source ~/.bashrc
   ```

## Install OpenJDK
Macroquad's `cargo-quad-apk` depends on OpenJDK8 for now

1. Install OpenJDK8
   ```bash
   $ sudo pacman -S jdk8-openjdk
   ```
2. Configure `~/.bashrc` for the correct `JAVA_HOME` path
   ```
   $ echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk" >> ~/.bashrc
   $ source ~/.bashrc
   ```

## Install Android SDK
Macroquad requires SDK r29 currently to run

```bash
$ wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
$ unzip -q sdk-tools-linux-4333796.zip
$ rm sdk-tools-linux-4333796.zip
$ yes | ./tools/bin/sdkmanager "platform-tools"
$ yes | ./tools/bin/sdkmanager "platforms;android-29"
$ yes | ./tools/bin/sdkmanager "build-tools;29.0.0"
```

## Install Android NDK
Latest NDK as of writing this is `r25` and is supported by Macroquad tooling
* [Android NDK Download site](https://developer.android.com/ndk/downloads/)

1. Download and build
   ```bash
   $ yay -Ga android-ndk; cd android-ndk
   $ makepkg -s
   ```
2. Install package
   ```bash
   $ sudo pacman -U android-ndk-r25-1-x86_64.pkg.tar.zst
   ```

## Adding Macroquad to your project
Warning: The Cargo plugin `quad-apk` needs to have Macroquad version `0.3.23` or newer to find the 
`src/native/android/mod_inject.rs` file.

1. Add the `macrqud` dependency to your `Cargo.toml`
   ```toml
   [dependencies]
   macroquad = "0.3.23"
   ```
2. Now add the Android target values to your `Cargo.toml`
   ```toml
   [package.metadata.android]
   # Build version which should always be the latest
   android_version = 33
   # Target and minimum API version you want to support
   target_sdk_version = 24
   min_sdk_version = 24
   # x86_64-linux-android is used by the emulator
   build_targets = [ "armv7-linux-androideabi", "aarch64-linux-android", "i686-linux-android", "x86_64-linux-android" ]
   package_name = "rust.mrsa"
   label = "MRSA"
   # Version used to determine whether one version is newer than another
   version_code = 1
   ```

## Install Cargo plugin for building Android apks
* The android build artifacts are located at `target/android-artifacts/debug/bin/<PROJECT>`
* Android Studio's emulator for a `x86_64` linux machine needs the rust target `i686-linux-android`

References:
* [Cargo Quad APK](https://github.com/not-fl3/cargo-quad-apk)

Problems to fix:
* `cargo-quad-apk` expects Android NDK r25, Android SDK 29 and OpenJdk8
* I used the Dockerfile to download and replicate the SDK and NDKs
* I installed `sudo pacman -S jdk8-openjdk` to get the right javac

* Newer versions of Java don't have a `/usr/lib/jvm/java-8-openjdk/jre/lib/rt.jar`
* `lib/rt.jar` vs `jmods/java.base.jmod`
* Newer versions of SDK use d8 rather then dex

1. Clone and build cargo-quad-apk
   ```bash
   $ git clone https://github.com/phR0ze/cargo-quad-apk
   $ cd cargo-quad-apk
   $ cargo build --release
   ```
2. Install cargo-quad-apk
   ```bash
   $ mv target/release/cargo-quad-apk ~/.cargo/bin/
   ```
3. Set the android sdk and ndk variables
   ```bash
   $ export NDK_HOME=/opt/android-ndk
   $ export JAVA_HOME=/opt/android-studio/jre
   $ export ANDROID_HOME=/home/$USER/Android/Sdk
   ```
4. Build project
   ```bash
   $ docker run --rm -v $(pwd):/root/src -w /root/src cargo-quad-apk:latest cargo quad-apk build
   $ docker run --rm -v $(pwd):/root/src -w /root/src cargo-quad-apk:latest cargo quad-apk build --release

   # An apk will be in target/android-artifacts/release/apk
   $ NDK_HOME=/opt/android-ndk JAVA_HOME=/usr/lib/jvm/java-8-openjdk ANDROID_HOME=~/Downloads/temp/sdk-r29 cargo quad-apk build

   # An apk will be in target/android-artifacts/release/apk
   cargo quad-apk build --release
   ```
5. Start `android-studio` and start the emulator
6. Install apk in emulator
   ```bash
   $ adb install target/android-artifacts/debug/apk/mrsa.apk
   ```

## Macroquad UI
Macroquad provides an intermediate UI that is fully skinnable. In order to get access to the ui 
components and setup custom skins you need to:
1. Import `use macroquad::ui::root_ui`
2. Use that function to configure the skin styles
   ```rust
   let label_style = root_ui()
     .style_builder()
     .font(include_bytes!("../examples/ui_assets/HTOWERT.TTF"))
     .unwrap()
     .text_color(Color::from_rgba(180, 180, 120, 255))
     .font_size(30)
     .build();
   ```
3. Integrate your custom style with any defaults that you don't want to change
   ```rust
   let skin = Skin {
     label_style,
     ..root_ui().default_skin()
   };
   ```
4. Finally in the main loop you'd want to activate the custom skin with `push_skin()` then create a 
   window based on it with `window()` and finally `pop_skin()` your custom skin
   ```rust
   root_ui().push_skin(&skin);
   root_ui().window(hash!(), vec2(20., 250.), vec2(300., 300.), |ui| {
      widgets::Button::new("Play")
          .position(vec2(65.0, 15.0))
          .ui(ui);
   });
   ```

### Margins
Macroquad UI has two different optional margin properties settable via the `StyleBuilder`. Access the 
style builder through the `root_ui()` function e.g. `root_ui().style_builder()`

Note: if `size()` is specified than the `*margin` functions won't take affect

* `background_margin` - provides similar margin as `margin` but doesn't distort the background image
* `margin` - provides similar margin as `background_margin` but distorts the backround image

## Debugging in Macroquad
All the `warn!`, `info!` and `debug!` MacroQuad messages will go into the android system messages. 
You can access them with `adb logcat`

Filter by tag
```
adb logcat -v brief SAPP:V "*:S"
```

# EGUI
Highly portable immediate mode GUI library in pure Rust. Their goal is to be a simple way to create a 
GUI or add a GUI to a game with simple custom widgets.
  * Pure Rust, inspired by Dear ImGui
  * Meant to be usable with other projects like Game engines
  * Integrates with Macroquad or MiniQuad
  * Immediate mode not retained mode which means high CPU load but games require this anyway

Ultimately I decided not to use EGUI as Macroquad provides its own skinnable intermediate UI. EGUI's 
widgets are more advanced and plentiful but Macroquad's widgets are sufficient and more importantly, 
for my needs, skinnable.

**References**
* [EGUI HTML5 demo](https://www.egui.rs/#demo)
* [Github egui-macroquad](https://github.com/optozorax/egui-macroquad)
* [Github egui-miniquad](https://github.com/not-fl3/egui-miniquad)
* [Example of game using it](https://twitter.com/PlayTheProcess/status/1417774452012724226)
  * [Reddit discussion](https://www.reddit.com/r/rust_gamedev/comments/mopoxk/showcasing_my_game_the_process_built_with_rust/)
* [Egui Node Graph](https://github.com/setzer22/egui_node_graph)
* [Simple headlines GUI app walkthrough](https://www.youtube.com/watch?v=NtUkr_z7l84)
* [Wireframe design tool not EGUI](https://excalidraw.com/)

## EGUI app
[eframe](https://crates.io/crates/eframe) is EGUI's official framework. It uses `egui_glow` and thus
[glow](https://github.com/grovesNL/glow) by default. To use a different low graphics drawing backend 
you can use `egui-minigquad`, `equi-macroquad`.

```bash
$ cargo run egui_demo_app
```

# Gaming Ecosystem

## Amethyst - archived
Data driven and data oriented game engine

* [Docs](https://amethyst.rs/doc)
* 2D and 3D support
* Massively parallel architecture
* Follows the Entity Comonent System (ECS) paradigm

## Bevy
* No WASM or Android yet :(
* Successor to Amethyst it has a ECS data paradigm
* Hot asset reloading to allow for runtime changes

## Emerald

## Fyrox
* Production ready 2D/3D engine
* Supports Windows, Linux, macOS and Web
* Extensive documentation and resources and a game editor

## GGEZ
**References**
* [Github GGEZ](https://github.com/ggez/ggez)

## Nannou
* Open source game framework
* Aims to use only Rust libraries and `cargo build`
* Full palette of creative tools for graphics, audio, lasers, lighting and more

## Piston
* Modular collection of 2D and 3D image processing, event programming, GUI, sound and animation libraries
* Uses a dynamic scripting language called Dyon

## Physics Engines

### Circle2D
https://github.com/koalefant/circle2d

### Rapier

### nphysics

### physx-rs
Wrapper around Nvidia's PhysX

# Gaming theory

## Entity Component Systems (ECS)

<!-- 
vim: ts=2:sw=2:sts=2
-->
