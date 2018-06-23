"MIT License
"Copyright (c) 2018 phR0ze
"
"Permission is hereby granted, free of charge, to any person obtaining a copy
"of this software and associated documentation files (the 'Software'), to deal
"in the Software without restriction, including without limitation the rights
"to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
"copies of the Software, and to permit persons to whom the Software is
"furnished to do so, subject to the following conditions:
"
"The above copyright notice and this permission notice shall be included in all
"copies or substantial portions of the Software.
"
"THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
"FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
"AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
"LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
"OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
"SOFTWARE.

" General settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://github.com/EricFalkenberg/dotfiles/blob/master/.vimrc
" https://github.com/zeorin/dotfiles/blob/e01cebf/.vimrc#L864-L900
" https://github.com/ryanoasis/vim-devicons/issues/158
" https://github.com/0phoff/DotFiles/blob/master/Vim/neovim.vim#L104-L137
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set title                         " Sets the window title to your current buffer name
set mouse=a                       " Enable mouse for all modes
set encoding=UTF-8                " Required for vim-devicons to work correctly
set autochdir                     " Automatically switch working directory to current file
set backspace=2                   " Configure backspace to work as normal same as =indent,eol,start
set clipboard=unnamedplus         " Set all yanks to be copied to register * as well as register +
set formatoptions+=tqw            " Text formatting, a=auto formatting for t=text and w=paragraphs
set nobackup                      " Don't make a backup of a file when overwriting it
set noerrorbells                  " Turn off incessant beeping
set showmatch		                  " When typing a closing parenthesis, bracket, or brace, shows match
set showmode                      " Show if you are in insert mode or command mode at the bottom of the screen
set wildmode=longest,list         " Sets tab completion for command line similar to bash
set shortmess=a                   " Use short messaging where possible, helps in shell call outs

" Search
set nohlsearch                    " Don't highlight matches with last search pattern
set ignorecase                    " Ignore case in search patterns
set smartcase                     " Works with ignorecase to only search case sensitive when capital is given

" Set numbering/position/status
set number			                  " Shows line numbers
set ruler 			                  " Shows current position (row and column) at the bottom of srceen

" Set tabbing/indenting/wrapping
set tabstop=2		                  " How many columns a tab counts for
set shiftwidth=2	                " Specifies how many columns text is indented with the rindent operations << and >>
set softtabstop=2                 " How many columns a tab counts for, only used when expandtab is not set
set cindent                       " Enables automatic C program indenting
set autoindent                    " Enables automatic C program indenting
set smartindent		                " Indents according to blocks of code, 'nosmartindent'
set expandtab		                  " Hitting tab in insert mode will produce the appropriate number of spaces
set textwidth=100	                " Maximum line length before wrapping; 0 means don't do this
set wrapmargin=10	                " wraps if within this many spaces from right margin; doesn't work unless text width is 0
"set cc=80                         " set an 80 column border for good coding style

" Text spelling
set spell spelllang=en_us         " Set spelling options
set nospell                       " Turn spelling off by default

" Plugin management settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible                                  " Disable old VI support, required by Vundle
filetype off                                      " Required for Vundle
set rtp+=~/.config/nvim/plugins/Vundle.vim        " Add Vundle to runtime path
call vundle#begin('~/.config/nvim/plugins')       " Initialize Vundle with correct plugin path
Plugin 'VundleVim/Vundle.vim'                     " Manage Vundle with Vundle

" ColorSchemes
Plugin 'vim-scripts/CycleColor' 			            " Color scheme cycler
Plugin 'ajmwagar/vim-deus' 				                " deus
Plugin 'YorickPeterse/happy_hacking.vim'          " happy_hacking
Plugin 'w0ng/vim-hybrid' 				                  " hybrid
Plugin 'kristijanhusak/vim-hybrid-material'       " hybrid_material
Plugin 'nanotech/jellybeans.vim' 			            " jellybeans
Plugin 'dikiaap/minimalist' 				              " minimalist
Plugin 'marcopaganini/termschool-vim-theme'       " termschool

