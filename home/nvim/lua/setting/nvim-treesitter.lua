vim.filetype.add({ extension = { ejs = "ejs" } })
vim.treesitter.language.register("html", "ejs")
vim.treesitter.language.register("bash", { "sh", "zsh" })

-- nvim-treesitter main ブランチの設定
-- (main ブランチでは ensure_installed, highlight.enable 等は廃止)
require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site',
}

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = {
    "bash",
    "markdown",
    "lua",
    "vim",
    "nix",
    "tmux",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html",
    "cssls",
    "scss",
    "ruby",
    "python3",
    "clang"
  },
  callback = function()
    -- syntax highlighting, provided by Neovim
    vim.treesitter.start()
    -- folds, provided by Neovim
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    -- indentation, provided by nvim-treesitter
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

