local map = vim.keymap.set

local function delete_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local windows = vim.fn.win_findbuf(bufnr)
  local listed = vim.fn.getbufinfo({ buflisted = 1 })

  if vim.bo[bufnr].modified then
    vim.notify("Buffer has unsaved changes", vim.log.levels.WARN, { title = "Buffers" })
    return
  end

  if #listed == 1 then
    vim.cmd("enew")
    vim.api.nvim_buf_delete(bufnr, { force = false })
    return
  end

  for _, win in ipairs(windows) do
    vim.api.nvim_win_call(win, function()
      vim.cmd("bprevious")
    end)
  end

  vim.api.nvim_buf_delete(bufnr, { force = false })
end

map("n", "<F8>", "<cmd>Neotree toggle filesystem reveal left<cr>", { desc = "Toggle explorer", silent = true })
map("n", "<leader>e", "<cmd>Neotree toggle filesystem reveal left<cr>", { desc = "Explorer", silent = true })

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files", silent = true })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Recent files", silent = true })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live grep", silent = true })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers", silent = true })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help tags", silent = true })

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics", silent = true })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics", silent = true })
map("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols", silent = true })
map("n", "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", { desc = "LSP references", silent = true })
map("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix", silent = true })

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all", silent = true })
map("n", "<leader>bd", delete_current_buffer, { desc = "Delete buffer", silent = true })
