local cmp = require("cmp")
local lspkind = require("lspkind")
vim.fn['skkeleton#initialize']()
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered({
      border = 'rounded'
    }),
    documentation = cmp.config.window.bordered({
      border = 'rounded'
    }),
  },
  sources = cmp.config.sources({
      { name = "skkeleton" },
    },
    {
      { name = "nvim_lsp" },
    },
    {
      { name = "buffer" },
      { name = "path" },
    }
  ),
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<Up>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<Down>"] = cmp.mapping.select_next_item(),
    ['<C-y>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
        else
          fallback()
        end
      end,
      s = cmp.mapping.confirm({ select = true }),
      c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
    }),
  },
  -- 補完メニューが表示されたときに最初の項目を事前に選択する
  completion = {
    completeopt = "menu,menuone",
  },
  preselect = cmp.PreselectMode.Item,
  formatting = {
    format = lspkind.cmp_format({
      mode = 'text_symbol',
      maxwidth = {
        menu = 50,
        abbr = 50,
      },
      ellipsis_char = '...',
      show_labelDetails = true,
      before = function(entry, vim_item)
        return vim_item
      end
    })
  },
})

-- autocmd で skkeleton のイベントにフックして関数を実行
function _G.cmp_enable_skk()
  cmp.setup.buffer({
    sources = cmp.config.sources({
      { name = 'skkeleton' }
    })
  })
end

function _G.cmp_disable_skk()
  cmp.setup.buffer({
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'path' },
      { name = 'cmdline' },
    })
  })
end

-- vim.cmd([[
--   augroup skkeleton_cmp
--     autocmd!
--     autocmd User skkeleton-enable-pre lua _G.cmp_enable_skk()
--     autocmd User skkeleton-disable-pre lua _G.cmp_disable_skk()
--   augroup END
-- ]])
--
cmp.setup.cmdline('/', {
  -- cmp.mapping.preset.cmdline の引数にキーマッピングの
  -- テーブルを渡すと、デフォルトのキーマップに任意のキーを
  -- 追加できる。
  mapping = cmp.mapping.preset.cmdline({
    ['<Down>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
    },
    ['<Up>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
  }),
  sources = {
    { name = 'buffer' }
  }
})
cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline({
    ['<Down>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end,
    },
    ['<Up>'] = {
      c = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end,
    },
  }),
  -- mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "cmdline_history" },
    { name = "path" },
    { name = "cmdline" },
  },
  completion = {
    completeopt = "menu,menuone",
  }
})
