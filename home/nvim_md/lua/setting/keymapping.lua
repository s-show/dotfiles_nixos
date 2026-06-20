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

-- jj -> Escape
-- j を押したら直ちに j を入力し、続けて j を押せば Escape を発行する
-- jj の手前で undo ブロックを区切る
vim.keymap.set('i', 'j', 'j<Plug>(g)', { desc = "jj -> Escape" })
vim.keymap.set('i', '<Plug>(g)j', '<BS><Esc>')
vim.keymap.set('i', '<Plug>(g)', '<Nop>')

-- 大文字の Y で行末までヤンク
vim.keymap.set('n', 'Y', 'y$', { silent = true })

-- i<space>でWORD選択
vim.keymap.set('x', 'i<leader>', 'iW', { silent = true })
vim.keymap.set('o', 'i<leader>', 'iW', { silent = true })

-- Visual コピー時にカーソル位置を保存
vim.keymap.set('x', 'y', 'mzy`z', { silent = true })
