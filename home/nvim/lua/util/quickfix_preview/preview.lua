--- プレビューウィンドウ管理モジュール.
-- @module quickfix_preview.preview

local state = require('util.quickfix_preview.state')

local M = {}

--- プレビューウィンドウを閉じる.
function M.close()
  local s = state.get()
  if s.preview_win and vim.api.nvim_win_is_valid(s.preview_win) then
    -- close_preview実行中のフラグを立てる
    state.set_closing_preview(true)

    -- ウィンドウを閉じる前に、バッファの参照を一時保存
    local buf_to_delete = s.preview_buf

    -- ウィンドウを閉じる
    pcall(vim.api.nvim_win_close, s.preview_win, true)
    state.set_preview_win(nil)

    -- バッファが有効で、他のウィンドウで使われていない場合のみ削除
    if buf_to_delete and vim.api.nvim_buf_is_valid(buf_to_delete) then
      local wins = vim.fn.win_findbuf(buf_to_delete)
      if #wins == 0 then
        pcall(vim.api.nvim_buf_delete, buf_to_delete, { force = true })
      end
    end
    state.set_preview_buf(nil)

    -- フラグをリセット
    state.set_closing_preview(false)
    state.set_display_preview(false)
  end
end

--- プレビューウィンドウを作成・更新する.
-- @param opts table オプション（debug_mode を含む）
function M.show(opts)
  opts = opts or {}
  local debug_mode = opts.debug_mode or false

  local qflist = vim.fn.getqflist()
  local current_line = vim.fn.line('.')

  if current_line < 1 or current_line > #qflist then
    return
  end

  local item = qflist[current_line]
  if debug_mode then
    vim.notify(vim.inspect(item))
  end

  local filename = (item.bufnr and vim.fn.bufname(item.bufnr)) or item.filename or ''
  if filename == '' then
    return
  end

  -- ファイルが存在するかチェック
  if vim.fn.filereadable(filename) == 0 then
    return
  end

  local s = state.get()

  -- プレビューバッファが存在しない場合は作成
  if not s.preview_buf or not vim.api.nvim_buf_is_valid(s.preview_buf) then
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = 'wipe'
    state.set_preview_buf(buf)
    s = state.get()
  end

  -- ファイルの内容を読み込み
  local lnum = (type(item.lnum) == "number" and item.lnum > 0) and item.lnum or 1
  local result = {}

  if state.is_from_find() then
    -- fd/find の場合は最初の7行
    result = vim.fn.readfile(filename, '', 7)
  else
    -- grep等の場合は該当行の前後を含めて読み込み
    local from_line = math.max(1, lnum - 3)
    local to_line = lnum + 3
    result = vim.fn.readfile(filename, '', to_line)
    -- from_line から to_line までを抽出
    if #result >= from_line then
      local extracted = {}
      for i = from_line, math.min(to_line, #result) do
        table.insert(extracted, result[i])
      end
      result = extracted
    end
  end

  -- バッファに内容を設定
  vim.bo[s.preview_buf].modifiable = true
  local ok, _ = pcall(vim.api.nvim_buf_set_lines, s.preview_buf, 0, -1, false, result)
  -- バイナリファイルなどを読み込んだ場合は処理終了
  if ok == false then
    vim.api.nvim_buf_set_lines(s.preview_buf, 0, -1, false, { "Unable to preview this file." })
    return
  end
  vim.bo[s.preview_buf].modifiable = false
  vim.bo[s.preview_buf].filetype = (vim.filetype and vim.filetype.match) and vim.filetype.match({ filename = filename }) or vim.fn.fnamemodify(filename, ':e')

  -- プレビューウィンドウが存在しない、または無効な場合は作成
  if not s.preview_win or not vim.api.nvim_win_is_valid(s.preview_win) then
    -- 現在のウィンドウの位置とサイズを取得
    local current_win = vim.api.nvim_get_current_win()
    local win_width = vim.api.nvim_win_get_width(current_win)
    local win_height = vim.api.nvim_win_get_height(current_win)

    -- プレビューウィンドウのサイズと位置を計算
    local preview_width = math.floor(win_width * 0.5)
    local preview_height = math.min(20, math.floor(win_height * 0.7))

    -- フローティングウィンドウの設定
    local win_opts = {
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
    local win = vim.api.nvim_open_win(s.preview_buf, false, win_opts)
    state.set_preview_win(win)

    -- プレビューウィンドウのオプション設定
    vim.wo[win].winhl = 'Normal:NormalFloat'
    vim.wo[win].cursorline = true
  else
    -- 既存のウィンドウにバッファを設定
    vim.api.nvim_win_set_buf(s.preview_win, s.preview_buf)
    -- タイトルを更新
    vim.api.nvim_win_set_config(s.preview_win, {
      title = ' Preview: ' .. vim.fn.fnamemodify(filename, ':t') .. ' ',
    })
  end

  -- 該当行にジャンプ
  if lnum > 0 then
    -- is_from_find の場合は先頭、それ以外は中央行
    local cursor_line = state.is_from_find() and math.min(lnum, #result) or math.min(4, #result)
    vim.api.nvim_win_set_cursor(state.get().preview_win, { cursor_line, 0 })
  end
end

--- プレビューの表示/非表示を切り替える.
function M.toggle()
  local s = state.get()
  if vim.bo.buftype ~= 'quickfix' then
    vim.notify('This command only works in quickfix window', vim.log.levels.WARN)
    return
  end

  if s.preview_win and vim.api.nvim_win_is_valid(s.preview_win) then
    state.set_display_preview(false)
    M.close()
  else
    state.set_display_preview(true)
    M.show()
  end
end

return M
