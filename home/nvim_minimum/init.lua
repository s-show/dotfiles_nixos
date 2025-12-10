local plugin_paths = {
  "/home/s-show/.local/share/nvim/lazy/denops.vim",
  "/home/s-show/.local/share/nvim/lazy/ddu.vim",
  "/home/s-show/.local/share/nvim/lazy/ddu-ui-ff",
  "/home/s-show/.local/share/nvim/lazy/ddu-filter-matcher_substring",
  "/home/s-show/.local/share/nvim/lazy/ddu-source-file_rec",
  "/home/s-show/.local/share/nvim/lazy/ddu-source-help",
  "/home/s-show/.local/share/nvim/lazy/ddu-filter-sorter_alpha",
  "/home/s-show/.local/share/nvim/lazy/pum.vim",
  "/home/s-show/.local/share/nvim/lazy/ddc.vim",
  "/home/s-show/.local/share/nvim/lazy/ddc-ui-pum",
  "/home/s-show/.local/share/nvim/lazy/ddc-source-file",
  "/home/s-show/.local/share/nvim/lazy/ddc-source-cmdline",
  "/home/s-show/.local/share/nvim/lazy/ddc-source-cmdline_history",
  "/home/s-show/.local/share/nvim/lazy/ddc-source-buffer",
  "/home/s-show/.local/share/nvim/lazy/ddc-filter-matcher_head",
  "/home/s-show/.local/share/nvim/lazy/ddc-filter-sorter_rank",
}

for _, path in ipairs(plugin_paths) do
  vim.opt.runtimepath:append(path)
end

vim.fn["ddu#custom#patch_global"]({
  ui = 'ff',
  uiParams = {
    ff = {
      filterFloatingPosition = "top",
      floatingBorder = "rounded",
      floatingTitle = 'list',
      split = "floating",
      startAutoAction = true,
      winHeight = '&lines / 4',
      winWidth = '&columns / 2',
      winRow = '&lines / 4 - 2',
      winCol = '&columns / 4',
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


local ddu_vim_autocmd_group = vim.api.nvim_create_augroup('ddu_vim', {})

vim.api.nvim_create_autocmd("FileType",
  {
    pattern = "ddu-ff",
    callback = function()
      vim.keymap.set("n", "q", [[<Cmd>call ddu#ui#do_action("quit")<CR>]], { buffer = true })
      vim.keymap.set("n", "<CR>", [[<Cmd>call ddu#ui#do_action("itemAction")<CR>]], { buffer = true })
      vim.keymap.set("n", "i", [[<Cmd>call ddu#ui#do_action("openFilterWindow")<CR>]], { buffer = true })
      vim.keymap.set("n", "P", [[<Cmd>call ddu#ui#do_action("togglePreview")<CR>]], { buffer = true })
    end,
  }
)

-- `<cmd>call` を使わない場合 `{expr=true}` オプションが必要になるが、
-- それだとカーソルが行頭に移動するので、`<cmd>call ` を使っている。
vim.keymap.set('n', '<leader>gh', [[<cmd>call ddu#start(#{name: 'help'})<CR>]])
vim.keymap.set('n', '<leader>gf', [[<cmd>call ddu#start(#{name: 'file_recursive'})<CR>]])

-- pum の設定は ddc.vim より前に行う必要がある
vim.fn["pum#set_option"]({
  border = 'rounded',
  padding = true,
  offset_cmdrow = 2,
  auto_select = true,
})

local pum_au_group = vim.api.nvim_create_augroup('pum_vim', {})

-- インサートモードに入った時に ddc.vim のキーバインドを設定する
vim.api.nvim_create_autocmd('InsertEnter', {
  group = pum_au_group,
  callback = function()
    InsertEnterPre()
  end
})

function InsertEnterPre()
  vim.keymap.set({ 'i', 't' }, '<C-n>',
    [[pum#visible() ? pum#map#select_relative(+1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set({ 'i', 't' }, '<C-p>',
    [[pum#visible() ? pum#map#select_relative(-1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set({ 'i', 't' }, '<C-e>', [[pum#visible() ? pum#map#cancel() : '<C-e>']], { expr = true })
  vim.keymap.set({ 'i', 't' }, '<C-y>', [[pum#visible() ? pum#map#confirm() : '<C-y>']], { expr = true })
  vim.keymap.set({ 'i', 't' }, '<tab>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#confirm']()
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<tab>', true, false, true), 'n', false)
    end
  end)
  vim.api.nvim_create_autocmd(
    { 'InsertLeave' },
    {
      once = true,
      group = pum_au_group,
      callback = function()
        InsertEnterPost()
      end
    }
  )
  vim.fn['ddc#enable']()
end

function InsertEnterPost()
  vim.keymap.del({ 'i', 't' }, '<C-n>')
  vim.keymap.del({ 'i', 't' }, '<C-p>')
  vim.keymap.del({ 'i', 't' }, '<C-e>')
  vim.keymap.del({ 'i', 't' }, '<C-y>')
  vim.keymap.del({ 'i', 't' }, '<tab>')
end

-- コマンドラインモードに入った時に ddc.vim のキーバインドを設定する
vim.api.nvim_create_autocmd('CmdlineEnter', {
  group = pum_au_group,
  callback = function()
    CommandlinePre()
  end
})

function CommandlinePre()
  vim.keymap.set('c', '<C-n>', [[pum#visible() ? pum#map#insert_relative(+1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set('c', '<C-p>', vim.fn["pum#map#insert_relative(-1, 'loop')"])
  vim.keymap.set('c', '<C-y>', vim.fn['pum#map#confirm'])
  vim.keymap.set('c', '<C-e>', [[pum#map#cancel()]], { expr = true })
  vim.api.nvim_create_autocmd(
    { 'User' },
    {
      pattern = 'DDCCmdlineLeave',
      group = pum_au_group,
      once = true,
      callback = function()
        CommandlinePost()
      end
    }
  )
  -- Enable command line completion for next command line session
  vim.fn['ddc#enable_cmdline_completion']()
end

function CommandlinePost()
  vim.keymap.del('c', '<C-n>')
  vim.keymap.del('c', '<C-p>')
  vim.keymap.del('c', '<C-y>')
  vim.keymap.del('c', '<C-e>')
end

vim.fn["ddc#custom#patch_global"]({
  -- uiは一番最初に設定する必要がある
  ui = 'pum',
  sources = {
    'file',
    'buffer',
    'cmdline',
    'cmdline_history',
  },
  autoCompleteEvents = {
    'InsertEnter',
    'TextChangedI',
    'TextChangedP',
    'TextChangedT',
    'CmdlineChanged',
  },
  cmdlineSources = {
    [":"] = {
      'cmdline_history',
      'cmdline',
    },
    ["@"] = {
      'cmdline',
      'cmdline_history',
      'file',
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
    ["-"] = {
      'buffer',
    },
    ["="] = {
      'buffer',
    }
  },
  sourceOptions = {
    _ = {
      matchers = { 'matcher_head' },
      sorters = { 'sorter_rank' },
      ignoreCase = true,
    },
    file = {
      mark = 'F',
      isVolatile = true,
      forceCompletionPattern = [[\S/\S*]],
      minAutoCompleteLength = 1000,
    },
  },
  sourceParams = {
    file = {
      filenameChars = "[:keyword:].",
      projFromCwdMaxItems = {},
    },
  },
  specialBufferCompletion = false
})
