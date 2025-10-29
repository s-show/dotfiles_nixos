-- BlinkCmpMenu のハイライトグループ設定
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, 'BlinkCmpMenuCustom', {
      fg = '#C0C0C0',  -- 銀色
      bg = 'NONE',     -- 背景は透過（テーマの背景色を使用）
    })
  end,
})

-- 初回読み込み時にも適用
vim.api.nvim_set_hl(0, 'BlinkCmpMenuCustom', {
  fg = '#C0C0C0',
  bg = 'NONE',
})
