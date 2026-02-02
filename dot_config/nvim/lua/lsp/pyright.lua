---@brief
---
--- https://github.com/microsoft/pyright
---
--- `pyright`, a static type checker and language server for python

local function set_python_path(command)
  local path = command.args
  local clients = vim.lsp.get_clients {
    bufnr = vim.api.nvim_get_current_buf(),
    name = 'pyright',
  }
  for _, client in ipairs(clients) do
    if client.settings then
      client.settings.python =
        vim.tbl_deep_extend('force', client.settings.python --[[@as table]], { pythonPath = path })
    else
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = path } })
    end
    client:notify('workspace/didChangeConfiguration', { settings = nil })
  end
end

local function get_venv_python(root_dir)
  local base = root_dir or vim.fn.getcwd()
  local win_path = vim.fs.joinpath(base, '.venv', 'Scripts', 'python.exe')
  if vim.uv.fs_stat(win_path) then
    return win_path
  end
  local posix_path = vim.fs.joinpath(base, '.venv', 'bin', 'python')
  if vim.uv.fs_stat(posix_path) then
    return posix_path
  end
  return nil
end

---@type vim.lsp.Config
return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyrightconfig.json',
    'pyproject.toml',
    'setup.py',
    'setup.cfg',
    'requirements.txt',
    'Pipfile',
    '.git',
  },
  settings = {
    python = {
      pythonPath = get_venv_python(vim.fn.getcwd()),
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
  on_init = function(client)
    local venv_python = get_venv_python(client.config.root_dir)
    if venv_python then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        python = { pythonPath = venv_python },
      })
    end
  end,
  on_attach = function(client, bufnr)
    local venv_python = get_venv_python(client.config.root_dir)
    if venv_python then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        python = { pythonPath = venv_python },
      })
      client:notify('workspace/didChangeConfiguration', { settings = nil })
    end
    vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', function()
      local params = {
        command = 'pyright.organizeimports',
        arguments = { vim.uri_from_bufnr(bufnr) },
      }

      -- Using client.request() directly because "pyright.organizeimports" is private
      -- (not advertised via capabilities), which client:exec_cmd() refuses to call.
      -- https://github.com/neovim/neovim/blob/c333d64663d3b6e0dd9aa440e433d346af4a3d81/runtime/lua/vim/lsp/client.lua#L1024-L1030
      ---@diagnostic disable-next-line: param-type-mismatch
      client.request('workspace/executeCommand', params, nil, bufnr)
    end, {
      desc = 'Organize Imports',
    })
    vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', set_python_path, {
      desc = 'Reconfigure pyright with the provided python path',
      nargs = 1,
      complete = 'file',
    })
  end,
}
