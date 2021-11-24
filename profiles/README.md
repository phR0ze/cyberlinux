cyberlinux profiles
====================================================================================================

<img align="left" width="48" height="48" src="../art/logo_256x256.png">
`Profile` in <b><i>cyberlinux</i></b> is a term used to describe the set of related installable 
deployments that will show up on your multi-boot ISO once the build completes. These deployments are 
meant to share a common desktop environment and build on each other in a layered fashion. In this way 
we can have a variety of different pre-built deployments for different purposes while still keeping 
the ondisk size minimal. There is an associated directory at `profiles/<PROFILE-NAME>` that contains 
the `profile.json` describing the deployments that are to be built as well as the `PKGBUILD` 
describing all the packages that the profile will build during ISO construction and can later be used 
to upgrade existing deployments.

### Quick links
* [.. up dir](..)
* [Profiles](#profiles)
  * [Packages](#packages)
    * [Build Packages](#build-packages)
    * [Publish Packages](#publish-packages)
  * [profile.json](#profile-json)
    * [deployments](#deployments)
    * [dependencies](#dependencies)
* [Layers](#layers)
* [Guides](#guides)
  * [Apps](#apps)
    * [Add new app](#add-new-app)
  * [Deployment](#deployment)
    * [Create a new deployment](#create-a-new-deployment)
  * [Xfce](#xfce)
    * [Cycle through workspaces](#cycle-through-workspaces)
    * [Default Wallpaper](#default-wallpaper)
    * [LCD clock style](#lcd-clock-style)
  * [Xorg](#xorg)
    * [Default Resolution](#default-resolution)
* [Backlog](#backlog)

---

# Profiles <a name="profiles"/></a>

## Packages <a name="packages"/></a>

### Build Packages <a name="build-packages"/></a>
1. Clone `cyberlinux` locally
2. Change directory into the `cyberlinux` directory
3. Re-build packages: `./build.sh -p xfce -c repo -r`

### Publish Packages <a name="publish-packages"/></a>
1. Copy the resulting packages to the repo clone
   ```bash
   $ cd ~/Projects/cyberlinux-repo/cyberlinux/x86_64
   $ rm *xfce*
   $ rm *standard*
   $ cp ~/Projects/cyberlinux/temp/repo/cyberlinux*.tar.zst .
   ```
2. Rebuild the repo and push the commit back to github
   ```bash
   $ rm cyberlinux.*
   $ repo-add cyberlinux.db.tar.gz *.pkg.tar.*
   ```
3. Commit the changes and push the commit
   ```bash
   $ cd ../../
   $ git add .
   $ git commit -m "Adding rust-adm and rust-src as standard/shell dependencies"
   $ git push
   ```

## profile.json <a name="profile-json"/></a>
The `profile.json` is the heart of the profile describing the installable `deployments` that will 
show up on your multi-boot ISO when the build completes.

## deployments <a name="deployments"/></a>
A `deployment` defines an installable option as listed in the booted ISO menu. It calls out the 
composition of the deployment as follows:

* `name` is the name of the deployment levaragable as a key in various commands
* `entry` is the description of the deployment that shows up in the ISO menu at boot time
* `kernel` is the kernel to use for the deployment and is largly a default at this point
* `layers` is the file system layers this deployment is composed of
* `groups` is the groups that new users should be part of for the installed deployment
* `packages` is a list of packages that should be installed as part of this deployment

## dependencies <a name="dependencies"/></a>
The `dependecies` section of the profile indicates if there are any other profiles that this profile 
depends on. This is useful when you have packages built in another profile that your profile depends 
on. For example the default Xfce profile's shell deployment depends on the standard packages for 
core, base and shell which will be installed and compose the Xfce shell layer. Note that layers 
cannot cross the profile boundary. In this example we depended on the standard profile's packages but 
we did not simply reference the standard profile's layers.

Call out profiles in the `dependencies` section will trigger them to be built first before your 
profile.

# Layers <a name="layers"/></a>
A `layer` referres to the squashfs image of the file system at a particular point in time. These 
layers are then overlaid on top of each other using the overlay file system to incrementally build up 
a complete file system. In this was a minimal shell type system can be created and stored as a squash 
fs image i.e. layer to then be used as the foundation on which a full linux desktop environment could 
then be built while still keeping the ability to install the underlying shell only layer as a 
separate deployment on the ISO. In this way we can re-use configs and applications for higher level 
deployments. For example a full desktop environment may be composed of a series of lower level layers 
that have been joined using the overlay fs technique. This allows for a lot of flexibility for 
deployment options while saving space on your ISO media.

# Guides <a name="guides"/></a>

## Apps <a name="apps"/></a>

### Add new app <a name="add-new-app"/></a>
To add a new application to the requirements for cyberlinux all you need to do is:

1. Determine which deployment to include it in. In this example we'll use `rust-asm` and `rust-src` 
   which are standard system packages so I'll include them in the `standard/shell` profile
2. Edit the target profile's `standard/PKGBUILD` and in the `shell` section add:
   ```
   'rust-src'                  # Source code for the Rust standard library
   'rust-wasm'                 # WebAssembly targets for Rust
   ```
3. Commit out your changes so you get a version bump
   ```bash
   $ git add .
   $ git commit -m "Adding rust asm targets and std source"
   ```
3. [Build Packages](#build-packages)
4. [Publish Packages](#publish-packages)

## Deployment <a name="deployment"/></a>

### Create a new deployment <a name="deployment"/></a>
You can create a new deployment with the following steps:

1. Navigate to your target profile e.g. `cd cyberlinux/profiles/xfce`
2. Create new deployment directory e.g. `mkdir theater`
3. Create a post install package script `theater.install` for the deployment:
   ```bash
   post_install()
   {
     echo ""
   }
   
   post_upgrade() {
   	post_install
   }
   ```
4. Modify the `PKGBUILD` file to include the new `theater` package
5. Modify the `profile.json` file to include the new deployment:
   ```json
   {
     "name": "theater",
     "entry": "Install xfce theater       // Theater env for Personal Use Only",
     "kernel": "linux",
     "layers": "xfce/shell,xfce/x11,xfce/lite,xfce/netbook,xfce/desktop,xfce/theater",
     "groups": "lp,wheel,network,storage,users,video,audio,adbusers,uucp,disk,docker,vboxusers",
     "packages": [
       "cyberlinux-xfce-theater"
     ]
   },
   ```
6. Clean repo packages `./build.sh -p xfce -c repo`
7. Build `./build.sh -p xfce -d theater -rimI`

## Xfce <a name="xfce"/></a>
Most of Xfce's custom configuration is stored in the dir `~/.config/xfce4/xfconf/xfce-perhannel-xml`. 
Typically the process for persisting a configuration is to make the change then copy over the related 
config file to this location then do a diff to see what changed. For example changing the LCD clock 
style went like this:

### Cycle through workspaces <a name="cycle-through-workspaces"/></a>
We'll be setting up `Super+Tab` to cycle through the existing workspaces forward and 
`Super+Shift+Tab` to cycle backward.

**Set keyboard binding**:
1. Open `Settings >Window Manager`
2. Switch to the `Keyboard` tab
3. Scroll down to the `Previous workspace` binding and set it to `Super+Shift+Tab`
3. Scroll down to the `Next workspace` binding and set it to `Super+Tab`

**Set keyboard binding**:
1. Open `Window Manager Tweaks`
2. Switch to the `Workspaces` tab
3. Enable `Wrap workspaces when the first or the last workspace is reached`

**Preserve the changes in cyberlinux**:
1. Copy `~/.config/xfce4/xfconf/xfce-perhannel-xml/xfce4-keyboard-shortcuts.xml` and
   `~/.config/xfce4/xfconf/xfce-perhannel-xml/xfce4.xml` to
   `~/Projects/cyberlinux/profiles/xfce/lite/etc/skel/.config/xfce4/xfconf/xfce-perhannel-xml/`
3. Run a diff `git diff` to see the target changes
   ```diff
   # w/profiles/xfce/lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm-keyboard-shortcuts.xml
   +      <property name="&lt;Super&gt;Tab" type="string" value="next_workspace_key"/>
   +      <property name="&lt;Shift&gt;&lt;Super&gt;ISO_Left_Tab" type="string" value="prev_workspace_key"/>
   w/profiles/xfce/lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
   -    <property name="wrap_cycle" type="bool" value="false"/>
   +    <property name="wrap_cycle" type="bool" value="true"/>
   ```
4. Now we can revert all changes and manually re-apply just the desired changes
   ```bash
   $ git checkout profiles/xfce/lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
   $ git checkout profiles/xfce/lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml

   $ cd ~/Projects/cyberlinux/profiles/xfce
   $ find . -name xfwm4.xml*
   ./lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
   ./server/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml_server

   $ find . -name xfce4-keyboard-shortcuts.xml*
   ./lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
   ```


### Default wallpaper <a name="default-wallpaper"/></a>
Wallpaper is stored at `/usr/share/backgrounds`. Both `Xfce` and `Nitrogen`, in the Openbox profile, 
have been configured to source that directory for wallpaper.

Xfce's wallpaper is set in the `~/.config/xfce4/xfce-perchannel-xml/xfce4-desktop.xml` file per 
monitor per workspace which doesn't translate well to a pre-installed default. We don't know what an 
end user's monitor is so the only way I've been able to do this is to set a default wallpaper image 
for all common monitor types which is cumbersome and annoying but it works.

Example for our new `theater` deployment:
1. Navigate to the Xfce profile root:
   ```bash
   $ cd cyberlinux/profiles/xfce
   ```
1. Create the theater directory path
   ```bash
   $ mkdir -p mkdir -p theater/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
   ```
2. Copy the lite example to the theater deployment using deployment specific suffix:
   ```bash
   $ cp lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml theater/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml.theater
   ```
3. Edit `theater/etc/skel/.config/xfce4/xfce-perhannel-xml/xfce4-desktop.xml.theater` and search replace the `last-image` value to your new image e.g. `theater_curtains1.jpg` made available in `profiles/standard/x11/usr/share/backgrounds`
4. Modify the post install script `theater.install` adding the install instructions
   ```bash
   # Set wallpaper
   pushd /etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml
   mv xfce4-desktop.xml.theater xfce4-desktop.xml
   popd
   ```

### LCD clock style <a name="lcd-clock-style"/></a>
1. Change the clock widget to be the LCD style via right clicking on it and choosing `Properties`
2. Copy `~/.config/xfce4/xfconf/xfce-perhannel-xml/xfce4-panel.xml` to
   `~/Projects/cyberlinux/profiles/xfce/lite/etc/skel/.config/xfce4/xfconf/xfce-perhannel-xml/xfce4-panel.xml`
3. Run a diff `git diff` to find the target changes
   ```diff
       <property name="plugin-12" type="string" value="clock">
   -      <property name="mode" type="uint" value="2"/>
   +      <property name="mode" type="uint" value="4"/>
   +      <property name="show-military" type="bool" value="false"/>
   +      <property name="show-meridiem" type="bool" value="false"/>
        </property>
   ```
4. Now we can revert all changes and manually re-apply just the desired changes
   ```bash
   $ git checkout profiles/xfce/lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml

   $ cd ~/Projects/cyberlinux/profiles/xfce
   $ find . -name xfce4-panel.xml*
   ./lite/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml
   ./netbook/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml_netbook
   ./desktop/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml_desktop
   ./theater/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml_theater
   ```

## Xorg <a name="xorg"/></a>
Xorg configuration is controlled by config files dropped in the `/etc/X11/xorg.conf.d` directory

### Default Resolution <a name="default-resolution"/></a>
1. Navigate to your target profile directory
   ```bash
   $ cd cyberlinux/profiles/xfce
   ```
2. Create the Xorg config directory for your target deployment
   ```bash
   $ mkdir -p theater/etc/X11/xorg.conf.d
   ```
3. Create the default resolution configuration file `theater/etc/X11/xorg.conf.d/10-display.conf`
   ```
   Section "Screen"
       Identifier "Screen0"
       SubSection "Display"
           Depth 24
           Modes "1920x1080"
       EndSubSection
   EndSection
   ```

# Backlog <a name="backlog"/></a>
* Document profile syntax

<!-- 
vim: ts=2:sw=2:sts=2
-->
