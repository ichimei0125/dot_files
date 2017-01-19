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
  " do stuff under linux 
elseif has("win32")
	set encoding=cp932 " for Japanese enviroment
endif
set shellslash
set fileencoding=utf-8
set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8,cp932
set fileformats=unix,dos,mac

" Add pathogen
execute pathogen#infect()

if has('gui_running')
	" set Boolmark workspace or whatever you want
	autocmd vimenter * NERDTree workspace

	if has("gui_gtk2")
		set guifont=Inconsolata\ 12

	elseif has("gui_macvim")
		set lines=40
		set columns=125
		set guifont=Menlo\ Regular:h13
		let g:livepreview_previewer = 'open -a Preview'

	elseif has("gui_win32")
		set shellslash " for vim-latex in win32
		"set guifont=Consolas:h11:cANSI
		set lines=41
		set columns=160
	endif
endif

"-----vim-latex-----
" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
filetype plugin on
" IMPORTANT: grep will sometimes skip displaying the file name if you
" search in a singe file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*

" OPTIONAL: This enables automatic indentation as you type.
filetype indent on

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'

" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
set sw=2
" TIP: if you write your \label's as \label{fig:something}, then if you
" type in \ref{fig: and press <C-n> you will automatically cycle through
" all the figure labels. Very useful!
set iskeyword+=:

" -----NERDTree-----
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"" quit if only NERDTree left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" -----color-----
color happy_hacking
