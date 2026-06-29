-- リーダーキー設定
vim.g.mapleader = " "

-- カーソル操作系
vim.keymap.set('n', '<Up>', 'gk')
vim.keymap.set('n', '<Down>', 'gj')
vim.opt.whichwrap:append {
  ['<'] = true,
  ['>'] = true,
  ['['] = true,
  [']'] = true,
  h = true,
  l = true,
}
vim.cmd('source ~/.config/nvim_md/lua/setting/keymapping.vim')

-- 大文字の Y で行末までヤンク
vim.keymap.set('n', 'Y', 'y$', { silent = true })

-- i<space>でWORD選択
vim.keymap.set('x', 'i<leader>', 'iW', { silent = true })
vim.keymap.set('o', 'i<leader>', 'iW', { silent = true })

-- Visual コピー時にカーソル位置を保存
vim.keymap.set('x', 'y', 'mzy`z', { silent = true })
vim.notify('foobar2000')
