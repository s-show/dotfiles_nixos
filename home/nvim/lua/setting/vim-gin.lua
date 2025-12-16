vim.api.nvim_create_autocmd({'FileType'}, {
  pattern = { 'gin-diff', 'gin-log', 'gin-status' },
  callback = function()
    local keymap = vim.keymap.set
    local opts = { buffer = true, noremap = true }
    keymap({ 'n' }, 'c', '<Cmd>Gin commit<Cr>', opts)
    keymap({ 'n' }, 's', '<Cmd>GinStatus<Cr>', opts)
    keymap({ 'n' }, 'L', '<Cmd>GinLog --graph --oneline<Cr>', opts)
    keymap({ 'n' }, 'd', '<Cmd>GinDiff --cached<Cr>', opts)
    keymap({ 'n' }, 'q', '<Cmd>bdelete<Cr>', opts)
    keymap({ 'n' }, 'p', [[<Cmd>lua vim.notify("Gin push")<Cr><Cmd>Gin push<Cr>]], opts)
    keymap({ 'n' }, 'P', [[<Cmd>lua vim.notify("Gin pull")<Cr><Cmd>Gin pull<Cr>]], opts)
  end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
  pattern = 'gin-status',
  callback = function()
  local keymap = vim.keymap.set
  local opts = { buffer = true, noremap = true }
  keymap({ 'n' }, 'h', '<Plug>(gin-action-stage)', opts)
  keymap({ 'n' }, 'l', '<Plug>(gin-action-unstage)', opts)
  end,
})
