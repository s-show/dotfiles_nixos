-- リーダーキー設定
vim.g.mapleader = " "

-- カーソル操作系
-- vim.keymap.set('n', 'j', 'gj', { noremap = true })
-- vim.keymap.set('n', 'k', 'gk', { noremap = true })
vim.keymap.set('n', '<Up>', 'gk')
vim.keymap.set('n', '<Down>', 'gj')
-- nvim-cmp が上下キーを使うので「Ctrl + 上下」で移動する
vim.keymap.set('i', '<C-Up>', '<C-G>k')
vim.keymap.set('i', '<C-Down>', '<C-G>j')
vim.opt.whichwrap:append {
  ['<'] = true,
  ['>'] = true,
  ['['] = true,
  [']'] = true,
  h = true,
  l = true,
}
vim.cmd('source ~/.config/nvim/lua/setting/keymapping.vim')

-- ファイル操作系
-- <leader>ww で保存
vim.keymap.set('n', '<leader>ww', "<Cmd>update<CR>")

vim.keymap.set('i', '/',
  [[complete_info(['mode']).mode == 'files' && complete_info(['selected']).selected >= 0 ? '<c-x><c-f>' : '/']],
  { expr = true }
)

-- jj -> Escape
-- j を押したら直ちに j を入力し、続けて j を押せば Escape を発行する
-- jj の手前で undo ブロックを区切る
vim.keymap.set('i', 'j', 'j<Plug>(g)', { desc = "jj -> Escape" })
vim.keymap.set('i', '<Plug>(g)j', '<BS><Esc>')
vim.keymap.set('i', '<Plug>(g)', '<Nop>')

-- 挿入モードでEmacsライクの左右移動
vim.keymap.set("i", "<C-b>", "<C-g>U<Left>")
vim.keymap.set("i", "<C-f>", "<C-g>U<Right>")

-- 大文字の Y で行末までヤンク
vim.keymap.set('n', 'Y', 'y$', { silent = true })

-- i<space>でWORD選択
vim.keymap.set('x', 'i<leader>', 'iW', { silent = true })
vim.keymap.set('o', 'i<leader>', 'iW', { silent = true })

-- 大文字の U でリドゥ
vim.keymap.set('n', 'U', '<c-r>', { silent = true })

-- Visual コピー時にカーソル位置を保存
vim.keymap.set('x', 'y', 'mzy`z', { silent = true })

-- 大文字の X で行末まで削除
vim.keymap.set('n', 'X', '"_D$', { silent = true })

-- Visual <, >で連続してインデントを操作
vim.keymap.set('x', '<', '<gv', { silent = true })
vim.keymap.set('x', '>', '>gv', { silent = true })

--=======================================================================================
-- tmux 操作系
--=======================================================================================
local tmux_operate = require('util.operate_tmux')

vim.keymap.set("n", "<C-s>", function () tmux_operate.send_prompt_tmux_pane(tmux_operate.aitool_pane_path) end,  { desc = "Send buf text to tmux pane" })
vim.keymap.set("i", "<C-s>", function()
  vim.cmd('stopinsert')
  tmux_operate.send_prompt_tmux_pane(tmux_operate.aitool_pane_path)
end, { desc = "Send buf text to tmux pane" })
vim.keymap.set("n", "<C-g>q", function()
  vim.cmd('quit!')
end, { desc = "Send buf text to tmux pane & vim quit!" })
vim.keymap.set("n", "<Up>", function() tmux_operate.send_key_tmux_frontend('Up') end, { desc = "Send <up> cursor to tmux pane" })
vim.keymap.set("n", "<Down>", function() tmux_operate.send_key_tmux_frontend('Down') end, { desc = "Send <down> cursor to tmux pane" })
vim.keymap.set("n", "<C-g><ESC>", function() tmux_operate.send_key_tmux_frontend('Escape') end,
  { desc = "Send <Escape> cursor to tmux pane" })
vim.keymap.set("n", "<C-g>c", function() tmux_operate.send_key_tmux_frontend('C-c') end, { desc = "Send <Ctrl-c> to tmux pane" })
vim.keymap.set("n", "<C-g>u", function() tmux_operate.send_key_tmux_frontend('C-u') end, { desc = "Send <Ctrl-u to tmux pane" })
vim.keymap.set("n", "<Enter>", function() tmux_operate.send_key_tmux_frontend('Enter') end, { desc = "Send <Enter> to tmux pane" })
vim.keymap.set("n", "<S-Tab>", function() tmux_operate.send_key_tmux_frontend('S-Tab') end, { desc = "Send <Enter> to tmux pane" })
vim.keymap.set("n", "<BS>", function() tmux_operate.send_key_tmux_frontend('BSpace') end, { desc = "Send <BackSpace> to tmux pane" })
vim.keymap.set("n", "<PageUp>", function() tmux_operate.scroll_src_pane('PageUp') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<PageDown>", function() tmux_operate.scroll_src_pane('PageDown') end, { desc = "scroll tmux pane(down)" })
vim.keymap.set("n", "<M-u>", function() tmux_operate.scroll_src_pane('C-u') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<M-d>", function() tmux_operate.scroll_src_pane('C-d') end, { desc = "scroll tmux pane(down)" })
vim.keymap.set("n", "<M-j>", function() tmux_operate.scroll_src_pane('j') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<M-k>", function() tmux_operate.scroll_src_pane('k') end, { desc = "scroll tmux pane(down)" })
vim.keymap.set("n", "<M-e>", function() tmux_operate.scroll_src_pane('C-e') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<M-y>", function() tmux_operate.scroll_src_pane('C-y') end, { desc = "scroll tmux pane(down)" })
