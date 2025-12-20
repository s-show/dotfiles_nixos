vim.fn["ddc#custom#patch_global"]({
  -- uiは一番最初に設定する必要がある
  ui = 'pum',
  -- ui = 'native',
  sources = {
    'skkeleton',
    'file',
  },
  autoCompleteEvents = {
    'InsertEnter',
    'TextChangedI',
    'TextChangedP',
    'TextChangedT',
  },
  sourceOptions = {
    _ = {
      matchers = { 'matcher_head' },
      sorters = { 'sorter_rank' },
      ignoreCase = true,
    },
    skkeleton = {
      mark = 'skk',
      matchers = {},
      sorters = {},
      converters = {},
      isVolatile = true,
      minAutoCompleteLength = 1,
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
})

-- https://github.com/Shougo/ddc.vim/blob/abd90cb2f3acf557d6ea6b98dbe74bbc58c0c479/doc/ddc.txt#L1424-L1438 のコードを元に実装
local skkeleton = vim.api.nvim_create_augroup("skkeleton", { clear = true })
vim.api.nvim_create_autocmd(
  { 'User' },
  {
    group = skkeleton,
    pattern = 'skkeleton-enable-pre',
    callback = function()
      vim.b.prev_buffer_config = vim.fn["ddc#custom#get_buffer"]()
      vim.fn["ddc#custom#patch_buffer"]({
        sources = {
          'skkeleton',
        }
      })
    end
  }
)
vim.api.nvim_create_autocmd(
  { 'User' },
  {
    group = skkeleton,
    pattern = 'skkeleton-disable-pre',
    callback = function()
      vim.fn["ddc#custom#set_buffer"](vim.b.prev_buffer_config)
    end
  }
)

vim.fn['skkeleton#initialize']()
