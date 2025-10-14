--- Quickfix プレビュー機能のメインモジュール.
-- @module quickfix_preview

local state = require('util.quickfix_preview.state')
local preview = require('util.quickfix_preview.preview')
local search = require('util.quickfix_preview.search')
local qf = require('util.quickfix_preview.qf')
local fuzzy_rank = require('util.fuzzy_rank')

local M = {}

-- デバッグモード
local debug_mode = false

--- fd で検索してその結果を quickfix に挿入する関数.
-- @param query string fd に渡す検索文字列
local function fd_to_quickfix(query)
  local file_list = search.get_files(query, { debug_mode = debug_mode })
  if not file_list or #file_list == 0 then
    vim.notify("検索結果が見つかりませんでした: " .. (query or ""), vim.log.levels.WARN)
    return
  end
  qf.populate_files(file_list)
  -- Findqfから開かれたことを示す
  state.set_source('find')
  state.set_display_preview(true)
  preview.show({ debug_mode = debug_mode })
end

-- FuzzyFindの結果をQuickfixに設定する関数
-- @param query string 検索文字列
local function fuzzy_find_to_quickfix(query)
  local file_list = search.get_files(nil, { debug_mode = debug_mode })
  if not file_list or #file_list == 0 then
    vim.notify("ファイルリストが取得できませんでした", vim.log.levels.WARN)
    return
  end

  local match_list = fuzzy_rank.rank(query, file_list)
  if not match_list or #match_list == 0 then
    vim.notify("検索結果が見つかりませんでした: " .. query, vim.log.levels.WARN)
    return
  end

  qf.populate_files(match_list)
  state.set_source('find')
  vim.notify(#match_list .. " 件の検索結果が見つかりました", vim.log.levels.INFO)
  state.set_display_preview(true)
  preview.show({ debug_mode = debug_mode })
end

--- バッファリストをquickfixに表示
local function buffers_to_quickfix()
  if qf.populate_buffers() then
    state.set_source('buffers')
    state.set_display_preview(true)
    preview.show({ debug_mode = debug_mode })
  end
end

--- バッファリストをquickfixに表示
local function oldfiles_to_quickfix()
  if qf.populate_oldfiles() then
    state.set_source('oldfiles')
    state.set_display_preview(true)
    preview.show({ debug_mode = debug_mode })
  end
end

--- セットアップ関数.
function M.setup(opts)
  opts = opts or {}
  debug_mode = opts.debug_mode or false

  -- Quickfixウィンドウ用の自動コマンドグループ
  local augroup = vim.api.nvim_create_augroup('QuickfixPreview', { clear = true })

  -- Quickfixウィンドウでカーソルが動いたときにプレビューを更新
  vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
    group = augroup,
    pattern = '*',
    callback = function()
      if vim.bo.buftype == 'quickfix' and state.get().display_preview then
        preview.show({ debug_mode = debug_mode })
      end
    end
  })

  -- Quickfixウィンドウを離れたときにプレビューを閉じる
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
    group = augroup,
    pattern = '*',
    callback = function()
      if vim.bo.buftype == 'quickfix' then
        state.set_display_preview(false)
        preview.close()
      end
    end
  })

  -- quickfixウィンドウが閉じられた時の処理
  vim.api.nvim_create_autocmd('BufWinLeave', {
    group = augroup,
    pattern = '*',
    callback = function()
      -- close_preview実行中の場合は何もしない
      if state.get().closing_preview then
        return
      end

      if vim.bo.buftype == 'quickfix' then
        local qf_bufnr = vim.api.nvim_get_current_buf()
        local winids = vim.fn.win_findbuf(qf_bufnr)
        -- quickfix ウィンドウが閉じられたときにクリーンアップ処理を実行する
        if #winids == 0 then
          state.set_source('grep')
          pcall(vim.keymap.del, 'n', 'q', { buffer = true })
          state.set_display_preview(false)
        end
      end
    end
  })

  -- Quickfixウィンドウ内でのキーマッピング
  vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    pattern = 'qf',
    callback = function()
      -- pキーでプレビューの表示/非表示を切り替え
      vim.keymap.set('n', 'p', ':QuickfixPreviewToggle<CR>', {
        buffer = true,
        silent = true,
        desc = 'Toggle preview window'
      })
      vim.keymap.set('n', 'q', ':cclose<CR>', {
        buffer = true,
        silent = true,
        desc = 'Close quickfix window'
      })
      -- `o` でアイテムを開くと同時に quickfix を閉じる
      vim.keymap.set('n', 'o', function()
        vim.cmd('cc ' .. vim.fn.line('.'))
        vim.cmd('cclose')
      end, {
        buffer = true,
        silent = true,
        desc = 'Open quickfix item and close quickfix window.'
      })
      -- `<Enter>` でアイテムを開くと同時に quickfix を閉じる
      vim.keymap.set('n', '<Enter>', function()
        vim.cmd('cc ' .. vim.fn.line('.'))
        vim.cmd('cclose')
      end, {
        buffer = true,
        silent = true,
        desc = 'Open quickfix item and close quickfix window.'
      })
      -- `v` で垂直分割（左端）に開くと同時にquickfixを閉じる
      vim.keymap.set('n', 'v', function()
        qf.open_in_split('vsplit')
      end, {
        buffer = true,
        silent = true,
        desc = 'Open quickfix item in vertical split (top left) and close quickfix window.'
      })
      -- `s` で水平分割（左上のウィンドウの下半分）に開くと同時にquickfixを閉じる
      vim.keymap.set('n', 's', function()
        qf.open_in_split('split')
      end, {
        buffer = true,
        silent = true,
        desc = 'Open quickfix item in horizontal split (top left bottom half) and close quickfix window.'
      })
      -- <Ctrl-v> で垂直分割（左端）に開く
      vim.keymap.set('n', '<C-v>', function()
        qf.open_in_split('vsplit', false)
      end, {
        buffer = true,
        silent = true,
        desc = 'Open quickfix item in vertical split (top left)'
      })
      -- <Ctrl-s> で水平分割（左上のウィンドウの下半分）に開く
      vim.keymap.set('n', '<C-s>', function()
        qf.open_in_split('split', false)
      end, {
        buffer = true,
        silent = true,
        desc = 'Open quickfix item in horizontal split (top left bottom half)'
      })
    end
  })

  -- 検索パターンを入力した直後にクイックフィックスを自動で閉じる
  vim.api.nvim_create_augroup('QuickfixAutoClose', { clear = true })
  -- ① すべての grep 系コマンド実行前に既存の quickfix ウィンドウを閉じる
  vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = 'QuickfixAutoClose',
    pattern = ':vimgrep*,:grep*,:lgrep*',
    callback = function()
      if vim.fn.winnr('$') > 0 then
        vim.cmd('cclose') -- 既に表示されている quickfix を閉じる
      end
    end,
  })

  -- ② 検索コマンド実行後、結果があるときだけ再度開く
  vim.api.nvim_create_autocmd('QuickFixCmdPost', {
    group = 'QuickfixAutoClose',
    pattern = { 'vimgrep', 'grep', 'lgrep', 'lvimgrep' },
    callback = function()
      local qflist = vim.fn.getqflist()
      if #qflist > 0 then
        vim.cmd('copen')  -- 結果が1件以上ならウィンドウを開く
      else
        vim.cmd('cclose') -- 結果が0件なら確実に閉じておく
      end
    end,
  })

  -- コマンドの定義

  -- プレビューの表示/非表示を切り替えるコマンド
  vim.api.nvim_create_user_command('QuickfixPreviewToggle', function()
    preview.toggle()
  end, {})

  -- Find の結果をQuickfixに表示するコマンド
  vim.api.nvim_create_user_command('Findqf', function(args)
    local query = table.concat(args.fargs, ' ')
    fd_to_quickfix(query)
  end, {
    nargs = '+',
    desc = 'Find files and show in quickfix'
  })

  -- Fuzzy find の結果をQuickfixに表示するコマンド
  vim.api.nvim_create_user_command('Fzfqf', function(args)
    local pattern = table.concat(args.fargs, ' ')
    if pattern == '' then
      vim.notify("検索パターンを指定してください", vim.log.levels.WARN)
      return
    end
    fuzzy_find_to_quickfix(pattern)
  end, {
    nargs = '+',
    desc = 'Fuzzy find files and show in quickfix'
  })

  -- Grep 用ラッパーコマンド（silent かつ quickfix にフォーカス）
  vim.api.nvim_create_user_command('Grep', function(args)
    -- すべて silent! で実行し、エラーメッセージも抑制
    vim.cmd('silent! grep ' .. table.concat(args.fargs, ' '))
    -- QuickFixCmdPost が走った後でも確実に開きたい場合はここでも
    state.set_source('grep')
    state.set_display_preview(true)
    vim.cmd('copen')
  end, {
    nargs = '+',
  })

  -- バッファリストをQuickfixに表示するコマンド
  vim.api.nvim_create_user_command('Bufqf', function()
    buffers_to_quickfix()
  end, {
    desc = 'List buffers in quickfix'
  })

  -- ファイル履歴をQuickfixに表示するコマンド
  vim.api.nvim_create_user_command('Oldfileqf', function()
    oldfiles_to_quickfix()
  end, {
    desc = 'List oldfiles in quickfix'
  })

  -- キーマッピング
  vim.keymap.set('n', '<leader>d',  ':Findqf ', { desc = 'Find file and show in quickfix' })
  vim.keymap.set('n', '<leader>z',  ':Fzfqf ', { desc = 'Fuzzy find files and show in quickfix' })
  vim.keymap.set('n', '<leader>gr', ':Grep ', { desc = 'grep wrapper and show in quickfix' })
  vim.keymap.set('n', '<leader>ol', ':Oldfileqf<CR>', { desc = 'oldfiles -> quickfix' })
  vim.keymap.set('n', '<leader>qb', ':Bufqf<CR>', { desc = 'Buffers -> quickfix' })
end

-- 各モジュールをエクスポート（必要に応じて）
M.preview = preview
M.search = search
M.qf = qf
M.state = state

return M

