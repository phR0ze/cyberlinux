Web
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Web development research

### Quick links
* [.. up dir](..)
* [Hosting](#hosting)
  * [Free static project website hosting](#free-static-project-website-hosting)
    * [Bitbucket](#bitbucket)
    * [Gitlab Pages](#gitlab-pages)
    * [Github Pages](#github-pages)
* [Single Page App](#single-page-app)
  * [App Shell Model](#app-shell-model)
  * [SEO issues with SPAs](#seo-issues-with-spas)
* [Web Framework](#web-framework)
  * [Overview](#overview)
  * [Frontend](#frontend)
    * [Dioxus frontend](#dioxus-frontend)
    * [Yew frontend](#yew-frontend)
  * [Backend](#backend)
* [WASM](#wasm)
  * [Setup Rust for WASM](#setup-rust-for-wasm)
  * [WASM Bundlers](#wasm-bundlers)
  * [WASM with Macroquad](#wasm-with-macroquad)
  * [Dioxus](#dioxus)
  * [Yew](#yew)
* [Web Platform](#web-platform)
  * [Wordpress](#wordpress)

# Hosting

## Free static project websites

### Bitbucket
* [Repo and file size limits](https://confluence.atlassian.com/bbkb/what-are-the-repository-and-file-size-limits-1167700604.html)
* [Repo size limits](https://bitbucket.org/blog/repository-size-limits)
* [Configure static website](https://support.atlassian.com/bitbucket-cloud/docs/publishing-a-website-on-bitbucket-cloud/)

* Limitations
  * 1 GB repo soft limit
  * 2 GB repo hard limit
  * 5000 requests per hour
  * 2 GB archive.zip files
  * Upload file size limit of 1GB?
    * I was able to push 115MB so maybe
  * Push limit of 3.5 GB/hour
* Features
  * Unlimited private repos
  * Git LFS limit of 1GB
* Workspace affects the clone URL
  * e.g. `git clone https://bitbucket.org/cyberlinux/aur.git`

#### Configure SSH Keys
Use SSH to avoid password prompts when you push code to Bitbucket

1. Edit your ssh config `~/.ssh/config`
2. Add a match block for bitbucket
   ```
   HostName bitbucket.org
   IdentityFile ~/.ssh/id_rsa
   ```
3. Now Navigate to your workspace root in bitbucket
4. Click the `SSH keys` option on the left
5. Click `Add key`
6. Give the key a label then paste in your public key

#### Publish Website with Bitbucket
[Reference](https://support.atlassian.com/bitbucket-cloud/docs/publishing-a-website-on-bitbucket-cloud/)
1. Create a new repository
   1. Set the Project name to `cyberlinux.bitbucket.io`
   2. Clone your repo with git protocol `git@bitbucket.org:cyberlinux/cyberlinux.bitbucket.io.git`
2. Add a `index.html` to the root of your project and commit and push the changes
3. Navigate to your new site [https://cyberlinux.bitbucket.io/](https://cyberlinux.bitbucket.io)
4. Directories are treated as their own sites
   1. Create a new directory `packages`
   2. Add nested directories to that dir `packages/cyberlinux/x86_64`
   3. This will then be accessible from arch linux with `Server = https://cyberlinux.bitbucket.io/packages/$repo/$arch`
5. Adding a new package
   1. Navigate to `~/Projects/cyberlinux.bitbucket.io/packages/cyberlinux/x86_64`
   2. Copy the target package here
   3. Remove stale index files `rm cyberlinux.*`
   4. Rebuild the index files `repo-add cyberlinux.db.tar.gz *.pkg.tar.*`
   5. Replace soft links with hard links for bitbucket to play nice
      ```
      $ ln cyberlinux.db.tar.gz cyberlinux.db -f
      $ ln cyberlinux.files.tar.gz cyberlinux.files -f
      ```

### Gitlab Pages
**Reference**
* [Gitlab Pages docs](https://docs.gitlab.com/ee/user/project/pages/)
* [100MB max artifact size](https://docs.gitlab.com/ee/administration/instance_limits.html)

### Github Pages
Github pages are pretty slick as they provide a simple way to create a static website for your 
project. Originally I used this as a nice way to host package files for my Arch Linux distro. However 
Github Pages has a strict file size limit of 100MB which makes this use case difficult as more and 
more packages are exceeding the limit these days.

#### Git Large File Storage <a name="git-large-file-storage"></a>
**WARNING** the git-lfs feature for Github is worthless as it has a 1Gb upload limit for opensource 
free accounts. Additionally it seems to interfere with powerline causing it to hang for a minute 
repeatedly. By turning off powerline in your shell before navigating to that project you can avoid 
this.

Git Large File Storage (LFS) replaces large files such as audio, videos, datasets and graphics with 
text pointers inside Git, while storing the file contents on a remote server like GitHub.com

1. Install the git-lfs extension for Arch Linux
   ```bash
   $ sudo pacman -S git-lfs
   ```
2. Navigate to the repo you'd like to use git-lfs for
   ```bash
   $ cd ~/Projects/cyberlinux-repo
   ```
3. Enable git-lfs for that repo which adds the configs `post-checkout`, `post-commit`, `post-merge`, 
   and `pre-push` to your local `.githooks` directory
   ```bash
   $ git lfs install
   ```
4. Configure the target extensions to track large file types
   ```bash
   $ git lfs track "*.zst"
   $ git lfs track "*.xz"
   ```
5. Now add all changes and commit them out and push them
   ```bash
   $ git add .
   $ git commit -m "Adding git lfs support"
   $ git lfs migrate import --everything --above=55Mb
   $ git push -f
   ```

# Single Page App

**Resources**:
* [What I wish I had known about SPAs](https://stackoverflow.blog/2021/12/28/what-i-wish-i-had-known-about-single-page-applications/)
* [The SPA must die reference](https://blog.logrocket.com/the-single-page-application-must-die/)

**Features**:
* No server roundtrip, reduced throughput
* Templating and routing on the client side
* The capability to work offline with caching
* Fast responsive design

## App Shell Model
The app shell model is the minimal HTML, CSS, and JavaScript that is required to power the user 
interface of a progressive web app and one of the components of a app with reliably good performance. 
The app shell is loaded once from the server by the user and cached locally then used from there for 
super fast startup times. A service worker then gets the app running. Dynamic content is loaded for 
each page using JavaScript. The app shell model results in blazing fast repeat visits and native-like 
interactions.

## Progressive enhancement
A progressive web app (PWA) is one that functions without JavaScript and progressively layers 
additional enhancements over the top to make the app more efficient and performant.

We can make proper use of server-side rendering by having the server initially respond to any 
navigation requests that are received with a complete HTML document, with content specific to the 
requested URL and not a bare-bones app shell. This way browsers or crawlers that don't support 
service workers can continue to send navigations requests to the server and the server will continue 
to respond to them with full HTML documents. Using `code splitting` we can load only enough 
JavaScript and CSS for the specific URL. This means on the first load a full HTML document is 
rendered that will still work if JavaScript is disabled. Once the first load finishes the react 
router's browser router takes over control of the navigation triggering client side rendering 
instead.

### SEO issues with SPAs
Search Engine Optimization (SEO) is the process of building your web application such that Google's 
crawlers are able to understand and correctly track and index it and rank it according to content. 
Single Page Applications are difficult for Google to understand and have a low SEO score.

One workaround for this is to serve different content for web crawlers to help them out.

### Social sharing issues with SPAs
Social networks when given a link will pull the webpage and uses the metadata inside the HTML header 
to generate a preview. This means often all links for an SPA will look the same and have an 
incomplete view.

### Caching issues with SPAs
Caching via CloudFlare or other reverse proxies can ease the load on your server and give end users a 
faster response. Because CloudFlare and other proxies don't execute JavaScript SPAs don't get the 
same caching that a traditional web application receives.

# Web Framework
A web framework is software tools that support the development of web applications; a web framework 
can range from a small codebase for micro apps to a large codebase for enterprise apps.

**References**
* [Complete Rust Web App](https://medium.com/@saschagrunert/a-web-application-completely-in-rust-6f6bdb6c4471)

## Overview

### Considerations
* Security
* Flexibility
* Community growth
* Project size

### Features
Web frameworks typically provide support for:
* Databases
* Templating
* Sessions
* Migrations

## Frontend
There is a growing ecosystem for frontend wasm. This means using Rust in the browser instead of or at 
least alongside of Javascript for SPA type web applications. Wasm output is run alongside JavaScript 
and can be published to npm and other packages. Rust uses a tool called `wasm-pack` to assemble and 
package crates that target Wasm.

**References**
* [Current Rust Web Frameworks](https://blog.logrocket.com/current-state-rust-web-frameworks/)

**Comparing frontend wasm frameworks**
* `stdweb`
  * stable, not prod ready, project size: small
* [Yew 25.4k](https://github.com/yewstack/yew)
  * billed as an improved version of stdweb. its a components based framework similar to React
  * stable, not prod ready, project size: small, med, large
* Percy
  * A toolkit for developing SPAs and managing UI
  * not stable, not prod ready, project size: small, med, large
* [Seed 3.5k](https://github.com/seed-rs/seed)
* Smithy
  * Rust native code, inspired by React
  * stable, prod ready, project size: small, med, large
* [Sauron 1.7k](https://github.com/ivanceras/sauron)
* [Iced 17.2k](https://github.com/iced-rs/iced)
* [MoonZoon 1.3k](https://github.com/MoonZoon/MoonZoon)
* Tauri

### Dioxus frontend
[Dioxus 6.6k](https://github.com/DioxusLabs/dioxus/) has a rapidly growing community.
* a virtual DOM-based UI with React-like design
* cross platform for web, mobile, and desktop.
* memory efficient
* ergonomic
* comprehensive inline documentation
* Good documentation
* Cross platform support, but mobile is weak
* Uses unstable Rust

### Yew frontend
Yew is a web app only framework and doesn't have desktop support

* [Trunk](https://trunkrs.dev/)
* [Ybc](https://github.com/thedodd/ybc)
* [Bulma](https://bulma.io/)

## Backend

* Rocket
  * Rust nightly
* Actix
  * Rust stable
* Gotham
* Rouille
* Nickels
* Thruster
* Iron
* Tide
* Dropshot

# WASM
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

## WASM with Macroquad

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

## Dioxus
[Dioxus 6.6k](https://github.com/DioxusLabs/dioxus/) has a rapidly growing community.
* React like design maps extremely well into Rust
* Cross platform for web, mobile, and desktop
* Memory efficient and ergonomic
* Comprehensive inline documentation
* But it uses unstable Rust

References:
* [Dioxus web docs](https://dioxuslabs.com/reference/web/)
* [Dioxus recommends Trunk](https://trunkrs.dev/)
  * Builds wasm apps

### Dioxus setup
1. Install WAM target
   ```
   $ rustup target add wasm32-unknown-unknown
   ```
2. Install Trunk
   ```
   $ cargo install trunk
   $ cargo install wasm-bindgen-cli
   ```
3. Create a new project
   ```
   $ cargo new --bin dioxus-app
   $ cd dioxus-app
   $ cargo add dioxus
   $ cargo add dioxus-web
   ```
4. Add index to use for Trunk
   ```html
   <!DOCTYPE html>
   <html>
     <head>
      <meta charset="utf-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
     </head>
     <body>
       <div id="main"> </div>
     </body>
   </html>
   ```
5. Set `main.rs` to:
   ```rust
   use dioxus::prelude::*;
   
   fn main() {
       dioxus::web::launch(app);
   }
   
   fn app(cx: Scope) -> Element {
       cx.render(rsx!{
           div { "hello, wasm!" }
       })
   }
   ```
6. Serve your app
   ```
   $ trunk serve
   ```

## Yew
Yew is a web app only framework and doesn't have desktop support

* [Trunk](https://trunkrs.dev/)
* [Ybc](https://github.com/thedodd/ybc)
* [Bulma](https://bulma.io/)

### Yew setup
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

# Web Platform
A web platform is a turn key style blog or content mangement system that only requires content. Which 
is different than a web framework which requires development to create the components needed to put  
together a web platform.

## WordPress
Workpress is the oldest and most widely used content management system for blogging out there. Its 
plugin system makes it highly configurable to suite any purpose.

### Wordpress plugins

#### Security
* Sucuri Security
* WordFence
* Cloudflare

#### Search Engine Optimization (SEO)
* Yoast SEO
* SEOPress
* All in One SEO Pack
* Rank Math

#### Starter Templates
* Astra Starter Templates
* Gutenberg Templates Library
* WPZoom Beaver Builder Templates

#### Video players
* Presto Player
* Easy Video Player

#### Utility
* Jetpack

* Ultimate Addons for Gutenburg
* Smush
* UpdraftPlus WordPress Backup Plugin