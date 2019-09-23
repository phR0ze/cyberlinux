" Copyright {{{
"MIT License
"Copyright (c) 2018-2019 phR0ze
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

" General settings
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
  set ignorecase                " Ignore case in search patterns. Also used when searching in the tags file.
  set smartcase                 " With ignorecase this searches case sensitive when capital is given

  " Mouse
  set mouse=a                   " Enable mouse for all modes
  set mousehide                 " Hide the mouse when typing text

  " Set numbering/status
  set number                    " Shows line numbers
  set ruler                     " Shows current position (row and column) at the bottom of srceen
  set modeline                  " Honor modelines in files as overrides
  set laststatus=2              " Always include the status line at the bottom of the screen
  set modelines=5               " Number of lines at begining of file to check for modelines

  " Set tabbing/indenting
  set tabstop=4                 " How many columns a tab counts for
  set shiftwidth=4              " Specifies how many columns text is indented with the rindent operations << and >>
  set softtabstop=4             " How many columns a tab counts for, only used when expandtab is not set
  set expandtab                 " Hitting tab in insert mode will produce the appropriate number of spaces
  set cindent                   " Enables automatic C program indenting
  set autoindent                " Enables automatic C program indenting
  set smartindent               " Indents according to blocks of code, 'nosmartindent'

  set showmatch                 " When typing a closing parenthesis, bracket, or brace, shows match
  set showmode                  " Show if you are in insert mode or command mode at the bottom of the screen
  set spell spelllang=en_us     " Set spelling options
  set nospell                   " Turn spelling off by default
  set textwidth=100             " Maximum line length before wrapping; 0 means don't do this
  set wrapmargin=10             " When width 0, this wraps if within this many spaces from right margin
  set wildmode=longest,list     " Sets tab completion for command line similar to bash

augroup END

augroup PluginSettings
  autocmd!

  set nocompatible              " Use current VIM syntax and not old VI syntax
  filetype plugin indent on     " Load filetype specific plugins and indent rules

  " Override filetype detection
  au BufNewFile,BufRead *.smali set filetype=smali
  au BufNewFile,BufRead *conkyrc set filetype=conkyrc

  " Override file type configs
  au FileType make setl noexpandtab
  au FileType vim setl foldmethod=marker
  au FileType yaml setl ts=2 sw=2 sts=2

  " Jedi: Turn off pop up call signatures
  let g:jedi#show_call_signatures = "2"

  " Jedi: Turn off auto completion
  let g:jedi#popup_on_dot = 0

  " Jedi: Turn off docstring preview window
  au FileType python setl completeopt-=preview

  " SuperTab: Enable menu filtering as you type
  set completeopt=menuone,longest,preview

  " SuperTab: Select first instead of last autocomplete
  let g:SuperTabDefaultCompletionType = "<c-n>"
augroup END

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

" Register +: Vim, X Apps
" Register + w/unnamedplus: Vim, X Apps, MSWindows/Synergy
" Register + w/Parcellite: Vim, X Apps, MSWindows/Synergy
" Register *: Vim, MSWindows/Synergy, middle clicks
" Register * w/Parcellite: Vim, MSWindows/Synergy, middle clicks
vnoremap <C-c> "+y
nnoremap <C-v> "+p
inoremap <C-v> <Esc>"+pa
nnoremap <C-a> ggVG

" Move up/down by rows rather than by lines
nnoremap k gk
nnoremap j gj

" Show syntax highlighting group with Ctrl+Shift+h for word under cursor
nnoremap <C-S-h> :call ColorGroup()<CR>
fun ColorGroup()
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfun

if has("gui_running")
    if has("win32") || has("win64")
        source $VIMRUNTIME/mswin.vim    " Add Windows copy/paste support
        autocmd GUIEnter * simalt ~x    " Start GUI maximized
    endif
endif

" Frank Color Scheme:
"******************************************************************************
" - Dark/dusty
" - No Italics
" - GUI Compatibility
" - 256 Color XTerm Compatibility
"******************************************************************************
syntax on                               " Turn on syntax hi-lighting
hi clear                                " Clear any previous hi-lighting
set background=dark                     " Set vim color mode (dark or light)
if has("gui_running")
    if has("gui_gtk2")
        set guioptions-=T               " Remove toolbar at the top
        set guifont=Inconsolata-g\ Medium\ 11
    endif
else
    set t_Co=256                        " Enable 256 colors for terminal mode
endif
let g:colors_name = "frank"             " Set color scheme name
let python_highlight_all = 1            " Enable syntax/python.vim highlighting
let c_gnu = 1                           " ?

" Colors
" Show groups: help hightlight-groups
" http://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
"******************************************************************************
let xBlack = [0, "#000000"]
let xWhite = [15, "#ffffff"]
let xGrayDusk = [59, "#5f5f5f"]
let xTealDusk = [66, "#5f8787"]
let xBlueDusk = [67, "#5f87af"]
let xPurpleDusk = [139, "#af87af"]
let xGreenDusk = [148, "#afd700"]       " 142 is also good
let xOrangeDusk = [202, "#ff5f00"]      " 208 is also really good
let xYellowDusk = [220, "#ffd700"]      " Numbers
let xBackground = [234, "#1c1c1c"]      " Background color for window
let xGrayDark = [236, "#3a3a3a"]        " Pop up menu background
let xGrayLight = [239, "#4e4e4e"]       " Visual hi-light background
let xGrayText = [252, "#d0d0d0"]