" Interface
Plugin 'scrooloose/nerdtree'                      " File explorer sidebar
"Plugin 'itchyny/lightline.vim'                   " Faster than airline, http://newbilityvery.github.io/2017/08/04/switch-to-lightline/
"Plugin 'Xuyuanp/nerdtree-git-plugin'             " Seems to break devicons in NerdTree
"Plugin 'vim-airline/vim-airline'                  " Awesome status bar at bottom with git support
"Plugin 'vim-airline/vim-airline-themes'           " Vim Airline themes
Plugin 'ryanoasis/vim-devicons'                   " Sweet folder/file icons for nerd tree
"Plugin 'colorize-devicons', {'pinned' : 1}        " Custom local plugin for colorizing devicons

" Git
Plugin 'airblade/vim-gitgutter'         

" Syntax
Plugin 'stephpy/vim-yaml'                         " yaml
Plugin 'kurayama/systemd-vim-syntax'              " systemd

call vundle#end()                                 " Finalize plugin management section
filetype plugin indent on                         " Turn file type and indenting back on

" Filetype settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Override filetype detection
au BufNewFile,BufRead *.smali set filetype=smali
au BufNewFile,BufRead *conkyrc set filetype=conkyrc

" Override file type configs
au FileType make setl noexpandtab
au FileType yaml setl ts=2 sw=2 sts=2

" DevIcons Settings
" https://github.com/ryanoasis/vim-devicons/wiki/Extra-Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set padding after/before glyph
let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ''

" Decorate directories with folder icons
let g:WebDevIconsUnicodeDecorateFolderNodes = 1

" NERDTree Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Show hidden files
let NERDTreeShowHidden = 1

" Automatically delete the buffer of the file you just deleted
let NERDTreeAutoDeleteBuffer = 1

" Key mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" n Normal mode map. Defined using :nmap or nnoremap
" i Insert mode map. Defined using :imap or inoremap
" v Visual and select mode map. Defined using :vmap or vnoremap
" x Visual mode map. Defined using :xmap or xnoremap
" s Select mode map. Defined using :smap or snoremap
" c Command-line mode map. Defined using :cmap or cnoremap
" noremap ignores other mappings - always use this mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle nerd tree with Ctrl+f
map <C-f> :NERDTreeToggle<CR>

" Move up/down by rows rather than by lines
nnoremap k gk
nnoremap j gj

" Configure copy/paste and select all
vnoremap <C-c> "+y
nnoremap <C-v> "+p
inoremap <C-v> <Esc>"+pa
nnoremap <C-a> ggVG

" Color settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on                                   " Turn on syntax hi-lighting
set t_Co=256                                " Enable 256 colors for terminal mode
set background=dark                         " Set vim color mode (dark or light)
colorscheme deus                            " Set the color scheme

" Colorize DevIcons
" http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ColorizeDevicons(iconmap)
  let colors = keys(a:iconmap)
  augroup devicons_colors
    autocmd!
    for color in colors

      " Set up highlight group e.g. 'devicons_green'
      exec 'autocmd FileType nerdtree,startify highlight devicons_'.color.
        \ ' guifg=#'.g:devicons_colors[color][0].' ctermfg='.g:devicons_colors[color][1]

      " Match highlight group e.g. 'devicons_green' with icons set e.g. ['', '', '', '']
      exec 'autocmd FileType nerdtree,startify syntax match devicons_'.color.
        \ ' /\v'.join(a:iconmap[color], '|').'/ containedin=ALL'
    endfor
  augroup END
endfunction

" Color to icon set mapping
"\'seagreen': ['', '', '', '', ''],
let g:devicons_iconmap = {
  \'lightgreen': ['', '', '', '', '', '', '', '', '', '', ''],
  \'yellow': ['', '', ''],
  \'orange': ['', '', '', 'λ', '', ''],
  \'red': ['', '', '', '', '', '', '', '', ''],
  \'magenta': [''],
  \'violet': ['', '', '', ''],
  \'blue': ['', '', '', '', '', '', '', '', '', '', '', '', ''],
  \'cyan': ['', '', '', ''],
  \'green': ['', '', '', '']
\}

" guifg in Xterm256 and ctermfg
let g:devicons_colors = {
  \'cyan'         : ['00ffff', '51'],
  \'blue'         : ['0000ff', '21'],
  \'violet'       : ['d787ff', '177'],
  \'red'          : ['ff0000', '196'],
  \'yellow'       : ['ffff00', '226'],
  \'orange'       : ['ffaf00', '214'],
  \'magenta'      : ['ff00ff', '201'],
  \'green'        : ['00ff00', '46'],
  \'lightgreen'   : ['87ff5f', '119']
\}

call ColorizeDevicons(g:devicons_iconmap)
