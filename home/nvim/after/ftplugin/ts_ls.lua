-- LSP の自動インポートを有効化するための設定
vim.fn["ddc#custom#patch_filetype"]({
  'javascript',
  'typescript',
  'javascriptreact',
  'typescriptreact',
}, {
  sourceParams = {
    lsp = {
      enableResolveItem = true,
    }
  }
})
