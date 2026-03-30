return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = true,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("config.lsp").setup()
    end,
  },
}
