return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      integrations = {
        cmp = true,
        gitsigns = true,
        mason = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotree = true,
        noice = true,
        notify = true,
        telescope = true,
        treesitter = true,
        which_key = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
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
        { "<leader>b", group = "buffers" },
        { "<leader>c", group = "code" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>x", group = "diagnostics" },
      },
    },
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
          disabled_filetypes = {
            statusline = { "dashboard" },
          },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = {
            {
              "filename",
              path = 1,
              symbols = {
                modified = " [+]",
                readonly = " [RO]",
              },
            },
          },
          lualine_x = {
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
            },
            "encoding",
            "filetype",
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
    },
    opts = {
      options = {
        always_show_bufferline = true,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics_dict)
          local parts = {}
          for level, count in pairs(diagnostics_dict) do
            local icon = level:match("error") and "E" or (level:match("warning") and "W" or "I")
            table.insert(parts, icon .. count)
          end
          return table.concat(parts, " ")
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            separator = true,
          },
        },
        separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      local stats = require("lazy").stats()

      local function button(icon, desc, action)
        return {
          icon = icon,
          desc = desc,
          action = action,
          key = "",
        }
      end

      return {
        theme = "doom",
        config = {
          header = {
            "",
            "  Neovim IDE",
            "",
          },
          center = {
            button("F", "Find file", "Telescope find_files"),
            button("R", "Recent files", "Telescope oldfiles"),
            button("G", "Live grep", "Telescope live_grep"),
            button("C", "Config", "edit " .. vim.fn.stdpath("config") .. "/init.lua"),
            button("Q", "Quit", "qa"),
          },
          footer = {
            "",
            string.format("Loaded %d plugins in %.2fms", stats.loaded, stats.startuptime),
          },
        },
      }
    end,
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { enabled = false },
        search = { enabled = false },
      },
    },
    keys = {
      {
        "<leader>sj",
        function()
          require("flash").jump()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash jump",
      },
      {
        "<leader>st",
        function()
          require("flash").treesitter()
        end,
        mode = { "n", "x", "o" },
        desc = "Flash treesitter",
      },
    },
  },
}
