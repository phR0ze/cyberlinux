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

### Browser Code (UI)
***chrome/browser*** is the location for all browser code including UI feature dirs like
***themes***. ***chrome/browser/ui/views/browser_frame.cc*** is the main entry point for UI
related code.

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
  * Handle button presses for the Avatar menu
* ***chrome/browser/ui/views/frame/browser_non_client_frame_view.cc***
  * Has reference to avatar_button_manager **profile_switcher_**  
  * Has **#define FRAME_AVATAR_BUTTON** bingo!!!
* ***chrome/browser/ui/views/frame/opaque_browser_frame_view.cc***
  * ?

* profile_indicator_icon
* profile_switcher

## Chromium Patches
Despite probably being the best browser out there Chromium has some glaring issues, in my opionion,
that need to be fixed before it useful as a daily runner.  I've focused on three major categories
for improvements in the code (***Arch Linux compatiblity***, ***Privacy/Security***, ***Aesthetic
compatibility with cyberlinux***. So I'm leveraging patches from others and creating my own to make
chromium fit with the ideals of the ***cyberlinux*** project as follows:

* **00-master-preferences.patch** - patching to set /etc/chromium/master_preferenes path to use
* **01-disable-default-extensions.patch** - patching to disble CloudPrint, HotWording, Feedback, InAppPayments
* **02-always-incognito-theme.patch** - patching code to always use the incognito theme (dark themes are better)
* **03-remove-manage-other-people.patch** - patching to remove the profile chooser in settings
* **04-remove-avatar-button.patch** - patching to remove the avatar button in the window title bar

Other Possibilities:  
* Disable guest mode completely and remove from settings

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
* Fix spellchecking with https://github.com/gcarq/inox-patchset/issues/83

## Notes
* 
profile switcher
ProfileSwitcher
glass_browser_frame_view.cc
AvatarIconPadding
incognito_bounds

* OFF_THE_RECORD
* SigninManager
* AvatarButton
* AvatarBubble
* AvatarMenu
* ShowAvatarBubbleFromAvatarButton
* IsOffTheRecord
* IsGuestSession
* SignIn
* Profiles
* LoginSession
* ChromeSessionManager
* chrome/browser/ui/views/profiles/profile_chooser_view.cc
    According to chrome/browser/ui/views/bookmarks/bookmark_bubble_sign_in_delegate_browsertest.cc
    comments line 100, ProfileChooserView::IsShowing() should be false
    * ProfileChooserView
    * IDS_PROFILES_MANAGE_USERS_BUTTON
    * account_button
    * guest_profile_button
* HandleManageOtherPeople 
* chrome_signin_helper.cc
    * NewIncognitoWindow
