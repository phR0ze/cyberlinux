Privoxy
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
[Privoxy](https://www.privoxy.org) is a non-caching web proxy with advanced filtering capabilities 
for enhancing privacy, modifying web page data and HTTP headers, controlling access, and removing
ads and other obnoxious internet junk.
<br><br>

### Quick links
* [.. up dir](..)
* [Getting started](#getting-started)
  * [Install](#install)
    * [Test](#test)
  * [Basic config](#basic-config)
    * [http\_proxy](#http-proxy)
    * [Server mode](#server-mode)
* [Whitelist](#whitelist)

# Getting started <a name="getting-started"/></a>

## Build <a name="build"/></a>
It's necessary to build privoxy to get the `https-inspection` feature and include the `--with-openssl` flag

1. Download the tarball from https://sourceforge.net/projects/ijbswa/files/latest/download

## Install <a name="install"/></a>
```bash
$ sudo pacman -S privoxy
$ sudo systemctl enable privoxy
$ sudo systemctl start privoxy
```

### Test <a name="test"/></a>
1. Launch chromium with the proxy set
   ```bash
   $ http_proxy="http://localhost:8118" chromium
   ```
2. Navigate to `http://p.p`

## Basic config <a name="basic-config"/></a>

### http\_proxy <a name="http-proxy"/></a>
Firefox, Chromium and many other applications will respect the system wide proxy configured using
the environment variables:
* `http_proxy="http://localhost:8118"`

### Server mode <a name="server-mode"/></a>
Privoxy can easily be configured to be available on your network as a shared proxy service

1. Edit `/etc/privoxy/config`
2. Set `listen-address` to your server's network IP e.g. `192.168.1.3:8118`

# Whitelist <a name="whitelist"/></a>
Edit your `/etc/privoxy/user.action` file and add
```
############################################################
# Block everything but exception list
############################################################

# Block everything
{ +block }
/

# Exception list
{ -block }
kids.example.com
toys.example.com
games.example.com
```

<!-- 
vim: ts=2:sw=2:sts=2
-->
