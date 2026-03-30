return {
  {
    "mfussenegger/nvim-dap",
    lazy = true,
  },
  {
    "nvim-neotest/nvim-nio",
    lazy = true,
  },
  {
    "rcarriga/nvim-dap-ui",
    lazy = true,
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
  },
  {
    "mfussenegger/nvim-dap-python",
    lazy = true,
    dependencies = {
      "mfussenegger/nvim-dap",
      "rcarriga/nvim-dap-ui",
    },
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    cmd = "ConformInfo",
  },
}
