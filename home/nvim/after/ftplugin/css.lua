-- LSP の自動インポートを有効化するための設定
vim.fn["ddc#custom#patch_filetype"]({ 'css' }, {
  sourceParams = {
    lsp = {
      enableResolveItem = true,
    }
  }
})
