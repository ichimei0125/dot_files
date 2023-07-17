syntax on
set number
set relativenumber
set tabstop=4

" encode
set encoding=utf-8

set fileencoding=utf-8
"set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8,cp932
set fileencodings=utf-8,cp932
set fileformats=unix,dos,mac

if has('gui_running')
	colorscheme nord
"
"	if has("gui_gtk2")
"		set guifont=Inconsolata\ 12
"
"	elseif has("gui_macvim")
"		set lines=70
"		set columns=180
"		set guifont=Menlo\ Regular:h13
"		set guioptions-=L  "remove left-hand scroll bar
"
"	elseif has("gui_win32")
"		"set guifont=Consolas:h11:cANSI
"		set guifont=MS_Gothic:h14
"		set lines=42
"		set columns=150	
"		set guioptions-=L  "remove left-hand scroll bar
"		set guioptions-=T  "remove toolbar
"	endif
endif


" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
