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
  * [profile.json](#profile-json)
    * [deployments](#deployments)
    * [dependencies](#dependencies)
* [Layers](#layers)
* [Guides](#guides)
  * [Deployment](#deployment)
    * [Create a new deployment](#create-a-new-deployment)
  * [Wallpaper](#wallpaper)
    * [Default Xfce Wallpaper](#default-xfce-wallpaper)
* [Backlog](#backlog)

---

# Profiles <a name="profiles"/></a>

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

## Wallpaper <a name="wallpaper"/></a>
Wallpaper is stored at `/usr/share/backgrounds`. Both `Xfce` and `Nitrogen`, in the Openbox profile, 
have been configured to source that directory for wallpaper.

### Default Xfce wallpaper <a name="default-xfce-wallpaper"/></a>


# Backlog <a name="backlog"/></a>
* Document profile syntax

<!-- 
vim: ts=2:sw=2:sts=2
-->
