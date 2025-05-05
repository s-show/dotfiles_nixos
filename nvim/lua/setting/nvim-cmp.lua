local cmp = require("cmp")
local lspkind = require("lspkind")
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
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
    { name = "skkeleton" },
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<Up>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<Down>"] = cmp.mapping.select_next_item(),
    ['<C-y>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<CR>"] = function(fallback)
      if cmp.visible() and cmp.get_active_entry() then
        cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
      else
        fallback()
      end
    end,
  },
  -- nvim-cmp で1つ目の候補に自動でフォーカスを当てるための設定
  completion = {
    completeopt = "menu,menuone,noinsert", -- "noselect"を除外した残り
  },
  experimental = {
    ghost_text = false,
  },
  -- Disabling completion in certain contexts, such as comments
  -- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-completion-in-certain-contexts-such-as-comments
  -- enabled = function()
  --   -- disable completion in comments
  --   local context = require 'cmp.config.context'
  --   -- keep command mode completion enabled when cursor is in a comment
  --   if vim.api.nvim_get_mode().mode == 'c' then
  --     return true
  --   else
  --     return not context.in_treesitter_capture("comment")
  --         and not context.in_syntax_group("Comment")
  --   end
  -- end,
  formatting = {
    format = lspkind.cmp_format({
      mode = 'text_symbol',
      maxwidth = {
        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
        -- can also be a function to dynamically calculate max width such as
        -- menu = function() return math.floor(0.45 * vim.o.columns) end,
        menu = 50,              -- leading text (labelDetails)
        abbr = 50,              -- actual suggestion item
      },
      ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true, -- show labelDetails in menu. Disabled by default
      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
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

vim.cmd([[
  augroup skkeleton_cmp
    autocmd!
    autocmd User skkeleton-enable-pre lua _G.cmp_enable_skk()
    autocmd User skkeleton-disable-pre lua _G.cmp_disable_skk()
  augroup END
]])

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
    completeopt = "menu,menuone,noinsert,noselect",
  }
})
