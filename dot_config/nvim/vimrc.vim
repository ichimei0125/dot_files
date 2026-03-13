syntax on
set number
set relativenumber
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set smartindent
set wrap
set ignorecase
set smartcase
set incsearch
set mouse=a
set clipboard+=unnamedplus
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8,cp932
set fileformats=unix,dos,mac
set signcolumn=yes
set updatetime=250
set termguicolors
set completeopt=menu,menuone,noselect
set cursorline

nnoremap <F8> :NERDTreeToggle<CR>

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
