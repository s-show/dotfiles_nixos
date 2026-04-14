local file_path = "/tmp/src_pane"
local function file_exist(path)
  if vim.fn.filereadable(path) ~= 0 then
    return true
  else
    vim.notify(path .. " not found", vim.log.levels.ERROR)
    return false
  end
end

local function get_tmux_src_pane(path)
  if file_exist(file_path) then
    return vim.fn.readfile(path)[1]:gsub("%s+", "")
  end
end

local function send_buf_text_tmux_pane()
  if file_exist(file_path) then
    local pane_id = get_tmux_src_pane(file_path)
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, "\n")

    vim.fn.system(string.format(
      "tmux send-keys -t %s %s",
      vim.fn.shellescape(pane_id),
      vim.fn.shellescape(text)
    ))
    vim.cmd("%d")
    -- vim.notify(string.format("Sent to tmux pane (%s)", pane_id))
  end
end

local function send_key_tmux_pane(key)
  if file_exist(file_path) then
    local pane_id = get_tmux_src_pane(file_path)
    local cmd_str = "tmux send-keys -t %s " .. key
    vim.fn.system(
      string.format(cmd_str, vim.fn.shellescape(pane_id))
    )
  end
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
vim.keymap.set("n", "<C-g><ESC>", function() send_key_tmux_pane('Escape') end, { desc = "Send <Escape> cursor to tmux pane" })
vim.keymap.set("n", "<C-g>c", function() send_key_tmux_pane('C-c') end, { desc = "Send <Ctrl-c> cursor to tmux pane" })
vim.keymap.set("n", "<Enter>", function() send_key_tmux_pane('Enter') end, { desc = "Send <Enter> cursor to tmux pane" })
