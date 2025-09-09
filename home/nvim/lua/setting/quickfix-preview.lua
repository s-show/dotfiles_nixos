-- Wildmenu設定
vim.opt.wildmenu = true
vim.opt.wildmode = { 'noselect:longest:lastused', 'full' }

-- fd と fzf が利用可能な場合、findfunc を設定
if vim.fn.executable('fd') == 1 and vim.fn.executable('fzf') == 1 then
  vim.opt.findfunc = 'v:lua.FuzzyFindFunc'
end

-- FuzzyFind関数
function FuzzyFindFunc(cmdarg)
  local cmd = "fd --hidden . | fzf --filter='" .. cmdarg .. "'"
  return vim.fn.systemlist(cmd)
end

-- Quickfixにfdの結果を設定する関数
function FdSetQuickfix(...)
  local args = { ... }
  local cmd = "fd -t f --hidden " .. table.concat(args, " ")
  local fdresults = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 then
    vim.notify("Fd エラー: " .. (fdresults[1] or "不明なエラー"), vim.log.levels.ERROR)
    return
  end

  local qflist = {}
  for _, val in ipairs(fdresults) do
    table.insert(qflist, {
      filename = val,
      lnum = 1,
      text = val
    })
  end

  vim.fn.setqflist(qflist)
  -- Findqfから開かれたことを示すフラグを設定
  vim.g.quickfix_opened_by_findqf = true
  vim.cmd('copen')
end

-- キーマッピング
vim.keymap.set('n', '<leader>f', ':find ', { desc = 'Find file' })
vim.keymap.set('n', '<leader>F', ':vert sf ', { desc = 'Find file in vertical split' })
vim.keymap.set('n', '<leader>d', ':Findqf ', { desc = 'Find with fd and show in quickfix' })

-- コマンド定義
vim.api.nvim_create_user_command('Findqf', function(opts)
  FdSetQuickfix(unpack(opts.fargs))
end, {
  nargs = '+',
  complete = 'file_in_path'
})

-- ============================
-- Quickfixプレビュー機能の追加
-- ============================

-- プレビューウィンドウの設定
local preview_win = nil
local preview_buf = nil
local closing_preview = false -- close_preview実行中かどうかのフラグ

