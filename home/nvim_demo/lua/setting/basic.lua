-- skkeleton + ddc.vim で変換候補が出たら一番上を自動的に選択するための設定
vim.opt.completeopt = 'menu,menuone'

-- c, x, s で削除した内容をレジスタに保存しない
-- https://zenn.dev/itmammoth/articles/e6d84bc346c78a#10.-x%E3%82%84s%E3%81%A7%E3%81%AF%E3%83%A4%E3%83%B3%E3%82%AF%E3%81%97%E3%81%AA%E3%81%84 参照
vim.keymap.set('n', 'c', '\"_c')
vim.keymap.set('n', 'x', '\"_x')
vim.keymap.set('n', 's', '\"_s')

-- ペースト結果のインデントを自動で揃えてカーソルを行末に移動
-- https://zenn.dev/vim_jp/articles/43d021f461f3a4#%E3%83%9A%E3%83%BC%E3%82%B9%E3%83%88%E7%B5%90%E6%9E%9C%E3%81%AE%E3%82%A4%E3%83%B3%E3%83%87%E3%83%B3%E3%83%88%E3%82%92%E8%87%AA%E5%8B%95%E3%81%A7%E6%8F%83%E3%81%88%E3%82%8B 参照
vim.keymap.set('n', 'p', ']p`]')
vim.keymap.set('n', 'P', ']P`]')

-- カーソルが行頭/末にあるとき、カーソルキー、BackSpaceキー、スペースキーで前/次行に移動しないようにする。
vim.opt.whichwrap = ""

-- ヤンクした箇所をハイライトする
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
      if vim.v.event.operator == "y" then
        vim.hl.on_yank({ timeout = 300 })
      end
    end,
})

-- スワップファイルを作成しない
vim.opt.swapfile = false
