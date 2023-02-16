Yew wasm front-end
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Yew development research
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
  * [Install Dependencies](#install-dependencies)
  * [Run Yew examples](#run-yew-examples)
  * [Create new Yew project](#create-new-yew-project)
* [Yew Basic Concepts](#yew-basic-concepts)

# Overview
Yew is a wasm front-end web-app only framework.

* [Trunk](https://trunkrs.dev/)
* [Ybc](https://github.com/thedodd/ybc)
* [Bulma](https://bulma.io/)

## Install dependencies
1. Install WASM target
   ```bash
   $ rustup target add wasm32-unknown-unknown
   ```
2. Install Yew dependencies
   ```bash
   $ cargo install --locked trunk
   $ cargo install --locked wasm-bindgen-cli
   ```

## Run Yew examples
```bash
$ git clone https://github.com/yewstack/yew
$ cd yew/examples/router
$ trunk serve --release 
```

Browse to `http://127.0.0.1:8080`

## Create new Yew project
1. Create new binary crate
   ```bash
   $ cargo new yew-basic
   $ cd yew-basic
   ```
2. Add yew dependency to the project `Cargo.toml`
   ```toml
   [dependencies]
   yew = { git = "https://github.com/yewstack/yew/", features = ["csr"] }
   ```
3. Update `main.rs`
   ```rust
   use yew::prelude::*;
   
   #[function_component]
   fn App() -> Html {
       let counter = use_state(|| 0);
       let onclick = {
           let counter = counter.clone();
           move |_| {
               let value = *counter + 1;
               counter.set(value);
           }
       };
   
       html! {
           <div>
               <button {onclick}>{ "+1" }</button>
               <p>{ *counter }</p>
           </div>
       }
   }
   
   fn main() {
       yew::Renderer::<App>::new().render();
   }
   ```
4. Add an index file `index.html`
   ```html
   <!DOCTYPE html>
   <html>
       <head>
           <meta charset="utf-8" />
           <title>Yew App</title>
       </head>
   </html>
   ```
5. Finally serve your application
   ```bash
   $ trunk serve
   ```
6. Browse to `http://127.0.0.1:8080`

# Yew Basic Concepts

## HTML with html!
You can write expressions resembling HTML. Yew turns this into rust code representing the DOM to 
generate. `html!` provides string interpolation such that you can easily embedded variables from 
surrounding scope.
```rust
use yew::prelude::*;

let header_text = "Hello world".to_string();
let header_html: Html = html! {
    <h1>{header_text}</h1>
};

let count: usize = 5;
let counter_html: Html = html! {
    <p>{"My age is: "}{count}</p>
};

let combined_html: Html = html! {
    <div>{header_html}{counter_html}</div>
};
```

**You can only return 1 wrapping element**: to return more use a fragment i.e. tag without a name
```rust
use yew::html;

// Wraps the top level elements in html fragment
html! {
    <>
        <div></div>
        <p></p>
    </>
};
```

## CSS with classes!
A handy macro to handle classes

## JS with RS
Javascript with Rust

## wasm-bingen
Wasm-bingen is a tool allowing for calling to and from Javascript

## web-sys
Bindings for web APIs

```rust
use wasm_bindgen::UnwrapThrowExt;
use web_sys::window;

let document = window()
    .expect_throw("window is undefined")
    .document()
    .expect_throw("document is undefined");
```

<!-- 
vim: ts=2:sw=2:sts=2
-->
