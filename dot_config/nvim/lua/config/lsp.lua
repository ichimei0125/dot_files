local M = {}

function M.capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
  end
  return capabilities
end

function M.on_attach(client, bufnr)
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Goto definition")
  map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
  map("n", "gi", vim.lsp.buf.implementation, "Goto implementation")
  map("n", "gr", vim.lsp.buf.references, "References")
  map("n", "K", vim.lsp.buf.hover, "Hover")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
  map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  map("n", "<leader>cf", function()
    local ok, conform = pcall(require, "conform")
    if ok then
      conform.format({ async = true, bufnr = bufnr, lsp_fallback = true })
      return
    end

    vim.lsp.buf.format({ async = true, bufnr = bufnr })
  end, "Format buffer")

  if client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup("user_lsp_highlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

function M.setup()
  local lsp_servers = {
    "lua_ls",
    "ty",
    "ruff",
  }

  local tools = {
    "black",
    "debugpy",
    "isort",
    "tree-sitter-cli",
  }

  vim.diagnostic.config({
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 2,
      source = "if_many",
      prefix = "●",
    },
    float = {
      border = "rounded",
      source = "if_many",
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = "E",
        [vim.diagnostic.severity.WARN] = "W",
        [vim.diagnostic.severity.INFO] = "I",
        [vim.diagnostic.severity.HINT] = "H",
      },
    },
  })

  require("mason-tool-installer").setup({
    ensure_installed = tools,
    auto_update = false,
    run_on_start = true,
    start_delay = 2000,
  })

  require("mason-lspconfig").setup({
    ensure_installed = lsp_servers,
    automatic_enable = false,
  })

  vim.lsp.config("lua_ls", {
    capabilities = M.capabilities(),
    on_attach = M.on_attach,
    settings = {
      Lua = {
        completion = {
          callSnippet = "Replace",
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          checkThirdParty = false,
        },
      },
    },
  })

  vim.lsp.enable("lua_ls")
end

return M
