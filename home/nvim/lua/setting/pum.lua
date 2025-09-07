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
  vim.keymap.set({ 'i', 't' }, '<tab>', [[pum#visible() ? pum#map#confirm() : '<tab>']], { expr = true })
  vim.keymap.set({ 'i', 't' }, '<Down>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#select_relative']('1', 'loop')
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Down>', true, false, true), 'n', false)
    end
  end)
  vim.keymap.set({ 'i', 't' }, '<Up>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#select_relative']('-1', 'loop')
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Up>', true, false, true), 'n', false)
    end
  end)
  vim.keymap.set({ 'i', 't' }, '<tab>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#confirm']()
    elseif vim.g['skkeleton#state'].phase == 'henkan' then
      return vim.fn['skkeleton#handle']('handleKey', { key = '', ['function'] = 'kakutei' })
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
  local pcall_result, _ = pcall(vim.api.nvim_del_keymap, { 'i', 't' }, '<C-n>')
  if pcall_result ~= false then
    vim.keymap.del({ 'i', 't' }, '<C-p>')
    vim.keymap.del({ 'i', 't' }, '<C-e>')
    vim.keymap.del({ 'i', 't' }, '<Left>')
    vim.keymap.del({ 'i', 't' }, '<C-y>')
    vim.keymap.del({ 'i', 't' }, '<Right>')
    vim.keymap.del({ 'i', 't' }, '<tab>')
  end
end

-- コマンドラインモードに入った時に ddc.vim のキーバインドを設定する
vim.api.nvim_create_autocmd('CmdlineEnter', {
  group = pum_au_group,
  callback = function()
    CommandlinePre()
  end
})

function CommandlinePre()
  vim.keymap.set('c', '<Tab>', vim.fn['pum#map#confirm'])
  vim.keymap.set('c', '<C-n>', [[pum#visible() ? pum#map#insert_relative(+1, 'loop') : ddc#map#manual_complete()]],
    { expr = true })
  vim.keymap.set('c', '<C-p>', [[pum#map#insert_relative(-1, 'loop')]], { expr = true })
  vim.keymap.set('c', '<C-y>', vim.fn['pum#map#confirm'])
  vim.keymap.set('c', '<Down>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#insert_relative']('1', 'loop')
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, false, true), 'n', false)
    end
  end)
  vim.keymap.set('c', '<Up>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#insert_relative']('-1', 'loop')
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-p>', true, false, true), 'n', false)
    end
  end)
  vim.keymap.set('c', '<Right>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#confirm']()
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Right>', true, false, true), 'n', false)
    end
  end)
  vim.keymap.set('c', '<Left>', function()
    if vim.fn['pum#visible']() then
      return vim.fn['pum#map#cancel']()
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Left>', true, false, true), 'n', false)
    end
  end)
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
  if vim.fn.maparg('<C-e>', 'c') ~= '' then
    vim.keymap.del('c', '<Tab>')
    vim.keymap.del('c', '<C-n>')
    vim.keymap.del('c', '<C-p>')
    vim.keymap.del('c', '<Down>')
    vim.keymap.del('c', '<Up>')
    vim.keymap.del('c', '<Left>')
    vim.keymap.del('c', '<Right>')
    vim.keymap.del('c', '<C-y>')
    vim.keymap.del('c', '<C-e>')
  end
end
