Changelog
====================================================================================================
<img align="left" width="48" height="48" src="../art/logo_256x256.png">
Simply documenting changes I've made to the distro and the dates the changes were rolled out for 
reference. 
<br><br>

### Quick links
* [.. up dir](..)

### Testlog <a name="testlog"/></a>
* 2021.11.24
  * Fix for using the wrong `cups.service`
* 2021.11.23
  * Set xfce clock to LCD style
  * Configure xfce workspaces cycling with Super+Tab and Super+Shift+Tab

### Changelog <a name="changelog"/></a>
* 2021.11.24
  * VSCode powerline console fonts are not working
    * Build and publish `nerd-fonts-inconsolata-go` to cyberlinux-repo
    * Add `nerd-fonts-inconsolata-go` to x11 base
    * Add vscode configs for `editor` font to be `Inconsolata-g`
    * Add vscode configs for `terminal` font to be `InconsolataGo Nerd Font Mono`
* 2021.11.21
  * VSCode Ctrl+Shift+r run combination
  * VSCode Ctrl+Shift+t test combination
* 2021.09.16
  * xfce:desktop: added desktop launch items
  * xfce:netbook: added desktop launch items
  * openbox:desktop: added image scan menu entry
  * standard:desktop: switch synergy for barrier
  * standard:desktop: added veracrypt
  * xfce:netbook: fix for kvantum icon only in settings
  * standard:x11: fix for dconf defaults in local.d
  * standard:base: remove dependency on BlackArch
  * standard:desktop: vscode configs should now be the correct location ~/.config/Code
  * standard:netbook: added kvantum manager
  * standard:netbook: added Zoom to the network menu
  * standard:netbook: added Cheese for webcam control
  * openbox:lite: set Arc-Dark gtk theme as default
* 2021.09.14
  * xfce:netbook: refactor more into the base x11 layer
* 2021.09.13
  * xfce:netbook: configure bluetooth
  * xfce:netbook: closing lid puts it in sleep mode with autolock on wake
  * xfce:netbook: screen dims when left sitting
  * xfce:netbook: wifi via the nm-applet worked out of the box
  * xfce:netbook: display brightness also works well
  * xfce:netbook: battery icon and status looks good
  * xfce:netbook: configured conky
  * installer: fix for autologin
  * openbox:server: network manager applet with openvpn
  * installer: network manager static IP support
  * xfce:netbook: added bluetooth management
  * xfce:lite: removed pnmixer
  * xfce:lite: set move and resize window hot keys to `Super+Enter` and `Super+Enter+Alt`
* 2021.09.11
  * standard:base: link `/run/systemd/resolve/resolv.conf` `/etc/resolv.conf`
* 2021.09.10
  * xfce:lite: customized Xfce default menus
  * xfce:lite: added `icons/hicolor/scalable/categories/cyberlinux.png` and set as menu icon
  * xfce:lite: `lockscreen` should be invoked before sleep so you have to login on wake
  * xfce:lite: `Super+L` locks screen and xfce4-session has `lockscreen` set
* 2021.09.09
  * xfce:lite: switched to Xfwm for better tiling and integration with Xfce
  * xfce:lite: set Arc Dark theme for GTK and Xfwm
  * xfce:lite: integrated power manager for screen brightness
  * xfce:lite: configured standard window shortcuts
  * xfce:lite: set keyboard repeat to `200` and speed to `80`
  * set xfce4-terminal dropdown `xfce4-terminal --drop-down`
  * set xfce4-terminal default settings via `~/.config/xfce4/terminal/terminalrc`
  * set Filezilla initial configs
* 2021.09.07
  * now supporting profiles depending on each other
* 2021.09.06
  * openbox:lite: fixed powerline default showing up on right
* 2021-08-16
  * openbox:lite: Fixed keyboard repeat rate with lxsession config
* 2021-08-11
  * openbox:lite: Replaced oblogout with arcologout a simple clean overlay logout app
* 2021-08-11
  * standard:x11: Powerline font doesn't look right in bash - solved set fontconfig
* 2021-08-10
  * Replaced cinnamon-screensaver with i3lock-color
* 2021-08-08
  * Migrated to nvim via cyberlinux-nvim
* 2021-08-04
  * Install yay from blackarch into the shell deployment
* 2021.09.04
  * Set standard language defaults: `LANG = "en_US.UTF-8"`
  * Passwords need to be SHA512 to avoid being flagged by pam policies

<!-- 
vim: ts=2:sw=2:sts=2
-->