" Functions
" g: global scope used by default when not specified
" a: indicates function arguments
" l: local function argument
"******************************************************************************
" group, fgcolor, bgcolor, attrib
fun SetColor(groups, ...)
    let l:attr = a:0 > 2 ? a:3 : "none"

    if !has("gui_running")
        let l:fgcolor = a:0 > 0 && type(a:1) == type([]) ? a:1[0] : g:xBackground[0]
        let l:bgcolor = a:0 > 1 && type(a:2) == type([]) ? a:2[0] : g:xBackground[0]
        for group in a:groups
            exec "hi " . group . " cterm=" . l:attr . " ctermfg=" . l:fgcolor . " ctermbg=" . l:bgcolor
        endfor
    else
        let l:fgcolor = a:0 > 0 && type(a:1) == type([]) ? a:1[1] : g:xBackground[1]
        let l:bgcolor = a:0 > 1 && type(a:2) == type([]) ? a:2[1] : g:xBackground[1]
        for group in a:groups
            exec "hi " . group . " gui=" . l:attr . " guifg=" . l:fgcolor . " guibg=" . l:bgcolor
        endfor
    endif
endfun

" Vim Interface
"******************************************************************************
" See all current colors with: hi

call SetColor(["Normal"], xGrayText)
call SetColor(["Question", "SpecialKey", "Title", "VertSplit", "WildMenu"], xOrangeDusk)

" Dosn't do anything in term only gvim
call SetColor(["Cursor"], xBlack, xOrangeDusk)
call SetColor(["CursorLine", "CursorColumn"], xBlack, xOrangeDusk)

call SetColor(["Error"], xOrangeDusk)
call SetColor(["Todo"], xBlack, xBlueDusk)
call SetColor(["LineNr", "NonText"], xGrayDusk)
call SetColor(["Directory"], xBlueDusk)
call SetColor(["MatchParen"], xOrangeDusk, xBlack, "bold")
call SetColor(["Underlined"], xBlueDusk, "none", "underline")
call SetColor(["ErrorMsg", "WarningMsg", "ModeMsg", "MoreMsg"], xOrangeDusk)

call SetColor(["TabLine", "TabLineFill", "TabLineSel"], xOrangeDusk)
"
" Tab completion menu
call SetColor(["Pmenu"], xBlueDusk, xGrayDark)
call SetColor(["PmenuSel"], xWhite, xBlueDusk)

" Status line at bottom (selected and non-selected/NC)
call SetColor(["StatusLine"], xWhite, xBlueDusk)
call SetColor(["StatusLineNC"], xBlack, xBlueDusk)
"
"hi DiffAdd           cterm=none          ctermfg=none   ctermbg=239
"hi DiffChange        cterm=none          ctermfg=none   ctermbg=170
"hi DiffDelete        cterm=bold          ctermfg=239    ctermbg=66
"hi DiffText          cterm=bold          ctermfg=15     ctermbg=none
"
call SetColor(["Visual", "VisualNOS"], xBlueDusk, xGrayLight)

"hi Folded            cterm=none          ctermfg=244    ctermbg=235
"hi FoldColumn        cterm=none          ctermfg=15     ctermbg=237
"
"hi IncSearch         cterm=none          ctermfg=15     ctermbg=149
"hi Search            cterm=none          ctermfg=15     ctermbg=149
"
" Code Syntax
"******************************************************************************
call SetColor(["String"], xOrangeDusk)
call SetColor(["Comment"], xTealDusk)
call SetColor(["Function", "Identifier"], xBlueDusk)
call SetColor(["Float", "Boolean", "Number"], xYellowDusk)
call SetColor(["PreProc", "Include", "Define", "Macro", "PreCondit"], xPurpleDusk)
call SetColor(["Constant", "Type", "StorageClass", "Typedef", "Structure"], xGreenDusk)
call SetColor(["Special", "Character", "SpecialChar", "Tag", "Delimiter", "SpecialComment", "Debug"], xBlueDusk)
call SetColor(["Statement", "Conditional", "Repeat", "Label", "Operator", "Keyword", "Exception"], xGreenDusk, "none", "bold")

" Markdown Syntax
"******************************************************************************
call SetColor(["markdownCode"], xBlueDusk)
call SetColor(["markdownLink"], xYellowDusk)
call SetColor(["markdownHeadingDelimiter"], xTealDusk)
call SetColor(["markdownH1", "markdownH2", "markdownH3", "markdownH4"], xOrangeDusk)
call SetColor(["markdownItalic", "markdownLinkText", "markdownListMarker", "markdownOrderedListMarker"], xGreenDusk)

" XML/HTML Syntax
"******************************************************************************
"hi xmlTagName        cterm=none         ctermfg=149     ctermbg=none
"hi xmlCdata          cterm=none         ctermfg=246     ctermbg=none
"hi xmlAttrib         cterm=none         ctermfg=110     ctermbg=none
"hi htmlTagName       cterm=none         ctermfg=149     ctermbg=none
"hi htmlArg           cterm=none         ctermfg=110     ctermbg=none
"hi htmlItalic        cterm=none         ctermfg=253     ctermbg=235
"
"hi Ignore            cterm=none         ctermfg=15      ctermbg=none
"
" Clean up
"******************************************************************************
delf SetColor
