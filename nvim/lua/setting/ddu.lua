vim.fn["ddu#custom#patch_global"]({
  ui = 'ff',
  uiParams = {
    ff = {
      filterFloatingPosition = "bottom",
      floatingBorder = "rounded",
      floatingTitle = 'list',
      previewFloating = true,
      previewFloatingBorder = "rounded",
      previewFloatingTitle = "Preview",
      previewSplit = "horizontal",
      -- previewSplit = "vertical",
      split = "floating",
      startAutoAction = true,
      autoAction = {
        name = "preview"
      },
      -- previewHeight = '&lines - 8 + 1',
      -- previewWidth = '&columns / 3 - 1',
      -- previewRow = 0,
      -- previewCol = '&columns / 2 + 1',
      -- winHeight = '&lines - 8',
      -- winWidth = '&columns / 3 - 1',
      -- winRow = '&lines / 2',
      -- winCol = '&columns / 2 - &columns / 3',
      winHeight = '&lines / 4',
      winWidth = '&columns / 2',
      winRow = '&lines / 4 - 2',
      winCol = '&columns / 4',
      previewHeight = '&lines / 3',
      previewWidth = '&columns / 2',
      previewRow = '&lines / 2 + &lines / 3 + 1',
      previewCol = '&columns / 4',
      prompt = "> ",
    }
  },
  sourceOptions = {
    _ = {
      matchers = { 'matcher_substring' },
      ignoreCase = true,
    },
  },
  kindOptions = {
    action = {
      defaultAction = "do",
    }
  },
  actionOptions = {
    quit = false
  }
})

vim.fn["ddu#custom#patch_local"]("file_recursive", {
  sources = {
    {
      name = { "file_rec" },
      options = {
        converters = {
          "converter_devicon",
        },
      },
      params = {
        ignoredDirectories = {
          "node_modules",
          ".git",
          "dist",
          ".vscode",
        },
      },
    },
  },
  sourceOptions = {
    file_rec = {
      sorters = { 'sorter_alpha' },
    }
  },
  kindOptions = {
    file = {
      defaultAction = "open",
    }
  }
})

vim.fn["ddu#custom#patch_local"]("buffer", {
  sources = {
    {
      name = { "buffer" },
    },
  },
  kindOptions = {
    file = {
      defaultAction = "open",
    }
  }
})

vim.fn["ddu#custom#patch_local"]("cmdline-history", {
  sources = {
    {
      name = { "command_history" },
    },
  },
  uiParams = {
    ff = {
      previewFloating = false,
      winHeight = '&lines / 2',
      winWidth = '&columns / 3',
      winRow = '&lines / 4',
      winCol = '&columns / 6 * 2',
    }
  },
  kindOptions = {
    command_history = {
      defaultAction = "execute",
    }
  }
})

vim.fn["ddu#custom#patch_local"]("help", {
  sources = {
    {
      name = { "help" },
      params = {
        style = { "allLang" },
      },
    },
  },
  sourceOptions = {
    help = {
      sorters = { 'sorter_alpha' },
    }
  },
  kindOptions = {
    help = {
      defaultAction = "open",
    }
  },
})

vim.fn["ddu#custom#patch_local"]("lsp_documentSymbol", {
  sources = {
    {
      name = { "lsp_documentSymbol" },
      params = {
        buffer = 0,
      }
    }
  },
  kindOptions = {
    lsp = {
      defaultAction = "open",
    }
  },
})

vim.fn["ddu#custom#patch_local"]("lsp_diagnostic", {
  sources = {
    {
      name = { "lsp_diagnostic" },
      params = {
        buffer = 0,
      }
    }
  },
  kindOptions = {
    lsp = {
      defaultAction = "open",
    }
  },
})

vim.fn["ddu#custom#patch_local"]("window", {
  sources = {
    {
      name = { "window" },
      params = {
        format = [['tab\|%tn:%w:%wi']]
      }
    }
  },
  kindOptions = {
    window = {
      defaultAction = 'open',
    }
  }
})

local ddu_vim_autocmd_group = vim.api.nvim_create_augroup('ddu_vim', {})

