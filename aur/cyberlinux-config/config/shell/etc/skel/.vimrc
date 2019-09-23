" Copyright {{{
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
" }}}

" General settings {{{
" Examples:
" https://github.com/EricFalkenberg/dotfiles/blob/master/.vimrc
" https://github.com/zeorin/dotfiles/blob/e01cebf/.vimrc#L864-L900
" https://github.com/ryanoasis/vim-devicons/issues/158
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup GeneralSettings
  autocmd!
  set title                     " Sets the window title to your current buffer name
  set encoding=UTF-8            " Required for vim-devicons to work correctly
  set autochdir                 " Automatically switch working directory to current file
  set backspace=2               " Configure backspace to work as normal same as =indent,eol,start
  set clipboard=unnamedplus     " Set all yanks to be copied to register * as well as register +
  set formatoptions+=tqw        " Text formatting, a=auto formatting for t=text and w=paragraphs
  set nobackup                  " Don't make a backup of a file when overwriting it
  set noerrorbells              " Turn off incessant beeping

  " Search
  set nohlsearch                " Don't highlight matches with last search pattern
  set ignorecase                " Ignore case in search patterns
  set smartcase                 " With ignorecase this searches case sensitive when capital is given

  " Mouse
  set mouse=a                   " Enable mouse for all modes
  set mousehide                 " Hide the mouse when typing text

  " Set numbering/status
  set number                    " Shows line numbers
  set ruler                     " Shows current position (row and column) at the bottom of srceen

  " Set tabbing/indenting
  set tabstop=2                 " How many columns a tab counts for
  set shiftwidth=2              " Specifies how many columns text is indented with the rindent operations << and >>
  set softtabstop=2             " How many columns a tab counts for, only used when expandtab is not set
  set expandtab                 " Hitting tab in insert mode will produce the appropriate number of spaces
  set cindent                   " Enables automatic C program indenting
  set autoindent                " Enables automatic C program indenting
  set smartindent               " Indents according to blocks of code, 'nosmartindent'

  set showmatch                 " When typing a closing parenthesis, bracket, or brace, shows match
  set showmode                  " Show if you are in insert/command mode at the bottom of the screen
  set spell spelllang=en_us     " Set spelling options
  set nospell                   " Turn spelling off by default
  set textwidth=100             " Maximum line length before wrapping; 0 means don't do this
  set wrapmargin=10             " When width 0, this wraps if within this many spaces from right margin
  set wildmode=longest,list     " Sets tab completion for command line similar to bash

  " Code folding
  "set foldenable                " Enable folding
  "set foldmarker={,}            " Markers are { }
  "set foldmethod=marker         " Create folds based on markers in code
  "set foldlevelstart=99       " Open all folds when opening a file
  "set foldnestmax=10          " Maximum nested folds
  "set foldtext=IndFoldTxt()   " Indent Fold Text
  "function! IndFoldTxt()
  "  let indent = repeat(' ', indent(v:foldstart))
  "  let txt = foldtext()
  "  return indent.txt
  "endfunction
augroup END
" }}}

