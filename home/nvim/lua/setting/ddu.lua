function GetNbDir()
  local handle = io.popen("nb env | grep NB_DIR=")
  if handle then
    local result = handle:read("*a")
    local success, err_msg, err_code = handle:close()
    if success and result ~= "" then
      local path = vim.fn.substitute(result, 'NB_DIR=', '', "g")
      path = vim.fn.substitute(path, '\n', '', "g")
      return path
    else
      return ""
    end
  else
    return ""
  end
end

vim.fn["ddu#custom#patch_global"]({
  ui = 'ff',
  uiParams = {
    ff = {
      filterFloatingPosition = "top",
      floatingBorder = "rounded",
      floatingTitle = 'list',
      previewFloating = true,
      previewFloatingBorder = "rounded",
      previewFloatingTitle = "Preview",
      previewSplit = "vertical",
      split = "floating",
      startAutoAction = true,
      autoAction = {
        name = "preview"
      },
      winHeight = '&lines * 6 / 10',
      winWidth = '&columns * 4 / 10',
      previewHeight = '&lines * 6 / 10',
      previewWidth = '&columns * 4 / 10',
      winRow = '&lines * 2 / 10',
      winCol = '&columns * 1 / 10',
      previewRow = '&lines * 2 / 10',
      previewCol = '&columns * 5.1 / 10',
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
    _ = {
      defaultAction = "open"
    },
    action = {
      defaultAction = "do",
    },
    word = {
      defaultAction = "append"
    },
  },
  actionOptions = {
    quit = false
  }
})

vim.fn["ddu#custom#patch_local"]("smart", {
  uiParams = {
    ff = {
      displaySourceName = "long"
    }
  },
  sources = {
    {
      name = { "buffer" },
      options = {
        converters = {
          "converter_devicon",
        },
      },
    },
    {
      name = { "mr" },
      options = {
        converters = {
          "converter_devicon",
        },
      },
      params = {
        kind = "mru",
      },
    },
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
          "direnv",
        },
      },
    },
  },
  -- sourceOptions = {
  --   buffer = {
  --     matchers = { 'matcher_relative' },
  --   },
  --   mr = {
  --     matchers = { 'matcher_relative' },
  --   },
  -- },
  unique = true,
  postFilters = {
    'sorter_mtime',
  }
})

vim.fn["ddu#custom#patch_local"]("file_rec", {
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
})

vim.fn["ddu#custom#patch_local"]("nb_list", {
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
          ".cache",
          ".git",
        },
      },
    },
  },
  sourceOptions = {
    file_rec = {
      path = GetNbDir(),
      sorters = { 'sorter_alpha' },
    }
  },
})

vim.fn["ddu#custom#patch_local"]("buffer", {
  sources = {
    {
      name = { "buffer" },
    },
  },
})

vim.fn["ddu#custom#patch_local"]("command_history", {
  uiParams = {
    ff = {
      previewFloating = false,
      winHeight = '&lines / 2',
      winWidth = '&columns / 3',
      winRow = '&lines / 4',
      winCol = '&columns / 6 * 2',
      displaySourceName = "no",
    }
  },
  sources = {
    {
      name = { "command_history" },
    },
  },
  sourceOptions = {
    command_history = {
      defaultAction = "execute",
    }
  },
  unique = true,
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
  unique = true,
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
})

vim.fn["ddu#custom#patch_local"]("jumplist", {
  sources = {
    {
      name = { "jumplist" },
      params = {
        tabnr = 1,
      }
    }
  },
  sourceOptions = {
    jumplist = {
      sorters = { 'sorter_reversed' },
    }
  },
})

vim.fn["ddu#custom#patch_local"]("mr", {
  sources = {
    {
      name = { "mr" },
      options = {
        converters = {
          "converter_devicon",
        },
      },
      params = {
        kind = "mrw",
      },
    },
  },
})

vim.fn["ddu#custom#patch_local"]("source", {
  uiParams = {
    ff = {
      previewFloating = false,
      winHeight = '&lines / 2',
      winWidth = '&columns / 3',
      winRow = '&lines / 4',
      winCol = '&columns / 6 * 2',
      displaySourceName = "no",
    }
  },
  sources = {
    {
      name = { "source" },
    },
  },
  sourceOptions = {
    source = {
      defaultAction = "execute",
      sorters = { 'sorter_alpha' }
    }
  }
})

