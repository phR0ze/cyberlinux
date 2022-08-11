# GUI in Rust

This is not a comprehensive approach but rather documenting my findings for my interests. Since I'm 
looking for custom widgets I think I'll turn my attention to game engines instead.

**References**
* [Are we gui yet](https://www.areweguiyet.com/)

## Options as of 2022.07
* [Azul](https://github.com/fschutt/azul) based on Webrender
* [Druid](https://github.com/linebender/druid)
* [Dioxus](https://github.com/DioxusLabs/dioxus/)
* [EGUI github](https://github.com/emilk/egui)
  * [EGUI Demo](https://www.egui.rs/#demo)
  * Pure Rust, inspired by Dear ImGui
  * Meant to be usable with other projects like Game engines
  * Integrates with Macroquad or MiniQuad
  * Immediate mode not retained mode which means high CPU load but games require this anyway
* [FLTK](https://github.com/fltk-rs/fltk-rs)
* [Flutter bridge](https://github.com/fzyzcjy/flutter_rust_bridge)
* [Iced](https://github.com/iced-rs/iced)
  * Windows, macOS, Linux and Web
* [Winit](https://github.com/rust-windowing/winit)
  * Windows handling in pure Rust

### Discontinued or abandoned
* [Conrod](https://github.com/pistondevelopers/conrod)
