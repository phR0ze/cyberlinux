# Samsung Chromebook 3
<img align="left" width="32" height="32" src="https://raw.githubusercontent.com/phR0ze/cyberlinux/master/art/logo_256x256.png">
Documenting information related to the <b><i>personal-celes.yml</i></b> profile<br/><br/>

## License
As called out in the [README.md](https://github.com/phR0ze/cyberlinux/tree/master/profiles) this
profile prefixed with ***personal*** uses applications with various restrictions and can not be used
commercial purposes. It is only to be used for personal use only.

## Build

### Compatible Environment
You'll need to be running cyberlinux or a compatible environment

### Build Profile
Once you have a compatible enviroment setup:

1. Clone ***cyberlinux***
    ```bash
    git clone https://github.com/phR0ze/cyberlinux.git
    ```
2. Build ***personal-celes*** profile
    ```bash
    sudo ./reduce clean build --iso-full --profile=personal-celes
    ```

## Deploy

### Prerequisites
Chromebooks are not setup for Linux out of the box however there has been some excellent work done
in this area to make Chromebooks behave like normal Linux netbooks.

1. Follow the direction found here https://wiki.galliumos.org/Installing/Preparing
2. Burn your ISO to a USB using
    ```bash
    sudo dd bs=4M if=/path/to/cyberlinux.iso of=/dev/sdx status=progress oflag=sync
    ```

### Install cyberlinux
1. Boot from USB
2. Select deployment option
3. Step through short wizard
4. Wait for ~5-10min for install to complete
5. Remove USB and reboot

## Configuration
Documenting various configuration changes that I made to support the ***celes*** platform

### Brightness
Brightness is controlled via the sysfs file ***/sys/class/backlight/intel_backlight/brightness***
with a max value of ***1200***. After a not finding an easy solution to use xbackight, simply wrote
my own script to modify the brightness directly and wired it up through openbox. See the
correspondign yaml file.

Manually change:

```bash
sudo tee /sys/class/backlight/intel_backlight/brightness <<< 800
```

### Turn off Display
***xset dpms force off***

## Notes
* https://github.com/GalliumOS/galliumos-distro/issues/270
* https://wiki.debian.org/InstallingDebianOn