-- プレビューウィンドウを作成・更新する関数
local function show_preview()
  -- 現在の行の情報を取得
  local qflist = vim.fn.getqflist()
  local current_line = vim.fn.line('.')

  if current_line < 1 or current_line > #qflist then
    return
  end

  local item = qflist[current_line]
  -- vim.notify(vim.inspect(item)) -- デバッグ用（必要に応じてコメントアウト）
  local filename = item.filename or item.bufnr and vim.fn.bufname(item.bufnr) or ''

  if filename == '' then
    return
  end

  -- ファイルが存在するかチェック
  if vim.fn.filereadable(filename) == 0 then
    return
  end

  -- プレビューバッファが存在しない場合は作成
  if not preview_buf or not vim.api.nvim_buf_is_valid(preview_buf) then
    preview_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[preview_buf].bufhidden = 'wipe'
  end

  -- ファイルの内容を読み込み
  -- （fd なら最初の7行を読み込み、vimgrep なら該当行から7行を読み込み）
  local start_line = item.lnum
  local lines = {}
  local result = {}
  if vim.g.quickfix_opened_by_findqf then
    result = vim.fn.readfile(filename, '', 7)
  else
    lines = vim.fn.readfile(filename)
  end
  local end_line = math.min(start_line + 7 - 1, #lines)

  for i = start_line, end_line do
    table.insert(result, lines[i])
  end

  -- バッファに内容を設定
  vim.bo[preview_buf].modifiable = true
  -- vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, result)
  vim.bo[preview_buf].modifiable = false
  vim.bo[preview_buf].filetype = vim.fn.fnamemodify(filename, ':e')

  -- プレビューウィンドウが存在しない、または無効な場合は作成
  if not preview_win or not vim.api.nvim_win_is_valid(preview_win) then
    -- 現在のウィンドウの位置とサイズを取得
    local current_win = vim.api.nvim_get_current_win()
    local win_width = vim.api.nvim_win_get_width(current_win)
    local win_height = vim.api.nvim_win_get_height(current_win)

    -- プレビューウィンドウのサイズと位置を計算
    local preview_width = math.floor(win_width * 0.5)
    local preview_height = math.min(20, math.floor(win_height * 0.7))

    -- フローティングウィンドウの設定
    local opts = {
      relative = 'win',
      win = current_win,
      width = preview_width,
      height = preview_height,
      col = win_width - preview_width - 2,
      row = 1,
      style = 'minimal',
      border = 'rounded',
      title = ' Preview: ' .. vim.fn.fnamemodify(filename, ':t') .. ' ',
      title_pos = 'center',
    }

    preview_win = vim.api.nvim_open_win(preview_buf, false, opts)

    -- プレビューウィンドウのオプション設定
    vim.wo[preview_win].winhl = 'Normal:NormalFloat'
    vim.wo[preview_win].cursorline = true
  else
    -- 既存のウィンドウにバッファを設定
    vim.api.nvim_win_set_buf(preview_win, preview_buf)
    -- タイトルを更新

    vim.api.nvim_win_set_config(preview_win, {
      title = ' Preview: ' .. vim.fn.fnamemodify(filename, ':t') .. ' ',
    })
  end

  -- 該当行にジャンプ
  if item.lnum and item.lnum > 0 then
    -- vim.api.nvim_win_set_cursor(preview_win, { math.min(item.lnum, #lines), 0 })
    vim.api.nvim_win_set_cursor(preview_win, { math.min(item.lnum, #result), 0 })
  end
end

-- プレビューウィンドウを閉じる関数
local function close_preview()
  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    -- close_preview実行中のフラグを立てる
    closing_preview = true

    -- ウィンドウを閉じる前に、バッファの参照を一時保存
    local buf_to_delete = preview_buf

    -- ウィンドウを閉じる
    pcall(vim.api.nvim_win_close, preview_win, true)
    preview_win = nil

    -- バッファが有効で、他のウィンドウで使われていない場合のみ削除
    if buf_to_delete and vim.api.nvim_buf_is_valid(buf_to_delete) then
      local wins = vim.fn.win_findbuf(buf_to_delete)
      if #wins == 0 then
        pcall(vim.api.nvim_buf_delete, buf_to_delete, { force = true })
      end
    end
    preview_buf = nil

    -- フラグをリセット
    closing_preview = false
  end
end

-- Quickfixウィンドウ用の自動コマンドグループ
local augroup = vim.api.nvim_create_augroup('QuickfixPreview', { clear = true })

-- Quickfixウィンドウでカーソルが動いたときにプレビューを更新
vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    if vim.bo.buftype == 'quickfix' and vim.g.quickfix_opened_by_findqf then
      show_preview()
    end
  end
})

-- Quickfixウィンドウを離れたときにプレビューを閉じる
vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    if vim.bo.buftype == 'quickfix' then
      close_preview()
    end
  end
})

-- Quickfixウィンドウが閉じられたときにプレビューも閉じる
vim.api.nvim_create_autocmd({ 'BufWinLeave' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    -- close_preview実行中の場合は何もしない
    if closing_preview then
      return
    end

    if vim.bo.buftype == 'quickfix' then
      close_preview()
    end
  end
})

-- プレビューの表示/非表示を切り替えるコマンド（オプション）
vim.api.nvim_create_user_command('QuickfixPreviewToggle', function()
  if vim.bo.buftype ~= 'quickfix' then
    vim.notify('This command only works in quickfix window', vim.log.levels.WARN)
    return
  end

  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    close_preview()
  else
    show_preview()
  end
end, {})

-- Quickfixウィンドウ内でのキーマッピング（オプション）
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
    -- Findqfでquickfixを開いた時のみqキーを設定
    vim.keymap.set('n', 'q', ':cclose<CR>', {
      buffer = true,
      silent = true,
      desc = 'Close quickfix window'
    })
  end
})

-- quickfixウィンドウが閉じられた時にqキーマッピングを削除
vim.api.nvim_create_autocmd('BufWinLeave', {
  group = augroup,
  pattern = '*',
  callback = function()
    -- close_preview実行中の場合は何もしない
    if closing_preview then
      return
    end

    if vim.bo.buftype == 'quickfix' and vim.g.quickfix_opened_by_findqf then
      -- フラグをリセット
      vim.g.quickfix_opened_by_findqf = false
      -- qキーマッピングを削除（存在する場合のみ）
      pcall(vim.keymap.del, 'n', 'q', { buffer = true })
    end
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

-- Grep 用ラッパーコマンド（silent かつ quickfix にフォーカス）
vim.api.nvim_create_user_command('Grep', function(opts)
  -- すべて silent! で実行し、エラーメッセージも抑制
  vim.cmd('silent! grep ' .. table.concat(opts.fargs, ' '))
  -- QuickFixCmdPost が走った後でも確実に開きたい場合はここでも
  vim.cmd('copen')
end, {
  nargs = '*',
  complete = 'file',
})
