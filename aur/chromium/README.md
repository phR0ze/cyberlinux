# chromium
Chromium without Google big brother montoring plus a few settings and UI tweaks to enhance privacy
and aesthetics.

https://github.com/gcarq/inox-patchset
https://github.com/Eloston/ungoogled-chromium
https://git.iridiumbrowser.de/cgit.cgi/iridium-browser/
https://anonscm.debian.org/cgit/pkg-chromium/pkg-chromium.git/tree/debian

## Update/Build process:
1. Update against arch abs PKGBUILD  
   https://git.archlinux.org/svntogit/packages.git/tree/repos/extra-x86_64?h=packages/chromium  
   a. Run: `yaourt -G chromium` to get the files locally  
   b. Manually sync any changes
2. Update patches/arch by hand
3. Build against arch patches only
4. Update patches/debian

## Source Code Navigation
https://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code

The chromium code base is separated into three main parts: 

1. **Browser** - the main process and represents the UI and I/O
2. **Renderer** - per-tab subprocess that is driven by the browser
3. **Webkit** - embedded in renderer to do layout and rendering

## Chromium Patches
I really like the ingonito theme and some of the incognito features offered in Chromium but not all.
To make this more alacarte I've created some patches to enable specific incognito features while
ignoring ones I don't like.

* **Always Incognito Theme** - patching code to always use the incognito theme

Other Possibilities:  
* **No User Management Icon** - in incognito mode there is no user management options or icon in bar
* **No Payments** - payments are disabled by default in incognito mode
* **No Browsing History** - browsing history is not saved 
* **No Download History** - download history is not saved
* **No Cookies Shared/Stored** - new clean cookie jar created and no cookies saved or shared
* **No Form Data Stored** - no information entered into web site forms is saved
* **No WebSite Data** - no website data of any kind is saved
* Webstore doesn't show up on new tab page
* Extensions opens a new window to use
* Settings opens a new window to use


### Other patches
I'm leveraging some of the patches from each of these projects see ***chroma.rb*** for details:

* **Arch Linux** - https://git.archlinux.org/svntogit/packages.git/tree/repos/extra-x86_64?h=packages/chromium
* **Debian** - https://anonscm.debian.org/cgit/pkg-chromium/pkg-chromium.git/tree/debian
* **INOX** - https://github.com/gcarq/inox-patchset

## Command line switches
Chromium has a number of command line switches that are convenient to always have set:

These command line switches can be set in ***/etc/chromium/chromium.conf***

* **--disable-background-networking** Disable Google location tracking for omnibar searches
* **--disable-cloud-import** Disable importing cloud data
* **--disable-dinosaur-easter-egg** Disable dumb dinosaur offline game
* **--disable-sync** Disable syncing browser data to Google Account
* **--process-per-site** Default is to use a separate process per tab, this reduces memory by using a process per site

Note: these can be validated by navigating to chrome://version

## Chromium Plugins
Chromium has a host of plugins available in the market for install a handful of which are essential
for safe performant operations and are included by default in this distribution of chromium:

* **https-everywhere** - automatically use HTTPS security where possible
* **smartup-gestures** - an acceptable mouse gestures plugin
* **tampermonkey** - World's most popular userscript manager
* **ublock-origin** - ad blocking is essential and origin adblock is one of the best
* **ublock-origin-extra** - foil early hostile anti-user mechanisms
* **videodownload-helper** - excellent clean plugin for downloading online videos

## Backlog: 
* Doesn't remember pinned sites across restarts

