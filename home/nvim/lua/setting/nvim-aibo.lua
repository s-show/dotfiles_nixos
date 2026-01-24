-- nvim-aibo ウィンドウ設定
-- 要件:
--   1. 縦分割で必ず左端に表示
--   2. ウィンドウ幅はアプリの幅の30%
--   3. <C-w>= でも幅は30%に固定

local AIBO_WIDTH_RATIO = 0.3

-- aiboバッファかどうかを判定
local function is_aibo_buffer(buf)
  local ft = vim.bo[buf].filetype
  return ft:match('^aibo%-') ~= nil
end

-- aiboウィンドウの幅を30%に固定する関数
local function fix_aibo_window_width()
  local target_width = math.floor(vim.o.columns * AIBO_WIDTH_RATIO)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if is_aibo_buffer(buf) then
      vim.api.nvim_win_set_width(win, target_width)
      vim.wo[win].winfixwidth = true
    end
  end
end

-- aiboウィンドウを開いたときに winfixwidth を設定
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'aibo-console.*', 'aibo-prompt.*' },
  callback = function()
    local win = vim.api.nvim_get_current_win()
    vim.wo[win].winfixwidth = true
    -- 少し遅延させて幅を設定（ウィンドウが完全に開いてから）
    vim.defer_fn(fix_aibo_window_width, 10)
  end,
})

-- <C-w>= をリマップして、aiboウィンドウを除外
vim.keymap.set('n', '<C-w>=', function()
  -- まず通常の均等化を実行
  vim.cmd('wincmd =')
  -- その後、aiboウィンドウの幅を再設定
  fix_aibo_window_width()
end, { desc = 'Equalize windows (keep aibo width fixed)' })

-- ターミナルサイズが変わったときも対応
vim.api.nvim_create_autocmd('VimResized', {
  callback = fix_aibo_window_width,
})

-- Key mapping for quick access
vim.keymap.set('n', '<leader>ac', function()
  local width = math.floor(vim.o.columns * AIBO_WIDTH_RATIO)
  -- topleft で左端に開く
  vim.cmd(string.format('Aibo -opener="topleft %dvsplit" -toggle claude', width))
end, { desc = 'Open Claude AI assistant' })
