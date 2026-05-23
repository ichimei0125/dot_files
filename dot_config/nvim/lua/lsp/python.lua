local lsp = require("config.lsp")

local M = {}

local uv = vim.uv or vim.loop
local notified_venv_roots = {}
local project_root_markers = {
  "ty.toml",
  "pyproject.toml",
  "setup.py",
  "setup.cfg",
  "requirements.txt",
  "Pipfile",
  ".git",
}

local function path_exists(path)
  return path and uv.fs_stat(path) ~= nil
end

local function path_is_dir(path)
  local stat = path and uv.fs_stat(path)
  return stat and stat.type == "directory"
end

local function executable(path)
  return path and vim.fn.executable(path) == 1
end

local function normalize_path(path)
  if not path or path == "" then
    return nil
  end

  if vim.startswith(path, "file://") then
    return vim.fs.normalize(vim.uri_to_fname(path))
  end

  return vim.fs.normalize(path)
end

local function normalize_dir(path)
  local normalized = normalize_path(path)
  if not normalized then
    return nil
  end

  local stat = uv.fs_stat(normalized)
  if stat and stat.type == "file" then
    return vim.fs.dirname(normalized)
  end

  return normalized
end

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Python IDE" })
  end)
end

local function find_project_root(path)
  local start = normalize_dir(path) or vim.fn.getcwd()
  local marker = vim.fs.find(project_root_markers, { path = start, upward = true })[1]

  if marker then
    return vim.fs.dirname(marker)
  end

  return start
end

local function find_venv(path)
  local start = normalize_dir(path) or vim.fn.getcwd()
  local root = find_project_root(start)
  local dir = start

  while dir do
    for _, name in ipairs({ ".venv", "venv" }) do
      local venv = vim.fs.joinpath(dir, name)
      if path_is_dir(venv) then
        return venv
      end
    end

    if dir == root then
      break
    end

    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then
      break
    end

    dir = parent
  end
end

local function get_python_path(root_dir)
  local base = normalize_dir(root_dir) or vim.fn.getcwd()
  local candidates = {}
  local add_candidate = function(path)
    if path then
      table.insert(candidates, path)
    end
  end

  if vim.env.VIRTUAL_ENV then
    add_candidate(vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python"))
    add_candidate(vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python3"))
    add_candidate(vim.fs.joinpath(vim.env.VIRTUAL_ENV, "Scripts", "python.exe"))
  end

  local venv = find_venv(base)
  if venv then
    add_candidate(vim.fs.joinpath(venv, "bin", "python"))
    add_candidate(vim.fs.joinpath(venv, "bin", "python3"))
    add_candidate(vim.fs.joinpath(venv, "Scripts", "python.exe"))
  end

  for _, path in ipairs(candidates) do
    if path_exists(path) then
      return path
    end
  end

  local python3 = vim.fn.exepath("python3")
  if python3 ~= "" then
    return python3
  end

  local python = vim.fn.exepath("python")
  if python ~= "" then
    return python
  end
end

local function set_python_path(command)
  local path = normalize_path(command.args)
  if not path then
    return
  end

  local executable_path = vim.fn.exepath(path)
  if executable_path ~= "" then
    path = executable_path
  elseif not path_exists(path) then
    local absolute_path = vim.fn.fnamemodify(path, ":p")
    if not path_exists(absolute_path) then
      notify(("Python path does not exist: %s"):format(path), vim.log.levels.WARN)
      return
    end
    path = absolute_path
  end

  local clients = vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    name = "ty",
  })

  for _, client in ipairs(clients) do
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
      ty = {
        configuration = {
          environment = {
            python = path,
          },
        },
      },
    })
    client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
  end
end

local function configure_ty_python(config, root_dir)
  local python_path = get_python_path(root_dir)
  if not python_path then
    return
  end

  config.settings = config.settings or {}
  config.settings.ty = config.settings.ty or {}
  config.settings.ty.configuration = config.settings.ty.configuration or {}
  config.settings.ty.configuration.environment = config.settings.ty.configuration.environment or {}
  config.settings.ty.configuration.environment.python = python_path
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
  local root = find_project_root(root_dir)
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
    { module = "pytest", package = "pytest" },
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

local function ty_config()
  return {
    cmd = { "ty", "server" },
    filetypes = { "python" },
    root_markers = project_root_markers,
    settings = {
      ty = {
        diagnosticMode = "workspace",
        completions = {
          autoImport = true,
        },
        configuration = {},
      },
    },
    before_init = function(_, config)
      configure_ty_python(config, config.root_dir)
    end,
    on_attach = function(client, bufnr)
      vim.api.nvim_buf_create_user_command(bufnr, "LspTySetPythonPath", set_python_path, {
        desc = "Reconfigure ty with the provided python path",
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

local function setup_ty()
  if not executable("ty") then
    notify("ty not found. Install it manually if needed.", vim.log.levels.WARN)
    return
  end

  local config = ty_config()
  config.capabilities = lsp.capabilities()

  vim.lsp.config("ty", config)
  vim.lsp.enable("ty")
end

local function setup_ruff()
  if not executable("ruff") then
    notify("ruff not found. Install it manually if needed.", vim.log.levels.WARN)
    return
  end

  vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = {
      "pyproject.toml",
      "ruff.toml",
      ".ruff.toml",
      ".git",
    },
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

local function attach_enabled_lsps_to_python_buffers()
  vim.defer_fn(function()
    pcall(vim.cmd.doautoall, "nvim.lsp.enable FileType")
  end, 250)
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

  dap_python.setup("debugpy-adapter", { include_configs = false })
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

  setup_ty()
  setup_ruff()
  attach_enabled_lsps_to_python_buffers()
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
