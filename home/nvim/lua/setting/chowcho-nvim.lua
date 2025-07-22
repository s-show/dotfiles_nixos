local chowcho = require('chowcho')
chowcho.setup({
  -- Must be a single character. The length of the array is the maximum number of windows that can be moved.
  labels = { "A", "B", "C", "D", "E", "F", "G", "H", "I" },
  use_exclude_default = true,
  ignore_case = true,
  selector = {
    float = {
      border_style = "rounded",
      icon_enabled = true,
      color = {
        label = {
          active = "#ff9966",
          inactive = "#a52a2a",
        },
        text = {
          active = "#a4c639",
          inactive = "#87a96b",
        },
        border = {
          active = "#ffbf00",
          inactive = "#e9d66b",
        },
      },
      zindex = 1,
    },
    statusline = {
      color = {
        label = {
          active = "#fefefe",
          inactive = "#d0d0d0",
        },
        text = {
          active = "#fefefe",
          inactive = "#d0d0d0",
        },
        background = {
          active = "#3d7172",
          inactive = "#203a3a",
        },
      },
    },
  },
})

-- [Neovimの<C-w><C-w>をchowcho.nvimで拡張する](https://zenn.dev/kawarimidoll/articles/daa39da5838567)
local win_keymap_set = function(key, callback)
  vim.keymap.set({ 'n', 't' }, '<C-w>' .. key, callback)
  vim.keymap.set({ 'n', 't' }, '<C-w><C-' .. key .. '>', callback)
end

win_keymap_set('w',
  function()
    local wins = 0

    -- 全ウィンドウをループ
    for i = 1, vim.fn.winnr('$') do
      local win_id = vim.fn.win_getid(i)
      local conf = vim.api.nvim_win_get_config(win_id)

      -- focusableなウィンドウをカウント
      if conf.focusable then
        wins = wins + 1

        -- ウィンドウ数が3以上ならchowchoを起動
        if wins > 2 then
          chowcho.run()
          return
        end
      end
    end

    -- ウィンドウが少なければ標準の<C-w><C-w>を実行
    vim.api.nvim_command('wincmd w')
  end
)
