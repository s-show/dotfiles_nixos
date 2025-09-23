local fuzzy_rank = require('util.fuzzy_rank')

-- cmdwin の高さを 10行に設定
vim.opt.cmdwinheight = 10

-- コマンドラインを使ってリアルタイムな曖昧検索
local function cmdline_fuzzy_search()
  local buf = vim.api.nvim_get_current_buf()
  local original_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  -- 検索前の履歴を一時退避
  vim.b.cmdwin_original_lines = original_lines

  -- 検索状態を保持するフラグ
  local search_active = true

  local group = vim.api.nvim_create_augroup('CmdwinFuzzySearch', { clear = true })

  -- 入力のためにコマンドラインに移動
  vim.api.nvim_feedkeys(':', 'n', false)

  -- CmdlineChangedイベントでリアルタイムフィルタリング
  vim.api.nvim_create_autocmd('CmdlineChanged', {
    group = group,
    callback = function()
      if not search_active then return end
      local query = vim.fn.getcmdline()
      -- 検索文字を全て削除した場合の処理
      if query == '' then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, original_lines)
      else
        local filtered = fuzzy_rank.rank(query, original_lines)
        if #filtered > 0 then
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, filtered)
        else
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '-- No matches found --' })
        end
      end
      -- コマンドラインを再描画
      vim.cmd('redraw')
      vim.cmd('normal! gg')
    end
  })

  -- Enterキーで検索を確定するキーマッピングを追加
  vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = group,
    once = true,
    callback = function()
      vim.keymap.set('c', '<CR>', function()
        search_active = false
        vim.api.nvim_clear_autocmds({ group = group })
        -- キーマッピングを削除
        pcall(vim.keymap.del, 'c', '<CR>')
        -- 空のコマンドを実行してコマンドラインを閉じる
        return '<C-u><Esc>'
      end, { expr = true })
    end
  })

  -- ESCキーでキャンセル
  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = group,
    once = true,
    callback = function()
      vim.schedule(function()
        if search_active then
          -- キャンセルされた場合は元に戻す
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, original_lines)
        end
        search_active = false
        vim.api.nvim_clear_autocmds({ group = group })
        -- キーマッピングを削除
        pcall(vim.keymap.del, 'c', '<CR>')
      end)
    end
  })
end

vim.api.nvim_create_autocmd(
  { 'CmdwinEnter' },
  {
    callback = function()
      vim.keymap.set('n', 'q', '<Cmd>close<CR>', { buffer = true })
      -- コマンドライン曖昧検索
      vim.keymap.set('n', '/', cmdline_fuzzy_search, {
        buffer = true,
        desc = 'Fuzzy search with command line'
      })
      -- このキーマップがあると `<Esc>` による復元処理がワンテンポ遅くなるので一時的に削除する
      pcall(vim.keymap.del, 'n', '<Esc><Esc>')
      -- <Esc> で検索結果を破棄してコマンド履歴を復元する
      vim.keymap.set('n', '<Esc>', function()
        local buf = vim.api.nvim_get_current_buf()
        local original = vim.b.cmdwin_original_lines
        if original then
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, original)
          vim.b.cmdwin_original_lines = nil
          vim.cmd('normal! G')
        end
      end, { buffer = true, desc = 'restore command history.' })
      vim.fn["ddc#custom#patch_global"]({
        ui = 'none'
      })
    end
  }
)

vim.api.nvim_create_autocmd(
  { 'CmdwinLeave' },
  {
    callback = function()
      pcall(vim.keymap.del, 'n', 'q')
      pcall(vim.keymap.del, 'n', '/')
      pcall(vim.keymap.del, 'n', '<Esc>')
      vim.keymap.set('n', '<ESC><ESC>', '<Cmd>nohlsearch<CR>', { silent = true })
      vim.fn["ddc#custom#patch_global"]({
        ui = 'pum'
      })
    end
  }
)
