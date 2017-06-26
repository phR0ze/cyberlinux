# GFXBoot theme inspired from Manjaro Linux

## Compile
The ***gfxboot*** package depends on and will automatically pull in the ***cpio*** package when
installed.

1. Install: sudo pacman -S gfxboot
2. Compile: make

### boot/data
Containes resources for GFXBoot theme

***Note:*** use Kolourpaint to save your images as it sets some special bits in the image that
GFXBoot needs to display them properly; otherwise you'll just see black squares.

- background.jpg:   Background image
- text.jpg:         Fade-in text image shown in the splash screen.
- timer_a.jpg:      Timeout spinner for the main menu
- splash.jpg:       Splash background
- gfxboot.cfg:      Master config file.
- 16x16.fnt:        Most complete font set you'll ever need

### boot/src
Breakdown of the source files used for the menu.

* splash.inc:       Source code for the splash.
* button.inc:       Source code for drawing buttons.
* main.ps:          The main menu generator and handling, parses gfxboot.cfg
* init.bc:          bit-compiling includes file.
* menu.inc:         Generates the main menu.
* panel.inc:        Generates the bottom panel.
* system.inc:       Abstracted low-level functions.
* timeout.inc:      Handles the timeout spinner.
* windows.inc:      Draws the main window.
* xmenu.inc:        Several functions for drawing the menu elements.
