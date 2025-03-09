vim.fn["ddc#custom#patch_global"]({
  -- uiは一番最初に設定する必要がある
  ui = 'pum',
  -- ui = 'native',
  sources = {
    'lsp',
    'file',
    'buffer',
    'vsnip',
    'cmdline',
    'cmdline_history'
  },
  autoCompleteEvents = {
    'InsertEnter',
    'TextChangedI',
    'TextChangedP',
    'CmdlineChanged',
  },
  cmdlineSources = {
    [":"] = {
      'cmdline_history',
      'cmdline',
    },
    ["@"] = {
      'cmdline_history',
      'cmdline',
    },
    [">"] = {
      'cmdline_history',
      'cmdline',
    },
    ["/"] = {
      'buffer',
    },
    ["?"] = {
      'buffer',
    },
    ["i"] = {
      'cmdline',
    },
  },
  sourceOptions = {
    _ = {
      matchers = { 'matcher_head' },
      sorters = { 'sorter_rank' },
      ignoreCase = true,
    },
    skkeleton = {
      mark = 'skkeleton',
      matchers = {},
      sorters = {},
      converters = {},
      isVolatile = true,
      minAutoCompleteLength = 1,
    },
    lsp = {
      dup = 'keep',
      mark = 'lsp',
      forceCompletionPattern = { [['\.\w*|:\w*|->\w*']] },
      keywordPattern = [[\k+]],
      converters = { 'converter_kind_labels' },
    },
    file = {
      mark = 'F',
      isVolatile = true,
      forceCompletionPattern = [[\S/\S*]],
      minAutoCompleteLength = 1000,
    },
    buffer = {
      mark = 'buffer',
    },
    vsnip = {
      mark = 'vsnip',
    },
  },
  sourceParams = {
    lsp = {
      -- lspEngine = 'vim-lsp',
      snippetEngine = vim.fn["denops#callback#register"](
        function(body)
          vim.fn["vsnip#anonymous"](body)
        end),
      -- snippetEngine = vim.fn["denops#callback#register"](function (body)
      --   require('luasnip').lsp_expand(body)
      -- end),
      enableResolveItem = true,
      enableAdditionalTextEdit = true,
      -- confirmBehavior = 'replace',
    },
    file = {
      filenameChars = "[:keyword:].",
      projFromCwdMaxItems = {},
    },
  },
  filterParams = {
    converter_kind_labels = {
      kindLabels = {
        Text = "",
        Method = "",
        Function = "",
        Constructor = "",
        Field = "",
        Variable = "",
        Class = "",
        Interface = "",
        Module = "",
        Property = "",
        Unit = "",
        Value = "",
        Enum = "",
        Keyword = "",
        Snippet = "",
        Color = "",
        File = "",
        Reference = "",
        Folder = "",
        EnumMember = "",
        Constant = "",
        Struct = "",
        Event = "",
        Operator = "",
        TypeParameter = ""
      },
      kindHlGroups = {
        Method = "Function",
        Function = "Function",
        Constructor = "Function",
        Field = "Identifier",
        Variable = "Identifier",
        Class = "Structure",
        Interface = "Structure"
      }
    }
  }
})
