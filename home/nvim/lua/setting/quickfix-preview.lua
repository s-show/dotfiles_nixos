--- 全体的な設定.
-- この設定全体で使う設定など.
-- @section basic

-- Wildmenu設定
vim.opt.wildmenu = true
vim.opt.wildmode = { 'noselect:longest:lastused', 'full' }
local debug_mode = false
local default_exclude_dirs = {
  ".git", ".svn", ".hg", ".bzr",
  "node_modules", "vendor",
  ".venv", "venv", "env",
  "__pycache__", ".pytest_cache", ".mypy_cache", ".tox",
  "dist", "build", "target",
  ".idea", ".vscode",
  ".DS_Store", ".cache",
  ".npm", ".yarn",
  "coverage", ".nyc_output",
  ".next", ".nuxt", "out"
}

--- テキストが空白文字だけで構成されているか調べる関数.
-- @param text string 調べたいテキスト.
-- @return boolean 空白文字だけなら `true`, 非空白文字があれば `false` を返す
local function is_blank_text(text)
  if text == nil or #text == 0 or vim.fn.match(text, '\\S') == -1 then
    return true
  else
    return false
  end
end

--- Quickfix プレビューセクション.
-- Quickfix のプレビューに関する設定.
-- @section quickfix

--- プレビューウィンドウの設定.
local preview_win     = nil
local preview_buf     = nil
local display_preview = false
local closing_preview = false -- close_preview実行中かどうかのフラグ
local quickfix_with_custom_find = false -- find/fd から開かれたかどうかのフラグ

--- プレビューウィンドウを閉じる関数.
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
    display_preview = false
  end
end

--- プレビューウィンドウを作成・更新する関数.
local function show_preview()
  local qflist = vim.fn.getqflist()
  local current_line = vim.fn.line('.')

  if current_line < 1 or current_line > #qflist then
    return
  end

  local item = qflist[current_line]
  if debug_mode then
    vim.notify(vim.inspect(item))
  end
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
  if quickfix_with_custom_find then
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
  local ok, _ = pcall(vim.api.nvim_buf_set_lines, preview_buf, 0, -1, false, result)
  -- バイナリファイルなどを読み込んだ場合は処理終了
  if ok == false then
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, { "Unable to preview this file." })
    return
  end
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
  -- display_preview = true
end

--- Quickfix ウィンドウのアイテムを垂直/水平分割で開く関数.
-- @param split_cmd string 垂直/水平分割の指定
local function open_quickfix_item(split_cmd)
  local qflist = vim.fn.getqflist()
  local current_line = vim.fn.line('.')
  local item = qflist[current_line]
  local filename = item.filename or item.bufnr and vim.fn.bufname(item.bufnr) or ''
  if filename == '' then
    vim.notify('Quickfix entry が取得できません', vim.log.levels.WARN)
    return
  end

  local lnum = (item.lnum and item.lnum > 0) and item.lnum or 1

  -- split_cmd は "vsplit" か "split"
  local cmd = string.format('%s +%d %s',
    split_cmd,
    lnum,
    vim.fn.fnameescape(filename))

  vim.cmd('cclose')   -- ウィンドウ操作を簡単にするために Quickfix ウィンドウをいったん閉じる
  vim.cmd('wincmd t') -- 左上のウィンドウに移動
  vim.cmd(cmd)        -- 分割してファイルを開く
  vim.cmd('copen')    -- Quickfix ウィンドウを再度開く
  if split_cmd == 'split' then
    vim.cmd('vertical wincmd =')
  end
end

-- Quickfixウィンドウ用の自動コマンドグループ
local augroup = vim.api.nvim_create_augroup('QuickfixPreview', { clear = true })

-- Quickfixウィンドウでカーソルが動いたときにプレビューを更新
vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
  group = augroup,
  pattern = '*',
  callback = function()
    if vim.bo.buftype == 'quickfix' and display_preview then
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
      display_preview = false
      close_preview()
    end
  end
})

