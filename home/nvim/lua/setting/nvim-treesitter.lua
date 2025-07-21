-- ビルトインTreesitter機能を完全に無効化
vim.treesitter.start = function() end
vim.treesitter.stop = function() end

-- nvim-treesitterの通常設定
require('nvim-treesitter.configs').setup {
  parser_install_dir = vim.fn.stdpath("data") .. "/treesitter",
  ensure_installed = {
    "lua",
    "vim",
    "vimdoc",
    "markdown",
    "markdown_inline",
    "c",
    "bash",
    "html",
    "css",
    "scss",
    "javascript",
    "typescript",
    "json",
    "ruby",
    "python",
    "nix",
  },
  auto_install = true,
  sync_install = false,
  highlight = {
    enable = true,
  },
}

-- パーサーディレクトリを追加
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/treesitter")
