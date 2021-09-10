Changelog
====================================================================================================
<img align="left" width="48" height="48" src="../art/logo_256x256.png">
Simply documenting changes I've made to the distro and the dates the changes were rolled out for 
reference. 
<br><br>

### Quick Links
* [.. up dir](README.md)

### Testlog <a name="testlog"/></a>
* xfce:lite: customized Xfce default menus
* xfce:lite: added `icons/hicolor/scalable/categories/cyberlinux.png` and set as menu icon
* xfce:lite: `lockscreen` should be invoked before sleep so you have to login on wake
* xfce:lite: `Super+L` locks screen and xfce4-session has `lockscreen` set
* make theater deployment based on desktop

### Changelog <a name="changelog"/></a>
* 2021-09-09:: xfce:lite: switched to Xfwm for better tiling and integration with Xfce
* 2021-09-09:: xfce:lite: set Arc Dark theme for GTK and Xfwm
* 2021-09-09:: xfce:lite: integrated power manager for screen brightness
* 2021-09-09:: xfce:lite: configured standard window shortcuts
* 2021-09-09:: xfce:lite: set keyboard repeat to `200` and speed to `80`
* 2021-09-09:: xfce:lite: set xfce4-terminal dropdown `xfce4-terminal --drop-down`
* 2021-09-09:: xfce:lite: set xfce4-terminal default settings via `~/.config/xfce4/terminal/terminalrc`
* 2021-09-09:: xfce:lite: set Filezilla initial configs
* 2021-09-07:: now supporting profiles depending on each other
* 2021-09-06:: openbox:lite: fixed powerline default showing up on right
* 2021-08-16:: openbox:lite: Fixed keyboard repeat rate with lxsession config
* 2021-08-11:: openbox:lite: Replaced oblogout with arcologout a simple clean overlay logout app
* 2021-08-11:: standard:x11: Powerline font doesn't look right in bash - solved set fontconfig
* 2021-08-10:: Replaced cinnamon-screensaver with i3lock-color
* 2021-08-08:: Migrated to nvim via cyberlinux-nvim
* 2021-08-04:: Install yay from blackarch into the shell deployment
* 2021-09-04:: Set standard language defaults: `LANG = "en_US.UTF-8"`
* 2021-09-04:: Passwords need to be SHA512 to avoid being flagged by pam policies

<!-- 
vim: ts=2:sw=2:sts=2
-->