vim.api.nvim_create_autocmd("FileType",
  {
    pattern = "ddu-ff",
    callback = function()
      vim.keymap.set("n", "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], { buffer = true })
      vim.keymap.set("n", "<Esc>", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], { buffer = true })
      vim.keymap.set("n", "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], { buffer = true })
      vim.keymap.set("n", "vo", [[<Cmd>call ddu#ui#do_action("itemAction", {'params': {'command': 'vsplit'}})<CR>]],
        { buffer = true })
      vim.keymap.set("n", "so", [[<Cmd>call ddu#ui#do_action("itemAction", {'params': {'command': 'split'}})<CR>]],
        { buffer = true })
      vim.keymap.set("n", "a", [[<Cmd>call ddu#ui#do_action('chooseAction')<CR>]], { buffer = true })
      vim.keymap.set("n", "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], { buffer = true })
      vim.keymap.set("n", "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], { buffer = true })
      vim.keymap.set("n", "<C-p>",
        [[<Cmd>call ddu#ui#do_action("previewExecute", {'command': 'execute "normal! \<C-y>"'})<CR>]], { buffer = true })
      vim.keymap.set("n", "<C-n>",
        [[<Cmd>call ddu#ui#do_action("previewExecute", {'command': 'execute "normal! \<C-e>"'})<CR>]], { buffer = true })
    end,
  }
)

vim.api.nvim_create_autocmd("User",
  {
    pattern = 'Ddu:ui:ff:openFilterWindow',
    callback = function()
      vim.keymap.set('c', '<C-n>', [[pum#visible() ? pum#map#insert_relative(+1, 'loop') : ddc#map#manual_complete()]],
        { expr = true, buffer = true })
      vim.keymap.set('c', '<C-p>', [[pum#map#insert_relative(-1, 'loop')]], { expr = true, buffer = true })
      vim.keymap.set('c', '<Down>', [[pum#map#insert_relative(+1, 'loop')]], { expr = true, buffer = true })
      vim.keymap.set('c', '<Up>', [[pum#map#insert_relative(-1, 'loop')]], { expr = true, buffer = true })
      vim.keymap.set('c', '<C-y>', [[pum#map#confirm()]], { expr = true, buffer = true })
      vim.keymap.set('c', '<C-e>', [[pum#map#cancel()]], { expr = true, buffer = true })
      vim.keymap.set({ 'n', 'i' }, '<CR>', [[<Esc><Cmd>close<CR>]], { expr = true, buffer = true })
      vim.fn['ddc#enable_cmdline_completion']()
    end,
  }
)

vim.api.nvim_create_autocmd({ 'User' },
  {
    pattern = 'Ddu:ui:ff:closeFilterWindow',
    callback = function()
      vim.keymap.del('c', '<C-n>', { buffer = true })
      vim.keymap.del('c', '<C-p>', { buffer = true })
      vim.keymap.del('c', '<Down>', { buffer = true })
      vim.keymap.del('c', '<Up>', { buffer = true })
      vim.keymap.del('c', '<C-y>', { buffer = true })
      vim.keymap.del('c', '<C-e>', { buffer = true })
      vim.keymap.del('n', '<CR>', { buffer = true })
      vim.keymap.del('i', '<CR>', { buffer = true })
      -- vim.keymap.del('c', '<CR>', { buffer = true })
      -- アイテムリスト用のキーバインドを復活させる
      vim.keymap.set("n", "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], { buffer = true })
      local autocmd_id = Get_autocmd_id({ group = ddu_vim_autocmd_group, pattern = 'Ddu:uiDone' })
      if autocmd_id ~= 0 then
        vim.api.nvim_del_autocmd(autocmd_id)
      end
    end
  }
)

-- `<cmd>call` を使わない場合 `{expr=true}` オプションが必要になるが、
-- それだとカーソルが行頭に移動するので、`<cmd>call ` を使っている。
-- vim.keymap.set('n', ';b', [[ddu#start(#{name: 'buffer'})]],         { expr = true })
-- vim.keymap.set('n', ';c', [[ddu#start(#{name: 'cmdline-history'})]],{ expr = true })
-- vim.keymap.set('n', ';l', [[ddu#start(#{name: 'lsp_documentSymbol'})]], { expr = true })
-- vim.keymap.set('n', ';e', [[ddu#start(#{name: 'lsp_diagnostic'})]], { expr = true })
-- vim.keymap.set('n', ';d', [[ddu#start(#{name: 'window'})]],         { expr = true })
vim.keymap.set('n', '<leader>gb', [[<cmd>call ddu#start(#{name: 'buffer'})<CR>]])
vim.keymap.set('n', '<leader>gc', [[<cmd>call ddu#start(#{name: 'cmdline-history'})<CR>]])
vim.keymap.set('n', '<leader>gl', [[<cmd>call ddu#start(#{name: 'lsp_documentSymbol'})<CR>]], { expr = true })
vim.keymap.set('n', '<leader>ge', [[<cmd>call ddu#start(#{name: 'lsp_diagnostic'})<CR>]])
vim.keymap.set('n', '<leader>gd', [[<cmd>call ddu#start(#{name: 'window'})<CR>]])
vim.keymap.set('n', '<leader>gh',
  function()
    Ddu_start_with_filter_window('help')
  end
)
vim.keymap.set('n', '<leader>gf',
  function()
    Ddu_start_with_filter_window('file_recursive')
  end
)

function Ddu_start_with_filter_window(source_name)
  vim.fn['ddu#start']({ name = source_name })
  return vim.api.nvim_create_autocmd("User",
    {
      pattern = 'Ddu:uiDone',
      group = ddu_vim_autocmd_group,
      nested = true,
      callback = function()
        local lineCount = vim.fn.line('$')
        if lineCount >= 10 then
          vim.fn['ddu#ui#async_action']('openFilterWindow')
        end
      end,
    }
  )
end

function Get_autocmd_id(args)
  local pcall_result, function_return = pcall(
    vim.api.nvim_get_autocmds, { group = args.group, pattern = { args.pattern } }
  )
  -- `nvim_get_autocmds` の検索結果が 0 件だと function_return は `{}` になる。
  -- そのため、`next(function_return) ~= nil` を AND 条件に指定して
  -- 検索結果 0 件の場合は 0 を返すようにしている。
  if pcall_result and next(function_return) ~= nil then
    -- vim.notify(vim.inspect(function_return))
    return function_return[1].id
  else
    return 0
  end
end

vim.fn['ddu#custom#action']('source', 'file_rec', 'insertPath', function(args)
  local selectedFilePath = vim.fn.substitute("." .. args["items"][1]["word"], "\\", "/", 'g')
  local beforeCursor = vim.fn.strcharpart(vim.fn.getline('.'), 0, vim.fn.getcharpos('.')[3])
  local afterCursor = vim.fn.strcharpart(vim.fn.getline('.'), vim.fn.getcharpos('.')[3],
    vim.fn.strchars(vim.fn.getline('.')))
  local newLine = beforeCursor .. selectedFilePath .. afterCursor
  vim.fn.setline('.', newLine)
  return 0
end)

vim.fn['ddu#custom#action']('source', 'buffer', 'deleteBuffer', function(args)
  -- vim.fn.setreg('a', vim.inspect(args)) -- 引数argsの内容をaレジスタにヤンクする
  vim.cmd['bd'](args["items"][1]["action"]["bufNr"])
  return 0
end)

-- ddu#custom#action を呼び出した時に与えられる引数の内容
-- {
--   actionParams = vim.empty_dict(),
--   context = {
--     bufName = "/home/s-show/.config/nvim/lua/setting/floater.vim",
--     bufNr = 23,
--     cwd = "/home/s-show/.config/nvim",
--     done = true,
--     doneUi = true,
--     input = "",
--     maxItems = 3,
--     mode = "n",
--     path = "/home/s-show/.config/nvim",
--     pathHistories = {},
--     winId = 1019
--   },
--   items = { {
--       __columnTexts = vim.empty_dict(),
--       __expanded = false,
--       __groupedPath = "",
--       __level = 0,
--       __sourceIndex = 0,
--       __sourceName = { "buffer" },
--       action = {
--         bufNr = 18,
--         isAlternate = true,
--         isCurrent = false,
--         isModified = 0,
--         path = "/home/s-show/.config/nvim/lua/setting/ftjpn.lua"
--       },
--       kind = "file",
--       matcherKey = "18 #  lua/setting/ftjpn.lua",
--       word = "18 #  lua/setting/ftjpn.lua"
--     } },
--   options = {
--     actionOptions = vim.empty_dict(),
--     actionParams = vim.empty_dict(),
--     actions = {},
--     columnOptions = vim.empty_dict(),
--     columnParams = vim.empty_dict(),
--     expandInput = false,
--     filterOptions = vim.empty_dict(),
--     filterParams = vim.empty_dict(),
--     input = "",
--     kindOptions = {
--       action = {
--         defaultAction = "do"
--       },
--       file = {
--         defaultAction = "open"
--       }
--     },
--     kindParams = vim.empty_dict(),
--     name = "buffer",
--     postFilters = {},
--     profile = false,
--     push = false,
--     refresh = false,
--     resume = false,
--     searchPath = "",
--     sourceOptions = {
--       _ = {
--         ignoreCase = true,
--         matchers = { "matcher_substring" }
--       },
--       buffer = {
--         actions = {
--           deleteBuffer = "7aed1aefe05ad186876e75f0b2306e82c826e802fdffb8adf368298f41d7a01c"
--         }
--       },
--       file_rec = {
--         actions = {
--           insertPath = "1a5fa7a425d5b96488d69a99fa666be9ca7cddb6a24bfd84262ee96e404018d7"
--         }
--       }
--     },
--     sourceParams = vim.empty_dict(),
--     sources = { {
--         name = { "buffer" }
--       } },
--     sync = false,
--     ui = "ff",
--     uiOptions = vim.empty_dict(),
--     uiParams = {
--       ff = {
--         autoAction = {
--           name = "preview"
--         },
--         filterFloatingPosition = "bottom",
--         floatingBorder = "rounded",
--         floatingTitle = "list",
--         previewCol = "&columns / 2 + 1",
--         previewFloating = true,
--         previewFloatingBorder = "rounded",
--         previewFloatingTitle = "Preview",
--         previewHeight = "&lines - 8 + 1",
--         previewRow = 0,
--         previewSplit = "horizontal",
--         previewWidth = "&columns / 3 - 1",
--         prompt = "> ",
--         split = "floating",
--         startAutoAction = true,
--         winCol = "&columns / 2 - &columns / 3",
--         winHeight = "&lines - 8",
--         winRow = "&lines / 2",
--         winWidth = "&columns / 3 - 1"
--       }
--     },
--     unique = false
--   }
-- }
