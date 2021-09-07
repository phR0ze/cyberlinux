NeoVim
====================================================================================================
<img align="left" width="48" height="48" src="../../art/logo_256x256.png">
NeoVim is a fork of Vim aiming to improve user experience and plugin implementation.
<br><br>

### Quick Links
* [.. up dir](..)
* [Overview](#overview)
  * [Getting started](#getting-started)
    * [Install NeoVim](#install-neovim)
    * [Migrating to NeoVim](#migrating-to-neovim)
  * [Config Locations](#config-locations)
* [vim-plug](#vim-plug)
  * [Install vim-plug](#install-vim-plug)
  * [Install plugins](#install-plugins)
  * [Plugins](#plugins)
* [Command Syntax](#command-syntax)

# Overview <a name="overview"></a>

## Getting started <a name="getting-started"></a>

### Install NeoVim <a name="install-neovim"></a>
Unfortunately NeoVim's QT UI is far inferior to GVim which is what I used to use. Typically however 
I simply use the shell version of neovim or Visual Studio Code with the Vim plugin when in a UI. As 
a fall back in lite configurations I'll use `geany`.
```bash
$ sudo pacman -S neovim
```

### Migrating to NeoVim <a name="migrating-to-neovim"></a>
On install of `cyberlinux` I've setup a link `ln -sf /usr/bin/nvim /usr/bin/vim` so I don't need to 
change any other configuration.

Simply copy your `~/.vimrc` to `~/.config/nvim/init.vim` as a starting point

## Config Locations <a name="config-locations"></a>
* ***Config file location:*** `~/.config/nvim/init.vim`
* ***Global user config file location:*** `/etc/xdg/nvim/sysinit.vim`
* ***Global default config file location:*** `/usr/share/nvim/sysinit.vim`
* ***Data directory for swap files:*** `~/.local/share/nvim`

# vim-plug <a name="vim-plug"></a>
[vim-plug](https://github.com/junegunn/vim-plug) is a minimalist vim plugin manager with super fast
parallel installation/update. It is the most popular one right now as well.

## Install vim-plug <a name="install-vim-plug"></a>
```bash
$ curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

## Install plugins <a name="install-plugins"></a>
```
$ nvim ~/.config/nvim/init.vim
:PlugInstall
:PlugUpdate
:q
```

## Plugins <a name="plugins"></a>
Vim plugins in the `vim-plug` world are just github repositories

### Utilities <a name="utilities"></a>
  # Utilities
  aserebryakov/vim-todo-lists         # Manage TODOs
  #Plug  yegappan/mru
  #Plug  junegunn/fzf , {  dir :  ~/.fzf ,  do :  ./install --all   }
  #Plug  junegunn/fzf.vim
  #Plug  ctrlpvim/ctrlp.vim
  #
  #Plug  Shougo/neocomplete.vim
  #Plug  tommcdo/vim-exchange
  #Plug  ntpeters/vim-better-whitespace
  #Plug  tpope/vim-surround
  #Plug  tpope/vim-repeat
  #Plug  jiangmiao/auto-pairs
  #Plug  vim-scripts/CursorLineCurrentWindow
  #Plug  victormours/better-writing.vim
  #Plug  janko-m/vim-test
  #Plug  skywind3000/asyncrun.vim
  #Plug  w0rp/ale
  #Plugin  scrooloose/nerdtree
  #Plugin  majutsushi/tagbar
  #Plugin  ervandew/supertab
  #Plugin  BufOnly.vim
  #Plugin  wesQ3/vim-windowswap
  #Plugin  SirVer/ultisnips
  #Plugin  junegunn/fzf.vim
  #Plugin  junegunn/fzf
  #Plugin  godlygeek/tabular
  #Plugin  ctrlpvim/ctrlp.vim
  #Plugin  benmills/vimux
  #Plugin  jeetsukumaran/vim-buffergator
  #Plugin  gilsondev/searchtasks.vim
  #Plugin  Shougo/neocomplete.vim
  #Plugin  tpope/vim-dispatch

  # Interface
  scrooloose/nerdtree                 # File explorer sidebar
  vim-airline/vim-airline             # Awesome status bar at bottom with git support
  vim-airline/vim-airline-themes      # Vim Airline themes
  ryanoasis/vim-devicons              # Sweet folder/file icons for nerd tree

  # ColorSchemes
  vim-scripts/CycleColor  			      # Color scheme cycler
  ajmwagar/vim-deus  				          # deus
  YorickPeterse/happy_hacking.vim     # happy_hacking
  w0ng/vim-hybrid  				            # hybrid
  kristijanhusak/vim-hybrid-material  # hybrid_material
  nanotech/jellybeans.vim  			      # jellybeans
  dikiaap/minimalist  				        # minimalist
  marcopaganini/termschool-vim-theme  # termschool

  # Programming
  airblade/vim-gitgutter              # Git integration in gutter
  tpope/vim-fugitive                  # Git integration
  #Plugin  kablamo/vim-git-log
  #Plugin  gregsexton/gitv
  #Plugin  jakedouglas/exuberant-ctags
  #Plugin  honza/vim-snippets
  #Plugin  Townk/vim-autoclose
  #Plugin  tomtom/tcomment_vim
  #Plugin  tobyS/vmustache
  #Plugin  janko-m/vim-test
  #Plugin  maksimr/vim-jsbeautify
  #Plugin  vim-syntastic/syntastic
  #Plugin  neomake/neomake
  #Plugin  artur-shaik/vim-javacomplete2
  #Bundle  jalcine/cmake.vim

  # Syntax highlighting
  zzeroo/vim-vala
  stephpy/vim-yaml                   # yaml
  hail2u/vim-css3-syntax             # css3
  kurayama/systemd-vim-syntax        # systemd

  # Markdown / Writting
  #Plugin  reedes/vim-pencil
  #Plugin  tpope/vim-markdown
  #Plugin  jtratner/vim-flavored-markdown
  #Plugin  LanguageTool

  # HTML
  #Plug  mattn/emmet-vim
  #Plug  slim-template/vim-slim
  #Plug  mustache/vim-mustache-handlebars

  # Javascript
  #Plug  pangloss/vim-javascript
  #Plug  mxw/vim-jsx
  #Plug  othree/yajs.vim
  #Plug  othree/javascript-libraries-syntax.vim
  #Plug  claco/jasmine.vim
  #Plug  kchmck/vim-coffee-script
  #Plug  lfilho/cosco.vim

  # Ruby
  #Plug  Keithbsmiley/rspec.vim
  #Plug  tpope/vim-rails
  #Plug  tpope/vim-endwise
  #Plug  ecomba/vim-ruby-refactoring
  #Plug  vim-ruby/vim-ruby
  #Plug  emilsoman/spec-outline.vim
  #Plug  victormours/vim-rspec
  #Plug  nelstrom/vim-textobj-rubyblock
  #Plug  kana/vim-textobj-user
  #Plug  jgdavey/vim-blockle
  #Plug  KurtPreston/vim-autoformat-rails
  #Plug  ngmy/vim-rubocop

  # Colorize last to ensure overriding
  phR0ze/vim-colorize                # Colorize various plugins
)


# Commad Syntax <a name="command-syntax"></a>

<!-- 
vim: ts=2:sw=2:sts=2
-->
