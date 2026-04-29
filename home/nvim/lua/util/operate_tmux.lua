local M = {}

--- Tmux の現在のウィンドウ番号を返す
---@return string
function M.get_tmux_current_window_id()
  -- 空白文字があると思わぬトラブルになるので削除しておく
  return (vim.fn.system("tmux display-message -p '#{window_index}'"):gsub("%s+", ""))
end

-- カレントウィンドウに応じた一時ファイルを開くようにする
M.aitool_pane_path = "/tmp/nvim_ime_aitool_pane_" .. M.get_tmux_current_window_id()
M.input_pane_path  = "/tmp/nvim_ime_input_pane_" .. M.get_tmux_current_window_id()

--- Tmux のペイン番号を格納したファイルの存在を確認する
--- @param path string
function M.file_exist(path)
  if vim.fn.filereadable(path) ~= 0 then
    return true
  else
    vim.notify(path .. " not found", vim.log.levels.ERROR)
    return false
  end
end

--- Tmux のペイン番号をファイルから読み取って返す
---@param path string
function M.get_tmux_pane_id(path)
  if M.file_exist(path) then
    -- 空白文字があると思わぬトラブルになるので削除しておく
    return (vim.fn.readfile(path)[1]:gsub("%s+", ""))
  end
end

--- Tmux のペインで AI ツールが起動しているかチェックする
---@return boolean, string
function M.aitool_exist()
  -- 1. カレントウィンドウの全てのペインの情報（識別子とPID）を取得
  local tmux_cmd = 'tmux list-panes -F "#{window_index} #{pane_index} #{pane_pid}"'
  local panes = vim.fn.systemlist(tmux_cmd)
  -- gemini 以外は pid からアプリ名
  local aitools = {
    'codex',
    'claude',
    'gemini',
    'opencode',
  }
  local result = false

  for _, line in ipairs(panes) do
    -- スペースで分割
    local parts = vim.split(line, " ")
    if #parts >= 3 then
      local win_info  = parts[1]
      local pane_info = parts[2]
      local pid       = parts[3]

      if win_info ~= M.get_tmux_current_window_id() then
        return result, ''
      end
      if pane_info ~= M.get_tmux_pane_id(M.aitool_pane_path) then
        return result, ''
      end

      -- 2. pgrep でその PID の子プロセスで AIツール が起動しているか確認
      for _, aitool in ipairs(aitools) do
        local pgrep_cmd = string.format('pgrep -P %s -f ' .. aitool, pid)
        vim.fn.system(pgrep_cmd)
        -- 終了ステータス (v:shell_error) が 0 なら見つかったということ
        if vim.v.shell_error == 0 then
          result = true
          return result, aitool
        end
      end
    end
  end
  return result, ''
end

--- 指定したペインがコピーモードに入っているかチェックする
---@param current_win_id string
---@param pane_id string
function M.copy_mode_check(current_win_id, pane_id)
  if M.file_exist(M.aitool_pane_path) then
    local cmd_str = "tmux display-message -p -t %s.%s '#{pane_in_mode}'"
    local pane_mode = vim.fn.system(
      string.format(cmd_str,
        vim.fn.shellescape(current_win_id),
        vim.fn.shellescape(pane_id))
    ):gsub("%s+", "")
    -- コピーモードだと 1 が返ってくる
    if pane_mode == "1" then
      return true
    else
      return false
    end
  end
end

--- 指定したペインがコピーモードなら通常モードに切り替える
---@param current_win_id string
---@param pane_id string
function M.copy_mode_off(current_win_id, pane_id)
  vim.fn.system(string.format(
    "tmux copy-mode -q -t %s.%s",
    vim.fn.shellescape(current_win_id),
    vim.fn.shellescape(pane_id)
  ))
end

--- 指定したペインが通常モードならコピーモードに切り替える
---@param current_win_id string
---@param pane_id string
function M.copy_mode_on(current_win_id, pane_id)
  if M.copy_mode_check(current_win_id, pane_id) == false then
    vim.fn.system(string.format(
      "tmux copy-mode -t %s.%s",
      vim.fn.shellescape(current_win_id),
      vim.fn.shellescape(pane_id)
    ))
  end
end

--- 指定したペインにキーを送信する
--- 汎用性を持たせるため、キー送信以外の処理は持たせていない
---@param current_win_id string
---@param pane_id string
---@param key string
function M.send_key_tmux(current_win_id, pane_id, key)
  vim.fn.system(string.format(
    "tmux send-keys -t %s.%s %s",
    vim.fn.shellescape(current_win_id),
    vim.fn.shellescape(pane_id),
    vim.fn.shellescape(key)
  ))
end

--- 指定したペインにテキストを送信する
--- 直接送信だと改行コードが失われるので一時ファイルを経由している
---@param pane_path string
---@param text string
function M.send_prompt_tmux_pane(pane_path, text)
  if M.file_exist(pane_path) then
    local current_win_id = M.get_tmux_current_window_id()
    local pane_id = M.get_tmux_pane_id(pane_path)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if text == nil then
      text = table.concat(lines, "\n")
    end

    local tmpfile = os.tmpname()
    local f = io.open(tmpfile, "w")
    if f == nil then
      return
    end
    f:write(text)
    f:close()

    if M.copy_mode_check(current_win_id, pane_id) then
      M.copy_mode_off(current_win_id, pane_id)
    end

    vim.fn.system(string.format(
      "tmux load-buffer -t %s %s && tmux paste-buffer -p -t %s.%s",
      vim.fn.shellescape(current_win_id),
      vim.fn.shellescape(tmpfile),
      vim.fn.shellescape(current_win_id),
      vim.fn.shellescape(pane_id)
    ))

    os.remove(tmpfile)
    -- 送信先が AI ペインかプロンプトペインかで処理を分ける
    if string.match(pane_path, "aitool") ~= nil then
      vim.cmd("%d")
    else
      vim.fn.system(string.format(
        "tmux select-pane -t %s ",
        vim.fn.shellescape(pane_id)
      ))
    end
  end
end

--- AI ツールが起動しているペインにキーを送信する
--- 必要な情報を収集して send_key_tmux 関数に渡す役目を担っている
---@param key string
function M.send_key_tmux_frontend(key)
  if M.file_exist(M.aitool_pane_path) then
    local current_win_id = M.get_tmux_current_window_id()
    local pane_id = M.get_tmux_pane_id(M.aitool_pane_path)
    M.send_key_tmux(current_win_id, pane_id, key)
  end
end

--- AI ツールが起動しているペインをスクロールする
--- 必要な情報を収集して send_key_tmux 関数に渡す役目を担っている
---@param key string
function M.scroll_src_pane(key)
  if M.file_exist(M.aitool_pane_path) then
    local current_win_id = M.get_tmux_current_window_id()
    local pane_id = M.get_tmux_pane_id(M.aitool_pane_path)
    local _, aitool_name = M.aitool_exist()

    -- OpenCode はコピーモードになっているとスクロールできないのでコピーモードを解除しておく
    if aitool_name == 'opencode' then
      if M.copy_mode_check(current_win_id, pane_id) then
        M.copy_mode_off(current_win_id, pane_id)
      end
    else
      -- OpenCode 以外はコピーモードでなければスクロールできないのでコピーモードに移行しておく
      if M.copy_mode_check(current_win_id, pane_id) == false then
        M.copy_mode_on(current_win_id, pane_id)
      end
    end

    M.send_key_tmux(current_win_id, pane_id, key)
  end
end

return M
