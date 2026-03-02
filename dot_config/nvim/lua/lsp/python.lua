local function get_venv_python(root_dir)
  local base = root_dir or vim.fn.getcwd()
  local win_path = vim.fs.joinpath(base, ".venv", "Scripts", "python.exe")
  if vim.uv.fs_stat(win_path) then
    return win_path
  end
  local posix_path = vim.fs.joinpath(base, ".venv", "bin", "python")
  if vim.uv.fs_stat(posix_path) then
    return posix_path
  end
  return "python"
end

local pyright = require("lsp.pyright")
local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_lsp then
  pyright.capabilities = cmp_lsp.default_capabilities()
end
vim.lsp.config("pyright", pyright)
vim.lsp.enable("pyright")

local ok_cmp, cmp = pcall(require, "cmp")
local ok_luasnip, luasnip = pcall(require, "luasnip")
if ok_cmp and ok_luasnip then
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping.select_next_item(),
      ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    }),
  })
end

local ok_dap_python, dap_python = pcall(require, "dap-python")
if ok_dap_python then
  dap_python.setup(get_venv_python(vim.fn.getcwd()))
  vim.keymap.set("n", "<F5>", function() require("dap").continue() end, { desc = "DAP Continue" })
  vim.keymap.set("n", "<F10>", function() require("dap").step_over() end, { desc = "DAP Step Over" })
  vim.keymap.set("n", "<F11>", function() require("dap").step_into() end, { desc = "DAP Step Into" })
  vim.keymap.set("n", "<F12>", function() require("dap").step_out() end, { desc = "DAP Step Out" })
  vim.keymap.set("n", "<leader>b", function() require("dap").toggle_breakpoint() end, { desc = "DAP Toggle Breakpoint" })
  vim.keymap.set("n", "<leader>B", function()
    require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "DAP Conditional Breakpoint" })
  vim.keymap.set("n", "<leader>dr", function() require("dap").repl.open() end, { desc = "DAP Open REPL" })
end
