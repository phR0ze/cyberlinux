Rust WASM
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting my learning experience with Rust and WASM
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
  * [Setup Rust Toolchain](#setup-rust-toolchain)

# Overview
Rust's zero runtime no garbage collection approach makes it ideal for WebAssembly small binary size 
and reliable speed. There are two main uses for Rust and WebAssembly: building an entire web app in 
Rust and building part of a web app in Rust using an existing JavaScript frontend. I'm targeting the 
first option i.e. pure Rust.

**References**
* [EGUI Macroquad Demo](https://github.com/not-fl3/egui-miniquad)
* [Yew](https://github.com/yewstack/yew)
* [Trunk](https://trunkrs.dev/)
* [Rust and Web Assembly](https://rustwasm.github.io/docs/book/)

## Setup Rust Toolchain

1. Install WASM target and build
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

