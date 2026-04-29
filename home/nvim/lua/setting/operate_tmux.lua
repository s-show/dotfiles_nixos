local function send_selected_text_input_pane(opts)
  local tmux_operate = require('util.operate_tmux')
  local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
  local text = table.concat(lines, "\n")
  tmux_operate.send_prompt_tmux_pane(tmux_operate.input_pane_path, text)
end

vim.api.nvim_create_user_command(
  'SendSelectedText',
  send_selected_text_input_pane,
  { range = true }
)
