local function get_tmux_current_window_id()
  return vim.fn.system("tmux display-message -p '#{window_index}'"):gsub("%s+", "")
end

-- カレントウィンドウに応じた一時ファイルを開くようにする
local path_for_src_pane = "/tmp/src_pane_" .. get_tmux_current_window_id()
local path_for_prompt_pane = "/tmp/prompt_pane_" .. get_tmux_current_window_id()

local function file_exist(path)
  if vim.fn.filereadable(path) ~= 0 then
    return true
  else
    vim.notify(path .. " not found", vim.log.levels.ERROR)
    return false
  end
end

local function get_tmux_pane_id(path)
  if file_exist(path) then
    return vim.fn.readfile(path)[1]:gsub("%s+", "")
  end
end

local function aitool_exist()
  -- 1. カレントウィンドウの全てのペインの情報（識別子とPID）を取得
  local tmux_cmd = 'tmux list-panes -F "#{window_index} #{pane_index} #{pane_pid}"'
  local panes    = vim.fn.systemlist(tmux_cmd)
  local aitools  = {
    'codex',
    'claude',
    'gemini',
    'opencode',
  }
  local result   = false

  for _, line in ipairs(panes) do
    -- スペースで分割
    local parts = vim.split(line, " ")
    if #parts >= 3 then
      local win_info  = parts[1]
      local pane_info = parts[2]
      local pid       = parts[3]

      if win_info ~= get_tmux_current_window_id() then
        vim.print('not equal win id')
        return
      end
      if pane_info ~= get_tmux_pane_id(path_for_src_pane) then
        vim.print('not equal pane id')
        return
      end

      -- 2. pgrep でその PID の子プロセスで AIツール が起動しているか確認
      for _, aitool in ipairs(aitools) do
        local pgrep_cmd = string.format('pgrep -P %s -f ' .. aitool, pid)
        vim.fn.system(pgrep_cmd)
        -- 終了ステータス (v:shell_error) が 0 なら見つかったということ
        if vim.v.shell_error == 0 then
          result = true
          return result
        end
      end
    end
  end
  return result
end

local function copy_mode_check(current_win_id, pane_id)
  if file_exist(path_for_src_pane) then
    local cmd_str = "tmux display-message -p -t %s.%s '#{pane_in_mode}'"
    local pane_mode = vim.fn.system(
      string.format(cmd_str,
        vim.fn.shellescape(current_win_id),
        vim.fn.shellescape(pane_id))
    ):gsub("%s+", "")
    if pane_mode == "1" then
      return true
    else
      return false
    end
  end
end

local function copy_mode_off(current_win_id, pane_id)
  vim.fn.system(string.format(
    "tmux copy-mode -q -t %s.%s",
    vim.fn.shellescape(current_win_id),
    vim.fn.shellescape(pane_id)
  ))
end

local function copy_mode_on(current_win_id, pane_id)
  if copy_mode_check() == false then
    vim.fn.system(string.format(
      "tmux copy-mode -t %s.%s",
      vim.fn.shellescape(current_win_id),
      vim.fn.shellescape(pane_id)
    ))
  end
end

local function send_text_tmux_pane(opts)
  if file_exist(path_for_prompt_pane) then
    local current_win_id = get_tmux_current_window_id()
    local pane_id = get_tmux_pane_id(path_for_prompt_pane)
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
    -- vim.notify(string.format("first line: [%s]", lines[1]))
    local text = table.concat(lines, "\n") .. "\n"

    local tmpfile = os.tmpname()
    local f = io.open(tmpfile, "w")
    if f == nil then
      return
    end
    f:write(text)
    f:close()

    vim.fn.system(string.format(
      "tmux load-buffer -t %s %s && tmux paste-buffer -p -t %s.%s",
      vim.fn.shellescape(current_win_id),
      vim.fn.shellescape(tmpfile),
      vim.fn.shellescape(current_win_id),
      vim.fn.shellescape(pane_id)
    ))

    os.remove(tmpfile)
    vim.fn.system(string.format(
      "tmux select-pane -t %s ",
      vim.fn.shellescape(pane_id)
    ))
  end
end

local function send_key_tmux(current_win_id, pane_id, key)
  vim.fn.system(string.format(
    "tmux send-keys -t %s.%s %s",
    vim.fn.shellescape(current_win_id),
    vim.fn.shellescape(pane_id),
    vim.fn.shellescape(key)
  ))
end

local function send_key_tmux_frontend(key)
  vim.print(aitool_exist())
  if file_exist(path_for_src_pane) and aitool_exist() then
    local current_win_id = get_tmux_current_window_id()
    local pane_id = get_tmux_pane_id(path_for_src_pane)
    send_key_tmux(current_win_id, pane_id, key)
  end
end

-- local function send_text_tmux_pane(opts)
--   if file_exist(path_for_prompt_pane) then
--     local current_win_id = get_tmux_current_window_id()
--     local pane_id = get_tmux_pane_id(path_for_prompt_pane)
--     local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
--     local text = table.concat(lines, "\n")
--
--     send_key_tmux(current_win_id, pane_id, text)
--   end
-- end

local function scroll_src_pane(key)
  if file_exist(path_for_src_pane) and aitool_exist() then
    local current_win_id = get_tmux_current_window_id()
    local pane_id = get_tmux_pane_id(path_for_src_pane)

    if copy_mode_check(current_win_id, pane_id) == false then
      copy_mode_on(current_win_id, pane_id)
    end

    send_key_tmux(current_win_id, pane_id, key)
  end
end

-- 実行用のコマンドを作成
vim.api.nvim_create_user_command('SendTextTmux', send_text_tmux_pane, { range = "%" })

vim.keymap.set("n", "<Enter>", function() send_key_tmux_frontend('Enter') end, { desc = "Send <Enter> to tmux pane" })
vim.keymap.set("n", "<PageUp>", function() scroll_src_pane('PageUp') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<PageDown>", function() scroll_src_pane('PageDown') end, { desc = "scroll tmux pane(down)" })
vim.keymap.set("n", "<M-u>", function() scroll_src_pane('C-u') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<M-d>", function() scroll_src_pane('C-d') end, { desc = "scroll tmux pane(down)" })
