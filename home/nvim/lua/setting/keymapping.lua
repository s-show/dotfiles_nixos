--=======================================================================================
--リーダーキー設定
--=======================================================================================
vim.g.mapleader = ","

--=======================================================================================
-- カーソル操作系
--=======================================================================================
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
vim.cmd('source ~/.config/nvim/lua/setting/keymapping.vim')
-- インサートモードで←・→移動した際に Undo block を中断させないための設定
-- [Insertモードでも気軽に←・→したい | Atusy's blog](https://blog.atusy.net/2023/03/03/horizontal-arrows-on-insert/)
vim.keymap.set('i', '<Left>', '<C-G>U<Left>')
vim.keymap.set('i', '<Right>', '<C-G>U<Right>')

--=======================================================================================
-- ファイル操作系
--=======================================================================================
-- ,ww で保存
vim.keymap.set('n', '<leader>ww', "<Cmd>update<CR>", { noremap = true })

--=======================================================================================
-- ウィンドウ操作系
--=======================================================================================
-- space-w-[vsjkhlc=]でウィンドウの分割・移動・リサイズ・クローズを実行
vim.keymap.set('n', '<leader>wv', '<Cmd>wincmd v<CR>', { silent = true })
vim.keymap.set('n', '<leader>ws', '<Cmd>wincmd s<CR>', { silent = true })
vim.keymap.set('n', '<leader>wj', '<Cmd>wincmd j<CR>', { silent = true })
vim.keymap.set('n', '<leader>wk', '<Cmd>wincmd k<CR>', { silent = true })
vim.keymap.set('n', '<leader>wh', '<Cmd>wincmd h<CR>', { silent = true })
vim.keymap.set('n', '<leader>wl', '<Cmd>wincmd l<CR>', { silent = true })
vim.keymap.set('n', '<leader>wc', '<Cmd>wincmd c<CR>', { silent = true })
vim.keymap.set('n', '<leader>tl', '<Cmd>tabnext<CR>', { silent = true })
vim.keymap.set('n', '<leader>th', '<Cmd>tabprevious<CR>', { silent = true })
vim.keymap.set('n', '<leader>tn', '<Cmd>tabnew<CR>', { silent = true })
vim.keymap.set('n', '<leader>tt', '',
  {
    callback = function()
      vim.api.nvim_exec2('tabnew', { output = true })
      vim.api.nvim_exec2('terminal pwsh.exe', { output = true })
    end,
    silent = true
  }
)

-- H/LとPageUp/PageDownを共存させる設定
-- https://blog.atusy.net/2024/05/29/vim-hl-enhanced/ を改変
-- Hのマッピング（条件分岐あり）
vim.keymap.set('n', 'H', function()
  if vim.fn.winline() == 1 then
    return '<PageUp>H<Plug>(H)'
  else
    return 'H<Plug>(H)'
  end
end, { expr = true })
-- Lのマッピング（条件分岐あり）
vim.keymap.set('n', 'L', function()
  if vim.fn.winline() == vim.fn.winheight(0) then
    return '<PageDown>Lzb<Plug>(L)'
  else
    return 'L<Plug>(L)'
  end
end, { expr = true })
-- <Plug>マッピング
vim.keymap.set('n', '<Plug>(H)H', '<PageUp>H<Plug>(H)')
vim.keymap.set('n', '<Plug>(L)L', '<PageDown>Lzb<Plug>(L)')
vim.keymap.set('i', '/',
  [[complete_info(['mode']).mode == 'files' && complete_info(['selected']).selected >= 0 ? '<c-x><c-f>' : '/']],
  { expr = true, noremap = false }
)

--=======================================================================================
-- ターミナル操作系
--=======================================================================================
vim.keymap.set('t', '<Esc>', '<C-\\><C-n><Plug>(Esc)', { noremap = true })
vim.keymap.set('n', '<Plug>(Esc)<Esc>', 'i', { noremap = true })

-- ノーマルモードの操作カスタマイズ
-- ;2連打でコマンドラインに移動
-- f motion とバッティングするので取り止め
-- vim.keymap.set('n', ';;', ':', { noremap = true })

-- 大文字の Y で行末までヤンク
vim.keymap.set('n', 'Y', 'y$', { silent = true, noremap = true })

-- i<space>でWORD選択
vim.keymap.set('x', 'i<leader>', 'iW', { silent = true, noremap = true })
vim.keymap.set('o', 'i<leader>', 'iW', { silent = true, noremap = true })

-- 大文字の U でリドゥ
vim.keymap.set('n', 'U', '<c-r>', { silent = true, noremap = true })

-- Visual コピー時にカーソル位置を保存
vim.keymap.set('x', 'y', 'mzy`z', { silent = true, noremap = true })

-- 大文字の X で行末まで削除
vim.keymap.set('n', 'X', '"_D$', { silent = true, noremap = true })

-- Visual <, >で連続してインデントを操作
vim.keymap.set('x', '<', '<gv', { silent = true, noremap = true })
vim.keymap.set('x', '>', '>gv', { silent = true, noremap = true })
