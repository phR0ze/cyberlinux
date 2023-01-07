Web
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Web development research

### Quick links
* [.. up dir](..)
* [Single Page App](#single-page-app)
  * [App Shell Model](#app-shell-model)
  * [SEO issues with SPAs](#seo-issues-with-spas)
* [Web Framework](#web-framework)
  * [Overview](#overview)
  * [Frontend](#frontend)
  * [Backend](#backend)
* [Web Platform](#web-platform)
  * [Wordpress](#wordpress)

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
Wasm output is run alongside JavaScript and can be published to npm and other packages. Rust uses a 
tool called `wasm-pack` to assemble and package crates that target Wasm.

**References**
* [Current Rust Web Frameworks](https://blog.logrocket.com/current-state-rust-web-frameworks/)

**Comparing frontend wasm frameworks**
* `stdweb`
  * stable, not prod ready, project size: small
* `Yew`
  * billed as an improved version of stdweb. its a components based framework similar to React
  * stable, not prod ready, project size: small, med, large
  * 
* Percy
  * A toolkit for developing SPAs and managing UI
  * not stable, not prod ready, project size: small, med, large
* Seed
* Smithy
  * Rust native code, inspired by React
  * stable, prod ready, project size: small, med, large
* Sauron
* `Dioxus`
  * a virtual DOM-based UI with React-like design
  * cross platform for web, mobile, and desktop.
  * memory efficient
  * ergonomic
  * comprehensive inline documentation
* Iced
* Tauri

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
