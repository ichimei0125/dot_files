local languages = {
  "bash",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "vim",
  "vimdoc",
  "yaml",
}

local filetypes = {
  "bash",
  "json",
  "lua",
  "markdown",
  "python",
  "vim",
  "vimdoc",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup()

      local function ensure_tree_sitter_cli()
        if vim.fn.executable("tree-sitter") == 1 then
          return true
        end

        local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
        local mason_tree_sitter = vim.fs.joinpath(mason_bin, "tree-sitter")
        if vim.fn.executable(mason_tree_sitter) == 1 then
          local separator = vim.fn.has("win32") == 1 and ";" or ":"
          vim.env.PATH = mason_bin .. separator .. (vim.env.PATH or "")
          return true
        end
      end

      local function install_parsers()
        if not ensure_tree_sitter_cli() then
          return
        end

        local installed = {}
        for _, language in ipairs(treesitter.get_installed("parsers")) do
          installed[language] = true
        end

        local missing = {}
        for _, language in ipairs(languages) do
          if not installed[language] then
            table.insert(missing, language)
          end
        end

        if #missing > 0 then
          treesitter.install(missing, { summary = true })
        end
      end

      install_parsers()

      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("user_treesitter_install", { clear = true }),
        pattern = "MasonToolsUpdateCompleted",
        callback = install_parsers,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter_start", { clear = true }),
        pattern = filetypes,
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
