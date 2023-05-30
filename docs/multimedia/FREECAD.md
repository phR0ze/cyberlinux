FreeCAD
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
Documenting my research on FreeCAD
<br><br>

### Quick links
* [.. up dir](README.md)
* [FreeCAD Overview](#freecad-overview)
  * [FreeCAD competitors](#freecad-competitors)
  * [Install and configure FreeCAD](#install-and-configure-freecad)

# FreeCAD Overview
General purpose CAD. With the BIM plugin you can get a lot of architecture support similar to Revit 
or Sketchup.

**References**
* BIM - Building Information Modeling
* [BIM with FreeCAD playlist](https://www.youtube.com/playlist?list=PLmKdGVtV5Vnt2cj4IZIv9FM39QHaE1ZaU)
* [BIM with FreeCAD - Introduction](https://www.youtube.com/watch?v=rkWOFQ2fGZQ)
* [House using ARCH workbench](https://www.youtube.com/watch?v=RduDsY_8kJ8)
* [FreeCAD Tuts](https://www.youtube.com/playlist?list=PLDd21g-eSHwkkxVOfVmR8ObpPN5QbL7ye)

## FreeCAD competitors
* Revit
* Sketchup
* Rymn

## Install and configure FreeCAD
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
 
## Workbenches
Workbenches in FreeCAD are a collection of tools that can be selected to focus on different aspects 
of CAD work. You can customize workbenches and move tools from one to another.

* `Arch` - contains a lot of tools for working with Architecture
* `BIM` - addon for Building Information Modeling tools similar to Revit, AchiCAD, Tkla, AllPlan or BricsCAD

## BIM Workbench
The BIM workbench is essentially the Arch workbench with additional tooling and settings to help with 
BIM.

* [BIM roof](https://www.youtube.com/watch?v=XCPUkXVqNQ8&list=PLU9HicgJ9hhJvYJso3a6w2TlSLfQvFhzW&index=1)

### Move with host
BIM components that are built off a base rectangle like walls and slabs have a property called `Move 
With Host` that can be set to true to keep them together when you move the base rectangle

### Selection Planes
Create selection planes for technical views that will show up in the `Techdraw Workbench`

1. Select all the components you'd like in the View
2. Hide any sub-components you don't want to show up
3. Click the `Selection Plane` button
4. Switch over to the `TechDraw` workbench

## TechDraw Workbench
The TechDraw workbench is used to make a 2D technical drawing of your work based on the selection 
planes you created with BIM.

* [Techdraw 15 min](https://www.youtube.com/watch?v=02Gv4gN117M)

1. Switch to the `TechDraw workbench`
2. Click the `Insert Default Page` button top left
3. Double click the `Page > Template` object and select a new template `USLetter_Landscape_blank.svg`
3. Select your selection planes and click `Insert Arch Workbench Object`
4. Select th enew `ArchView` and change its scale in its properties from `1.0` to `0.005`

<!-- 
vim: ts=2:sw=2:sts=2
-->
