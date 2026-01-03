-- Esc 二連打で検索でヒットした箇所のハイライトを消去する
vim.keymap.set('n', '<ESC><ESC>', '<Cmd>nohlsearch<CR>',
{ silent = true }
)

-- set help file language
vim.opt.helplang = 'ja'

-- netrw disabled
-- vim.api.nvim_set_var('loaded_netrwPlugin', 1)

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
  desc = "Not record 'w', 'q' etc command in command_history"
})

-- コマンド履歴の保存件数を1000件にする
vim.opt.history = 1000

-- カーソル下の単語をハイライトする
-- https://zenn.dev/itmammoth/articles/e6d84bc346c78a#1.-%E3%82%AB%E3%83%BC%E3%82%BD%E3%83%AB%E4%B8%8B%E3%81%AE%E5%8D%98%E8%AA%9E%E3%82%92%E3%83%8F%E3%82%A4%E3%83%A9%E3%82%A4%E3%83%88%E3%81%99%E3%82%8B 参照
vim.keymap.set('n', '<space><space>', function()
  vim.fn.setreg('/', vim.fn.expand('<cword>'))
  vim.opt.hlsearch = true
end,
{ desc = "Highlight word under cursor" }
)

-- カーソル下の単語のヘルプを開く
-- vim.cmd.help(vim.fn.expand('<cword>')) を rhs に直接設定すると
-- なぜかエラーになるので、コールバック関数で呼び出している。
vim.keymap.set('n', '<leader>H',
  function()
    vim.cmd [[echon '']]
    local pcall_result, _ = pcall(vim.cmd.help, vim.fn.expand('<cword>'))
    if pcall_result ~= true then
      vim.notify('keyword not found in help.', vim.log.levels.WARN)
    end
  end,
{ desc = 'Open help under the cursor' }
)

-- `K` をタイプするとカーソル下のキーワードのヘルプを表示
-- ヘルプ画面でも使用可能
vim.opt_global.keywordprg = ':help'

-- カーソルが行頭/末にあるとき、カーソルキー、BackSpaceキー、スペースキーで前/次行に移動しないようにする。
vim.opt.whichwrap = ""

-- コマンドラインの実行結果を新しいバッファに追記するコマンドを作成
-- https://www.reddit.com/r/neovim/comments/zhweuc/whats_a_fast_way_to_load_the_output_of_a_command/ を参考に作成
vim.api.nvim_create_user_command('Redir', function(ctx)
  local _, function_return = pcall(vim.fn.execute, ctx.args)
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
  desc = 'Highlight yank strings',
})


-- Vim/Neovimをquitするときに特殊ウィンドウを一気に閉じる
-- https://zenn.dev/vim_jp/articles/ff6cd224fab0c7
vim.api.nvim_create_autocmd('QuitPre', {
  callback = function()
    -- 現在のウィンドウ番号を取得
    local current_win = vim.api.nvim_get_current_win()
    -- すべてのウィンドウをループして調べる
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      -- カレント以外を調査
      if win ~= current_win then
        local buf = vim.api.nvim_win_get_buf(win)
        -- buftypeが空文字（通常のバッファ）があればループ終了
        if vim.bo[buf].buftype == '' then
          return
        end
      end
    end
    -- ここまで来たらカレント以外がすべて特殊ウィンドウということなので
    -- カレント以外をすべて閉じる
    vim.cmd.only({ bang = true })
    -- この後、ウィンドウ1つの状態でquitが実行されるので、Vimが終了する
  end,
  desc = 'Close all special buffers and quit Neovim',
})
