local function get_tmux_current_window_id()
  return vim.fn.system("tmux display-message -p '#{window_index}'"):gsub("%s+", "")
end

-- カレントウィンドウに応じた一時ファイルを開くようにする
local file_path = "/tmp/src_pane_" .. get_tmux_current_window_id()

local function file_exist(path)
  if vim.fn.filereadable(path) ~= 0 then
    return true
  else
    vim.notify(path .. " not found", vim.log.levels.ERROR)
    return false
  end
end

local function get_tmux_src_pane_id(path)
  if file_exist(file_path) then
    return vim.fn.readfile(path)[1]:gsub("%s+", "")
  end
end

local function copy_mode_check(current_win_id, pane_id)
  if file_exist(file_path) then
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

local function send_key_tmux(current_win_id, pane_id, key)
  vim.fn.system(string.format(
    "tmux send-keys -t %s.%s %s",
    vim.fn.shellescape(current_win_id),
    vim.fn.shellescape(pane_id),
    vim.fn.shellescape(key)
  ))
end

local function send_buf_text_tmux_pane()
  if file_exist(file_path) then
    local current_win_id = get_tmux_current_window_id()
    local pane_id = get_tmux_src_pane_id(file_path)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, "\n")

    if copy_mode_check(current_win_id, pane_id) then
      copy_mode_off(current_win_id, pane_id)
    end

    send_key_tmux(current_win_id, pane_id, text)
    vim.cmd("%d")
    vim.notify(string.format("Sent to tmux pane (%s.%s)", current_win_id, pane_id))
  end
end

local function send_key_tmux_pane(key)
  if file_exist(file_path) then
    local current_win_id = get_tmux_current_window_id()
    local pane_id = get_tmux_src_pane_id(file_path)
    send_key_tmux(current_win_id, pane_id, key)
  end
end

local function scroll_src_pane(key)
  local current_win_id = get_tmux_current_window_id()
  local pane_id = get_tmux_src_pane_id(file_path)

  if copy_mode_check(current_win_id, pane_id) == false then
    copy_mode_on(current_win_id, pane_id)
  end

  send_key_tmux_pane(key)
end

vim.keymap.set("n", "<C-s>", send_buf_text_tmux_pane, { desc = "Send buf text to tmux pane" })
vim.keymap.set("n", "<C-g>q", function()
    send_buf_text_tmux_pane()
    vim.cmd('quit!')
  end,
  { desc = "Send buf text to tmux pane & vim quit!" }
)
vim.keymap.set("n", "<Up>", function() send_key_tmux_pane('Up') end, { desc = "Send <up> cursor to tmux pane" })
vim.keymap.set("n", "<Down>", function() send_key_tmux_pane('Down') end, { desc = "Send <down> cursor to tmux pane" })
vim.keymap.set("n", "<C-g><ESC>", function() send_key_tmux_pane('Escape') end,
  { desc = "Send <Escape> cursor to tmux pane" })
vim.keymap.set("n", "<C-g>c", function() send_key_tmux_pane('C-c') end, { desc = "Send <Ctrl-c> to tmux pane" })
vim.keymap.set("n", "<C-g>u", function() send_key_tmux_pane('C-u') end, { desc = "Send <Ctrl-u to tmux pane" })
vim.keymap.set("n", "<Enter>", function() send_key_tmux_pane('Enter') end, { desc = "Send <Enter> to tmux pane" })
vim.keymap.set("n", "<BS>", function() send_key_tmux_pane('BSpace') end, { desc = "Send <BackSpace> to tmux pane" })
vim.keymap.set("n", "<PageUp>", function() scroll_src_pane('PageUp') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<PageDown>", function() scroll_src_pane('PageDown') end, { desc = "scroll tmux pane(down)" })
vim.keymap.set("n", "<M-u>", function() scroll_src_pane('C-u') end, { desc = "scroll tmux pane(up)" })
vim.keymap.set("n", "<M-d>", function() scroll_src_pane('C-d') end, { desc = "scroll tmux pane(down)" })
