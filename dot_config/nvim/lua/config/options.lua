vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.mouse = "a"
opt.wrap = false
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.termguicolors = true
opt.clipboard:append("unnamedplus")
opt.completeopt = { "menu", "menuone", "noselect" }
opt.confirm = true
opt.expandtab = true
opt.shiftwidth = 4
opt.smartcase = true
opt.smartindent = true
opt.ignorecase = true
opt.incsearch = true
opt.pumheight = 12
opt.laststatus = 3
opt.showmode = false
opt.timeoutlen = 300
opt.updatetime = 250
opt.tabstop = 4
opt.softtabstop = 4
opt.undofile = true
opt.winminwidth = 5
opt.fileencoding = "utf-8"
opt.fileencodings = { "utf-8", "cp932" }
opt.fileformats = { "unix", "dos", "mac" }
opt.encoding = "utf-8"
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
