Web
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting my learning experience with Rust Web frameworks
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
* [Axum](#axum)

# Overview

**Resources**
* [Rust on Nails](https://rust-on-nails.com/docs/ide-setup/introduction/)

# Axum
Axum, built by the same team that made Tokio, provides a web server and routing and is compatible 
with the tower middleware which is extensive.

**Resources**
* [Axum and Yew](https://github.com/rksm/axum-yew-setup)
* [Testing Axum](https://github.com/tokio-rs/axum/blob/main/examples/testing/src/main.rs)
* [Axum Examples](https://github.com/tokio-rs/axum/tree/main/examples)
* [Service static files with Axum](https://benw.is/posts/serving-static-files-with-axum)

## Tower-http
Provides axum the ability to serve static files

Add the dependency to your project
```toml
[dependencies]
tower-http = { version = "0.4.0", features = ["fs", "trace"] }
```

## Serve a Dioxus app
During development you'll be running the backend piece directly and working with the database etc... 
while on the frontend you'll be serving with `dioxus-cli serve`. These two components don't know 
about each other. In production we'll need to serve pre-compiled frontend files statically without 
`dioxus-cli` and instead use `axum` the chosen backend.

* [Dioxus cli config](https://github.com/DioxusLabs/cli/blob/master/docs/src/configure.md)
* [Axum and Dioxus](https://rust-on-nails.com/docs/full-stack-web/server-side-components/)

1. Create your `Dioxus.toml`
   ```rust
   $ cd ~/Projects/<project>/frontend
   $ dioxus config init <project>
   ```
2. Clean and build WASM
   ```rust
   $ dioxus clean
   $ dioxus build
   ```


1. Modify the axum server code `main.rs` to serve the static WASM content
   ```rust
   ```

<!-- 
vim: ts=2:sw=2:sts=2
-->
