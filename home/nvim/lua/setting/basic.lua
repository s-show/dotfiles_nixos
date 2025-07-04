-- 検索設定
vim.api.nvim_set_keymap('n', '<ESC><ESC>', '<Cmd>nohlsearch<CR>', {silent=true})

-- set help file language
vim.opt.helplang = 'ja'

-- netrw disabled
vim.api.nvim_set_var('loaded_netrwPlugin', 1)

-- skkeleton + ddc.vim で変換候補が出たら一番上を自動的に選択するための設定
vim.opt.completeopt = 'menu,menuone'

-- `w`や`q`などのコマンドをコマンド履歴に残さないようにする設定
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "c:*",
  -- group = utils.augroup,
  callback = function()
    local cmd = vim.fn.histget(":", -1)
    if cmd == "x" or cmd == "xa" or cmd:match("^w?q?a?!?$") then
      vim.fn.histdel(":", -1)
    end
  end,
})

-- コマンド履歴の保存件数を1000件にする
vim.opt.history = 1000

-- c, x, s で削除した内容をレジスタに保存しない
-- https://zenn.dev/itmammoth/articles/e6d84bc346c78a#10.-x%E3%82%84s%E3%81%A7%E3%81%AF%E3%83%A4%E3%83%B3%E3%82%AF%E3%81%97%E3%81%AA%E3%81%84 参照
vim.keymap.set('n', 'c', '\"_c')
vim.keymap.set('n', 'x', '\"_x')
vim.keymap.set('n', 's', '\"_s')

-- ビジュアルモードで連続ペーストできるようにする
-- https://zenn.dev/itmammoth/articles/e6d84bc346c78a#11.-%E3%83%93%E3%82%B8%E3%83%A5%E3%82%A2%E3%83%AB%E3%83%A2%E3%83%BC%E3%83%89%E3%81%A7%E9%80%A3%E7%B6%9A%E3%83%9A%E3%83%BC%E3%82%B9%E3%83%88%E3%81%A7%E3%81%8D%E3%82%8B%E3%82%88%E3%81%86%E3%81%AB 参照
vim.keymap.set('x', 'p', '\"_d\"0P')

-- ペースト結果のインデントを自動で揃えてカーソルを行末に移動
-- https://zenn.dev/vim_jp/articles/43d021f461f3a4#%E3%83%9A%E3%83%BC%E3%82%B9%E3%83%88%E7%B5%90%E6%9E%9C%E3%81%AE%E3%82%A4%E3%83%B3%E3%83%87%E3%83%B3%E3%83%88%E3%82%92%E8%87%AA%E5%8B%95%E3%81%A7%E6%8F%83%E3%81%88%E3%82%8B 参照
vim.keymap.set('n', 'p', ']p`]')
vim.keymap.set('n', 'P', ']P`]')

-- カーソル下の単語をハイライトする
-- https://zenn.dev/itmammoth/articles/e6d84bc346c78a#1.-%E3%82%AB%E3%83%BC%E3%82%BD%E3%83%AB%E4%B8%8B%E3%81%AE%E5%8D%98%E8%AA%9E%E3%82%92%E3%83%8F%E3%82%A4%E3%83%A9%E3%82%A4%E3%83%88%E3%81%99%E3%82%8B 参照
vim.keymap.set('n', '<space><space>', function ()
  vim.fn.setreg('/', vim.fn.expand('<cword>'))
  vim.opt.hlsearch = true
end)

-- カーソル下の単語のヘルプを開く 
-- vim.cmd.help(vim.fn.expand('<cword>')) を rhs に直接設定すると
-- なぜかエラーになるので、コールバック関数で呼び出している。
vim.keymap.set('n', '<leader>H', function()
  vim.cmd[[echon '']]
  local pcall_result, function_return = pcall(vim.cmd.help, vim.fn.expand('<cword>'))
  if pcall_result ~= true then
    vim.notify('keyword not found in help.', vim.log.levels.WARN)
  end
end)

-- `K` をタイプするとカーソル下のキーワードのヘルプを表示
-- ヘルプ画面でも使用可能
vim.opt_global.keywordprg = ':help'

-- カーソルが行頭/末にあるとき、カーソルキー、BackSpaceキー、スペースキーで前/次行に移動しないようにする。
vim.opt.whichwrap = ""

-- コマンドラインの実行結果を新しいバッファに追記するコマンドを作成
-- https://www.reddit.com/r/neovim/comments/zhweuc/whats_a_fast_way_to_load_the_output_of_a_command/ を参考に作成
vim.api.nvim_create_user_command('Redir', function(ctx)
  local pcall_result, function_return = pcall(vim.fn.execute, ctx.args)
  vim.cmd('new')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(function_return, '\n', { plain = true }))
  vim.opt_local.modified = false
end, { nargs = '+', complete = 'command' })

-- ヤンクした箇所をハイライトする
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
      if vim.v.event.operator == "y" then
        vim.hl.on_yank({ timeout = 300 })
      end
    end,
})
