"----------------------------
"  must install 
"  NERDTree, pathogen, happy_hacking
"
"  Mac:
"----------------------------


syntax on
set number

" encode
if has("mac")
	set encoding=utf-8
elseif has("unix")
  " do stuff under linux and "
elseif has("win32")
	set encoding=cp932 " for Japanese enviroment
endif

set fileencoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8,cp932
set fileformats=unix,dos,mac

" Add pathogen
execute pathogen#infect()

if has('gui_running')
	if has("gui_gtk2")
		set guifont=Inconsolata\ 12

	elseif has("gui_macvim")
		set lines=40
		set columns=125
		set guifont=Menlo\ Regular:h13
		let g:livepreview_previewer = 'open -a Preview'
		autocmd vimenter * NERDTree """"""/ADD/YOUR/PATH 

	elseif has("gui_win32")
		"set guifont=Consolas:h11:cANSI
		autocmd vimenter * NERDTree """""C:\ADD\YOUR\PATH
		set lines=41
		set columns=160
	endif
endif

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"" quit if only NERDTree left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" color
color happy_hacking
