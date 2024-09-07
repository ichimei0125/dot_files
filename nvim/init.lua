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
  'mfussenegger/nvim-dap',
  'mfussenegger/nvim-dap-ui',
})

-- nvim-dap 快捷键配置
local dap = require('dap')
-- 设置 VSCode 风格的快捷键
vim.api.nvim_set_keymap('n', '<F5>', ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F10>', ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F11>', ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<S-F11>', ":lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F9>', ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
-- 如果你想设置带条件的断点
vim.api.nvim_set_keymap('n', '<leader>bc', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { noremap = true, silent = true })
-- 打开调试终端 (如果你想在调试时查看变量等信息)
vim.api.nvim_set_keymap('n', '<leader>dt', ":lua require'dap'.repl.open()<CR>", { noremap = true, silent = true })


if vim.g.neovide then
    -- Put anything you want to happen only in Neovide here
    vim.cmd("colorscheme nord")
    vim.o.guifont = "Inconsolata Nerd Font Mono:h14" -- text below applies for VimScript
end

--load vimrc.vim
local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)
