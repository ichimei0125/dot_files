return {
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
  },
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      require("config.completion").setup()
    end,
  },
}
