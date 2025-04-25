-- local picker = require("snacks.picker")

vim.api.nvim_set_keymap('n', '<leader>sf', "<cmd>lua Snacks.picker.files()<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<leader>sp', "<cmd>lua Snacks.picker.smart()<CR>", { silent = true })
vim.api.nvim_set_keymap('n', '<leader>sd', "<cmd>lua Snacks.dashboard()<CR>", { silent = true })
