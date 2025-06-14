-- pum の設定は ddc.vim より前に行う必要がある
-- vim.fn["pum#set_option"]('border', 'rounded')
vim.fn["pum#set_option"]({
  border = 'rounded',
  padding = true,
  offset_cmdrow = 2,
  auto_select = true,
})

local pum_au_group = vim.api.nvim_create_augroup('pum_vim', {})

--[[
インサートモードに入った時に ddc.vim のキーバインドを設定する
--]]
vim.api.nvim_create_autocmd('InsertEnter', {
  group = pum_au_group,
  callback = function()
    InsertEnterPre()
  end
})

function InsertEnterPre()
  vim.keymap.set('i', '<C-n>', [[pum#visible() ? pum#map#select_relative(+1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set('i', '<C-p>', [[pum#visible() ? pum#map#select_relative(-1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set('i', '<C-e>', [[pum#visible() ? pum#map#cancel() : '<C-e>']], { expr = true })
  vim.keymap.set('i', '<C-y>', [[pum#visible() ? pum#map#confirm() : '<C-y>']], { expr = true })
  -- vim.keymap.set('i', '<CR>',  [[pum#visible() ? pum#map#confirm() : lexima#expand('<LT>CR>', 'i')]], { expr = true })
  vim.cmd [[
    inoremap <silent><expr> <CR> pum#visible() ? "\<Cmd>call pum#map#confirm()\<CR>" :
    \ "\<C-r>=lexima#expand('<LT>CR>', 'i')\<CR>"
  ]]
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
  vim.api.nvim_del_keymap('i', '<C-n>')
  vim.api.nvim_del_keymap('i', '<C-p>')
  vim.api.nvim_del_keymap('i', '<C-e>')
  vim.api.nvim_del_keymap('i', '<C-y>')
end

--[[
コマンドラインモードに入った時に ddc.vim のキーバインドを設定する
--]]
vim.keymap.set('n', ':', function() CommandlinePre() return ':' end, { expr = true })
vim.keymap.set('n', '/', function() CommandlinePre() return '/' end, { expr = true })
vim.keymap.set('n', '?', function() CommandlinePre() return '?' end, { expr = true })

function CommandlinePre()
  vim.keymap.set('c', '<Tab>', [[pum#visible() ? pum#map#insert_relative(+1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set('c', '<S-Tab>', [[pum#map#insert_relative(-1, 'loop')]], { expr = true })
  vim.keymap.set('c', '<C-n>', [[pum#visible() ? pum#map#insert_relative(+1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set('c', '<C-p>', [[pum#map#insert_relative(-1, 'loop')]], { expr = true })
  vim.keymap.set('c', '<Down>', [[pum#map#insert_relative(+1, 'loop')]], { expr = true })
  vim.keymap.set('c', '<Up>', [[pum#map#insert_relative(-1, 'loop')]], { expr = true })
  vim.keymap.set('c', '<C-y>', [[pum#map#confirm()]], { expr = true })
  vim.keymap.set('c', '<CR>', [[pum#visible() ? pum#map#confirm() : '<CR>']], { expr = true })
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
  vim.api.nvim_del_keymap('c', '<C-n>')
  vim.api.nvim_del_keymap('c', '<C-p>')
  vim.api.nvim_del_keymap('c', '<Down>')
  vim.api.nvim_del_keymap('c', '<Up>')
  vim.api.nvim_del_keymap('c', '<C-y>')
  vim.api.nvim_del_keymap('c', '<CR>')
  vim.api.nvim_del_keymap('c', '<C-e>')
end

-- vim.api.nvim_create_autocmd(
--   { 'User' },
--   {
--     pattern = 'PumCompleteDone',
--     group = pum_au_group,
--     once = true,
--     callback = function()
--       vim.notify('hogehoge')
--       vim.cmd('doautocmd CompleteDone')
--     end
--   }
-- )
--
-- カラースキーマの設定を上書きしている
-- vim.cmd [[highlight PmenuSel ctermbg=green guibg=green]]
-- vim.cmd [[highlight PmenuSel ctermfg=black guifg=black]]
