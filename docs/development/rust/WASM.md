Rust WASM
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting my learning experience with Rust and WASM
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
  * [Setup Rust for WASM](#setup-rust-for-wasm)
  * [WASM Bundlers](#wasm-bundlers)
  * [Frontend WASM](#frontend-wasm)
* [Frontend Web App with Yew](#frontend-web-app-with-yew)
  * [Yew setup](#yew-setup)
* [WASM with Macroquad](#wasm-with-macroquad)

# Overview
Rust's zero runtime (small binary) no garbage collection (reliable speed) approach makes it ideal for 
WebAssembly. There are two main uses for Rust and WebAssembly: building an entire web app in Rust and 
building part of a web app in Rust using an existing JavaScript frontend. I'm targeting the first 
option i.e. pure Rust.

**References**
* [EGUI Macroquad Demo](https://github.com/not-fl3/egui-miniquad)
* [Are We Web Yet](https://www.arewewebyet.org/topics/frameworks/#frontend)

## Setup Rust for WASM

1. Install WASM tooling
   ```
   $ rustup target add wasm32-unknown-unknown
   ```

## WASM Bundlers
* [Trunk](https://trunkrs.dev/)
  * Builds and Wasm apps and provides a local dev server simplifying Wasm dev in Rust
* [wasm-pack](https://rustwasm.github.io/wasm-pack/)
  * Build rust-generated WebAssembly packages that you could publish to the NPM alongside Javascript

## Frontend WASM
There is a growing ecosystem for frontend wasm. This means using Rust in the browser instead of or at 
least alongside of Javascript for SPA type web applications.

* [Yew 25.4k](https://github.com/yewstack/yew)
* [Iced 17.2k](https://github.com/iced-rs/iced)
* [Dioxus 5.5k](https://github.com/DioxusLabs/dioxus/)
* [Seed 3.5k](https://github.com/seed-rs/seed)
* [Sauron 1.7k](https://github.com/ivanceras/sauron)
* [MoonZoon 1.3k](https://github.com/MoonZoon/MoonZoon)

### Dioxus
Cross platform including Web, Mobile and Linux

* Good documentation
* Cross platform support, mobile is weak
* Uses unstable Rust

# Frontend Web App with Yew
Yew is a web app only framework and doesn't have desktop support

* [Trunk](https://trunkrs.dev/)
* [Ybc](https://github.com/thedodd/ybc)
* [Bulma](https://bulma.io/)

## Yew setup
1. Install WASM target
2. Install Yew dependencies
   ```
   $ cargo install --locked trunk
   $ cargo install --locked wasm-bindgen-cli
   ```
3. Run examples
   ```
   $ git clone https://github.com/yewstack/yew
   $ cd yew/examples/router
   $ trunk serve --release 
   ```

# WASM with Macroquad

1. Install WASM target
   ```
   $ rustup target add wasm32-unknown-unknown
   $ cargo install -f wasm-bindgen-cli
   $ cargo update
   $ cargo build --target wasm32-unknown-unknown
   $ wasm-strip target/wasm32-unknown-unknown/debug/<app>.wasm
   ```
2. Add `index.html`
   ```
   <html lang="en">
   
   <head>
       <meta charset="utf-8">
       <title>TITLE</title>
       <style>
           html,
           body,
           canvas {
               margin: 0px;
               padding: 0px;
               width: 100%;
               height: 100%;
               overflow: hidden;
               position: absolute;
               background: black;
               z-index: 0;
           }
       </style>
   </head>
   
   <body>
       <canvas id="glcanvas" tabindex='1'></canvas>
       <!-- Minified and statically hosted version of https://github.com/not-fl3/macroquad/blob/master/js/mq_js_bundle.js -->
       <script src="https://not-fl3.github.io/miniquad-samples/mq_js_bundle.js"></script>
       <script>load("CRATENAME.wasm");</script> <!-- Your compiled wasm file -->
   </body>
   
   </html>
   ```
3. Install test web server and serve app
   ```
   $ cargo install basic-http-server
   $ basic-http-server --addr 127.0.0.1:8080
   [INFO ] basic-http-server 0.8.1
   [INFO ] addr: http://127.0.0.1:8080
   [INFO ] root dir: .
   [INFO ] extensions: false
   ```
4. Open a browser to `127.0.0.1:8080`

