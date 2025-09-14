--=======================================================================================
--リーダーキー設定
--=======================================================================================
vim.g.mapleader = " "

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
-- <leader>ww で保存
vim.keymap.set('n', '<leader>ww', "<Cmd>update<CR>")

--=======================================================================================
-- ウィンドウ操作系
--=======================================================================================
-- space-w-[vsjkhlc=]でウィンドウの分割・移動・リサイズ・クローズを実行
-- モード、キー、コマンドをまとめて管理
local keymaps = {
  -- ノーマルモードのウィンドウ操作
  { mode = 'n', key = '<leader>wv', cmd = '<Cmd>wincmd v<CR>' },
  { mode = 'n', key = '<leader>ws', cmd = '<Cmd>wincmd s<CR>' },
  { mode = 'n', key = '<leader>wj', cmd = '<Cmd>wincmd j<CR>' },
  { mode = 'n', key = '<leader>wk', cmd = '<Cmd>wincmd k<CR>' },
  { mode = 'n', key = '<leader>wh', cmd = '<Cmd>wincmd h<CR>' },
  { mode = 'n', key = '<leader>wl', cmd = '<Cmd>wincmd l<CR>' },
  { mode = 'n', key = '<leader>wc', cmd = '<Cmd>wincmd c<CR>' },

  -- ノーマルモードのタブ操作
  { mode = 'n', key = '<leader>tl', cmd = '<Cmd>tabnext<CR>' },
  { mode = 'n', key = '<leader>th', cmd = '<Cmd>tabprevious<CR>' },
  { mode = 'n', key = '<leader>tn', cmd = '<Cmd>tabnew<CR>' },

  -- ターミナルモードのキーマップ
  { mode = 't', key = '<C-g>h',     cmd = '<C-\\><C-n><C-w>h' },
  { mode = 't', key = '<C-g>j',     cmd = '<C-\\><C-n><C-w>j' },
  { mode = 't', key = '<C-g>k',     cmd = '<C-\\><C-n><C-w>k' },
  { mode = 't', key = '<C-g>l',     cmd = '<C-\\><C-n><C-w>l' },
  { mode = 't', key = '<C-g>tl',    cmd = '<Cmd>tabnext<CR>' },
  { mode = 't', key = '<C-g>th',    cmd = '<Cmd>tabprevious<CR>' },
  { mode = 't', key = '<C-g>tn',    cmd = '<Cmd>tabnew<CR>' },
}
-- まとめて設定
for _, mapping in ipairs(keymaps) do
  vim.keymap.set(mapping.mode, mapping.key, mapping.cmd, { silent = true })
end

-- タブが2つ以上あればタブを順番に選択し、タブが1つならターミナルタブを開く
vim.keymap.set('n', '<leader>tt', function()
    if #vim.api.nvim_list_tabpages() >= 2 then
      vim.cmd('tabnext')
    else
      vim.api.nvim_exec2('tabnew', { output = true })
      vim.api.nvim_exec2('terminal', { output = true })
    end
  end,
  {
    silent = true,
    desc = 'create terminal tab || tab cycle.'
  }
)

-- H/LとPageUp/PageDownを共存させる設定
-- https://blog.atusy.net/2024/05/29/vim-hl-enhanced/ を改変
-- Hのマッピング（条件分岐あり）
vim.keymap.set('n', 'H',
  function()
    if vim.fn.winline() == 1 then
      return '<PageUp>H<Plug>(H)'
    else
      return 'H<Plug>(H)'
    end
  end,
  {
    expr = true,
    desc = 'H to H and PageUp'
  }
)
-- Lのマッピング（条件分岐あり）
vim.keymap.set('n', 'L',
  function()
    if vim.fn.winline() == vim.fn.winheight(0) then
      return '<PageDown>Lzb<Plug>(L)'
    else
      return 'L<Plug>(L)'
    end
  end,
  {
    expr = true,
    desc = 'L to L and PageDown'
  })

-- [Vimでz連打でカーソル行を画面中央・上・下に移動させる](https://zenn.dev/vim_jp/articles/67ec77641af3f2) を Lua に書き直し
vim.keymap.set('n', 'zz', 'zz<Plug>(z1)', { desc = "multiple z type 'recenter-top-bottom'" })
vim.keymap.set('n', '<Plug>(z1)z', 'zt<plug>(z2)')
vim.keymap.set('n', '<Plug>(z2)z', 'zb<Plug>(z3)')
vim.keymap.set('n', '<Plug>(z3)z', 'zz<Plug>(z1)')

--=======================================================================================
-- ターミナル操作系
--=======================================================================================
vim.keymap.set('t', '<C-]>', '<C-\\><C-n>')

--=======================================================================================
-- 編集系
--=======================================================================================
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
-- 行選択でも複数行への挿入を可能にする
vim.keymap.set( "v", "A",
  function()
    if vim.fn.mode(0) == "V" then
      return "<C-v>0o$A"
    else
      return "A"
    end
  end,
  {
    expr = true,
    desc = "行選択モードでも複数行に挿入できる A",
  }
)
