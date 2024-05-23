syntax on
set number
"set relativenumber
set tabstop=4
set nowrap
set hlsearch

" encode
set encoding=utf-8
"if has("mac")
"	set encoding=utf-8
"elseif has("unix")
 " do stuff under linux and "
"elseif has("win32")
	" set encoding=cp932
"set encoding=utf-8
"endif

set fileencoding=utf-8
"set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8,cp932
set fileformats=unix,dos,mac

call plug#begin()
" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'
Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'nordtheme/vim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'easymotion/vim-easymotion'
Plug 'davidhalter/jedi-vim'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

set background=dark
colorscheme nord

if has('gui_running')

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
		set guifont=Inconsolata\ Nerd\ Font\ Mono:h14
		set lines=42
		set columns=170	
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

" MarkdownPreview
	" for fixbug
	" preview page title
	" ${name} will be replace with the file name
"let g:mkdp_page_title = '${name}'
"nmap <C-F5> <Plug>MarkdownPreviewToggle


" 列出所有键映射
function! ListMappings()
    let all_maps = getcompletion('', 'map')
        for map in all_maps
                echo map
                    endfor
                    endfunction

                    " 为了在 Vim 中执行该函数，你可以创建一个自定义命令
                    command! ListAllMappings call ListMappings()
