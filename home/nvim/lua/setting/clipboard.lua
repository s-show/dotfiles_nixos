-- クリップボードとの連携は指定した場合のみにするためコメントアウト
-- vim.opt.clipboard:append { "unnamedplus" }

-- copy to clipboard
vim.keymap.set('v', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>Y', '"+yg_')

-- cut to clipboard
vim.keymap.set('v', '<leader>d', '"+d')
vim.keymap.set('n', '<leader>D', '"+dg_')

-- C-xでコマンドラインに入力した文字列をヤンクする
vim.keymap.set('c', '<C-x>', function()
  vim.fn.setreg('"0', vim.fn.getcmdline())
end)

local function paste()
  return {
    vim.fn.split(vim.fn.getreg(""), "\n"),
    vim.fn.getregtype(""),
  }
end

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ['+'] = paste,
    ['*'] = paste
  },
}

-- c, x, s で削除した内容をレジスタに保存しない
-- https://zenn.dev/itmammoth/articles/e6d84bc346c78a#10.-x%E3%82%84s%E3%81%A7%E3%81%AF%E3%83%A4%E3%83%B3%E3%82%AF%E3%81%97%E3%81%AA%E3%81%84 参照
vim.keymap.set({ 'n', 'v' }, 'c', '\"_c')
vim.keymap.set({ 'n', 'v' }, 'x', '\"_x')
vim.keymap.set({ 'n', 'v' }, 's', '\"_s')

-- ビジュアルモードで連続ペーストできるようにする
-- https://zenn.dev/itmammoth/articles/e6d84bc346c78a#11.-%E3%83%93%E3%82%B8%E3%83%A5%E3%82%A2%E3%83%AB%E3%83%A2%E3%83%BC%E3%83%89%E3%81%A7%E9%80%A3%E7%B6%9A%E3%83%9A%E3%83%BC%E3%82%B9%E3%83%88%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%88%E3%81%86%E3%81%AB 参照
vim.keymap.set('x', 'p', '\"_d\"0P')

-- ペースト結果のインデントを自動で揃えてカーソルを行末に移動
-- https://zenn.dev/vim_jp/articles/43d021f461f3a4#%E3%83%9A%E3%83%BC%E3%82%B9%E3%83%88%E7%B5%90%E6%9E%9C%E3%81%AE%E3%82%A4%E3%83%B3%E3%83%87%E3%83%B3%E3%83%88%E3%82%92%E8%87%AA%E5%8B%95%E3%81%A7%E6%8F%83%E3%81%88%E3%82%8B 参照
vim.keymap.set('n', 'p', ']p`]')
vim.keymap.set('n', 'P', ']P`]')
