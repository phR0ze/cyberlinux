WordPress
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
WordPress development research

### Quick links
* [.. up dir](..)
* [Overview](#overview)

# Overview
WordPress is the oldest and most widely used content management system for blogging out there. Its 
plugin system makes it highly configurable to suite any purpose.

# Containerized WordPress
Running WordPress in Docker requires two separate containers, a web container running Apache and PHP 
and a database container hosting MySQL. You must set up Docker Volumes for the WordPress data 
directories.

## Install Dependencies
```bash
$ sudo pacman -S docker-compose
```

## Deploying WordPress
1. Create a new project directory
   ```bash
   $ mkdir wordpress
   $ cd wordpress
   ```
2. Create the `docker-compose.yaml` file
   ```
   version: "3"
   
   services:
     wordpress:
       image: wordpress:6.1-php8.0
       restart: unless-stopped
       ports:
         - 80
       environment:
         WORDPRESS_DB_HOST: mysql
         WORDPRESS_DB_USER: username
         WORDPRESS_DB_PASSWORD: password
         WORDPRESS_DB_NAME: wordpress
       volumes:
         - wordpress:/var/www/html
     mysql:
       image: mysql:8.0
       restart: unless-stopped
       environment:
         MYSQL_DATABASE: wordpress
         MYSQL_USER: username
         MYSQL_PASSWORD: password
         MYSQL_RANDOM_ROOT_PASSWORD: "1"
       volumes:
         - mysql:/var/lib/mysql
   
   volumes:
     mysql:
     wordpress:
   ```
3. Boot up your service by running
   ```bash
   $ docker-compose --no-ansi -d
   ```

# WordPress plugins

## Security
* Sucuri Security
* WordFence
* Cloudflare

## Search Engine Optimization (SEO)
* Yoast SEO
* SEOPress
* All in One SEO Pack
* Rank Math

## Starter Templates
* Astra Starter Templates
* Gutenberg Templates Library
* WPZoom Beaver Builder Templates

## Video players
* Presto Player
* Easy Video Player

## Utility
* Jetpack

* Ultimate Addons for Gutenburg
* Smush
* UpdraftPlus WordPress Backup Plugin

<!-- 
vim: ts=2:sw=2:sts=2
-->
