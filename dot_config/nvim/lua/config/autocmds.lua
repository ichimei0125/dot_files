local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = augroup("user_yank_highlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

autocmd("VimResized", {
  group = augroup("user_resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

local function load_python_ide()
  if vim.g.loaded_python_ide == 1 then
    return
  end

  vim.g.loaded_python_ide = 1

  local ok, err = pcall(function()
    require("lazy").load({
      plugins = {
        "nvim-dap",
        "nvim-dap-ui",
        "nvim-dap-python",
        "nvim-nio",
        "conform.nvim",
      },
    })

    require("lsp.python").setup()
  end)

  if not ok then
    vim.g.loaded_python_ide = 0
    vim.schedule(function()
      vim.notify(err, vim.log.levels.ERROR, { title = "Python IDE" })
    end)
  end
end

autocmd("FileType", {
  group = augroup("user_python_ide", { clear = true }),
  pattern = "python",
  callback = function()
    vim.schedule(load_python_ide)
  end,
})

if vim.bo.filetype == "python" then
  vim.schedule(load_python_ide)
end
