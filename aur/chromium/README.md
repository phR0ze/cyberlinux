# chromium
Chromium ***without*** Google's Orwellian type tracking, plus a few settings and UI tweaks to
enhance privacy and aesthetics to support ***cyberlinux***.

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
   a. **WebUI** - the webui directory contains UI elements for settings etc...
2. **Renderer** - per-tab subprocess that is driven by the browser
3. **Webkit** - embedded in renderer to do layout and rendering

### Browser Code (UI)
https://www.chromium.org/developers/design-documents/browser-window

***chrome/browser*** is the location for all browser code including UI feature dirs like
***themes***. ***chrome/browser/ui/views/browser_frame.cc*** is the main entry point for UI
related code.

#### Frame UI Code
Views and frames are the GTK wrappers for the window

* ***chrome/browser/ui/browser.cc***
  * Top level window in the application (i.e. main entry point)  
* ***chrome/browser/ui/views/browser_frame.cc***
  * BrowserFrame::GetThemeProvider => ThemeService::GetThemeProviderForProfile
  * BrowserFrame::GetNewAvatarMenuButton => browser_frame_view->GetProfileSwitcherView
* ***chrome/browser/themes/theme_service.cc***
  * Patch to always use incognito theme
* ***chrome/browser/ui/views/browser_view.cc***
  * BrowserView implementation
* ***chrome/browser/ui/profiles/profile_chooser_view.cc***
  * The dialog that is opened when you click Manage People from the Avatar Menu
* ***chrome/browser/ui/profiles/avatar_button.cc***
  * Actual Avatar button but we need the caller of this **AvatarButtonManager**
* ***chrome/browser/ui/views/frame/avatar_button_manager.cc***
  * Where the AvatarButton is actually created and added to the frame view
* ***chrome/browser/ui/views/frame/browser_non_client_frame_view.cc***
  * Looked promising but seems not used on linux and instead use ***opaque_browser_frame_view.cc***
* ***chrome/browser/ui/views/frame/opaque_browser_frame_view.cc***
  * Where the AvatarButtonManager is created and used to add the AvatarButton to the frame view
  * Has reference to avatar_button_manager i.e. **profile_switcher_**

#### WebUI Code
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

## Chromium Patches
Despite probably being the best browser out there Chromium has some glaring issues, in my opionion,
that need to be fixed before its useful as a daily runner.  I've focused on three major categories
for improvements in the code (***Arch Linux compatiblity***, ***Privacy/Security***, ***Aesthetic
compatibility with cyberlinux***. So I'm leveraging patches from others and creating my own to make
chromium fit with the ideals of the ***cyberlinux*** project as follows:

* **00-master-preferences.patch** - patching to set /etc/chromium/master_preferenes path to use
* **01-disable-default-extensions.patch** - patching to disble CloudPrint, HotWording, Feedback, InAppPayments
* **02-always-incognito-theme.patch** - patching code to always use the incognito theme (dark themes are better)
* **03-remove-profile-management.patch** - patching to remove profile managment from settings
* **04-remove-avatar-button.patch** - patching to remove the avatar button in the window title bar

Note: built in extensions can be validated by navigating to ***chrome://net-internals/#modules***

Other Possibilities:  
* Accidently removed the ingonito icon at the same time as the avatar icon
* Disable guest mode completely and remove from settings
* ***chrome://settings/content/cookies*** **Keep local data only until you quit your browser** is
false by default
* ***chrome://settings/content/automaticDownloads/ set to **Do not allow any site to download
multiple files automatically**
* ***chrome://settings/languages*** Spell check off by deafult?

* **No User Management Icon** - removing the user management icon as Linux is already multli-user
* Remove people in settings
* Remove multi user settings
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

These command line switches can be set in ***/etc/chromium/launcher.conf***

* **--disable-background-networking** Disable Google location tracking for omnibar searches
* **--disable-cloud-import** Disable importing cloud data
* **--disable-dinosaur-easter-egg** Disable dumb dinosaur offline game
* **--disable-sync** Disable syncing browser data to Google Account
* **--process-per-site** Default is to use a separate process per tab, this reduces memory by using a process per site

Note: these can be validated by navigating to ***chrome://version***

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
* Fix spellchecking with https://github.com/gcarq/inox-patchset/issues/83
