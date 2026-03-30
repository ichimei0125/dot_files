---@brief
--- https://github.com/microsoft/pyright
--- `pyright`, a static type checker and language server for python

local M = {}

local function fs_stat(path)
  return path and (vim.uv or vim.loop).fs_stat(path)
end

local function executable(path)
  return path and vim.fn.executable(path) == 1
end

function M.get_python_path(root_dir)
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
    if fs_stat(path) then
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

M.config = {
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
      pythonPath = M.get_python_path(vim.fn.getcwd()),
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
    local python_path = M.get_python_path(client.config.root_dir)
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
      python = { pythonPath = python_path },
    })
  end,
  on_attach = function(client, bufnr)
    local python_path = M.get_python_path(client.config.root_dir)
    client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
      python = { pythonPath = python_path },
    })
    client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })

    vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
      desc = "Reconfigure pyright with the provided python path",
      nargs = 1,
      complete = "file",
    })
  end,
}

return M
