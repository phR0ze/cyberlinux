cyberlinux WINE documentation
====================================================================================================
<img align="left" width="48" height="48" src="../art/logo_256x256.png">
Documentation for various wine related settings
<br><br>

### Quick links
* [.. up dir](..)
* [Overview](#overview)
* [Install Wine](#install-wine)
* [Wine Prefixes](#wine-prefixes)
  * [Create new 32bit Wine Prefix](#create-new-32bit-wine-prefix)
  * [Delete a Wine prefix](#delete-a-wine-prefix)
  * [Reset dll overrides](#reset-dll-overrides)
  * [Audio problems](#audio-problems)
  * [Video problems](#video-problems)
    * [Wine GLXBadFBConfig](#wine-glxbadfbconfig)
    * [Ensure you have 32-bit drivers](#ensure-you-have-32bit-drivers)
* [Warcraft 2 Battle.net Edition](#warcraft-2-battle-net-edition)
  * [Warcraft 2 prerequisites](#warcraft-2-prerequisites)
  * [Install Warcraft 2](#install-warcraft-2)
  * [Host Warcraft 2 LAN multi player game](#host-warcraft2-lan-multi-player-game)

# Overview <a name="overview"/></a>
Wine uses the `WINEPREFIX` as separate C-drive/registries. Typically you'll want one per app unless
the apps are sharing configuration or depend on each other.

# Install Wine <a name="install-wine"/></a>
https://wiki.archlinux.org/index.php/wine

```bash
# Install Wine
$ sudo pacman -S winetricks wine-gecko wine-mono zenity

# Ensure 32-bit dependencies are installed
$ sudo pacman -S lib32-freetype2 lib32-libpulse lib32-mpg123 lib32-libusb
```

# Wine Prefixes <a name="wine-prefixes"/></a>
Wine prefixes, a.k.a wine bottle, are simply a folder where wine will store all files like the
registry, apps etc... for your session. Often it is useful to have a prefix per application if the
target application needs a specific version of windows and a lot of custom settings and fixes.

## Create new 32bit Wine Prefix <a name="createa-a-new-32bit-wine-prefix"/></a>
Wine by default creates a single `~/.wine` prefix as 64bit but often its old Windows apps were trying
to run so we'll need a new 32bit prefix created.

```bash
$ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/<prefix> wincfg
```

## Delete a Wine prefix <a name="delete-a-wine-prefix"/></a>
Since a wine prefix is just a directory, all you need to do is delete the directory associated with
it. Typically they will be stored in `~/.wine` or `~/.wine/prefixes`.

```bash
$ rm -rf ~/.wine/prefixes/steam
```

## Reset dll overrides <a name="reset-dll-overrides"/></a>
```
$ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 winetricks alldlls=default
```

## Audio problems <a name="audio-problems"/></a>
If you don't see your audio devices show up in a 32bit prefix under the `winecfg > Audio` tab its
probably because you need to install the 32bit drivers for your devices.

Install the pulse audio 32bit driver:
```bash
$ sudo pacman -S lib32-libpulse
```

## Video problems <a name="video-problems"/></a>

### Wine GLXBadFBConfig <a name="wine-glxbadfbconfig"/></a>
[Wine GLXBadFBConfig bug](https://bugs.winehq.org/show_bug.cgi?id=50859#c11)

**Workaround:**
```bash
# Prefix your wine commands with the mesa environment variable override
$ MESA_GL_VERSION_OVERRIDE=4.5 WINEARCH=win32 ....
```

### Ensure you have 32-bit drivers <a name="ensure-you-have-32bit-drivers"/></a>
If you get video issues in a 32 prefix ensure you have the 32bit drivers

Example:
```bash
$ sudo pacman -S lib32-nvidia-340xx-utils lib32-nvidia-340xx
```

# Warcraft 2 Battle.net Edition <a name="warcraft-2-battle-net-edition"/></a>

* [Lutris Script](https://lutris.net/games/install/12552/view)
* [Wine HQ guide](https://appdb.winehq.org/objectManager.php?sClass=version&iId=592)

## Warcraft 2 prerequisites <a name="warcraft-2-prerequisites"/></a>
1. Install [see Install Wine](#install-wine)
2. Purchase Warcraft 2 from [GOG](https://www.gog.com)
3. Download using the `Download offline backup game installers` option
4. Create a new win32 winprefix
   ```bash
   $ mkdir -p ~/.wine/prefixes
   $ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 winecfg
   ```

5. Set the target windows version:  
   a. Navigate to the `Applications` tab  
   b. Choose `Windows Version: >Windows 7` at the bottom  

6. Set the default audio devices:  
   a. Navigate to the `Audio` tab  
   b. Select your audio devices `System default` is fine for systems with a single audio output  

7. Close Wine configuration by clicking `OK`

## Install Warcraft 2 <a name="install-warcraft-2"/></a>
By default the GOG installer will install to `C:\GOG Games\Warcraft II BNE` which with our prefix
will be `~/.wine/prefixes/warcraft2/drive_c/GOG\ Games/Warcraft\ II\ BNE/`

1. Launch the installer
   ```bash
   $ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 wine ./setup_warcraft_ii_2.02_v4_\(28734\).exe
   ```
2. Select Setup Language: `English` and click `OK`
3. Check `Yes, I have read and accept EULA` then click `Install`
4. Click `Exit`

5. Setup Direct X windowing as desired:  
   a. Launch the direct x config tool  
      ```
      $ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 wine ~/.wine/prefixes/warcraft2/drive_c/GOG\ Games/Warcraft\ II\ BNE/dxcfg.exe
      ```
   b. Set `Display mode> 1280x1024 85Hz`  
   c. Set `Presentation >Windowed`  
   d. Set `Enhancements >Anisotropic filtering > Enabled - AF 16x`    
   e. Set `Enhancements >Antialiasing > Enabled - MSAA 8x`    
   f. Click `Save` then `Exit`  

6. We need to use the `wsock32.dll` supplied by GOG for IPX to work. No copying or moving of the
   `wsock32.dll` is needed. Instead simply set the override to not use the builtin one and it will
   automatically find the correct one and work. 
   a. Launch wine config to override the dll  
      ```
      $ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 winecfg
      ```
   b. Select the `Libraries` tab  
   c. Enter `wsock32` into the `New override for library` drop down  
   d. Click `Add` accept the warning and you'll see `wsock32(native,builtin)` in the `Existing Overrides`  
   e. Click `Apply` and `OK`  

7. Setup IPX Configuration:  
   a. Launch the IPX configuration binary sitting along side the game files:
      ```
      $ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 wine ~/.wine/prefixes/warcraft2/drive_c/GOG\ Games/Warcraft\ II\ BNE/ipxconfig.exe
      ```
   b. Select your `Primary Interface` e.g. `enp1s0`  
   c. Select your `Network adapters` e.g. `enp1s0`  
   d. Ensure `Enable Interface` is checked  
   e. Ensure `Enable Windows 95 SO_BROADCAST bug` is checked  
   f. Ensure `Automatically create Windows Firewall exceptions` is checked  
   g. Click `Apply` then `OK`  

## Host Warcraft 2 LAN multi player game <a name="host-warcraft2-lan-multi-player-game"/></a>
1. Launch warcraft 2:
   ```
   $ WINEARCH=win32 WINEPREFIX=~/.wine/prefixes/warcraft2 wine ~/.wine/prefixes/warcraft2/drive_c/GOG\ Games/Warcraft\ II\ BNE/Warcraft\ II\ BNE_dx.exe
   ```
2. Click through the intro
3. Navigate to `Multi Player Game > Enhanced >IPX network`
4. Click `Connect`
5. Enter your desired username e.g. `foobar`
6. Click `Create Game`
7. Have other players follow same process then `Join Game`

<!-- 
vim: ts=2:sw=2:sts=2
-->
