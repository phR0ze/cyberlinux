Actix
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Actix development research
<br><br>

### Quick links
* [.. up dir](..)

# Getting Started
[Actix getting started guide](https://actix.rs/docs/getting-started/)

1. [see ../rust/README.md#create-new-project](../rust/README.md#create-new-project)
2. Add the actix dependency in `Cargo.toml`
   ```toml
   [dependencies]
   actix-web = "4"
   ```
3. Replace the contents of `src/main.rs` with:
   ```rust
   use actix_web::{get, post, web, App, HttpResponse, HttpServer, Responder};
   
   #[get("/")]
   async fn hello() -> impl Responder {
       HttpResponse::Ok().body("Hello world!")
   }
   
   #[post("/echo")]
   async fn echo(req_body: String) -> impl Responder {
       HttpResponse::Ok().body(req_body)
   }
   
   async fn manual_hello() -> impl Responder {
       HttpResponse::Ok().body("Hey there!")
   }
   ```

# Actix application
Actix provides all the primitives needed to build robust web applications in Rust. It provides:
* Routing
* Middleware
* Pre-processing of requests
* Post procesing of responses

The `App` instance is the is the fundamental building block used to register routes and middleware. 
It also shares application state shared across all handlers within the same scope. An application 
`scope` acts as a namespace for all routes, i.e. all routes for a specific application scope have the 
same url path prefix. The application prefix always contains a leading `/` slash. If a supplied 
prefix does not contain the leading `/` slash it is automatically inserted. For an application with 
scope `/app` any request of the form `/app`, `/app/`, or `/app/test` would match while `/application` 
would not.

<!-- 
vim: ts=2:sw=2:sts=2
-->
