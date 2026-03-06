-- ビルトインTreesitter機能を完全に無効化
-- vim.treesitter.start = function() end
-- vim.treesitter.stop = function() end

vim.filetype.add({ extension = { ejs = "ejs" } })
vim.treesitter.language.register("html", "ejs")

-- パーサーディレクトリを追加
-- vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/treesitter")

-- nvim-treesitterの通常設定
require('nvim-treesitter').setup {
  ensure_installed = {},
  auto_install = false,
  sync_install = false,
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true
  },
  textobjects = {
    enable = true
  },
}

-- vim.api.nvim_create_autocmd("FileType", {
--   group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
--   callback = function(ctx)
--     -- 必要に応じて`ctx.match`に入っているファイルタイプの値に応じて挙動を制御
--     -- `pcall`でエラーを無視することでパーサーやクエリがあるか気にしなくてすむ
--     pcall(vim.treesitter.start)
--   end,
-- })
