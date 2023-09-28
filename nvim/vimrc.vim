syntax on
set number
" set relativenumber
set tabstop=4
set expandtab      " 使用空格代替制表符
set shiftwidth=4   " 自动缩进宽度
set smartindent    " 智能自动缩进
set wrap           " 自动换行
set ignorecase     " 搜索时忽略大小写
set smartcase      " 如果搜索中有大写字母则区分大小写
set incsearch      " 增量搜索
set mouse=a        " 启用鼠标支持
set clipboard+=unnamedplus " 与系统剪贴板共享

" encode
set encoding=utf-8

set fileencoding=utf-8
"set fileencodings=iso-2022-jp,euc-jp,sjis,utf-8,cp932
set fileencodings=utf-8,cp932
set fileformats=unix,dos,mac

" 快捷键映射
nnoremap <F8> :NERDTreeToggle<CR>
nnoremap <F9> :AsyncRun python %<CR>
nnoremap <F10> :AsyncRun gcc -Wall -o %:r %<CR>
nnoremap <F12> :ALEToggle<CR>

" 启动调试会话
nmap <F5> :call vimspector#Launch()<CR>

" 设置断点
nmap <F9> :call vimspector#ToggleBreakpoint()<CR>

" 单步执行
nmap <F10> :call vimspector#Continue()<CR>
nmap <F11> :call vimspector#StepOver()<CR>
nmap <F12> :call vimspector#StepInto()<CR>


" 设置 Coc.nvim
let g:coc_global_extensions = ['coc-snippets', 'coc-python', 'coc-ccls', 'coc-json', 'coc-highlight']

" 在 vimspector 配置中设置 Python 解释器路径
let g:vimspector_install_gadgets = [ { 'name': 'python' } ]
let g:vimspector_py_path = '/Users/shi/.virtualenv/py311/bin/python'


" Start NERDTree when Vim starts with a directory argument.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
    \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
" Exit Vim if NERDTree is the only window remaining in the only tab.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
