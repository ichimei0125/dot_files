local pyright = require("lsp.pyright")

local function python_path(root_dir)
  return pyright.get_python_path(root_dir)
end

local uv = vim.uv or vim.loop
local ensured_venv_roots = {}

local function path_exists(path)
  return path and uv.fs_stat(path) ~= nil
end

local function find_venv(root_dir)
  local root = root_dir or vim.fn.getcwd()
  local candidates = {
    vim.fs.joinpath(root, ".venv"),
    vim.fs.joinpath(root, "venv"),
  }

  for _, venv in ipairs(candidates) do
    if path_exists(venv) then
      return venv
    end
  end
end

local function venv_python(venv)
  if not venv then
    return nil
  end

  local candidates = {
    vim.fs.joinpath(venv, "bin", "python"),
    vim.fs.joinpath(venv, "Scripts", "python.exe"),
  }

  for _, py in ipairs(candidates) do
    if path_exists(py) then
      return py
    end
  end
end

local function local_venv_bin(root_dir, name)
  local venv = find_venv(root_dir)
  if not venv then
    return nil
  end

  local candidates = {
    vim.fs.joinpath(venv, "bin", name),
    vim.fs.joinpath(venv, "Scripts", name .. ".exe"),
  }

  for _, candidate in ipairs(candidates) do
    if path_exists(candidate) then
      return candidate
    end
  end
end

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Python venv" })
  end)
end

local function ensure_venv_python_packages(root_dir)
  local root = root_dir or vim.fn.getcwd()
  if ensured_venv_roots[root] then
    return
  end

  local venv = find_venv(root)
  if not venv then
    return
  end

  local py = venv_python(venv)
  if not py then
    notify(("发现虚拟环境但没找到 python: %s"):format(venv), vim.log.levels.WARN)
    return
  end

  ensured_venv_roots[root] = true

  local required_modules = {
    { module = "debugpy", package = "debugpy" },
    { module = "pytest", package = "pytest" },
    { module = "ruff", package = "ruff" },
    { module = "black", package = "black" },
    { module = "isort", package = "isort" },
  }

  local missing = {}
  for _, item in ipairs(required_modules) do
    local result = vim.system({
      py,
      "-c",
      ([[import importlib.util, sys; sys.exit(0 if importlib.util.find_spec(%q) else 1)]]):format(item.module),
    }, { text = true }):wait()

    if result.code ~= 0 then
      table.insert(missing, item.package)
    end
  end

  if #missing == 0 then
    return
  end

  notify(("%s 缺失，正在安装到 %s"):format(table.concat(missing, ", "), venv))

  vim.system({
    py,
    "-m",
    "pip",
    "install",
    "--disable-pip-version-check",
    unpack(missing),
  }, { text = true }, function(result)
    if result.code == 0 then
      notify(("已安装到项目虚拟环境: %s"):format(table.concat(missing, ", ")))
    else
      local err = (result.stderr or result.stdout or "unknown error"):gsub("%s+$", "")
      notify(("安装失败: %s"):format(err), vim.log.levels.ERROR)
    end
  end)
end

local ok_mason, mason = pcall(require, "mason")
if ok_mason then
  mason.setup()
end

pcall(function()
  require("mason-tool-installer").setup({
    ensure_installed = {
      "pyright",
      "ruff",
      "debugpy",
      "black",
      "isort",
    },
    auto_update = false,
    run_on_start = true,
    start_delay = 3000,
  })
end)

pcall(function()
  require("mason-lspconfig").setup({
    ensure_installed = { "pyright", "ruff" },
    automatic_enable = false,
  })
end)

pcall(function()
  require("luasnip.loaders.from_vscode").lazy_load()
end)

local capabilities = vim.lsp.protocol.make_client_capabilities()
local ok_cmp_lsp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_lsp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

pyright.capabilities = capabilities
vim.lsp.config("pyright", pyright)
vim.lsp.enable("pyright")

