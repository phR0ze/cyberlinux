Firefox configuration
====================================================================================================
<img align="left" width="48" height="48" src="../../../art/logo_256x256.png">
Documenting how I like to configure Firefox
<br><br>

### Quick links
* [.. up dir](..)
* [Config](#config)
  * [View Markdown](#view-markdown)
  * [Recent tab switching](#recent-tab-switching)
* [Extensions](#extensions)
  * [ublock origin](#ublock-origin)

# Config

## View Markdown
1. Browse to `about:config`
2. Search for `helpers.private_mime_types_file` which show the mime path `~/.mime.types`
3. Create the file `~/.mime.types`
   ```
   text/plain       md txt
   ```
4. Download and install [Markdown viewer](https://addons.mozilla.org/en-US/firefox/addon/markdown-viewer-chrome/)

## Recent tab switching
1. Navigate to `MENU >Settings`
2. Check `General >Ctrl+Tab cycles through tabs in recently used order`

# Extensions

## ublock origin
1. Navigate to `MENU >Add-ons and themes`
2. Punch into the search `ublock origin`
3. Click through and then `Add to Firefox >Add`
4. Select `Allow this extension to run in Private Windows` and click `Okay`

<!-- 
vim: ts=2:sw=2:sts=2
-->
