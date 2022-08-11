# Gaming in Rust

My intent in researching the Rust gaming ecosystem is to glean enough information to write a Android 
based application in Rust with custom graphics.

## Resources
* [GameDevRS](https://gamedev.rs/news)

### Example Applications
* FDG Force directed graph
  * [Github](https://github.com/grantshandy/fdg)
  * [Demo](https://grantshandy.github.io/fdg)
* Graphite - 2D image in-browser editor
  * [GraphiteRS](https://graphite.rs/)
  * [Graphite Github](https://github.com/GraphiteEditor/Graphite)
  * [Graphite Demo](https://editor.graphite.rs/)
* Hydrofoil - 3D super high quality Steam game
  * [Hydrofoil Generation](https://store.steampowered.com/app/1448820/Hydrofoil_Generation/)
* [Portal](https://github.com/optozorax/portal)
  * Uses both MacroQuad and EGUI
* Quad GIF - GIF rendering example using Macroquad
  * [Quad GIF Github](https://github.com/ollej/quad-gif)
* Rusty Aquarium
  * [Github](https://github.com/ollej/rusty-aquarium)
  * [Demo](https://ollej.github.io/rusty-aquarium/demo/)
* Rusty Slider
  * [Github](https://github.com/ollej/rusty-slider)
  * [Demo](https://ollej.github.io/rusty-slider/demo/example-slideshows.html)
* Sugar Cubes
  * [Demo](https://henryksloan.github.io/sugarcubes/)
  * [Github](https://github.com/henryksloan/sugarcubes)
  * MacroQuad and EGUI
  * Buildable and runnable

 
### Tutorials and learning
* [Boy Maas - youtube](https://www.youtube.com/channel/UC_GA3MH6UmklIgQX3_fCpLQ)
* [Bevvy Basics](https://www.youtube.com/c/PhaestusFox)
  * [Episode 1](https://youtu.be/pB3ERI5JtrA)
  * [Episode 2](https://youtu.be/G37yUGL3e1U)
  * [Episode 3](https://youtu.be/1q5iQsLVGJA)
  * [Episode 4](https://youtu.be/PjLozjlOgJ4)
* [Integrating Rust modules in Android](https://blog.logrocket.com/integrating-rust-module-android-app/)

# Libraries and platforms
* Most graphics packages are targetting `Vulkan`

**References:**
* [Are we game yet](https://arewegameyet.rs/)
* [5 Rust Game Engines](https://blog.logrocket.com/5-rust-game-engines-consider-next-project/)

**Sumary points:**
* Use Macroquad for maximum cross-platform support e.g. FishFight and Zemeroth

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

## EGUI
* [EGUI github](https://github.com/emilk/egui)
  * [EGUI Demo](https://www.egui.rs/#demo)
  * Pure Rust, inspired by Dear ImGui
  * Meant to be usable with other projects like Game engines
  * Integrates with Macroquad or MiniQuad
  * Immediate mode not retained mode which means high CPU load but games require this anyway

## Emerald

## Fyrox
* Production ready 2D/3D engine
* Supports Windows, Linux, macOS and Web
* Extensive documentation and resources and a game editor

## GGEZ
[GGEZ](https://github.com/ggez/ggez)

## Macroquad
[Macroqud github](https://github.com/not-fl3/macroquad) is a simple and easy-to-use game library.

Resources:
* [Publish Game on Android](https://macroquad.rs/tutorials/android/)
  * [Zemeroth](https://play.google.com/store/apps/details?id=rust.zemeroth)
* [Projects based on MacroQuad](https://github.com/ozkriff/awesome-quads)
* [Fish Game](https://github.com/heroiclabs/fishgame-macroquad)
* [Platformer Book](https://not-fl3.github.io/platformer-book/)
* [Fish Game tutorial](https://heroiclabs.com/blog/tutorials/rust-fishgame/)
* [Quad Sound](https://github.com/not-fl3/quad-snd)

### Features
* Android, Linux and WASM support
* Arch Linux specific instructions
  * `pacman -S pkg-config libx11 libxi mesa-libgl alsa-lib`
* Efficient 2D rendering with automatic geometry batching
* Supported by [Embark Studios](https://www.embark-studios.com) who are building their own game 
engine from the ground up in Rust

## Miniquad
[Miniquad github](https://github.com/not-fl3/miniquad) aims to provide a graphics abstraction that 
works the same way on any platform with a GPU, being as light weight as possible while covering as 
many machines as possible. Seems to be the backing graphics package for MacroQuad which aims to be 
more comprehensive for gaming.

Resources:
* [Miniquad Android game interop](https://macroquad.rs/articles/java/)

### Features
* Supports: Android, Linux, WASM and others
* Supported by [Embark Studios](https://www.embark-studios.com)

## Nannou
* Open source game framework
* Aims to use only Rust libraries and `cargo build`
* Full palette of creative tools for graphics, audio, lasers, lighting and more

## Piston
* Modular collection of 2D and 3D image processing, event programming, GUI, sound and animation libraries
* Uses a dynamic scripting language called Dyon

# Physics Engines

## Circle2D
https://github.com/koalefant/circle2d

## Rapier

## nphysics

## physx-rs
Wrapper around Nvidia's PhysX

# Gaming theory

## Entity Component Systems (ECS)

