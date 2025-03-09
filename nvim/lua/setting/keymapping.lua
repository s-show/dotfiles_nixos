-- リーダーキー設定
vim.g.mapleader = ","

-- カーソル操作系
vim.api.nvim_set_keymap('n', 'j', 'gj', { noremap = true })
vim.api.nvim_set_keymap('n', 'k', 'gk', { noremap = true })
vim.api.nvim_set_keymap('n', '<Up>', 'gk', { noremap = true })
vim.api.nvim_set_keymap('n', '<Down>', 'gj', { noremap = true })
-- nvim-cmp が上下キーを使うので「Ctrl + 上下」で移動する
vim.api.nvim_set_keymap('i', '<C-Up>', '<C-G>k', { noremap = true })
vim.api.nvim_set_keymap('i', '<C-Down>', '<C-G>j', { noremap = true })
vim.opt.whichwrap:append {
  ['<'] = true,
  ['>'] = true,
  ['['] = true,
  [']'] = true,
  h = true,
  l = true,
}

-- ファイル操作系
-- ;w で保存
vim.api.nvim_set_keymap('n', '<leader>ww', "<Cmd>update<CR>", { noremap = true })

-- ウィンドウ操作系
-- space-w-[vsjkhlc=]でウィンドウの分割・移動・リサイズ・クローズを実行
vim.api.nvim_set_keymap('n', '<leader>wv', '<Cmd>wincmd v<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>ws', '<Cmd>wincmd s<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>wj', '<Cmd>wincmd j<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>wk', '<Cmd>wincmd k<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>wh', '<Cmd>wincmd h<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>wl', '<Cmd>wincmd l<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>wc', '<Cmd>wincmd c<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>tl', '<Cmd>tabnext<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>th', '<Cmd>tabprevious<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>tn', '<Cmd>tabnew<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<leader>tt', '',
  {
    callback = function()
      vim.api.nvim_exec2('tabnew', { output = true })
      vim.api.nvim_exec2('terminal pwsh.exe', { output = true })
    end,
    silent = true
  }
)


vim.api.nvim_set_keymap('i', '/',
  [[complete_info(['mode']).mode == 'files' && complete_info(['selected']).selected >= 0 ? '<c-x><c-f>' : '/']],
  { expr = true, noremap = false }
)

-- ターミナル操作系
vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n><Plug>(Esc)', { noremap = true })
vim.api.nvim_set_keymap('n', '<Plug>(Esc)<Esc>', 'i', { noremap = true })

-- ノーマルモードの操作カスタマイズ
-- ;2連打でコマンドラインに移動
-- f motion とバッティングするので取り止め
-- vim.api.nvim_set_keymap('n', ';;', ':', { noremap = true })

-- 大文字の Y で行末までヤンク
vim.api.nvim_set_keymap('n', 'Y', 'y$', {silent = true, noremap = true})

-- i<space>でWORD選択
vim.api.nvim_set_keymap('x', 'i<leader>', 'iW', {silent = true, noremap = true})
vim.api.nvim_set_keymap('o', 'i<leader>', 'iW', {silent = true, noremap = true})

-- 大文字の U でリドゥ
vim.api.nvim_set_keymap('n', 'U', '<c-r>', {silent = true, noremap = true})

-- Visual コピー時にカーソル位置を保存
vim.api.nvim_set_keymap('x', 'y', 'mzy`z', {silent = true, noremap = true})

-- 大文字の X で行末まで削除
vim.api.nvim_set_keymap('n', 'X', '"_D$', {silent = true, noremap = true})

-- Visual <, >で連続してインデントを操作
vim.api.nvim_set_keymap('x', '<', '<gv', {silent = true, noremap = true})
vim.api.nvim_set_keymap('x', '>', '>gv', {silent = true, noremap = true})
