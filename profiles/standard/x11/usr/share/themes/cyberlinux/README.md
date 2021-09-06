# cyberlinux theme
cyberlinux is a dark GTK2/GTK3/openbox modern flat theme with a blue edge.  

***cyberlinux*** blue: **#39aef4**

## Install/Usage
-   Copy to `/usr/share/themes/` or `~/.local/share/themes`
-   Launch lxappearance and select and apply it
-   Set Icon theme: Paper

## OpenBox Theme Support
http://openbox.org/wiki/Help:Themes

Themes are stored in ***/usr/share/themes***

### Theme file structure
```
ThemesDirectory  (such as /usr/share/themes)
 |
 +-> ThemeName  (This is the name of the theme, e.g. cyberlinux)
      |
      +-> openbox-3  (This the type of the theme - it's for Openbox 3!)
           |
           |-> themerc  (This is the main theme file, documented in this page)
           |
           |-> max.xbm  (These are optional xbm masks for the titlebar buttons)
           |-> close.xbm
           ...
           +-> shade.xbm
```

### Textures
Determines the visual look of an element, not case sensative

`Parentrelative | ((Solid | Gradient Gradient-Type) [Border] [Interlaced]`

* **Parentrelative** means inherits its colors from behind effectively transparent
* **Solid** means that the background of the textures is filled with a single color
* **Border** can be used on both solid and gradient textures. Valid options for the border are
***Flat***, ***Raised***, and ***Sunken***. When a border is not specified ***Raised*** is assumed.

### Button Images
The images used for the titlebar buttons and the submenu bullet are 1-bit xbm (X Bitmaps). These are
masks where 0 = clear and 1 = colored. The xbm image files are placed in the same directory as your
***themerc*** as shown in the file structure section. OpenBox has some internal defaults found in
***/usr/share/doc/openbox/xbm***. Each button image has a specific name for a specific purpose:

### Sizing Images
http://www.jasong-designs.com/2015/05/05/sizing-custom-window-icons-for-openbox/

Icons get scaled according to the font size in the titlebar. Standard sizes are 8px by 8px or 10px
by 10px. So in order for your .xbm images not to be clipped make them the standard 10x10 then
specify a larger font size in obconf.

### Maximized button
* **max.xbm** - button unpressed
* **max_toggled.xbm** - button toggled
* **max_pressed.xbm** - button pressed
* **max_disabled.xbm** - button disabled
* **max_hover.xbm** - mouse over button
* **max_toggled_pressed.xbm** - button toggled and pressed
* **max_toggled_hover.xbm** - mouse over the button in a toggled state

### Iconify button
* **iconify.xbm** - button unpressed
* **iconify_pressed.xbm** - button pressed
* **iconify_hover.xbm** - mouse over button

### Close button
* **close.xbm** - button unpressed
* **close_pressed.xbm** - button pressed
* **close_disabled.xbm** - button disabled
* **close_hover.xbm** - mouse over button
