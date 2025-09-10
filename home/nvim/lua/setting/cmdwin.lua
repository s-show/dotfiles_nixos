-- cmdwin の高さを 10行に設定
vim.opt.cmdwinheight = 10

-- 曖昧検索の実装
local function fuzzy_match(str, pattern)
  if #pattern == 0 then return true end

  -- 区切り文字で分割
  local segments = {}
  local current = ""

  for i = 1, #str do
    local char = str:sub(i, i)
    if char:match("[%.%s/_%(%)%[%]{}'\",;:!?<>|\\-]") then
      if #current > 0 then
        table.insert(segments, current)
      end
      current = ""
    else
      current = current .. char
    end
  end
  if #current > 0 then
    table.insert(segments, current)
  end

  -- 各セグメントで曖昧検索
  local pattern_lower = pattern:lower()
  for _, segment in ipairs(segments) do
    local seg_lower = segment:lower()
    local p_idx = 1

    for s_idx = 1, #seg_lower do
      if seg_lower:sub(s_idx, s_idx) == pattern_lower:sub(p_idx, p_idx) then
        p_idx = p_idx + 1
        if p_idx > #pattern_lower then
          return true
        end
      end
    end
  end
  return false
end

-- コマンドラインを使ったインタラクティブ曖昧検索
local function cmdline_fuzzy_search()
  local buf = vim.api.nvim_get_current_buf()
  local original_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  vim.b.cmdwin_original_lines = original_lines

  -- 検索状態を保持
  local search_active = true
  local last_query = ""

  -- autocmdグループを作成
  local group = vim.api.nvim_create_augroup('CmdwinFuzzySearch', { clear = true })

  -- コマンドラインでの入力を開始
  vim.api.nvim_feedkeys(':', 'n', false)

  -- CmdlineChangedイベントでリアルタイムフィルタリング
  vim.api.nvim_create_autocmd('CmdlineChanged', {
    group = group,
    callback = function()
      if not search_active then return end

      local query = vim.fn.getcmdline()
      last_query = query

      if query == '' then
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, original_lines)
      else
        local filtered = {}
        for _, line in ipairs(original_lines) do
          if fuzzy_match(line, query) then
            table.insert(filtered, line)
          end
        end

        if #filtered > 0 then
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, filtered)
        else
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, { '-- No matches found --' })
        end
      end

      -- コマンドラインを再描画
      vim.cmd('redraw')
    end
  })

  -- Enterキーで検索を確定
  vim.api.nvim_create_autocmd('CmdlineEnter', {
    group = group,
    once = true,
    callback = function()
      vim.keymap.set('c', '<CR>', function()
        search_active = false
        vim.api.nvim_clear_autocmds({ group = group })
        -- 空のコマンドを実行してコマンドラインを閉じる
        return '<C-u><Esc>'
      end, { expr = true, buffer = true })
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
      -- <Esc> で検索結果を破棄して元に戻す
      vim.keymap.set('n', '<Esc>', function()
        local buf = vim.api.nvim_get_current_buf()
        local original = vim.b.cmdwin_original_lines
        if original then
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, original)
          vim.b.cmdwin_original_lines = nil
        end
      end, { buffer = true, desc = 'Cancel fuzzy search and restore' })
    end
  }
)
