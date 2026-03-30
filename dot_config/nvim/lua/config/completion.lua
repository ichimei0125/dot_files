local M = {}

local kind_icons = {
  Class = "[C]",
  Color = "[Color]",
  Constant = "[Const]",
  Constructor = "[New]",
  Enum = "[Enum]",
  EnumMember = "[Item]",
  Event = "[Event]",
  Field = "[Field]",
  File = "[File]",
  Folder = "[Dir]",
  Function = "[Fn]",
  Interface = "[If]",
  Keyword = "[Key]",
  Method = "[Meth]",
  Module = "[Mod]",
  Operator = "[Op]",
  Property = "[Prop]",
  Reference = "[Ref]",
  Snippet = "[Snip]",
  Struct = "[Struct]",
  Text = "[Txt]",
  TypeParameter = "[Type]",
  Unit = "[Unit]",
  Value = "[Val]",
  Variable = "[Var]",
}

function M.setup()
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  require("luasnip.loaders.from_vscode").lazy_load()

  cmp.setup({
    completion = {
      completeopt = "menu,menuone,noinsert",
    },
    experimental = {
      ghost_text = true,
    },
    preselect = cmp.PreselectMode.None,
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    window = {
      completion = cmp.config.window.bordered({
        border = "rounded",
        scrollbar = false,
      }),
      documentation = cmp.config.window.bordered({
        border = "rounded",
      }),
    },
    formatting = {
      fields = { "kind", "abbr", "menu" },
      format = function(entry, item)
        item.kind = string.format("%s %s", kind_icons[item.kind] or "", item.kind)
        item.menu = ({
          nvim_lsp = "[LSP]",
          luasnip = "[Snip]",
          path = "[Path]",
          buffer = "[Buf]",
        })[entry.source.name]
        return item
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = false }),
      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
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
      { name = "nvim_lsp", priority = 1000 },
      { name = "luasnip", priority = 750 },
      { name = "path", priority = 500 },
    }, {
      { name = "buffer", priority = 250 },
    }),
    sorting = {
      priority_weight = 2,
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.recently_used,
        cmp.config.compare.locality,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    },
  })
end

return M
