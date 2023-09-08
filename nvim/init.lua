local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	"preservim/nerdtree",
	"nordtheme/vim",
	"vim-airline/vim-airline",
	"vim-airline/vim-airline-themes",
	"davidhalter/jedi-vim",
--	"jeetsukumaran/vim-pythonsense",
--	"mhinz/vim-signify",
  	'puremourning/vimspector',
    -- 使用异步加载插件
	'skywind3000/asyncrun.vim',
   	'dense-analysis/ale',
    {'neoclide/coc.nvim', branch = 'release'},

    
    -- Python 开发相关插件
    'vim-python/python-syntax',
    {'numirias/semshi',cmd='UpdateRemotePlugins'}
    
})

--load vimrc.vim
local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)
