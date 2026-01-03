-- ビルトインTreesitter機能を完全に無効化
vim.treesitter.start = function() end
vim.treesitter.stop = function() end

-- nvim-treesitterの通常設定
require('nvim-treesitter.configs').setup {
  parser_install_dir = vim.fn.stdpath("data") .. "/treesitter",
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

vim.filetype.add({ extension = { ejs = "ejs" } })
vim.treesitter.language.register("html", "ejs")

-- パーサーディレクトリを追加
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/treesitter")
