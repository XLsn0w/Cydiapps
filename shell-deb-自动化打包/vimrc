filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
 
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

if filereadable(expand("~/.vimrc.bundles"))
    source ~/.vimrc.bundles
endif
nmap <Leader>tb :TagbarToggle<CR>
let g:tagbar_ctags_bin='/usr/bin/ctags'
let g:tagbar_width=30
autocmd BufReadPost *.cpp,*.c,*.h,*.hpp,*.cc,*.cxx call tagbar#autoopen()
let g:jedi#auto_initialization = 1

let g:solarized_termtrans=1
let g:solarized_contrast="normal"
let g:solarized_visibility="normal"

set background=dark
set t_Co=256
colorscheme solarized

nmap <leader>nt :NERDTree<CR>
let NERDTreeHighlightCursorline=1
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.obj$', '\.o$', '\.so$', '\.egg$', '^\.git$', '^\.svn$', '^\.hg$' ]
let g:netrw_home='~/bak'
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | end

let g:ctrlp_map = '<leader>ff'
let g:ctrlp_cmd = 'CtrlP'
map <leader>fp :CtrlPMRU<CR>
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/]\.(git|hg|svn|rvm)$',
    \ 'file': '\v\.(exe|so|dll|zip|tar|tar.gz)$',
    \ }

let g:ctrlp_working_path_mode=0
let g:ctrlp_match_window_bottom=1
let g:ctrlp_max_height=15
let g:ctrlp_match_window_reversed=0
let g:ctrlp_mruf_max=500
let g:ctrlp_follow_symlinks=1

let g:Powerline_symbols = 'unicode'
let g:rbpt_colorpairs = [
    \ ['brown',       'RoyalBlue3'],
    \ ['Darkblue',    'SeaGreen3'],
    \ ['darkgray',    'DarkOrchid3'],
    \ ['darkgreen',   'firebrick3'],
    \ ['darkcyan',    'RoyalBlue3'],
    \ ['darkred',     'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['brown',       'firebrick3'],
    \ ['gray',        'RoyalBlue3'],
    \ ['black',       'SeaGreen3'],
    \ ['darkmagenta', 'DarkOrchid3'],
    \ ['Darkblue',    'firebrick3'],
    \ ['darkgreen',   'RoyalBlue3'],
    \ ['darkcyan',    'SeaGreen3'],
    \ ['darkred',     'DarkOrchid3'],
    \ ['red',         'firebrick3'],
    \ ]
let g:rbpt_max = 40
let g:rbpt_loadcmd_toggle = 0

let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_guide_size            = 1
let g:indent_guides_start_level           = 2


set nocompatible
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,sjis,euc-jp
set fileformats=unix,dos
set backup
set backupdir=~/.backup
set history=50
set ignorecase
set smartcase
set hlsearch
set incsearch
set number
set showmatch
set autoindent
set backspace=indent,eol,start
set shiftwidth=4
set expandtab
syntax on
highlight Comment ctermfg=LightCyan
set wrap
set ts=4
set ru
autocmd BufNewFile *.py,*.sh, exec ":call SetTitle()"
let $author_name = "Kellan Fan"
func SetTitle()  
    if &filetype == 'python'  
        call setline(2, "\#coding=utf8")  
        call setline(3, "\"\"\"")  
        call setline(4, "\# Author: ".$author_name)  
        call setline(5, "\# Created Time : ".strftime("%c"))  
        call setline(6, "")  
        call setline(7, "\# File Name: ".expand("%"))  
        call setline(8, "\# Description:")  
        call setline(9, "")  
        call setline(10, "\"\"\"")  
        call setline(11,"")  
    endif  
    if &filetype == 'sh'  
        call setline(2, "\#######################################################################")  
        call setline(3, "\#Author: ".$author_name)  
        call setline(4, "\#Created Time : ".strftime("%c"))  
        call setline(5, "\#File Name: ".expand("%"))  
        call setline(6, "\#Description:")  
        call setline(7, "\#######################################################################")  
        call setline(8,"")  
    endif  
endfunc