" Plugin install {{{
augroup PluginInstall
  autocmd!

  set nocompatible                            " Use modern VIM syntax, required by Vundle
  filetype off                                " Required for Vundle
  set rtp+=~/.vim/bundle/Vundle.vim           " Add Vundle to runtime path
  call vundle#begin()                         " Initialize Vundle
  Plugin 'VundleVim/Vundle.vim'               " Manage Vundle with Vundle

  " Utilities
  Plugin 'aserebryakov/vim-todo-lists'        " Manage TODOs
  "Plug 'yegappan/mru'
  "Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all'  }
  "Plug 'junegunn/fzf.vim'
  "Plug 'ctrlpvim/ctrlp.vim'
  "
  "Plug 'Shougo/neocomplete.vim'
  "Plug 'tommcdo/vim-exchange'
  "Plug 'ntpeters/vim-better-whitespace'
  "Plug 'tpope/vim-surround'
  "Plug 'tpope/vim-repeat'
  "Plug 'jiangmiao/auto-pairs'
  "Plug 'vim-scripts/CursorLineCurrentWindow'
  "Plug 'victormours/better-writing.vim'
  "Plug 'janko-m/vim-test'
  "Plug 'skywind3000/asyncrun.vim'
  "Plug 'w0rp/ale'
  "Plugin 'scrooloose/nerdtree'
  "Plugin 'majutsushi/tagbar'
  "Plugin 'ervandew/supertab'
  "Plugin 'BufOnly.vim'
  "Plugin 'wesQ3/vim-windowswap'
  "Plugin 'SirVer/ultisnips'
  "Plugin 'junegunn/fzf.vim'
  "Plugin 'junegunn/fzf'
  "Plugin 'godlygeek/tabular'
  "Plugin 'ctrlpvim/ctrlp.vim'
  "Plugin 'benmills/vimux'
  "Plugin 'jeetsukumaran/vim-buffergator'
  "Plugin 'gilsondev/searchtasks.vim'
  "Plugin 'Shougo/neocomplete.vim'
  "Plugin 'tpope/vim-dispatch'

  " Interface
  Plugin 'scrooloose/nerdtree'                " File explorer sidebar
  Plugin 'vim-airline/vim-airline'            " Awesome status bar at bottom with git support
  Plugin 'vim-airline/vim-airline-themes'     " Vim Airline themes
  Plugin 'ryanoasis/vim-devicons'             " Sweet folder/file icons for nerd tree

  " ColorSchemes
  Plugin 'vim-scripts/CycleColor'             " Color scheme cycler
  Plugin 'ajmwagar/vim-deus'                  " deus
  Plugin 'YorickPeterse/happy_hacking.vim'    " happy_hacking
  Plugin 'w0ng/vim-hybrid'                    " hybrid
  Plugin 'kristijanhusak/vim-hybrid-material' " hybrid_material
  Plugin 'nanotech/jellybeans.vim'            " jellybeans
  Plugin 'dikiaap/minimalist'                 " minimalist
  Plugin 'marcopaganini/termschool-vim-theme' " termschool

  " Programming
  Plugin 'airblade/vim-gitgutter'             " Git integration in gutter
  Plugin 'tpope/vim-fugitive'                 " Git integration
  "Plugin 'kablamo/vim-git-log'
  "Plugin 'gregsexton/gitv'
  "Plugin 'jakedouglas/exuberant-ctags'
  "Plugin 'honza/vim-snippets'
  "Plugin 'Townk/vim-autoclose'
  "Plugin 'tomtom/tcomment_vim'
  "Plugin 'tobyS/vmustache'
  "Plugin 'janko-m/vim-test'
  "Plugin 'maksimr/vim-jsbeautify'
  "Plugin 'vim-syntastic/syntastic'
  "Plugin 'neomake/neomake'
  "Plugin 'artur-shaik/vim-javacomplete2'
  "Bundle 'jalcine/cmake.vim'

  " Syntax highlighting
  Plugin 'stephpy/vim-yaml'                  " yaml
  Plugin 'hail2u/vim-css3-syntax'            " css3
  Plugin 'kurayama/systemd-vim-syntax'       " systemd

  " Markdown / Writting
  "Plugin 'reedes/vim-pencil'
  "Plugin 'tpope/vim-markdown'
  "Plugin 'jtratner/vim-flavored-markdown'
  "Plugin 'LanguageTool'

  " HTML
  "Plug 'mattn/emmet-vim'
  "Plug 'slim-template/vim-slim'
  "Plug 'mustache/vim-mustache-handlebars'

  " Javascript
  "Plug 'pangloss/vim-javascript'
  "Plug 'mxw/vim-jsx'
  "Plug 'othree/yajs.vim'
  "Plug 'othree/javascript-libraries-syntax.vim'
  "Plug 'claco/jasmine.vim'
  "Plug 'kchmck/vim-coffee-script'
  "Plug 'lfilho/cosco.vim'

  " Ruby
  "Plug 'Keithbsmiley/rspec.vim'
  "Plug 'tpope/vim-rails'
  "Plug 'tpope/vim-endwise'
  "Plug 'ecomba/vim-ruby-refactoring'
  "Plug 'vim-ruby/vim-ruby'
  "Plug 'emilsoman/spec-outline.vim'
  "Plug 'victormours/vim-rspec'
  "Plug 'nelstrom/vim-textobj-rubyblock'
  "Plug 'kana/vim-textobj-user'
  "Plug 'jgdavey/vim-blockle'
  "Plug 'KurtPreston/vim-autoformat-rails'
  "Plug 'ngmy/vim-rubocop'

  " Colorize last to ensure overriding
  Plugin 'phR0ze/vim-colorize'               " Colorize various plugins

  call vundle#end()                          " Plugins must be btw begin/end for Vundle to manage them
  filetype plugin indent on                  " Turn file type and indenting back on
