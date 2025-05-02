-- local picker = require("snacks.picker")

vim.api.nvim_set_keymap('n', '<leader>sf', "<cmd>lua Snacks.picker.files()<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<leader>ss', "<cmd>lua Snacks.picker.smart()<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<leader>sp', "<cmd>lua Snacks.picker()<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<leader>sd', "<cmd>lua Snacks.dashboard()<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<leader>se', "<cmd>lua Snacks.explorer()<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<leader>sh', "<cmd>lua Snacks.picker.help()<CR>", { silent = true })
