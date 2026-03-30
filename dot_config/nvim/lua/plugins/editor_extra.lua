return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      current_line_blame = false,
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local map = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
        end

        map("]h", gitsigns.next_hunk, "Next hunk")
        map("[h", gitsigns.prev_hunk, "Previous hunk")
        map("<leader>hs", gitsigns.stage_hunk, "Stage hunk")
        map("<leader>hr", gitsigns.reset_hunk, "Reset hunk")
        map("<leader>hp", gitsigns.preview_hunk, "Preview hunk")
        map("<leader>hb", gitsigns.blame_line, "Blame line")
      end,
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    ft = { "markdown", "md" },
    init = function()
      vim.g.mkdp_filetypes = { "markdown", "md" }
    end,
  },
}
