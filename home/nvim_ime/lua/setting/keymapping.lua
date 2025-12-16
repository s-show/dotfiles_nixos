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
-- ,ww で保存
vim.keymap.set('n', '<leader>ww', "<Cmd>update<CR>")

vim.keymap.set('i', '/',
  [[complete_info(['mode']).mode == 'files' && complete_info(['selected']).selected >= 0 ? '<c-x><c-f>' : '/']],
  { expr = true }
)

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