augroup END
" }}}

" Filetype settings {{{
augroup FiletypeSettings
  autocmd!

  " Override filetype detection
  au BufNewFile,BufRead *.smali set filetype=smali
  au BufNewFile,BufRead *conkyrc set filetype=conkyrc

  " Override file type configs
  au FileType make setl noexpandtab
  au FileType vim setl foldmethod=marker
  au FileType yaml setl ts=2 sw=2 sts=2
augroup END
" }}}

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

" Default arrow symbols
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

" Vim-Airline settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Always include powerline status line at the bottom of the screen
set laststatus=2

" User powerline fonts for icons
let g:airline_powerline_fonts = 1

"let g:Powerline_symbols = 'unicode'

" Automatically displays all buffers when there's only one tab open
let g:airline#extensions#tabline#enabled = 1

" Set the airline theme
let g:airline_theme = 'deus'

"let g:hybrid_custom_term_colors = 1
"let g:hybrid_reduced_contrast = 1 

" Syntastic settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1

" Supertab settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" SuperTab: Enable menu filtering as you type
"set completeopt=menuone,longest,preview
"
"" SuperTab: Select first instead of last autocomplete
"let g:SuperTabDefaultCompletionType = "<c-n>"
"

" Enable omni completion.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Enable heavy omni completion.
"if !exists('g:neocomplete#sources#omni#input_patterns')
"  let g:neocomplete#sources#omni#input_patterns = {}
"endif
""let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
"
"" For perlomni.vim setting.
"" https://github.com/c9s/perlomni.vim
"let g:neocomplete#sources#omni#input_patterns.java = '[^. *\t]\.\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

" Key Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" n Normal mode map. Defined using :nmap or nnoremap
" i Insert mode map. Defined using :imap or inoremap
" v Visual and select mode map. Defined using :vmap or vnoremap
" x Visual mode map. Defined using :xmap or xnoremap
" s Select mode map. Defined using :smap or snoremap
" c Command-line mode map. Defined using :cmap or cnoremap
" noremap ignores other mappings - always use this mode
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = ","

" Edit/source my ~/.vimrc
nnoremap <leader>ev :split $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr> 

" Toggle nerd tree with Ctrl+f
nnoremap <C-f> :NERDTreeToggle<CR>

" Move up/down by rows rather than by lines
nnoremap k gk
nnoremap j gj

" Configure copy/paste and select all
vnoremap <C-c> "+y
nnoremap <C-v> "+p
inoremap <C-v> <Esc>"+pa
nnoremap <C-a> ggVG

" Color settings
"******************************************************************************
syntax on                                   " Turn on syntax hi-lighting
set t_Co=256                                " Enable 256 colors for terminal mode
set background=dark                         " Set vim color mode (dark or light)
colorscheme deus                            " Set the color scheme
