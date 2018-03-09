# cyberlinux-xkeyboard-config
Custom keyboard layouts for machines supported by cyberlinux

## Resources
* https://wiki.archlinux.org/index.php/X_KeyBoard_extension
* https://github.com/dnschneid/crouton/blob/master/targets/keyboard
* https://www.x.org/releases/X11R7.7/doc/kbproto/xkbproto.html#The_Overlay1_and_Overlay2_Controls

## Overlays
A keyboard overlay allows some subset of the keyboard to report alternate keycodes when the overlay
is enabled.  For example a keyboard overlay can be used to simulate a numeric or editing keypad on a
keyboard that does not actually have one by generating alternate keycodes for some keys when the
overlay is enabled. This technique is very common with ultra portable computers that have reduced
sized keyboards. XKB includes direct support for two keyboard overlays, using the ***Overlay1*** and
***Overlay2*** controls.  When ***Overlay1*** is enabled, all of the keys that are members of the
first keyboard overlay generate alternate keycodes. When ***Overlay2*** is enabled, all of the keys
that are members of the second keyboard overlay genearte alternate keycodes.

to specify the overlay to which a key belongs and the alternate keycode it should generate when that
overlay is enabled, assign it either the ***KB_Overlay1*** or ***KB_Overlay2*** key behaviors.

## Samsung Chromebook 3 (CELES)

### 1. Add Compatibility Map
https://wiki.archlinux.org/index.php/X_KeyBoard_extension#xkb_compatibility

Compatibility maps are specifications of what action should each key produce in order to preserve
compatibility with XKB-unaware clients.

1. Edit: ***compat/Makefile.am***
2. Add: ***celes*** to ***compat_Data*** list
3. Edit: ***compat/celes***
4. Add compatibility overlay
```bash
default partial xkb_compatibility "overlay"  {
    interpret Overlay1_Enable+AnyOfOrNone(all) {
        action= SetControls(controls=Overlay1);
    };
};
```

### 2. Add Key Codes

### 3. Add Key Symbols
```bash
// This mapping assumes that inet(evdev) will also be sourced
partial
xkb_symbols "overlay" {
    key <LWIN> { [ Overlay1_Enable ], overlay1=<LWIN> };
    key <AB09> { overlay1=<INS> };
    key <LEFT> { overlay1=<HOME> };
    key <RGHT> { overlay1=<END> };
    key <UP>   { overlay1=<PGUP> };
    key <DOWN> { overlay1=<PGDN> };
    key <FK01> { overlay1=<I247> };
    key <I247> { [ XF86Back ] };
    key <FK02> { overlay1=<I248> };
    key <I248> { [ XF86Forward ] };
    key <FK03> { overlay1=<I249> };
    key <I249> { [ XF86Reload ] };
    key <FK04> { overlay1=<I235> }; // XF86Display
    key <FK05> { overlay1=<I250> };
    key <I250> { [ XF86ApplicationRight ] };
    key <FK06> { overlay1=<I232> }; // XF86MonBrightnessDown
    key <FK07> { overlay1=<I233> }; // XF86MonBrightnessUp
    key <FK08> { overlay1=<MUTE> };
    key <FK09> { overlay1=<VOL-> };
    key <FK10> { overlay1=<VOL+> };
    key <AE01> { overlay1=<FK01> };
    key <AE02> { overlay1=<FK02> };
    key <AE03> { overlay1=<FK03> };
    key <AE04> { overlay1=<FK04> };
    key <AE05> { overlay1=<FK05> };
    key <AE06> { overlay1=<FK06> };
    key <AE07> { overlay1=<FK07> };
    key <AE08> { overlay1=<FK08> };
    key <AE09> { overlay1=<FK09> };
    key <AE10> { overlay1=<FK10> };
    key <AE11> { overlay1=<FK11> };
    key <AE12> { overlay1=<FK12> };
    key <BKSP> { overlay1=<DELE> };
    key <LALT> { overlay1=<CAPS> };
    key <RALT> { overlay1=<CAPS> };
    // For some strange reason, some Super_R events are triggered when
    // the Search key is released (i.e. with overlay on).
    // This maps RWIN to a dummy key (<I253>), to make sure we catch it.
    key <RWIN> { [ NoSymbol ], overlay1=<I253> };
    // Map dummy key to no symbol
    key <I253> { [ NoSymbol ] };
};
```
