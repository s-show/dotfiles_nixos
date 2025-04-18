-- vim.opt.clipboard:append { "unnamed", "unnamedplus" }

-- copy to clipboard
vim.api.nvim_set_keymap('v', '<leader>y', '"*y', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>Y', '"*yg_', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>y', '"*y', {noremap = true})

-- copy from clipboard
vim.api.nvim_set_keymap('v', '<leader>p', '"*p', {noremap = true})
vim.api.nvim_set_keymap('v', '<leader>P', '"*P', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>P', '"*P', {noremap = true})
vim.api.nvim_set_keymap('n', '<leader>p', '"*p', {noremap = true})

-- C-xでコマンドラインに入力した文字列をヤンクする
vim.keymap.set('c', '<C-x>', function()
	vim.fn.setreg('"0', vim.fn.getcmdline())
end)