vim.fn["ddu#custom#patch_local"]("colorscheme", {
  uiParams = {
    ff = {
      previewFloating = false,
      winHeight = '&lines / 2',
      winWidth = '&columns / 3',
      winRow = '&lines / 4',
      winCol = '&columns / 6 * 2',
      displaySourceName = "no",
    }
  },
  sources = {
    {
      name = { "colorscheme" },
    },
  },
  sourceOptions = {
    colorscheme = {
      defaultAction = "set"
    }
  }
})

vim.fn["ddu#custom#patch_local"]("rg", {
  sources = {
    {
      name = { "rg" },
      options = {
        matchers = {},
        volatile = true,
      },
    }
  },
  uiParams = {
    ff = {
      ignoreEmpty = false,
      autoResize = false,
    }
  }
})

vim.fn["ddu#custom#patch_local"]("nb_rg", {
  sources = {
    {
      name = { "rg" },
      options = {
        matchers = {},
        volatile = true,
        path = GetNbDir()
      },
    }
  },
  uiParams = {
    ff = {
      ignoreEmpty = false,
      autoResize = false,
    }
  }
})

vim.fn["ddu#custom#patch_local"]("register", {
  sources = {
    {
      name = { "register" },
    }
  },
})

vim.fn["ddu#custom#patch_local"]("nb", {
  sources = {
    {
      name = { "nb" },
      params = {
        limit = 15,
      }
    },
  },
})

local ddu_vim_autocmd_group = vim.api.nvim_create_augroup('ddu_vim', {})

