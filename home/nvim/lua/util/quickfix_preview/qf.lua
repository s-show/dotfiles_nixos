--- Quickfix リスト管理モジュール.
-- @module quickfix_preview.qf

local M = {}

--- 引数で渡された find/fd の検索結果を quickfix に挿入する.
-- @param file_list string[] quickfix に挿入するファイルのリスト
function M.populate_files(file_list)
  if not file_list or #file_list == 0 then
    return
  end
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

--- 現在のquickfixアイテムを取得.
-- @return table|nil 現在のアイテム
function M.current_item()
  local qflist = vim.fn.getqflist()
  local current_line = vim.fn.line('.')

  if current_line < 1 or current_line > #qflist then
    return nil
  end

  return qflist[current_line]
end

--- Quickfix ウィンドウのアイテムを垂直/水平分割で開く.
-- @param split_cmd string 垂直/水平分割の指定 ('vsplit' or 'split')
-- @param close boolean アイテムを開いた後にquickfixを閉じるか否かを指定
function M.open_in_split(split_cmd, close)
  if close == nil then
    close = true
  end
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
  if close == false then
    vim.cmd('copen')  -- Quickfix ウィンドウを再度開く
  end
  if split_cmd == 'split' then
    vim.cmd('vertical wincmd =')
  end
end

--- バッファリストをquickfixに送る.
function M.populate_buffers()
  -- リストされているバッファのみ取得
  local bufinfos = vim.fn.getbufinfo({ buflisted = 1 })

  -- lastused でソート（最近使用したものが上に）
  table.sort(bufinfos, function(a, b)
    return (a.lastused or 0) > (b.lastused or 0)
  end)

  local qflist = {}
  for _, bufinfo in ipairs(bufinfos) do
    -- 名前のないバッファや特殊なURIスキームは除外
    if bufinfo.name ~= '' and not bufinfo.name:match('^%w+://') then
      local text = vim.fn.fnamemodify(bufinfo.name, ':~:.')
      -- 変更されているバッファには [+] を追加
      if bufinfo.changed == 1 then
        text = text .. ' [+]'
      end

      table.insert(qflist, {
        bufnr = bufinfo.bufnr,
        lnum = bufinfo.lnum or 1,
        col = 1,
        text = text
      })
    end
  end

  -- quickfixリストを設定
  vim.fn.setqflist({}, 'r', { items = qflist, title = 'buffer list' })

  if #qflist > 0 then
    vim.cmd('copen')
    return true
  else
    vim.notify('表示可能なバッファがありません', vim.log.levels.WARN)
    return false
  end
end

-- ファイル履歴をquickfixに送る
function M.populate_oldfiles()
  local oldfiles = vim.v.oldfiles
  local qflist = {}
  for _, oldfile in ipairs(oldfiles) do
    if oldfile ~= '' then
      table.insert(qflist, {
        filename = oldfile,
        lnum     = 1,
        col      = 1,
        text     = oldfile
      })
    end
  end

  -- quickfixリストを設定
  vim.fn.setqflist({}, 'r', { items = qflist, title = 'oldfile list' })

  if #qflist > 0 then
    vim.cmd('copen')
    return true
  else
    vim.notify('表示可能なファイル履歴がありません', vim.log.levels.WARN)
    return false
  end
end

return M
