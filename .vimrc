syntax on
set number
set relativenumber
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
" execute pathogen#infect('bundle/{}')

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
"call plug#begin('~/.vim/plugged')
"call plug#begin('C:\Users\y_shi\Vim\vimfiles\plugged')
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'arcticicestudio/nord-vim'
"Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

if has('gui_running')
	colorscheme nord

	autocmd vimenter * NERDTree workspace
	let NERDTreeShowBookmarks=1

	if has("gui_gtk2")
		set guifont=Inconsolata\ 12

	elseif has("gui_macvim")
		set lines=70
		set columns=180
		set guifont=Menlo\ Regular:h13
		set guioptions-=L  "remove left-hand scroll bar

	elseif has("gui_win32")
		"set guifont=Consolas:h11:cANSI
		set guifont=MS_Gothic:h14
		set lines=42
		set columns=150	
		set guioptions-=L  "remove left-hand scroll bar
		set guioptions-=T  "remove toolbar
		set guioptions-=m  "remove menubar
	endif
endif

" NerdTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
"" quit if only NERDTree left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
let NERDTreeShowHidden=1 " show dotfiles

