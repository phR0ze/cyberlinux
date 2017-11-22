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

## Semi-Incognito
Incognito mode is an awesome feature and I'd like to leverage many of its features to be used in
everyday browsing by default:

### Icognito Pros
* **Incognito Theme** - the dark theme provided by incognito mode is way better than the standard theme
* **No User Management Icon** - in incognito mode there is no user management options or icon in bar
* **No Payments** - payments are disabled by default in incognito mode
* No Browsing History
* No Download History
* Temp Cookie Store
* Won't share existing cookies

### Incognito Negatives
* Webstore doesn't show up on new tab page
* Extensions opens a new window to use
* Settings opens a new window to use

### Notes
Search terms:
* incognito
* IsOffTheRecord

# TODO: 
* Google omni bar search isn't working
* Doesn't remember pinned sites across restarts
