cyberlinux repo documentation
====================================================================================================

<img align="left" width="48" height="48" src="../art/logo_256x256.png">
<b><i>cyberlinux</i></b> was designed to provide the unobtrusive beauty and power of Arch Linux as a
fully customized automated offline multi-deployment ISO. Using clean declarative yaml profiles,
cyberlinux is able to completely customize and automate the building of Arch Linux filesystems
which are bundled as a bootable ISO. Many common use cases are available as deployment options
right out of the box, but the option to build your own infinitely flexible deployment is yours
for the taking.

### Disclaimer
***cyberlinux*** comes with absolutely no guarantees or support of any kind. It is to be used at
your own risk.  Any damages, issues, losses or problems caused by the use of ***cyberlinux*** are
strictly the responsiblity of the user and not the developer/creator of ***cyberlinux***.

Key:
* **AUR** simply means the upstream aur package was built and added to this repo
* **Repackaged** indicates the upstream bits were customized and saved at `cyberlinux/aur/<package>`
* **Custom** indicates this package was wrote from scratch and saved at `cyberlinux/aur/<package>`

| Package                         | Version           | Purpose                
| ------------------------------- | ------------------| ------------------------------------------------------------------
| abiword-gtk2                    | 3.0.2.-3          | AUR: The non gtk2 one flickers, this one seems to be ok
| arch-install-scripts            | 22-2              | Repackaged: patched the arch-chroot to retry umount for reduce
| asterisk                        | 15.4.1-2          | Custom: asterisk telephony engine
| awf-git                         | v1.3.1.r4.gcee91. | ?
| bindip                          | 0.0.1-1           | ?
| ccextractor                     | 0.88-1            | AUR: dependency of makemkv
| chromium                        | 76.0.3809.100-4   | Custom: cyberlinux build of chromium with security enhancements
| chromium-widevine               | 1:4.10.1440.18-2  | AUR: Chromium dependency for viewing premium media content
| cinnamon-desktop                | 3.4.2-1           | Repackaged: support file for lockscreen
| cinnamon-screensaver            | 3.0.1-1           | Repackaged: keeping the old lockscreen behavior
| cinnamon-translations           | 3.4.2-1           | Repackaged: support file for lockscreen
| cri-tools                       | 1.11.1-2          | ?
| cyberlinux-config               | 0.0.3-1           | Custom: provides cyberlinux configuration files
| cyberlinux-desktop-config       | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-grub                 | 0.0.3-1           | Custom: provides cyberlinux splash screen and boot files
| cyberlinux-keyring              | 0.0.170-2         | Custom: provides cyberlinux keyring
| cyberlinux-laptop-config        | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-lite-config          | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-netbook-config       | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-plank                | 0.11.4-4          | Repackaged: modified the source with better defaults 
| cyberlinux-screenfetch          | 3.8.0-2           | Custom: cyberlinux screenfetch
| cyberlinux-server-config        | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-shell-config         | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-theater-config       | 0.0.3-1           | Custom: provides configuration for the cyberlinux desktop deployment
| cyberlinux-vim-plugins          | 0.0.2-1           | Custom: provides useful default vim plugins
| epson-inkjet-printer-escpr2     | 1.0.26-1          | AUR: Driver for the Epson WorkForce 7710 inkjet all-in-one printer
| galliumos-braswell-config       | 1.0.0-1           | AUR: Braswell configuration files for Samsung 3 Chromebook
| google-cloud-sdk                | 243.0.0-1         | ?
| helm                            | 2.14.0-1          | ?
| idesk                           | 0.7.5-8           | AUR: desktop icon support
| iksemel                         | 1.5-1             | AUR: FreeSWITCH dependency
| imagescan-plugin-networkscan    | 1.1.2-1           | AUR: Scanner driver for Epson WorkForce 7710 inject all-in-on printer
| input-wacom-dkms                | 0.39.0-1          | AUR: wacom input driver
| inxi                            | 3.0.36-2          | AUR: Low level cli tool for device configuration discovery
| jd-gui                          | 1.6.3             | Repackaged: patched with dark theme and java font fix
| kubeadm                         | 1.11.2-2          | ?
| kubecni                         | 0.7.2-2           | ?
| kubectl                         | 1.11.2-2          | ?
| kubelet                         | 1.11.2-2          | ?
| lib32-freetype2                 | 2.8-2             | ?
| lib32-nvidia-340xx-utils        | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| lib32-opencl-nvidia-340xx       | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| libblockdev                     | 2.22-2            | Repackaged: recompiled ABS with `--without-lvm` to remove the lvm2 dependency
| libxnvctrl-340xx                | 340.107-2         | Repackaged: provides libxnvctrl used by conky
| light                           | 1.1.2-1           | AUR: file size ui tool
| makemkv                         | 1.14.4-1          | Repackaged version making ccextractor a default dependency
| mkinitcpio-vt-colors            | 1.0.0-1           | Custom: provides kernel output coloring on boot
| mycli                           | 1.23.2-1          | AUR: A terminal client for MySQL with AutoCompletion and SyntaxHighlighting
| numix-frost-themes              | 3.6.6-1           | ?
| nvidia-340xx                    | 340.107-92        | AUR: supports the Quadro FX 3800 and other older cards
| nvidia-340xx-dkms               | 340.107-92        | AUR: supports the Quadro FX 3800 and other older cards
| nvidia-340xx-settings           | 340.107-2         | AUR: supports the Quadro FX 3800 and other older cards
| nvidia-340xx-utils              | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| opencl-nvidia-340xx             | 340.107-4         | AUR: supports the Quadro FX 3800 and other older cards
| openvpn-update-systemd-resolved | 1.2.6-1           | ?
| paper-icon-theme                | 1.4.0-1           | ?
| php                             | 7.1.12-2          | ?
| php-apache                      | 7.1.12-2          | ?
| php-gd                          | 7.1.12-2          | ?
| php-sqlite                      | 7.1.12-2          | ?
| pjproject                       | 2.7-1             | ?
| pnmixer                         | 0.7.2-1           | ?
| postman-bin                     | 6.1.3-2           | ?
| powerline-gitstatus             | 1.3.1-1           | Custom: provides gitstatus in PS1 using powerline
| python-cli_helpers              | 2.1.0-1           | AUR: supports `mycli`
| ruby-amatch                     | 0.4.0-1           | ?
| ruby-byebug                     | 11.0.0-1          | ?
| ruby-coderay                    | 1.1.2-3           | ?
| ruby-filesize                   | 0.2.0-3           | ?
| ruby-method\_source             | 0.9.2-3           | ?
| ruby-net-scp                    | 1.2.1-3           | ?
| ruby-net-sftp                   | 2.1.2-2           | ?
| ruby-net-sftp                   | 2.1.2-3           | ?
| ruby-net-ssh                    | 4.2.0-3           | ?
| ruby-nub                        | 0.1.2-1           | ?
| ruby-pry                        | 0.12.2-1          | ?
| ruby-pry-byebug                 | 3.7.0-1           | ?
| ruby-rest-client                | 2.0.2-3           | ?
| ruby-themoviedb                 | 1.0.1-1           | ?
| systemd-docker                  | 0.2.1-1           | ?
| teamviewer                      | 13.2.13582-1      | All-In-One Software for Remote Support and Online Meetings
| termcap                         | 1.3.1-6           | ?
| tiny-media-manager              | 2.9.16-1          | AUR: Kodi compatible media manager
| ttf-google-fonts-fun            | 1.0.0             | Repackaged: some of the script and sans serif fun fonts
| ttf-google-fonts-work           | 1.0.0             | Repackaged: includes the same fonts as typewolf did
| ttf-inconsolata-g               | 20090213-3        | AUR: excellent mono space coding font
| ttf-ms-fonts                    | 2.0-10            | AUR: old venerable Microsoft fonts
| ttf-nerd-fonts-symbols          | 2.0.0-2           | AUR: font symbols useful for powerine etc...
| vdhcoapp-bin                    | 1.3.0-2           | Repackaged: Video Download Helper's companion app, simply bumped the version
| virtualbox-ext-oracle           | 6.0.4-1           | AUR: extensions for virtualbox
| visual-studio-code-bin          | 1.34.0-2          | AUR: excellent development IDE
| vivaldi                         | 2.5.1525.48-1     | An advanced browser made with the power user in mind
| vpnctl                          | 0.0.62-1          | ?
| vundle                          | 0.10.2-2          | ?
| winff                           | 1.5.5+f721e4d-1   | AUR: GUI for ffmpeg
| wpa\_gui                        | 2.6-1             | Custom: A Qt frontend to wpa\_supplicant
| xcursor-numix-frost             | 0.9.9-4           | Custom: X-Cursor theme for use with numix products
| xnviewmp                        | 0.89-1            | AUR: An efficient multimedia viewer, browser and converter
| zoom                            | 2.8.252201.0616-1 | AUR: Video Conferencing and Web Conferencing Service
