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

## Command line switches
Chromium has a number of command line switches that are convenient to always have set:

These command line switches can be set in ***/etc/chromium/chromium.conf***

* **--disable-background-networking** Disable Google location tracking for omnibar searches
* **--disable-cloud-import** Disable importing cloud data
* **--disable-dinosaur-easter-egg** Disable dumb dinosaur offline game
* **--disable-sync** Disable syncing browser data to Google Account
* **--process-per-site** Default is to use a separate process per tab, this reduces memory by using a process per site

Note: these can be validated by navigating to chrome://version

## Semi-Incognito
Incognito mode is an awesome feature and I'd like to leverage many of its features to be used in
everyday browsing by default:

### Icognito Pros
* **Incognito Theme** - the dark theme provided by incognito mode is way better than the standard theme
* **No User Management Icon** - in incognito mode there is no user management options or icon in bar
* **No Payments** - payments are disabled by default in incognito mode
* **No Browsing History** - browsing history is not saved 
* **No Download History** - download history is not saved
* **No Cookies Shared/Stored** - new clean cookie jar created and no cookies saved or shared
* **No Form Data Stored** - no information entered into web site forms is saved
* **No WebSite Data** - no website data of any kind is saved

### Incognito Negatives
* Webstore doesn't show up on new tab page
* Extensions opens a new window to use
* Settings opens a new window to use

### Incognito Patch
```
grep -r incognito --exclude-dir={docs,ios}
```

## Backlog: 
* Doesn't remember pinned sites across restarts
