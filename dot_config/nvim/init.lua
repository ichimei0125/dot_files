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

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function()
        require("catppuccin").setup({
          flavour = "mocha",
          integrations = {
            cmp = true,
            mason = true,
            noice = true,
            notify = true,
            treesitter = true,
            which_key = true,
            native_lsp = {
              enabled = true,
            },
          },
        })
        vim.cmd.colorscheme("catppuccin")
      end,
    },
    "nvim-tree/nvim-web-devicons",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
      },
      cmd = "Neotree",
      keys = {
        { "<F8>", "<cmd>Neotree toggle filesystem reveal left<cr>", desc = "Toggle file explorer" },
      },
      opts = {
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
        },
        window = {
          position = "left",
          width = 32,
        },
      },
      init = function()
        vim.api.nvim_create_autocmd("VimEnter", {
          callback = function(data)
            local directory = vim.fn.isdirectory(data.file) == 1
            if not directory then
              return
            end

            vim.cmd.cd(data.file)
            require("neo-tree.command").execute({
              toggle = false,
              dir = data.file,
              position = "left",
            })
          end,
        })
      end,
    },
    {
      "nvim-lualine/lualine.nvim",
      event = "VeryLazy",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = function()
        return {
          options = {
            theme = require("catppuccin.utils.lualine")("mocha"),
            globalstatus = true,
            section_separators = { left = "", right = "" },
            component_separators = { left = "", right = "" },
          },
        }
      end,
    },
    {
      "rcarriga/nvim-notify",
      event = "VeryLazy",
      opts = {
        background_colour = "#1e1e2e",
        fps = 60,
        render = "compact",
        stages = "fade_in_slide_out",
        timeout = 2500,
        top_down = false,
      },
      config = function(_, opts)
        local notify = require("notify")
        notify.setup(opts)
        vim.notify = notify
      end,
    },
    {
      "folke/noice.nvim",
      event = "VeryLazy",
      dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
      },
      opts = {
        lsp = {
          progress = { enabled = false },
          hover = { enabled = true },
          signature = { enabled = true },
        },
        messages = {
          enabled = true,
        },
        notify = {
          enabled = true,
          view = "notify",
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      },
    },
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {
        preset = "modern",
        delay = 300,
        spec = {
          { "<leader>f", group = "find" },
          { "<leader>x", group = "diagnostics" },
        },
      },
    },
    {
      "nvim-telescope/telescope.nvim",
      branch = "0.1.x",
      cmd = "Telescope",
      dependencies = { "nvim-lua/plenary.nvim" },
      keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      },
      opts = {
        defaults = {
          layout_strategy = "horizontal",
          layout_config = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          sorting_strategy = "ascending",
          winblend = 0,
        },
      },
    },
    {
      "folke/trouble.nvim",
      cmd = "Trouble",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
        { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
        { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP references" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
      },
      opts = {
        focus = true,
        warn_no_results = false,
      },
    },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    "mfussenegger/nvim-dap",
    "mfussenegger/nvim-dap-python",
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "stevearc/conform.nvim",
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown", "md" }
      end,
      ft = { "markdown", "md" },
    },
  },
  checker = { enabled = true },
})

local function load_python_ide()
  if vim.g.loaded_python_ide == 1 then
    return
  end
  vim.g.loaded_python_ide = 1
  require("lsp.python")
end

if vim.bo.filetype == "python" then
  load_python_ide()
else
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = load_python_ide,
  })
end

local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
vim.cmd.source(vimrc)
