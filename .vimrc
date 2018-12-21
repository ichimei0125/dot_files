syntax on
set number
set tabstop=4

" encode
if has("mac")
	set encoding=utf-8
elseif has("unix")
  " do stuff under linux and "
elseif has("win32")
	set encoding=cp932
endif

set fileencoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8,cp932
set fileformats=unix,dos,mac

" Add pathogen
execute pathogen#infect()
filetype plugin indent on

if has('gui_running')
	color happy_hacking "color

	autocmd vimenter * NERDTree workspace
	let NERDTreeShowBookmarks=1

	if has("gui_gtk2")
		set guifont=Inconsolata\ 12

	elseif has("gui_macvim")
		set lines=40
		set columns=125
		set guifont=Menlo\ Regular:h13
		set guioptions-=L  "remove left-hand scroll bar

	elseif has("gui_win32")
		"set guifont=Consolas:h11:cANSI
		set guifont=MS_Gothic:h12
		set lines=35
		set columns=130	
		set guioptions-=L  "remove left-hand scroll bar
		set guioptions-=T  "remove toolbar
	endif
endif

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"" quit if only NERDTree left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

