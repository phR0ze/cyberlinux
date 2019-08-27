# chromium
Chromium ***without*** Google's Orwellian type tracking, plus a few settings and UI tweaks to
enhance privacy and aesthetics to support ***cyberlinux***.

### Disclaimer
This is a work in progress and comes with absolutely no guarantees or support of any kind. It is to
be used at your own risk.

## Table of Contents
* [Installation](#installation)
  * [Install](#install)
  * [Configure](#configure)
* [Overview](#overview)
  * [Data Sent to Google](#data-sent-to-google)
  * [Forks and Builds](#forks-and-builds)
    * [Arch Chromium](#arch-chromium)
    * [Woolyss](#woolyss)
    * [Ungoogled Chromium](#ungoogled-chromium)
    * [Inox Chromium](#inox-chromium)
    * [Bromite Chromium](#bromite-chromium)
    * [Debian Chromium](#debian-chromium)
    * [Iridium Chromium](#iridium-chromium)
    * [Vilvaldi Chromium](#vilvaldi-chromium)
    * [Epic Chromium](#epic-chromium)
    * [SRWare Iron Chromium](#epic-chromium)
    * [Opera 15 Chromium](#opera-15-chromium)
    * [Brave Chromium](#brave-chromium)
    * [Vendor Chromium](#vendor-chromium)
  * [Chrome built in pages](#chrome-built-in-pages)
  * [Command line switches](#command-line-switches)
  * [Chromium Settings](#chromium-settings)
  * [Chromium Policies](#chromium-policies)
  * [Chromium Extensions](#chromium-extensions)
* [cyberlinux Chromium](#cyberlinux-chromium)
  * [Update/Build process](#update-build-process)
  * [Chromium Patches](#chromium-patches)
      * [Other patches - see chroma.rb for details](#other-patches)
  * [Source Code Navigation](#source-code-navigation)
      * [Frame UI Code](#frame-ui-code)
      * [WebUI Code](#webui-code)
  * [Javascript modal dialogs](#javascript-modal-dialogs)
* [Backlog](#backlog)
* [Completed](#completed)

# Installation <a name="installation"></a>

## Install <a name="install"></a>
```bash
$ sudo pacman -S chromium pepper-flash chromium-widevine
```

## Configure <a name="configure"></a>
TBD from old doc

# Overview <a name="overview"></a>
Because of Google's backing and a ton of other contributors Chromium has become the defacto standard
in the browser market and seen a lot of performance and efficiency boosts other browser haven't been
able to keep up with.  Despite its awesomeness, however Google has built a bunch of Orwellian phone
home type tracking, privacy leaking, and ad-vertising crap etc... into the code base. 

Many efforts have been made to plugs these vulnerabilities. My goal is to leverage these fixes where
possible to get a browswer that is fast, private and compatible with chromium's browser extensions
out of the box.

## Data Sent to Google <a name="data-sent-to-google"></a>
* ***Installation ID*** - Google Chrome generates a unique identification on installation time.
  According to Google, this ID will be used to track the number of installations.
* ***RLZ identifier*** - Google Chrome communicates information about where Google Chrome was downloaded
* ***Client ID*** - A unique client ID transmitted to Google in the case that Google Chrome crashes
* ***Link tracking*** - the links you click and enter in the address bar
* ***Suggest*** - During your input, text from the url bar is transmitted to google. Can be disabled
  by unchecking the `Under the Hood >Use a prediction service` setting.
* ***Alternate Error Pages*** - if you have a navigation error in your url it is sent to googl and
  you get an error message from Google's servers. Can be disabled by unchecking the `Under the Hood
  >Use a web service to help resolve navigation errors` setting.
* ***Bug Tracker*** - If Chrome detects a fault it is sent to Google
* ***Google Updater*** - Google installs a Google updater that searches updates in the background
* ***Malformed URL*** - Once you enter the wrong address in the browser address line, Chrome will send this address to Google

## Forks and Builds <a name="forks-and-builds"></a>
A number of forks and builds have sprung into existence to offer various alternatives. Some simply
building the open source chromium bits to make them available, while others are customized with
patches and still others have forked the code base to add features or privacy. Due to the work
involved in maintaining these patch sets, custom builds and forks many lag behind the Chromium code
base substantially.

I've ordered them by usefullness to the ***cyberlinux*** project which is Arch Linux based.

### Arch Chromium <a name="arch-chromium"></a>
Arch Linux provides a simple build of chromium with only minimal system patches to work with the Arch
Linux operating system.

Packages available to Arch:
* **extra/chromium** - standard chromium build
* ***extra/pepper-flash*** - Adobe Flash Player PPAPI plugin for chromium
* ***aur/chromium-widevine*** - widevine DRM protected media plugin for chromium
* ***aur/https-everywhere-chrome*** - chromium extension to use https everywhere
* ***aur/chromium-ublock-origin*** - an efficient ad blocker extension for chromium
* ***aur/chromium-extension-violentmonkey-git*** - monkey scripts alternative extension for chromium

### Ungoogled Chromium <a name="ungoogled-chromium"></a>
https://github.com/Eloston/ungoogled-chromium

### Inox Chromium <a name="inox-chromium"></a>
https://github.com/gcarq/inox-patchset maintained primarily by Michael Egger is a set of patches
that improve security and privacy of Chromium.

### Debian Chromium <a name="debian-chromium"></a>
https://tracker.debian.org/pkg/chromium maintained mainly by Michael Gilbert provides Debian's build
of Chromium with some stability patching.

### Bromite Chromium <a name="bromite-chromium"></a>
https://github.com/bromite/bromite maintained primarily by Carl csagan5 is a set of patches that
improve ad blocking and privacy. The project seems to be very active.

### Iridium Chromium <a name="iridium-chromium"></a>
https://github.com/iridium-browser/tracker/wiki/Differences-between-Iridium-and-Chromium is a fork
of Chromium backed by the Open Source Business Alliance aimed at privacy and security in a
transparent auditable way.

### Vilvaldi Chromium <a name="vilvalidi-chromium"></a>
Vivaldi is the brainchild of Opera’s former CEO, who wasn’t happy with the direction Opera was
headed. It aims to target power users while bringing back discarded features from Opera.

### Epic Chromium <a name="epic-chromium"></a>
Epic is a privacy-centered web browser. It is always in a “Private browsing” mode, and proactively
removes cookies, browser history, and cache upon exit. It also disables other data that is sent to
Google, like address bar suggestions.

### SRWare Iron Chromium <a name="epic-chromium"></a>
SRWare Iron is another privacy-focused browser that aims to eliminate privacy-compromising
functionality from Google Chrome. To accomplish this, it takes a different approach: instead of
adding new features, it actually strips down potentially privacy-related functionality from Chrome.
It removes Google-hosted error pages, Google Updater, DNS pre-fetching, address bar suggestions,
etc. Built in ad-blocking, user agent switcher and more.

### Opera 15 Chromium <a name="opera-15-chromium"></a>
Opera continued to innovate and break new grounds for browsers, being the first to integrate an ad
blocker by default, a VPN-like system, a cryptocurrency wallet, and it was also the first browser to
experiment a floating video player window years before Google developers even thought of adding one
to Chrome.

### Brave Chromium <a name="brave-chromium"></a>
Privacy-focused browser Brave has finished the final phase of a two-stage process and has now
migrated most of its userbase to a full Chromium codebase, the same one used by Chrome, Vivaldi,
Opera, and soon, Edge. Brave doesn't integrate any of the Google-based features that Chromium
includes. Includes built-in ad blocking, built in tor and more.

### Blisk Chromium <a name="blisk-chromium"></a>
Blisk is a Chromium browser like no other, mainly because it's aimed at developers above all.
Regular users can use it too, but the browser is packed choke-full with tools and features that
developers often install as extensions on Chrome installations. This developer-oriented browser
comes with features such a tool that lets devs test how a website would look on laptops, tablets,
and smartphones alike; support for touch events; user-agent switching; different device pixel
ratio rendering; and many other more.

### Superbird Chromium <a name="superbird-chromium"></a>
http://superbird-browser.com/download.php

### Woolyss <a name="Woolyss"></a>
https://chromium.woolyss.com aims to provide information on how to get/install chromium for your
various platforms or in Windows case provides automated builds. Its a good resource for tracking
Chromiums latest versions and stability.

### Vendor Chromium <a name="vendor-chromium"></a>
Many vendors have highly customized versions of chromium they offer

* ***Comodo Dragon*** disables the privacy-compromising functionality in Chrome. It removes address
bar suggestions, bug tracking system, and Google user tracking. The built-in PDF viewer, Google Safe
Browsing, and Google Translate also get the boot. It lets users configure their computers to use
Comodo’s DNS servers, which performs additional checks to verify the security of websites.
* Avast Secure Browser
* Amazon Silk
* Samnsun Internet Browser
* Yandex Browser
* Qihoo 360 Secure Browser
* Torch Browser

## Chrome built in pages <a name="chrome-built-in-pages"></a>
* **chrome://gpu** - get GPU details
* **chrome://net-internals/#modules** - validate built in extensions
* **chrome://sandbox** - get sandbox details
* **chrome://version** - validate command line flags and see versions

## Command line switches <a name="command-line-switches"></a>
Chromium has a number of command line switches that are convenient to always have set:

These command line switches can be set in ***/etc/chromium/launcher.conf***

* **--disable-background-networking** Disable Google location tracking for omnibar searches
* **--disable-cloud-import** Disable importing cloud data
* **--disable-dinosaur-easter-egg** Disable dumb dinosaur offline game
* **--disable-sync** Disable syncing browser data to Google Account
* **--process-per-site** Default is to use a separate process per tab, this reduces memory by using a process per site
* **--disable-logging** Default is to log various things
* **--disable-notifications** Disable the annoying pop up notifications
* **--disable-ntp-popular-sites** Disable tracking and listing populare sites on your New Tab Page

## Chromium Settings <a name="chromium-settings"></a>
These settings have all been translated into preferences or policies but I like having a list here to
double check:

1. Navigate to `chrome://settings`
2. Disable `Autofill >Passwords >Offer to save passwords`
3. Disable `Autofill >Payment methods >Save and fill payment methods`
4. Disable `Autofill >Addresses and more >Save and fill addresses`
5. Select `Appearance >Themes >Classic`
6. Enable `Appearance >Show bookmarks bar`
7. Select `Search engine >DuckDuckGo`
8. Disable `Sync and Google services >Autocomplete searches and URLs`
9. Disable `Sync and Google services >Show suggestions for similar pages when a page can't be found`
10. Disable `Sync and Google services >Safe Browsing (protects you and your device from dangerous sites)`
11. Disable `Sync and Google services >Help improve Chrome security`
12. Disable `Sync and Google services >Make searches and browsing better`
13. Disable `Allow Chromium sign-in`
13. Enable `Send a "Do Not Track" request with your browsing traffic`
14. Disable `Allow sites to check if you have payment methods saved`
15. Disable `Preload pages for faster browsing and searching`
16. Select `Site Settings >Cookies >Keep local data only until you quit your browser`
16. Disable `Site Settings >Location`
17. Disable `Site Settings >Notifications`
18. Disable `Site Settings >Pop-ups and redirects`

## Chromium Policies <a name="chromium-policies"></a>
References for policy and extension settings
* http://dev.chromium.org/administrators/policy-list-3
* https://www.chromium.org/administrators/linux-quick-start
* https://www.chromium.org/administrators/configuring-policy-for-extensions

Chromium has the ability to set policy read from ***/etc/chromium/policies/recommended*** also
policies can also be configured for extensions that support policy management via the managed
storage API. Extensions that support policy management are listed in ***chrome://policy*** along
with the policies they support.

## Chromium Extensions <a name="chromium-extensions"></a>
Chromium has a host of extensions available in the webstore for install. A handful of which are essential
for safe, performant operations and others useful:

* **https-everywhere** - automatically use HTTPS security where possible
* **markdown-viewer** - convert markdown files to HTML inside chromium, allow access to file URLS
* **smartup-gestures** - an acceptable mouse gestures plugin
* **tampermonkey** - World's most popular userscript manager
* **ublock-origin** - ad blocking is essential and origin adblock is one of the best
* **ublock-origin-extra** - foil early hostile anti-user mechanisms
* **videodownload-helper** - excellent clean plugin for downloading online videos

# cyberlinux Chromium <a name="cyberlinux-chromium"></a>
Chromium ***without*** Google's Orwellian type tracking, plus a few settings and UI tweaks to
enhance privacy and aesthetics to support ***cyberlinux***.

## Update/Build process <a name="update-build-process"></a>
Notes to myself when re-building this package:

Example target version `76.0.3809.100`:
1. Update against arch abs PKGBUILD  
   ```bash
   # Download the arch abs chromium package
   # https://git.archlinux.org/svntogit/packages.git/tree/repos/extra-x86_64?h=packages/chromium  
   $ yay -G extra/chromium

   # Ensure we have the correct target version
   $ grep "pkgver=" chromium/PKGBUILD 
   pkgver=76.0.3809.100

   # Manually compare and update as needed.
   $ diff PKGBUILD chromium/PKGBUILD
   ```
2. Update `patches/arch` by hand
   ```bash
   # Remove all the existing patches
   $ rm patches/arch/*

   # Download source to create clean patches
   $ makepkg -so

   # Stage chromium for generating patches
   $ cp chromium-76.0.3809.100.tar.xz patches/arch; cd patches/arch
   $ tar xfJ chromium-76.0.3809.100.tar.xz
   $ rm chromium-76.0.3809.100.tar.xz
   $ mv chromium-76.0.3809.100 a; cp -a a b

   # Create patch for 'Allow building against system libraries in official builds' in PKGBUILD
   $ cd b; sed -i 's/OFFICIAL_BUILD/GOOGLE_CHROME_BUILD/' tools/generate_shim_headers/generate_shim_headers.py
   $ diff -ruN a b > 00-build-against-system-libraries.patch

   # Create patch for https://crbug.com/893950 fix in PKGBUILD
   $ rm -rf b; cp -a a b; cd b
   $ sed -i -e 's/\<xmlMalloc\>/malloc/' -e 's/\<xmlFree\>/free/' \
     third_party/blink/renderer/core/xml/*.cc \
     third_party/blink/renderer/core/xml/parser/xml_document_parser.cc \
     third_party/libxml/chromium/libxml_utils.cc
   $ diff -ruN a b > 01-crbug.com-893950.patch

   # Move the widevine patch into 'not-used' as the debian patches for this way better

   # Recreate the skia harmony patch
   $ rm -rf b; cp -a a b; cd b
   $ patch -Np0 -i ../../../chromium/chromium-skia-harmony.patch
   $ diff -ruN a b > 02-chromium-skia-harmony.patch
   ```
3. Build against arch patches only
   ```bash
   # Comment out the patchsets except for arch
   # Comment out the plugins section at the bottom

   # Build and package
   $ makepkg -s
   ```
4. Update patches/debian next
   ```bash
   # Update latest chroma for debian patches then run
   # see github.com/phR0ze/chroma
   $ ./chroma down patches debian

   # Update the PKGBUILD to include the debian patches
   $ makepkg -Cfs
   ```
5. Update patches/ungoogled next
   ```bash
   # Update latest chroma for ungoogled patches then run
   # see github.com/phR0ze/chroma
   $ ./chroma down patches ungoogled

   # Update the PKGBUILD to include the debian patches
   $ makepkg -Cfs
   ```
6. Validate plugins install and configuration is correct
   | Feature               | Notes
   |-----------------------|---------------------------------------------------
   | Incognito             | Color scheme is correct and indicator icon exists
   | Show Home Button      | Enabled correctly in settings based on master preferences
   | Send a "Do Not Track" | Enabled correctly in settings based on master preferences
   | Ask where to save     | Is working correctly defaults to ~/Downloads
   | Cookies               | Set to keep local data only until you quit your browser
   | Flash                 | Blocks sites from running Flash is off
   | PDF documents         | Allow pdfs to be viewed in browser
   | Block location        | Site access to location is strictly blocked
   | Block notifications   | Site access to notifications is strictly blocked
   | Plugins               | Plugins are now working from webstore
7. Extensions

## Chromium Patches <a name="chromium-patches"></a>
Despite probably being the best browser out there Chromium has some glaring issues, in my opionion,
that need to be fixed before its useful as a daily runner.  I've focused on three major categories
for improvements in the code (***Arch Linux compatiblity***, ***Privacy/Security***, ***Aesthetic
compatibility with cyberlinux***. So I'm leveraging patches from others and creating my own to make
chromium fit with the ideals of the ***cyberlinux*** project as follows:

* **01-disable-default-extensions.patch** - patching to disble CloudPrint, HotWording, Feedback, InAppPayments
* **02-always-incognito-theme.patch** - no longer using as dark mode can be easily enabled with a flag now
* **03-remove-profile-management.patch** - patching to remove profile managment from settings
* **04-remove-avatar-button.patch** - patching to remove the avatar button in the window title bar

### Other patches - see chroma.rb for details <a name="other-patches"></a>
I'm leveraging some of the patches from some of these projects:

* **Arch Linux** - https://git.archlinux.org/svntogit/packages.git/tree/repos/extra-x86_64?h=packages/chromium
* **Debian** - https://anonscm.debian.org/cgit/pkg-chromium/pkg-chromium.git/tree/debian
* **INOX** - https://github.com/gcarq/inox-patchset
* **Iridium** - https://git.iridiumbrowser.de/cgit.cgi/iridium-browser/
* **Ungoogled** - https://github.com/Eloston/ungoogled-chromium

## Source Code Navigation <a name="source-code-navigation"></a>
https://www.chromium.org/developers/how-tos/getting-around-the-chrome-source-code

The chromium code base is separated into three main parts: 

1. **Browser** - the main process and represents the UI and I/O
   a. **WebUI** - the webui directory contains UI elements for settings etc...
2. **Renderer** - per-tab subprocess that is driven by the browser
3. **Webkit** - embedded in renderer to do layout and rendering

### Frame UI Code <a name="frame-ui-code"></a>
https://www.chromium.org/developers/design-documents/browser-window

`chrome/browser` is the location for all browser frame code including UI feature dirs like
`themes`. `chrome/browser/ui/views/browser_frame.cc` is the main entry point for UI
related code.

* `chrome/browser/ui/browser.cc`
  * Top level window in the application (i.e. main entry point)  
* `chrome/browser/ui/views/browser_frame.cc`
  * BrowserFrame::GetThemeProvider => ThemeService::GetThemeProviderForProfile
  * BrowserFrame::GetNewAvatarMenuButton => browser_frame_view->GetProfileSwitcherView
* `chrome/browser/themes/theme_service.cc`
  * Patch to always use incognito theme
* `chrome/browser/ui/views/browser_view.cc`
  * BrowserView implementation
* `chrome/browser/ui/profiles/profile_chooser_view.cc`
  * The dialog that is opened when you click Manage People from the Avatar Menu
* `chrome/browser/ui/profiles/avatar_button.cc`
  * Actual Avatar button but we need the caller of this **AvatarButtonManager**
* `chrome/browser/ui/views/frame/avatar_button_manager.cc`
  * Where the AvatarButton is actually created and added to the frame view
* `chrome/browser/ui/views/frame/browser_non_client_frame_view.cc`
  * Looked promising but seems not used on linux and instead use `opaque_browser_frame_view.cc`
* `chrome/browser/ui/views/frame/opaque_browser_frame_view.cc`
  * Where the AvatarButtonManager is created and used to add the AvatarButton to the frame view
  * Has reference to avatar_button_manager i.e. **profile_switcher_**
  * InitWindowCaptionButton, IDR_MINIMIZE, IDR_MAXIMIZE, IDR_CLOSE
* `chrome/app/theme/theme_resources.grd`
  * Source file paths for all images
  * ui/views/resources/default_100_percent/linux/linux_minimize.png

### WebUI Code <a name="webui-code"></a>
WebUI is responsible for content UI like extensions, settings, etc...

* ***chrome/browser/ui/toolbar/app_menu_model.cc***
  * Construction of the menu for the UI
* ***chrome/app/settings_strings.grdp***
  * UI settings menu strings **IDS_SETTINGS_PEOPLE_MANAGE_OTHER_PEOPLE**
* ***chrome/app/settings_chromium_strings.grdp***
  * Ui settings menu strings **IDS_SETTINGS_SYNC_DISABLED_BY_ADMINISTRATOR**
* ***chrome/browser/ui/webui/settings/md_settings_localized_strings.provider.cc***
  * Links IDS_SETTINGS_PEOPLE_MANAGE_OTHER_PEOPLE to manageOtherPeople
* ***chrome/browser/resources/settings/people_page/people_page.html***
  * Actual html layout code for people settings UI widgets

## Javascript modal dialogs <a name="javascript-modal-dialogs"></a>
http://www.javascripter.net/faq/confirm.htm
https://googlechrome.github.io/samples/block-modal-dialogs-sandboxed-iframe/

The goal is to have javascript execute but block all modal dialogs such as alert(), confirm(),
print(), prompt().

The sandbox feature with ***allow-scripts*** and ***allow-modals***

# Backlog  <a name="backlog"></a>

# Completed <a name="completed"></a>
* 76.0.3809.100: Dark Mode all the time
* 76.0.3809.100: Webstore extensions are not allowed
* 76.0.3809.100: ***chrome://settings/languages*** Spell check off by deafult?
* 76.0.3809.100: Fix spellchecking with https://github.com/gcarq/inox-patchset/issues/83
* 76.0.3809.100: ***chrome://settings/content/cookies*** **Keep local data only until you quit your browser** is false by default
