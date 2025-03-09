require("oil").setup({
  -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
  -- Set to false if you want some other plugin (e.g. netrw) to open when you edit directories.
  default_file_explorer = true,
  view_options = {
    show_hidden = true
  },
})
-- ファイルを開くとき、フルパスではなく相対パスで開く。
vim.api.nvim_create_augroup("OilRelPathFix", {})
vim.api.nvim_create_autocmd("BufLeave", {
  group = "OilRelPathFix",
  pattern = "oil:///*",
  callback = function()
    vim.cmd("cd .")
  end,
})
-- カレントディレクトリを開くキーバインド
vim.keymap.set("n", "<leader>go", function()
  require("oil").open(".")
end, { desc = "Oil ." })

vim.api.nvim_create_augroup("OpenOil", {})
vim.api.nvim_create_autocmd("FileType", {
  -- group = "OpenOil",
  pattern = 'oil',
  callback = function()
    vim.keymap.set('n', '<leader>vo', "<cmd>lua require('oil').select({ vertical = true, close = true })<CR>", { buffer = true })
    vim.keymap.set('n', '<leader>so', "<cmd>lua require('oil').select({ horizontal = true, close = true })<CR>", { buffer = true })
    vim.keymap.set('n', '<leader>P', "<cmd>lua require('oil').open_preview({ vertical = true })<CR>", { buffer = true })
    vim.keymap.set('n', '<leader>gd', "<cmd>lua ToggleDetail()<CR>", { buffer = true })
  end,
})

local toggle_detail = true
function ToggleDetail()
  if toggle_detail then
    require('oil').set_columns({ 'icon', 'permissions', 'size', 'mtime' })
    toggle_detail = false
  else
    require('oil').set_columns({ 'icon' })
    toggle_detail = true
  end
end