-- プレビューの表示/非表示を切り替えるコマンド
vim.api.nvim_create_user_command('QuickfixPreviewToggle', function()
  if vim.bo.buftype ~= 'quickfix' then
    vim.notify('This command only works in quickfix window', vim.log.levels.WARN)
    return
  end

  if preview_win and vim.api.nvim_win_is_valid(preview_win) then
    display_preview = false
    close_preview()
  else
    display_preview = true
    show_preview()
  end
end, {})

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
    -- <C-v> で垂直分割（左端）に開く
    vim.keymap.set('n', '<C-v>', function()
      open_quickfix_item('vsplit')
    end, {
      buffer = true,
      silent = true,
      desc = 'Open quickfix item in vertical split (top left)'
    })
    -- <C-s> で水平分割（左上のウィンドウの下半分）に開く
    vim.keymap.set('n', '<C-s>', function()
      open_quickfix_item('split')
    end, {
      buffer = true,
      silent = true,
      desc = 'Open quickfix item in horizontal split (top left bottom half)'
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

    if vim.bo.buftype == 'quickfix' then
      local qf_bufnr = vim.api.nvim_get_current_buf()
      local winids = vim.fn.win_findbuf(qf_bufnr)
      -- quickfix ウィンドウが閉じられたときにクリーンアップ処理を実行する
      if #winids == 0 then
        quickfix_with_custom_find = false
        pcall(vim.keymap.del, 'n', 'q', { buffer = true })
        display_preview = false
      end
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


--- find/fd sections.
-- find/fd による検索に関する設定.
-- @section find/fd

--- fdが利用可能かチェック.
local function is_fd_available()
  return vim.fn.executable("fd") == 1
end

--- findコマンドを構築.
-- @param exclude_dirs string[] 検索対象から除外するディレクトリのリスト
-- @param search_fils string 検索したいファイル名
-- @return function() find 検索のコマンド文字列
local function build_find_command(exclude_dirs, search_file)
  local prune_parts = {}
  for i, dir in ipairs(exclude_dirs) do
    table.insert(prune_parts, "-name " .. dir)
    if i < #exclude_dirs then
      table.insert(prune_parts, "-o")
    end
  end

  if is_blank_text(search_file) == false then
    return string.format(
      [[find . -type d \( %s \) -prune -o -name "*%s*" -type f -print | awk '{ flag = ($0 ~ /^\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      table.concat(prune_parts, " "),
      search_file
    )
  else
    return string.format(
      [[find . -type d \( %s \) -prune -o -type f -print | awk '{ flag = ($0 ~ /^\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      table.concat(prune_parts, " ")
    )
  end
end

--- fdコマンドを構築.
-- @param exclude_dirs string[] 検索対象から除外するディレクトリのリスト
-- @param search_fils string 検索したいファイル名
-- @return function() fd 検索のコマンド文字列
local function build_fd_command(exclude_dirs, search_file)
  local exclude_parts = {}
  for _, dir in ipairs(exclude_dirs) do
    table.insert(exclude_parts, "--exclude " .. vim.fn.shellescape(dir))
  end
  local fd_cmd = ""
  if is_blank_text(search_file) == false then
    fd_cmd = string.format(
      [[fd %s --type f --hidden %s . | awk '{ flag = ($0 ~ /^\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      search_file,
      table.concat(exclude_parts, " ")
    )
  else
    fd_cmd = string.format(
      [[fd --type f --hidden %s . | awk '{ flag = ($0 ~ /^\./ ? 0 : 1); print flag "|" $0 }' | sort -t'|' -k1,1 -k2,2 | cut -d'|' -f2-]],
      table.concat(exclude_parts, " ")
    )
  end

  return fd_cmd
end

--- ファイル検索関数.
-- @param search_file 検索したいファイル名
-- @return string[] or nil
local function get_file_list(search_file)
  local exclude_dirs = default_exclude_dirs
  local use_fd = is_fd_available()

  local cmd
  if use_fd then
    cmd = build_fd_command(exclude_dirs, search_file)
  else
    cmd = build_find_command(exclude_dirs, search_file)
  end
  if debug_mode then
    print(cmd)
  end

  local file_list = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("fd エラー: " .. (file_list[1] or "不明なエラー"), vim.log.levels.ERROR)
    return nil
  end
  return file_list
end

--- fd の結果のパスを `/` と `.` で分割する.
-- @param path string find/fd コマンドでリストアップされたファイルリストの各ファイル
-- @return string[] ファイルのパスを `/` で分割したテーブル
local function split_path(path)
  local splited_path = {}
  local current_text = ""
  for i = 1, #path do
    local char = path:sub(i, i)
    if char:match("[./]") then
      if #current_text > 0 then
        -- 区切り文字が出たらそれまでの文字列を返り値に格納する
        table.insert(splited_path, current_text)
      end
      current_text = ""
    else
      current_text = current_text .. char
    end
  end
  if #current_text > 0 then
    table.insert(splited_path, current_text)
  end
  return splited_path
end

--- 曖昧検索を実行してヒットするか否かを返す関数.
-- @parame text_list string[] `split_path` で分割されたパスが渡されることを想定している
-- @parame pattern string 曖昧検索の検索文字列
-- @return boolean 曖昧検索でヒットすれば `true`, ヒットしなければ `false` を返す
local function fuzzy_match(text_list, pattern)
  local pattern_lower = pattern:lower()
  for _, text in ipairs(text_list) do
    local text_lower = text:lower()
    local pattern_idx = 1
    for text_idx = 1, #text_lower do
      if text_lower:sub(text_idx, text_idx) == pattern_lower:sub(pattern_idx, pattern_idx) then
        pattern_idx = pattern_idx + 1
        if pattern_idx > #pattern_lower then
          return true
        end
      end
    end
  end
  return false
end

--- 引数で渡された find/fd の検索結果を quickfix に挿入する関数.
-- @param file_list string[] quickfix に挿入するファイルのリスト
local function filelist_to_quickfix(file_list)
  local qflist = {}
  for _, file in ipairs(file_list) do
    table.insert(qflist, {
      filename = file,
      lnum = 1,
      text = file
    })
  end
  vim.fn.setqflist(qflist)
  vim.cmd('copen')
end

--- fd で検索してその結果を quickfix に挿入する関数.
-- @param query string fd に渡す検索文字列
local function fd_to_Quickfix(query)
  local file_list = get_file_list(query)
  filelist_to_quickfix(file_list)
  -- Findqfから開かれたことを示すフラグを設定
  quickfix_with_custom_find = true
  display_preview = true
  show_preview()
end

-- FuzzyFindの結果をQuickfixに設定する関数
local function fuzzy_find_to_Quickfix(query)
  local file_list = get_file_list()
  local match_list = {}
  if file_list ~= nil or #file_list > 0 then
    for _, file in ipairs(file_list) do
      local splited_path = split_path(file)
      if fuzzy_match(splited_path, query) then
        table.insert(match_list, file)
      end
    end
  end

  if #match_list == 0 or match_list == nil then
    vim.notify("検索結果が見つかりませんでした: " .. query, vim.log.levels.WARN)
    return
  end

  filelist_to_quickfix(match_list)
  quickfix_with_custom_find = true
  vim.notify(#match_list .. " 件の検索結果が見つかりました", vim.log.levels.INFO)
  display_preview = true
  show_preview()
end

-- Find の結果をQuickfixに表示するコマンド
vim.api.nvim_create_user_command('Findqf', function(opts)
  fd_to_Quickfix(unpack(opts.fargs))
end, {
  nargs = '+',
  desc = 'Find files and show in quickfix'
})

-- Fuzzy find の結果をQuickfixに表示するコマンド
vim.api.nvim_create_user_command('Fzfqf', function(opts)
  local pattern = table.concat(opts.fargs, ' ')
  if pattern == '' then
    vim.notify("検索パターンを指定してください", vim.log.levels.WARN)
    return
  end
  fuzzy_find_to_Quickfix(pattern)
end, {
  nargs = '+',
  desc = 'Fuzzy find files and show in quickfix'
})

--- Grep functions.
-- Grep 検索に関する設定.
-- @section grep

-- Grep 用ラッパーコマンド（silent かつ quickfix にフォーカス）
vim.api.nvim_create_user_command('Grep', function(opts)
  -- すべて silent! で実行し、エラーメッセージも抑制
  vim.cmd('silent! grep ' .. table.concat(opts.fargs, ' '))
  -- QuickFixCmdPost が走った後でも確実に開きたい場合はここでも
  display_preview = true
  vim.cmd('copen')
end, {
  nargs = '+',
})

--- keymap functions.
-- キーマッピングに関する設定.
-- @section keymap

-- キーマッピング
vim.keymap.set('n', '<leader>d',  ':Findqf ', { desc = 'Find file and show in quickfix' })
vim.keymap.set('n', '<leader>z',  ':Fzfqf ',  { desc = 'Fuzzy find files and show in quickfix' })
vim.keymap.set('n', '<leader>gr', ':Grep',    { desc = 'grep wrapper and show in quickfix' })
