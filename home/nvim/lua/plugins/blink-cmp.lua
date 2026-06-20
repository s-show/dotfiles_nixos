return {
  "saghen/blink.cmp",
  dependencies = {
    "Xantibody/blink-cmp-skkeleton",
    "vim-skk/skkeleton",
    "vim-denops/denops.vim",
  },
  version = '1.*',
  opts = {
    keymap = {
      preset = "super-tab",
      ["<C-u>"] = { "scroll_documentation_up", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      ['<C-y>'] = { "select_and_accept", "fallback" },
      ["<C-m>"] = { "select_and_accept", "fallback" },
      ["<C-n>"] = { "show" },
      ["<Space>"] = {},
    }, -- Required: Let skkeleton handle Space
    sources = {
      default = function(ctx)
        if require("blink-cmp-skkeleton").is_enabled() then
          return { "skkeleton" }
        else
          return { "lsp", "path", "snippets", "buffer", "cmdline" }
        end
      end,
      providers = {
        skkeleton = {
          name = "skkeleton",
          module = "blink-cmp-skkeleton",
        },
      },
      min_keyword_length = function(ctx)
        -- :wq, :qa -> menu doesn't popup
        -- :Lazy, :wqa -> menu popup
        if ctx.mode == "cmdline" and ctx.line:find("^%l+$") ~= nil then
          return 3
        end
        return 0
      end,
    },
    completion = {
      menu = {
        border = 'rounded',
        winhighlight = 'Normal:BlinkCmpMenuCustom,CursorLine:BlinkCmpMenuSelection,Search:None',
      },
      documentation = {
        window = {
          border = 'rounded',
        },
        auto_show = true,
      },
      list = {
        selection = {
          auto_insert = true,
        }
      }
    },
    signature = {
      window = {
        border = 'single',
      },
    },
    cmdline = {
      keymap = {
        ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
        ['<S-Tab>'] = { 'show_and_insert_or_accept_single', 'select_prev' },
        ['<C-space>'] = { 'show', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Right>'] = { 'select_next', 'fallback' },
        ['<Left>'] = { 'select_prev', 'fallback' },
        ['<C-y>'] = { 'select_and_accept', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<Enter>'] = { 'accept_and_enter', 'fallback' }
      },
      completion = {
        menu = {
          auto_show = true,
        },
      },
    },
  },
}
