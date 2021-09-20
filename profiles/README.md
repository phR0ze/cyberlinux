cyberlinux profiles
====================================================================================================

<img align="left" width="48" height="48" src="../art/logo_256x256.png">
Profiles in <b><i>cyberlinux</i></b> is a term used to describe the set of installable deployments 
that will show up on your multi-boot ISO once the build completes. It also refers to the associated 
directory at `profiles/<PROFILE-NAME>` that contains the `profile.json` describing the deployments 
that are to be built as well as the `PKGBUILD` describing all the packages that the profile will 
build during ISO construction and can later be used to upgrade existing deployments.

### Quick links
* [.. up dir](..)
* [profile.json](#profile-json)
* [Backlog](#backlog)

---

# profile.json <a name="profile-json"/></a>
The `profile.json` is the heart of the profile describing the installable deployments that will show 
up on your multi-boot ISO when the build completes. 

# Backlog <a name="backlog"/></a>
* Document profile syntax

<!-- 
vim: ts=2:sw=2:sts=2
-->