vim.lsp.config("ruff", {
  capabilities = capabilities,
  init_options = {
    settings = {
      args = {},
    },
  },
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
})
vim.lsp.enable("ruff")

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
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
      { name = "buffer" },
    }),
  })
end

pcall(function()
  require("conform").setup({
    notify_on_error = true,
    format_on_save = function(bufnr)
      if vim.bo[bufnr].filetype == "python" then
        return {
          timeout_ms = 2000,
          lsp_fallback = false,
        }
      end
    end,
    formatters_by_ft = {
      python = { "isort", "black" },
    },
    formatters = {
      isort = {
        command = function()
          return local_venv_bin(vim.fn.getcwd(), "isort") or "isort"
        end,
      },
      black = {
        command = function()
          return local_venv_bin(vim.fn.getcwd(), "black") or "black"
        end,
      },
    },
  })
end)

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr, silent = true }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "LSP Goto Definition" }))
    vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("force", opts, { desc = "LSP References" }))
    vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "LSP Hover" }))
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", opts, { desc = "LSP Rename" }))
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", opts, { desc = "LSP Code Action" }))
    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ async = true, lsp_fallback = true, bufnr = bufnr })
    end, vim.tbl_extend("force", opts, { desc = "Format Buffer" }))
    vim.keymap.set("n", "<leader>oi", function()
      local filename = vim.api.nvim_buf_get_name(bufnr)
      local ruff_cmd = local_venv_bin(vim.fn.getcwd(), "ruff") or "ruff"
      vim.system({ ruff_cmd, "check", "--select", "I", "--fix", filename }, { text = true }):wait()
      vim.cmd("edit")
    end, vim.tbl_extend("force", opts, { desc = "Organize Imports (ruff)" }))
  end,
})

local ok_dap, dap = pcall(require, "dap")
local ok_dapui, dapui = pcall(require, "dapui")
local ok_dap_python, dap_python = pcall(require, "dap-python")
if ok_dap and ok_dap_python then
  ensure_venv_python_packages(vim.fn.getcwd())
  dap_python.setup(python_path(vim.fn.getcwd()))
  dap_python.test_runner = "pytest"

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch current file",
      program = "${file}",
      pythonPath = function()
        return python_path(vim.fn.getcwd())
      end,
      console = "integratedTerminal",
      cwd = "${workspaceFolder}",
      justMyCode = true,
    },
    {
      type = "python",
      request = "launch",
      name = "Pytest current file",
      module = "pytest",
      args = { "${file}" },
      pythonPath = function()
        return python_path(vim.fn.getcwd())
      end,
      console = "integratedTerminal",
      cwd = "${workspaceFolder}",
      justMyCode = true,
    },
  }

  vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "", numhl = "" })

  map("n", "<F5>", function() dap.continue() end, "DAP Continue")
  map("n", "<F10>", function() dap.step_over() end, "DAP Step Over")
  map("n", "<F11>", function() dap.step_into() end, "DAP Step Into")
  map("n", "<F12>", function() dap.step_out() end, "DAP Step Out")
  map("n", "<leader>db", function() dap.toggle_breakpoint() end, "DAP Toggle Breakpoint")
  map("n", "<leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, "DAP Conditional Breakpoint")
  map("n", "<leader>dr", function() dap.repl.open() end, "DAP Open REPL")
  map("n", "<leader>du", function()
    if ok_dapui then
      dapui.toggle({})
    end
  end, "DAP UI Toggle")
  map("n", "<leader>dt", function() dap_python.test_method() end, "DAP Debug Test Method")
  map("n", "<leader>df", function() dap_python.test_class() end, "DAP Debug Test Class")

  if ok_dapui then
    dapui.setup()
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end
  end
end

vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function(args)
    local dir = (args and args.file ~= "") and args.file or vim.fn.getcwd()
    ensure_venv_python_packages(dir)
  end,
})
