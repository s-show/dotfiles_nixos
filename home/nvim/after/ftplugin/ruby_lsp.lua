-- LSP の自動インポートを有効化するための設定
vim.fn["ddc#custom#patch_filetype"]({ 'ruby' }, {
  sourceParams = {
    lsp = {
      enableResolveItem = true,
    }
  }
})
vim.notify('attach c filetype')
