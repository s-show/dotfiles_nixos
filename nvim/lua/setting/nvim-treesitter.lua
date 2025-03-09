require("nvim-treesitter.configs").setup({
  ensure_installed = {
  },
  sync_install = false,
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
})
vim.wo.foldmethod = 'manual'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
