-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
    "preservim/nerdtree",
    "nordtheme/vim",
    "vim-airline/vim-airline",
    "vim-airline/vim-airline-themes",
    "neovim/nvim-lspconfig",
    -- install with yarn or npm
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown", "md" }
      end,
      ft = { "markdown", "md" },
    },
    {
      "epwalsh/obsidian.nvim",
      version = "*",  -- recommended, use latest release instead of latest commit
      lazy = true,
      ft = "markdown",
      -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
      -- event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
      --   -- refer to `:h file-pattern` for more examples
      --   "BufReadPre path/to/my-vault/*.md",
      --   "BufNewFile path/to/my-vault/*.md",
      -- },
      dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",
    
        -- see below for full list of optional dependencies 👇
      },
      opts = {
        workspaces = {
          {
            name = "note",
            path = "C:\\Users\\shi\\iCloudDrive\\iCloud~md~obsidian\\note",
          },
        },
        -- see below for full list of options 👇
      },
    }
  },
  checker = { enabled = true },
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

-- lsp custom lua script
-- load lsp
require('lsp.pyright')
vim.lsp.enable('pyright')

--load vimrc.vim
local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)