vim.api.nvim_create_autocmd("FileType",
  {
    pattern = "ddu-ff",
    callback = function()
      vim.keymap.set("n", "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], { buffer = true })
      vim.keymap.set("n", "<Esc>", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], { buffer = true })
      vim.keymap.set("n", "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], { buffer = true })
      vim.keymap.set("n", "<C-v>", [[<Cmd>call ddu#ui#do_action("itemAction", {'params': {'command': 'vsplit'}})<CR>]],
        { buffer = true })
      vim.keymap.set("n", "<C-s>", [[<Cmd>call ddu#ui#do_action("itemAction", {'params': {'command': 'split'}})<CR>]],
        { buffer = true })
      vim.keymap.set("n", "a", [[<Cmd>call ddu#ui#do_action('chooseAction')<CR>]], { buffer = true })
      vim.keymap.set("n", "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], { buffer = true })
      vim.keymap.set("n", "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], { buffer = true })
      vim.keymap.set("n", "<C-p>",
        [[<Cmd>call ddu#ui#do_action("previewExecute", {'command': 'execute "normal! \<C-y>"'})<CR>]], { buffer = true })
      vim.keymap.set("n", "<C-n>",
        [[<Cmd>call ddu#ui#do_action("previewExecute", {'command': 'execute "normal! \<C-e>"'})<CR>]], { buffer = true })
      if vim.fn["ddu#custom#get_current"]().name == "command_history" then
        vim.keymap.set("n", "e", [[<Cmd>call ddu#ui#do_action("itemAction", {'name': 'edit'})<CR>]], { buffer = true })
        vim.keymap.set("n", "dd", [[<Cmd>call ddu#ui#do_action("itemAction", {'name': 'delete'})<CR>]], { buffer = true })
      end
    end,
  }
)

vim.api.nvim_create_autocmd("User",
  {
    pattern = 'Ddu:ui:ff:openFilterWindow',
    callback = function()
      vim.keymap.set({ 'n', 'i', 'c' }, '<CR>', [[<Cmd>close<CR>]], { expr = true, buffer = true })
      vim.fn['ddc#enable_cmdline_completion']()
    end,
  }
)

vim.api.nvim_create_autocmd({ 'User' },
  {
    pattern = 'Ddu:ui:ff:closeFilterWindow',
    callback = function()
      vim.keymap.del('n', '<CR>', { buffer = true })
      vim.keymap.del('i', '<CR>', { buffer = true })
      vim.keymap.del('c', '<CR>', { buffer = true })
      -- アイテムリスト用のキーバインドを復活させる
      vim.keymap.set("n", "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], { buffer = true })
      local autocmd_id = Get_autocmd_id({ group = ddu_vim_autocmd_group, pattern = 'Ddu:uiDone' })
      if autocmd_id ~= 0 then
        vim.api.nvim_del_autocmd(autocmd_id)
      end
    end
  }
)

vim.keymap.set('n', '<leader>ds', function()
  vim.fn['ddu#start']({ name = 'smart' })
end)
vim.keymap.set('n', '<leader>df', function()
  vim.fn['ddu#start']({ name = 'file_rec' })
end)
vim.keymap.set('n', '<leader>dm', function()
  vim.fn['ddu#start']({ name = 'mr' })
end)
vim.keymap.set('n', '<leader>db', function()
  vim.fn['ddu#start']({ name = 'buffer' })
end)
vim.keymap.set('n', '<leader>dc', function()
  vim.fn['ddu#start']({ name = 'command_history' })
end)
vim.keymap.set('n', '<leader>dl', function()
  vim.fn['ddu#start']({ name = 'lsp_documentSymbol' })
end)
vim.keymap.set('n', '<leader>de', function()
  vim.fn['ddu#start']({ name = 'lsp_diagnostic' })
end)
vim.keymap.set('n', '<leader>dh', function()
  vim.fn['ddu#start']({ name = 'help' })
end)
vim.keymap.set('n', '<leader>dj', function()
  vim.fn['ddu#start']({ name = 'jumplist' })
end)
vim.keymap.set('n', '<leader>dp', function()
  vim.fn['ddu#start']({ name = 'source' })
end)
vim.keymap.set('n', '<leader>dg', function()
  vim.fn['ddu#start']({ name = 'rg' })
end)
vim.keymap.set('n', '<leader>dr', function()
  vim.fn['ddu#start']({ name = 'register' })
end)
vim.keymap.set('n', '<leader>ne', function()
  vim.fn['ddu#start']({ name = 'nb_list' })
end)
vim.keymap.set('n', '<leader>nr', function()
  vim.fn['ddu#start']({ name = 'nb_rg' })
end)

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

-- vim.api.nvim_create_autocmd("User",
--   {
--     pattern = 'Ddu:uiDone',
--     callback = function()
--       vim.print(vim.inspect(vim.fn['ddu#ui#get_items']()))
--     end,
--   }
-- )

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
--
-- vim.fn["ddu#custom#get_current"]('sources') の出力
-- {
--   actionOptions = {
--     quit = false
--   },
--   actionParams = vim.empty_dict(),
--   actions = {},
--   columnOptions = vim.empty_dict(),
--   columnParams = vim.empty_dict(),
--   expandInput = false,
--   filterOptions = {
--     converter_devicon = {
--       minInputLength = 0
--     },
--     matcher_substring = {
--       minInputLength = 0
--     }
--   },
--   filterParams = {
--     converter_devicon = {
--       defaultIcon = "",
--       defaultIconHlgroup = "",
--       extentionIcons = vim.empty_dict(),
--       padding = 0,
--       specificFileIcons = vim.empty_dict()
--     },
--     matcher_substring = {
--       highlightMatched = "",
--       limit = 1000,
--       maxLength = 500
--     }
--   },
--   input = "",
--   kindOptions = {
--     _ = {
--       defaultAction = "open"
--     },
--     action = {
--       defaultAction = "do"
--     },
--     colorscheme = {
--       defaultAction = "set"
--     },
--     source = {
--       defaultAction = "execute"
--     },
--     word = {
--       defaultAction = "append"
--     }
--   },
--   kindParams = vim.empty_dict(),
--   name = "smart",
--   postFilters = { "sorter_mtime", "deduplicate_path" },
--   profile = false,
--   push = false,
--   refresh = false,
--   resume = false,
--   searchPath = "",
--   sourceOptions = {
--     _ = {
--       ignoreCase = true,
--       matchers = { "matcher_substring" }
--     },
--     buffer = {
--       actions = {
--         deleteBuffer = "f3d759476d692152cdbf1e5a382ddd70898782935eb6176a670c8a5b3b593eeb"
--       },
--       columns = {},
--       converters = { "converter_devicon" },
--       defaultAction = "",
--       dynamicFilters = "",
--       ignoreCase = true,
--       limitPath = "",
--       matcherKey = "word",
--       matchers = { "matcher_substring" },
--       maxItems = 10000,
--       path = "",
--       preview = true,
--       smartCase = false,
--       sorters = {},
--       volatile = false
--     },
--     file_rec = {
--       actions = {
--         insertPath = "be6af6154c6f4ed6f2850a01c7bd99dd77be927970dc8530c6b00fe78a9b5f4f"
--       },
--       columns = {},
--       converters = { "converter_devicon" },
--       defaultAction = "",
--       dynamicFilters = "",
--       ignoreCase = true,
--       limitPath = "",
--       matcherKey = "word",
--       matchers = { "matcher_substring" },
--       maxItems = 10000,
--       path = "",
--       preview = true,
--       smartCase = false,
--       sorters = {},
--       volatile = false
--     },
--     mr = {
--       actions = vim.empty_dict(),
--       columns = {},
--       converters = { "converter_devicon" },
--       defaultAction = "",
--       dynamicFilters = "",
--       ignoreCase = true,
--       limitPath = "",
--       matcherKey = "word",
--       matchers = { "matcher_substring" },
--       maxItems = 10000,
--       path = "",
--       preview = true,
--       smartCase = false,
--       sorters = {},
--       volatile = false
--     },
--     source = {
--       sorters = { "sorter_alpha" }
--     }
--   },
--   sourceParams = {
--     buffer = vim.empty_dict(),
--     file_rec = {
--       chunkSize = 1000,
--       expandSymbolicLink = false,
--       ignoredDirectories = { "node_modules", ".git", "dist", "direnv" }
--     },
--     mr = {
--       kind = "mru"
--     }
--   },
--   sources = { {
--       name = { "buffer" },
--       options = {
--         converters = { "converter_devicon" }
--       }
--     }, {
--       name = { "mr" },
--       options = {
--         converters = { "converter_devicon" }
--       },
--       params = {
--         kind = "mru"
--       }
--     }, {
--       name = { "file_rec" },
--       options = {
--         converters = { "converter_devicon" }
--       },
--       params = {
--         ignoredDirectories = { "node_modules", ".git", "dist", "direnv" }
--       }
--     } },
--   sync = false,
--   syncLimit = 0,
--   syncTimeout = 0,
--   ui = "ff",
--   uiOptions = {
--     ff = {
--       actions = vim.empty_dict(),
--       defaultAction = "default",
--       filterInputFunc = "input",
--       filterInputOptsFunc = "",
--       filterPrompt = "",
--       filterUpdateCallback = "",
--       filterUpdateMax = 0,
--       persist = false,
--       toggle = false
--     }
--   },
--   uiParams = {
--     ff = {
--       autoAction = {
--         name = "preview"
--       },
--       autoResize = false,
--       cursorPos = 0,
--       displaySourceName = "long",
--       displayTree = false,
--       exprParams = { "previewCol", "previewRow", "previewHeight", "previewWidth", "winCol", "winRow", "winHeight", "winWidth" },
--       filterFloatingPosition = "top",
--       floatingBorder = "rounded",
--       floatingTitle = "list",
--       floatingTitlePos = "left",
--       focus = true,
--       highlights = vim.empty_dict(),
--       ignoreEmpty = false,
--       immediateAction = "",
--       maxDisplayItems = 1000,
--       maxHighlightItems = 100,
--       maxWidth = 200,
--       onPreview = 0,
--       overwriteStatusline = true,
--       overwriteTitle = false,
--       pathFilter = "",
--       previewCol = "&columns * 5.1 / 10",
--       previewFloating = true,
--       previewFloatingBorder = "rounded",
--       previewFloatingTitle = "Preview",
--       previewFloatingTitlePos = "left",
--       previewFloatingZindex = 100,
--       previewFocusable = true,
--       previewHeight = "&lines * 6 / 10",
--       previewMaxSize = 1000000,
--       previewRow = "&lines * 2 / 10",
--       previewSplit = "vertical",
--       previewWidth = "&columns * 4 / 10",
--       previewWindowOptions = { { "&signcolumn", "no" }, { "&foldcolumn", 0 }, { "&foldenable", 0 }, { "&number", 0 }, { "&wrap", 0 } },
--       prompt = "> ",
--       replaceCol = 0,
--       reversed = false,
--       split = "floating",
--       splitDirection = "botright",
--       startAutoAction = true,
--       winCol = "&columns * 1 / 10",
--       winHeight = "&lines * 6 / 10",
--       winRow = "&lines * 2 / 10",
--       winWidth = "&columns * 4 / 10"
--     }
--   },
--   unique = false
-- }
