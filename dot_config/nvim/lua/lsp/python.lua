local lsp = require("config.lsp")

local M = {}

local uv = vim.uv or vim.loop
local notified_venv_roots = {}

local function path_exists(path)
  return path and uv.fs_stat(path) ~= nil
end

local function executable(path)
  return path and vim.fn.executable(path) == 1
end

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Python IDE" })
  end)
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

local function get_python_path(root_dir)
  local base = root_dir or vim.fn.getcwd()
  local candidates = {
    vim.env.VIRTUAL_ENV and vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python") or nil,
    vim.env.VIRTUAL_ENV and vim.fs.joinpath(vim.env.VIRTUAL_ENV, "Scripts", "python.exe") or nil,
    vim.fs.joinpath(base, ".venv", "bin", "python"),
    vim.fs.joinpath(base, ".venv", "Scripts", "python.exe"),
    vim.fs.joinpath(base, "venv", "bin", "python"),
    vim.fs.joinpath(base, "venv", "Scripts", "python.exe"),
  }

  for _, path in ipairs(candidates) do
    if path_exists(path) then
      return path
    end
  end

  if executable("python3") then
    return "python3"
  end

  return "python"
end

local function set_python_path(command)
  local path = command.args
  local clients = vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    name = "pyright",
  })

  for _, client in ipairs(clients) do
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
      python = { pythonPath = path },
    })
    client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
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

  for _, path in ipairs(candidates) do
    if path_exists(path) then
      return path
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

local function has_python_module(py, module)
  local result = vim.system({
    py,
    "-c",
    ([[import importlib.util, sys; sys.exit(0 if importlib.util.find_spec(%q) else 1)]]):format(module),
  }, { text = true }):wait()

  return result.code == 0
end

local function notify_missing_venv_python_packages(root_dir)
  local root = root_dir or vim.fn.getcwd()
  if notified_venv_roots[root] then
    return
  end

  local venv = find_venv(root)
  if not venv then
    return
  end

  local py = venv_python(venv)
  if not py then
    notify(("Virtual environment found but python is missing: %s"):format(venv), vim.log.levels.WARN)
    return
  end

  local required_modules = {
    { module = "debugpy", package = "debugpy" },
    { module = "pytest", package = "pytest" },
    { module = "ruff", package = "ruff" },
    { module = "black", package = "black" },
    { module = "isort", package = "isort" },
  }

  local missing = {}
  for _, item in ipairs(required_modules) do
    if not has_python_module(py, item.module) then
      table.insert(missing, item.package)
    end
  end

  if #missing == 0 then
    return
  end

  notified_venv_roots[root] = true
  notify(
    ("Missing project Python packages in %s: %s. Install them manually if needed."):format(
      venv,
      table.concat(missing, ", ")
    ),
    vim.log.levels.WARN
  )
end

local function organize_imports(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local root = vim.fs.dirname(filename)
  local ruff_cmd = local_venv_bin(root, "ruff") or "ruff"

  vim.system({ ruff_cmd, "check", "--select", "I", "--fix", filename }, { text = true }):wait()
  vim.cmd("edit")
end

local function pyright_config()
  return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    },
    settings = {
      python = {
        pythonPath = get_python_path(vim.fn.getcwd()),
        analysis = {
          autoImportCompletions = true,
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          typeCheckingMode = "basic",
          useLibraryCodeForTypes = true,
        },
      },
      pyright = {
        disableOrganizeImports = true,
      },
    },
    on_init = function(client)
      local python_path = get_python_path(client.config.root_dir)
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
        python = { pythonPath = python_path },
      })
    end,
    on_attach = function(client, bufnr)
      local python_path = get_python_path(client.config.root_dir)
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
        python = { pythonPath = python_path },
      })
      client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })

      vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
        desc = "Reconfigure pyright with the provided python path",
        nargs = 1,
        complete = "file",
      })

      lsp.on_attach(client, bufnr)
      vim.keymap.set("n", "<leader>oi", function()
        organize_imports(bufnr)
      end, { buffer = bufnr, silent = true, desc = "Organize imports" })
    end,
  }
end

local function setup_pyright()
  if not executable("pyright-langserver") then
    notify("pyright-langserver not found. Install it manually if needed.", vim.log.levels.WARN)
    return
  end

  local config = pyright_config()
  config.capabilities = lsp.capabilities()

  vim.lsp.config("pyright", config)
  vim.lsp.enable("pyright")
end

local function setup_ruff()
  if not executable("ruff") then
    notify("ruff not found. Install it manually if needed.", vim.log.levels.WARN)
    return
  end

  vim.lsp.config("ruff", {
    capabilities = lsp.capabilities(),
    on_attach = function(client, bufnr)
      client.server_capabilities.hoverProvider = false
      lsp.on_attach(client, bufnr)
    end,
    init_options = {
      settings = {
        args = {},
      },
    },
  })

  vim.lsp.enable("ruff")
end

local function setup_conform()
  if vim.g.loaded_python_conform == 1 then
    return
  end

  vim.g.loaded_python_conform = 1

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
        command = function(_, ctx)
          return local_venv_bin(ctx.dirname, "isort") or "isort"
        end,
      },
      black = {
        command = function(_, ctx)
          return local_venv_bin(ctx.dirname, "black") or "black"
        end,
      },
    },
  })
end

local function setup_dap()
  if vim.g.loaded_python_dap == 1 then
    return
  end

  vim.g.loaded_python_dap = 1

  local dap = require("dap")
  local dapui = require("dapui")
  local dap_python = require("dap-python")

  notify_missing_venv_python_packages(vim.fn.getcwd())

  dap_python.setup(get_python_path(vim.fn.getcwd()))
  dap_python.test_runner = "pytest"

  dap.configurations.python = {
    {
      type = "python",
      request = "launch",
      name = "Launch current file",
      program = "${file}",
      pythonPath = function()
        return get_python_path(vim.fn.getcwd())
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
        return get_python_path(vim.fn.getcwd())
      end,
      console = "integratedTerminal",
      cwd = "${workspaceFolder}",
      justMyCode = true,
    },
  }

  vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "", numhl = "" })

  local map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
  end

  map("<F5>", dap.continue, "DAP continue")
  map("<F10>", dap.step_over, "DAP step over")
  map("<F11>", dap.step_into, "DAP step into")
  map("<F12>", dap.step_out, "DAP step out")
  map("<leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
  map("<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, "Conditional breakpoint")
  map("<leader>dr", dap.repl.open, "Open REPL")
  map("<leader>du", function()
    dapui.toggle({})
  end, "DAP UI")
  map("<leader>dt", dap_python.test_method, "Debug test method")
  map("<leader>df", dap_python.test_class, "Debug test class")

  dapui.setup({
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.50 },
          { id = "breakpoints", size = 0.17 },
          { id = "stacks", size = 0.17 },
          { id = "watches", size = 0.16 },
        },
        position = "right",
        size = 48,
      },
      {
        elements = {
          { id = "repl", size = 0.55 },
          { id = "console", size = 0.45 },
        },
        position = "bottom",
        size = 12,
      },
    },
  })

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

function M.setup()
  if vim.g.loaded_python_ide_config == 1 then
    return
  end

  vim.g.loaded_python_ide_config = 1

  setup_pyright()
  setup_ruff()
  setup_conform()
  setup_dap()

  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    group = vim.api.nvim_create_augroup("user_python_venv", { clear = true }),
    callback = function(args)
      local dir = (args and args.file ~= "") and args.file or vim.fn.getcwd()
      notify_missing_venv_python_packages(dir)
    end,
  })
end

return M
