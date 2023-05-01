Multimedia
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documenting various multimedia technologies
<br><br>

### Quick links
* [.. up dir](https://github.com/phR0ze/cyberlinux)
* [3D Computer Graphics](#3d-computer-graphics)
  * [Sweet Home 3D](#sweet-home-3d)
* [Audio](#audio)
  * [Backup an audio CD](#backup-an-audio-cd)
  * [Convert WAV to MP3](#convert-wav-to-mp3)
* [Images](#images)
  * [Convert HEIC to JPEG](#convert-heic-to-jpeg)
* [Screen Recorder](#screen-recorder)
* [Video](#video)
  * [Backup a Blu-ray](#backup-a-bluray)
  * [Backup a DVD](#backup-a-dvd)
  * [Extracting specific chapters](#extracting-specific-chapters)
  * [Burning an DVD](#burning-an-dvd)
  * [Encode Blu-ray to x265](#encode-blu-ray-to-x265)
  * [Encode DVD to x265](#encode-dvd-to-x265)
  * [Cut Video w/out Re-encoding](#cut-video-without-re-encoding)
  * [Lossless Rotate](#lossless-rotate)
  * [Strip GPS Location](#strip-gps-location)

# 3D Computer Graphics
* Sweet Home 3d
* FreeCAD
* LibreCAD
* OpenSCAD
* Remo 3d
* SAS offerings
  * [Sketchup Free](https://app.sketchup.com)
  * [OnShape Free](https://www.onshape.com/en/products/free)

## FreeCAD
General purpose CAD. With the BIM plugin you can get a lot of architecture support similar to Revit 
or Sketchup.

**References**
* BIM - Building Information Modeling
* [BIM with FreeCAD playlist](https://www.youtube.com/playlist?list=PLmKdGVtV5Vnt2cj4IZIv9FM39QHaE1ZaU)
* [BIM with FreeCAD - Introduction](https://www.youtube.com/watch?v=rkWOFQ2fGZQ)
* [House using ARCH workbench](https://www.youtube.com/watch?v=RduDsY_8kJ8)
* [FreeCAD Tuts](https://www.youtube.com/playlist?list=PLDd21g-eSHwkkxVOfVmR8ObpPN5QbL7ye)

### FreeCAD competitors
* Revit
* Sketchup
* Rymn


### Install and configure FreeCAD
1. Install FreeCAD
   ```bash
   $ sudo pacman -S freecad
   ```
2. Install addons, navigate to `Tools > Addon manager`
   * `BIM` workbench for Building Information Modeling for architecture
   * `Render` allows you to use external renders to produce nice images
   * `FreeCAD-ArchTextures` provides ability to texture models in FreeCAD directly
   * `dxf-library` to export dxf file format
   * `flamingo` collection of tools to work with metalic structures
   * `parts_library` collection of pre-made objects
3. Restart FreeCAD
4. BIM Welcome screen you can revist it at `Help > BIM Welcome screen`
   1. Navigate to the `BIM` workbench
   2. Work through the BIM setup wizard
   3. Choose `Fill with default values` as `US/Imperial`
   4. Choose `Preferred working units` as `feet`
5. Configure Settings, navigate to `Edit > Preferences > General > Units`
   1. Choose `Unit System` as `Building US (ft-in/sqft/cft)`
6. Switch to Revit mouse controls
   1. Bottom right where you see `CAD` change that to `Revit`
   2. Hover over your selection and it will show you how to use the mouse
   3. Also click the same menu and select `Settings >Orbin Style >Turntable`
   4. Press Shift and hold middle mouse button to pan
   5. Hit `Home` to return to home view
 
### Workbenches
Workbenches in FreeCAD are a collection of tools that can be selected to focus on different aspects 
of CAD work. You can customize workbenches and move tools from one to another.

* `Arch` - contains a lot of tools for working with Architecture
* `BIM` - addon for Building Information Modeling tools similar to Revit, AchiCAD, Tkla, AllPlan or BricsCAD

### BIM Workbench
The BIM workbench is essentially the Arch workbench with additional tooling and settings to help with 
BIM.

## Sweet Home 3D

# Audio

## Backup an audio CD
1. Install `Asunder`
   ```bash
   $ sudo pacman -S asunder
   ```
2. Configure WAV uncompressed
   1. Click `Preferences`
   2. Select the `Encode` tab
   3. Check the `WAV (uncompressed)` option
3. Configure output directory
   1. Select the `General` tab
   2. Select the `Destination folder`
   3. Unchck `Create M3U playlist`
3. Turn on error correction (will slow it way down)
   1. Navigate to the `Advanced` tab
   2. Uncheck at the bottom the `Faster ripping (no error correction)` option

## Convert WAV to MP3
1. Install `Sound Konverter`
   ```bash
   $ sudo pacman -S soundkonverter
   ```
2. Launch `soundkonverter`
3. Navigate to `File >Add folder...` and select your target audio file directory
4. Click `Proceed` to have it automatically select all audio file types
5. Set `Qualtity: High`, `Destination` directory and hit `OK`
6. Click `Start`

# Images

## Convert HEIC to JPEG
Image conversions are easily done with `imagemagick`
```bash
# Install imagemagick
$ sudo pacman -S imagemagick

# Convert all heic pix to jpeg
$ mogrify -format jpg *.heic

# Delete the original heic files
$ rm *.heic
```

# Screen Recorder
The two best are ***SimpleScreenRecorder*** and ***RecordMyDesktop***

1. Install: `sudo pacman -S simplescreenrecorder`
2. Launch: `simplescreenrecorder`
3. Click ***Continue***
4. Click ***Record a fixed rectangle*** then ***Select window...***
5. Click the content area of the window to be recorder to only record the content
6. Uncheck ***Record cursor***
7. Uncheck ***Record audio***
8. Click ***Continue***
9. Click ***Browse*** to choose a file to record as
10. Choose ***Preset*** as ***faster***
11. Click ***Continue***
12. Click ***Start Recording***



# Video

## Backup a Blu-ray
Instructions for backing up your legally purchased personal collection.

1. Build and install the latest bits
   ```bash
   $ yay -Ga makemkv
   $ cd makemkv
   $ makepkg -s
   $ sudo pacman -U makemkv-1.16.5-1-x86_64.pkg.tar.zst
   $ sudo pacman -S ccextractor
   ```

2. Register makemkv
   a. Launch `makemkv`  
   b. Navigate to the [MakeMKV Forum](https://forum.makemkv.com/forum/viewtopic.php?t=1053)  
   c. Use the key in the app at `Help >Register`  

3. Backup your Blu-ray
   a. Hit thie big button to open up the Blu-ray  
   b. Setup the output directory on the right  
   c. Uncheck everything but the largest title on the left  
   d. Drill in and uncheck any audio and sub-title languages you don't want  
   e. Hit the `Save selected titles` button on the right  

## Backup a DVD
Instructions for backing up your legally purchased personal collection.

1. First install the tooling:
   ```bash
   $ sudo pacman -S dvdbackup libdvdcss
   ```

2. Determine the name of your optical drive:
   ```bash
   $ lsblk
   NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
   sr0     11:0    1   7.2G  0 rom  
   ```

3. Simply clone the entire dvd to make a backup of your personal collection:
   ```bash
   $ dvdbackup -i /dev/sr0 -o <movie-name> -M
   ```

4. Create an ISO from the backup:
   ```bash
   # Create the AUDIO_TS if it doesn't exist, helps with convetional dvd player compatibility
   $ mkisofs -dvd-video -o image.iso ~/dir_containing_video_ts
   ```

5. Verify that your iso is playable:
   ```bash
   $ mplayer dvd::// -dvd-device image.iso
   ```

## Extracting specific chapters
Note often when doing a full dvd backup the first chapter will be the menu

1. Follow the instructions from [Backup a DVD](#backup-a-dvd) to get a local copy to work with

2. Determine which titles you want to extract from:
   ```bash
   # -i needs to refer to the location where the VIDEO_TS is stored
   $ dvdbackup -i backup -I
   ...
   Title set 1
     The aspect ratio of title set 1 is 4:3
   	 Title set 1 has 1 angle
   	 Title set 1 has 1 audio track
   	 Title set 1 has 0 subpicture channels
   
   	 Title included in title set 1 is
   	   Title 1:
   			 Title 1 has 22 chapters
   			 Title 1 has 2 audio channels
   ```

2. Now extract the chapters you'd like e.g. chapter 1:
   ```bash
   # -s start chapter 
   # -e start chapter 
   # -n output directory name to use
   $ dvdbackup -i backup -t 1 -s 1 -e 1 -n Chapter-01
  
   # Ignore the libdvdread
   # libdvdread: Couldn't find device name
   ```

3. Use bash to extract them all skipping menu and offsetting numbers:
   ```bash
   $ for i in {1..21}; do dvdbackup -i backup -t 1 -s $((i+1)) -e $((i+1)) -n "Chapter-0${i}"
   ```

## Burning a DVD
1. Use step 2 from [Backup a DVD](#backup-a-dvd) to determine your device name

2. Use `growisofs` to burn the image to a disc:
   ```bash
   $ growisofs -dvd-compat -Z /dev/sr0=image.iso
   ```

## Encode Blu-ray to x265
1. Install: `sudo pacman -S handbrake`
2. Launch: `ghb`
3. Configure main page settings  
   a. Click `Open Source`  
   b. Navigate to the target `mkv` file and double click it  
   c. Set `Preset` to `Official > General >Super HQ 1080p30 Surround`  
   d. Change `Format` to `Matroska (avformat)`  
   e. Change the `Save As` location to `~/Downloads`  
4. Select the `Dimensions` tab  
   a. Ensure that `Automatic` is selected  
5. Select the `Video` tab  
   a. Ensure that `Video Encoder` is set to `H.265 10-bit (x265)`  
   b. Set `Framerate` to `Same as source` and enable `Variable Framerate`  
   c. Set `Constant Quality` value to `RF: 20` and `Preset` to `slower`  
   d. Set `Tune` to `animation` if applicable  
6. Select the `Audio` tab  
   a. Ensure the `Track List` includes your desired language  
7. Select the `Subtitles` tab  
   a. Ensure the `Track List` says `Foreign Audio Scan -> Burned into Video (Forced Subtitles Only)`  
8. Name the output file  
   a. e.g. `Title (Year) [1080p.x265.AC3.rf20].mkv`  

## Encode DVD to x265
1. Install: `sudo pacman -S handbrake`
2. Launch: `ghb`
3. Configure main page settings  
   a. Click `Open Source`  
   b. Navigate to the `VIDEO_TS` directory and click `Open`  
   c. Set `Preset` to `Official >Matroska >H.265 MKV 480p30`  
4. Select the `Dimensions` tab  
   a. Ensure that `Auto Crop` is selected  
5. Select the `Video` tab  
   a. Ensure that `Video Encoder` is set to `H.265(x265)`  
   b. Set `Framerate` to `Same as source` and enable `Variable Framerate`  
   c. Set `Constant Quality` value to `RF: 18` and `Preset` to `slower`  
   d. Set `Tune` to `animation` if applicable  
6. Select the `Audio` tab  
   a. Ensure the `Track List` includes your desired language  
7. Select the `Subtitles` tab  
   a. Ensure the `Track List` says `Foreign Audio Scan -> Burned into Video (Forced Subtitles Only)`  
8. Name the output file  
   a. e.g. `Title (Year) [480p.x265.AC3.rf19].mkv`  

## Cut Video w/out Re-encoding
1. Install: `sudo pacman -S losslesscut-bin`
2. Launch: `losslesscut`
3. Drag and drop your `mkv` file from [Encode DVD to x265](#encode-dvd-to-x265) into the main window
4. Accept the prompt to `Import chapters`
5. Right click on the first chapter and select `Jump to cut start`
6. Now remove chapters to include in the segment you want up until the last one you want
7. Now use the `Set cut start to current position` button to expand the last piece up to the start
8. Right click on this new expanded chapter and choose `Include ONLY this segment in export`
9. Click `Export` button validate settins and click `Export` again

## Lossless Rotate
This just sets the metadata for the video. Its up to your player to play it with the correct rotation

Rotate clockwise by 90 degrees
```bash
$ ffmpeg -i $INPUTVIDEO -metadata:s:v rotate="90" -codec copy $OUTPUTVIDEO
```

Rotate clockwise by 270 degrees
```bash
$ ffmpeg -i $INPUTVIDEO -metadata:s:v rotate="270" -codec copy $OUTPUTVIDEO
```

## Strip GPS Location
1. Install: `sudo pacman -S perl-image-exiftool`
2. List out the existing exif info: `exiftool <file>`
3. Remove gps exif data: `exiftool -all= <file>`

<!-- 
vim: ts=2:sw=2:sts=2
-->
